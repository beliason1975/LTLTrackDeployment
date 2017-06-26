USE [RoadrunnerCentral]
GO

/****** Object:  StoredProcedure [dbo].[GetMcleodTrackingByPickup]    Script Date: 06/22/2017 5:20:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetMcleodTrackingByPickup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetMcleodTrackingByPickup] AS'
END
GO



-- =============================================
-- Author:        Dan Paluszynski
-- Create date: 7/25/2016
-- Description:    Get Mcleod shipment tracking information by Pickup Number
-- =============================================
ALTER PROCEDURE [dbo].[GetMcleodTrackingByPickup]
    @PickupNbr CHAR(8)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @vErrMessage NVARCHAR (1000)

        ------------------------------------------------------------------------------
        --***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***
        --SET @@PickupNbr char(8) = '21754384'
        --***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***
        ------------------------------------------------------------------------------

        SELECT
            o.id as [McLeodOrderNbr],
            @PickupNbr as [PickupRequestNbr],  --2
            o.coyote_pu_no,
            fg.pro_nbr as [ProNbr],  --4
            o.operational_status as [OperationalStatus],
            RTRIM(ship.location_name) as [ShipperName],  --6
            RTRIM(ship.[address]) as [ShipperAddress],
            RTRIM(ship.address2) as [ShipperAddress2],  --8
            RTRIM(ship.city_name) as [ShipperCity],
            RTRIM(ship.state) as [ShipperState],  --10
            ship.zip_code as [ShipperZip],
            RTRIM(con.location_name) as [ConsigneeName],  --12
            RTRIM(con.[address]) as [ConsigneeAddress],
            RTRIM(con.address2) as [ConsigneeAddress2],  --14
            RTRIM(con.city_name) as [ConsigneeCity],
            CASE WHEN RTRIM(con.[state]) = 'XX' THEN NULL ELSE RTRIM(con.[state]) END as [ConsigneeState],  --16
            CASE WHEN RTRIM(con.zip_code) = '99999' THEN NULL ELSE RTRIM(con.zip_code) END as [ConsigneeZip],
            ship.sched_arrive_early as [SchedArriveEarly],  --18
            ship.sched_arrive_late as [SchedArriveLate],
            CASE WHEN o.operational_status = 'PICK' THEN ship.actual_departure ELSE NULL END as [ActualDeparture],  --20
            ship.projected_arrival  as [ProjectedArrival],
            RTRIM(ship.id) as [StopID],  --22
            o.shipper_stop_id,
            o.consignee_stop_id,  --24
            o.[weight],
            o.Pieces,  --26
            fg.ship_ref_nbr,
            fg.cons_ref_nbr,  --28
            o.[status],
            RTRIM(l.LocationCode) as [LocationCode],  --30
            RTRIM(l.LocationName) as [LocationName],
            RTRIM(l.Phone) as [Phone], --32
            ship.operational_status as [PUStopOpStatus],
            ship.actual_arrival as [PUStopActualArrival], --34
            o.ordered_date as [OrderDate]
        FROM MCLEOD.lme_1510_ltl.dbo.orders o
            LEFT JOIN MCLEOD.lme_1510_ltl.dbo.stop ship ON --Shipper Info
                o.shipper_stop_id = ship.id AND
                o.company_id = ship.company_id AND
                ship.stop_type = 'PU'
            LEFT JOIN MCLEOD.lme_1510_ltl.dbo.stop con ON  --Consignee Info
                o.consignee_stop_id = con.id AND
                o.company_id = con.company_id AND
                con.stop_type = 'SO'
            LEFT JOIN MCLEOD.lme_1510_ltl.dbo.[freight_group] fg ON
                o.id = fg.lme_order_id AND
                o.company_id = fg.company_id AND
                ISNULL(fg.pro_nbr,'') <> ''
            LEFT JOIN (SELECT
                        RTRIM(LocationCode) AS [LocationCode],
                        RTRIM(LocationName) AS [LocationName],
                        RTRIM(lcm.Value) AS [Phone]
                    FROM [dbo].[Location] l
                        LEFT JOIN [dbo].[LocationContactMethodValue] lcm
                            ON l.LocationID = lcm.LocationID
                        INNER JOIN [dbo].[ContactMethod] cm
                            ON lcm.ContactMethodID = cm.ContactMethodID
                    WHERE cm.[ContactMethodID] = 21) l ON
                RTRIM(ship.zone_id) = RTRIM(l.LocationCode)
        WHERE --o.operational_status = 'PICK' AND
            (o.coyote_pu_no = @PickupNbr OR o.id = @PickupNbr)
            --AND o.ordered_date > DATEADD(MM, -3, GETDATE())



End

GO


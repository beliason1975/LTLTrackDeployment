USE [RoadrunnerCentral]
GO

/****** Object:  StoredProcedure [dbo].[McleodTrackingByProNbrGet]    Script Date: 06/18/2017 6:56:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[McleodTrackingByProNbrGet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[McleodTrackingByProNbrGet] AS'
END
GO

-- =============================================
-- Author:		Dan Paluszynski
-- Create date: 6/28/2016
-- Description:	Get Mcleod shipment tracking information by Pro Number
-- =============================================
ALTER PROCEDURE [dbo].[McleodTrackingByProNbrGet]
	@ProNumber varchar(50) = NULL,
	@StopID varchar(32) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @vErrMessage NVARCHAR (1000)

	BEGIN TRY
		------------------------------------------------------------------------------
		--***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***
		--SET @ProNumber varchar(50) = '344811138'
		--SET @StopID varchar(32) = 'zz1a6obgqac0f3slappd01'
		--***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***
		------------------------------------------------------------------------------
		IF ISNULL(@ProNumber,'') <> ''
			BEGIN
				--Get top level shipment info...
				SELECT
					o.id as [McLeodOrderNbr],
					ISNULL(o.coyote_pu_no, o.id) as [PickupRequestNbr],  --2
					fg.pro_nbr as [ProNbr],
					o.operational_status as [OperationalStatus],  --4
					RTRIM(ship.location_name) as [ShipperName],
					RTRIM(ship.[address]) as [ShipperAddress],  --6
					RTRIM(ship.address2) as [ShipperAddress2],
					RTRIM(ship.city_name) as [ShipperCity],  --8
					RTRIM(ship.state) as [ShipperState],
					ship.zip_code as [ShipperZip],  --10
					RTRIM(con.location_name) as [ConsigneeName],
					RTRIM(con.[address]) as [ConsigneeAddress],  --12
					RTRIM(con.address2) as [ConsigneeAddress2],
					RTRIM(con.city_name) as [ConsigneeCity],  --14
					CASE WHEN RTRIM(con.[state]) = 'XX' THEN NULL ELSE RTRIM(con.[state]) END as [ConsigneeState],
					CASE WHEN RTRIM(con.zip_code) = '99999' THEN NULL ELSE RTRIM(con.zip_code) END as [ConsigneeZip],  --16
					ship.sched_arrive_early as [SchedArriveEarly],
					ship.sched_arrive_late as [SchedArriveLate],  --18
					CASE WHEN o.operational_status = 'PICK' THEN ship.actual_departure ELSE NULL END as [ActualDeparture],
					ship.projected_arrival  as [ProjectedArrival],  --20
					RTRIM(ship.id) as [StopID],
					o.shipper_stop_id,  --22
					o.consignee_stop_id,
					o.[weight],  --24
					o.Pieces,
					fg.ship_ref_nbr,  --26
					fg.cons_ref_nbr,
					o.[status],  --28
					RTRIM(l.LocationCode) as [LocationCode],
					RTRIM(l.LocationName) as [LocationName],  --30
					RTRIM(l.Phone) as [Phone],
					ship.operational_status as [PUStopOpStatus],  --32
					ship.actual_arrival as [PUStopActualArrival],
					o.ordered_date as [OrderDate]
				FROM MCLEOD.lme_1510_ltl_uat.dbo.orders o
					INNER JOIN MCLEOD.lme_1510_ltl_uat.dbo.stop ship with(nolock) ON --Shipper Info
						o.shipper_stop_id = ship.id AND
						o.company_id = ship.company_id AND
						ship.stop_type = 'PU'
					LEFT JOIN MCLEOD.lme_1510_ltl_uat.dbo.stop con with(nolock) ON  --Consignee Info
						o.consignee_stop_id = con.id AND
						o.company_id = con.company_id AND
						con.stop_type = 'SO'
					INNER JOIN MCLEOD.lme_1510_ltl_uat.dbo.freight_group fg ON
						o.id = fg.lme_order_id AND
						o.company_id = fg.company_id
					LEFT JOIN (SELECT
								RTRIM(LocationCode) AS [LocationCode],
								RTRIM(LocationName) AS [LocationName],
								RTRIM(lcm.Value) AS [Phone]
							FROM RoadrunnerCentral.dbo.Location l
								LEFT JOIN [RoadrunnerCentral].[dbo].[LocationContactMethodValue] lcm ON l.LocationID = lcm.LocationID
								INNER JOIN [RoadrunnerCentral].[dbo].[ContactMethod] cm ON lcm.ContactMethodID = cm.ContactMethodID
							WHERE cm.[ContactMethodID] = 21) l ON
						RTRIM(ship.zone_id) = RTRIM(l.LocationCode)
				WHERE o.operational_status = 'PICK' AND fg.pro_nbr = @ProNumber
			END
		------------------------------------------------------------------------------
		IF ISNULL(@StopID,'') <> ''
			BEGIN
				SELECT
					rn.stop_id,
					rn.reference_qual as [ReferenceQual],
					rn.reference_number as [ReferenceNbr]
				FROM MCLEOD.lme_1510_ltl_uat.dbo.reference_number rn
				WHERE rn.stop_id = @StopID and rn.reference_qual NOT LIKE '%SI%'
			END
	END TRY
	BEGIN CATCH

		DECLARE
			@vErrSource   NVARCHAR (250),
			@vErrDescription NVARCHAR (500),
			@iErrorSeverity  INT,
			@iErrorState  INT

		SET @vErrDescription = RTRIM(ERROR_MESSAGE())
		SET @vErrSource   = ERROR_PROCEDURE()
		SET @iErrorSeverity  = ERROR_SEVERITY()
		SET @iErrorState  = ERROR_STATE()

		SET @vErrMessage = 'ERROR_NUMBER = ' + @vErrDescription + '; ERROR_NUMBER = ' + RTRIM(CONVERT(char,ERROR_NUMBER())) + '; ERROR_LINE = ' + RTRIM(CONVERT(char,ERROR_LINE())) + '; ERROR_SEVERITY=' + RTRIM(CONVERT(char,ERROR_SEVERITY()))

		-- Use RAISERROR inside CATCH block to return error information
		-- about original error that caused execution to jump to CATCH block.
		RAISERROR
		(
		@vErrDescription, -- Message text.
		@iErrorSeverity, -- Severity.
		@iErrorState  -- State.
		)

		IF @vErrSource IS NULL
			BEGIN
				SET @vErrSource = 'STORED PROC McleodTrackingByProNbrGet'
			END

		EXEC spErrorTraceLog_Insert @vErrDescription, @vErrSource, @vErrMessage, 'EXEC McleodTrackingByProNbrGet'

	END CATCH;
END

GO



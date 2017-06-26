USE [LTLTrack_Dev]
GO

/****** Object:  StoredProcedure [dbo].[GetMcLeodTrackingData]    Script Date: 06/16/2017 4:56:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetMcLeodTrackingData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetMcLeodTrackingData] AS'
END
GO







ALTER PROCEDURE [dbo].[GetMcLeodTrackingData]
    @searchTerm varchar(9)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET NOCOUNT ON;

declare @baseDate        as  date       = dateadd(day, -3, getdate());
declare @nostate         as  varchar(2) = 'XX';
declare @nozip           as  varchar(10) = '99999';
declare @ship_stop_type  as  varchar(2) = 'PU';
declare @con_stop_type   as  varchar(2) = 'SO';

select
        rtrim(fg.pro_nbr)                      as PK_pro,
        rtrim(o.customer_id)as CustomerID,
        NULL as DispatchCode,
        case
            when o.pieces < 0 then 0
            else o.pieces
        end                                        as Pieces,
        case
            when o.[weight] < 0 then 0
            else o.[weight]
        end                                        as Weight,
        rtrim(ship.location_name)                  as Origin,
        rtrim(ship.[address])                      as OriginAddress,
        rtrim(ship.city_name)                      as OriginCity,
        rtrim(ship.state)                          as OriginState,
        rtrim(ship.zip_code)                       as OriginZip,
        rtrim(con.location_name)                   as Consignee,
        rtrim(con.[address])                       as ConsigneeAddress,
        rtrim(con.city_name)                       as ConsigneeCity,
        case
            when rtrim(con.[state]) = @nostate
            then NULL
            else rtrim(con.[state])
        end                                        as ConsigneeState,
        case
            when rtrim(con.zip_code) = @nozip
            then NULL
            else rtrim(con.zip_code)
        end                                        as ConsigneeZip,
        NULL          as  Manifest		  ,
        NULL          as  Tractor			  ,
        NULL          as  BOL				  ,
        NULL          as  PONumber		  ,
        rtrim(o.coyote_pu_no)                      as CoyotePickupNumber,
        cast(o.id as int)                          as McLeodPickupNumber,
        ship.sched_arrive_early                    as AppointmentDate,
        ship.projected_arrival                     as EstDeliveryDate,
        ship.actual_arrival                        as DeliveredDate
from    OFFSQLENTD01.McLeodData_LTL.dbo.orders o
        left join OFFSQLENTD01.McLeodData_LTL.dbo.[stop]        ship on o.shipper_stop_id   = ship.id         and o.company_id = ship.company_id and ship.stop_type = @ship_stop_type
        left join OFFSQLENTD01.McLeodData_LTL.dbo.[stop]        con  on o.consignee_stop_id = con.id          and o.company_id = con.company_id  and con.stop_type  = @con_stop_type
        left join OFFSQLENTD01.McLeodData_LTL.dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id
where   fg.pro_nbr = @searchTerm
group by
         rtrim(fg.pro_nbr)
       , rtrim(o.customer_id)
       , case
            when o.pieces < 0 then 0
            else o.pieces
        end
       , case
            when o.[weight] < 0 then 0
            else o.[weight]
        end
        , rtrim(ship.location_name)
        , rtrim(ship.[address])
        , rtrim(ship.city_name)
        , rtrim(ship.state)
        , rtrim(ship.zip_code)
        , rtrim(con.location_name)
        , rtrim(con.[address])
        , rtrim(con.city_name)
        , rtrim(con.[state])
        , rtrim(con.zip_code)
        , ship.sched_arrive_early
        , ship.sched_arrive_late
        , rtrim(o.coyote_pu_no)
        , cast(o.id as int)
        , ship.sched_arrive_early
        , ship.projected_arrival
        , ship.actual_arrival




END






GO



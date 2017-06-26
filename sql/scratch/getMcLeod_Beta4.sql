--IF OBJECT_ID('tempdb..#mcleod') IS NOT NULL DROP TABLE #mcleod;

----CREATE TABLE #mcleod(
----	[Pro] [int] NOT NULL,
----	[CustomerID] [int] NULL,
----	-- [DispatchCode] [int] NULL,
----	[Pieces] [int] NOT NULL,
----	[Weight] [int] NOT NULL,
----	[Origin] [varchar](256) NULL,
----	[OriginAddress] [varchar](256) NULL,
----	[OriginCity] [varchar](50) NULL,
----	[OriginState] [varchar](10) NULL,
----	[OriginZip] [varchar](10) NULL,
----	[Consignee] [varchar](256) NULL,
----	[ConsigneeAddress] [varchar](256) NULL,
----	[ConsigneeCity] [varchar](50) NULL,
----	[ConsigneeState] [varchar](10) NULL,
----	[ConsigneeZip] [varchar](10) NULL,
----	-- [Tractor] [varchar](50) NULL,
----	-- [BOL] [varchar](50) NULL,
----	-- [PONumber] [varchar](50) NULL,
----	[ReadyTime] [datetime2](7) NULL,
----	[CloseTime] [datetime2](7) NULL,
----	[CoyotePickupNumber] [varchar](50) NULL,
----	[McLeodPickupNumber] [int] NULL,
----	[ApptDate]        [datetime2](7) NULL,
----	[EstDeliveryDate] [datetime2](7) NULL,
----	[DeliveredDate]   [datetime2](7) NULL);


declare @searchTerm     as varchar(30) = '399396993';
--declare @searchTerm     as varchar(30) = '23271525';
declare @baseDate        as  date       = dateadd(day, -3, getdate());
declare @nostate         as  varchar(2) = 'XX';
declare @nozip           as  varchar(10) = '99999';
declare @ship_stop_type  as  varchar(2) = 'PU';
declare @con_stop_type   as  varchar(2) = 'SO';

select
      case when fg.pro_nbr is not null and try_cast(fg.pro_nbr as int) is not null
          then cast(fg.pro_nbr as int)
          else NULL
     end                                                as PK_Pro
   , case when customer_id is not null and try_cast(customer_id as int) is not null
          then cast(customer_id as int)
          else NULL
     end                                                as CustomerID
   , NULL                                               as DispatchCode
   , case
         when o.pieces < 0 or isnull(o.pieces, 0) = 0
        then 0
        else o.pieces
     end                                                as Pieces
   , case
         when o.weight < 0 or isnull(o.weight, 0) = 0
         then 0
         else o.[weight]
     end                                                as Weight
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
            then ''
            else rtrim(con.[state])
        end                                        as ConsigneeState,
        case
            when rtrim(con.zip_code) = @nozip
            then ''
            else rtrim(con.zip_code)
        end                                        as ConsigneeZip,
        ship.sched_arrive_early                    as ReadyTime,
        ship.sched_arrive_late                     as CloseTime,
        rtrim(o.coyote_pu_no)                      as CoyotePickupNumber,
        cast(o.id as int)                          as McLeodPickupNumber,
        ship.sched_arrive_early                    as ApptDate,
        ship.projected_arrival                     as EstDeliveryDate,
        ship.actual_arrival                        as DeliveredDate
--into #mcleod
from    [OFFSQLENTD01].[McLeodData_LTL].[dbo].[orders]                  o
        left join [OFFSQLENTD01].[McLeodData_LTL].[dbo].[stop]          ship on o.shipper_stop_id   = ship.id         and o.company_id = ship.company_id and ship.stop_type = @ship_stop_type
        left join [OFFSQLENTD01].[McLeodData_LTL].[dbo].[stop]          con  on o.consignee_stop_id = con.id          and o.company_id = con.company_id  and con.stop_type  = @con_stop_type
        left join [OFFSQLENTD01].[McLeodData_LTL].[dbo].[freight_group] fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id
WHERE (
        (
            LEN(@searchTerm) = 9 AND o.operational_status = 'PICK' AND try_cast(ltrim(rtrim(fg.pro_nbr)) as int) = 1 and ltrim(rtrim(fg.pro_nbr)) = @searchTerm)
        OR
        (
            LEN(@searchTerm) = 8 AND (o.coyote_pu_no = @searchTerm OR o.id = @searchTerm))
      )
group by
       CASE when fg.pro_nbr is null then 0
            when TRY_CAST(ltrim(rtrim(fg.pro_nbr)) AS int) is null then 0
            else cast(ltrim(rtrim(fg.pro_nbr)) as int)
       END
      , CASE when o.customer_id is null then 0
            when TRY_CAST(ltrim(rtrim(o.customer_id)) AS int) is null then 0
            else cast(ltrim(rtrim(o.customer_id)) as int)
       END
        , o.pieces
        , o.[weight]
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


----'')'
--insert into #mcleod exec(@query1)

------ insert into mcleod
----select *
----from mcleod
--where pro > 0



--select * from #mcleod
--where

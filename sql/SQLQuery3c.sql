IF OBJECT_ID('tempdb..#mcleod') IS NOT NULL DROP TABLE #mcleod;

CREATE TABLE #mcleod(
	[Pro] [int] NOT NULL,
	[CustomerID] [int] NULL,
	-- [DispatchCode] [int] NULL,
	[Pieces] [int] NOT NULL,
	[Weight] [int] NOT NULL,
	[Origin] [varchar](256) NULL,
	[OriginAddress] [varchar](256) NULL,
	[OriginCity] [varchar](50) NULL,
	[OriginState] [varchar](10) NULL,
	[OriginZip] [varchar](10) NULL,
	[Consignee] [varchar](256) NULL,
	[ConsigneeAddress] [varchar](256) NULL,
	[ConsigneeCity] [varchar](50) NULL,
	[ConsigneeState] [varchar](10) NULL,
	[ConsigneeZip] [varchar](10) NULL,
	-- [Tractor] [varchar](50) NULL,
	-- [BOL] [varchar](50) NULL,
	-- [PONumber] [varchar](50) NULL,
	[ReadyTime] [datetime2](7) NULL,
	[CloseTime] [datetime2](7) NULL,
	[CoyotePickupNumber] [varchar](50) NULL,
	[McLeodPickupNumber] [int] NULL,
	[ApptDate]        [datetime2](7) NULL,
	[EstDeliveryDate] [datetime2](7) NULL,
	[DeliveredDate]   [datetime2](7) NULL);


declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(OFFSQLENTD01,
''
declare @baseDate        as  date       = dateadd(day, -3, getdate());
declare @nostate         as  varchar(2) = ''''XX'''';
declare @nozip           as  varchar(10) = ''''99999'''';
declare @ship_stop_type  as  varchar(2) = ''''PU'''';
declare @con_stop_type   as  varchar(2) = ''''SO'''';

select
       CASE when fg.pro_nbr is null then 0
            when TRY_CAST(ltrim(rtrim(fg.pro_nbr)) AS int) is null then 0
            else cast(ltrim(rtrim(fg.pro_nbr)) as int)
       END AS Pro,
       CASE when o.customer_id is null then 0
            when TRY_CAST(ltrim(rtrim(o.customer_id)) AS int) is null then 0
            else cast(ltrim(rtrim(o.customer_id)) as int)
       END as CustomerID,

        case
            when try_cast(o.pieces as int) is null then 0
            else o.pieces
        end                                        as Pieces,
        case
            when o.[weight] is null or o.[weight] < 0
            then 0
            else o.[weight]
        end                                        as Weight,
        rtrim(ship.location_name)                  as Origin,
        rtrim(ship.[address])                      as OriginAddress,
        rtrim(ship.city_name)                      as OriginCity,
        rtrim(ship.state)                          as OriginState,
        rtrim(ship.zip_code)                       as OriginZip,
        rtrim(con.location_name)                   as Consignee,address])                       as ConsigneeAddress,
        rtrim(con.city_name)                       as ConsigneeCity,
        case
        rtrim(con.[
            when rtrim(con.[state]) = @nostate
            then ''''''''
            else rtrim(con.[state])
        end                                        as ConsigneeState,
        case
            when rtrim(con.zip_code) = @nozip
            then ''''''''
            else rtrim(con.zip_code)
        end                                        as ConsigneeZip,
        ship.sched_arrive_early                    as ReadyTime,
        ship.sched_arrive_late                     as CloseTime,
        rtrim(o.coyote_pu_no)                      as CoyotePickupNumber,
        cast(o.id as int)                          as McLeodPickupNumber,
        ship.sched_arrive_early                    as ApptDate,
        ship.projected_arrival                     as EstDeliveryDate,
        ship.actual_arrival                        as DeliveredDate
from    OFFSQLENTD01.McLeodData_LTL.dbo.orders o
        left join OFFSQLENTD01.McLeodData_LTL.dbo.[stop]        ship on o.shipper_stop_id   = ship.id         and o.company_id = ship.company_id and ship.stop_type = @ship_stop_type
        left join OFFSQLENTD01.McLeodData_LTL.dbo.[stop]        con  on o.consignee_stop_id = con.id          and o.company_id = con.company_id  and con.stop_type  = @con_stop_type
        left join OFFSQLENTD01.McLeodData_LTL.dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id
where   o.ordered_date >= @baseDate
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


'')'
insert into #mcleod exec(@query1)

-- insert into mcleod
select *
from mcleod
where pro > 0


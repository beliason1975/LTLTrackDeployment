declare @baseDate        as  date       = dateadd(day, -1, getdate());
declare @nostate         as  varchar(2) = 'XX';
declare @nozip           as  varchar(5) = '99999';
declare @ship_stop_type  as  varchar(2) = 'PU';
declare @con_stop_type   as  varchar(2) = 'SO';

IF OBJECT_ID('tempdb..#mcleod') IS not null drop table #mcleod;

select  distinct
        fg.pro_nbr                                 as Pro,
        o.customer_id                              as CustomerID,
        null                                       as DispatchCode,
        case
            when o.pieces is null
            then 0
            else o.pieces
        end                                        as Pieces,
        case
            when o.[weight] is null
            then 0
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
            when rtrim(con.[state])  = @nostate
            then null
            else rtrim(con.[state])
        end                                        as ConsigneeState,
        case
            when rtrim(con.zip_code) = @nozip
            then null
            else rtrim(con.zip_code)
        end                                        as ConsigneeZip,
        null                                       as Manifest,
        null                                       as Tractor,
        null                                       as BOL,
        null                                       as PONumber,
        ship.sched_arrive_early                    as ReadyTime,
        ship.sched_arrive_late                     as CloseTime,
        cast(rtrim(o.coyote_pu_no) as int)         as CoyotePickupNumber,
        cast(rtrim(o.id) as int)                   as McLeodPickupNumber,
        ship.sched_arrive_early                    as ApptDate,
        ship.sched_arrive_early                    as EstDeliveryDate,
        ship.actual_arrival                        as DeliveredDate
into    #mcleod
from    dbo.orders o
        inner join dbo.[stop]        ship on o.shipper_stop_id   = ship.id         and o.company_id = ship.company_id and ship.stop_type = @ship_stop_type
        inner join dbo.[stop]        con  on o.consignee_stop_id = con.id          and o.company_id = con.company_id  and con.stop_type  = @con_stop_type
        inner join dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id
where   o.ordered_date >= @baseDate and isnumeric(fg.pro_nbr) = 1
group by
         fg.pro_nbr
		, o.customer_id
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
        , cast(rtrim(o.coyote_pu_no) as int)
        , cast(rtrim(o.id) as int)
        , ship.sched_arrive_early
        , ship.sched_arrive_early
        , ship.actual_arrival


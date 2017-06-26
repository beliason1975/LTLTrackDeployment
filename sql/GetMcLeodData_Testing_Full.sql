    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET NOCOUNT ON;


DECLARE @fromDate as date = dateadd (week , -1 , getdate());
declare  @searchTerm varchar(9) = '23267824'

SELECT
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
   , rtrim(orig.location_name)                          as Origin
   , rtrim(orig.address)                                as OriginAddress
   , rtrim(orig.city_name)                              as OriginCity
   , rtrim(orig.state)                                  as OriginState
   , rtrim(orig.zip_code)                               as OriginZip
   , rtrim(con.location_name)                           as Consignee
   , rtrim(con.address)                                 as ConsigneeAddress
   , rtrim(con.city_name)                               as ConsigneeCity
   , case when rtrim(con.state)    = 'XX'
         then null
         else rtrim(con.state)
     end                                                as ConsigneeState
   , case when rtrim(con.zip_code) = '99999'
         then null
         else rtrim(con.zip_code)
     end                                                as ConsigneeZip
   , NULL                                               as Manifest
   , NULL                                               as Tractor
   , NULL                                               as BOL
   , NULL                                               as PONumber
   , rtrim(o.coyote_pu_no)                              as CoyotePickupNumber
   , rtrim(o.id)                                        as McLeodPickupNumber
   , rtrim(con.sched_arrive_early)                     as ApptDate
   , rtrim(con.sched_arrive_late)                       as EstDeliveryDate
   , rtrim(con.actual_arrival)                         as DeliveredDate
from orders o
    left join  [stop]         orig on orig.id = o.shipper_stop_id    and
                                      orig.company_id = o.company_id and
                                      orig.stop_type = 'PU'
    left join  [stop]         con  on con.id = o.consignee_stop_id   and
                                      con.company_id = o.company_id  and
                                      con.stop_type = 'SO'
    left join freight_group  fg   on fg.lme_order_id = o.id         and
                                      fg.company_id = o.company_id
where o.ordered_date >= @fromDate and isnull(fg.pro_nbr, '') <> '' and try_cast(fg.pro_nbr as int) is not null --and fg.lme_order_id is not null
group by
     case when fg.pro_nbr is not null and try_cast(fg.pro_nbr as int) is not null
          then cast(fg.pro_nbr as int)
          else NULL
     end
   , case when customer_id is not null and try_cast(customer_id as int) is not null
          then cast(customer_id as int)
          else NULL
     end
   , case
         when o.pieces < 0 or isnull(o.pieces, 0) = 0
         then 0
         else o.pieces
    end
   , case
        when o.weight < 0 or isnull(o.weight, 0) = 0
        then 0
        else o.[weight]
     end
   , rtrim(orig.location_name)
   , rtrim(orig.address)
   , rtrim(orig.city_name)
   , rtrim(orig.state)
   , rtrim(orig.zip_code)
   , rtrim(con.location_name)
   , rtrim(con.address)
   , rtrim(con.city_name)
   , case when rtrim(con.state) = 'XX'
        then null
        else rtrim(con.state)
     end
   , case when rtrim(con.zip_code) = '99999'
        then null
        else rtrim(con.zip_code)
     end
   , rtrim(o.coyote_pu_no)
   , rtrim(o.id)
   , rtrim(con.sched_arrive_early)
   , rtrim(con.sched_arrive_late)
   , rtrim(con.actual_arrival)








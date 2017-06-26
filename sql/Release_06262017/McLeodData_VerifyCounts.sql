declare @fromDate as date = dateadd (week , -1 , getdate());
declare @total int = 0;
declare @non_null_pros_only int = 0;
declare @non_null_pros_valid_numbers_only int = 0;
declare @null_pros_only int = 0;
declare @no_order_id int = 0;
declare @non_null_pros_invalid_numbers_only int = 0;

set @total = (select sum(grpCount) as Total
from
(
--select fg.pro_nbr as Pro, o.id as McLeodPickupNumber, o.coyote_pu_no as CoyotePickupNumber , o.ordered_date
select count(*) as grpCount
from    McLeodData_LTL.dbo.orders o
        left join McLeodData_LTL.dbo.[stop]        ship on o.shipper_stop_id   = ship.id          and o.company_id = ship.company_id and ship.stop_type = 'PU'
        left join McLeodData_LTL.dbo.[stop]        con  on o.consignee_stop_id = con.id           and o.company_id = con.company_id  and con.stop_type  = 'SO'
        left join McLeodData_LTL.dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id   --and isnull(fg.pro_nbr, '') <> ''
         --and                     try_cast(rtrim(fg.pro_nbr) as int) is not null
where o.ordered_date >= @fromDate
--and o.id not in (
--group by o.id, fg.pro_nbr
group by fg.pro_nbr, o.id, o.coyote_pu_no, o.ordered_date
--order by o.id
)T)

set @non_null_pros_only = (select sum(grpCount) as SubTotal_1
from
(
select count(o.id) as grpCount, cast(fg.pro_nbr as int) as pro_nbr
--select fg.pro_nbr as Pro, o.id as McLeodPickupNumber, o.coyote_pu_no as CoyotePickupNumber , o.ordered_date
--select count(*) as grpCount
from    McLeodData_LTL.dbo.orders o
        left join McLeodData_LTL.dbo.[stop]        ship on o.shipper_stop_id   = ship.id          and o.company_id = ship.company_id and ship.stop_type = 'PU'
        left join McLeodData_LTL.dbo.[stop]        con  on o.consignee_stop_id = con.id           and o.company_id = con.company_id  and con.stop_type  = 'SO'
        inner join McLeodData_LTL.dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id   --and isnull(fg.pro_nbr, '') <> ''
         --and                     try_cast(rtrim(fg.pro_nbr) as int) is not null
where o.ordered_date >= @fromDate and isnull(fg.pro_nbr, '') <> '' --and fg.lme_order_id is not null

--and o.id not in (
--group by o.id, fg.pro_nbr
group by fg.pro_nbr, o.id, o.coyote_pu_no, o.ordered_date
--order by o.id
)T)

set @non_null_pros_valid_numbers_only = (select sum(grpCount) as SubTotal_1A
from
(
select count(o.id) as grpCount
--select fg.pro_nbr as Pro, o.id as McLeodPickupNumber, o.coyote_pu_no as CoyotePickupNumber , o.ordered_date
--select count(*) as grpCount
from    McLeodData_LTL.dbo.orders o
        left join McLeodData_LTL.dbo.[stop]        ship on o.shipper_stop_id   = ship.id          and o.company_id = ship.company_id and ship.stop_type = 'PU'
        left join McLeodData_LTL.dbo.[stop]        con  on o.consignee_stop_id = con.id           and o.company_id = con.company_id  and con.stop_type  = 'SO'
        inner join McLeodData_LTL.dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id   --and isnull(fg.pro_nbr, '') <> ''
         --and                     try_cast(rtrim(fg.pro_nbr) as int) is not null
where o.ordered_date >= @fromDate and isnull(fg.pro_nbr, '') <> '' and try_cast(fg.pro_nbr as int) is not null --and fg.lme_order_id is not null

--and o.id not in (
--group by o.id, fg.pro_nbr
group by fg.pro_nbr, o.id, o.coyote_pu_no, o.ordered_date
--order by o.id
)T)

set @non_null_pros_invalid_numbers_only = (select sum(grpCount) as SubTotal_1A
from
(
select count(o.id) as grpCount
--select fg.pro_nbr as Pro, o.id as McLeodPickupNumber, o.coyote_pu_no as CoyotePickupNumber , o.ordered_date
--select count(*) as grpCount
from    McLeodData_LTL.dbo.orders o
        left join McLeodData_LTL.dbo.[stop]        ship on o.shipper_stop_id   = ship.id          and o.company_id = ship.company_id and ship.stop_type = 'PU'
        left join McLeodData_LTL.dbo.[stop]        con  on o.consignee_stop_id = con.id           and o.company_id = con.company_id  and con.stop_type  = 'SO'
        inner join McLeodData_LTL.dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id   --and isnull(fg.pro_nbr, '') <> ''
         --and                     try_cast(rtrim(fg.pro_nbr) as int) is not null
where o.ordered_date >= @fromDate and isnull(fg.pro_nbr, '') <> '' and try_cast(fg.pro_nbr as int) is null --and fg.lme_order_id is not null

--and o.id not in (
--group by o.id, fg.pro_nbr
group by fg.pro_nbr, o.id, o.coyote_pu_no, o.ordered_date
--order by o.id
)T)

set @null_pros_only = (select sum(grpCount) as SubTotal_2
from
(
select count(o.id) as grpCount
--select fg.pro_nbr as Pro, o.id as McLeodPickupNumber, o.coyote_pu_no as CoyotePickupNumber , o.ordered_date
--select count(*) as grpCount
from    McLeodData_LTL.dbo.orders o
        left join McLeodData_LTL.dbo.[stop]        ship on o.shipper_stop_id   = ship.id          and o.company_id = ship.company_id and ship.stop_type = 'PU'
        left join McLeodData_LTL.dbo.[stop]        con  on o.consignee_stop_id = con.id           and o.company_id = con.company_id  and con.stop_type  = 'SO'
        inner join McLeodData_LTL.dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id --and isnull(fg.pro_nbr, '') <> ''
where o.ordered_date >= @fromDate and isnull(fg.pro_nbr, '') = '' --and fg.lme_order_id is not null
--group by o.id, fg.pro_nbr
group by fg.pro_nbr, o.id, o.coyote_pu_no, o.ordered_date
--order by o.id
)T)


set @no_order_id = (select sum(grpCount) as SubTotal_2
from
(
select count(o.id) as grpCount
--select fg.pro_nbr as Pro, o.id as McLeodPickupNumber, o.coyote_pu_no as CoyotePickupNumber , o.ordered_date
--select count(*) as grpCount
from    McLeodData_LTL.dbo.orders o
        left join McLeodData_LTL.dbo.[stop]        ship on o.shipper_stop_id   = ship.id          and o.company_id = ship.company_id and ship.stop_type = 'PU'
        left join McLeodData_LTL.dbo.[stop]        con  on o.consignee_stop_id = con.id           and o.company_id = con.company_id  and con.stop_type  = 'SO'
        left join McLeodData_LTL.dbo.freight_group fg   on o.id                = fg.lme_order_id and o.company_id = fg.company_id --and isnull(fg.pro_nbr, '') <> ''
where o.ordered_date >= @fromDate and fg.lme_order_id is null
--group by o.id, fg.pro_nbr
group by fg.pro_nbr, o.id, o.coyote_pu_no, o.ordered_date
--order by o.id
)T)

select @non_null_pros_only as [All ProNumbers], @non_null_pros_valid_numbers_only as [Only Integer Pros], @non_null_pros_invalid_numbers_only as [Invalid Integer Pros],  @null_pros_only as [Only PickupNumbers], @no_order_id as [No Corresponding OrderID], @non_null_pros_only + @null_pros_only + @no_order_id as [Pro + NoPro Count + NoOrderID], @total as Total

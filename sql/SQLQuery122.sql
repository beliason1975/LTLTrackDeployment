

select wh.Pro, wh.ApptDate, wh.EstDeliveryDate, wh.DeliveredDate,
      (select min(x.col) 
      from ( 
            select ApptDate        as col from ProDataWH x where x.Pro=wh.Pro
            union all              
            select EstDeliveryDate as col from ProDataWH x where x.Pro=wh.Pro
            union all              
            select DeliveredDate   as col from ProDataWH x where x.Pro=wh.Pro 
           )x) 
from ProDataWH wh

select * from ProDataWH where Pro = 394287627
select pro, min(EstDeliveryDate) as EstDeliveryDate from ProDataWH
group by pro
having count(*) > 3
order by pro

select
          cr.Pro
         --, cr.CustomerID
         --, cr.DispatchCode
         --, cr.Pieces
         --, cr.Weight
         --, cr.Origin
         --, cr.OriginAddress
         --, cr.OriginCity
         --, cr.OriginState
         --, cr.OriginZip
         --, cr.Consignee
         --, cr.ConsigneeAddress
         --, cr.ConsigneeCity
         --, cr.ConsigneeState
         --, cr.ConsigneeZip
         --, cr.Manifest
         EstDeliveryDate
         ,
         (select min(x.col) 
      from ( 
            --select ApptDate        as col from ProDataWH x where x.Pro=cr.Pro
            --union all              
            select EstDeliveryDate as col from ProDataWH x where x.Pro=cr.Pro and cr.Pro = 394287627
            --union all              
            --select DeliveredDate   as col from ProDataWH x where x.Pro=cr.Pro 
           )x)
from ProDataWH cr


from 
select pro, apptdate, EstDeliveryDate, DeliveredDate from ProDataWH where pro = 394287627
-group by pro
having count(*) > 3
order by pro





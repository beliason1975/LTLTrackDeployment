insert into pro
select
  wh.Pro   as PK_Pro
, wh.CustomerID
, wh.DispatchCode
, wh.Pieces
, wh.[Weight]
, wh.Origin
, wh.OriginAddress
, wh.OriginCity
, wh.OriginState
, wh.OriginZIP
, wh.Consignee
, wh.ConsigneeAddress
, wh.ConsigneeCity
, wh.ConsigneeState
, wh.ConsigneeZIP
--, wh.Tractor
, NULL as manifest
, max(wh.BOL) as BOL
, max(wh.PONumber) as PONumber
, max(isnull(wh.CoyotePickupNumber, 0) )
, max(isnull(wh.McLeodPickupNumber, 0))
, wh.ApptDate
, min(wh.EstDeliveryDate     ) as EstDeliveryDate
, wh.DeliveredDate
from
ProDataWH wh
inner join
(
	select w2.Pro, MIN(w2.EstDeliveryDate) as MinEstDeliveryDate
	from ProDataWH w2
	group by w2.pro

) T
on wh.Pro = T.pro and
   wh.EstDeliveryDate = T.MinEstDeliveryDate
GROUP BY
	  wh.Pro
	, wh.CustomerID
	, wh.DispatchCode
	, wh.Pieces
	, wh.[Weight]
	, wh.Origin
	, wh.OriginAddress
	, wh.OriginCity
	, wh.OriginState
	, wh.OriginZip
	, wh.Consignee
	, wh.ConsigneeAddress
	, wh.ConsigneeCity
	, wh.ConsigneeState
	, wh.ConsigneeZip
	--, wh.CoyotePickupNumber
	--, wh.McLeodPickupNumber
    , wh.ApptDate
	--, wh.EstDeliveryDate
	, wh.DeliveredDate
	-- select * from Pro










select
  Pro
, CustomerID
, DispatchCode
, Pieces
, Weight
, Origin
, OriginAddress
, OriginCity
, OriginState
, OriginZIP
, Consignee
, ConsigneeAddress
, ConsigneeCity
, ConsigneeState
, ConsigneeZIP
, Manifest
, Tractor
, BOL
, PONumber
  CoyotePickupNumber
,  CAST(CAST(ApptDate) AS VARCHAR(10)) AS DATE
,  CAST(CAST(EstDeliveryDate) AS VARCHAR(10)) AS DATE
,  CASE WHEN DeliveredDate <> 0
     THEN CAST(CAST(DeliveredDate) AS VARCHAR(10))
     ELSE NULL
     END
 FROM
 (
 select w.Pro, MIN(EstDeliveryDate) as MinEstDeliveryDate
 from #CoyoteResults cr
 group by pro
 ) U
 -- inner join prodataWh w on w.Pro = T.Pro

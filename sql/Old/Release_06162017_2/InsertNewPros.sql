INSERT INTO Pro
SELECT distinct
	  w.Pro as PK_Pro
	, MAX(w.CustomerID  ) AS CustomerID
	, MAX(w.DispatchCode)  AS DispatchCode
	, w.Pieces
	, w.[Weight] as Weight
	, w.Origin
	, w.OriginAddress
	, w.OriginCity
	, w.OriginState
	, w.OriginZip
	, w.Consignee		  	AS Consignee
	, w.ConsigneeAddress	AS ConsigneeAddress
	, w.ConsigneeCity	  	AS ConsigneeCity
	, w.ConsigneeState  	AS ConsigneeState
	, w.ConsigneeZip	   AS ConsigneeZip
	, null as Manifest
	, MAX(w.BOL		) AS BOL
	, MAX(w.PoNumber) AS PoNumber
	, MAX(w.CoyotePickupNumber) as CoyotePickupNumber
	, MAX(w.McLeodPickupNumber) as McLeodPickupNumber
	, MAX(w.ApptDate)         as ApptDate
	, MAX(w.EstDeliveryDate)  as EstDeliveryDate
	, MAX(w.DeliveredDate  )    as DeliveredDate
FROM ProDataWH w
lEFT JOIN Pro r on r.PK_Pro = w.Pro
	WHERE r.PK_Pro is null
--where w.Pro not in (select Pro from #results) AND isnull(ltrim(rtrim(ConsigneeAddress)), '') <> ''
GROUP BY
	    w.Pro
	, w.Pieces
	, w.[Weight]
	, w.Origin
	, w.OriginAddress
	, w.OriginCity
	, w.OriginState
	, w.OriginZip
	, w.Consignee
	, w.ConsigneeAddress
	, w.ConsigneeCity
	, w.ConsigneeState
	, w.ConsigneeZip
	--, w.Manifest
	--, w.BOL
	--, w.PoNumber

	-- select * from Pro order by PK_Pro

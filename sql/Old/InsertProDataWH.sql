SET NOCOUNT ON;

INSERT INTO ProDataWH
		(
			CustomerID
			, Pro
			, DispatchCode
			, Pieces
			, [Weight]
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
			, Pickup#
			, ApptDate
			, EstDeliveryDate
			, DeliveredDate
	)
SELECT CustomerID
    , Pro
    , DispatchCode
    , Pieces
    , [Weight]
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
    , Pickup#
    , CAST(CAST(apptDate AS VARCHAR(10)) AS DATE) AS ApptDate
    , CAST(CAST(estDeliveryDate AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
    , CASE WHEN DeliveredDate <> 0
        THEN CAST(CAST(DeliveredDate AS VARCHAR(10)) AS DATE)
        ELSE NULL
    END AS DeliveredDate
FROM #tempResults
ORDER BY Pro;


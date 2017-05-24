	SET NOCOUNT ON;

    INSERT INTO Pro
	(
		PK_Pro
		, CustomerID
		, DispatchCode
		, Pieces
		, [Weight]
		, Origin
		, OriginAddress
		, OriginCity
		, OriginState
		, OriginZip
		, Consignee
		, ConsigneeAddress
		, ConsigneeCity
		, ConsigneeState
		, ConsigneeZip
		, Manifest
		, BOL
		, PoNumber
		, PickupNumber
		, AppointmentDate
		, EstDeliveryDate
		, DeliveredDate
	)
 	SELECT Pro
		, CustomerID
		, DispatchCode
		, SUM(Pieces) as Pieces
		, SUM([Weight]) as [Weight]
		, Origin
		, OriginAddress
		, OriginCity
		, OriginState
		, OriginZip
		, Consignee
		, ConsigneeAddress
		, ConsigneeCity
		, ConsigneeState
		, ConsigneeZip
		, MAX(Manifest) as Manifest
		, BOL
		, PoNumber
		, MAX(Pickup#) as Pickup#
		, MAX(ApptDate) as ApptDate
		, MAX(EstDeliveryDate) as EstDeliveryDate
		, MAX(DeliveredDate) as DeliveredDate
	FROM dbo.ProDataWH
	WHERE Pro NOT IN (SELECT PK_Pro FROM dbo.Pro GROUP BY PK_Pro)
	GROUP BY Pro
		, CustomerID
		, DispatchCode
		-- , Pieces
		-- , [Weight]
		, Origin
		, OriginAddress
		, OriginCity
		, OriginState
		, OriginZip
		, Consignee
		, ConsigneeAddress
		, ConsigneeCity
		, ConsigneeState
		, ConsigneeZip
		--, Manifest
		, BOL
		, PoNumber;
		--, Pickup#
		-- , ApptDate
		-- , EstDeliveryDate
		-- , DeliveredDate;



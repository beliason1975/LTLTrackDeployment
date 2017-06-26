USE [LTLTrack_Demo]
GO

/****** Object:  StoredProcedure [dbo].[InsertNewPros]    Script Date: 05/05/2017 4:09:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertNewPros]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[InsertNewPros] AS' 
END
GO



-- =============================================
-- Author:		Jason Stack
-- Create date: 09MAR2017
-- Description:	Insert new Pros to Pro data table
-- =============================================
ALTER PROCEDURE [dbo].[InsertNewPros]
AS
BEGIN
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
		--, Manifest
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
		--, Manifest
		, BOL
		, PoNumber
		, PickupNumber
		, CAST(CAST(apptDate AS VARCHAR(10)) AS DATE) AS ApptDate
		, CAST(CAST(estDeliveryDate AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
		, CASE WHEN DeliveredDate <> 0
			THEN CAST(CAST(DeliveredDate AS VARCHAR(10)) AS DATE) 
			ELSE NULL 
		  END AS DeliveredDate
		--, ApptDate
		--, EstDeliveryDate
		--, DeliveredDate
	FROM dbo.ProDataWH
		where PickupNumber <> 'NULL'
		and EstDeliveryDate <> 'NULL'
		--and Pro = 263585465
		--and Pro NOT IN (SELECT DISTINCT PK_Pro FROM dbo.Pro)

	GROUP BY Pro
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
		--, Manifest
		, BOL
		, PoNumber
		, PickupNumber
		, ApptDate
		, EstDeliveryDate
		, DeliveredDate;
END



GO


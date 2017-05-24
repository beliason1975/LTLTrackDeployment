USE [LTLTrack]
GO
/****** Object:  StoredProcedure [dbo].[GetMcleodTrackingByProNbrGet]    ******/2017 2:33:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetMcleodTrackingByProNbrGet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetMcleodTrackingByProNbrGet] AS' 
END
GO

-- =============================================
-- Author:		Dan Paluszynski, Jason Stack
-- Create date: 6/28/2016
-- Description:	Get Mcleod shipment tracking information by Pro Number or Reference #(s) for a given StopID 
-- =============================================
ALTER PROCEDURE [dbo].[GetMcleodTrackingByProNbrGet]
	@ProNumber varchar(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;

------------------------------------------------------------------------------
--***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***
--DECLARE @ProNumber varchar(50)
--SET @ProNumber = '154984264'
--***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***
------------------------------------------------------------------------------

	SELECT  freight_group.pro_nbr as [PK_Pro]
		--,reference_number.stop_id
		,reference_number.reference_qual as [RefQual]
		,reference_number.reference_number as [RefNbr]
		--,reference_number.id as ReferenceID
	FROM OFFSQLENTD01.McLeodData_LTL.dbo.orders orders
		INNER JOIN OFFSQLENTD01.McLeodData_LTL.dbo.reference_number
			ON orders.shipper_stop_id = reference_number.stop_id
				AND orders.company_id = reference_number.company_id
		INNER JOIN OFFSQLENTD01.McLeodData_LTL.dbo.freight_group freight_group
			ON orders.id = freight_group.lme_order_id
				AND orders.company_id = freight_group.company_id
				AND freight_group.pro_nbr = @ProNumber
				--AND ISNULL(freight_group.pro_nbr, '') <> ''
	ORDER BY freight_group.pro_nbr, reference_number.id
END

GO

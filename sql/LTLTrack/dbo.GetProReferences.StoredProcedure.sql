USE [LTLTrack]
GO
/****** Object:  StoredProcedure [dbo].[GetProReferences]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetProReferences]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetProReferences] AS' 
END
GO



-- =============================================
-- Author:		Dan Paluszynski, Jason Stack
-- Create date: 6/28/2016
-- Description:	Get Mcleod shipment tracking information by Pro Number or Reference #(s) for a given StopID 
-- =============================================
ALTER PROCEDURE [dbo].[GetProReferences]
@proNumber varchar(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;

------------------------------------------------------------------------------
--***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***
--DECLARE @proNumber varchar(50)
--SET @proNumber = '154984264'
--***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***TEST DATA***
------------------------------------------------------------------------------

	SELECT 
	ROW_NUMBER() OVER (Order by CAST(freight_group.pro_nbr as bigint)) AS PK_ProReference,  
	CAST(freight_group.pro_nbr as bigint) as [FK_Pro]
		,reference_number.reference_qual as [RefQual]
		,reference_number.reference_number as [RefNbr]
	FROM OFFSQLENTD01.McLeodData_LTL.dbo.orders orders
		INNER JOIN OFFSQLENTD01.McLeodData_LTL.dbo.reference_number
			ON orders.shipper_stop_id = reference_number.stop_id
				AND orders.company_id = reference_number.company_id
		INNER JOIN OFFSQLENTD01.McLeodData_LTL.dbo.freight_group freight_group
			ON orders.id = freight_group.lme_order_id
				AND orders.company_id = freight_group.company_id
				AND freight_group.pro_nbr = @proNumber
	ORDER BY PK_ProReference, CAST(freight_group.pro_nbr as bigint), reference_number.id
END



GO

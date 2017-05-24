USE [LTLTrack]
GO
/****** Object:  StoredProcedure [dbo].[GetPickupNumber]    ******/2017 2:37:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetPickupNumber]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetPickupNumber] AS' 
END
GO


ALTER PROCEDURE [dbo].[GetPickupNumber]
	@proNumber decimal(9,0)
AS

--DECLARE @proNumber DECIMAL(9,0) = 160968228
--	, @isProNum BIT = 1

BEGIN

	SET NOCOUNT ON;
	

	DECLARE @pro# decimal(9,0) = null
	DECLARE @numberlength int;

	set @numberlength = (select LEN(CAST(@proNumber AS varchar(9))))

	--select @numberlength

	IF @numberlength = 9
	BEGIN
		SELECT PUTRAN.DLPUNO 
		FROM [PUTRAN] PUTRAN
		WHERE PUTRAN.DLPRO = @proNumber
	END
	ELSE
		SELECT null;

END


GO

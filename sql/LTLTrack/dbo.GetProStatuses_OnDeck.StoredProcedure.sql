USE [LTLTrack]
GO
/****** Object:  StoredProcedure [dbo].[GetProStatuses_OnDeck]    ******/2017 2:37:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetProStatuses_OnDeck]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetProStatuses_OnDeck] AS' 
END
GO


-- =============================================
-- Author:		Jason Stack
-- Create date: 01MAR2017
-- Description:	Get LTL PRO data from Coyote
-- =============================================
ALTER PROCEDURE [dbo].[GetProStatuses_OnDeck]
	@proNumber decimal(9,0)
AS

--DECLARE @proNumber DECIMAL(9,0) = 160968228
--	, @isProNum BIT = 1

BEGIN

	SET NOCOUNT ON;
	

	SELECT 
		CAST(PROSTA.ALPRO as int) AS FK_Pro
		, CAST(PROSTA.ALSTAT as varchar(3)) AS StatusCode
		, CAST(PROSTA.ALDATE AS varchar(10)) AS StatusDate
		, CAST(PROSTA.ALTIME as int) AS StatusTime
		, CAST(PROSTA.ALCMT as varchar(50)) AS StatusComment
		--, PROSTA.StatusDateTime as [DateTime]
	FROM [COYOTE].[B10A282B].[RDFSV31DTA].[PROSTA] PROSTA
	WHERE PROSTA.ALPRO = @proNumber
	ORDER BY CAST(PROSTA.ALDATE AS varchar(10)), CAST(PROSTA.ALTIME as int)
	--ORDER BY PROSTA.StatusDateTime

END














GO

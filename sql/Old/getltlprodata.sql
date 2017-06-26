USE [LTLTrack]
GO

/****** Object:  StoredProcedure [dbo].[GetLTLProData]    Script Date: 04/30/2017 2:43:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetLTLProData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetLTLProData] AS' 
END
GO






-- =============================================
-- Author:		Jason Stack
-- Create date: 01MAR2017
-- Description:	Get LTL PRO data from Coyote
-- =============================================
ALTER PROCEDURE [dbo].[GetLTLProData]
	@inputNumber decimal(9,0)
	, @isProNum bit
AS

--DECLARE @inputNumber DECIMAL(9,0) = 160968228
--	, @isProNum BIT = 1

BEGIN
	
	SET NOCOUNT ON;
	

	DECLARE @pickup# decimal(8,0) --= 22646108
		, @pro# decimal(9,0) -- = 154984181   --406061846,406077198;
	DECLARE @sqlString nvarchar(MAX);

	IF @isProNum = 0 
	BEGIN
		SELECT @pro# = DLPRO 
					FROM [COYOTE].[B10A282B].[RDFSV31DTA].[PUTRAN] PUTRAN
					WHERE DLPUNO = @inputNumber
	END
	ELSE
		SET @pro# = @inputNumber

	--SELECT @pro#
	--Declare @temp int

	
	SELECT DISTINCT 
		PROHDR.AJPRO# AS FK_Pro
		, PROSTA.ALSTAT AS StatusCode
		, CAST(CAST(PROSTA.ALDATE AS varchar(10)) AS date) AS StatusDate
		, PROSTA.ALTIME AS StatusTime
		, PROSTA.ALCMT AS StatusComment
	FROM [COYOTE].[B10A282B].[RDFSV31DTA].[PROHDR] PROHDR
		INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[PROSTA] PROSTA
			ON PROHDR.AJPRO# = PROSTA.ALPRO
				AND PROHDR.AJPRO# = @pro#
		LEFT JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[APPT] APPT
			ON PROHDR.AJPRO# = APPT.BSPRO
		LEFT JOIN (SELECT DISTINCT BBPRO
					, BASTDT
					, BASTTM
					, BBFSC
					, CAST (BAMFST AS varchar) BAMFST
					, BATRKR
				FROM [COYOTE].[B10A282B].[RDFSV31DTA].[MFSTDTL] MFSTDTL
					INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[MFSTHDR] MFSTHDR
						ON MFSTDTL.BBMFST  = MFSTHDR.BAMFST
				WHERE BBPRO = @pro#
				) qManifest
				ON LTRIM(RTRIM(PROSTA.ALXREF)) = qManifest.BAMFST
					AND PROHDR.AJPRO# = qManifest.BBPRO
		LEFT JOIN  [COYOTE].[B10A282B].[RDFSV31DTA].[PUTRAN] PUTRAN
			ON PROHDR.AJPRO# = PUTRAN.DLPRO
		LEFT JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[PROSTA] dueStatus
			ON PROHDR.AJPRO# = dueStatus.ALPRO
				AND AJPRO# = @pro#
				AND dueStatus.ALSTAT = 'DUD'
		WHERE PROSTA.ALSTAT <> 'ENL' AND PROSTA.ALSTAT <> 'SYN' AND PROSTA.ALSTAT <> 'OFD' AND PROSTA.ALSTAT <> 'APT' AND PROSTA.ALSTAT <> 'DEL' AND LTRIM(RTRIM(PROSTA.ALSTAT)) <> ''

		ORDER BY CAST(CAST(PROSTA.ALDATE AS varchar(10)) AS date), PROSTA.ALTIME

END






GO


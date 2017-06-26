USE [RoadrunnerCentral]
GO

/****** Object:  StoredProcedure [dbo].[LTLTrack_GetCoyoteProHeader]    Script Date: 06/23/2017 1:26:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LTLTrack_GetCoyoteProHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LTLTrack_GetCoyoteProHeader] AS' 
END
GO






-- =============================================
-- Author:		Curtis A. Fleischer
-- Create date: 3/28/2014
-- Description:	Retrieve Tracking information from Coyote ProHeader table
-- =============================================
ALTER PROCEDURE [dbo].[LTLTrack_GetCoyoteProHeader] (
	@pProNumber integer,
	@webSite bit
)
AS
BEGIN
    IF OBJECT_ID('tempdb..#track') IS NOT NULL DROP TABLE #track;
    IF OBJECT_ID('tempdb..#TrackProHeader') IS NOT NULL DROP TABLE #TrackProHeader;

	CREATE TABLE #track(
	   [ProNumber] varchar(20)
      ,[OriginName] varchar(50) null
      ,[OriginAddress1] varchar(100) null
      ,[OriginAddress2] varchar(100) null
      ,[OriginCity] varchar(50) null
      ,[OriginState] varchar(2) null
      ,[OriginPostalCode] varchar(10) null
      ,[DestinationName] varchar(50) null
      ,[DestinationAddress1] varchar(100) null
      ,[DestinationAddress2] varchar(100) null
      ,[DestinationCity] varchar(50) null
      ,[DestinationState] varchar(2) null
      ,[DestinationPostalCode] varchar(10) null
      ,[CustomerNumber] varchar(20) null
      ,[BOLNumber] varchar(50) null
      ,[PONumber] varchar(50) null
      ,[Pieces] int null
      ,[Weight] int null
      ,[AppointmentDate] varchar(20)  null
      ,[AppointmentTime] varchar(20) null
      ,[DeliveredDate] varchar(20)  null
      ,[BilltoNumber] varchar(20) null
      ,[ProjectedDeliveryDate] INT null
      ,[DeliveredTime] varchar(20) null
      ,[HAWB] varchar(20) null
      ,[OriginTerminalName] varchar(25) null
      ,[OriginTerminalPhone] varchar(25) null
      ,[BOLReceived] varchar(2) NULL
      ,[PODReceived] varchar(2)
	  )

	declare @query1 varchar(max) =
	'SELECT * FROM OPENQUERY(COYOTE, ''SELECT C.AJPRO# as ProNumber,
			C.AJSNM AS OriginName,
			C.AJSAD1 AS OriginAddress1,
			C.AJSAD2 AS OriginAddress2,
			C.AJSCTY AS OriginCity,
			C.AJSST AS OriginState,
			C.AJSZIP AS OriginPostalCode,
			C.AJCNM AS DestinationName,
			C.AJCAD1 AS DestinationAddress1,
			C.AJCAD2 AS DestinationAddress2,
			C.AJCCTY AS DestinationCity,
			C.AJCST AS DestinationState,
			C.AJCZIP AS DestinationPostalCode,
			C.AJSCD AS CustomerNumber,
			C.AJBLNO AS BOLNumber,
			C.AJPONO AS PONumber,
			C.AJTPCS AS Pieces,
			C.AJTWGT AS Weight,
			B.BSDATE AS AppointmentDate,
			B.BSTIME AS AppointmentTime,
			D.ALDATE AS DeliveredDate,
			C.AJBCD AS BilltoNumber,
			A.ALDATE AS ProjectedDeliveryDate,
			'''' '''' AS DeliveredTime,
			'''' '''' AS HAWB,
		    C.AJORIG AS OriginTerminalName,
			'''' '''' AS OriginTerminalPhone,
			C.AJBLIN AS BOLAvail,
			C.AJDRIN AS DRAvail
	from RDFSV31DTA.PROHDR C
	left outer join RDFSV31DTA.APPT B ON C.AJCO# = B.BSCONO
		AND C.AJPRO# = B.BSPRO
	LEFT OUTER JOIN RDFSV31DTA.PROSTA A ON C.AJCO# = A.ALCO
		AND C.ajpro# = A.ALPRO AND A.ALSTAT = ''''DUD''''
	LEFT OUTER JOIN RDFSV31DTA.PROSTA D ON C.AJCO# = D.ALCO
		AND C.ajpro# = D.ALPRO AND D.ALFSC <> ''''I''''
		AND D.ALSTAT IN (''''DED'''', ''''DES'''', ''''DEL'''', ''''DEO'''')
	WHERE C.AJCO# = 01 AND C.AJPRO# = ' + CAST(@pProNumber AS varchar) +
	' FETCH FIRST ROW ONLY'')'

	INSERT INTO #track exec(@query1)

	UPDATE #track SET OriginTerminalName= l.LocationName,
		OriginTerminalPhone = lcm.Value
	FROM [dbo].[Location] l
	LEFT JOIN [dbo].[LocationContactMethodValue] lcm
		ON l.LocationID = lcm.LocationID
	LEFT JOIN [dbo].[ContactMethod] cm
		ON lcm.ContactMethodID = cm.ContactMethodID
	WHERE l.LocationCode = #track.OriginTerminalName
	AND cm.[Name] = 'Toll Free'

SELECT [ProNumber]
      ,[OriginName]
      ,[OriginAddress1]
      ,[OriginAddress2]
      ,[OriginCity]
      ,[OriginState]
      ,[OriginPostalCode]
      ,[DestinationName]
      ,[DestinationAddress1]
      ,[DestinationAddress2]
      ,[DestinationCity]
      ,[DestinationState]
      ,[DestinationPostalCode]
      ,[CustomerNumber]
      ,[BOLNumber]
      ,[PONumber]
      ,[Pieces]
      ,[Weight]
      ,CASE WHEN [AppointmentDate] = 0 OR [AppointmentDate] IS NULL THEN
			null
			ELSE
				CONVERT(DATETIME, CAST([AppointmentDate] AS varchar), 112)
			END AS [AppointmentDate]
      ,[AppointmentTime]
      ,CASE WHEN [ProjectedDeliveryDate] = 0 OR [ProjectedDeliveryDate] IS NULL THEN
				null
			ELSE
				CONVERT(DATETIME, CAST([ProjectedDeliveryDate] AS varchar), 112)
			END AS [EstimatedDeliveryDate]
      ,CASE WHEN [DeliveredDate] = 0 OR [DeliveredDate] IS NULL THEN
				null
			ELSE
				CONVERT(DATETIME, CAST([DeliveredDate] AS varchar), 112)
			END AS [DeliveredDate]
      ,[BilltoNumber]
     ,CASE WHEN [ProjectedDeliveryDate] = 0 OR [ProjectedDeliveryDate] IS NULL THEN
				null
			ELSE
				CONVERT(DATETIME, CAST([ProjectedDeliveryDate] AS varchar), 112)
			END AS [ProjectedDeliveryDate]
      ,[DeliveredTime]
      ,[HAWB]
      ,[OriginTerminalName]
      ,[OriginTerminalPhone]
      ,CASE WHEN [BOLReceived] = 'Y' THEN 1 ELSE 0 END AS [BOLReceived]
      ,CASE WHEN [PODReceived] = 'Y' THEN 1 ELSE 0 END AS [PODReceived]
    INTO #TrackProHeader
	FROM #track

	DROP TABLE #track

	END

	IF @webSite = 1
		SELECT * FROM #TrackProHeader --[SPINSQLC01\INTERNET].[RoadrunnerCentral].dbo.TrackingCache2013
		WHERE ProNumber = @pProNumber
	ELSE
	BEGIN
		DECLARE @Manifest varchar(10)

		CREATE TABLE #Manifest (
			ManifestNumber varchar(15),
			SequenceNumber int
		)

		DECLARE @manifestQuery varchar(max) =
		'INSERT INTO #Manifest
		SELECT * FROM openquery(COYOTE, ''SELECT BBMFST AS ManifestNumber,
			BBSEQ AS SequenceNumber
			FROM RDFSV31DTA.MFSTDTL1
			WHERE BBCO# = 1 AND BBPRO = ' + CAST(@pProNumber AS varchar) + ''')'
		EXEC(@manifestQuery)

		SELECT @Manifest = isnull((SELECT TOP 1
			SUBSTRING(LTRIM(STR(ManifestNumber)),1,6)+'-'+SUBSTRING(LTRIM(STR(ManifestNumber)),7,1)
			FROM #Manifest
			ORDER BY SequenceNumber DESC),'')

		DROP TABLE #Manifest

		SELECT *, @Manifest AS Manifest FROM #TrackProHeader
		WHERE ProNumber = @pProNumber
	END






GO



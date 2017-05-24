USE [LTLTrack]
GO

/****** Object:  StoredProcedure [dbo].[GetProStatuses]    Script Date: 05/18/2017 6:06:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetProStatuses]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetProStatuses] AS'
END
GO



-- =============================================
-- Author:		Curtis A. Fleischer
-- Create date: 3/28/2014
-- Description:	Retrieve Tracking information from Coyote ProHeader table
--
-- Updated: 4/24/17 Dan Paluszynski - The business requested the SQL Server cache table logic be removed and all queries return up todate Coyote data.
-- =============================================
ALTER PROCEDURE [dbo].[GetProStatuses] (
	@proNumber integer
)
AS
BEGIN
	/*IF NOT EXISTS (SELECT * FROM RoadrunnerCentral.dbo.TrackingStatusCache2013
					WHERE ProNumber = @proNumber)
	BEGIN */
		DECLARE @website int = 1;
		DECLARE @manifestCount int = 0
		CREATE TABLE #status
		(  [ProNumber] varchar(20)
		  ,[StatusDate] varchar(10) null
		  ,[StatusTime] varchar(10) null
		  ,[StatusCode] varchar(10) null
		  ,[StatusComment] varchar(100) null
		  ,[StatusPostedDate] varchar(10) null
		  ,[StatusPostedTime] varchar(10) null
		  ,[OrigCityState] varchar(200) null
		  ,[DestCityState] varchar(200) null
		  ,[MnfstDate] varchar(10) null
		)

		CREATE TABLE #Appt
		(  [ProNumber] varchar(20)
		  ,[StatusDate] varchar(10) null
		  ,[StatusTime] varchar(10) null
		)
		CREATE TABLE #MfstData
		(	MfstDate int,
			ProNumber int,
			ScacLocation varchar(6),
			Location varchar(6),
			ScacDest varchar(6),
			Dest varchar(6)
		)

		CREATE TABLE #agents
		(	Scac varchar(5),
			TermCode varchar(4),
			City varchar(150),
			State varchar(3)
		)

		DECLARE @query varchar(max) =
			'SELECT * FROM OPENQUERY(COYOTE, ''SELECT ALPRO AS ProNumber,
				ALDATE AS StatusDate,
				ALTIME AS StatusTime,
				ALSTAT AS StatusCode,
				ALCMT AS StatusComment,
				ALPDTE AS StatusPostedDate,
				ALPTIM AS StatusPostedTime,
				'''''''' AS OrigCityState,
				'''''''' AS DestCityState,
				'''''''' AS MnfstDate
			FROM RDFSV31DTA.PROSTA
			LEFT OUTER JOIN RDFSV31DTA.TERM T ON T.TFTERM = ALLOC
			where ALCO = 1 AND ALPRO = ' + cast(@proNumber as varchar) + '
				AND alloc <> ''''IMG'''' AND alfsc <> ''''I''''
			ORDER BY ALPDTE DESC, ALPTIM DESC'')'

		INSERT INTO #status EXEC(@query)

		SET @query = 'SElECT * FROM OpenQuery(COYOTE, ''SELECT BSPRO AS ProNumber,
			BSDATE AS StatusDate, BSTIME AS statusTime
			FROM B10A282B.RDFSV31DTA.APPT
			WHERE BSCONO = 1 and BSPRO = ' + cast(@proNumber as varchar) + ' '')'

		INSERT INTO #Appt EXEC(@query)

		UPDATE #status SET StatusDate = (SELECT a.StatusDate FROM #Appt a WHERE A.ProNumber = ProNumber),
		StatusTime = (SELECT a.StatusTime FROM #Appt a WHERE A.ProNumber = ProNumber)
		WHERE StatusCode = 'APT'

		DELETE #status
		WHERE StatusCode NOT IN (SELECT TrackingCode
			 FROM RoadrunnerCentral.dbo.TrackingMessages
			WHERE Tracking = 1)

--***********************************************************************
-- Remove any statuses entered after Delivery StatusCodes
-- This 'fixes' poorly entered data.
		DECLARE @statDate int
		DECLARE @StatTime int
		SELECT @statDate = MAX(StatusDate), @StatTime = MAX(StatusTime)
		FROM #Status
		WHERE StatusCode IN ('DEL', 'DED', 'DEO', 'DER', 'DES', 'DIR', 'TDC')

		IF @statDate IS NOT null
		BEGIN
			DELETE #Status WHERE (StatusDate >= @statDate AND StatusTime >= @StatTime)
				AND StatusCode NOT IN ('DEL', 'DED', 'DEO', 'DER', 'DES', 'DIR', 'TDC')
		END
--***********************************************************************

		SET @query = 'SElECT * FROM OpenQuery(COYOTE, ''SELECT NESCAC AS Scac, NEIPAC AS TermCode,
			TRIM(NECITY) AS City, TRIM(NEST) AS State
			FROM B10A282B.RDFSV31DTA.ILMAST'')'

		INSERT INTO #agents EXEC(@query)

		SET @query = 'SELECT * FROM OPENQUERY(COYOTE, ''SELECT BADATE AS MfstDate,
			BBPRO AS ProNumber,
			BATLSC AS ScacLocation, BAORIG AS Location,
			BADLSC AS ScacDest, BADEST AS Dest
			FROM [B10A282B].[RDFSV31DTA].[MFSTHDR]
			LEFT JOIN [B10A282B].[RDFSV31DTA].[MFSTDTL] ON BAMFST = BBMFST
		WHERE [BACO#] = 1
			AND BBPRO = ' + cast(@proNumber as varchar) + '
			AND BATRPS <> 0
		ORDER BY ProNumber DESC'')'

		INSERT INTO #MfstData EXEC(@query)
--*************************************************************************
-- Update CityState Data
		DECLARE @MfstDate int
		DECLARE @Location varchar(5)
		DECLARE @scacDest varchar(5)
		DECLARE @Dest varchar(5)

		DECLARE curMan CURSOR FOR
		SELECT MfstDate, Location, ScacDest, Dest FROM #MfstData ORDER BY MfstDate
		OPEN curMan
		FETCH NEXT FROM curMan INTO @MfstDate, @Location, @scacDest, @Dest
		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE #Status SET OrigCityState = UPPER([dbo].[GetLocationCityStateString](@Location)),
			mnfstDate = @MfstDate
			WHERE StatusDate >= @MfstDate

			UPDATE #Status SET DestCityState =
			CASE WHEN @scacDest = 'RDFS' OR @scacDest = '' THEN
				CASE WHEN @Dest = 'DIR' THEN 'Consignee Location'
				ELSE UPPER([dbo].[GetLocationCityStateString](@Dest))
				END
			ELSE
				(SELECT UPPER(RTRIM(LTRIM (City)))
				+ ', ' + State FROM #agents
				WHERE Scac = @scacDest AND TermCode = @Dest)
			END
			WHERE StatusDate >= @MfstDate
			SET @manifestCount = @manifestCount + 1
			FETCH NEXT FROM curMan INTO @MfstDate, @Location, @scacDest, @Dest
		END
		CLOSE curMan
		DEALLOCATE curMan
--*************************************************************************
		UPDATE #status SET StatusComment = (SELECT TrackingMessage
			FROM RoadrunnerCentral.dbo.TrackingMessages
			WHERE StatusCode = TrackingCode)
		WHERE StatusCode NOT IN ('DUD', 'DSP', 'ENR', 'INV')

		UPDATE #status SET StatusComment =
		COALESCE(StatusComment +
			' ' + Case WHEN @manifestCount = 1 THEN DestCityState
			WHEN StatusDate > MnfstDate THEN DestCityState
			ELSE OrigCityState END, 'Trailer arived at terminal')
		WHERE [StatusCode] IN ('ARX')

		UPDATE #status SET StatusComment = StatusComment +
			' ' + CONVERT(varchar, CONVERT(DATETIME, CAST([StatusDate] AS varchar), 112), 1),
			StatusDate = StatusPostedDate
		WHERE [StatusCode] IN ('DUD')

		UPDATE #Status SET StatusComment = StatusComment +
				' ' + CONVERT(varchar, CONVERT(DATETIME, CAST([StatusDate] AS varchar), 112), 1),
				StatusDate = StatusPostedDate
		WHERE StatusCode = 'APT'

		UPDATE #Status SET StatusComment =
		COALESCE(
			'Trailer dispatched from ' + OrigCityState
		+ ' to ' + DestCityState,
		'Trailer dispatched To terminal')
		WHERE StatusCode = 'DSP'

		UPDATE #Status SET StatusComment =
		COALESCE(CASE WHEN Charindex('@', StatusComment, 0) > 0 THEN
			'Trailer enroute at ' + LTRIM(RTRIM(SUBSTRING(StatusComment, Charindex('@', StatusComment, 0) + 1, (LEN(StatusComment) - Charindex('@', StatusComment, 0)) )))
		ELSE
			'Trailer enroute at ' + LTRIM(RTRIM(StatusComment))
		END,
			'Trailer enroute')
		WHERE StatusCode = 'ENR'

		UPDATE #Status SET StatusComment = StatusComment +
				' in ' + Case WHEN @manifestCount = 1 THEN DestCityState
				WHEN StatusDate > MnfstDate THEN DestCityState
				ELSE OrigCityState END
		WHERE StatusCode = 'UNL'

		/*
		INSERT INTO RoadrunnerCentral.dbo.TrackingStatusCache2013
			([ProNumber], [StatusDate], [StatusTime], [StatusCode], [StatusComment])
		SELECT [ProNumber]
			,CONVERT(DATETIME, CAST([StatusDate] AS varchar), 112) AS [StatusDate]
			,[StatusTime]
			,[StatusCode]
			,[StatusComment]
		FROM #status
		*/

		DROP TABLE #MfstData
		DROP TABLE #agents
		DROP Table #Appt
	--END

	IF @webSite = 1
		BEGIN
			SELECT --t.TrackingStatusCacheID,
				t.ProNumber,
				Convert(varchar, CONVERT(DATETIME, CAST(t.[StatusDate] AS varchar), 112), 1) AS StatusDate,
				t.StatusTime, t.StatusCode, t.StatusComment
			FROM #status t --RoadrunnerCentral.dbo.TrackingStatusCache2013 t
			 WHERE t.ProNumber = @proNumber AND t.StatusCode NOT IN ('DUD', 'INV')
			ORDER BY t.StatusDate ASC, CAST(t.StatusTime as integer) ASC, t.StatusCode ASC
		END
	ELSE
		BEGIN
			SELECT --t.TrackingStatusCacheID,
				t.ProNumber, Convert(varchar, CONVERT(DATETIME, CAST(t.[StatusDate] AS varchar), 112), 1) AS StatusDate,
				t.StatusTime, t.StatusCode, t.StatusComment
			FROM #status t --RoadrunnerCentral.dbo.TrackingStatusCache2013 t
			 WHERE t.ProNumber = @proNumber
			ORDER BY t.StatusDate DESC, CAST(t.StatusTime as integer) DESC
		END
	DROP TABLE #status
END



GO



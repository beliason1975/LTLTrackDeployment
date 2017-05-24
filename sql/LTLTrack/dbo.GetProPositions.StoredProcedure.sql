USE [LTLTrack]
GO
/****** Object:  StoredProcedure [dbo].[GetProPositions]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetProPositions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetProPositions] AS' 
END
GO


ALTER PROCEDURE [dbo].[GetProPositions]
		@proNumber int
AS


BEGIN

select TP.*, PTP.FK_Pro as ProID	from 
			ProTruckPosition PTP
join		TruckPosition TP on TP.PK_TruckPosition = PTP.FK_TruckPosition
where PTP.FK_Pro = @proNumber
order by TP.TruckID, TP.PingTimeStamp desc

END



GO

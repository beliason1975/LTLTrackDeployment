USE [LTLTrack]
GO
/****** Object:  StoredProcedure [dbo].[GetTrackingMessages]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetTrackingMessages]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetTrackingMessages] AS' 
END
GO




--
-- Chris Coffman 4/16/2017
-- Return Tracking Messages
--

ALTER PROCEDURE [dbo].[GetTrackingMessages]

AS
BEGIN
SET NOCOUNT ON

SELECT [PK_MessageID]
      ,[TrackingCode]
      ,[TrackingMessage] as TrackingMessageText
      ,[FullMessage]
      ,[Tracking]
      ,[StatusReport]
  FROM [LTLTrack].[dbo].[TrackingMessages]
  END



GO

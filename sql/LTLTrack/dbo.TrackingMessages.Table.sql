USE [LTLTrack]
GO
/****** Object:  Table [dbo].[TrackingMessages]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrackingMessages]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TrackingMessages](
	[PK_MessageID] [int] NOT NULL,
	[TrackingCode] [varchar](50) NOT NULL,
	[TrackingMessage] [varchar](70) NOT NULL,
	[FullMessage] [bit] NOT NULL,
	[Tracking] [bit] NOT NULL,
	[StatusReport] [bit] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [FK_TrackingCode]    ******/2017 2:33:46 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TrackingMessages]') AND name = N'FK_TrackingCode')
CREATE CLUSTERED INDEX [FK_TrackingCode] ON [dbo].[TrackingMessages]
(
	[TrackingCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

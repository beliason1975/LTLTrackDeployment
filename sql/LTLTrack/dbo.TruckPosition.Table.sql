USE [LTLTrack]
GO
/****** Object:  Table [dbo].[TruckPosition]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TruckPosition]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TruckPosition](
	[PK_TruckPosition] [int] IDENTITY(1,1) NOT NULL,
	[TruckID] [varchar](50) NOT NULL,
	[RandMessageID] [int] NOT NULL,
	[Odometer] [int] NULL,
	[Speed] [int] NULL,
	[IgnitionOn] [bit] NULL,
	[InMotion] [bit] NULL,
	[Latitude] [real] NULL,
	[Longitude] [real] NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](10) NULL,
	[Region] [varchar](50) NULL,
	[Proximity] [varchar](50) NULL,
	[Bearing] [int] NULL,
	[PingTimeStamp] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_TruckPosition] PRIMARY KEY CLUSTERED 
(
	[PK_TruckPosition] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Index [IX_PingTimeStamp]    ******/2017 2:38:50 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TruckPosition]') AND name = N'IX_PingTimeStamp')
CREATE NONCLUSTERED INDEX [IX_PingTimeStamp] ON [dbo].[TruckPosition]
(
	[PingTimeStamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_TruckID]    ******/2017 2:38:50 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TruckPosition]') AND name = N'IX_TruckID')
CREATE NONCLUSTERED INDEX [IX_TruckID] ON [dbo].[TruckPosition]
(
	[TruckID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ProPosition_PingTimeStamp]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TruckPosition] ADD  CONSTRAINT [DF_ProPosition_PingTimeStamp]  DEFAULT (getdate()) FOR [PingTimeStamp]
END

GO

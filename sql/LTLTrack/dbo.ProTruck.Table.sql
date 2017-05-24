USE [LTLTrack]
GO
/****** Object:  Table [dbo].[ProTruck]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProTruck]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProTruck](
	[FK_Pro] [int] NOT NULL,
	[TruckID] [varchar](50) NOT NULL,
	[StopTrackingPosition] [bit] NOT NULL,
 CONSTRAINT [PK_ProTruck_1] PRIMARY KEY CLUSTERED 
(
	[FK_Pro] ASC,
	[TruckID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ProTruck_Invalid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ProTruck] ADD  CONSTRAINT [DF_ProTruck_Invalid]  DEFAULT ((0)) FOR [StopTrackingPosition]
END

GO

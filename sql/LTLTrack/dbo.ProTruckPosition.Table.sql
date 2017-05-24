USE [LTLTrack]
GO
/****** Object:  Table [dbo].[ProTruckPosition]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProTruckPosition](
	[FK_TruckPosition] [int] NOT NULL,
	[FK_Pro] [int] NOT NULL,
 CONSTRAINT [PK_ProTruckPosition] PRIMARY KEY CLUSTERED 
(
	[FK_TruckPosition] ASC,
	[FK_Pro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_Pro]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
ALTER TABLE [dbo].[ProTruckPosition]  WITH CHECK ADD  CONSTRAINT [FK_ProTruckPosition_Pro] FOREIGN KEY([FK_Pro])
REFERENCES [dbo].[Pro] ([PK_Pro])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_Pro]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
ALTER TABLE [dbo].[ProTruckPosition] CHECK CONSTRAINT [FK_ProTruckPosition_Pro]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_TruckPosition]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
ALTER TABLE [dbo].[ProTruckPosition]  WITH CHECK ADD  CONSTRAINT [FK_ProTruckPosition_TruckPosition] FOREIGN KEY([FK_TruckPosition])
REFERENCES [dbo].[TruckPosition] ([PK_TruckPosition])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_TruckPosition]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
ALTER TABLE [dbo].[ProTruckPosition] CHECK CONSTRAINT [FK_ProTruckPosition_TruckPosition]
GO

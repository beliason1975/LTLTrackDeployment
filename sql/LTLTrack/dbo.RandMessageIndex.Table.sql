USE [LTLTrack]
GO
/****** Object:  Table [dbo].[RandMessageIndex]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RandMessageIndex]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RandMessageIndex](
	[PK_RandMessageIndex] [int] IDENTITY(1,1) NOT NULL,
	[PreviousLastMaxIndexReceived] [int] NOT NULL,
	[LastMaxIndexReceived] [int] NOT NULL,
 CONSTRAINT [PK_RandMessageIndex] PRIMARY KEY CLUSTERED 
(
	[PK_RandMessageIndex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_RandMessageIndex_PreviousLastMaxIndexReceived]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RandMessageIndex] ADD  CONSTRAINT [DF_RandMessageIndex_PreviousLastMaxIndexReceived]  DEFAULT ((1)) FOR [PreviousLastMaxIndexReceived]
END

GO

USE [LTLTrack]
GO
/****** Object:  Table [dbo].[Pro]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pro]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Pro](
	[PK_Pro] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[DispatchCode] [int] NULL,
	[Pieces] [int] NULL,
	[Weight] [int] NULL,
	[Origin] [varchar](256) NULL,
	[OriginAddress] [varchar](256) NULL,
	[OriginCity] [varchar](50) NULL,
	[OriginState] [varchar](10) NULL,
	[OriginZip] [varchar](10) NULL,
	[Consignee] [varchar](256) NULL,
	[ConsigneeAddress] [varchar](256) NULL,
	[ConsigneeCity] [varchar](50) NULL,
	[ConsigneeState] [varchar](10) NULL,
	[ConsigneeZip] [varchar](10) NULL,
	[Manifest] [int] NULL,
	[BOL] [varchar](50) NULL,
	[PoNumber] [varchar](50) NULL,
	[PickupNumber] [int] NULL,
	[AppointmentDate] [datetime2](7) NULL,
	[EstDeliveryDate] [datetime2](7) NULL,
	[DeliveredDate] [datetime2](7) NULL,
 CONSTRAINT [PK_Pro] PRIMARY KEY CLUSTERED 
(
	[PK_Pro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Index [IX_CustomerID]    ******/2017 2:38:50 PM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Pro]') AND name = N'IX_CustomerID')
CREATE NONCLUSTERED INDEX [IX_CustomerID] ON [dbo].[Pro]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

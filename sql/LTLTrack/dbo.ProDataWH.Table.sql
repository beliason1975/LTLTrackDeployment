USE [LTLTrack]
GO
/****** Object:  Table [dbo].[ProDataWH]    ******/2017 2:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProDataWH]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProDataWH](
	[Pro] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[DispatchCode] [int] NOT NULL,
	[Pieces] [int] NOT NULL,
	[Weight] [int] NOT NULL,
	[Origin] [varchar](50) NOT NULL,
	[OriginAddress] [varchar](50) NOT NULL,
	[OriginCity] [varchar](25) NOT NULL,
	[OriginState] [varchar](50) NOT NULL,
	[OriginZIP] [varchar](50) NOT NULL,
	[Consignee] [varchar](50) NOT NULL,
	[ConsigneeAddress] [varchar](50) NOT NULL,
	[ConsigneeCity] [varchar](50) NOT NULL,
	[ConsigneeState] [varchar](25) NOT NULL,
	[ConsigneeZIP] [varchar](50) NOT NULL,
	[Manifest] [int] NOT NULL,
	-- [StatusCode] [char](3) NOT NULL,
	-- [StatusDate] [date] NULL,
	-- [StatusTime] [decimal](4, 0) NOT NULL,
	-- [StatusComment] [char](50) NOT NULL,
	-- [Manifest] [char](20) NOT NULL,
	[Tractor] [varchar](50) NOT NULL,
	[BOL] [varchar](50) NULL,
	[PONumber] [varchar](50) NULL,
	[PickupNumber] [int] NULL,
	[ApptDate] [datetime2](7) NULL,
	[EstDeliveryDate] [datetime2](7) NULL,
	[DeliveredDate] [datetime2](7) NULL
) ON [PRIMARY]
END
GO

USE [LTLTrack_Demo]
GO

/****** Object:  StoredProcedure [dbo].[InsertProTrucks]    Script Date: 05/05/2017 4:09:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertProTrucks]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[InsertProTrucks] AS' 
END
GO

-- =============================================
-- Author:		Jason Stack
-- Create date: 10MAR2017
-- Description:	Append Pro truck data
-- =============================================
ALTER PROCEDURE [dbo].[InsertProTrucks] 
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO dbo.ProTruck
	(
		FK_Pro
		, TruckID
		, Manifest
	)
	SELECT ProDataWH.Pro
		, ProDataWH.Tractor
		, ProDataWH.Manifest
	FROM dbo.ProDataWH
		LEFT JOIN dbo.ProTruck
			ON ProDataWH.Pro = ProTruck.FK_Pro
				AND ProDataWH.Tractor = ProTruck.TruckID
	WHERE ISNULL(ProTruck.FK_Pro, 0) = 0
		AND ISNULL(ProTruck.TruckID, '') = ''
	GROUP BY ProDataWH.Pro
		, ProDataWH.Tractor
		, ProDataWH.Manifest;
END

GO


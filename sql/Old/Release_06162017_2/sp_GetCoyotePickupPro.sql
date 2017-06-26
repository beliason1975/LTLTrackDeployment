USE [RoadrunnerCentral]
GO

/****** Object:  StoredProcedure [dbo].[GetCoyotePickupPro]    Script Date: 06/19/2017 2:21:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetCoyotePickupPro]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GetCoyotePickupPro] AS'
END
GO



-- =============================================
-- Author:		Dan Paluszynski
-- Create date: 08/26/2016
-- Description:	Gets a pickup #s PRO #, or a PRO #s pickup #
--				@GetType 0 - Get by pickup #; 1 - Get by pro #
-- =============================================
ALTER PROCEDURE [dbo].[GetCoyotePickupPro] (
	@GetValue NCHAR(20),
	@GetType TINYINT
)
AS
BEGIN
	IF @GetType = 0
		BEGIN
			SELECT
			  DLPRO, DLPUNO
			FROM [COYOTE].[B10A282B].[RDFSV31DTA].[PUTRAN] P
			WHERE DLPUNO = @GetValue
		END
	ELSE IF @GetType = 1
		BEGIN
			--SELECT @GetValue AS [DLPRO], NULL AS [DLPUNO]
			SELECT
			  DLPRO, DLPUNO
			FROM [COYOTE].[B10A282B].[RDFSV31DTA].[PUTRAN] P
			WHERE DLPRO = @GetValue
		END
END







GO



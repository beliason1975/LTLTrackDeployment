USE [RoadrunnerCentral]
GO

/****** Object:  StoredProcedure [dbo].[LTLTrack_GetCoyotePickupPro]    Script Date: 06/23/2017 1:26:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LTLTrack_GetCoyotePickupPro]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LTLTrack_GetCoyotePickupPro] AS'
END
GO





-- =============================================
-- Author:		Dan Paluszynski
-- Create date: 08/26/2016
-- Description:	Gets a pickup #s PRO #, or a PRO #s pickup #
--				@GetType 0 - Get by pickup #; 1 - Get by pro #
-- =============================================
ALTER PROCEDURE [dbo].[LTLTrack_GetCoyotePickupPro] (
	@GetValue VARCHAR(20),
	@GetType INT
)
AS
BEGIN
    declare @query1 varchar(max);

	IF @GetType = 0
	BEGIN
        set @query1 =
        'SELECT * FROM OPENQUERY(COYOTE, ''
			    SELECT DLPRO, DLPUNO
			    FROM [RDFSV31DTA].[PUTRAN] P
			    WHERE DLPUNO = ' + @GetValue + ' FETCH FIRST ROW ONLY
        '')';
        EXEC(@query1);
	END
	ELSE
	BEGIN
        set @query1 =
        'SELECT * FROM OPENQUERY(COYOTE, ''
			    SELECT DLPRO, DLPUNO
			    FROM [RDFSV31DTA].[PUTRAN] P
			    WHERE DLPRO = ' + @GetValue + ' FETCH FIRST ROW ONLY
        '')';
        EXEC(@query1);
	END
END



GO



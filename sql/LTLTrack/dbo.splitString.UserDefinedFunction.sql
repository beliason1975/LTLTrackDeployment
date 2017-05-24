USE [LTLTrack]
GO
/****** Object:  UserDefinedFunction [dbo].[splitString]    ******/2017 2:33:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[splitString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[splitString] (@stringToSplit VARCHAR(MAX))
RETURNS @returnList TABLE ([Name] [nvarchar](500))
AS
BEGIN
	DECLARE @name NVARCHAR(255)
	DECLARE @pos INT

	WHILE CHARINDEX('','', @stringToSplit) > 0
	BEGIN
		SELECT @pos = CHARINDEX('','', @stringToSplit)

		SELECT @name = SUBSTRING(@stringToSplit, 1, @pos - 1)

		INSERT INTO @returnList
		SELECT @name

		SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos + 1, LEN(@stringToSplit) - @pos)
	END

	INSERT INTO @returnList
	SELECT @stringToSplit

	RETURN
END
' 
END

GO

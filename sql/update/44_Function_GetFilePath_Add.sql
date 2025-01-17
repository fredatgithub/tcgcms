set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE FUNCTION [dbo].[GetFilePath]
(
	@vcUrl VARCHAR(255),
	@vcFilePath VARCHAR(255)
)
RETURNS VARCHAR(255)
AS
BEGIN

DECLARE @reValue VARCHAR(255)
IF(@vcUrl IS NULL OR @vcUrl = '')
BEGIN
	SET @reValue = @vcFilePath
END
ELSE
BEGIN
	SET @reValue = @vcUrl
END

RETURN  @reValue
END



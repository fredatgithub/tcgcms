set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROC [dbo].[SP_Manage_CheckAdminPower]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@reValue INT OUTPUT
)
/*
DECLARE @reValue INT
EXEC SP_Manage_CheckAdminPower
	@vcAdminName ='admins',
	@vcIp ='127.0.0.1',
	@reValue = @reValue OUTPUT

SELECT @reValue
*/
AS

EXEC SP_Manage_CheckIP
	@vcIP = @vcip,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN;
END

IF(@vcAdminName IS NULL OR @vcAdminName ='')
BEGIN
	SET @reValue=-1000000012 --操作员为空，您是否尚未登陆？
	RETURN;
END

DECLARE @t_Online CHAR(1)
SELECT @t_Online = cIsOnline FROM admin (NOLOCK) WHERE vcAdminName =@vcAdminName

IF(@t_Online<>'Y')
BEGIN
	SET @reValue=-1000000017 --您不并不在线，您是否尚未登陆？
END

SET @reValue=1



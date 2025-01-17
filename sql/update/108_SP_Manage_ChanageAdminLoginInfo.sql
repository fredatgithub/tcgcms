set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




ALTER PROC [dbo].[SP_Manage_ChanageAdminLoginInfo]
(
	@vcAdminName varchar(50),
	@oldPwd VARCHAR(32),
	@NewPwd VARCHAR(32),
	@vcNickName VARCHAR(50),
	@vcIP VARCHAR(15),
	@reValue INT OUTPUT
)
AS

EXEC SP_Manage_CheckAdminPower
	@vcAdminName =@vcAdminName,
	@vcIp =@vcIp,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN;
END

DECLARE @t_pwd VARCHAR(32)
DECLARE @t_lock CHAR(1)

SELECT @t_pwd = vcPassword,@t_lock = cLock FROM admin (NOLOCK) WHERE  vcAdminName = @vcAdminName

IF(@t_pwd<>@oldPwd)
BEGIN
	SET @reValue = -1000000009 --输入原始密码不正确
	RETURN;
END

IF(@t_lock='Y')
BEGIN
	SET @reValue = -1000000010 --您的帐号已经锁定，不能修改登陆信息
	RETURN;
END

IF(@NewPwd='' OR @NewPwd IS NULL)
BEGIN
	UPDATE admin SET vcNickName = @vcNickName
	WHERE vcAdminName = @vcAdminName
END
ELSE
BEGIN
	UPDATE admin SET vcNickName = @vcNickName,vcPassword = @NewPwd
	WHERE vcAdminName = @vcAdminName
END

EXEC SP_Manage_OnlineMdy
	@vcAdminName = @vcAdminName,
	@vcIp = @vcIp,
	@vcActive = '修改登陆信息',
	@reValue = @reValue

IF(@reValue<0)
BEGIN
	RETURN;
END

SET @reValue = 1





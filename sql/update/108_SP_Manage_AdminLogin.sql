set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go










ALTER proc [dbo].[SP_Manage_AdminLogin]
(
	@vcAdminName varchar (50),
	@vcPassword varchar(32),
	@vcip VARCHAR(15),
	@reValue int output 
)

/*
DECLARE @reValue int
EXEC SP_Manage_AdminLogin
	@vcAdminName = 'admin',
	@vcPassword = 'admin',
	@vcip ='127.0.0.1',
	@reValue = @reValue output 

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

DECLARE @T_name varchar(50)
DECLARE @T_pwd varchar(32)
DECLARE @clock char(1)
DECLARE @cIsOnline CHAR(1)
DECLARE @t_lastIp VARCHAR(15)
DECLARE @t_isDel CHAR(1)

SET @cIsOnline = 'N'
SET @t_isDel = 'N'

EXEC Sp_Manage_OnlineKickTimeOutAdmin

SELECT @T_name = vcAdminName,@T_pwd=vcPassword,@clock = clock,@cIsOnline=cIsOnline ,
@t_lastIp = vcLastLoginIp,@t_isDel=cIsDel FROM admin (NOLOCK) WHERE vcAdminName = @vcAdminName

IF(@T_name IS NULL)
BEGIN
	SET  @reValue = -1000000002 --用户不存在
	RETURN
END

IF(@cIsOnline='Y' AND @t_lastIp <> @vcip)
BEGIN
	SET @reValue = -1000000005 --管理员已经在线
	RETURN
END

IF(@T_pwd<>@vcPassword)
BEGIN
	SET @reValue = -1000000003 --用户密码错误
	RETURN
END

IF(@clock='Y')
BEGIN
	SET @reValue = -1000000004 --用户已经被锁定
	RETURN
END

IF(@t_isDel='Y')
BEGIN
	SET @reValue = -1000000018 --您的帐号已经被删除，请联系管理员！
	RETURN;
END

EXEC SP_Manage_OnlineMdy
	@vcAdminName = @vcAdminName,
	@vcIp = @vcip,
	@vcActive = '登陆后台',
	@reValue = @reValue

IF(@reValue<0)
BEGIN
	RETURN;
END

UPDATE admin SET vcLastLoginIp = @vcip,iLoginCount=iLoginCount+1,
dLastLoginDate = GETDATE() WHERE vcAdminName = @vcAdminName

SET @reValue = 1








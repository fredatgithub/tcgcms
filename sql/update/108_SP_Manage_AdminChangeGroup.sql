set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





ALTER PROC [dbo].[SP_Manage_AdminChangeGroup]
(
	@vcAdminName VARCHAR(50),
	@iRoleId INT,
	@vcAdmins VARCHAR(1000),
	@vcIp VARCHAR(15),
	@reValue INT OUTPUT
)
/*
DECLARE @reValue INT
EXEC SP_Manage_AdminChangeGroup
	@vcAdminName = 'admin',
	@iRoleId =1,
	@vcAdmins ='''leo85729'',''admin''',
	@vcIp ='127.0.0.1',
	@reValue = @reValue OUTPUT

SELECT @reValue
*/
AS

EXEC SP_Manage_CheckAdminPower
	@vcAdminName =@vcAdminName,
	@vcIp =@vcIp,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN;
END


IF(@iRoleId=0 OR @iRoleId IS NULL)
BEGIN
	SET @reValue=-1000000011 --组编号不正确
	RETURN;
END

IF(CHARINDEX(',',@vcAdmins)>0)
BEGIN
	DECLARE @sql NVARCHAR(2000)
	SET @sql = 'UPDATE admin SET iRole = '+CAST(@iRoleId AS VARCHAR(1000))
	+' WHERE vcAdminName IN ('+@vcAdmins+')'
	Execute Sp_Executesql @sql
END
ELSE
BEGIN
	SET @vcAdmins = REPLACE(@vcAdmins,'''','');
	UPDATE admin SET iRole = @iRoleId WHERE vcAdminName=@vcAdmins
END


DECLARE @log VARCHAR(1000)
SET @log = '移动管理员[' + @vcAdmins + ']到角色组ID【'+CAST(@iRoleId AS VARCHAR(1000))+'】'
EXEC SP_Manage_OnlineMdy
	@vcAdminName = @vcAdminName,
	@vcIp = @vcip,
	@vcActive = @log,
	@reValue = @reValue

IF(@reValue<0)
BEGIN
	RETURN;
END

SET @reValue=1






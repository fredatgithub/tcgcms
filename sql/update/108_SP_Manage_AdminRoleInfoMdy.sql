set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





ALTER PROC [dbo].[SP_Manage_AdminRoleInfoMdy]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@vcRoleName VARCHAR(50),
	@vcContent VARCHAR(255),
	@vcPopedom VARCHAR(1000),
	@vcClassPopedom VARCHAR(255),
	@cAction CHAR(2) ='01',
	@iRole INT = 0,
	@reValue INT OUTPUT
)
AS

IF(@vcRoleName IS NULL OR @vcRoleName='')
BEGIN
	SET @reValue = -1000000013  --角色组名称不能为空
	RETURN;
END

EXEC SP_Manage_CheckAdminPower
	@vcAdminName =@vcAdminName,
	@vcIp =@vcIp,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN;
END

DECLARE @log VARCHAR(1000)

IF(@cAction='01')
BEGIN
	SET @log = '添加角色组[' + @vcRoleName + ']'
	INSERT INTO AdminRole (vcRoleName,vcContent,vcPopedom,vcClassPopedom)
	VALUES(@vcRoleName,@vcContent,@vcPopedom,@vcClassPopedom)
END

IF(@cAction='02' AND @iRole>0)
BEGIN
	SET @log = '修改角色组[' + CAST(@iRole AS VARCHAR(1000)) + ':' + @vcRoleName + ']'
	UPDATE AdminRole
	SET vcRoleName = @vcRoleName,vcContent=@vcContent,vcPopedom=@vcPopedom,
	vcClassPopedom=@vcClassPopedom WHERE iID = @iRole
END



EXEC SP_Manage_OnlineMdy
	@vcAdminName = @vcAdminName,
	@vcIp = @vcip,
	@vcActive = @log,
	@reValue = @reValue

IF(@reValue<0)
BEGIN
	RETURN;
END

SET @reValue = 1







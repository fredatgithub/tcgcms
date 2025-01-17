set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROC [dbo].[SP_Manage_AdminRoleDel]
(
	@vcAdminName VARCHAR(50),
	@vcIP VARCHAR(15),
	@iRole INT,
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

IF(@iRole IS NULL OR @iRole ='')
BEGIN
	SET @reValue = -1000000014 -- 角色组编号不能为空
	RETURN;
END

DECLARE @t_Count INT
SELECT @t_Count = COUNT(1) FROM admin (NOLOCK) WHERE iRole = @iRole
IF(@t_Count>0)
BEGIN
	SET @reValue = -1000000015 -- 要删除此联系组，请先移出或删除此组中的管理员
	RETURN;
END


DELETE AdminRole WHERE iID = @iRole

DECLARE @log VARCHAR(1000)
SET @log = '删除角色组ID['+CAST(@iRole AS VARCHAR(1000))+']'
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




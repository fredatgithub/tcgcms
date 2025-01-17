set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROC [dbo].[SP_Manage_DelAdmins]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@vcAdmins VARCHAR(1000),
	@action CHAR(2) ='01',
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

IF(@vcAdmins ='' OR @vcAdmins IS NULL)
BEGIN
	SET @reValue = -1000000016 --尚未选择需要删除的管理员
	RETURN;
END

DECLARE @sql NVARCHAR(2000)
DECLARE @log VARCHAR(1000)
IF(@action='01')
BEGIN
	IF(CHARINDEX(',',@vcAdmins)>0)
	BEGIN
		SET @sql = 'UPDATE admin SET cIsDel = ''Y'''+
		+' WHERE vcAdminName IN ('+@vcAdmins+')'
		Execute Sp_Executesql @sql
	END
	ELSE
	BEGIN
		SET @vcAdmins = REPLACE(@vcAdmins,'''','');
		UPDATE admin SET cIsDel = 'Y' WHERE vcAdminName=@vcAdmins
	END
	
	SET @log = '删除管理员[' + @vcAdmins + ']到回收站'
END

IF(@action='02')
BEGIN
	IF(CHARINDEX(',',@vcAdmins)>0)
	BEGIN
		SET @sql = 'DELETE admin WHERE vcAdminName IN ('+@vcAdmins+')'
		Execute Sp_Executesql @sql
	END
	ELSE
	BEGIN
		SET @vcAdmins = REPLACE(@vcAdmins,'''','');
		DELETE admin WHERE vcAdminName=@vcAdmins
	END
	SET @log = '彻底删除管理员[' + @vcAdmins + ']'
END

IF(@action='03')
BEGIN
	IF(CHARINDEX(',',@vcAdmins)>0)
	BEGIN
		SET @sql = 'UPDATE admin SET cIsDel = ''N'''+
		+' WHERE vcAdminName IN ('+@vcAdmins+')'
		Execute Sp_Executesql @sql
	END
	ELSE
	BEGIN
		SET @vcAdmins = REPLACE(@vcAdmins,'''','');
		UPDATE admin SET cIsDel = 'N' WHERE vcAdminName=@vcAdmins
	END
	
	SET @log = '救回管理员[' + @vcAdmins + ']'
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

SET @reValue =1



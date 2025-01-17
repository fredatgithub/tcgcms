set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROC [dbo].[SP_Template_DelTemplate]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@vctemps VARCHAR(1000),
	@reValue INT OUTPUT 
)
AS

IF(@vctemps ='' OR @vctemps IS NULL)
BEGIN
	SET @reValue = -1000000028 --尚未选择需要删除的资讯模版
	RETURN;
END	

IF(@vcAdminName='' OR @vcAdminName IS NULL)
BEGIN
	SET @reValue= -1000000012 --操作员为空，您是否尚未登陆？
	RETURN
END

DECLARE @sql NVARCHAR(2000)

IF(CHARINDEX(',',@vctemps)>0)
BEGIN
	SET @sql = 'DELETE TemplateInfo WHERE Id IN ('+@vctemps+')'
	Execute Sp_Executesql @sql
END
ELSE
BEGIN
	DELETE TemplateInfo WHERE Id = @vctemps
END


DECLARE @LOG VARCHAR(2000)
SET @LOG='删除模版['+@vctemps+']'
EXEC Sp_Manage_AddAdminLog
	@vcAdminName = @vcAdminName,
	@vcActive = @LOG,
	@vcIp =@vcIp,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN
END

SET @reValue =1



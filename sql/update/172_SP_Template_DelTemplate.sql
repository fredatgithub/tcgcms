USE [TCGDB]
GO
/****** 对象:  StoredProcedure [dbo].[SP_Template_DelTemplate]    脚本日期: 03/15/2010 14:45:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



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


SET @sql = 'DELETE Template WHERE Id IN ('+@vctemps+')'
Execute Sp_Executesql @sql


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




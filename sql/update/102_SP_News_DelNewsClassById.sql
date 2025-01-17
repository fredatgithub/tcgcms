set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROC [dbo].[SP_News_DelNewsClassById]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@iClassId INT,
	@reValue INT OUTPUT
)
AS

IF(@vcAdminName ='' OR @vcAdminName IS NULL)
BEGIN
	SET @reValue=-1000000012 --操作员为空，您是否尚未登陆？
	RETURN;
END

IF(@iClassId =0 OR @iClassId IS NULL)
BEGIN
	SET @reValue=-1000000031 --资讯分类编号为空
	RETURN;
END

DECLARE @n_count INT
SET @n_count = 0
SELECT @n_count =  COUNT(1) FROM T_News_NewsInfo (NOLOCK) WHERE iClassID=@iClassId
IF(@n_count>0)
BEGIN
	SET @reValue=-1000000032 --该分类下还存在资源，请移出后再删除
	RETURN;
END

SET @n_count = 0
SELECT @n_count =  COUNT(1) FROM Categories (NOLOCK) WHERE iParent = @iClassId
IF(@n_count>0)
BEGIN
	SET @reValue=-1000000033 --该分类下还存在子分类，请移出后再删除
	RETURN;
END

DELETE Categories WHERE iID=@iClassId

DECLARE @LOG VARCHAR(100)
SET @LOG ='删除分类['+CAST(@iClassId AS VARCHAR)+']'

EXEC Sp_Manage_AddAdminLog
	@vcAdminName =@vcAdminName,
	@vcActive = @LOG,
	@vcIp = @vcIp,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN
END

SET @reValue=1



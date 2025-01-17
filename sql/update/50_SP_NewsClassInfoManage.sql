





IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_News_AddClassInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_News_AddClassInfo]


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SP_News_ClassInfoManage]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@vcClassName VARCHAR(200),
	@vcName VARCHAR(50),
	@iParent INT,
	@iTemplate INT,
	@iListTemplate INT,
	@vcDirectory VARCHAR(200),
	@vcUrl VARCHAR(255),
	@iOrder INT,
	@action CHAR(2) ='01',
	@cVisible CHAR(1) = 'Y',
	@iClassId INT = 0,
	@reValue INT OUTPUT
)

/*

DECLARE @reValue INT
EXEC SP_News_AddClassInfo
	@vcAdminName ='admin',
	@vcIp ='127.0.0.1',
	@vcClassName ='dsfsdg',
	@vcName ='dgg',
	@iParent =0,
	@iTemplate = 0,
	@iListTemplate=0,
	@vcDirectory='',
	@vcUrl ='',
	@iOrder =0,
	@reValue =@reValue OUTPUT

SELECT @reValue
*/
AS

IF(@vcAdminName IS NULL OR @vcAdminName ='')
BEGIN
	SET @reValue=-1000000012 --操作员为空，您是否尚未登陆？
	RETURN;
END

IF(@vcClassName='' OR @vcClassName IS NULL OR @vcName='' OR @vcName IS NULL)
BEGIN
	SET @reValue=-1000000020 --分类名或别名不能为空
	RETURN
END

IF(@iParent<>0)
BEGIN
	IF(@iTemplate=0 OR @iTemplate IS NULL)
	BEGIN
		SET @reValue=-1000000021 --模版编号不能为空
		RETURN
	END

	IF(@iListTemplate=0 OR @iListTemplate IS NULL)
	BEGIN
		SET @reValue=-1000000029 --列表模版编号不能为空
		RETURN
	END

	IF(@vcDirectory='' OR @vcDirectory IS NULL)
	BEGIN
		SET @reValue=-1000000022 --生成路径不能为空
		RETURN
	END

	IF(@vcUrl='' OR @vcUrl IS NULL)
	BEGIN
		SET @reValue=-1000000023 --前台分类首页不能为空
		RETURN
	END
END

DECLARE @TID INT
DECLARE @LOG VARCHAR(100)

IF(@action='01')
BEGIN
	
	INSERT INTO T_News_ClassInfo(vcClassName,vcName,iParent,iTemplate,iListTemplate,vcDirectory,vcUrl,iOrder,Visible)
	VALUES(@vcClassName,@vcName,@iParent,@iTemplate,@iListTemplate,@vcDirectory,@vcUrl,@iOrder,@cVisible)

	SET @TID=@@IDENTITY
	SET @LOG ='添加资讯分类'+CAST(@TID AS VARCHAR)
END

IF(@action='02')
BEGIN
	IF(@iClassId=@iParent)
	BEGIN
		SET @reValue=-1000000030 --父类ID不能为自己的ID
		RETURN;
	END
--	DECLARE @T_COUNT INT
--	SET @T_COUNT = 0
--	SELECT @T_COUNT = COUNT(1) FROM T_News_ClassInfo (NOLOCK) WHERE iParent= @iClassId
--	IF(@T_COUNT>0)
--	BEGIN
--		SET @reValue = -1000000056 --父分类不能变成孩子的孩子
--		RETURN
--	END

	SET @LOG ='修改资讯分类'+CAST(@iClassId AS VARCHAR)
	UPDATE T_News_ClassInfo SET vcClassName=@vcClassName,@vcName=vcName,iParent=@iParent,
	iTemplate=@iTemplate,iListTemplate=@iListTemplate,vcDirectory=@vcDirectory,vcUrl=@vcUrl,iOrder=@iOrder,
	Visible = @cVisible
	WHERE iID =@iClassId
END

EXEC Sp_Manage_AddAdminLog
	@vcAdminName =@vcAdminName,
	@vcActive = @LOG,
	@vcIp = @vcIp,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN
END
SET @reValue =1








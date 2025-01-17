set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROC [dbo].[SP_Skin_categories_Manage]
(
	@vcClassName VARCHAR(200),
	@vcName VARCHAR(50),
	@Parent VARCHAR(36),
	@iTemplate VARCHAR(36),
	@iListTemplate VARCHAR(36),
	@vcDirectory VARCHAR(200),
	@vcUrl VARCHAR(255),
	@SkinId VARCHAR(36) = '',
	@iOrder INT,
	@action CHAR(2) ='01',
	@cVisible CHAR(1) = 'Y',
	@iClassId VARCHAR(36),
	@DataBaseService VARCHAR(50) ='',
	@reValue INT OUTPUT
)

/*

DECLARE @reValue INT
EXEC SP_News_AddClassInfo
	@vcClassName ='dsfsdg',
	@vcName ='dgg',
	@iParent =0,
	@iTemplate = 0,
	@iListTemplate=0,
	@vcDirectory='',
	@vcUrl ='',
	@iOrder =0,
	@DataBaseService=''
	@reValue =@reValue OUTPUT

SELECT @reValue
*/
AS

IF (@DataBaseService='' OR @DataBaseService IS NULL)
BEGIN
	SET @DataBaseService = 'resourceDataBase';	
END

IF(@vcClassName='' OR @vcClassName IS NULL OR @vcName='' OR @vcName IS NULL)
BEGIN
	SET @reValue=-1000000020 --分类名或别名不能为空
	RETURN
END

IF(@action='01')
BEGIN
	IF(@SkinId='' OR @SkinId IS NULL)
	BEGIN
		SET @reValue=-1000000100 --分类所属模板不能为空
		RETURN
	END
END

IF(@Parent<>0)
BEGIN
	IF(@iTemplate='' OR @iTemplate IS NULL)
	BEGIN
		SET @reValue=-1000000021 --模版编号不能为空
		RETURN
	END

	IF(@iListTemplate='' OR @iListTemplate IS NULL)
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


IF(@action='01')
BEGIN
	
	INSERT INTO Categories(Id,vcClassName,vcName,SkinId,Parent,iTemplate,iListTemplate,vcDirectory,vcUrl,iOrder,Visible,
	            DataBaseService)
	VALUES(@iClassId,@vcClassName,@vcName,@SkinId,@Parent,@iTemplate,@iListTemplate,@vcDirectory,@vcUrl,@iOrder,@cVisible,@DataBaseService)


END

IF(@action='02')
BEGIN
	IF(@iClassId=@Parent)
	BEGIN
		SET @reValue=-1000000030 --父类ID不能为自己的ID
		RETURN;
	END

	UPDATE Categories SET vcClassName=@vcClassName,vcName=@vcName,Parent=@Parent,
	iTemplate=@iTemplate,iListTemplate=@iListTemplate,vcDirectory=@vcDirectory,vcUrl=@vcUrl,iOrder=@iOrder,
	Visible = @cVisible,DataBaseService=@DataBaseService
	WHERE ID =@iClassId
END


SET @reValue =1













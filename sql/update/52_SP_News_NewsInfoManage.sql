set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROC [dbo].[SP_News_NewsInfoManage]
(
	@cAction CHAR(2) ='01',
	@iId INT =0,
	@iClassID INT,
	@vcTitle VARCHAR(100),	--资讯标题
	@vcUrl VARCHAR(255),	--跳转地址
	@vcContent TEXT,		--资讯内容
	@vcAuthor VARCHAR(50)='',	
	@iFrom INT,	--资讯来源
	@iCount INT = 0,
	@vcKeyWord VARCHAR(100),	--资讯关键字
	@vcEditor VARCHAR(50),	--资讯编辑者
	@cCreated CHAR(1)='N',
	@cPostByUser CHAR(1)='N',
	@vcSmallImg VARCHAR(255),
	@vcBigImg VARCHAR(255),
	@vcShortContent VARCHAR(500),
	@vcSpeciality VARCHAR(100),
	@cChecked CHAR(1)='N',
	@cDel CHAR(1) ='N',
	@vcFilePath VARCHAR(255),--资讯路径
	@iIDOut INT OUTPUT,
	@vcExtension VARCHAR(6),
	@cShief CHAR(2)='01',
	@cStrong CHAR(1)='N',
	@vcTitleColor VARCHAR(10)='',
	@reValue INT OUTPUT
)
/*

DECLARE @reValue INT
EXEC SP_News_NewsInfoManage
	@iClassID=0,
	@vcTitle ='',	--资讯标题
	@vcUrl ='',	--跳转地址
	@vcContent ='',		--资讯内容
	@vcAuthor ='',	
	@iFrom =0,	--资讯来源
	@vcKeyWord ='',	--资讯关键字
	@vcEditor ='',	--资讯编辑者
	@vcSmallImg ='',
	@vcBigImg ='',
	@vcShortContent ='',
	@vcSpeciality ='',
	@cChecked ='N',
	@vcFilePath ='',--资讯路径
	@reValue = @reValue OUTPUT

SELECT @reValue
*/
AS

IF(@vcTitle='' OR @vcTitle IS NULL)
BEGIN
	SET @reValue = -1000000039 --资讯标题不能为空
	RETURN
END

IF(@vcAuthor='')
BEGIN
	SET @vcAuthor=@vcEditor
END

IF(@vcEditor='' OR @vcEditor IS NULL)
BEGIN
	SET @reValue = -1000000041 --资讯编辑者不能为空
	RETURN
END

IF(@iFrom =0 OR @iFrom IS NULL)
BEGIN
	SET @reValue = -1000000042 --资讯来源不能为空
	RETURN
END

IF(@iClassID =0 OR @iClassID IS NULL)
BEGIN
	SET @reValue = -1000000056 --资讯分类不能为空
	RETURN
END

IF(@vcKeyWord ='' OR @vcKeyWord IS NULL)
BEGIN
	SET @reValue = -1000000043 --资讯关键字不能为空
	RETURN
END

IF(@cShief='02')
BEGIN
	DECLARE @C INT
	SET @C=0
	SELECT @C=COUNT(1) FROM T_News_NewsInfo (NOLOCK) WHERE vcTitle = @vcTitle AND iClassID=@iClassID
	IF(@C>0)
	BEGIN
		SET @reValue = -1000000065 --抓取文章标题不能重复
		RETURN;
	END
END

DECLARE @ClassPath VARCHAR(200)
SET @ClassPath=''
SELECT @ClassPath = vcDirectory FROM T_News_ClassInfo WHERE iId=@iClassID
IF(@ClassPath='' OR @ClassPath IS NULL)
BEGIN
	SET @reValue = -1000000045 --资讯分类不存在
	RETURN
END

SET XACT_ABORT ON
BEGIN TRY
BEGIN TRAN

	IF(@cAction='01')
	BEGIN
		DECLARE @DATE DATETIME
		SET @DATE = GETDATE()
		
		INSERT INTO T_News_NewsInfo (iClassID,vcTitle,vcUrl,vcContent,vcAuthor,iFrom,iCount,vcKeyWord,
		vcEditor,cCreated,vcSmallImg,vcBigImg,vcShortContent,vcSpeciality,cChecked,cDel,cPostByUser,
		vcFilePath,dAddDate,dUpDateDate,vcTitleColor,cStrong) VALUES(@iClassID,@vcTitle,@vcUrl,@vcContent,@vcAuthor,@iFrom,
		@iCount,@vcKeyWord,@vcEditor,@cCreated,@vcSmallImg,@vcBigImg,@vcShortContent,@vcSpeciality,
		@cChecked,@cDel,@cPostByUser,@vcFilePath,@DATE,@DATE,@vcTitleColor,@cStrong)

		SET @iIDOut = @@IDENTITY
		
	END
	
	IF(@cAction='02')
	BEGIN
		IF(@iId=0)
		BEGIN
			SET @reValue = -1000000046 --修改文章的ID不能为0
			RETURN
		END
		
		DECLARE @T_COUNT INT
		SET @T_COUNT = 0
		SELECT @T_COUNT =COUNT(1) FROM T_News_NewsInfo (NOLOCK) WHERE iId=@iId
		IF(@T_COUNT<>1)
		BEGIN
			SET @reValue = -1000000047 --修改文章不存在
			RETURN
		END
	

		UPDATE T_News_NewsInfo SET iClassID=@iClassID,vcTitle=@vcTitle,vcUrl=@vcUrl,vcContent=@vcContent,
		vcAuthor=@vcAuthor,iFrom=@iFrom,iCount=@iCount,vcKeyWord=@vcKeyWord,vcEditor=@vcEditor,
		cCreated=@cCreated,vcSmallImg=@vcSmallImg,vcBigImg=@vcBigImg,vcShortContent=@vcShortContent,
		vcSpeciality=@vcSpeciality,cChecked=@cChecked,cDel=@cDel,cPostByUser=@cPostByUser,vcFilePath=@vcFilePath,
		dUpDateDate=GETDATE(),vcTitleColor = @vcTitleColor,cStrong = @cStrong WHERE iId =@iId
		
		
		
		SET @iIDOut = @iId
	END
COMMIT
END TRY

BEGIN CATCH  
	ROLLBACK     
	SET @reValue = -1000000006		--数据库出错
	RETURN;
END CATCH
SET XACT_ABORT OFF 

SET @reValue = 1











set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




ALTER PROC [dbo].[SP_Template_ManageTemplate]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@SkinId VARCHAR(36),
	@TemplateType INT,
	@iParentId  VARCHAR(36) ='',
	@iSystemType INT =0,
	@vcTempName VARCHAR(50),
	@vcContent TEXT,
	@vcUrl VARCHAR(255),
	@action CHAR(2) = '01',
	@Id VARCHAR(36) = '',
	@reValue INT OUTPUT
)
AS

DECLARE @LOG VARCHAR(200)
DECLARE @TID INT

IF(@vcAdminName='' OR @vcAdminName IS NULL)
BEGIN
	SET @reValue= -1000000012 --操作员为空，您是否尚未登陆？
	RETURN
END

IF(@TemplateType=-1)
BEGIN
	SET @reValue= -1000000026 --请选择模版类别！ 
	RETURN
END

IF(@TemplateType=0)
BEGIN
	IF(@vcUrl='' OR @vcUrl IS NULL)
	BEGIN
		SET @reValue= -1000000024 --单页时地址不能为空 
		RETURN
	END
END

IF(@vcContent IS NULL)
BEGIN
	SET @reValue = -1000000027 --模板内容不能为空
	RETURN
END
--
--IF(@iSiteId <=0)
--BEGIN
--	SET @reValue = -1000000025 --站点ID不能为空
--	RETURN
--END

if(@action='01')
BEGIN
	INSERT INTO TemplateInfo (Id,SkinId,TemplateType,iParentId,iSystemType,vcTempName,vcContent,vcUrl,dUpdateDate,dAddDate)
	VALUES(@Id,@SkinId,@TemplateType,@iParentId,@iSystemType,@vcTempName,@vcContent,@vcUrl,GETDATE(),GETDATE())
	SET @LOG = '添加新模版['+ @Id +']'
END

if(@action='02')
BEGIN
	UPDATE TemplateInfo SET vcTempName=@vcTempName,vcContent=@vcContent,
	vcUrl=@vcUrl,dUpdateDate=GETDATE() WHERE Id = @Id
	SET @LOG = '修改模版['+CAST(@Id AS VARCHAR)+']'
END


EXEC Sp_Manage_AddAdminLog
	@vcAdminName = @vcAdminName,
	@vcActive = @LOG,
	@vcIp =@vcIp,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN
END

SET @reValue=1





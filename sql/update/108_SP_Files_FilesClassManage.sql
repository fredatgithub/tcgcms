set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROC [dbo].[SP_Files_FilesClassManage]
(
	@vcAdminName VARCHAR(50),
	@vcIP VARCHAR(15),
	@cAction CHAR(2) ='01',
	@iId INT = 0,
	@vcFileName NVARCHAR(100),
	@iParentId int =0,
	@vcMeno NVARCHAR(100),
	@reValue INT OUTPUT
)
AS
IF(@vcAdminName IS NULL OR @vcAdminName ='')
BEGIN
	SET @reValue=-1000000012 --操作员为空，您是否尚未登陆？
	RETURN;
END

IF(@vcFileName='' OR @vcFileName IS NULL)
BEGIN
	SET @reValue=-1000000057 --文件名不能为空
	RETURN
END

IF(@vcMeno='' OR @vcMeno IS NULL)
BEGIN
	SET @reValue=-1000000058 --简单说明不能为空 
	RETURN
END

DECLARE @TID INT
DECLARE @LOG NVARCHAR(100)

IF(@cAction='01')
BEGIN
	INSERT INTO filecategories (vcFileName,iParentId,vcMeno) VALUES(@vcFileName,@iParentId,@vcMeno)

	SET @TID=@@IDENTITY
	SET @LOG ='添加文件夹'+ @vcFileName
END

IF(@cAction='02')
BEGIN
	DECLARE @T_FILENAME NVARCHAR(100)
	DECLARE @T_DO NVARCHAR(100)
	SET @T_DO = ''
	
	SELECT @T_FILENAME = vcFileName,@T_DO=vcMeno FROM filecategories WHERE iId = @iId
	IF(@T_DO='')
	BEGIN
		SET @reValue=-1000000059 --修改的分类不存在
		RETURN
	END
	
	UPDATE filecategories SET vcFileName=@vcFileName,vcMeno=@vcMeno,iParentId=@iParentId
	WHERE iId = @iId

	IF(@T_FILENAME<>@vcFileName)
	BEGIN
		SET @LOG = '修改文件夹名'+@T_FILENAME+'为'+@vcFileName+' '
	END
	ELSE
	BEGIN
		SET @LOG = '修改文件夹'+@T_FILENAME
	END
	
	
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


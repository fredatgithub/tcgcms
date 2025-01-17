set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



ALTER PROC [dbo].[SP_Files_FileInfoManageByAdmin]
(
	@cAction CHAR(2) = '01',
	@vcAdminName VARCHAR(50) = '',
	@vcIp VARCHAR(15)='',
	@iID BIGINT = 0,
	@iClassId INT = 0,
	@vcFileName NVARCHAR(100)='',
	@iSize INT = 0,
	@vcType VARCHAR(10) ='',
	@iDowns INT =0,
	@iRequest INT =0,
	@reValue INT OUTPUT
)
AS

IF(@cAction='01')
BEGIN
	IF(@vcAdminName IS NULL OR @vcAdminName ='')
	BEGIN
		SET @reValue=-1000000012 --操作员为空，您是否尚未登陆？
		RETURN;
	END

	IF(@iClassId =0 OR @iClassId IS NULL)
	BEGIN
		SET @reValue=-1000000060 --文件所在的文件夹不能为空
		RETURN;
	END
	IF(@vcFileName ='' OR @vcFileName IS NULL)
	BEGIN
		SET @reValue=-1000000061 --文件名称不能为空
		RETURN;
	END
	IF(@vcType ='' OR @vcType IS NULL)
	BEGIN
		SET @reValue=-1000000062 --文件类型不能为空
		RETURN;
	END

	IF(@iSize =0 OR @iSize IS NULL)
	BEGIN
		SET @reValue=-1000000063 --文件大小不能为空
		RETURN;
	END

	INSERT INTO fileresources (iID,iClassId,vcFileName,iSize,vcType,dCreateDate,vcIP)
	VALUES(@iID,@iClassId,@vcFileName,@iSize,@vcType,GETDATE(),@vcIP)
END

IF(@cAction='02')
BEGIN
	IF(@iID =0 OR @iID IS NULL)
	BEGIN
		SET @reValue=-1000000064 --需要删除的文件间编号不能为空
		RETURN;
	END
	DELETE fileresources WHERE iID = @iID
END

SET @reValue = 1


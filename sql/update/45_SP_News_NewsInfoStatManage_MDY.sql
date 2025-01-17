set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



ALTER PROC [dbo].[SP_News_NewsInfoStatManage]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@cAction CHAR(2) = '01',
	@ids VARCHAR(1000) ='',
	@vcKey VARCHAR(30) = '',
	@vcKeValue CHAR(1) ='',
	@reValue INT OUTPUT
)
AS

IF(@vcAdminName IS NULL OR @vcAdminName ='')
BEGIN
	SET @reValue=-1000000012 --操作员为空，您是否尚未登陆？
	RETURN;
END

IF(@ids='')
BEGIN
	SET @reValue = -1000000051 --需要改变的文章不能为空
	RETURN
END

DECLARE @LOG NVARCHAR(200)
IF(@cAction='01')
BEGIN
	IF(@vcKeValue ='' OR @vcKeValue IS NULL OR (@vcKeValue <> 'N' AND @vcKeValue <> 'Y'))
	BEGIN
		SET @reValue = -1000000049 --需要修改的状态的值不能为空
		RETURN
	END
	
	DECLARE @SQL NVARCHAR(1000)
	IF(@vcKey ='' OR @vcKey IS NULL)
	BEGIN
		SET @reValue = -1000000048 --需要修改的状态名不能为空
		RETURN
	END
	ELSE IF(@vcKey = 'Checked')
	BEGIN
		IF(CHARINDEX(',',@ids)>0)
		BEGIN
			SET @SQL = 'UPDATE T_News_NewsInfo SET cChecked = '''+@vcKeValue+''''+
			+' WHERE iID IN ('+@ids+')'
			Execute Sp_Executesql @SQL
		END
		ELSE
		BEGIN
			UPDATE T_News_NewsInfo SET cChecked = @vcKeValue WHERE iID = @ids
		END
		SET @LOG = '更改资源['+@ids+']审核状态为['+@vcKeValue+']'
	END
	ELSE IF(@vcKey = 'Created')
	BEGIN
		IF(CHARINDEX(',',@ids)>0)
		BEGIN
			SET @SQL = 'UPDATE T_News_NewsInfo SET cCreated = '''+@vcKeValue+''''+
			+' WHERE iID IN ('+@ids+')'
			Execute Sp_Executesql @SQL
		END
		ELSE
		BEGIN
			UPDATE T_News_NewsInfo SET cCreated = @vcKeValue WHERE iID = @ids
		END
		SET @LOG = '更改资源['+@ids+']生成状态为['+@vcKeValue+']'
	END
	ELSE IF(@vcKey = 'Del')
	BEGIN
		IF(CHARINDEX(',',@ids)>0)
		BEGIN
			SET @SQL = 'UPDATE T_News_NewsInfo SET cDel = '''+@vcKeValue+''''+
			+' WHERE iID IN ('+@ids+')'
			Execute Sp_Executesql @SQL
		END
		ELSE
		BEGIN
			UPDATE T_News_NewsInfo SET cDel = @vcKeValue WHERE iID = @ids
		END
		IF(@vcKeValue='Y')
		BEGIN
			IF(CHARINDEX(',',@ids)>0)
			BEGIN
				SET @SQL = 'UPDATE T_News_NewsInfo SET cCreated = ''N'''+
				+' WHERE iID IN ('+@ids+')'
				Execute Sp_Executesql @SQL
			END
			ELSE
			BEGIN
				UPDATE T_News_NewsInfo SET cCreated = 'N' WHERE iID = @ids
			END
		END
		
		SET @LOG = '更改资源['+@ids+']存在状态为['+@vcKeValue+']'
	END
	ELSE
	BEGIN
		SET @reValue = -1000000050 --并无该状态
		RETURN
	END
END

IF(@cAction='02')
BEGIN
	SET @SQL = 'DELETE T_News_NewsInfo WHERE iId in (' + @ids+')'
	Execute Sp_Executesql @SQL

	SET @LOG = '彻底删除资源['+@ids+']'
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




set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go








ALTER PROC [dbo].[SP_Manage_AddAdmin]
(
	@vcAdminName varchar(50),
	@vcNickname varchar(50),
	@vcPassWord varchar(32),
	@iRole int,
	@clock CHAR(1),
	@vcPopedom VARCHAR(1000),
	@vcClassPopedom VARCHAR(255),
	@aAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@action CHAR(2) = '01', 
	@reValue int output
)
AS

EXEC SP_Manage_CheckAdminPower
	@vcAdminName =@vcAdminName,
	@vcIp =@vcIp,
	@reValue = @reValue OUTPUT

IF(@reValue<0)
BEGIN
	RETURN;
END

DECLARE @log VARCHAR(1000)
IF(@action='01')
BEGIN
	DECLARE @t_vcAdminName varchar(50)
	SELECT @t_vcAdminName = vcAdminName FROM admin (NOLOCK) WHERE vcAdminName = @vcAdminName
	IF(@t_vcAdminName<>'' AND @t_vcAdminName IS NOT NULL)
	BEGIN
		SET @reValue = -1000000005 --管理员帐号已经存在
		RETURN;
	END
END

SET XACT_ABORT ON
BEGIN TRY
BEGIN TRAN
	IF(@action='01')
	BEGIN
		SET @log = '添加管理员[' + @vcAdminName + ']'
		INSERT INTO admin
		(vcAdminName,vcNickName,vcPassWord,iRole,clock,vcPopedom,vcClassPopedom)
		VALUES(@vcAdminName,@vcNickname,@vcPassWord,@iRole,@clock,@vcPopedom,@vcClassPopedom)
	END
	
	IF(@action='02')
	BEGIN
		SET @log = '修改管理员[' + @vcAdminName + ']'
		
		IF(@vcPassWord<>'' AND @vcPassWord IS NOT NULL)
		BEGIN
			UPDATE admin SET vcNickName=@vcNickName,vcPassWord=@vcPassWord,iRole=@iRole,
			clock=@clock,vcPopedom=@vcPopedom,vcClassPopedom=@vcClassPopedom
			WHERE vcAdminName=@vcAdminName
		END
		ELSE
		BEGIN
			UPDATE admin SET vcNickName=@vcNickName,iRole=@iRole,
			clock=@clock,vcPopedom=@vcPopedom,vcClassPopedom=@vcClassPopedom
			WHERE vcAdminName=@vcAdminName
		END
	END
COMMIT
END TRY

BEGIN CATCH  
	ROLLBACK     
	SET @reValue = -1000000006		--数据库出错
	RETURN;
END CATCH
SET XACT_ABORT OFF 

EXEC SP_Manage_OnlineMdy
	@vcAdminName = @aAdminName,
	@vcIp = @vcip,
	@vcActive = @log,
	@reValue = @reValue

IF(@reValue<0)
BEGIN
	RETURN;
END

SET @reValue = 1






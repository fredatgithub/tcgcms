set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




ALTER PROC [dbo].[SP_Manage_OnlineMdy]
(
	@vcAdminName VARCHAR(50),
	@vcIp VARCHAR(15),
	@vcActive NVARCHAR(255),
	@reValue INT OUTPUT
)
AS

EXEC Sp_Manage_AddAdminLog
	@vcAdminName = @vcAdminName,
	@vcActive = @vcActive,
	@vcIp = @vcIp,
	@reValue=@reValue OUTPUT

IF(@reValue<0)
BEGIN
	EXEC Sp_Manage_OnlineKickTimeOutAdmin
	RETURN;
END

DECLARE @n_count INT
SET @n_count = 0

SELECT @n_count = COUNT(1) FROM AdminOnline (NOLOCK) WHERE vcAdminName = @vcAdminName

IF(@n_count=0)
BEGIN
	UPDATE admin SET cIsOnline = 'Y',vcLastLoginIp=@vcIp WHERE vcAdminName=@vcAdminName
	INSERT INTO AdminOnline (vcAdminName,vcIp,dActiveTime,vcActive)
	VALUES(@vcAdminName,@vcIp,GETDATE(),@vcActive)
END

IF(@n_count=1)
BEGIN
	UPDATE AdminOnline SET dActiveTime = GETDATE(),vcActive = @vcActive
	WHERE vcAdminName = @vcAdminName
END

IF(@n_count>1)
BEGIN
	DELETE AdminOnline WHERE vcAdminName = @vcAdminName
	INSERT INTO AdminOnline (vcAdminName,vcIp,dActiveTime,vcActive)
	VALUES(@vcAdminName,@vcIp,GETDATE(),@vcActive)
END


EXEC Sp_Manage_OnlineKickTimeOutAdmin

SET @reValue = 1





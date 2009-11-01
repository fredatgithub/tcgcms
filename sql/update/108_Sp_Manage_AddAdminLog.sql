set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROC [dbo].[Sp_Manage_AddAdminLog]
(
	@vcAdminName VARCHAR(50),
	@vcActive NVARCHAR(255),
	@vcIp VARCHAR(15),
	@reValue INT OUTPUT
)--WITH ENCRYPTION 
AS


IF(@vcAdminName IS NULL OR @vcAdminName ='')
BEGIN
	SET @reValue=-1000000012 --操作员为空，您是否尚未登陆？
	RETURN;
END

INSERT INTO AdminLog (vcAdminName,vcActive,vcIp)
VALUES(@vcAdminName,@vcActive,@vcIp)

SET @reValue = 1




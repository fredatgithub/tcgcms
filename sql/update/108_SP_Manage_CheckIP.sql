set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROC [dbo].[SP_Manage_CheckIP]
(
	@vcIP VARCHAR(15),
	@reValue INT OUTPUT
)

/*

DECLARE @reValue INT
EXEC SP_Manage_CheckIP
	@vcIP = '127.0.0.1',
	@reValue = @reValue OUTPUT

SELECT @reValue
*/
AS

DECLARE @IP_Count int
DECLARE @IP_NUM BIGINT
SET @IP_Count = 0

EXEC Sp_Manage_IpToNum
	@ip = @vcIP,   
	@ip_value = @IP_NUM OUT,  
	@retval = @reValue OUT 

SELECT @IP_Count = count(*) FROM AdminRefuseIp (NOLOCK) WHERE 
vcStartIp<=@IP_NUM and vcEndtIp>=@IP_NUM and cValid = 'Y'

IF(@IP_Count>0)
BEGIN
	SET @reValue = -1000000001 --用户IP被锁定
	RETURN
END
ELSE
BEGIN
	SET @reValue = 1
	RETURN;
END


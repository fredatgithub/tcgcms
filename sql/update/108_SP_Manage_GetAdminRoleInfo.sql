set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



ALTER PROC [dbo].[SP_Manage_GetAdminRoleInfo]
(
	@admincount INT OUTPUT,
	@deladmincount INT OUTPUT,
	@reValue INT OUTPUT
)
/*
DECLARE @admincount INT
DECLARE @reValue INT 
EXEC SP_Manage_GetAdminRoleInfo
	@admincount = @admincount OUTPUT,
	@reValue = @reValue OUTPUT

SELECT @admincount,@reValue
*/
AS

SELECT  @admincount = COUNT(1) FROM  admin (NOLOCK) WHERE cIsDel <> 'Y'

SELECT  @deladmincount = COUNT(1) FROM  admin (NOLOCK) WHERE cIsDel = 'Y'

SELECT iID,vcRoleName,(SELECT COUNT(1) FROM admin WHERE iRole = A.iID AND cIsDel <> 'Y') AS num 
FROM dbo.AdminRole A (NOLOCK) ORDER BY num DESC

SET @reValue = 1




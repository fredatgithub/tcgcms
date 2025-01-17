set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROC [dbo].[Sp_Manage_OnlineKickTimeOutAdmin]

AS
DECLARE @TimeOut int
SET @TimeOut = 60*30 --秒

update admin SET cIsOnline='N' 
WHERE  vcAdminName in (SELECT DISTINCT vcadminname FROM AdminOnline (NOLOCK) 
WHERE DATEDIFF(s, dActiveTime, GETDATE())> @TimeOut)

DELETE FROM AdminOnline 
WHERE DATEDIFF(s, dActiveTime, GETDATE())> @TimeOut


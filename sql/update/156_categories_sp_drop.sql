/****** 对象:  StoredProcedure [dbo].[SP_categories_Manage]    脚本日期: 03/07/2010 14:52:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_categories_Manage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_categories_Manage]
USE [TCG_DB]
GO
/****** 对象:  StoredProcedure [dbo].[SP_TCG_GetPage]    脚本日期: 09/07/2010 20:57:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_TCG_GetPage]
(
    @tblName	nvarchar(50),				----要显示的表或多个表的连接
	@fldName	nvarchar(500),				----要显示的字段列表
	@fldSort	nvarchar(200),				----排序字段列表或条件,必须输入
	@strCondition	nvarchar(4000),			----查询条件,不需where,必须输入
	@pageSize	int = 20,					----每页显示的记录个数
	@page		int = 1 ,					----要显示那一页的记录
	@curpage	int = 1 OUTPUT,				----返回显示那一页的记录
	@pageCount	int = 1 OUTPUT,				----查询结果分页后的总页数
	@counts		int = 1 OUTPUT,				----查询到的记录数
	@retval		int = 1 OUTPUT				----返回状态
)
AS
	DECLARE @sql nvarchar(4000)
	DECLARE @count int    

	--取得总记录数
	SET @sql = 'SELECT @cnt=COUNT(1) FROM '
				+ @tblName
				+ ' WITH (NOLOCK)'
				+ ' WHERE ' 
				+ @strCondition
	
	--print @sql
	EXEC sp_executesql @sql,N'@cnt int OUTPUT',@cnt=@counts OUTPUT
	
	IF @counts = 0
	BEGIN
		--如果总页数为0
		SET @pageCount = 0
		SET @curpage = 0
		SET @retval = 1
		RETURN
	END
	ELSE
		SET @count = @counts

    --取得分页总数
    SET @pageCount=(@count+@pageSize-1)/@pageSize

    /**//**当前页大于总页数 取最后一页**/
	SET @curpage = @page
    IF @page>@pageCount
        SET @curpage=@pageCount
	IF @page = 0
		SET @curpage=1

	--取得分页记录结果
	SET @sql = ' SELECT '
				+ @fldName 
				+ ' FROM ( SELECT '
				+ @fldName
				+ ', ROW_NUMBER() OVER(ORDER BY '
				+ @fldSort
				+ ') AS ROW FROM '
				+ @tblName
				+ ' WITH (NOLOCK)'
				+ ' WHERE '
				+ @strCondition
				+ ') tempDB WHERE  ROW BETWEEN '
				+ CAST(@pageSize*(@curpage-1) + 1 as varchar(12))
				+ ' AND '
				+ CAST(@curpage*@pageSize as varchar(12))

	print @sql
	EXEC (@sql)

	SET @retval = 1


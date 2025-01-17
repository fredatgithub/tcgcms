set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





ALTER PROC [dbo].[SP_News_GetNewsInfoById]
(
	@iID VARCHAR(36)
)
/*
EXEC SP_News_GetNewsInfoById
	@iID='8f2fe764-2e41-4a0b-96eb-73b27aaed4b2'
*/
AS

	SELECT iClassID,vcTitle,vcUrl,vcContent,vcAuthor,iFrom,iCount,vcKeyWord,
	vcEditor,cCreated,vcSmallImg,vcBigImg,vcShortContent,vcSpeciality,cChecked,
	cDel,cPostByUser,vcFilePath,dAddDate,dUpDateDate,vcTitleColor,cStrong
	FROM resources (NOLOCK)
	WHERE iId = @iID 

	SELECT B.vcClassName,B.vcName,B.Parent,B.iTemplate,B.iListTemplate,B.vcDirectory,B.vcUrl,B.iOrder
	FROM resources A (NOLOCK),Categories B (NOLOCK) 
	WHERE A.iId = @iID AND A.iClassID = B.Id








IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetImportStatus]') AND type = N'FN') BEGIN
	DROP FUNCTION dbo.sfGetImportStatus
END
GO

CREATE FUNCTION dbo.sfGetImportStatus(
	@asOfDate as smalldatetime
)
RETURNS varchar(10)
AS
BEGIN

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	DECLARE @status varchar(10) = ''

	SELECT @status += CASE WHEN ItemType IS NULL THEN '0' ELSE '1' END
	FROM Serial S
		LEFT JOIN (SELECT DISTINCT ItemType FROM ImportItem WHERE ImportId = @importId) I ON S.Id = I.ItemType
	WHERE S.Id <= 10
	ORDER BY S.Id

	RETURN @status
END

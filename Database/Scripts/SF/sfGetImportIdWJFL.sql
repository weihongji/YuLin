IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetImportIdWJFL]') AND type = N'FN') BEGIN
	DROP FUNCTION dbo.sfGetImportIdWJFL
END
GO

CREATE FUNCTION dbo.sfGetImportIdWJFL(
	@asOfDate as smalldatetime
)
RETURNS int
AS
BEGIN
	DECLARE @importId int
	SELECT TOP 1 @importId = Id FROM Import WHERE ImportDate <= @asOfDate AND WJFLDate IS NOT NULL ORDER BY ImportDate DESC

	RETURN @importId
END

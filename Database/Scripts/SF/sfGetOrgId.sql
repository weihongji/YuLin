IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetOrgId]') AND type = N'FN') BEGIN
	DROP FUNCTION dbo.sfGetOrgId
END
GO

CREATE FUNCTION dbo.sfGetOrgId(
	@name as nvarchar(200)
)
RETURNS int
AS
BEGIN
	DECLARE @orgId int

	SELECT TOP 1 @orgId = Id FROM Org WHERE @name IN (Name, Alias1, Alias2)
	IF @orgId IS NULL BEGIN
		SET @name = REPLACE(@name, '榆林分行', '')
		SELECT TOP 1 @orgId = Id FROM Org WHERE @name IN (Name, Alias1, Alias2)
	END
	IF @orgId IS NULL BEGIN
		SELECT TOP 1 @orgId = Id FROM Org WHERE Name LIKE '%' + @name + '%' OR Alias1 LIKE '%' + @name + '%' OR Alias2 LIKE '%' + @name + '%'
	END

	RETURN @orgId
END

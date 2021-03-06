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
	SET @name = LTRIM(RTRIM(@name))

	IF LEN(@name) = 0 OR @name IS NULL BEGIN
		RETURN NULL
	END

	IF SUBSTRING(@name, 1, 3) = '806' BEGIN
		SELECT TOP 1 @orgId = Id FROM Org WHERE OrgNo = @name
		RETURN @orgId
	END

	SELECT TOP 1 @orgId = Id FROM Org WHERE @name IN (Name, Alias1, Alias2)
	IF @orgId IS NULL BEGIN
		SET @name = REPLACE(@name, '榆林分行', '')
		SET @name = REPLACE(@name, '长安银行', '')
		SELECT TOP 1 @orgId = Id FROM Org WHERE @name IN (Name, Alias1, Alias2)
	END
	IF @orgId IS NULL BEGIN
		SELECT TOP 1 @orgId = Id FROM Org WHERE Name LIKE '%' + @name + '%' OR Alias1 LIKE '%' + @name + '%' OR Alias2 LIKE '%' + @name + '%'
	END
	IF @orgId IS NULL BEGIN
		DECLARE @core nvarchar(2) = SUBSTRING(@name, 1, 2)
		SELECT TOP 1 @orgId = Id FROM Org WHERE Name LIKE '%' + @core + '%' OR Alias1 LIKE '%' + @core + '%' OR Alias2 LIKE '%' + @core + '%'
	END

	RETURN @orgId
END

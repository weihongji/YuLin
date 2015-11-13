IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetOrgNo]') AND type = N'FN') BEGIN
	DROP FUNCTION dbo.sfGetOrgNo
END
GO

CREATE FUNCTION dbo.sfGetOrgNo(
	@name as nvarchar(200)
)
RETURNS varchar(50)
AS
BEGIN
	DECLARE @orgNo varchar(50)

	SELECT TOP 1 @orgNo = Number FROM Org WHERE @name IN (Name, Alias1, Alias2)
	IF @orgNo IS NULL BEGIN
		SET @name = REPLACE(@name, 'ÓÜÁÖ·ÖÐÐ', '')
		SELECT TOP 1 @orgNo = Number FROM Org WHERE @name IN (Name, Alias1, Alias2)
	END
	IF @orgNo IS NULL BEGIN
		SELECT TOP 1 @orgNo = Number FROM Org WHERE Name LIKE '%' + @name + '%' OR Alias1 LIKE '%' + @name + '%' OR Alias2 LIKE '%' + @name + '%'
	END

	RETURN @orgNo
END

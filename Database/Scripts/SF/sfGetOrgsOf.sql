IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetOrgsOf]')) BEGIN
	DROP FUNCTION dbo.sfGetOrgsOf
END
GO

CREATE FUNCTION dbo.sfGetOrgsOf(
	@area as varchar(5) /* All, YL, SF */
)
RETURNS @result TABLE (
		Id int NOT NULL,
		OrgNo varchar(50) NOT NULL,
		Name nvarchar(100) NOT NULL
)
AS
BEGIN
	IF @area IS NULL OR LEN(@area) = 0 BEGIN
		SET @area = 'All'
	END
	
	IF @area = 'YL' BEGIN
		INSERT INTO @result(Id, OrgNo, Name) SELECT Id, OrgNo, Name FROM Org WHERE NOT (Name LIKE '%神木%' OR Name LIKE '%府谷%' OR Name LIKE '%神府%')
	END
	ELSE IF @area = 'SF' BEGIN
		INSERT INTO @result(Id, OrgNo, Name) SELECT Id, OrgNo, Name FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%' OR Name LIKE '%神府%'
	END
	ELSE IF @area = 'All' BEGIN
		INSERT INTO @result(Id, OrgNo, Name) SELECT Id, OrgNo, Name FROM Org
	END
	ELSE BEGIN
		INSERT INTO @result(Id, OrgNo, Name) SELECT Id, OrgNo, Name FROM Org WHERE Name LIKE '%' + @area + '%'
	END

	RETURN
END

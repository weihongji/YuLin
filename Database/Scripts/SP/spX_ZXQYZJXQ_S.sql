IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_ZXQYZJXQ_S') BEGIN
	DROP PROCEDURE spX_ZXQYZJXQ_S
END
GO

CREATE PROCEDURE spX_ZXQYZJXQ_S
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate smalldatetime = '20150930'

	DECLARE @lastYear as int = YEAR(@asOfDate) - 1
	DECLARE @lastSeason as int = MONTH(@asOfDate) / 3

	IF @lastSeason = 0 BEGIN
		SET @lastYear = @lastYear - 1
		SET @lastSeason = 4
	END

	DECLARE @importId int
	DECLARE @importIdLastYear int
	DECLARE @importIdLastSeason int

	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate
	SELECT @importIdLastYear = Id FROM Import WHERE ImportDate = @lastYear
	SELECT @importIdLastSeason = Id FROM Import WHERE ImportDate = @lastSeason

	SELECT ROW_NUMBER() OVER(ORDER BY CustomerName) AS [Index]
		, CustomerName
		, RegistrationIn = '2008'
		, OrgType = MAX(OrgType)
		, IndustryType1 = MAX(IndustryType1)
		, AppliedAmount = SUM(Balance1)
		, Direction = MAX(Direction4)
		, LastYearAmount = SUM(Balance1)
		, LastSeasonAmount = SUM(Balance1)
	FROM ImportPublic
	WHERE ImportId = @importId
		AND OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
		AND MyBankIndTypeName IN ('中型企业', '小型企业')
	GROUP BY CustomerName
END

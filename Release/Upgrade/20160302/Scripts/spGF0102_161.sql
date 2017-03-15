IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF0102_161') BEGIN
	DROP PROCEDURE spGF0102_161
END
GO

CREATE PROCEDURE spGF0102_161
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	DECLARE @total as money
	DECLARE @overdue90 as money

	SELECT @total = CAST(ROUND(SUM(CurrentDebitBalance)/10000, 2) AS money) FROM ImportYWNei
	WHERE ImportId = @importId
		AND SubjectCode BETWEEN '1301' AND '1382'
		AND OrgId = 1001

	SELECT @overdue90 = SUM(Balance) FROM (
		SELECT OverdueDays = CASE WHEN P.LoanEndDate < @asOfDate AND P.Balance1 > 0 THEN DATEDIFF(day, P.LoanEndDate, @asOfDate) ELSE 0 END
			, OweInterestDays = P.OweInterestDays
			, Balance = P.Balance1
		FROM ImportPublic P
		WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND P.PublicType = 1
		UNION ALL
		SELECT OverdueDays = CASE WHEN P.ContractStartDate < @asOfDate AND P.LoanBalance > 0 THEN DATEDIFF(day, P.ContractEndDate, @asOfDate) ELSE 0 END
			, OweInterestDays = P.InterestOverdueDays
			, Balance = P.LoanBalance
		FROM ImportPrivate P
		WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
	) AS X
	WHERE OverdueDays > 90 OR OweInterestDays > 90
		
	SELECT DangerLevel, CAST(ROUND(SUM(CapitalAmount)/10000, 2) AS money) as Amount INTO #Result FROM ImportLoan
	WHERE ImportId = @importId
		AND OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
	GROUP BY DangerLevel

	SELECT Total = ISNULL(@total, 0)
		, GuanZhu = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel LIKE '关%')
		, CiJi    = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '次级')
		, KeYi    = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '可疑')
		, SunShi  = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '损失')
		, Over90  = ISNULL(@overdue90, 0)

	DROP TABLE #Result
END

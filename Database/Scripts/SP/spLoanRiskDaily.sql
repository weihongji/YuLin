IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spLoanRiskDaily') BEGIN
	DROP PROCEDURE spLoanRiskDaily
END
GO

CREATE PROCEDURE spLoanRiskDaily
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate smalldatetime = '20151031'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate
	DECLARE @importIdWJFL int = dbo.sfGetImportIdWJFL(@asOfDate)

	SELECT OrgId, SUM(CapitalAmount) AS Amount, SUM(OweYingShouInterest) + SUM(OweCuiShouInterest) AS OweInterest INTO #Total FROM ImportLoan
	WHERE ImportId = @importId
	GROUP BY OrgId

	SELECT OrgId, SUM(CapitalAmount) AS Amount, COUNT(*) AS Number INTO #YB FROM ImportLoan
	WHERE ImportId = @importId
		AND LoanState IN ('逾期', '部分逾期', '非应计') AND LoanTypeName != '委托贷款'
	GROUP BY OrgId

	SELECT OrgId, SUM(CapitalAmount) AS Amount, COUNT(*) AS Number INTO #BL FROM ImportLoan
	WHERE ImportId = @importId
		AND LoanState IN ('逾期', '部分逾期', '非应计') AND LoanTypeName != '委托贷款'
		AND DangerLevel IN ('次级', '可疑', '损失')
	GROUP BY OrgId

	SELECT OrgId, SUM(CapitalAmount) AS Amount, COUNT(*) AS Number INTO #ZQX FROM ImportLoan
	WHERE ImportId = @importId
			AND LoanState = '正常'
			AND OweYingShouInterest + OweCuiShouInterest != 0
	GROUP BY OrgId

	SELECT O.Id AS OrgId, O.Alias1 AS OrgName, CAST(ROUND(ISNULL(T.Amount, 0)/10000, 2) AS money) AS Total_Amount, CAST(ROUND(ISNULL(T.OweInterest, 0)/10000, 2) AS money) AS Total_Interest
		, ISNULL(Y.Number, 0) - ISNULL(B.Number, 0) AS YQ_Count, CAST(ROUND((ISNULL(Y.Amount, 0)-ISNULL(B.Amount, 0))/10000, 2) AS money) AS YQ_Amount
		, ISNULL(B.Number, 0) AS BL_Count, CAST(ROUND(ISNULL(B.Amount, 0)/10000, 2) AS money) AS BL_Amount
		, ISNULL(Z.Number, 0) AS ZQX_Count, CAST(ROUND(ISNULL(Z.Amount, 0)/10000, 2) AS money) AS ZQX_Amount
		, ISNULL(Y.Number, 0) AS YBTotal_Count, CAST(ROUND(ISNULL(Y.Amount, 0)/10000, 2) AS money) AS YBTotal_Amount
	INTO #Result
	FROM Org O
		LEFT JOIN #Total T ON O.Id = T.OrgId
		LEFT JOIN #YB    Y ON O.Id = Y.OrgId
		LEFT JOIN #BL    B ON O.Id = B.OrgId
		LEFT JOIN #ZQX   Z ON O.Id = Z.OrgId
	WHERE T.Amount > 0
		AND NOT(O.Name LIKE '%神木%' OR O.Name LIKE '%府谷%')
		AND O.OrgNo != '806057777'

	-- Offset
	UPDATE R SET R.Total_Amount += F.Offset
	FROM #Result R INNER JOIN OrgOffset F ON R.OrgId = F.OrgId
	WHERE @asOfDate BETWEEN F.StartDate AND F.EndDate

	IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'Shell_LoanRisk') BEGIN
		SELECT * INTO Shell_LoanRisk FROM #Result WHERE 1 = 2
	END

	IF @asOfDate > '2001-01-01' BEGIN
		SELECT R.* FROM #Result R INNER JOIN Org O ON R.OrgId = O.Id ORDER BY O.OrgNo, O.Id
	END

	DROP TABLE #Total
	DROP TABLE #YB
	DROP TABLE #BL
	DROP TABLE #ZQX
	DROP TABLE #Result
END

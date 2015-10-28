IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_WJFL_M_vs') BEGIN
	DROP PROCEDURE spX_WJFL_M_vs
END
GO

CREATE PROCEDURE spX_WJFL_M_vs
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate smalldatetime = '20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	DECLARE @importIdLastMonth int
	SELECT @importIdLastMonth = MAX(Id) FROM Import WHERE ImportDate <= DATEADD(DAY, -1, CONVERT(varchar(6), @asOfDate, 112) + '01')

	IF OBJECT_ID('tempdb..#Result') IS NOT NULL BEGIN
		DROP TABLE #Result
	END

	CREATE TABLE #Result(
		Sorting int,
		CustomerScale nvarchar(20),
		BL_Increase_Count int,
		BL_Increase_Amount decimal(15, 2),
		BL_Decrease_Count int,
		BL_Decrease_Amount decimal(15, 2),
		YQ_Increase_Count int,
		YQ_Increase_Amount decimal(15, 2),
		YQ_Decrease_Count int,
		YQ_Decrease_Amount decimal(15, 2),
		FY_Increase_Count int,
		FY_Increase_Amount decimal(15, 2),
		FY_Decrease_Count int,
		FY_Decrease_Amount decimal(15, 2),
	)

	INSERT INTO #Result (Sorting, CustomerScale
		, BL_Increase_Count, BL_Increase_Amount, BL_Decrease_Count, BL_Decrease_Amount
		, YQ_Increase_Count, YQ_Increase_Amount, YQ_Decrease_Count, YQ_Decrease_Amount
		, FY_Increase_Count, FY_Increase_Amount, FY_Decrease_Count, FY_Decrease_Amount
	)
	SELECT 1, '大中客户', 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00
	UNION
	SELECT 2, '小微客户', 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00
	UNION
	SELECT 3, '个人客户', 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00

	IF OBJECT_ID('tempdb..#ResultCurrentMonth') IS NOT NULL BEGIN
		DROP TABLE #ResultCurrentMonth
	END
	IF OBJECT_ID('tempdb..#ResultPreviousMonth') IS NOT NULL BEGIN
		DROP TABLE #ResultPreviousMonth
	END

	CREATE TABLE #ResultCurrentMonth(
		CustomerScale nvarchar(20),
		CustomerName nvarchar(100),
		Amount decimal(15, 2)
	)
	CREATE TABLE #ResultPreviousMonth(
		CustomerScale nvarchar(20),
		CustomerName nvarchar(100),
		Amount decimal(15, 2)
	)

	/* 不良贷款 */
	INSERT INTO #ResultCurrentMonth(CustomerScale, CustomerName, Amount)
	SELECT CustomerScale = '大中客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importId AND L.DangerLevel IN ('次级', '可疑', '损失')
		AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '小微客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = 1 AND L.DangerLevel IN ('次级', '可疑', '损失')
		AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '个人客户', L.LoanAccount AS CustomerName, L.CapitalAmount AS Amount FROM ImportLoan L INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importId AND L.DangerLevel IN ('次级', '可疑', '损失')
	-- Previous Month
	INSERT INTO #ResultPreviousMonth(CustomerScale, CustomerName, Amount)
	SELECT CustomerScale = '大中客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('次级', '可疑', '损失')
		AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '小微客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = 2 AND L.DangerLevel IN ('次级', '可疑', '损失')
		AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '个人客户', L.LoanAccount AS CustomerName, L.CapitalAmount AS Amount FROM ImportLoan L INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('次级', '可疑', '损失')

	UPDATE R SET BL_Increase_Count = M.[Count], BL_Increase_Amount = M.Amount
	FROM #Result R INNER JOIN (
		SELECT A.CustomerScale, COUNT(*) AS [Count], SUM(A.Amount) AS Amount FROM #ResultCurrentMonth A WHERE NOT EXISTS(SELECT * FROM #ResultPreviousMonth B WHERE B.CustomerName = A.CustomerName)
		GROUP BY A.CustomerScale
	) AS M ON R.CustomerScale = M.CustomerScale

	UPDATE R SET BL_Decrease_Count = M.[Count], BL_Decrease_Amount = M.Amount
	FROM #Result R INNER JOIN (
		SELECT A.CustomerScale, COUNT(*) AS [Count], SUM(A.Amount) AS Amount FROM #ResultPreviousMonth A WHERE NOT EXISTS(SELECT * FROM #ResultCurrentMonth B WHERE B.CustomerName = A.CustomerName)
		GROUP BY A.CustomerScale
	) AS M ON R.CustomerScale = M.CustomerScale

	DELETE FROM #ResultCurrentMonth
	DELETE FROM #ResultPreviousMonth

	/* 逾期 */
	INSERT INTO #ResultCurrentMonth(CustomerScale, CustomerName, Amount)
	SELECT CustomerScale = '大中客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importId AND L.LoanState IN ('逾期', '部分逾期')
		AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '小微客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importId AND L.LoanState IN ('逾期', '部分逾期')
		AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '个人客户', L.LoanAccount AS CustomerName, L.CapitalAmount AS Amount FROM ImportLoan L INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importId AND L.LoanState IN ('逾期', '部分逾期')
	-- Previous Month
	INSERT INTO #ResultPreviousMonth(CustomerScale, CustomerName, Amount)
	SELECT CustomerScale = '大中客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importIdLastMonth AND L.LoanState IN ('逾期', '部分逾期')
		AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '小微客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importIdLastMonth AND L.LoanState IN ('逾期', '部分逾期')
		AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '个人客户', L.LoanAccount AS CustomerName, L.CapitalAmount AS Amount FROM ImportLoan L INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importIdLastMonth AND L.LoanState IN ('逾期', '部分逾期')

	UPDATE R SET YQ_Increase_Count = M.[Count], YQ_Increase_Amount = M.Amount
	FROM #Result R INNER JOIN (
		SELECT A.CustomerScale, COUNT(*) AS [Count], SUM(A.Amount) AS Amount FROM #ResultCurrentMonth A WHERE NOT EXISTS(SELECT * FROM #ResultPreviousMonth B WHERE B.CustomerName = A.CustomerName)
		GROUP BY A.CustomerScale
	) AS M ON R.CustomerScale = M.CustomerScale

	UPDATE R SET YQ_Decrease_Count = M.[Count], YQ_Decrease_Amount = M.Amount
	FROM #Result R INNER JOIN (
		SELECT A.CustomerScale, COUNT(*) AS [Count], SUM(A.Amount) AS Amount FROM #ResultPreviousMonth A WHERE NOT EXISTS(SELECT * FROM #ResultCurrentMonth B WHERE B.CustomerName = A.CustomerName)
		GROUP BY A.CustomerScale
	) AS M ON R.CustomerScale = M.CustomerScale

	DELETE FROM #ResultCurrentMonth
	DELETE FROM #ResultPreviousMonth

	/* 非应计 */
	INSERT INTO #ResultCurrentMonth(CustomerScale, CustomerName, Amount)
	SELECT CustomerScale = '大中客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importId AND L.LoanState = '非应计'
		AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '小微客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importId AND L.LoanState = '非应计'
		AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '个人客户', L.LoanAccount AS CustomerName, L.CapitalAmount AS Amount FROM ImportLoan L INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importId AND L.LoanState = '非应计'
	-- Previous Month
	INSERT INTO #ResultPreviousMonth(CustomerScale, CustomerName, Amount)
	SELECT CustomerScale = '大中客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importIdLastMonth AND L.LoanState = '非应计'
		AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '小微客户', L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importIdLastMonth AND L.LoanState = '非应计'
		AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
	GROUP BY L.CustomerName
	UNION ALL
	SELECT CustomerScale = '个人客户', L.LoanAccount AS CustomerName, L.CapitalAmount AS Amount FROM ImportLoan L INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount
	WHERE L.ImportId = @importIdLastMonth AND L.LoanState = '非应计'

	UPDATE R SET FY_Increase_Count = M.[Count], FY_Increase_Amount = M.Amount
	FROM #Result R INNER JOIN (
		SELECT A.CustomerScale, COUNT(*) AS [Count], SUM(A.Amount) AS Amount FROM #ResultCurrentMonth A WHERE NOT EXISTS(SELECT * FROM #ResultPreviousMonth B WHERE B.CustomerName = A.CustomerName)
		GROUP BY A.CustomerScale
	) AS M ON R.CustomerScale = M.CustomerScale

	UPDATE R SET FY_Decrease_Count = M.[Count], FY_Decrease_Amount = M.Amount
	FROM #Result R INNER JOIN (
		SELECT A.CustomerScale, COUNT(*) AS [Count], SUM(A.Amount) AS Amount FROM #ResultPreviousMonth A WHERE NOT EXISTS(SELECT * FROM #ResultCurrentMonth B WHERE B.CustomerName = A.CustomerName)
		GROUP BY A.CustomerScale
	) AS M ON R.CustomerScale = M.CustomerScale

	SELECT
		CAST(ROUND(BL_Increase_Count, 2) AS decimal(10, 2)) AS BL_Increase_Count,
		CAST(ROUND(BL_Increase_Amount, 2) AS decimal(10, 2)) AS BL_Increase_Amount,
		CAST(ROUND(BL_Decrease_Count, 2) AS decimal(10, 2)) AS BL_Decrease_Count,
		CAST(ROUND(BL_Decrease_Amount, 2) AS decimal(10, 2)) AS BL_Decrease_Amount,
		CAST(ROUND(YQ_Increase_Count, 2) AS decimal(10, 2)) AS YQ_Increase_Count,
		CAST(ROUND(YQ_Increase_Amount, 2) AS decimal(10, 2)) AS YQ_Increase_Amount,
		CAST(ROUND(YQ_Decrease_Count, 2) AS decimal(10, 2)) AS YQ_Decrease_Count,
		CAST(ROUND(YQ_Decrease_Amount, 2) AS decimal(10, 2)) AS YQ_Decrease_Amount,
		CAST(ROUND(FY_Increase_Count, 2) AS decimal(10, 2)) AS FY_Increase_Count,
		CAST(ROUND(FY_Increase_Amount, 2) AS decimal(10, 2)) AS FY_Increase_Amount,
		CAST(ROUND(FY_Decrease_Count, 2) AS decimal(10, 2)) AS FY_Decrease_Count,
		CAST(ROUND(FY_Decrease_Amount, 2) AS decimal(10, 2)) AS FY_Decrease_Amount
	FROM #Result ORDER BY Sorting

	DROP TABLE #Result
	DROP TABLE #ResultCurrentMonth
	DROP TABLE #ResultPreviousMonth
END

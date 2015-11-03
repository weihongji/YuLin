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

	/* 不良贷款 */
	-- 大中客户
	UPDATE R SET BL_Increase_Count = IC, BL_Increase_Amount = IA, BL_Decrease_Count = DC, BL_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('次级', '可疑', '损失')
								AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.DangerLevel IN ('次级', '可疑', '损失')
								AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '大中客户'

	-- 小微客户
	UPDATE R SET BL_Increase_Count = IC, BL_Increase_Amount = IA, BL_Decrease_Count = DC, BL_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('次级', '可疑', '损失')
								AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.DangerLevel IN ('次级', '可疑', '损失')
								AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '小微客户'

	-- 个人客户
	UPDATE R SET BL_Increase_Count = IC, BL_Increase_Amount = IA, BL_Decrease_Count = DC, BL_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importIdLastMonth AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND DangerLevel IN ('次级', '可疑', '损失')
							GROUP BY CustomerName, LoanAccount
						) AS O
						FULL OUTER JOIN (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importId AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND DangerLevel IN ('次级', '可疑', '损失')
							GROUP BY CustomerName, LoanAccount
						) AS N
						ON O.LoanAccount = N.LoanAccount
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '个人客户'

	/* 逾期 */
	-- 大中客户
	UPDATE R SET YQ_Increase_Count = IC, YQ_Increase_Amount = IA, YQ_Decrease_Count = DC, YQ_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importIdLastMonth AND L.LoanState IN ('逾期', '部分逾期')
								AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.LoanState IN ('逾期', '部分逾期')
								AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '大中客户'

	-- 小微客户
	UPDATE R SET YQ_Increase_Count = IC, YQ_Increase_Amount = IA, YQ_Decrease_Count = DC, YQ_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importIdLastMonth AND L.LoanState IN ('逾期', '部分逾期')
								AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.LoanState IN ('逾期', '部分逾期')
								AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '小微客户'

	-- 个人客户
	UPDATE R SET YQ_Increase_Count = IC, YQ_Increase_Amount = IA, YQ_Decrease_Count = DC, YQ_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importIdLastMonth AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND LoanState IN ('逾期', '部分逾期')
							GROUP BY CustomerName, LoanAccount
						) AS O
						FULL OUTER JOIN (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importId AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND LoanState IN ('逾期', '部分逾期')
							GROUP BY CustomerName, LoanAccount
						) AS N
						ON O.LoanAccount = N.LoanAccount
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '个人客户'

	/* 非应计 */
	-- 大中客户
	UPDATE R SET FY_Increase_Count = IC, FY_Increase_Amount = IA, FY_Decrease_Count = DC, FY_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importIdLastMonth AND L.LoanState = '非应计'
								AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.LoanState = '非应计'
								AND P.MyBankIndTypeName IN ('大型企业', '中型企业')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '大中客户'

	-- 小微客户
	UPDATE R SET FY_Increase_Count = IC, FY_Increase_Amount = IA, FY_Decrease_Count = DC, FY_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importIdLastMonth AND L.LoanState = '非应计'
								AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.LoanState = '非应计'
								AND P.MyBankIndTypeName IN ('小型企业', '微型企业')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '小微客户'

	-- 个人客户
	UPDATE R SET FY_Increase_Count = IC, FY_Increase_Amount = IA, FY_Decrease_Count = DC, FY_Decrease_Amount = DA
	FROM #Result R
		, (
			SELECT ISNULL(SUM(IC), 0) AS IC, ISNULL(SUM(DC), 0) AS DC, ISNULL(SUM(IA), 0) AS IA, ISNULL(SUM(DA), 0) AS DA
			FROM (
					SELECT CustomerName = ISNULL(O.CustomerName, N.CustomerName)
						, IC = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, DC = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN 1 ELSE 0 END
						, IA = CASE WHEN ISNULL(O.Amount, 0) < ISNULL(N.Amount, 0) THEN ISNULL(N.Amount, 0) - ISNULL(O.Amount, 0) ELSE 0 END
						, DA = CASE WHEN ISNULL(O.Amount, 0) > ISNULL(N.Amount, 0) THEN ISNULL(O.Amount, 0) - ISNULL(N.Amount, 0) ELSE 0 END
					FROM (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importIdLastMonth AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND LoanState = '非应计'
							GROUP BY CustomerName, LoanAccount
						) AS O
						FULL OUTER JOIN (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importId AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND LoanState = '非应计'
							GROUP BY CustomerName, LoanAccount
						) AS N
						ON O.LoanAccount = N.LoanAccount
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '个人客户'

	SELECT
		  BL_Increase_Count, BL_Increase_Amount, BL_Decrease_Count, BL_Decrease_Amount
		, YQ_Increase_Count, YQ_Increase_Amount, YQ_Decrease_Count, YQ_Decrease_Amount
		, FY_Increase_Count, FY_Increase_Amount, FY_Decrease_Count, FY_Decrease_Amount
	FROM #Result ORDER BY Sorting

	DROP TABLE #Result
END

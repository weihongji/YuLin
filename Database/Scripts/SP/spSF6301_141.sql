IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spSF6301_141') BEGIN
	DROP PROCEDURE spSF6301_141
END
GO

CREATE PROCEDURE spSF6301_141
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate smalldatetime = '20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	IF OBJECT_ID('tempdb..#Result') IS NOT NULL BEGIN
		DROP TABLE #Result
	END

	CREATE TABLE #Result(
		Sorting int,
		SubjectName nvarchar(50),
		Balance1 money,
		Balance2 money,
		Balance3 money,
		Balance4 money,
		Balance5 money,
		Balance6 money,
		Balance7 money,
		Balance8 money
	)

	INSERT INTO #Result (Sorting, Balance1, Balance2, Balance3, Balance4, Balance5, Balance6, Balance7, Balance8, SubjectName)
	SELECT 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.0.0境内贷款余额合计'
	UNION ALL
	SELECT 2, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.1.2关注类贷款'
	UNION ALL
	SELECT 3, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.1.3次级类贷款'
	UNION ALL
	SELECT 4, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.1.4可疑类贷款'
	UNION ALL
	SELECT 5, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.1.5损失类贷款'
	UNION ALL
	SELECT 6, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.2.1信用贷款'
	UNION ALL
	SELECT 7, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.2.2保证贷款'
	UNION ALL
	SELECT 8, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.2.3抵（质）押贷款'
	UNION ALL
	SELECT 9, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.2.4贴现及买断式转贴现'
	UNION ALL
	SELECT 10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.3.1逾期90天以内'
	UNION ALL
	SELECT 11, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.3.2逾期91天到360天'
	UNION ALL
	SELECT 12, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.3.3逾期361天以上'
	UNION ALL
	SELECT 13, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2.地方政府融资平台贷款余额'
	UNION ALL
	SELECT 14, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '4.表外授信余额'
	UNION ALL
	SELECT 15, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '4.1其中：票据承兑'

	IF OBJECT_ID('tempdb..#ResultSingle') IS NOT NULL BEGIN
		DROP TABLE #ResultSingle
	END
	CREATE TABLE #ResultSingle(
		Category nvarchar(50),
		A money,
		B money,
		C money,
		D money,
		E money,
		F money
	)

	INSERT INTO #ResultSingle
	SELECT DangerLevel, A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F)
	FROM (
		SELECT DangerLevel, A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F)
		FROM (
			SELECT DangerLevel = ISNULL(DangerLevel, 'NULL')
					, A = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
					, B = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
					, C = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
					, D = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
					, E = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
					, F = 0.00
			FROM ImportPublic P LEFT JOIN ImportLoanView L ON P.LoanAccount = L.LoanAccount AND L.ImportId = P.ImportId
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
		) AS X1
		GROUP BY DangerLevel
		UNION ALL
		SELECT DangerLevel = ISNULL(L.DangerLevel, 'NULL'), A = 0.00, B = 0.00, C = 0.00, D = 0.00, E = 0.00, F = SUM(P.LoanBalance)
		FROM ImportPrivate P LEFT JOIN ImportLoanView L ON P.LoanAccount = L.LoanAccount AND L.ImportId = P.ImportId
		WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
			AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
		GROUP BY L.DangerLevel
	) AS X2
	GROUP BY DangerLevel

	/* 合并各关注类金额 */
	UPDATE #ResultSingle SET Category = '关注0' WHERE Category = '关注'
	INSERT INTO #ResultSingle
	SELECT '关注', A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F) FROM #ResultSingle WHERE Category LIKE '关%'
	DELETE FROM #ResultSingle WHERE Category LIKE '关%' AND Category <> '关注'

	/* 1.境内贷款余额合计 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, (
			SELECT A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F)
			FROM #ResultSingle
		) AS X
	WHERE R.Sorting = 1

	/* 1.1.2关注类贷款 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 2 AND X.Category LIKE '关%'

	/* 1.1.3次级类贷款 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 3 AND X.Category = '次级'

	/* 1.1.4可疑类贷款 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 4 AND X.Category = '可疑'

	/* 1.1.5损失类贷款 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 5 AND X.Category = '损失'

	DELETE FROM #ResultSingle

	INSERT INTO #ResultSingle
	SELECT DBFS, A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F)
	FROM (
		SELECT DBFS, A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F)
		FROM (
			SELECT D.Category AS DBFS
					, A = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
					, B = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
					, C = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
					, D = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
					, E = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
					, F = 0.00
			FROM ImportPublic P INNER JOIN DanBaoFangShi D ON P.VouchTypeName = D.Name
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
		) AS X1
		GROUP BY DBFS
		UNION ALL
		SELECT D.Category AS DBFS, A = 0.00, B = 0.00, C = 0.00, D = 0.00, E = 0.00, F = SUM(P.LoanBalance)
		FROM ImportPrivate P INNER JOIN DanBaoFangShi D ON P.DanBaoFangShi = D.Name
		WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
			AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
		GROUP BY D.Category
	) AS X2
	GROUP BY DBFS

	/* 1.2.1信用贷款 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 6 AND X.Category = '信用'

	/* 1.2.2保证贷款 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 7 AND X.Category = '保证'

	/* 1.2.3抵（质）押贷款 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R,
		(SELECT A = SUM(A),  B = SUM(B),  C = SUM(C),  D = SUM(D),  E = SUM(E),  F = SUM(F) FROM #ResultSingle WHERE Category IN ('抵押', '质押')) X
	WHERE R.Sorting = 8

	/* 1.2.4贴现及买断式转贴现 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, (
		SELECT A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F)
		FROM (
				SELECT    A = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
						, B = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
						, C = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
						, D = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
						, E = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
						, F = 0.00
				FROM ImportPublic P
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
					AND BusinessType LIKE '%贴现%'
			) AS X1
		) AS X
	WHERE R.Sorting = 9

	/* 1.3按贷款逾期情况 */
	IF OBJECT_ID('tempdb..#PublicOverDue') IS NOT NULL BEGIN
		DROP TABLE #PublicOverDue
	END
	IF OBJECT_ID('tempdb..#PrivateOverDue') IS NOT NULL BEGIN
		DROP TABLE #PrivateOverDue
	END
	-- Public
	SELECT P.ScopeName, P.Balance1
		, OverdueDays = CASE WHEN P.LoanEndDate < @asOfDate AND P.Balance1 > 0 THEN DATEDIFF(day, P.LoanEndDate, @asOfDate) ELSE 0 END
		, OweInterestDays
		, FinalDays = 0
		, DaysLevel = '                 '
	INTO #PublicOverDue
	FROM ImportPublic P
	WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
		AND EXISTS(
			SELECT * FROM ImportLoanView L
			WHERE L.ImportId = P.ImportId AND L.LoanAccount = P.LoanAccount
				AND (L.DangerLevel IN ('次级', '可疑', '损失') OR L.DangerLevel LIKE '关%')
		)

	UPDATE #PublicOverDue SET FinalDays = ISNULL(CASE WHEN OverdueDays >= OweInterestDays THEN OverdueDays ELSE OweInterestDays END, 0)
	UPDATE #PublicOverDue SET DaysLevel = (
			CASE
				WHEN FinalDays <=  0  THEN ''
				WHEN FinalDays <= 90  THEN '90天以内'
				WHEN FinalDays <= 360  THEN '91到360天'
				ELSE '361天以上'
			END
		)
	--Private
	SELECT P.LoanBalance, P.ProductName AS CustomerType
		, OverdueDays = CASE WHEN P.ContractStartDate < @asOfDate AND P.LoanBalance > 0 THEN DATEDIFF(day, P.ContractEndDate, @asOfDate) ELSE 0 END
		, OweInterestDays = P.InterestOverdueDays
		, FinalDays = 0
		, DaysLevel = '                 '
	INTO #PrivateOverDue
	FROM ImportPrivate P
	WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
		AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
		AND EXISTS(
			SELECT * FROM ImportLoanView L
			WHERE L.ImportId = P.ImportId AND L.LoanAccount = P.LoanAccount
				AND (L.DangerLevel IN ('次级', '可疑', '损失') OR L.DangerLevel LIKE '关%')
		)

	UPDATE #PrivateOverDue SET OverdueDays = OweInterestDays WHERE OverdueDays = 0 AND OweInterestDays > 0 AND CustomerType LIKE '%房%'
	UPDATE #PrivateOverDue SET FinalDays = ISNULL(CASE WHEN OverdueDays >= OweInterestDays THEN OverdueDays ELSE OweInterestDays END, 0)
	UPDATE #PrivateOverDue SET DaysLevel = (
			CASE
				WHEN FinalDays <=  0  THEN ''
				WHEN FinalDays <= 90  THEN '90天以内'
				WHEN FinalDays <= 360  THEN '91到360天'
				ELSE '361天以上'
			END
		)

	DELETE FROM #ResultSingle

	INSERT INTO #ResultSingle
	SELECT DaysLevel, A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F)
	FROM (
		SELECT DaysLevel, A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = SUM(F)
		FROM (
				SELECT DaysLevel
					, A = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
					, B = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
					, C = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
					, D = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
					, E = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
					, F = 0.00
				FROM #PublicOverDue
			) AS X1
		GROUP BY DaysLevel
		UNION ALL
		SELECT DaysLevel, A = 0.00, B = 0.00, C = 0.00, D = 0.00, E = 0.00, F = SUM(LoanBalance)
		FROM #PrivateOverDue
		GROUP BY DaysLevel
	) AS X
	GROUP BY DaysLevel

	/* 1.3.1逾期90天以内 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 10 AND X.Category = '90天以内'

	/* 1.3.2逾期91天到360天 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 11 AND X.Category = '91到360天'

	/* 1.3.3逾期361天以上 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, #ResultSingle X
	WHERE R.Sorting = 12 AND X.Category = '361天以上'
	
	/* 2.地方政府融资平台贷款余额 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, (
		SELECT A = ISNULL(SUM(A), 0), B = ISNULL(SUM(B), 0), C = ISNULL(SUM(C), 0), D = ISNULL(SUM(D), 0), E = ISNULL(SUM(E), 0), F = 0.00
		FROM (
				SELECT A = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
					, B = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
					, C = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
					, D = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
					, E = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
					, F = 0.00
				FROM ImportPublic P
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
					AND IsINRZ = '是'
			) AS X1
	) AS X
	WHERE R.Sorting = 13

	/* 4.表外授信余额 */
	/* 4.1其中：票据承兑 */
	UPDATE R SET Balance1 = X.A, Balance2 = X.B, Balance3 = X.C, Balance4 = X.D, Balance5 = X.E, Balance6 = X.F, Balance7 = X.F
	FROM #Result R, (
		SELECT A = SUM(A), B = SUM(B), C = SUM(C), D = SUM(D), E = SUM(E), F = 0.00
		FROM (
				SELECT A = CASE WHEN ScopeName = '大型企业' THEN NormalBalance ELSE 0.00 END
					, B = CASE WHEN ScopeName = '中型企业' THEN NormalBalance ELSE 0.00 END
					, C = CASE WHEN ScopeName = '小型企业' THEN NormalBalance ELSE 0.00 END
					, D = CASE WHEN ScopeName = '微型企业' THEN NormalBalance ELSE 0.00 END
					, E = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND NormalBalance < 500 THEN NormalBalance ELSE 0.00 END
					, F = 0.00
				FROM ImportPublic P
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 2 --表外
			) AS X1
	) AS X
	WHERE R.Sorting IN (14, 15)

	SELECT * FROM #Result

	DROP TABLE #Result
	DROP TABLE #ResultSingle
END

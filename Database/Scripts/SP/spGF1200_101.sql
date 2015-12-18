IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF1200_101') BEGIN
	DROP PROCEDURE spGF1200_101
END
GO

CREATE PROCEDURE spGF1200_101
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate smalldatetime = '20151130'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	DECLARE @importIdLastYear int
	SELECT @importIdLastYear = Id FROM Import WHERE ImportDate <= CAST(YEAR(@asOfDate) - 1 AS varchar) + '1231'

	IF OBJECT_ID('tempdb..#Result') IS NOT NULL BEGIN
		DROP TABLE #Result
	END

	CREATE TABLE #Result(
		Id int,
		SubjectName nvarchar(50),
		JS money, -- 本期减少
		ZC money, -- 正常类贷款
		GZ money, -- 关注类贷款
		CJ money, -- 次级类贷款
		KY money, -- 可疑类贷款
		SS money  -- 损失类贷款
	)

	INSERT INTO #Result (Id, JS, ZC, GZ, CJ, KY, SS, SubjectName)
	SELECT 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2.本期增加'
	UNION ALL
	SELECT 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '3.正常类贷款'
	UNION ALL
	SELECT 2, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '4.关注类贷款'
	UNION ALL
	SELECT 3, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '5.次级类贷款'
	UNION ALL
	SELECT 4, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '6.可疑类贷款'
	UNION ALL
	SELECT 5, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '7.损失类贷款'

	IF @importId IS NULL BEGIN
		SELECT * FROM #Result
		RETURN
	END

	-- 本期增加 (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '关%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '次级' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '可疑' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '损失' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND NOT EXISTS(SELECT * FROM ImportLoan LY WHERE LY.ImportId = @importIdLastYear AND LY.LoanAccount = L.LoanAccount)
			) AS X1
		) AS X
	WHERE R.Id = 0

	-- 正常类贷款 (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '关%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '次级' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '可疑' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '损失' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND (DangerLevel IS NULL OR DangerLevel = '正常' ))
			) AS X1
		) AS X
	WHERE R.Id = 1

	-- 关注类贷款 (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '关%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '次级' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '可疑' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '损失' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND DangerLevel LIKE '关%')
			) AS X1
		) AS X
	WHERE R.Id = 2

	-- 次级类贷款 (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '关%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '次级' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '可疑' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '损失' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND DangerLevel = '次级')
			) AS X1
		) AS X
	WHERE R.Id = 3

	-- 可疑类贷款 (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '关%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '次级' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '可疑' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '损失' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND DangerLevel = '可疑')
			) AS X1
		) AS X
	WHERE R.Id = 4

	-- 损失类贷款 (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '关%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '次级' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '可疑' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '损失' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND DangerLevel = '损失')
			) AS X1
		) AS X
	WHERE R.Id = 5

	-- 本期减少 (column)
	DECLARE @dateLastDec01 datetime = CAST(YEAR(@asOfDate) - 1 AS varchar) + '1201'
	DECLARE @dateLastDec31 datetime = CAST(YEAR(@asOfDate) - 1 AS varchar) + '1231'
	UPDATE R SET R.JS = X.Total
	FROM #Result R
		, (
			SELECT Total = SUM(CapitalAmount)
			FROM (
				SELECT CapitalAmount
				FROM ImportLoan L
					LEFT JOIN ImportPublic U ON L.LoanAccount = U.LoanAccount AND U.ImportId = @importId
					LEFT JOIN ImportPrivate V ON L.LoanAccount = V.LoanAccount AND V.ImportId = @importId
				WHERE L.ImportId = @importId
					AND L.LoanEndDate >= @asOfDate AND (U.OweInterestDays > 0 OR V.InterestOverdueDays > 0)
					AND L.LoanStartDate BETWEEN @dateLastDec01 AND @dateLastDec31
			) AS X1
		) AS X
	WHERE R.Id = 1

	UPDATE R SET R.JS = X.Total
	FROM #Result R
		INNER JOIN (
			SELECT Id, Total = SUM(CapitalAmount)
			FROM (
				SELECT Id =
						CASE
							WHEN DangerLevel LIKE '关%' THEN 2
							WHEN DangerLevel = '次级' THEN 3
							WHEN DangerLevel = '可疑' THEN 4
							WHEN DangerLevel = '损失' THEN 5
							ELSE 1
						END
					, CapitalAmount
				FROM ImportLoan LY
				WHERE ImportId = @importIdLastYear
					AND NOT EXISTS(SELECT * FROM ImportLoan L WHERE L.ImportId = @importId AND L.LoanAccount = LY.LoanAccount)
			) AS X1
			GROUP BY Id
		) AS X ON R.Id = X.Id
	WHERE R.Id BETWEEN 2 AND 5
	
	SELECT Id, SubjectName
		, JS = ROUND(ISNULL(JS, 0)/10000, 2)
		, ZC = ROUND(ISNULL(ZC, 0)/10000, 2)
		, GZ = ROUND(ISNULL(GZ, 0)/10000, 2)
		, CJ = ROUND(ISNULL(CJ, 0)/10000, 2)
		, KY = ROUND(ISNULL(KY, 0)/10000, 2)
		, SS = ROUND(ISNULL(SS, 0)/10000, 2)
	FROM #Result

END

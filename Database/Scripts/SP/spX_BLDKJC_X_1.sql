IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_BLDKJC_X_1') BEGIN
	DROP PROCEDURE spX_BLDKJC_X_1
END
GO

CREATE PROCEDURE spX_BLDKJC_X_1
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20151031'--'20150930'

	DECLARE @asOfDateLastTenDays as smalldatetime
	DECLARE @asOfDateLastMonth as smalldatetime = @asOfDate - DAY(@asOfDate) -- Last day of previous month
	DECLARE @asOfDateYearStart as smalldatetime = CAST(Year(@asOfDate) AS varchar(4)) + '0101'

	SET @asOfDateYearStart = @asOfDateYearStart - 1 --���弶���෽�濼�ǣ�ȡȥ�����յ����ڸ�����

	SET @asOfDateLastTenDays =
		CASE
			WHEN DAY(@asOfDate) <= 10 THEN @asOfDateLastMonth
			WHEN DAY(@asOfDate) <= 20 THEN CONVERT(varchar(6), @asOfDate, 112) + '10'
			ELSE CONVERT(varchar(6), @asOfDate, 112) + '20'
		END

	DECLARE @importIdToday int
	DECLARE @importIdLastTenDays int
	DECLARE @importIdLastMonth int
	DECLARE @importIdYearStart int

	SELECT @importIdToday = Id FROM Import WHERE ImportDate = @asOfDate
	SELECT @importIdLastTenDays = Id FROM Import WHERE ImportDate = @asOfDateLastTenDays
	SELECT @importIdLastMonth = Id FROM Import WHERE ImportDate =  @asOfDateLastMonth
	SELECT @importIdYearStart = Id FROM Import WHERE ImportDate =  @asOfDateYearStart

	--SELECT @asOfDateLastTenDays AS LastTenDays, @asOfDateLastMonth AS LastMonth, @asOfDateYearStart AS YearStart
	--SELECT @importIdToday AS ImportIdToday, @importIdLastTenDays AS ImportIdLastTenDays, @importIdLastMonth AS ImportIdLastMonth, @importIdYearStart AS ImportIdYearStart

	IF OBJECT_ID('tempdb..#PublicToday') IS NOT NULL BEGIN
		DROP TABLE #PublicToday
		DROP TABLE #PublicLastTenDays
		DROP TABLE #PublicLastMonth
		DROP TABLE #PublicYearStart

		DROP TABLE #PrivateToday
		DROP TABLE #PrivateLastTenDays
		DROP TABLE #PrivateLastMonth
		DROP TABLE #PrivateYearStart

		DROP TABLE #Final
	END

	CREATE TABLE #PublicToday(
		Balance money,
		GZ money,
		CJ money,
		KY money,
		SS money
	)

	CREATE TABLE #PrivateToday(
		Balance money,
		GZ money,
		CJ money,
		KY money,
		SS money
	)

	/* Publics */
	IF DAY(@asOfDate + 1) = 1 BEGIN --Last day of the month
		INSERT INTO #PublicToday
		SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
		FROM (
			SELECT Balance = CapitalAmount
				, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
				, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
				, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
				, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
			FROM ImportLoan
			WHERE ImportId = @importIdToday AND OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
				AND CustomerType = '�Թ�'
		) AS X
	END
	ELSE BEGIN
		INSERT INTO #PublicToday
		SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
		FROM (
			SELECT Balance = L.CapitalAmount
				, GZ = CASE WHEN W.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
				, CJ = CASE WHEN W.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
				, KY = CASE WHEN W.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
				, SS = CASE WHEN W.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
			FROM ImportLoan L
				LEFT JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
			WHERE L.ImportId = @importIdToday AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
				AND L.CustomerType = '�Թ�'
		) AS X
	END

	SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
	INTO #PublicLastTenDays
	FROM (
		SELECT Balance = L.CapitalAmount
			, GZ = CASE WHEN W.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
			, CJ = CASE WHEN W.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
			, KY = CASE WHEN W.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
			, SS = CASE WHEN W.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
		FROM ImportLoan L
			LEFT JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdLastTenDays AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
			AND L.CustomerType = '�Թ�'
	) AS X

	SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
	INTO #PublicLastMonth
	FROM (
		SELECT Balance = CapitalAmount
			, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
			, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
			, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
			, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
		FROM ImportLoan
		WHERE ImportId = @importIdLastMonth AND OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
			AND CustomerType = '�Թ�'
	) AS X

	SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
	INTO #PublicYearStart
	FROM (
		SELECT Balance = CapitalAmount
			, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
			, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
			, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
			, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
		FROM ImportLoan
		WHERE ImportId = @importIdYearStart AND OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
			AND CustomerType = '�Թ�'
	) AS X

	/* Privates */
	IF DAY(@asOfDate + 1) = 1 BEGIN --Last day of the month
		INSERT INTO #PrivateToday
		SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
		FROM (
			SELECT Balance = CapitalAmount
				, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
				, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
				, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
				, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
			FROM ImportLoan
			WHERE ImportId = @importIdToday AND OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
				AND CustomerType = '��˽'
		) AS X
	END
	ELSE BEGIN
		INSERT INTO #PrivateToday
		SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
		FROM (
			SELECT Balance = L.CapitalAmount
				, GZ = CASE WHEN W.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
				, CJ = CASE WHEN W.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
				, KY = CASE WHEN W.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
				, SS = CASE WHEN W.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
			FROM ImportLoan L
				LEFT JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
			WHERE L.ImportId = @importIdToday AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
				AND L.CustomerType = '��˽'
		) AS X
	END

	SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
	INTO #PrivateLastTenDays
	FROM (
		SELECT Balance = L.CapitalAmount
			, GZ = CASE WHEN W.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
			, CJ = CASE WHEN W.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
			, KY = CASE WHEN W.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
			, SS = CASE WHEN W.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
		FROM ImportLoan L
			LEFT JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdLastTenDays AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
			AND L.CustomerType = '��˽'
	) AS X

	SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
	INTO #PrivateLastMonth
	FROM (
		SELECT Balance = CapitalAmount
			, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
			, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
			, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
			, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
		FROM ImportLoan
		WHERE ImportId = @importIdLastMonth AND OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
			AND CustomerType = '��˽'
	) AS X

	SELECT SUM(Balance) AS Balance, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
	INTO #PrivateYearStart
	FROM (
		SELECT Balance = CapitalAmount
			, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
			, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
			, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
			, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
		FROM ImportLoan
		WHERE ImportId = @importIdYearStart AND OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
			AND CustomerType = '��˽'
	) AS X

	/* Final Temporary table */
	SELECT Id, Category
		, Today = CAST(ROUND(ISNULL(Today/10000, 0), 2) AS decimal(10, 2))
		, LastTenDays = CAST(ROUND(ISNULL(LastTenDays/10000, 0), 2) AS decimal(10, 2))
		, LastMonth = CAST(ROUND(ISNULL(LastMonth/10000, 0), 2) AS decimal(10, 2))
		, YearStart = CAST(ROUND(ISNULL(YearStart/10000, 0), 2) AS decimal(10, 2))
	INTO #Final
	FROM (
		SELECT 1 AS Id, 'Public' AS Category, T.Balance AS Today, D.Balance AS LastTenDays, M.Balance AS LastMonth, Y.Balance AS YearStart
		FROM #PublicToday T, #PublicLastTenDays D, #PublicLastMonth M, #PublicYearStart Y
		UNION ALL
		SELECT 2 AS Id, 'Private' AS Category, T.Balance AS Today, D.Balance AS LastTenDays, M.Balance AS LastMonth, Y.Balance AS YearStart
		FROM #PrivateToday T, #PrivateLastTenDays D, #PrivateLastMonth M, #PrivateYearStart Y
		UNION ALL
		SELECT 3 AS Id, 'PublicGZ' AS Category, T.GZ AS Today, D.GZ AS LastTenDays, M.GZ AS LastMonth, Y.GZ AS YearStart
		FROM #PublicToday T, #PublicLastTenDays D, #PublicLastMonth M, #PublicYearStart Y
		UNION ALL
		SELECT 4 AS Id, 'PrivateGZ' AS Category, T.GZ AS Today, D.GZ AS LastTenDays, M.GZ AS LastMonth, Y.GZ AS YearStart
		FROM #PrivateToday T, #PrivateLastTenDays D, #PrivateLastMonth M, #PrivateYearStart Y
		UNION ALL
		SELECT 5 AS Id, 'PublicCJ' AS Category, T.CJ AS Today, D.CJ AS LastTenDays, M.CJ AS LastMonth, Y.CJ AS YearStart
		FROM #PublicToday T, #PublicLastTenDays D, #PublicLastMonth M, #PublicYearStart Y
		UNION ALL
		SELECT 6 AS Id, 'PublicKY' AS Category, T.KY AS Today, D.KY AS LastTenDays, M.KY AS LastMonth, Y.KY AS YearStart
		FROM #PublicToday T, #PublicLastTenDays D, #PublicLastMonth M, #PublicYearStart Y
		UNION ALL
		SELECT 7 AS Id, 'PublicSS' AS Category, T.SS AS Today, D.SS AS LastTenDays, M.SS AS LastMonth, Y.SS AS YearStart
		FROM #PublicToday T, #PublicLastTenDays D, #PublicLastMonth M, #PublicYearStart Y
		UNION ALL
		SELECT 8 AS Id, 'PrivateCJ' AS Category, T.CJ AS Today, D.CJ AS LastTenDays, M.CJ AS LastMonth, Y.CJ AS YearStart
		FROM #PrivateToday T, #PrivateLastTenDays D, #PrivateLastMonth M, #PrivateYearStart Y
		UNION ALL
		SELECT 9 AS Id, 'PrivateKY' AS Category, T.KY AS Today, D.KY AS LastTenDays, M.KY AS LastMonth, Y.KY AS YearStart
		FROM #PrivateToday T, #PrivateLastTenDays D, #PrivateLastMonth M, #PrivateYearStart Y
		UNION ALL
		SELECT 10 AS Id, 'PrivateSS' AS Category, T.SS AS Today, D.SS AS LastTenDays, M.SS AS LastMonth, Y.SS AS YearStart
		FROM #PrivateToday T, #PrivateLastTenDays D, #PrivateLastMonth M, #PrivateYearStart Y
	) AS X

	/* Result to output */
	SELECT Id, Category, Today, DiffLastTenDays = Today - LastTenDays, DiffLastMonth = Today - LastMonth, DiffYearStart = Today - YearStart
	FROM #Final
	UNION ALL
	SELECT Id, Category
		, RatioToday = CAST(ROUND(ISNULL(RatioToday*100, 0), 2) AS decimal(10, 2)) --����100ֻ��Ϊ�˱��decimal(10, 2)�������excel֮ǰ�س���100
		, DiffRatioLastTenDays = CAST(ROUND(ISNULL((RatioToday - RatioLastTenDays)*100, 0), 2) AS decimal(10, 2))
		, DiffRatioLastMonth = CAST(ROUND(ISNULL((RatioToday - RatioLastMonth)*100, 0), 2) AS decimal(10, 2))
		, DiffRatioYearStart = CAST(ROUND(ISNULL((RatioToday - RatioYearStart)*100, 0), 2) AS decimal(10, 2))
	FROM (
		-- ����������
		SELECT 101 AS Id, 'BL_Ratio' AS Category, RatioToday = CASE WHEN T.Today <> 0 THEN R.Today/T.Today ELSE 0.00 END
			, RatioLastTenDays = CASE WHEN T.LastTenDays <> 0 THEN R.LastTenDays/T.LastTenDays ELSE 0.00 END
			, RatioLastMonth = CASE WHEN T.LastMonth <> 0 THEN R.LastMonth/T.LastMonth ELSE 0.00 END
			, RatioYearStart = CASE WHEN T.YearStart <> 0 THEN R.YearStart/T.YearStart ELSE 0.00 END
		FROM (
				SELECT Today = SUM(Today), LastTenDays = SUM(LastTenDays), LastMonth = SUM(LastMonth), YearStart = SUM(YearStart) FROM #Final
				WHERE Id IN (1, 2)
			) T
			, (
				SELECT Today = SUM(Today), LastTenDays = SUM(LastTenDays), LastMonth = SUM(LastMonth), YearStart = SUM(YearStart) FROM #Final
				WHERE Id BETWEEN 5 AND 10
			) R
		UNION ALL
		-- �����಻��������
		SELECT 102 AS Id, 'BL_Ratio_Public' AS Category, RatioToday = CASE WHEN T.Today <> 0 THEN R.Today/T.Today ELSE 0.00 END
			, RatioLastTenDays = CASE WHEN T.LastTenDays <> 0 THEN R.LastTenDays/T.LastTenDays ELSE 0.00 END
			, RatioLastMonth = CASE WHEN T.LastMonth <> 0 THEN R.LastMonth/T.LastMonth ELSE 0.00 END
			, RatioYearStart = CASE WHEN T.YearStart <> 0 THEN R.YearStart/T.YearStart ELSE 0.00 END
		FROM (
				SELECT Today = SUM(Today), LastTenDays = SUM(LastTenDays), LastMonth = SUM(LastMonth), YearStart = SUM(YearStart) FROM #Final
				WHERE Id IN (1)
			) T
			, (
				SELECT Today = SUM(Today), LastTenDays = SUM(LastTenDays), LastMonth = SUM(LastMonth), YearStart = SUM(YearStart) FROM #Final
				WHERE Id IN (5, 6, 7)
			) R
		UNION ALL
		-- �����಻��������
		SELECT 103 AS Id, 'BL_Ratio_Private' AS Category, RatioToday = CASE WHEN T.Today <> 0 THEN R.Today/T.Today ELSE 0.00 END
			, RatioLastTenDays = CASE WHEN T.LastTenDays <> 0 THEN R.LastTenDays/T.LastTenDays ELSE 0.00 END
			, RatioLastMonth = CASE WHEN T.LastMonth <> 0 THEN R.LastMonth/T.LastMonth ELSE 0.00 END
			, RatioYearStart = CASE WHEN T.YearStart <> 0 THEN R.YearStart/T.YearStart ELSE 0.00 END
		FROM (
				SELECT Today = SUM(Today), LastTenDays = SUM(LastTenDays), LastMonth = SUM(LastMonth), YearStart = SUM(YearStart) FROM #Final
				WHERE Id IN (2)
			) T
			, (
				SELECT Today = SUM(Today), LastTenDays = SUM(LastTenDays), LastMonth = SUM(LastMonth), YearStart = SUM(YearStart) FROM #Final
				WHERE Id IN (8, 9, 10)
			) R
	) AS X
	ORDER BY Id

	DROP TABLE #PublicToday
	DROP TABLE #PublicLastTenDays
	DROP TABLE #PublicLastMonth
	DROP TABLE #PublicYearStart

	DROP TABLE #PrivateToday
	DROP TABLE #PrivateLastTenDays
	DROP TABLE #PrivateLastMonth
	DROP TABLE #PrivateYearStart

	DROP TABLE #Final
END
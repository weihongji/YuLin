IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_BLDKJC_X_2') BEGIN
	DROP PROCEDURE spX_BLDKJC_X_2
END
GO

CREATE PROCEDURE spX_BLDKJC_X_2
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
	
	DECLARE @NoShenFu_1 money, @NoShenFu_2 money, @NoShenFu_3 money, @NoShenFu_4 money
	DECLARE @HengShan_1 money, @HengShan_2 money, @HengShan_3 money, @HengShan_4 money
	DECLARE @JingBian_1 money, @JingBian_2 money, @JingBian_3 money, @JingBian_4 money
	DECLARE @DingBian_1 money, @DingBian_2 money, @DingBian_3 money, @DingBian_4 money
	DECLARE @ShenMu_1 money, @ShenMu_2 money, @ShenMu_3 money, @ShenMu_4 money
	DECLARE @FuGu_1 money, @FuGu_2 money, @FuGu_3 money, @FuGu_4 money

	/* Today */
	IF DAY(@asOfDate + 1) = 1 BEGIN --Last day of the month
		SELECT @NoShenFu_1 = ISNULL(SUM(CapitalAmount), 0)
		FROM ImportLoan
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

		SELECT @HengShan_1 = ISNULL(SUM(CapitalAmount), 0)
		FROM ImportLoan
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

		SELECT @JingBian_1 = ISNULL(SUM(CapitalAmount), 0)
		FROM ImportLoan
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

		SELECT @DingBian_1 = ISNULL(SUM(CapitalAmount), 0)
		FROM ImportLoan
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

		SELECT @ShenMu_1 = ISNULL(SUM(CapitalAmount), 0)
		FROM ImportLoanSF
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%')

		SELECT @FuGu_1 = ISNULL(SUM(CapitalAmount), 0)
		FROM ImportLoanSF
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')
	END
	ELSE BEGIN
		SELECT @NoShenFu_1 = ISNULL(SUM(L.CapitalAmount), 0)
		FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

		SELECT @HengShan_1 = ISNULL(SUM(L.CapitalAmount), 0)
		FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

		SELECT @JingBian_1 = ISNULL(SUM(L.CapitalAmount), 0)
		FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

		SELECT @DingBian_1 = ISNULL(SUM(L.CapitalAmount), 0)
		FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

		SELECT @ShenMu_1 = ISNULL(SUM(L.CapitalAmount), 0)
		FROM ImportLoanSF L INNER JOIN ImportLoanSF W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%')

		SELECT @FuGu_1 = ISNULL(SUM(L.CapitalAmount), 0)
		FROM ImportLoanSF L INNER JOIN ImportLoanSF W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')
	END

	/* LastTenDays */
	SELECT @NoShenFu_2 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

	SELECT @HengShan_2 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

	SELECT @JingBian_2 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @DingBian_2 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @ShenMu_2 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoanSF L INNER JOIN ImportLoanSF W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%')

	SELECT @FuGu_2 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoanSF L INNER JOIN ImportLoanSF W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	/* LastMonth */
	SELECT @NoShenFu_3 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

	SELECT @HengShan_3 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdLastMonth AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

	SELECT @JingBian_3 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdLastMonth AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @DingBian_3 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdLastMonth AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @ShenMu_3 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoanSF L
	WHERE L.ImportId = @importIdLastMonth AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%')

	SELECT @FuGu_3 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoanSF L
	WHERE L.ImportId = @importIdLastMonth AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	/* YearStart */
	SELECT @NoShenFu_4 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdYearStart AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

	SELECT @HengShan_4 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdYearStart AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

	SELECT @JingBian_4 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdYearStart AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @DingBian_4 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdYearStart AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @ShenMu_4 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoanSF L
	WHERE L.ImportId = @importIdYearStart AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%')

	SELECT @FuGu_4 = ISNULL(SUM(L.CapitalAmount), 0)
	FROM ImportLoanSF L
	WHERE L.ImportId = @importIdYearStart AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	/* Result to output */
	SELECT Id, Category, Today, DiffLastTenDays = Today - LastTenDays, DiffLastMonth = Today - LastMonth, DiffYearStart = Today - YearStart
	FROM (
		SELECT Id = 1, Category = '�ܶ�'
			, CAST(ROUND(@NoShenFu_1 + @ShenMu_1 + @FuGu_1, 0)/10000 AS money) AS Today
			, CAST(ROUND(@NoShenFu_2 + @ShenMu_2 + @FuGu_2, 0)/10000 AS money) AS LastTenDays
			, CAST(ROUND(@NoShenFu_3 + @ShenMu_3 + @FuGu_3, 0)/10000 AS money) AS LastMonth
			, CAST(ROUND(@NoShenFu_4 + @ShenMu_4 + @FuGu_4, 0)/10000 AS money) AS YearStart
		UNION ALL
		SELECT Id = 2, Category = '��ľ'
			, CAST(ROUND(@ShenMu_1/10000, 0) AS money)
			, CAST(ROUND(@ShenMu_2/10000, 0) AS money)
			, CAST(ROUND(@ShenMu_3/10000, 0) AS money)
			, CAST(ROUND(@ShenMu_4/10000, 0) AS money)
		UNION ALL
		SELECT Id = 3, Category = '����'
			, CAST(ROUND(@FuGu_1/10000, 2) AS money)
			, CAST(ROUND(@FuGu_2/10000, 2) AS money)
			, CAST(ROUND(@FuGu_3/10000, 2) AS money)
			, CAST(ROUND(@FuGu_4/10000, 2) AS money)
		UNION ALL
		SELECT Id = 4, Category = '��ɽ'
			, CAST(ROUND(@HengShan_1/10000, 2) AS money)
			, CAST(ROUND(@HengShan_2/10000, 2) AS money)
			, CAST(ROUND(@HengShan_3/10000, 2) AS money)
			, CAST(ROUND(@HengShan_4/10000, 2) AS money)
		UNION ALL
		SELECT Id = 5, Category = '����'
			, CAST(ROUND(@JingBian_1/10000, 2) AS money)
			, CAST(ROUND(@JingBian_2/10000, 2) AS money)
			, CAST(ROUND(@JingBian_3/10000, 2) AS money)
			, CAST(ROUND(@JingBian_4/10000, 2) AS money)
		UNION ALL
		SELECT Id = 6, Category = '����'
			, CAST(ROUND(@DingBian_1/10000, 2) AS money)
			, CAST(ROUND(@DingBian_2/10000, 2) AS money)
			, CAST(ROUND(@DingBian_3/10000, 2) AS money)
			, CAST(ROUND(@DingBian_4/10000, 2) AS money)
	) AS X
	ORDER BY Id

END

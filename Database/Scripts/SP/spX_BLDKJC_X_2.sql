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

	/* Today */
	IF DAY(@asOfDate + 1) = 1 BEGIN --Last day of the month
		SELECT @NoShenFu_1 = SUM(CapitalAmount)
		FROM ImportLoan
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

		SELECT @HengShan_1 = SUM(CapitalAmount)
		FROM ImportLoan
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

		SELECT @JingBian_1 = SUM(CapitalAmount)
		FROM ImportLoan
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

		SELECT @DingBian_1 = SUM(CapitalAmount)
		FROM ImportLoan
		WHERE ImportId = @importIdToday AND DangerLevel IN ('�μ�', '����', '��ʧ')
			AND OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')
	END
	ELSE BEGIN
		SELECT @NoShenFu_1 = SUM(L.CapitalAmount)
		FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

		SELECT @HengShan_1 = SUM(L.CapitalAmount)
		FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

		SELECT @JingBian_1 = SUM(L.CapitalAmount)
		FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

		SELECT @DingBian_1 = SUM(L.CapitalAmount)
		FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
		WHERE L.ImportId = @importIdToday AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
			AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')
	END

	/* LastTenDays */
	SELECT @NoShenFu_2 = SUM(L.CapitalAmount)
	FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

	SELECT @HengShan_2 = SUM(L.CapitalAmount)
	FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

	SELECT @JingBian_2 = SUM(L.CapitalAmount)
	FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @DingBian_2 = SUM(L.CapitalAmount)
	FROM ImportLoan L INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdLastMonth
	WHERE L.ImportId = @importIdLastTenDays AND W.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	/* LastMonth */
	SELECT @NoShenFu_3 = SUM(L.CapitalAmount)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

	SELECT @HengShan_3 = SUM(L.CapitalAmount)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdLastMonth AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

	SELECT @JingBian_3 = SUM(L.CapitalAmount)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdLastMonth AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @DingBian_3 = SUM(L.CapitalAmount)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdLastMonth AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	/* YearStart */
	SELECT @NoShenFu_4 = SUM(L.CapitalAmount)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdYearStart AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')

	SELECT @HengShan_4 = SUM(L.CapitalAmount)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdYearStart AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%��ɽ%')

	SELECT @JingBian_4 = SUM(L.CapitalAmount)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdYearStart AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	SELECT @DingBian_4 = SUM(L.CapitalAmount)
	FROM ImportLoan L
	WHERE L.ImportId = @importIdYearStart AND DangerLevel IN ('�μ�', '����', '��ʧ')
		AND L.OrgId IN (SELECT Id FROM Org WHERE Name LIKE '%����%')

	/* Result to output */
	SELECT Id, Category, Today, DiffLastTenDays = Today - LastTenDays, DiffLastMonth = Today - LastMonth, DiffYearStart = Today - YearStart
	FROM (
		SELECT Id = 1, Category = '�ܶ�'
			, CAST(ROUND(ISNULL(@NoShenFu_1/10000, 0), 2) AS money) AS Today
			, CAST(ROUND(ISNULL(@NoShenFu_2/10000, 0), 2) AS money) AS LastTenDays
			, CAST(ROUND(ISNULL(@NoShenFu_3/10000, 0), 2) AS money) AS LastMonth
			, CAST(ROUND(ISNULL(@NoShenFu_4/10000, 0), 2) AS money) AS YearStart
		UNION ALL
		SELECT Id = 2, Category = '��ɽ'
			, CAST(ROUND(ISNULL(@HengShan_1/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@HengShan_2/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@HengShan_3/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@HengShan_4/10000, 0), 2) AS money)
		UNION ALL
		SELECT Id = 3, Category = '����'
			, CAST(ROUND(ISNULL(@JingBian_1/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@JingBian_2/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@JingBian_3/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@JingBian_4/10000, 0), 2) AS money)
		UNION ALL
		SELECT Id = 4, Category = '����'
			, CAST(ROUND(ISNULL(@DingBian_1/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@DingBian_2/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@DingBian_3/10000, 0), 2) AS money)
			, CAST(ROUND(ISNULL(@DingBian_4/10000, 0), 2) AS money)
	) AS X
	ORDER BY Id

END

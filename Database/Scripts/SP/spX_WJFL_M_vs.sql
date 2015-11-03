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
	SELECT 1, '���пͻ�', 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00
	UNION
	SELECT 2, 'С΢�ͻ�', 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00
	UNION
	SELECT 3, '���˿ͻ�', 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00, 0, 0.00

	/* �������� */
	-- ���пͻ�
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
							WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
								AND P.MyBankIndTypeName IN ('������ҵ', '������ҵ')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
								AND P.MyBankIndTypeName IN ('������ҵ', '������ҵ')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '���пͻ�'

	-- С΢�ͻ�
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
							WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
								AND P.MyBankIndTypeName IN ('С����ҵ', '΢����ҵ')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
								AND P.MyBankIndTypeName IN ('С����ҵ', '΢����ҵ')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = 'С΢�ͻ�'

	-- ���˿ͻ�
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
								AND DangerLevel IN ('�μ�', '����', '��ʧ')
							GROUP BY CustomerName, LoanAccount
						) AS O
						FULL OUTER JOIN (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importId AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND DangerLevel IN ('�μ�', '����', '��ʧ')
							GROUP BY CustomerName, LoanAccount
						) AS N
						ON O.LoanAccount = N.LoanAccount
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '���˿ͻ�'

	/* ���� */
	-- ���пͻ�
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
							WHERE L.ImportId = @importIdLastMonth AND L.LoanState IN ('����', '��������')
								AND P.MyBankIndTypeName IN ('������ҵ', '������ҵ')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.LoanState IN ('����', '��������')
								AND P.MyBankIndTypeName IN ('������ҵ', '������ҵ')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '���пͻ�'

	-- С΢�ͻ�
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
							WHERE L.ImportId = @importIdLastMonth AND L.LoanState IN ('����', '��������')
								AND P.MyBankIndTypeName IN ('С����ҵ', '΢����ҵ')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.LoanState IN ('����', '��������')
								AND P.MyBankIndTypeName IN ('С����ҵ', '΢����ҵ')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = 'С΢�ͻ�'

	-- ���˿ͻ�
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
								AND LoanState IN ('����', '��������')
							GROUP BY CustomerName, LoanAccount
						) AS O
						FULL OUTER JOIN (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importId AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND LoanState IN ('����', '��������')
							GROUP BY CustomerName, LoanAccount
						) AS N
						ON O.LoanAccount = N.LoanAccount
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '���˿ͻ�'

	/* ��Ӧ�� */
	-- ���пͻ�
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
							WHERE L.ImportId = @importIdLastMonth AND L.LoanState = '��Ӧ��'
								AND P.MyBankIndTypeName IN ('������ҵ', '������ҵ')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.LoanState = '��Ӧ��'
								AND P.MyBankIndTypeName IN ('������ҵ', '������ҵ')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '���пͻ�'

	-- С΢�ͻ�
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
							WHERE L.ImportId = @importIdLastMonth AND L.LoanState = '��Ӧ��'
								AND P.MyBankIndTypeName IN ('С����ҵ', '΢����ҵ')
							GROUP BY L.CustomerName
						) AS O
						FULL OUTER JOIN (
							SELECT L.CustomerName, SUM(L.CapitalAmount) AS Amount FROM ImportLoan L INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
							WHERE L.ImportId = @importId AND L.LoanState = '��Ӧ��'
								AND P.MyBankIndTypeName IN ('С����ҵ', '΢����ҵ')
							GROUP BY L.CustomerName
						) AS N
						ON O.CustomerName = N.CustomerName
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = 'С΢�ͻ�'

	-- ���˿ͻ�
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
								AND LoanState = '��Ӧ��'
							GROUP BY CustomerName, LoanAccount
						) AS O
						FULL OUTER JOIN (
							SELECT CustomerName, LoanAccount, SUM(CapitalAmount) AS Amount FROM ImportLoan
							WHERE ImportId = @importId AND LoanAccount IN (SELECT P.LoanAccount FROM ImportPrivate P)
								AND LoanState = '��Ӧ��'
							GROUP BY CustomerName, LoanAccount
						) AS N
						ON O.LoanAccount = N.LoanAccount
					WHERE ISNULL(O.Amount, 0) <> ISNULL(N.Amount, 0)
				) AS XX
			) AS X
	WHERE R.CustomerScale = '���˿ͻ�'

	SELECT
		  BL_Increase_Count, BL_Increase_Amount, BL_Decrease_Count, BL_Decrease_Amount
		, YQ_Increase_Count, YQ_Increase_Amount, YQ_Decrease_Count, YQ_Decrease_Amount
		, FY_Increase_Count, FY_Increase_Amount, FY_Decrease_Count, FY_Decrease_Amount
	FROM #Result ORDER BY Sorting

	DROP TABLE #Result
END

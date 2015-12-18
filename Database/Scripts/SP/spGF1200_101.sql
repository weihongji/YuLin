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
		JS money, -- ���ڼ���
		ZC money, -- ���������
		GZ money, -- ��ע�����
		CJ money, -- �μ������
		KY money, -- ���������
		SS money  -- ��ʧ�����
	)

	INSERT INTO #Result (Id, JS, ZC, GZ, CJ, KY, SS, SubjectName)
	SELECT 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2.��������'
	UNION ALL
	SELECT 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '3.���������'
	UNION ALL
	SELECT 2, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '4.��ע�����'
	UNION ALL
	SELECT 3, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '5.�μ������'
	UNION ALL
	SELECT 4, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '6.���������'
	UNION ALL
	SELECT 5, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '7.��ʧ�����'

	IF @importId IS NULL BEGIN
		SELECT * FROM #Result
		RETURN
	END

	-- �������� (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND NOT EXISTS(SELECT * FROM ImportLoan LY WHERE LY.ImportId = @importIdLastYear AND LY.LoanAccount = L.LoanAccount)
			) AS X1
		) AS X
	WHERE R.Id = 0

	-- ��������� (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND (DangerLevel IS NULL OR DangerLevel = '����' ))
			) AS X1
		) AS X
	WHERE R.Id = 1

	-- ��ע����� (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND DangerLevel LIKE '��%')
			) AS X1
		) AS X
	WHERE R.Id = 2

	-- �μ������ (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND DangerLevel = '�μ�')
			) AS X1
		) AS X
	WHERE R.Id = 3

	-- ��������� (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND DangerLevel = '����')
			) AS X1
		) AS X
	WHERE R.Id = 4

	-- ��ʧ����� (row)
	UPDATE R SET R.ZC = X.ZC, R.GZ = X.GZ, R.CJ = X.CJ, R.KY = X.KY, R.SS = X.SS
	FROM #Result R
		, (
			SELECT ZC = SUM(CapitalAmount - GZ - CJ - KY - SS), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
				SELECT CapitalAmount
					, GZ = CASE WHEN DangerLevel LIKE '��%' THEN CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE ImportId = @importId
					AND LoanAccount IN (SELECT LoanAccount FROM ImportLoan WHERE ImportId = @importIdLastYear AND DangerLevel = '��ʧ')
			) AS X1
		) AS X
	WHERE R.Id = 5

	-- ���ڼ��� (column)
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
							WHEN DangerLevel LIKE '��%' THEN 2
							WHEN DangerLevel = '�μ�' THEN 3
							WHEN DangerLevel = '����' THEN 4
							WHEN DangerLevel = '��ʧ' THEN 5
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

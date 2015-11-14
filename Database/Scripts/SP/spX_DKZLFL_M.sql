IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_DKZLFL_M') BEGIN
	DROP PROCEDURE spX_DKZLFL_M
END
GO

CREATE PROCEDURE spX_DKZLFL_M
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
		Balance0 decimal(15, 2),
		Balance1 decimal(15, 2),
		Balance2 decimal(15, 2),
		Balance3 decimal(15, 2),
		Balance4 decimal(15, 2),
		Balance5 decimal(15, 2),
		Balance6 decimal(15, 2)
	)

	INSERT INTO #Result (Sorting, Balance0, Balance1, Balance2, Balance3, Balance4, Balance5, Balance6, SubjectName)
	SELECT 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '�������'
	UNION ALL
	SELECT 2, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '���˿ͻ�'
	UNION ALL
	SELECT 3, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 'С��ҵ'
	UNION ALL
	SELECT 4, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '���˿ͻ�'
	UNION ALL
	SELECT 5, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '�������Ѵ���'
	UNION ALL
	SELECT 6, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '����ס������'
	UNION ALL
	SELECT 7, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '���˾�Ӫ����'

	IF OBJECT_ID('tempdb..#ResultSingle') IS NOT NULL BEGIN
		DROP TABLE #ResultSingle
	END
	CREATE TABLE #ResultSingle(
		Category nvarchar(50),
		Total decimal(15, 2),
		G1 decimal(15, 2),
		G2 decimal(15, 2),
		G3 decimal(15, 2),
		CJ decimal(15, 2),
		KY decimal(15, 2),
		SS decimal(15, 2)
	)

	INSERT INTO #ResultSingle
	SELECT CustomerType, Total = SUM(CapitalAmount), G1 = SUM(G1), G2 = SUM(G2), G3 = SUM(G3), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
	FROM (
		SELECT CustomerType, CapitalAmount
				, G1 = CASE WHEN DangerLevel = '��һ' THEN CapitalAmount ELSE 0.00 END
				, G2 = CASE WHEN DangerLevel = '�ض�' THEN CapitalAmount ELSE 0.00 END
				, G3 = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
				, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
				, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
				, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
		FROM ImportLoan
		WHERE ImportId = @importId
			AND OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
	) AS X1
	GROUP BY CustomerType

	/* ������� */
	UPDATE R SET Balance0 = X.Total, Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Total), G1 = SUM(G1), G2 = SUM(G2), G3 = SUM(G3), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS) FROM #ResultSingle
	) AS X
	WHERE R.SubjectName = '�������'

	/* ���˿ͻ� */
	UPDATE R SET Balance0 = X.Total, Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.SubjectName = '���˿ͻ�' AND X.Category = '�Թ�'

	/* ���˿ͻ� */
	UPDATE R SET Balance0 = X.Total, Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.SubjectName = '���˿ͻ�' AND X.Category = '��˽'

	DELETE FROM #ResultSingle

	INSERT INTO #ResultSingle
	SELECT '', Total = SUM(CapitalAmount), G1 = SUM(G1), G2 = SUM(G2), G3 = SUM(G3), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
	FROM (
		SELECT CapitalAmount
				, G1 = CASE WHEN DangerLevel = '��һ' THEN CapitalAmount ELSE 0.00 END
				, G2 = CASE WHEN DangerLevel = '�ض�' THEN CapitalAmount ELSE 0.00 END
				, G3 = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
				, CJ = CASE WHEN DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
				, KY = CASE WHEN DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
				, SS = CASE WHEN DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
		FROM ImportLoan L INNER JOIN ImportPublic P ON L.ImportId = P.ImportId AND L.LoanAccount = P.LoanAccount
		WHERE L.ImportId = @importId
			AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
			AND P.MyBankIndTypeName IN ('С����ҵ', '΢����ҵ')
	) AS X1

	/* С��ҵ */
	UPDATE R SET Balance0 = X.Total, Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.SubjectName = 'С��ҵ'
	
	DELETE FROM #ResultSingle

	INSERT INTO #ResultSingle
	SELECT ProductName, Total = SUM(CapitalAmount), G1 = SUM(G1), G2 = SUM(G2), G3 = SUM(G3), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
	FROM (
		SELECT P.ProductName, CapitalAmount
				, G1 = CASE WHEN L.DangerLevel = '��һ' THEN CapitalAmount ELSE 0.00 END
				, G2 = CASE WHEN L.DangerLevel = '�ض�' THEN CapitalAmount ELSE 0.00 END
				, G3 = CASE WHEN L.DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
				, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN CapitalAmount ELSE 0.00 END
				, KY = CASE WHEN L.DangerLevel = '����' THEN CapitalAmount ELSE 0.00 END
				, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN CapitalAmount ELSE 0.00 END
		FROM ImportLoan L INNER JOIN ImportPrivate P ON L.ImportId = P.ImportId AND L.LoanAccount = P.LoanAccount
		WHERE L.ImportId = @importId
			AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
	) AS X1
	GROUP BY ProductName

	/* �������Ѵ��� */
	UPDATE R SET Balance0 = X.Total, Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Total), G1 = SUM(G1), G2 = SUM(G2), G3 = SUM(G3), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
		FROM #ResultSingle WHERE Category LIKE '%����%'
	) AS X
	WHERE R.SubjectName = '�������Ѵ���'

	/* ����ס������ */
	UPDATE R SET Balance0 = X.Total, Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Total), G1 = SUM(G1), G2 = SUM(G2), G3 = SUM(G3), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
		FROM #ResultSingle WHERE Category LIKE '%��%'
	) AS X
	WHERE R.SubjectName = '����ס������'

	/* ���˾�Ӫ���� */
	UPDATE R SET Balance0 = X.Total, Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Total), G1 = SUM(G1), G2 = SUM(G2), G3 = SUM(G3), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
		FROM #ResultSingle WHERE Category LIKE '%��Ӫ%'
	) AS X
	WHERE R.SubjectName = '���˾�Ӫ����'

	SELECT Balance0 = CAST(ROUND(ISNULL(Balance0/10000, 0), 2) AS decimal(10, 2))
		, Balance1 = CAST(ROUND(ISNULL(Balance1/10000, 0), 2) AS decimal(10, 2))
		, Balance2 = CAST(ROUND(ISNULL(Balance2/10000, 0), 2) AS decimal(10, 2))
		, Balance3 = CAST(ROUND(ISNULL(Balance3/10000, 0), 2) AS decimal(10, 2))
		, Balance4 = CAST(ROUND(ISNULL(Balance4/10000, 0), 2) AS decimal(10, 2))
		, Balance5 = CAST(ROUND(ISNULL(Balance5/10000, 0), 2) AS decimal(10, 2))
		, Balance6 = CAST(ROUND(ISNULL(Balance6/10000, 0), 2) AS decimal(10, 2))
	FROM #Result
	ORDER BY Sorting

	DROP TABLE #Result
	DROP TABLE #ResultSingle
END
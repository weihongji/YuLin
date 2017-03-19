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
		Balance0 money,
		Balance1 money,
		Balance2 money,
		Balance3 money,
		Balance4 money,
		Balance5 money,
		Balance6 money
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
		Total money,
		G1 money,
		G2 money,
		G3 money,
		CJ money,
		KY money,
		SS money
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
		FROM ImportLoanView
		WHERE ImportId = @importId
			AND OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
	) AS X1
	GROUP BY CustomerType

	/* ������� */
	UPDATE R SET Balance0 = dbo.sfGetLoanBalance(@asOfDate, 0), Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Total), G1 = SUM(G1), G2 = SUM(G2), G3 = SUM(G3), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS) FROM #ResultSingle
	) AS X
	WHERE R.SubjectName = '�������'

	/* ���˿ͻ� */
	UPDATE R SET Balance0 = dbo.sfGetLoanBalance(@asOfDate, 1), Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.SubjectName = '���˿ͻ�' AND X.Category = '�Թ�'

	/* ���˿ͻ� */
	UPDATE R SET Balance0 = dbo.sfGetLoanBalance(@asOfDate, 2), Balance1 = X.G1, Balance2 = X.G2, Balance3 = X.G3, Balance4 = X.CJ, Balance5 = X.KY, Balance6 = X.SS
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
		FROM ImportLoanView L INNER JOIN ImportPublic P ON L.ImportId = P.ImportId AND L.LoanAccount = P.LoanAccount
		WHERE L.ImportId = @importId
			AND L.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
			AND P.MyBankIndTypeName IN ('С����ҵ', '΢����ҵ')
			AND P.PublicType = 1
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
		FROM ImportLoanView L INNER JOIN ImportPrivate P ON L.ImportId = P.ImportId AND L.LoanAccount = P.LoanAccount
		WHERE L.ImportId = @importId
			AND L.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
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

	SELECT Balance0 = CAST(ROUND(ISNULL(Balance0/10000, 0), 2) AS money)
		, Balance1 = CAST(ROUND(ISNULL(Balance1/10000, 0), 2) AS money)
		, Balance2 = CAST(ROUND(ISNULL(Balance2/10000, 0), 2) AS money)
		, Balance3 = CAST(ROUND(ISNULL(Balance3/10000, 0), 2) AS money)
		, Balance4 = CAST(ROUND(ISNULL(Balance4/10000, 0), 2) AS money)
		, Balance5 = CAST(ROUND(ISNULL(Balance5/10000, 0), 2) AS money)
		, Balance6 = CAST(ROUND(ISNULL(Balance6/10000, 0), 2) AS money)
	FROM #Result
	ORDER BY Sorting

	DROP TABLE #Result
	DROP TABLE #ResultSingle
END

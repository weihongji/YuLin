IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_CSHSX_M_1_Single') BEGIN
	DROP PROCEDURE spX_CSHSX_M_1_Single
END
GO

CREATE PROCEDURE spX_CSHSX_M_1_Single
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
		Id int,
		Name nvarchar(50),
		Total money,
		ZC money,
		GZ money,
		CJ money,
		KY money,
		SS money
	)

	INSERT INTO #Result (Id, Total, ZC, GZ, CJ, KY, SS, Name)
	SELECT 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '����ϼ�'
	UNION ALL
	SELECT 2, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.1���ô���'
	UNION ALL
	SELECT 3, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.2��֤����'
	UNION ALL
	SELECT 4, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.3�֣��ʣ�Ѻ����'
	UNION ALL
	SELECT 5, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '1.4���ּ����ʽת����'
	UNION ALL
	SELECT 6, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2.1����90������'
	UNION ALL
	SELECT 7, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2.2����91�쵽360��'
	UNION ALL
	SELECT 8, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2.3����361������'
	UNION ALL
	SELECT 9, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '3.1��˾�����'
	UNION ALL
	SELECT 10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '���У����ز���������'
	UNION ALL
	SELECT 11, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '3.2���˾�Ӫ�Դ���'
	UNION ALL
	SELECT 12, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '3.3���˹�������'
	UNION ALL
	SELECT 13, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '3.4������������'

	IF OBJECT_ID('tempdb..#ResultSingle') IS NOT NULL BEGIN
		DROP TABLE #ResultSingle
	END
	CREATE TABLE #ResultSingle(
		Name nvarchar(50),
		Total money,
		ZC money,
		GZ money,
		CJ money,
		KY money,
		SS money
	)
	
	INSERT INTO #ResultSingle(Name, Total, ZC, GZ, CJ, KY, SS)
	SELECT DanBao
		, Total = SUM(Balance)
		, ZC = SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
		, GZ = SUM(GZ)
		, CJ = SUM(CJ)
		, KY = SUM(KY)
		, SS = SUM(SS)
	FROM (
		SELECT DanBao = D.Category
			, Balance = P.Balance1
			, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.Balance1 ELSE 0.00 END
			, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.Balance1 ELSE 0.00 END
			, KY = CASE WHEN L.DangerLevel = '����' THEN P.Balance1 ELSE 0.00 END
			, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.Balance1 ELSE 0.00 END
		FROM ImportPublic P
			LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
			LEFT JOIN DanBaoFangShi D ON D.Name = P.VouchTypeName
		WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND P.PublicType = 1
		UNION ALL
		SELECT DanBao = D.Category
			, Balance = P.LoanBalance
			, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.LoanBalance ELSE 0.00 END
			, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.LoanBalance ELSE 0.00 END
			, KY = CASE WHEN L.DangerLevel = '����' THEN P.LoanBalance ELSE 0.00 END
			, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.LoanBalance ELSE 0.00 END
		FROM ImportPrivate P
			LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
			LEFT JOIN DanBaoFangShi D ON D.Name = P.DanBaoFangShi
		WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
	) AS X
	GROUP BY DanBao

	/* ����ϼ� */
	UPDATE #Result SET Total = ISNULL(dbo.sfGetLoanBalance(@asOfDate, 0)/10000, 0) WHERE Id = 1
	UPDATE R SET ZC = R.Total - X.GZ - X.CJ - X.KY - X.SS, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, (
		SELECT GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS) FROM #ResultSingle
	) AS X
	WHERE R.Id = 1

	/* 1.���������ʽ */

	/* 1.1���ô��� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.Id = 2 AND X.Name = '����'

	/* 1.3�֣��ʣ�Ѻ���� */
	UPDATE R SET Total = X1.Total, ZC = X1.ZC, GZ = X1.GZ, CJ = X1.CJ, KY = X1.KY, SS = X1.SS
	FROM #Result R, (
			SELECT Total = SUM(X.Total), ZC = SUM(X.ZC), GZ = SUM(X.GZ), CJ = SUM(X.CJ), KY = SUM(X.KY), SS = SUM(X.SS)
			FROM #ResultSingle X
			WHERE X.Name IN ('��Ѻ', '��Ѻ')
		) X1
	WHERE R.Id = 4




	/* 1.4���ּ����ʽת���� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Balance)
			, ZC = SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
			, GZ = SUM(GZ)
			, CJ = SUM(CJ)
			, KY = SUM(KY)
			, SS = SUM(SS)
		FROM (
				SELECT Balance = P.Balance1
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.Balance1 ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.Balance1 ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN P.Balance1 ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.Balance1 ELSE 0.00 END
				FROM ImportPublic P
					LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND P.PublicType = 1
					AND P.BusinessType LIKE '%����%'
			) AS X1
		) AS X
	WHERE R.Id = 5

	/* 1.2��֤���� */
	UPDATE R SET Total = R1.Total - R2.Total
		, ZC = R1.ZC - R2.ZC
		, GZ = R1.GZ - R2.GZ
		, CJ = R1.CJ - R2.CJ
		, KY = R1.KY - R2.KY
		, SS = R1.SS - R2.SS
	FROM #Result R
		, (SELECT * FROM #Result WHERE Id IN (1)) R1
		, (
			SELECT Total = ISNULL(SUM(Total), 0)
				, ZC = ISNULL(SUM(ZC), 0)
				, GZ = ISNULL(SUM(GZ), 0)
				, CJ = ISNULL(SUM(CJ), 0)
				, KY = ISNULL(SUM(KY), 0)
				, SS = ISNULL(SUM(SS), 0)
			FROM #Result WHERE Id IN (2, 4, 5)
		) R2
	WHERE R.Id = 3

	/* 2.������������� */

	DELETE FROM #ResultSingle

	INSERT INTO #ResultSingle(Name, Total, ZC, GZ, CJ, KY, SS)
	SELECT DaysLevel
		, Total = SUM(Balance)
		, ZC = SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
		, GZ = SUM(GZ)
		, CJ = SUM(CJ)
		, KY = SUM(KY)
		, SS = SUM(SS)
	FROM (
		SELECT DaysLevel =
				CASE
					WHEN OverdueDays <= 0 AND OweInterestDays <= 0 THEN '0'
					WHEN OverdueDays <= 90 AND OweInterestDays <= 90 THEN '1-90'
					WHEN OverdueDays <= 360 AND OweInterestDays <= 360 THEN '91-360'
					ELSE '361+'
				END
			, Balance, GZ, CJ, KY, SS
		FROM (
			SELECT OverdueDays = CASE WHEN P.LoanEndDate < @asOfDate AND P.Balance1 > 0 THEN DATEDIFF(day, P.LoanEndDate, @asOfDate) ELSE 0 END
				, OweInterestDays = P.OweInterestDays
				, Balance = P.Balance1
				, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.Balance1 ELSE 0.00 END
				, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.Balance1 ELSE 0.00 END
				, KY = CASE WHEN L.DangerLevel = '����' THEN P.Balance1 ELSE 0.00 END
				, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.Balance1 ELSE 0.00 END
			FROM ImportPublic P
				LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
				LEFT JOIN DanBaoFangShi D ON D.Name = P.VouchTypeName
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND P.PublicType = 1
			UNION ALL
			SELECT OverdueDays = CASE WHEN P.ContractStartDate < @asOfDate AND P.LoanBalance > 0 THEN DATEDIFF(day, P.ContractEndDate, @asOfDate) ELSE 0 END
				, OweInterestDays = P.InterestOverdueDays
				, Balance = P.LoanBalance
				, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.LoanBalance ELSE 0.00 END
				, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.LoanBalance ELSE 0.00 END
				, KY = CASE WHEN L.DangerLevel = '����' THEN P.LoanBalance ELSE 0.00 END
				, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.LoanBalance ELSE 0.00 END
			FROM ImportPrivate P
				LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
				LEFT JOIN DanBaoFangShi D ON D.Name = DanBaoFangShi
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
		) AS X
	) AS X
	GROUP BY DaysLevel

	/* 2.1����90������ */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.Id = 6 AND X.Name = '1-90'

	/* 2.2����91�쵽360�� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.Id = 7 AND X.Name = '91-360'

	/* 2.3����361������ */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.Id = 8 AND X.Name = '361+'
	
	/* 3.1��˾����� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, (
		SELECT Total = ISNULL(dbo.sfGetLoanBalance(@asOfDate, 1)/10000, 0)
			, ZC = ISNULL(dbo.sfGetLoanBalance(@asOfDate, 1)/10000, 0) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
			, GZ = SUM(GZ)
			, CJ = SUM(CJ)
			, KY = SUM(KY)
			, SS = SUM(SS)
		FROM (
				SELECT Balance = P.Balance1
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.Balance1 ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.Balance1 ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN P.Balance1 ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.Balance1 ELSE 0.00 END
				FROM ImportPublic P
					LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND P.PublicType = 1
			) AS X1
		) AS X
	WHERE R.Id = 9

	/* 3.1��˾����� - ���У����ز��������� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Balance)
			, ZC = SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
			, GZ = SUM(GZ)
			, CJ = SUM(CJ)
			, KY = SUM(KY)
			, SS = SUM(SS)
		FROM (
				SELECT Balance = P.Balance1
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.Balance1 ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.Balance1 ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN P.Balance1 ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.Balance1 ELSE 0.00 END
				FROM ImportPublic P
					LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND P.PublicType = 1
					--AND P.BusinessType = '���ز���������'
					AND P.IndustryType1 = '���ز�ҵ'
			) AS X1
		) AS X
	WHERE R.Id = 10
	
	/* 3.2���˾�Ӫ�Դ��� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Balance)
			, ZC = SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
			, GZ = SUM(GZ)
			, CJ = SUM(CJ)
			, KY = SUM(KY)
			, SS = SUM(SS)
		FROM (
				SELECT Balance = P.LoanBalance
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.LoanBalance ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.LoanBalance ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN P.LoanBalance ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.LoanBalance ELSE 0.00 END
				FROM ImportPrivate P
					LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
					AND P.ProductName IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
			) AS X1
		) AS X
	WHERE R.Id = 11
	
	/* 3.3���˹������� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Balance)
			, ZC = SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
			, GZ = SUM(GZ)
			, CJ = SUM(CJ)
			, KY = SUM(KY)
			, SS = SUM(SS)
		FROM (
				SELECT Balance = P.LoanBalance
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.LoanBalance ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.LoanBalance ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN P.LoanBalance ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.LoanBalance ELSE 0.00 END
				FROM ImportPrivate P
					LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
					AND P.ProductName LIKE '%��%'
			) AS X1
		) AS X
	WHERE R.Id = 12
	
	/* 3.4������������ */
	UPDATE R SET Total = X.Total - ISNULL(R1.Total, 0) - ISNULL(R2.Total, 0)
		, ZC = X.ZC - ISNULL(R1.ZC, 0) - ISNULL(R2.ZC, 0)
		, GZ = X.GZ - ISNULL(R1.GZ, 0) - ISNULL(R2.GZ, 0)
		, CJ = X.CJ - ISNULL(R1.CJ, 0) - ISNULL(R2.CJ, 0)
		, KY = X.KY - ISNULL(R1.KY, 0) - ISNULL(R2.KY, 0)
		, SS = X.SS - ISNULL(R1.SS, 0) - ISNULL(R2.SS, 0)
	FROM #Result R
		, (SELECT * FROM #Result WHERE Id = 11) AS R1
		, (SELECT * FROM #Result WHERE Id = 12) AS R2
		, (
			SELECT Total = ISNULL(dbo.sfGetLoanBalance(@asOfDate, 2)/10000, 0)
				, ZC = ISNULL(dbo.sfGetLoanBalance(@asOfDate, 2)/10000, 0) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
				, GZ = SUM(GZ)
				, CJ = SUM(CJ)
				, KY = SUM(KY)
				, SS = SUM(SS)
			FROM (
					SELECT Balance = P.LoanBalance
						, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN P.LoanBalance ELSE 0.00 END
						, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN P.LoanBalance ELSE 0.00 END
						, KY = CASE WHEN L.DangerLevel = '����' THEN P.LoanBalance ELSE 0.00 END
						, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN P.LoanBalance ELSE 0.00 END
					FROM ImportPrivate P
						LEFT JOIN ImportLoanView L ON L.LoanAccount = P.LoanAccount AND L.ImportId = P.ImportId
					WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
				) AS X1
			) AS X
	WHERE R.Id = 13

	UPDATE #Result
	SET Total = ISNULL(Total, 0)
		, ZC = ISNULL(ZC, 0)
		, GZ = ISNULL(GZ, 0)
		, CJ = ISNULL(CJ, 0)
		, KY = ISNULL(KY, 0)
		, SS = ISNULL(SS, 0)
	
	SELECT * FROM #Result ORDER BY Id

	DROP TABLE #Result
	DROP TABLE #ResultSingle

END

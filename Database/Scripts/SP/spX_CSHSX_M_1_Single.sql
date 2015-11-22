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
		Total decimal(15, 2),
		ZC decimal(15, 2),
		GZ decimal(15, 2),
		CJ decimal(15, 2),
		KY decimal(15, 2),
		SS decimal(15, 2)
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
		Total decimal(15, 2),
		ZC decimal(15, 2),
		GZ decimal(15, 2),
		CJ decimal(15, 2),
		KY decimal(15, 2),
		SS decimal(15, 2)
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
			, Balance = L.CapitalAmount
			, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
			, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
			, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
			, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
		FROM ImportLoan L
			LEFT JOIN ImportPublic  PB ON L.LoanAccount = PB.LoanAccount AND PB.ImportId = L.ImportId
			LEFT JOIN ImportPrivate PV ON L.LoanAccount = PV.LoanAccount AND PV.ImportId = L.ImportId
			LEFT JOIN DanBaoFangShi D  ON D.Name = ISNULL(PV.DanBaoFangShi, PB.VouchTypeName)		
		WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
	) AS X
	GROUP BY DanBao

	/* ����ϼ� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, (
		SELECT Total = SUM(Total), ZC = SUM(ZC), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS) FROM #ResultSingle
	) AS X
	WHERE R.Id = 1

	/* 1.���������ʽ */

	/* 1.1���ô��� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.Id = 2 AND X.Name = '����'

	/* 1.3�֣��ʣ�Ѻ���� */
	UPDATE R SET Total = X.Total, ZC = X.ZC, GZ = X.GZ, CJ = X.CJ, KY = X.KY, SS = X.SS
	FROM #Result R, #ResultSingle X
	WHERE R.Id = 4 AND X.Name IN ('��Ѻ', '��Ѻ')


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
				SELECT Balance = L.CapitalAmount
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
					LEFT JOIN ImportPublic  PB ON L.LoanAccount = PB.LoanAccount AND PB.ImportId = L.ImportId
				WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
					AND PB.PublicType = 1 AND PB.BusinessType LIKE '%����%'
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
					WHEN OverdueDays <=   0 AND OweInterestDays <=   0 THEN '0'
					WHEN OverdueDays <=  90 AND OweInterestDays <=  90 THEN '1-90'
					WHEN OverdueDays <= 360 AND OweInterestDays <= 360 THEN '91-360'
					ELSE '361+'
				END
			, Balance, GZ, CJ, KY, SS
		FROM (
			SELECT OverdueDays = CASE WHEN L.LoanEndDate < @asOfDate AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END
				, OweInterestDays = ISNULL(PV.InterestOverdueDays, PB.OweInterestDays)
				, Balance = L.CapitalAmount
				, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
				, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
				, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
				, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
			FROM ImportLoan L
				LEFT JOIN ImportPublic  PB ON L.LoanAccount = PB.LoanAccount AND PB.ImportId = L.ImportId
				LEFT JOIN ImportPrivate PV ON L.LoanAccount = PV.LoanAccount AND PV.ImportId = L.ImportId
				LEFT JOIN DanBaoFangShi D  ON D.Name = ISNULL(PV.DanBaoFangShi, PB.VouchTypeName)		
			WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
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
		SELECT Total = SUM(Balance)
			, ZC = SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
			, GZ = SUM(GZ)
			, CJ = SUM(CJ)
			, KY = SUM(KY)
			, SS = SUM(SS)
		FROM (
				SELECT Balance = L.CapitalAmount
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
				WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
					AND L.CustomerType = '�Թ�'
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
				SELECT Balance = L.CapitalAmount
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
					INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND P.ImportId = L.ImportId
				WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
					AND L.CustomerType = '�Թ�'
					AND P.BusinessType = '���ز���������'
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
				SELECT Balance = L.CapitalAmount
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
					INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = L.ImportId
				WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
					AND L.CustomerType = '��˽'
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
				SELECT Balance = L.CapitalAmount
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
				FROM ImportLoan L
					INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = L.ImportId
				WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
					AND L.CustomerType = '��˽'
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
			SELECT Total = SUM(Balance)
				, ZC = SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)
				, GZ = SUM(GZ)
				, CJ = SUM(CJ)
				, KY = SUM(KY)
				, SS = SUM(SS)
			FROM (
					SELECT Balance = L.CapitalAmount
						, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
						, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
						, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
						, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
					FROM ImportLoan L
					WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
						AND L.CustomerType = '��˽'
				) AS X1
			) AS X
	WHERE R.Id = 13

	UPDATE #Result
	SET Total = ISNULL(Total, 0)/10000
		, ZC = ISNULL(ZC, 0)/10000
		, GZ = ISNULL(GZ, 0)/10000
		, CJ = ISNULL(CJ, 0)/10000
		, KY = ISNULL(KY, 0)/10000
		, SS = ISNULL(SS, 0)/10000
	
	SELECT * FROM #Result ORDER BY Id

	DROP TABLE #Result
	DROP TABLE #ResultSingle

END

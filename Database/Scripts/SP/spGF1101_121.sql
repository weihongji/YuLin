IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF1101_121') BEGIN
	DROP PROCEDURE spGF1101_121
END
GO

CREATE PROCEDURE spGF1101_121
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT Id, Name AS Direction
		, CAST(ROUND(ISNULL(ZC, 0), 2) AS decimal(10, 2)) AS ZC
		, CAST(ROUND(ISNULL(GZ, 0), 2) AS decimal(10, 2)) AS GZ
		, CAST(ROUND(ISNULL(CJ, 0), 2) AS decimal(10, 2)) AS CJ
		, CAST(ROUND(ISNULL(KY, 0), 2) AS decimal(10, 2)) AS KY
		, CAST(ROUND(ISNULL(SS, 0), 2) AS decimal(10, 2)) AS SS
	FROM (
			SELECT D.Id, D.Name, B.ZC, B.GZ, B.CJ, B.KY, B.SS FROM Direction D
				LEFT JOIN (
					SELECT Direction1
						, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
						, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
					FROM (
						SELECT Direction1, Balance1 AS Balance
							, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN Balance1 ELSE 0.00 END
							, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN Balance1 ELSE 0.00 END
							, KY = CASE WHEN L.DangerLevel = '����' THEN Balance1 ELSE 0.00 END
							, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN Balance1 ELSE 0.00 END
						FROM ImportPublic P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
						WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%��ľ%' AND P.OrgName2 NOT LIKE '%����%'
						UNION ALL
						SELECT Direction1, LoanBalance AS Balance
							, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN LoanBalance ELSE 0.00 END
							, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN LoanBalance ELSE 0.00 END
							, KY = CASE WHEN L.DangerLevel = '����' THEN LoanBalance ELSE 0.00 END
							, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN LoanBalance ELSE 0.00 END
						FROM ImportPrivate P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
						WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%��ľ%' AND P.OrgName2 NOT LIKE '%����%'
							AND P.ProductName IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
					) AS X
					GROUP BY Direction1
				) AS B ON D.Name = B.Direction1
			WHERE D.Id <= 20

			UNION ALL
			SELECT 101 AS Id, '���ÿ�' AS Name
				, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
				, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
			FROM (
				SELECT LoanBalance AS Balance
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN LoanBalance ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN LoanBalance ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN LoanBalance ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN LoanBalance ELSE 0.00 END
				FROM ImportPrivate P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
				WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%��ľ%' AND P.OrgName2 NOT LIKE '%����%'
					AND P.ProductName LIKE '%����%'
			) AS X

			UNION ALL
			SELECT 102 AS Id, '����' AS Name
				, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
				, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
			FROM (
				SELECT LoanBalance AS Balance
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN LoanBalance ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN LoanBalance ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN LoanBalance ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN LoanBalance ELSE 0.00 END
				FROM ImportPrivate P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
				WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%��ľ%' AND P.OrgName2 NOT LIKE '%����%'
					AND P.ProductName LIKE '%����%'
			) AS X

			UNION ALL
			SELECT 103 AS Id, 'ס�����Ҵ���' AS Name
				, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
				, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
			FROM (
				SELECT LoanBalance AS Balance
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN LoanBalance ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN LoanBalance ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN LoanBalance ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN LoanBalance ELSE 0.00 END
				FROM ImportPrivate P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
				WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%��ľ%' AND P.OrgName2 NOT LIKE '%����%'
					AND P.ProductName LIKE '%ס��%'
			) AS X

			UNION ALL
			SELECT 104 AS Id, '����' AS Name
				, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
				, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
			FROM (
				SELECT LoanBalance AS Balance
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN LoanBalance ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN LoanBalance ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN LoanBalance ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN LoanBalance ELSE 0.00 END
				FROM ImportPrivate P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
				WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%��ľ%' AND P.OrgName2 NOT LIKE '%����%'
					AND P.ProductName NOT IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
					AND P.ProductName NOT LIKE '%����%'
					AND P.ProductName NOT LIKE '%����%'
					AND P.ProductName NOT LIKE '%ס��%'
			) AS X

			UNION ALL
			SELECT 105 AS Id, '���ʽת����' AS Name
				, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
				, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
			FROM (
					SELECT Balance1 AS Balance
							, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN Balance1 ELSE 0.00 END
							, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN Balance1 ELSE 0.00 END
							, KY = CASE WHEN L.DangerLevel = '����' THEN Balance1 ELSE 0.00 END
							, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN Balance1 ELSE 0.00 END
					FROM ImportPublic P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
					WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%��ľ%' AND P.OrgName2 NOT LIKE '%����%'
						AND P.BusinessType LIKE '%ת����%'
				) AS X1

			UNION ALL
			SELECT 106 AS Id, '���˾�Ӫ�Դ���' AS Name
				, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
				, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
			FROM (
				SELECT LoanBalance AS Balance
					, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN LoanBalance ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN LoanBalance ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '����' THEN LoanBalance ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN LoanBalance ELSE 0.00 END
				FROM ImportPrivate P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
				WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%��ľ%' AND P.OrgName2 NOT LIKE '%����%'
					AND P.ProductName IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
			) AS X

			/* 4.���ڴ��� */
			UNION ALL
			SELECT Id = CASE
						WHEN DaysLevel = '30������'     THEN 111
						WHEN DaysLevel = '31��90��'     THEN 112
						WHEN DaysLevel = '91�쵽180��'  THEN 113
						WHEN DaysLevel = '181�쵽270��' THEN 114
						WHEN DaysLevel = '271�쵽360��' THEN 115
						ELSE 116
					END
				, Name = DaysLevel
				, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS))/10000 AS ZC
				, SUM(GZ)/10000 AS GZ, SUM(CJ)/10000 AS CJ, SUM(KY)/10000 AS KY, SUM(SS)/10000 AS SS
			FROM (
					SELECT Balance, GZ, CJ, KY, SS
						, DaysLevel =
							CASE
								WHEN FinalDays <= 30  THEN '30������'
								WHEN FinalDays <= 90  THEN '31��90��'
								WHEN FinalDays <= 180 THEN '91�쵽180��'
								WHEN FinalDays <= 270 THEN '181�쵽270��'
								WHEN FinalDays <= 360 THEN '271�쵽360��'
								ELSE '361������'
							END
					FROM (
							SELECT Balance, GZ, CJ, KY, SS, FinalDays = ISNULL(CASE WHEN OverdueDays >= OweInterestDays THEN OverdueDays ELSE OweInterestDays END, 0)
							FROM (
									SELECT L.CapitalAmount AS Balance
										, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN L.CapitalAmount ELSE 0.00 END
										, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN L.CapitalAmount ELSE 0.00 END
										, KY = CASE WHEN L.DangerLevel = '����' THEN L.CapitalAmount ELSE 0.00 END
										, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN L.CapitalAmount ELSE 0.00 END
										, OverdueDays = CASE WHEN L.LoanEndDate < @asOfDate AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END
										, OweInterestDays = ISNULL(CASE WHEN L.CustomerType = '��˽' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END, 0)
									FROM ImportLoan L
										LEFT JOIN ImportPrivate PV ON PV.LoanAccount = L.LoanAccount AND PV.ImportId = L.ImportId
										LEFT JOIN ImportPublic PB ON PB.LoanAccount = L.LoanAccount AND PB.ImportId = L.ImportId
									WHERE L.ImportId = @importId
										AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
								) AS X1
						) AS X2
					WHERE FinalDays > 0
				) AS X3
			GROUP BY DaysLevel

		) AS Final
	ORDER BY Id

END

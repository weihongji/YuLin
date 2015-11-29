IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF0107_141') BEGIN
	DROP PROCEDURE spGF0107_141
END
GO

CREATE PROCEDURE spGF0107_141
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT Id, Name AS Direction, CAST(ROUND(ISNULL(Balance, 0), 2) AS money) AS Balance
	FROM (
			SELECT D.Id, D.Name, B.Balance FROM Direction D
				LEFT JOIN (
					SELECT Direction1, SUM(Balance) AS Balance FROM (
						SELECT Direction1, SUM(Balance1) AS Balance FROM ImportPublic
						WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%'
						GROUP BY Direction1
						UNION ALL
						SELECT Direction1, SUM(LoanBalance) AS Balance FROM ImportPrivate
						WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%'
							AND ProductName IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
						GROUP BY Direction1
					) AS X
					GROUP BY Direction1
				) AS B ON D.Name = B.Direction1
			WHERE D.Id <= 20
			UNION ALL
			SELECT 101 AS Id, '���ÿ�' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%'
				AND ProductName LIKE '%����%'
			UNION ALL
			SELECT 102 AS Id, '����' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%'
				AND ProductName LIKE '%����%'
			UNION ALL
			SELECT 103 AS Id, 'ס�����Ҵ���' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%'
				AND ProductName LIKE '%ס��%'
			UNION ALL
			SELECT 104 AS Id, '����' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%'
				AND ProductName NOT IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
				AND ProductName NOT LIKE '%����%'
				AND ProductName NOT LIKE '%����%'
				AND ProductName NOT LIKE '%ס��%'
			UNION ALL
			SELECT 105 AS Id, '���˾�Ӫ�Դ���' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%'
				AND ProductName IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
		) AS Final
	ORDER BY Id
END


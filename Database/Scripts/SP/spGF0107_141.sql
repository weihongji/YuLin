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
						WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
						GROUP BY Direction1
						UNION ALL
						SELECT Direction1, SUM(LoanBalance) AS Balance FROM ImportPrivate
						WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
							AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
						GROUP BY Direction1
					) AS X
					GROUP BY Direction1
				) AS B ON D.Name = B.Direction1
			WHERE D.Id <= 20
			UNION ALL
			SELECT 101 AS Id, '信用卡' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
				AND ProductName LIKE '%公务卡%'
			UNION ALL
			SELECT 102 AS Id, '汽车' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
				AND ProductName LIKE '%汽车%'
			UNION ALL
			SELECT 103 AS Id, '住房按揭贷款' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
				AND ProductName LIKE '%住房%'
			UNION ALL
			SELECT 104 AS Id, '其他' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
				AND ProductName NOT IN ('个人经营贷款', '个人质押贷款(经营类)')
				AND ProductName NOT LIKE '%公务卡%'
				AND ProductName NOT LIKE '%汽车%'
				AND ProductName NOT LIKE '%住房%'
			UNION ALL
			SELECT 105 AS Id, '个人经营性贷款' AS Name, SUM(LoanBalance) AS Balance FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
				AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
		) AS Final
	ORDER BY Id
END


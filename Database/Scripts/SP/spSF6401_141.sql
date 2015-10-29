IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spSF6401_141') BEGIN
	DROP PROCEDURE spSF6401_141
END
GO

CREATE PROCEDURE spSF6401_141
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	DECLARE @yearStart as smalldatetime, @yearEnd as smalldatetime
	SET @yearStart = CONVERT(varchar(4), @asOfDate, 112) + '0101'
	SET @yearEnd = CONVERT(varchar(4), @asOfDate, 112) + '1231'

	SELECT Id, Name AS Direction
		, CAST(ROUND(ISNULL(Balance1, 0), 2) AS decimal(10, 2)) AS Balance1
		, CAST(ROUND(ISNULL(Balance2, 0), 2) AS decimal(10, 2)) AS Balance2
		, CAST(ROUND(ISNULL(Balance3, 0), 2) AS decimal(10, 2)) AS Balance3
		, CAST(ROUND(ISNULL(Balance4, 0), 2) AS decimal(10, 2)) AS Balance4
		, CAST(ROUND(ISNULL(Balance5, 0), 2) AS decimal(10, 2)) AS Balance5
		, CAST(ROUND(ISNULL(Balance6, 0), 2) AS decimal(10, 2)) AS Balance6
	FROM (
			SELECT D.Id, D.Name, B.Balance1, B.Balance2, B.Balance3, B.Balance4, B.Balance5, B.Balance6
			FROM Direction D
				LEFT JOIN (
					SELECT Direction1, SUM(Balance1) AS Balance1, SUM(Balance2) AS Balance2, SUM(Balance3) AS Balance3, SUM(Balance4) AS Balance4, SUM(Balance5) AS Balance5, SUM(Balance6) AS Balance6
					FROM (
							SELECT Direction1
								, Balance1 = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
								, Balance2 = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
								, Balance3 = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
								, Balance4 = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
								, Balance5 = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1<=5000000 THEN Balance1 ELSE 0.00 END
								, Balance6 = 0.00
							FROM ImportPublic
							WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
							UNION ALL
							SELECT Direction1
								, Balance1 = 0.00, Balance2 = 0.00, Balance3 = 0.00, Balance4 = 0.00, Balance5 = 0.00
								, LoanBalance AS Balance6
							FROM ImportPrivate
							WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
								AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
						) AS X
					GROUP BY Direction1
				) AS B ON D.Name = B.Direction1
			WHERE D.Id <= 20
			UNION ALL
			SELECT 101 AS Id, '贷款当年累计发放额' AS Name, Balance1 = SUM(Balance1), Balance2 = SUM(Balance2), Balance3 = SUM(Balance3), Balance4 = SUM(Balance4), Balance5 = SUM(Balance5), Balance6 = SUM(Balance6)
			FROM (
					SELECT Balance1 = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
						, Balance2 = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
						, Balance3 = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
						, Balance4 = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
						, Balance5 = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1<=5000000 THEN Balance1 ELSE 0.00 END
						, Balance6 = 0.00
					FROM ImportPublic
					WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
						AND LoanStartDate BETWEEN @yearStart AND @yearEnd
					UNION
					SELECT Balance1 = 0.00, Balance2 = 0.00, Balance3 = 0.00, Balance4 = 0.00, Balance5 = 0.00, LoanBalance AS Balance6
					FROM ImportPrivate
					WHERE ImportId = @importId AND OrgName2 NOT LIKE '%神木%' AND OrgName2 NOT LIKE '%府谷%'
						AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
						AND ContractStartDate BETWEEN @yearStart AND @yearEnd
				) AS X
		) AS Final
	ORDER BY Id
END


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spSF6401_141_Count') BEGIN
	DROP PROCEDURE spSF6401_141_Count
END
GO

CREATE PROCEDURE spSF6401_141_Count
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	DECLARE @yearStart as smalldatetime, @yearEnd as smalldatetime
	SET @yearStart = CONVERT(varchar(4), @asOfDate, 112) + '0101'
	SET @yearEnd = CONVERT(varchar(4), @asOfDate, 112) + '1231'

	SELECT SUM(Count1) AS Count1, SUM(Count2) AS Count2, SUM(Count3) AS Count3, SUM(Count4) AS Count4, SUM(Count5) AS Count5, SUM(Count6) AS Count6
	FROM (
			SELECT Count1 = CASE WHEN MAX(ScopeName) = '大型企业' THEN 1 ELSE 0 END
				, Count2 = CASE WHEN MAX(ScopeName) = '中型企业' THEN 1 ELSE 0 END
				, Count3 = CASE WHEN MAX(ScopeName) = '小型企业' THEN 1 ELSE 0 END
				, Count4 = CASE WHEN MAX(ScopeName) = '微型企业' THEN 1 ELSE 0 END
				, Count5 = CASE WHEN MAX(ScopeName) IN ('小型企业', '微型企业') AND MAX(Balance1)<=5000000 THEN 1 ELSE 0 END
				, Count6 = 0
			FROM ImportPublic
			WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 2)
				AND LoanStartDate BETWEEN @yearStart AND @yearEnd
			GROUP BY CustomerName
			UNION ALL
			SELECT Count1 = 0, Count2 = 0, Count3 = 0, Count4 = 0, Count5 = 0, 1 AS Count6
			FROM ImportPrivate
			WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 3)
				AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
				AND ContractStartDate BETWEEN @yearStart AND @yearEnd
			GROUP BY CustomerName, IdCardNo
		) AS X
END


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF0102_081') BEGIN
	DROP PROCEDURE spGF0102_081
END
GO

CREATE PROCEDURE spGF0102_081
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	DECLARE @total as decimal(15, 2)

	SELECT @total = CAST(ROUND(SUM(CurrentDebitBalance)/10000, 2) AS decimal(10, 2)) FROM ImportYWNei
	WHERE ImportId = @importId
		AND SubjectCode BETWEEN '1301' AND '1382'

	
	SELECT DangerLevel, CAST(ROUND(SUM(CapitalAmount)/10000, 2) AS decimal(10, 2)) as Amount INTO #Result FROM ImportLoan
	WHERE ImportId = @importId
	GROUP BY DangerLevel

	SELECT Total = @total
		, GuanZhu = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel LIKE '关%')
		, CiJi    = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '次级')
		, KeYi    = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '可疑')
		, SunShi  = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '损失')

	DROP TABLE #Result
END

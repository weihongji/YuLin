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

	DECLARE @total as money

	SELECT @total = CAST(ROUND(SUM(CurrentDebitBalance)/10000, 2) AS money) FROM ImportYWNei
	WHERE ImportId = @importId
		AND SubjectCode BETWEEN '1301' AND '1382'

	
	SELECT DangerLevel, CAST(ROUND(SUM(CapitalAmount)/10000, 2) AS money) as Amount INTO #Result FROM ImportLoan
	WHERE ImportId = @importId
		AND OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%��ľ%' OR Name LIKE '%����%')
	GROUP BY DangerLevel

	SELECT Total = @total
		, GuanZhu = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel LIKE '��%')
		, CiJi    = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '�μ�')
		, KeYi    = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '����')
		, SunShi  = (SELECT SUM(Amount) FROM #Result WHERE DangerLevel = '��ʧ')

	DROP TABLE #Result
END

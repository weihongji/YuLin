IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_CSHSX_M_2') BEGIN
	DROP PROCEDURE spX_CSHSX_M_2
END
GO

CREATE PROCEDURE spX_CSHSX_M_2
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20151031'

	DECLARE @asOfDateLastMonth as smalldatetime = @asOfDate - DAY(@asOfDate) -- Last day of previous month
	
	DECLARE @importId int
	DECLARE @importIdLastMonth int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate
	SELECT @importIdLastMonth = Id FROM Import WHERE ImportDate = @asOfDateLastMonth
	
	IF OBJECT_ID('tempdb..#Top20') IS NOT NULL BEGIN
		DROP TABLE #Top20
	END

	SELECT TOP 20 Id = MAX(Id), CustomerName, TotalBalance = CAST(SUM(CapitalAmount)/10000 AS money)
	INTO #Top20
	FROM ImportLoan L
	WHERE ImportId = @importId
		AND OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
		AND CustomerType = '对公'
		AND EXISTS(SELECT * FROM ImportPublic P WHERE P.LoanAccount = L.LoanAccount AND P.ImportId = @importId) --Exclude 陕西恒盛塬实业集团有限公司
	GROUP BY CustomerName
	ORDER BY TotalBalance DESC

	SELECT P.OrgName2, T.CustomerName, D.Name AS Direction, P.IsINRZ, LoanAmount = CAST(L.LoanAmount/10000 AS money), T.TotalBalance, P.BusinessType, L.LoanStartDate, L.LoanEndDate, P.VouchTypeName, L.DangerLevel, DangerLevelLM = LM.DangerLevel
	FROM #Top20 T
		INNER JOIN ImportLoan L ON T.Id = L.Id
		INNER JOIN ImportPublic P ON P.LoanAccount = L.LoanAccount AND P.ImportId = @importId
		LEFT JOIN ImportLoan LM ON LM.ImportId = @importIdLastMonth AND LM.LoanAccount = L.LoanAccount
		LEFT JOIN Direction D ON D.Name = P.Direction1
	ORDER BY T.TotalBalance DESC

	DROP TABLE #Top20
END

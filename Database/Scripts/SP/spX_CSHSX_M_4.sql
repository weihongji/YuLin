IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_CSHSX_M_4') BEGIN
	DROP PROCEDURE spX_CSHSX_M_4
END
GO

CREATE PROCEDURE spX_CSHSX_M_4
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

	SELECT TOP 20 P.OrgName2, P.CustomerName, D.Name AS Direction, LoanAmount = CAST(P.LoanBalance AS money), LoanBalance = CAST(P.LoanBalance AS money), P.ProductName, L.LoanStartDate, L.LoanEndDate, P.DanBaoFangShi, L.DangerLevel, DangerLevelLM = LM.DangerLevel
	FROM ImportLoan L
		INNER JOIN ImportPrivate P ON P.LoanAccount = L.LoanAccount AND P.ImportId = @importId
		LEFT JOIN ImportLoan LM ON LM.ImportId = @importIdLastMonth AND LM.LoanAccount = L.LoanAccount
		LEFT JOIN Direction D ON D.Name = P.Direction1
	WHERE L.ImportId = @importId
		AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%ÉñÄ¾%' OR Name LIKE '%¸®¹È%')
		AND L.CustomerType = '¶ÔË½'
	ORDER BY P.LoanBalance DESC

END

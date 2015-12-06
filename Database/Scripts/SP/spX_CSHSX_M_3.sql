IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_CSHSX_M_3') BEGIN
	DROP PROCEDURE spX_CSHSX_M_3
END
GO

CREATE PROCEDURE spX_CSHSX_M_3
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20151031'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT ROW_NUMBER() OVER(ORDER BY L.Id) AS [Index],  P.OrgName2, L.CustomerName, D.Name AS Direction, P.IsINRZ
		, LoanAmount = CAST(L.LoanAmount/10000 AS money)
		, CapitalAmount = CAST(L.CapitalAmount/10000 AS money)
		, P.BusinessType
		, LoanDates = CONVERT(varchar(10), L.LoanStartDate, 120) + '|' + CONVERT(varchar(10), L.LoanEndDate, 120)
		, P.VouchTypeName
		, IsYuQi = CASE WHEN LoanState IN ('逾期', '部分逾期') THEN '是' ELSE '否' END
		, OverdueDays = CASE WHEN L.LoanEndDate < @asOfDate AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END
		, OweCapital = CAST(L.OweCapital/10000 AS money)
		, OweInterestAmount = CAST((L.OweYingShouInterest + L.OweCuiShouInterest)/10000 AS money)
		, L.DangerLevel
	FROM ImportLoan L
		INNER JOIN ImportPublic P ON P.LoanAccount = L.LoanAccount AND P.ImportId = @importId
		LEFT JOIN Direction D ON D.Name = P.Direction1
	WHERE L.ImportId = @importId
		AND L.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
		AND CustomerType = '对公'
		AND DangerLevel IN ('次级', '可疑', '损失')
	ORDER BY L.Id

END

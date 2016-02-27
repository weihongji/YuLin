IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_FXDKTB_D') BEGIN
	DROP PROCEDURE spX_FXDKTB_D
END
GO

CREATE PROCEDURE spX_FXDKTB_D
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @orgId7777 int = (SELECT Id FROM Org WHERE OrgNo = '806057777')

	DECLARE @asOfDateYesterday as smalldatetime
	SELECT @asOfDateYesterday = MAX(ImportDate) FROM Import WHERE ImportDate < @asOfDate

	IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'Shell_LoanRisk') BEGIN
		EXEC spLoanRiskDaily '19000101'
	END

	SELECT * INTO #ResultToday     FROM Shell_LoanRisk WHERE 1=2
	SELECT * INTO #ResultYesterday FROM Shell_LoanRisk WHERE 1=2
	
	INSERT INTO #ResultToday     EXEC spLoanRiskDaily @asOfDate
	INSERT INTO #ResultYesterday EXEC spLoanRiskDaily @asOfDateYesterday

	SELECT OrgName, Total_Amount
		, YQ_Count, YQ_Amount, YQ_Amount/Total_Amount AS YQ_Percentage
		, BL_Count, BL_Amount, BL_Amount/Total_Amount AS BL_Percentage
		, ZQX_Count, ZQX_Amount, ZQX_Amount/Total_Amount AS ZQX_Percentage
		, Total_Interest
		, FX_Count = YBTotal_Count + ZQX_Count, FX_Amount = YBTotal_Amount + ZQX_Amount, FX_Percentage = (YBTotal_Amount + ZQX_Amount)/Total_Amount
		, FX_Y_Count = ISNULL((SELECT T.YBTotal_Count + T.ZQX_Count - (Y.YBTotal_Count + Y.ZQX_Count) FROM #ResultYesterday Y WHERE Y.OrgId = T.OrgId), 0)
		, FX_Y_Amount = ISNULL((SELECT T.YBTotal_Amount + T.ZQX_Amount - (Y.YBTotal_Amount + Y.ZQX_Amount) FROM #ResultYesterday Y WHERE Y.OrgId = T.OrgId), 0)
		, FX_Y_Percentage = ISNULL((SELECT (T.YBTotal_Amount + T.ZQX_Amount)/T.Total_Amount - ((Y.YBTotal_Amount + Y.ZQX_Amount)/Y.Total_Amount) FROM #ResultYesterday Y WHERE Y.OrgId = T.OrgId), 0)
	FROM #ResultToday T
	UNION ALL
	SELECT '清算中心（贴现）', CAST(ROUND(dbo.sfGetLoanBalanceOf(@asOfDate, 1301, @orgId7777)/10000, 2) AS money)
		, 0, 0, 0
		, 0, 0, 0
		, 0, 0, 0
		, 0
		, 0, 0, 0
		, 0, 0, 0

	DROP TABLE #ResultToday
	DROP TABLE #ResultYesterday
END


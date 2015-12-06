IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_FXDKTB_D') BEGIN
	DROP PROCEDURE spX_FXDKTB_D
END
GO

CREATE PROCEDURE spX_FXDKTB_D
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'Shell_LoanRisk') BEGIN
		EXEC spLoanRiskDaily '19000101'
	END
	SELECT * INTO #Result FROM Shell_LoanRisk WHERE 1=2
	INSERT INTO #Result EXEC spLoanRiskDaily @asOfDate

	SELECT OrgName, Total_Amount
		, YQ_Count, YQ_Amount, YQ_Amount/Total_Amount AS YQ_Percentage
		, BL_Count, BL_Amount, BL_Amount/Total_Amount AS BL_Percentage
		, ZQX_Count, ZQX_Amount, ZQX_Amount/Total_Amount AS ZQX_Percentage
		, Total_Interest
		, Y_B_Count = YBTotal_Count, Y_B_Amount = YBTotal_Amount, Y_B_Percentage = YBTotal_Amount/Total_Amount
	FROM #Result R
		INNER JOIN Org O ON R.OrgId = O.Id
	ORDER BY O.OrgNo, O.Id

	DROP TABLE #Result
END


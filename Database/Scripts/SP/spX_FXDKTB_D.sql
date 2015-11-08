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
		, BLDK_Count, BLDK_Amount, BLDK_Amount/Total_Amount AS BLDK_Percentage
		, ZQX_Count, ZQX_Amount, ZQX_Amount/Total_Amount AS ZQX_Percentage
		, Total_Interest
		, Y_B_Count = YQ_Count + BLDK_Count, Y_B_Amount = YQ_Amount + BLDK_Amount, Y_B_Percentage = (YQ_Amount + BLDK_Amount)/Total_Amount
	FROM #Result

	DROP TABLE #Result
END


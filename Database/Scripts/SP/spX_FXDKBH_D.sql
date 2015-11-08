IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_FXDKBH_D') BEGIN
	DROP PROCEDURE spX_FXDKBH_D
END
GO

CREATE PROCEDURE spX_FXDKBH_D
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20151104'

	DECLARE @asOfDateYesterday as smalldatetime = @asOfDate - 1
	DECLARE @asOfDateLastMonth as smalldatetime
	IF DAY(@asOfDate + 1) = 1 BEGIN -- Last day of month
		SET @asOfDateLastMonth = @asOfDate - DAY(@asOfDate) -- Last day of previous month
	END
	ELSE BEGIN
		SET @asOfDateLastMonth = DATEADD(MONTH, -1, @asOfDate)
	END

	DECLARE @importIdToday int
	DECLARE @importIdYesterday int
	DECLARE @importIdLastMonth int

	SELECT @importIdToday = Id FROM Import WHERE ImportDate = @asOfDate
	SELECT @importIdYesterday = Id FROM Import WHERE ImportDate = @asOfDateYesterday
	SELECT @importIdLastMonth = Id FROM Import WHERE ImportDate =  @asOfDateLastMonth

	--SELECT @importIdToday AS ImportIdToday, @importIdYesterday AS ImportIdYesterday, @importIdLastMonth AS ImportIdLastMonth
	--SELECT @asOfDate AS [Today], @asOfDateYesterday AS [Yesterday], @asOfDateLastMonth AS [LastMonth]

	IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'Shell_LoanRisk') BEGIN
		EXEC spLoanRiskDaily '19000101'
	END
	SELECT * INTO #ResultToday		FROM Shell_LoanRisk WHERE 1=2
	SELECT * INTO #ResultYesterday	FROM Shell_LoanRisk WHERE 1=2
	SELECT * INTO #ResultLastMonth	FROM Shell_LoanRisk WHERE 1=2

	INSERT INTO #ResultToday		EXEC spLoanRiskDaily @asOfDate
	INSERT INTO #ResultYesterday	EXEC spLoanRiskDaily @asOfDateYesterday
	INSERT INTO #ResultLastMonth	EXEC spLoanRiskDaily @asOfDateLastMonth

	SELECT T.OrgName
		, Total_Amount	  = T.Total_Amount
		, Total_Amount_Y = T.Total_Amount - Y.Total_Amount
		, Total_Amount_M = T.Total_Amount - M.Total_Amount

		-- YQ
		, YQ_Count	= T.YQ_Count
		, YQ_Amount	= T.YQ_Amount
		, YQ_Percentage = T.YQ_Amount/T.Total_Amount

		, YQ_Y_Count	= T.YQ_Count  - Y.YQ_Count
		, YQ_Y_Amount	= T.YQ_Amount - Y.YQ_Amount

		, YQ_M_Count	= T.YQ_Count  - M.YQ_Count
		, YQ_M_Amount	= T.YQ_Amount - M.YQ_Amount

		-- BLDK
		, BLDK_Count	= T.BLDK_Count
		, BLDK_Amount	= T.BLDK_Amount
		, BLDK_Percentage = T.BLDK_Amount/T.Total_Amount

		, BLDK_Y_Count	= T.BLDK_Count  - Y.BLDK_Count
		, BLDK_Y_Amount	= T.BLDK_Amount - Y.BLDK_Amount

		, BLDK_M_Count	= T.BLDK_Count  - M.BLDK_Count
		, BLDK_M_Amount	= T.BLDK_Amount - M.BLDK_Amount

		-- ZQX
		, ZQX_Count	= T.ZQX_Count
		, ZQX_Amount	= T.ZQX_Amount
		, ZQX_Percentage = T.ZQX_Amount/T.Total_Amount

		, ZQX_Y_Count	= T.ZQX_Count  - Y.ZQX_Count
		, ZQX_Y_Amount	= T.ZQX_Amount - Y.ZQX_Amount

		, ZQX_M_Count	= T.ZQX_Count  - M.ZQX_Count
		, ZQX_M_Amount	= T.ZQX_Amount - M.ZQX_Amount

		-- YQ + BLDK
		, YQ_BL_Count	= T.YQ_Count  + T.BLDK_Count
		, YQ_BL_Amount	= T.YQ_Amount + T.BLDK_Amount
		, YQ_BL_Percentage = (T.YQ_Amount + T.BLDK_Amount)/T.Total_Amount

		, YQ_BL_Y_Count	= T.YQ_Count  + T.BLDK_Count   - (Y.YQ_Count  + Y.BLDK_Count)
		, YQ_BL_Y_Amount= T.YQ_Amount + T.BLDK_Amount  - (Y.YQ_Amount + Y.BLDK_Amount)

		, YQ_BL_M_Count	= T.YQ_Count  + T.BLDK_Count   - (M.YQ_Count  + M.BLDK_Count)
		, YQ_BL_M_Amount= T.YQ_Amount + T.BLDK_Amount  - (M.YQ_Amount + M.BLDK_Amount)

		, Total_Interest = T.Total_Interest
		, Total_Interest_Y = T.Total_Interest - Y.Total_Interest
		, Total_Interest_M = T.Total_Interest - M.Total_Interest
	FROM #ResultToday T
		LEFT JOIN #ResultYesterday Y ON Y.OrgNo = T.OrgNo
		LEFT JOIN #ResultLastMonth M ON M.OrgNo = T.OrgNo

	DROP TABLE #ResultToday
	DROP TABLE #ResultYesterday
	DROP TABLE #ResultLastMonth
END

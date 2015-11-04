IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_WJFL_M') BEGIN
	DROP PROCEDURE spX_WJFL_M
END
GO

CREATE PROCEDURE spX_WJFL_M
	@type as varchar(20),
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @type as varchar(20) = 'FYJ'
	--DECLARE @asOfDate smalldatetime = '20151031'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	DECLARE @asOfDatePreviousMonth as smalldatetime
	DECLARE @importIdPreviousMonth int
	SELECT TOP 1 @importIdPreviousMonth = Id, @asOfDatePreviousMonth = ImportDate FROM Import
	WHERE ImportDate <= DATEADD(DAY, -1, CONVERT(varchar(6), @asOfDate, 112) + '01')
	ORDER BY ImportDate DESC

	/* Create temporary table using the empty shell */
	IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'Shell_WJFL') BEGIN
		EXEC spReportLoanRiskPerMonth @type, '19991231'
	END
	IF OBJECT_ID('tempdb..#Result') IS NOT NULL BEGIN
		DROP TABLE #Result
	END
	SELECT * INTO #Result FROM Shell_WJFL WHERE 1=2

	/* Populate temporary table with data of current month and previous month */
	INSERT INTO #Result EXEC spReportLoanRiskPerMonth @type, @asOfDate
	INSERT INTO #Result EXEC spReportLoanRiskPerMonth @type, @asOfDatePreviousMonth

	UPDATE #Result SET IsNew = '��' WHERE ImportId = @importId AND LoanAccount NOT IN (SELECT LoanAccount FROM #Result WHERE ImportId = @importIdPreviousMonth)

	DELETE FROM #Result WHERE ImportId = @importIdPreviousMonth

	/* Choose columns for the type */
	IF @type = 'YQ' BEGIN
		SELECT OrgName, CustomerName, CapitalAmount, OweCapital, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, OweInterestDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, Comment
		FROM #Result
		ORDER BY Id
	END
	ELSE IF @type = 'ZQX' BEGIN
		SELECT OrgName, CustomerName, CapitalAmount, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, OweInterestDays
			, DanBaoFangShi = (SELECT Category FROM DanBaoFangShi WHERE Name = DanBaoFangShi2)
			, Industry, CustomerType, LoanType, IsNew, Comment
		FROM #Result
		ORDER BY Id
	END
	ELSE IF @type = 'F_HYB' BEGIN
		SELECT '���ַ���' AS OrgName
			, OrgName AS OrgName2
			, CustomerName
			, IdCardNo
			, DangerLevel
			, CapitalAmount = CAST(ROUND(CapitalAmount/10000, 2) AS decimal(10, 2))
			, CustomerType
			, LoanType
			, OverdueDays
			, OweInterestDays
			, FinalDays
			, DaysLevel =
					CASE
						WHEN FinalDays <=  0  THEN ''
						WHEN FinalDays <= 30  THEN '30������'
						WHEN FinalDays <= 90  THEN '31��90��'
						WHEN FinalDays <= 180 THEN '91�쵽180��'
						WHEN FinalDays <= 270  THEN '181�쵽270��'
						WHEN FinalDays <= 360  THEN '271�쵽360��'
						ELSE '361������'
					END
			, Direction1
			, Direction2
			, Direction3
			, Direction4
			, DanBaoFangShi
			, IsLongTerm = CASE WHEN LoanType LIKE '%����%' THEN '��' WHEN LoanType LIKE '%�г���%' THEN '��' ELSE '' END
		FROM #Result
		ORDER BY Id
	END
	ELSE BEGIN
		SELECT OrgName, CustomerName, CapitalAmount, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, OweInterestDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, Comment
		FROM #Result ORDER BY Id
	END

	DROP TABLE #Result
END

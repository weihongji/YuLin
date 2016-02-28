IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_WJFLPRD_D') BEGIN
	DROP PROCEDURE spX_WJFLPRD_D
END
GO

CREATE PROCEDURE spX_WJFLPRD_D
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	DECLARE @importIdOfLastMonthEndDay int
	DECLARE @endDayOfLastMonth smalldatetime = @asOfDate - DATEPART(day, @asOfDate)
	DECLARE @endDayOfThisMonth smalldatetime = DATEADD(MONTH, 1, @endDayOfLastMonth + 1) - 1

	--SELECT @endDayOfLastMonth, @asOfDate, @endDayOfThisMonth

	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate
	SELECT @importIdOfLastMonthEndDay = Id FROM Import WHERE ImportDate = @endDayOfLastMonth
	IF NOT EXISTS(SELECT * FROM ImportPublic WHERE ImportId = @importIdOfLastMonthEndDay) OR NOT EXISTS(SELECT * FROM ImportPrivate WHERE ImportId = @importIdOfLastMonthEndDay) BEGIN
		DECLARE @msg varchar(120) = '上个月末(' + CONVERT(varchar(10), @endDayOfLastMonth, 120) + ')的台账还没导入！';
		THROW 50000, @msg, 1
	END

	SELECT OrgName = O.Alias1
		, L.CustomerName
		, L.CapitalAmount
		, OweInterestAmount = L.OweYingShouInterest + L.OweCuiShouInterest
		, L.LoanStartDate
		, L.LoanEndDate
		, OverdueDays = CASE WHEN L.LoanEndDate < @endDayOfThisMonth AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @endDayOfThisMonth) ELSE 0 END
		, OweInterestDays = CASE WHEN L.CustomerType = '对私' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
		, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)
	INTO #Result
	FROM ImportLoan L
		LEFT JOIN Org O ON O.Id = L.OrgId4Report
		LEFT JOIN ImportPrivate PV ON PV.LoanAccount = L.LoanAccount AND PV.ImportId = @importIdOfLastMonthEndDay
		LEFT JOIN ImportPublic PB ON PB.LoanAccount = L.LoanAccount AND PB.ImportId = @importIdOfLastMonthEndDay
	WHERE L.ImportId = @importId
			AND (
				L.LoanState IN ('非应计', '逾期', '部分逾期')
				OR (L.LoanState = '正常' AND L.OweYingShouInterest + L.OweCuiShouInterest != 0)
			)

	UPDATE #Result SET OweInterestDays = OweInterestDays + DATEPART(DAY, @endDayOfThisMonth) WHERE OweInterestDays > 0 --只有上月台帐显示有欠息的才计算本月末的欠息天数

	UPDATE #Result SET OverdueDays = OweInterestDays WHERE OverdueDays = 0 AND OweInterestDays > 0 AND CustomerType LIKE '%房%'
	UPDATE #Result SET CustomerType =
			CASE
				WHEN CustomerType LIKE '%房%'   THEN '住房'
				WHEN CustomerType LIKE '%消费%' THEN '综消'
				WHEN CustomerType LIKE '%经营%' THEN '经营'
				ELSE CustomerType
			END

	SELECT OrgName, CustomerName, CapitalAmount, OweInterestAmount, LoanStartDate, LoanEndDate
		, OverdueDays = ISNULL(OverdueDays, 0)
		, OweInterestDays = ISNULL(OweInterestDays, 0)
	FROM #Result

	DROP TABLE #Result
END

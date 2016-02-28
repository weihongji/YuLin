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
		DECLARE @msg varchar(120) = '�ϸ���ĩ(' + CONVERT(varchar(10), @endDayOfLastMonth, 120) + ')��̨�˻�û���룡';
		THROW 50000, @msg, 1
	END

	SELECT OrgName = O.Alias1
		, L.CustomerName
		, L.CapitalAmount
		, OweInterestAmount = L.OweYingShouInterest + L.OweCuiShouInterest
		, L.LoanStartDate
		, L.LoanEndDate
		, OverdueDays = CASE WHEN L.LoanEndDate < @endDayOfThisMonth AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @endDayOfThisMonth) ELSE 0 END
		, OweInterestDays = CASE WHEN L.CustomerType = '��˽' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
		, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)
	INTO #Result
	FROM ImportLoan L
		LEFT JOIN Org O ON O.Id = L.OrgId4Report
		LEFT JOIN ImportPrivate PV ON PV.LoanAccount = L.LoanAccount AND PV.ImportId = @importIdOfLastMonthEndDay
		LEFT JOIN ImportPublic PB ON PB.LoanAccount = L.LoanAccount AND PB.ImportId = @importIdOfLastMonthEndDay
	WHERE L.ImportId = @importId
			AND (
				L.LoanState IN ('��Ӧ��', '����', '��������')
				OR (L.LoanState = '����' AND L.OweYingShouInterest + L.OweCuiShouInterest != 0)
			)

	UPDATE #Result SET OweInterestDays = OweInterestDays + DATEPART(DAY, @endDayOfThisMonth) WHERE OweInterestDays > 0 --ֻ������̨����ʾ��ǷϢ�Ĳż��㱾��ĩ��ǷϢ����

	UPDATE #Result SET OverdueDays = OweInterestDays WHERE OverdueDays = 0 AND OweInterestDays > 0 AND CustomerType LIKE '%��%'
	UPDATE #Result SET CustomerType =
			CASE
				WHEN CustomerType LIKE '%��%'   THEN 'ס��'
				WHEN CustomerType LIKE '%����%' THEN '����'
				WHEN CustomerType LIKE '%��Ӫ%' THEN '��Ӫ'
				ELSE CustomerType
			END

	SELECT OrgName, CustomerName, CapitalAmount, OweInterestAmount, LoanStartDate, LoanEndDate
		, OverdueDays = ISNULL(OverdueDays, 0)
		, OweInterestDays = ISNULL(OweInterestDays, 0)
	FROM #Result

	DROP TABLE #Result
END

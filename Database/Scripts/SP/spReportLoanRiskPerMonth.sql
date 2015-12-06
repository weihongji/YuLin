IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spReportLoanRiskPerMonth') BEGIN
	DROP PROCEDURE spReportLoanRiskPerMonth
END
GO

CREATE PROCEDURE spReportLoanRiskPerMonth
	@type as varchar(20),
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT -1 AS Id INTO #LoanId

	IF @type = 'FYJ' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId = @importId
			AND LoanState = '��Ӧ��'
	END
	ELSE IF @type = 'BLDK' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND DangerLevel IN ('�μ�', '����', '��ʧ')
	END
	ELSE IF @type = 'YQ' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND LoanState IN ('����', '��������')
	END
	ELSE IF @type = 'ZQX' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND LoanState = '����'
			AND OweYingShouInterest + OweCuiShouInterest != 0
	END
	ELSE IF @type = 'GZDK' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND DangerLevel LIKE '��%'
	END
	ELSE IF @type = 'F_HYB' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND (DangerLevel IN ('�μ�', '����', '��ʧ') OR DangerLevel LIKE '��%')
	END

	DECLARE @placeTaker_IsNew nvarchar(2) = ''

	SELECT L.Id, L.ImportId, L.LoanAccount, OrgName = CASE WHEN L.CustomerType = '��˽' AND O.Alias1 = '��˾��' THEN 'Ӫҵ��' ELSE O.Alias1 END
		, L.CustomerName, L.CapitalAmount, L.OweCapital, L.DangerLevel
		, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest
		, LoanStartDate = CONVERT(VARCHAR(8), L.LoanStartDate, 112)
		, LoanEndDate = CONVERT(VARCHAR(8), L.LoanEndDate, 112)
		, OverdueDays = CASE WHEN L.LoanEndDate < @asOfDate AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END
		, OweInterestDays = CASE WHEN L.CustomerType = '��˽' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
		, DanBaoFangShi = ISNULL(NA.DanBaoFangShi, OD.DanBaoFangShi)
		, DanBaoFangShi2 = ISNULL(PV.DanBaoFangShi, PB.VOUCHTYPENAME) /* ֻǷϢ */
		, Industry = ISNULL(PV.Direction1, PB.Direction1)
		, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)
		, LoanType = L.LoanTypeName
		, IsNew = @placeTaker_IsNew
		, Comment = L.LoanState
		, IdCardNo = ISNULL(PV.IdCardNo, PB.OrgCode)
		, Direction1 = ISNULL(PV.Direction1, PB.Direction1)
		, Direction2 = ISNULL(PV.Direction2, PB.Direction2)
		, Direction3 = ISNULL(PV.Direction3, PB.Direction3)
		, Direction4 = ISNULL(PV.Direction4, PB.Direction4)
		, FinalDays = 0
	INTO #Result
	FROM ImportLoan L
		LEFT JOIN Org O ON L.OrgId = O.Id
		LEFT JOIN ImportPrivate PV ON PV.LoanAccount = L.LoanAccount AND PV.ImportId = L.ImportId
		LEFT JOIN ImportPublic PB ON PB.LoanAccount = L.LoanAccount AND PB.ImportId = L.ImportId
		LEFT JOIN ImportNonAccrual NA ON L.LoanAccount = NA.LoanAccount AND NA.ImportId = L.ImportId
		LEFT JOIN ImportOverdue OD ON L.LoanAccount = OD.LoanAccount AND OD.ImportId = L.ImportId
	WHERE L.Id IN (SELECT Id FROM #LoanId)
		AND L.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
	
	UPDATE #Result SET OverdueDays = OweInterestDays WHERE OverdueDays = 0 AND OweInterestDays > 0 AND CustomerType LIKE '%��%'
	UPDATE #Result SET CustomerType =
			CASE
				WHEN CustomerType LIKE '%��%'   THEN 'ס��'
				WHEN CustomerType LIKE '%����%' THEN '����'
				WHEN CustomerType LIKE '%��Ӫ%' THEN '��Ӫ'
				ELSE CustomerType
			END
	IF @type = 'F_HYB' BEGIN
		UPDATE #Result SET FinalDays = ISNULL(CASE WHEN OverdueDays >= OweInterestDays THEN OverdueDays ELSE OweInterestDays END, 0)
	END

	IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'Shell_WJFL') BEGIN
		SELECT * INTO Shell_WJFL FROM #Result WHERE 1 = 2
	END

	IF @asOfDate > '2015-01-01' BEGIN
		SELECT * FROM #Result
	END

	DROP TABLE #LoanId
	DROP TABLE #Result
END

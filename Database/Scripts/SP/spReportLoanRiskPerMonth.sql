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
		WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
			AND LoanState = '��Ӧ��'
	END
	ELSE IF @type = 'BLDK' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
			AND DangerLevel IN ('�μ�', '����', '��ʧ')
	END
	ELSE IF @type = 'YQ' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
			AND LoanState IN ('����', '��������')
	END
	ELSE IF @type = 'ZQX' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
			AND LoanState = '����'
			AND OweYingShouInterest + OweCuiShouInterest != 0
	END
	ELSE IF @type = 'GZDK' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
			AND DangerLevel LIKE '��%'
	END
	ELSE IF @type = 'F_HYB' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
			AND (DangerLevel IN ('�μ�', '����', '��ʧ') OR DangerLevel LIKE '��%')
	END

	SELECT L.Id, OrgName = CASE WHEN L.CustomerType = '��˽' AND O.Alias1 = '��˾��' THEN 'Ӫҵ��' ELSE O.Alias1 END
		, L.CustomerName, L.CapitalAmount, L.OweCapital, L.DangerLevel
		, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest
		, LoanStartDate = CONVERT(VARCHAR(8), L.LoanStartDate, 112)
		, LoanEndDate = CONVERT(VARCHAR(8), L.LoanEndDate, 112)
		, OverdueDays = CASE WHEN L.LoanEndDate < @asOfDate THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END
		, OweInterestDays = CASE WHEN L.CustomerType = '��˽' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
		, DanBaoFangShi = ISNULL(NA.DanBaoFangShi, OD.DanBaoFangShi)
		, DanBaoFangShi2 = ISNULL(PV.DanBaoFangShi, PB.VOUCHTYPENAME) /* ֻǷϢ */
		, Industry = ISNULL(PV.Direction1, PB.Direction1)
		, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)
		, LoanType = L.LoanTypeName
		, IsNew = CASE WHEN EXISTS(
					SELECT * FROM ImportLoan PL
					WHERE PL.LoanAccount = L.LoanAccount
						AND PL.ImportItemId IN (SELECT Id FROM ImportItem WHERE ImportId IN (SELECT Id FROM Import WHERE ImportDate < @asOfDate))
				) THEN '' ELSE '��' END
		, Comment = L.LoanState
	INTO #Result
	FROM ImportLoan L
		LEFT JOIN Org O ON L.OrgNo = O.Number
		LEFT JOIN ImportPrivate PV ON PV.CustomerName = L.CustomerName AND PV.ContractStartDate = L.LoanStartDate AND PV.ContractEndDate = L.LoanEndDate AND PV.OrgNo = L.OrgNo AND PV.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 3)
		LEFT JOIN ImportPublic PB ON PB.LoanAccount = L.LoanAccount AND PB.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 2)
		LEFT JOIN ImportNonAccrual NA ON L.LoanAccount = NA.LoanAccount AND NA.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 4)
		LEFT JOIN ImportOverdue OD ON L.LoanAccount = OD.LoanAccount AND OD.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 5)
	WHERE L.Id IN (SELECT Id FROM #LoanId)
	
	UPDATE #Result SET OverdueDays = OweInterestDays WHERE OverdueDays = 0 AND OweInterestDays > 0 AND CustomerType LIKE '%��%'
	UPDATE #Result SET CustomerType =
			CASE
				WHEN CustomerType LIKE '%��%'   THEN 'ס��'
				WHEN CustomerType LIKE '%����%' THEN '����'
				WHEN CustomerType LIKE '%��Ӫ%' THEN '��Ӫ'
				ELSE CustomerType
			END

	IF @type = 'YQ' BEGIN
		SELECT OrgName, CustomerName, CapitalAmount, OweCapital, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, OweInterestDays
			, DanBaoFangShi = (SELECT Category FROM DanBaoFangShi WHERE Name = DanBaoFangShi2)
			, Industry, CustomerType, LoanType, IsNew, Comment
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
	ELSE BEGIN
		SELECT OrgName, CustomerName, CapitalAmount, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, OweInterestDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, Comment
		FROM #Result ORDER BY Id
	END

	DROP TABLE #LoanId
END

IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spC_XZDKMX_D') BEGIN
	DROP PROCEDURE spC_XZDKMX_D
END
GO

CREATE PROCEDURE spC_XZDKMX_D
	@type as varchar(20),
	@asOfDate1 as smalldatetime,
	@asOfDate2 smalldatetime,
	@columns as nvarchar(2000) = ''
AS
BEGIN
	SET NOCOUNT ON;

	/*
	DECLARE @type as varchar(20) = 'FYJ'
	DECLARE @asOfDate1 smalldatetime = '20151101'
	DECLARE @asOfDate2 smalldatetime = '20151102'
	DECLARE @columns as nvarchar(2000)
	SET @columns = 'CustomerName, CapitalAmount, DangerLevel'
	*/
	IF @columns IS NULL OR LEN(@columns) = 0 BEGIN
		SET @columns = ''
		SELECT @columns = @columns + ', ' + ColName FROM TableMapping where TableId = 'ImportLoanXZ' and MappingMode = 1
		SET @columns = SUBSTRING(@columns, 3, LEN(@columns))
	END
	IF CHARINDEX('''', @columns, 1) > 0 BEGIN
		RETURN
	END

	DECLARE @asOfDateWJFL smalldatetime
	DECLARE @importIdWJFL int
	IF @asOfDate1 > @asOfDate2 BEGIN
		SET @asOfDateWJFL = @asOfDate1
		SET @asOfDate1 = @asOfDate2
		SET @asOfDate2 = @asOfDateWJFL
	END
	SELECT TOP 1 @importIdWJFL = Id, @asOfDateWJFL = ImportDate FROM Import
	WHERE ImportDate <= @asOfDate2 AND [State] = 2
	ORDER BY ImportDate DESC

	DECLARE @importId1 int
	DECLARE @importId2 int
	SELECT @importId1 = Id FROM Import WHERE ImportDate = @asOfDate1
	SELECT @importId2 = Id FROM Import WHERE ImportDate = @asOfDate2
	
	IF OBJECT_ID('tempdb..#ResultWJFL') IS NOT NULL BEGIN
		DROP TABLE #ResultWJFL
	END
	SELECT L.LoanAccount
		, L.DangerLevel
		, DanBaoFangShi = ISNULL(NA.DanBaoFangShi, OD.DanBaoFangShi)
		, DanBaoFangShi2 = ISNULL(PV.DanBaoFangShi, PB.VOUCHTYPENAME) /* 只欠息 */
		, OverdueDays = CASE WHEN L.LoanEndDate < @asOfDateWJFL AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @asOfDateWJFL) ELSE 0 END
		, OweInterestDays = CASE WHEN L.CustomerType = '对私' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
		, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)
	INTO #ResultWJFL
	FROM ImportLoan L
		LEFT JOIN ImportPrivate PV ON PV.LoanAccount = L.LoanAccount AND PV.ImportId = L.ImportId
		LEFT JOIN ImportPublic PB ON PB.LoanAccount = L.LoanAccount AND PB.ImportId = L.ImportId
		LEFT JOIN ImportNonAccrual NA ON L.LoanAccount = NA.LoanAccount AND NA.ImportId = L.ImportId
		LEFT JOIN ImportOverdue OD ON L.LoanAccount = OD.LoanAccount AND OD.ImportId = L.ImportId
	WHERE L.ImportId = @importIdWJFL
		AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')

	UPDATE #ResultWJFL SET OverdueDays = OweInterestDays WHERE OverdueDays = 0 AND OweInterestDays > 0 AND CustomerType LIKE '%房%'
	UPDATE #ResultWJFL SET CustomerType =
			CASE
				WHEN CustomerType LIKE '%房%'   THEN '住房'
				WHEN CustomerType LIKE '%消费%' THEN '综消'
				WHEN CustomerType LIKE '%经营%' THEN '经营'
				ELSE CustomerType
			END
	IF @type = 'ZQX' BEGIN
		UPDATE #ResultWJFL SET DanBaoFangShi = (SELECT Category FROM DanBaoFangShi WHERE Name = DanBaoFangShi2)
	END

	SELECT -1 AS Id INTO #LoanId

	IF @type = 'FYJ' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT L2.Id FROM
			(
				SELECT Id, LoanAccount FROM ImportLoan
				WHERE OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
					AND ImportId = @importId1
					AND LoanState = '非应计'
			) AS L1
			RIGHT JOIN
			(
				SELECT Id, LoanAccount FROM ImportLoan
				WHERE OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
					AND ImportId = @importId2
					AND LoanState = '非应计'
			) AS L2 ON L1.LoanAccount = L2.LoanAccount
		WHERE L1.Id IS NULL
	END
	ELSE IF @type = 'YQ' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT L2.Id FROM
			(
				SELECT Id, LoanAccount FROM ImportLoan
				WHERE OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
					AND ImportId = @importId1
					AND LoanState IN ('逾期', '部分逾期')
			) AS L1
			RIGHT JOIN
			(
				SELECT Id, LoanAccount FROM ImportLoan
				WHERE OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
					AND ImportId = @importId2
					AND LoanState IN ('逾期', '部分逾期')
			) AS L2 ON L1.LoanAccount = L2.LoanAccount
		WHERE L1.Id IS NULL
	END
	ELSE IF @type = 'ZQX' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT L2.Id FROM
			(
				SELECT Id, LoanAccount FROM ImportLoan
				WHERE OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
					AND ImportId = @importId1
					AND LoanState = '正常' AND OweYingShouInterest + OweCuiShouInterest != 0
			) AS L1
			RIGHT JOIN
			(
				SELECT Id, LoanAccount FROM ImportLoan
				WHERE OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
					AND ImportId = @importId2
					AND LoanState = '正常' AND OweYingShouInterest + OweCuiShouInterest != 0
			) AS L2 ON L1.LoanAccount = L2.LoanAccount
		WHERE L1.Id IS NULL
	END

	SELECT L.Id, L.ImportId
		, SubIndex = 0
		, L.CustomerName
		, L.CapitalAmount
		, DangerLevel = ISNULL(R.DangerLevel, L.DangerLevel)
		, R.DanBaoFangShi
		, L.LoanStartDate
		, L.LoanEndDate
		, R.OverdueDays
		, OweInterestAmount = L.OweYingShouInterest + L.OweCuiShouInterest
		, R.OweInterestDays
		, OrgName = CASE WHEN L.CustomerType = '对私' AND O.Alias1 = '公司部' THEN '营业部' ELSE O.Alias1 END
		, BusinessType = R.CustomerType
		, L.OrgNo, L.LoanCatalog, L.LoanAccount, L.CustomerNo, L.CustomerType, L.CurrencyType, L.LoanAmount, L.OweCapital, L.OweYingShouInterest, L.OweCuiShouInterest, L.DueBillNo, L.ZhiHuanZhuanRang, L.HeXiaoFlag, L.LoanState, L.LoanType, L.LoanTypeName, L.Direction, L.ZhuanLieYuQi, L.ZhuanLieFYJ, L.InterestEndDate, L.LiLvType, L.LiLvSymbol, L.LiLvJiaJianMa, L.YuQiLiLvYiJu, L.YuQiLiLvType, L.YuQiLiLvSymbol, L.YuQiLiLvJiaJianMa, L.LiLvYiJu, L.ContractInterestRatio, L.ContractOverdueInterestRate, L.ChargeAccount
	INTO #Result
	FROM ImportLoan L
		INNER JOIN Org O ON L.OrgNo = O.Number
		LEFT JOIN #ResultWJFL R ON L.LoanAccount = R.LoanAccount
	WHERE L.Id IN (SELECT Id FROM #LoanId WHERE Id > 0)

	UPDATE R SET SubIndex = (SELECT COUNT(*) FROM #Result I WHERE I.OrgNo = R.OrgNo AND I.Id<=R.Id) FROM #Result R

	DECLARE @sql nvarchar(2000)
	SET @sql='SELECT ' + @columns + ' FROM #Result ORDER BY OrgNo, Id'
	EXEC sp_executesql @sql

	DROP TABLE #Result
	DROP TABLE #ResultWJFL
	DROP TABLE #LoanId
END

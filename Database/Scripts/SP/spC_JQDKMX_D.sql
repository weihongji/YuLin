IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spC_JQDKMX_D') BEGIN
	DROP PROCEDURE spC_JQDKMX_D
END
GO

CREATE PROCEDURE spC_JQDKMX_D
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
		SELECT @columns = @columns + ', ' + ColName FROM TableMapping where TableId = 'ImportLoanJQ' and MappingMode = 1
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
	WHERE ImportDate <= @asOfDate1 AND WJFLDate IS NOT NULL
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
		AND L.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())

	UPDATE #ResultWJFL SET OverdueDays = OweInterestDays WHERE OverdueDays = 0 AND OweInterestDays > 0 AND CustomerType LIKE '%房%'
	UPDATE #ResultWJFL SET CustomerType =
			CASE
				WHEN CustomerType LIKE '%房%'   THEN '住房'
				WHEN CustomerType LIKE '%消费%' THEN '综消'
				WHEN CustomerType LIKE '%经营%' THEN '经营'
				ELSE CustomerType
			END

	SELECT -1 AS Id INTO #LoanId

	INSERT INTO #LoanId(Id)
	SELECT L1.Id FROM
		(
			SELECT Id, LoanAccount, CapitalAmount, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest
			FROM ImportLoan
			WHERE OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
				AND ImportId = @importId1
				AND (
					LoanState IN ('非应计', '逾期', '部分逾期')
					OR (LoanState = '正常' AND OweYingShouInterest + OweCuiShouInterest != 0)
				)
		) AS L1
		LEFT JOIN
		(
			SELECT Id, LoanAccount, CapitalAmount, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest
			FROM ImportLoan
			WHERE OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
				AND ImportId = @importId2
				AND (
					LoanState IN ('非应计', '逾期', '部分逾期')
					OR (LoanState = '正常' AND OweYingShouInterest + OweCuiShouInterest != 0)
				)
		) AS L2 ON L1.LoanAccount = L2.LoanAccount
	WHERE L1.CapitalAmount > ISNULL(L2.CapitalAmount, 0) OR L1.OweInterestAmount > ISNULL(L2.OweInterestAmount, 0)

	SELECT L.Id, L.ImportId
		, SubIndex = 0
		, L.CustomerName
		, CapitalAmount = ISNULL(L2.CapitalAmount, 0)
		, PaidCapital = L.CapitalAmount - ISNULL(L2.CapitalAmount, 0)
		, DangerLevel = ISNULL(R.DangerLevel, L.DangerLevel)
		, R.DanBaoFangShi
		, L.LoanStartDate
		, L.LoanEndDate
		, OverdueDays = CASE WHEN L2.Id IS NOT NULL THEN R.OverdueDays ELSE 0 END
		, OweInterestAmount = ISNULL(L2.OweYingShouInterest + L2.OweCuiShouInterest, 0)
		, PaidInterest = L.OweYingShouInterest + L.OweCuiShouInterest - ISNULL(L2.OweYingShouInterest + L2.OweCuiShouInterest, 0)
		, OweInterestDays = CASE WHEN L2.Id IS NOT NULL THEN R.OweInterestDays ELSE 0 END
		, OrgName = CASE WHEN L.CustomerType = '对私' AND O.Alias1 = '公司部' THEN '营业部' ELSE O.Alias1 END
		, BusinessType = R.CustomerType
		, L.OrgId, L.OrgNo, L.LoanCatalog, L.LoanAccount, L.CustomerNo, L.CustomerType, L.CurrencyType, L.LoanAmount, L.OweCapital, L.OweYingShouInterest, L.OweCuiShouInterest, L.DueBillNo, L.ZhiHuanZhuanRang, L.HeXiaoFlag
		, LoanState = CASE WHEN L.LoanState = '正常' THEN '只欠息' ELSE L.LoanState END
		, L.LoanType, L.LoanTypeName, L.Direction, L.ZhuanLieYuQi, L.ZhuanLieFYJ, L.InterestEndDate, L.LiLvType, L.LiLvSymbol, L.LiLvJiaJianMa, L.YuQiLiLvYiJu, L.YuQiLiLvType, L.YuQiLiLvSymbol, L.YuQiLiLvJiaJianMa, L.LiLvYiJu, L.ContractInterestRatio, L.ContractOverdueInterestRate, L.ChargeAccount
	INTO #Result
	FROM ImportLoan L
		INNER JOIN Org O ON L.OrgId = O.Id
		LEFT JOIN #ResultWJFL R ON L.LoanAccount = R.LoanAccount
		LEFT JOIN ImportLoan L2 ON L.LoanAccount = L2.LoanAccount AND L2.ImportId = @importId2
	WHERE L.Id IN (SELECT Id FROM #LoanId WHERE Id > 0)

	UPDATE R SET SubIndex = (SELECT COUNT(*) FROM #Result I WHERE I.OrgId = R.OrgId AND I.Id<=R.Id) FROM #Result R

	DECLARE @sql nvarchar(2000)
	SET @sql='SELECT ' + @columns + ' FROM #Result ORDER BY OrgId, Id'
	EXEC sp_executesql @sql

	DROP TABLE #Result
	DROP TABLE #ResultWJFL
	DROP TABLE #LoanId
END

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
			AND LoanState = '非应计'
	END
	ELSE IF @type = 'BLDK' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND DangerLevel IN ('次级', '可疑', '损失')
	END
	ELSE IF @type = 'YQ' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND LoanState IN ('逾期', '部分逾期')
	END
	ELSE IF @type = 'ZQX' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND LoanState = '正常'
			AND OweYingShouInterest + OweCuiShouInterest != 0
	END
	ELSE IF @type = 'GZDK' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND DangerLevel LIKE '关%'
	END
	ELSE IF @type = 'F_HYB' BEGIN
		INSERT INTO #LoanId(Id)
		SELECT Id FROM ImportLoan
		WHERE ImportId=@importId
			AND (DangerLevel IN ('次级', '可疑', '损失') OR DangerLevel LIKE '关%')
	END

	SELECT L.Id, OrgName = CASE WHEN L.CustomerType = '对私' AND O.Alias1 = '公司部' THEN '营业部' ELSE O.Alias1 END
		, L.CustomerName, L.CapitalAmount, L.OweCapital, L.DangerLevel
		, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest
		, LoanStartDate = CONVERT(VARCHAR(8), L.LoanStartDate, 112)
		, LoanEndDate = CONVERT(VARCHAR(8), L.LoanEndDate, 112)
		, OverdueDays = CASE WHEN L.LoanEndDate < @asOfDate THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END
		, OweInterestDays = CASE WHEN L.CustomerType = '对私' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
		, DanBaoFangShi = ISNULL(NA.DanBaoFangShi, OD.DanBaoFangShi)
		, DanBaoFangShi2 = ISNULL(PV.DanBaoFangShi, PB.VOUCHTYPENAME) /* 只欠息 */
		, Industry = ISNULL(PV.Direction1, PB.Direction1)
		, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)
		, LoanType = L.LoanTypeName
		, IsNew = CASE WHEN EXISTS(
					SELECT * FROM ImportLoan PL
					WHERE PL.LoanAccount = L.LoanAccount
						AND PL.ImportId IN (SELECT Id FROM Import WHERE ImportDate < @asOfDate)
				) THEN '' ELSE '是' END
		, Comment = L.LoanState
		, IdCardNo = ISNULL(PV.IdCardNo, PB.OrgCode)
		, Direction1 = ISNULL(PV.Direction1, PB.Direction1)
		, Direction2 = ISNULL(PV.Direction2, PB.Direction2)
		, Direction3 = ISNULL(PV.Direction3, PB.Direction3)
		, Direction4 = ISNULL(PV.Direction4, PB.Direction4)
		, FinalDays = 0
	INTO #Result
	FROM ImportLoan L
		LEFT JOIN Org O ON L.OrgNo = O.Number
		LEFT JOIN ImportPrivate PV ON PV.CustomerName = L.CustomerName AND PV.ContractStartDate = L.LoanStartDate AND PV.ContractEndDate = L.LoanEndDate AND PV.OrgNo = L.OrgNo AND PV.ImportId = @importId
		LEFT JOIN ImportPublic PB ON PB.LoanAccount = L.LoanAccount AND PB.ImportId = @importId
		LEFT JOIN ImportNonAccrual NA ON L.LoanAccount = NA.LoanAccount AND NA.ImportId = @importId
		LEFT JOIN ImportOverdue OD ON L.LoanAccount = OD.LoanAccount AND OD.ImportId = @importId
	WHERE L.Id IN (SELECT Id FROM #LoanId)
	
	UPDATE #Result SET OverdueDays = OweInterestDays WHERE OverdueDays = 0 AND OweInterestDays > 0 AND CustomerType LIKE '%房%'
	UPDATE #Result SET CustomerType =
			CASE
				WHEN CustomerType LIKE '%房%'   THEN '住房'
				WHEN CustomerType LIKE '%消费%' THEN '综消'
				WHEN CustomerType LIKE '%经营%' THEN '经营'
				ELSE CustomerType
			END

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
		UPDATE #Result SET FinalDays = CASE WHEN OverdueDays >= OweInterestDays THEN OverdueDays ELSE OweInterestDays END

		SELECT '榆林分行' AS OrgName
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
						WHEN FinalDays <= 30  THEN '30天以内'
						WHEN FinalDays <= 90  THEN '31到90天'
						WHEN FinalDays <= 180 THEN '91天到180天'
						WHEN FinalDays <= 270  THEN '181天到270天'
						WHEN FinalDays <= 360  THEN '271天到360天'
						ELSE '361天以上'
					END
			, Direction1
			, Direction2
			, Direction3
			, Direction4
			, DanBaoFangShi
			, IsLongTerm = CASE WHEN LoanType LIKE '%短期%' THEN '否' WHEN LoanType LIKE '%中长期%' THEN '是' ELSE '' END
		FROM #Result
		ORDER BY Id
	END
	ELSE BEGIN
		SELECT OrgName, CustomerName, CapitalAmount, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, OweInterestDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, Comment
		FROM #Result ORDER BY Id
	END

	DROP TABLE #LoanId
	DROP TABLE #Result
END

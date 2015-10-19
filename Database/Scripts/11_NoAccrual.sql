DECLARE @importId as int = 1
DECLARE @loanAccount as varchar(50) = '610112201120001443'
DECLARE @importItemIdLoan as int, @importItemIdPublic as int, @importItemIdPrivate as int, @importItemIdNonAccrual as int, @importItemIdOverdue as int
DECLARE @asOfDate as smalldatetime
DECLARE @customerType nvarchar(20)
DECLARE @customerScale nvarchar(20) /* 1: 大中企业, 2: 小微企业, 3: 个人消费 */
DECLARE @danbaofangshi nvarchar(20)
DECLARE @overdueDays as int, @oweInterestDays as int
DECLARE @importLoanId as int
DECLARE @dangerLevel nvarchar(20) /* 正常, 关注, 次级, 可疑, 损失*/

SELECT @importItemIdLoan = Id		FROM ImportItem WHERE ImportId = @importId AND ItemType = 1
SELECT @importItemIdPublic = Id		FROM ImportItem WHERE ImportId = @importId AND ItemType = 2
SELECT @importItemIdPrivate = Id	FROM ImportItem WHERE ImportId = @importId AND ItemType = 3
SELECT @importItemIdNonAccrual = Id	FROM ImportItem WHERE ImportId = @importId AND ItemType = 4
SELECT @importItemIdOverdue = Id	FROM ImportItem WHERE ImportId = @importId AND ItemType = 5

SELECT @asOfDate = ImportDate FROM Import WHERE Id = @importId
SELECT @importLoanId = Id
	, @customerType = CustomerType
	, @overdueDays = CASE WHEN LoanEndDate < @asOfDate THEN DATEDIFF(day, LoanEndDate, @asOfDate) ELSE 0 END
FROM ImportLoan
WHERE ImportItemId = @importItemIdLoan AND LoanAccount = @loanAccount

IF @customerType = '对公' BEGIN
	SELECT @customerScale = (CASE WHEN P.MyBankIndTypeName IN ('微型企业', '小型企业') THEN '2' ELSE '1' END)
		, @oweInterestDays = P.OweInterestDays
	FROM ImportPublic P INNER JOIN ImportLoan L ON P.FContractNo = L.LoanAccount AND P.ImportItemId = @importItemIdPublic
	WHERE L.Id = @importLoanId
END
ELSE BEGIN
	SELECT @customerScale = (CASE WHEN LEN(P.Direction1) > 0 THEN '2' ELSE '3' END)
		, @oweInterestDays = InterestOverdueDays
	FROM ImportPrivate P INNER JOIN ImportLoan L ON P.CustomerName = L.CustomerName AND P.ContractStartDate = L.LoanStartDate AND P.ContractEndDate = L.LoanEndDate AND P.OrgNo = L.OrgNo AND P.ImportItemId = @importItemIdPrivate
	WHERE L.Id = @importLoanId
END

SELECT @danbaofangshi = DanBaoFangShi FROM ImportNonAccrual A INNER JOIN ImportLoan L ON A.LoanAccount = L.LoanAccount AND A.ImportItemId = @importItemIdNonAccrual
WHERE L.Id = @importLoanId

IF @danbaofangshi IS NULL BEGIN
	SELECT @danbaofangshi = DanBaoFangShi FROM ImportOverdue O INNER JOIN ImportLoan L ON O.LoanAccount = L.LoanAccount AND O.ImportItemId = @importItemIdOverdue
	WHERE L.Id = @importLoanId
END

DECLARE @days int = (CASE WHEN @overdueDays >= @oweInterestDays THEN @overdueDays ELSE @oweInterestDays END)
IF @customerScale = '1' BEGIN --大中企业
	SET @dangerLevel = (CASE WHEN @days = 0 THEN '正常' WHEN @days BETWEEN 1 AND 90 THEN '关注' WHEN @days BETWEEN 91 AND 180 THEN '次级' WHEN @days > 181 THEN '可疑' END)
END
ELSE IF @customerScale = '2' BEGIN --小微企业
	IF @danbaofangshi = '信用' BEGIN
		SET @dangerLevel = (CASE
				WHEN @days = 0 THEN '正常'
				WHEN @days BETWEEN  1 AND 30 THEN '关注2'
				WHEN @days BETWEEN 31 AND 60 THEN '关注3'
				WHEN @days BETWEEN 61 AND 90 THEN '次级'
				WHEN @days BETWEEN 91 AND 180 THEN '可疑'
				WHEN @days BETWEEN 181 AND 360 THEN '可疑'
				WHEN @days > 361 THEN '损失' END
			)
	END
	ELSE IF @danbaofangshi = '保证' BEGIN
		SET @dangerLevel = (CASE
				WHEN @days = 0 THEN '正常'
				WHEN @days BETWEEN  1 AND 30 THEN '关注1'
				WHEN @days BETWEEN 31 AND 60 THEN '关注2'
				WHEN @days BETWEEN 61 AND 90 THEN '关注3'
				WHEN @days BETWEEN 91 AND 180 THEN '次级'
				WHEN @days BETWEEN 181 AND 360 THEN '可疑'
				WHEN @days > 361 THEN '损失' END
			)
	END
	ELSE IF @danbaofangshi = '抵押' BEGIN
		SET @dangerLevel = (CASE
				WHEN @days = 0 THEN '正常'
				WHEN @days BETWEEN  1 AND 30 THEN '正常'
				WHEN @days BETWEEN 31 AND 60 THEN '关注1'
				WHEN @days BETWEEN 61 AND 90 THEN '关注2'
				WHEN @days BETWEEN 91 AND 180 THEN '关注3'
				WHEN @days BETWEEN 181 AND 360 THEN '次级'
				WHEN @days BETWEEN 361 AND 540 THEN '可疑'
				WHEN @days > 541 THEN '损失' END
			)
	END
	ELSE IF @danbaofangshi = '质押' BEGIN
		SET @dangerLevel = (CASE
				WHEN @days = 0 THEN '正常'
				WHEN @days BETWEEN  1 AND 30 THEN '正常'
				WHEN @days BETWEEN 31 AND 60 THEN '正常'
				WHEN @days BETWEEN 61 AND 90 THEN '关注2'
				WHEN @days BETWEEN 91 AND 180 THEN '关注3'
				WHEN @days BETWEEN 181 AND 360 THEN '次级'
				WHEN @days BETWEEN 361 AND 540 THEN '可疑'
				WHEN @days > 541 THEN '损失' END
			)
	END
END
ELSE IF @customerScale = '3' BEGIN --个人消费
	SET @dangerLevel = (CASE
			WHEN @days = 0 THEN '正常'
			WHEN @days BETWEEN  1 AND 30 THEN '关注1'
			WHEN @days BETWEEN 31 AND 60 THEN '关注2'
			WHEN @days BETWEEN 61 AND 90 THEN '关注3'
			WHEN @days BETWEEN 91 AND 180 THEN '次级'
			WHEN @days > 181 THEN '可疑' END
		)
END

SELECT @dangerLevel AS DangerLevel, @customerScale AS CustomerScale, @danbaofangshi, @overdueDays, @oweInterestDays

/*
	SELECT *
	FROM ImportPrivate P INNER JOIN ImportLoan L ON P.CustomerName = L.CustomerName AND P.ContractStartDate = L.LoanStartDate AND P.ContractEndDate = L.LoanEndDate AND P.OrgNo = L.OrgNo AND P.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = 1 AND ItemType = 3)
	WHERE L.Id = 7490

select * FROM ImportLoan where LoanAccount ='806050001481018516' --#7490
select * FROM ImportPrivate where CustomerName = '高伟' and ImportItemId = 3 --#3414

DECLARE @monthLastDay as smalldatetime = '20150801'
DELETE FROM ReportLoanRiskPerMonthFYJ WHERE ImportId = @importId
--INSERT INTO ReportLoanRiskPerMonthFYJ(ImportId, OrgName, CustomerName, LoanBalance, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, InterestOverdueDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, LoanState)
SELECT @importId AS ImportId, O.Alias1, L.CustomerName, L.CapitalAmount, 'xxx' AS DangerLevel
	, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest
	, L.LoanStartDate, L.LoanEndDate
	, OverdueDays = CASE WHEN L.LoanEndDate < @monthLastDay THEN DATEDIFF(day, L.LoanEndDate, @monthLastDay) ELSE 0 END
	, OweInterestDays = CASE WHEN L.CustomerType = '对私' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
	, DanBaoFangShi = ISNULL(NA.DanBaoFangShi, OD.DanBaoFangShi)
	, Industry = ISNULL(PV.Direction1, PB.Direction1)
	, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)
	, LoanType = L.LoanTypeName
	, IsNew = 'xxx'
	, Comment = L.LoanState
FROM ImportLoan L
	LEFT JOIN Org O ON L.OrgNo = O.Number
	LEFT JOIN ImportPrivate PV ON PV.CustomerName = L.CustomerName AND PV.ContractStartDate = L.LoanStartDate AND PV.ContractEndDate = L.LoanEndDate AND PV.OrgNo = L.OrgNo AND PV.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 3)
	LEFT JOIN ImportPublic PB ON PB.FContractNo = L.LoanAccount AND PB.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 2)
	LEFT JOIN ImportNonAccrual NA ON L.LoanAccount = NA.LoanAccount AND NA.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 4)
	LEFT JOIN ImportOverdue OD ON L.LoanAccount = OD.LoanAccount AND OD.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 5)
WHERE LoanState = '非应计' AND L.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
ORDER BY L.Id

*/
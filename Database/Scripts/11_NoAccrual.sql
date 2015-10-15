DECLARE @importId as int
SELECT @importId = Id FROM Import WHERE ImportDate = '20150901'
DECLARE @monthLastDay as smalldatetime = '20150901'
SELECT O.Alias1, L.CustomerName, L.CapitalAmount, 'xxx' AS DangerLevel
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
	LEFT JOIN ImportPrivate PV ON PV.CustomerName = L.CustomerName AND PV.ContractStartDate = L.LoanStartDate AND PV.ContractEndDate = L.LoanEndDate AND PV.OrgNo = L.OrgNo AND PV.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 2)
	LEFT JOIN ImportPublic PB ON PB.FContractNo = L.LoanAccount AND PB.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
	LEFT JOIN ImportNonAccrual NA ON L.LoanAccount = NA.LoanAccount AND NA.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 3)
	LEFT JOIN ImportOverdue OD ON L.LoanAccount = OD.LoanAccount AND OD.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 4)
WHERE LoanState = '非应计' AND L.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 0)
	AND L.CustomerName = '李世平'
ORDER BY L.Id

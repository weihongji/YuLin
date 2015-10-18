DECLARE @importId as int = 2
DECLARE @monthLastDay as smalldatetime = '20150801'
DELETE FROM ReportLoanRiskPerMonthFYJ WHERE ImportId = @importId
--INSERT INTO ReportLoanRiskPerMonthFYJ(ImportId, OrgName, CustomerName, LoanBalance, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, InterestOverdueDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, LoanState)
SELECT @importId AS ImportId, O.Alias1, L.CustomerName, L.CapitalAmount, 'xxx' AS DangerLevel
	, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest
	, L.LoanStartDate, L.LoanEndDate
	, OverdueDays = CASE WHEN L.LoanEndDate < @monthLastDay THEN DATEDIFF(day, L.LoanEndDate, @monthLastDay) ELSE 0 END
	, OweInterestDays = CASE WHEN L.CustomerType = '��˽' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
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
WHERE LoanState = '��Ӧ��' AND L.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
ORDER BY L.Id
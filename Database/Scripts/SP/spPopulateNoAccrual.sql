IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spPopulateNoAccrual') BEGIN
	DROP PROCEDURE spPopulateNoAccrual
END
GO

CREATE PROCEDURE spPopulateNoAccrual
	@importId int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @asOfDate as smalldatetime
	SELECT @asOfDate = ImportDate FROM Import WHERE Id = @importId

	DELETE FROM ReportLoanRiskPerMonthFYJ WHERE ImportId = @importId

	INSERT INTO ReportLoanRiskPerMonthFYJ(ImportId, LoanAccount, OrgName, CustomerName, LoanBalance, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, InterestOverdueDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, LoanState)
	SELECT @importId AS ImportId, L.LoanAccount, O.Alias1, L.CustomerName, L.CapitalAmount, 'xxx' AS DangerLevel
		, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest
		, L.LoanStartDate, L.LoanEndDate
		, OverdueDays = CASE WHEN L.LoanEndDate < @asOfDate THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END
		, OweInterestDays = CASE WHEN L.CustomerType = '对私' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END
		, DanBaoFangShi = ISNULL(NA.DanBaoFangShi, OD.DanBaoFangShi)
		, Industry = ISNULL(PV.Direction1, PB.Direction1)
		, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)
		, LoanType = L.LoanTypeName
		, IsNew = '否'
		, Comment = L.LoanState
	FROM ImportLoan L
		LEFT JOIN Org O ON L.OrgNo = O.Number
		LEFT JOIN ImportPrivate PV ON PV.CustomerName = L.CustomerName AND PV.ContractStartDate = L.LoanStartDate AND PV.ContractEndDate = L.LoanEndDate AND PV.OrgNo = L.OrgNo AND PV.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 3)
		LEFT JOIN ImportPublic PB ON PB.FContractNo = L.LoanAccount AND PB.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 2)
		LEFT JOIN ImportNonAccrual NA ON L.LoanAccount = NA.LoanAccount AND NA.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 4)
		LEFT JOIN ImportOverdue OD ON L.LoanAccount = OD.LoanAccount AND OD.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 5)
	WHERE LoanState = '非应计' AND L.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1)
	ORDER BY L.Id

	--Update IsNew column
	UPDATE ReportLoanRiskPerMonthFYJ SET IsNew = '是'
	WHERE ImportId = @importId
		AND NOT EXISTS(SELECT * FROM ReportLoanRiskPerMonthFYJ R WHERE R.ImportId IN (SELECT Id FROM Import WHERE ImportDate < @asOfDate) AND R.LoanAccount = ReportLoanRiskPerMonthFYJ.LoanAccount)
END

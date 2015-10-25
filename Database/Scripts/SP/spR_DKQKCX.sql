IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spR_DKQKCX') BEGIN
	DROP PROCEDURE spR_DKQKCX
END
GO

CREATE PROCEDURE spR_DKQKCX
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT Id, OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, DangerLevel, LoanAmount, CapitalAmount
		, OweCapital, OweYingShouInterest, OweCuiShouInterest, DueBillNo, CONVERT(VARCHAR(8), LoanStartDate, 112), CONVERT(VARCHAR(8), LoanEndDate, 112), LoanState, LoanTypeName, Direction, CONVERT(VARCHAR(8), InterestEndDate, 112)
	FROM ImportLoan
	WHERE ImportId = @importId
END


IF EXISTS(SELECT * FROM sys.views WHERE name = 'ImportLoanSFView') BEGIN
	DROP VIEW dbo.ImportLoanSFView
END
GO

CREATE VIEW dbo.ImportLoanSFView   
AS
	SELECT Id, ImportId, OrgId, OrgId4Report, DangerLevel, OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, CurrencyType, LoanAmount, CapitalAmount, OweCapital, OweYingShouInterest, OweCuiShouInterest, DueBillNo, LoanStartDate, LoanEndDate, ZhiHuanZhuanRang, HeXiaoFlag, LoanState, LoanType, LoanTypeName, Direction, ZhuanLieYuQi, ZhuanLieFYJ, InterestEndDate, LiLvType, LiLvSymbol, LiLvJiaJianMa, YuQiLiLvYiJu, YuQiLiLvType, YuQiLiLvSymbol, YuQiLiLvJiaJianMa, LiLvYiJu, ContractInterestRatio, ContractOverdueInterestRate, ChargeAccount FROM ImportLoan WHERE OrgId IN (SELECT Id FROM dbo.sfGetOrgsOf('SF'))
	UNION ALL
	SELECT NULL AS Id, ImportId, OrgId, OrgId AS OrgId4Report, DangerLevel, OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, CurrencyType, LoanAmount, CapitalAmount, OweCapital, OweYingShouInterest, OweCuiShouInterest, DueBillNo, LoanStartDate, LoanEndDate, ZhiHuanZhuanRang, HeXiaoFlag, LoanState, LoanType, LoanTypeName, Direction, ZhuanLieYuQi, ZhuanLieFYJ, InterestEndDate, LiLvType, LiLvSymbol, LiLvJiaJianMa, YuQiLiLvYiJu, YuQiLiLvType, YuQiLiLvSymbol, YuQiLiLvJiaJianMa, LiLvYiJu, ContractInterestRatio, ContractOverdueInterestRate, ChargeAccount FROM ImportLoanSF
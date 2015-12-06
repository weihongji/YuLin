IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetLoanBalance]') AND type = N'FN') BEGIN
	DROP FUNCTION dbo.sfGetLoanBalance
END
GO

CREATE FUNCTION dbo.sfGetLoanBalance(
	@asOfDate as smalldatetime,
	@type as smallint /* 0: 全部, 1: 公司, 2: 个人 */
)
RETURNS money
AS
BEGIN
	RETURN dbo.sfGetLoanBalanceOf(@asOfDate, @type, 1001)
END

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetLoanBalanceSF]') AND type = N'FN') BEGIN
	DROP FUNCTION dbo.sfGetLoanBalanceSF
END
GO

CREATE FUNCTION dbo.sfGetLoanBalanceSF(
	@asOfDate as smalldatetime,
	@type as smallint /* 0: 全部, 1: 公司, 2: 个人 */
)
RETURNS money
AS
BEGIN
	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	IF @type IS NULL OR (@type != 1 AND @type != 2) BEGIN
		SET @type = 0
	END

	DECLARE @balance money
	SELECT @balance = SUM(CapitalAmount) FROM ImportLoanSFView
	WHERE ImportId = @importId
		AND (@type = 0
			OR @type = 1 AND CustomerType = '对公'
			OR @type = 2 AND CustomerType = '对私'
		)

	RETURN ISNULL(@balance, 0)
END

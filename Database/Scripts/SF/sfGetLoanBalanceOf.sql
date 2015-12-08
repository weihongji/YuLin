IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetLoanBalanceOf]') AND type = N'FN') BEGIN
	DROP FUNCTION dbo.sfGetLoanBalanceOf
END
GO

CREATE FUNCTION dbo.sfGetLoanBalanceOf(
	@asOfDate as smalldatetime,
	@type as smallint, /* 0: 全部, 1: 公司, 2: 个人, xxxx: 科目代号 */
	@orgId as int
)
RETURNS money
AS
BEGIN
	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	IF @type IS NULL BEGIN
		SET @type = 0
	END

	DECLARE @balance money
	SELECT @balance = SUM(CurrentDebitBalance) FROM ImportYWNei
	WHERE ImportId = @importId AND SubjectCode BETWEEN '1301' AND '1382'
		AND OrgId = @orgId
		AND (@type = 0
			OR @type = 1 AND SubjectName NOT LIKE '%个人%'
			OR @type = 2 AND SubjectName LIKE '%个人%'
			OR @type BETWEEN 1000 AND 9999 AND SubjectCode = CAST(@type AS varchar)
		)

	RETURN ISNULL(@balance, 0)
END

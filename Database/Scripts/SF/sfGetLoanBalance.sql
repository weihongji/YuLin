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
	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	IF @type IS NULL OR (@type != 1 AND @type != 2) BEGIN
		SET @type = 0
	END

	DECLARE @balance money
	SELECT @balance = SUM(CurrentDebitBalance) FROM ImportYWNei
	WHERE ImportId = @importId AND SubjectCode BETWEEN '1301' AND '1382'
		AND (@type = 0
			OR @type = 1 AND SubjectName NOT LIKE '%个人%'
			OR @type = 2 AND SubjectName LIKE '%个人%'
		)

	RETURN @balance
END

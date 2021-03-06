IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetMonthsInFuture]')) BEGIN
	DROP FUNCTION dbo.sfGetMonthsInFuture
END
GO

CREATE FUNCTION dbo.sfGetMonthsInFuture()
RETURNS @result TABLE (
		[Date] smalldatetime NOT NULL
)
AS
BEGIN
	DECLARE @startDate smalldatetime = CONVERT(varchar(6), GETDATE(), 112) + '01'

	INSERT INTO @result([Date])
	SELECT DATEADD(MONTH, Id - 1, @startDate) FROM Serial WHERE Id BETWEEN 1 AND 13 ORDER BY Id

	RETURN
END

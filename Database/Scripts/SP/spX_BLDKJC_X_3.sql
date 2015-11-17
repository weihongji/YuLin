IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_BLDKJC_X_3') BEGIN
	DROP PROCEDURE spX_BLDKJC_X_3
END
GO

CREATE PROCEDURE spX_BLDKJC_X_3
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20151031'--'20150930'

	DECLARE @asOfDateLastTenDays as smalldatetime
	DECLARE @asOfDateLastMonth as smalldatetime = @asOfDate - DAY(@asOfDate) -- Last day of previous month
	DECLARE @asOfDateYearStart as smalldatetime = CAST(Year(@asOfDate) AS varchar(4)) + '0101'

	SET @asOfDateYearStart = @asOfDateYearStart - 1 --从五级分类方面考虑，取去年年终的日期更合理

	SET @asOfDateLastTenDays =
		CASE
			WHEN DAY(@asOfDate) <= 10 THEN @asOfDateLastMonth
			WHEN DAY(@asOfDate) <= 20 THEN CONVERT(varchar(6), @asOfDate, 112) + '10'
			ELSE CONVERT(varchar(6), @asOfDate, 112) + '20'
		END

	--SELECT @asOfDateLastTenDays AS LastTenDays, @asOfDateLastMonth AS LastMonth, @asOfDateYearStart AS YearStart

	IF OBJECT_ID('tempdb..#Today') IS NOT NULL BEGIN
		DROP TABLE #Today
		DROP TABLE #LastTenDays
		DROP TABLE #LastMonth
		DROP TABLE #YearStart
	END
	SELECT * INTO #Today FROM Shell_01 WHERE 1=2
	SELECT * INTO #LastTenDays FROM Shell_01 WHERE 1=2
	SELECT * INTO #LastMonth FROM Shell_01 WHERE 1=2
	SELECT * INTO #YearStart FROM Shell_01 WHERE 1=2

	INSERT INTO #Today EXEC spX_BLDKJC_X_3_Single @asOfDate
	INSERT INTO #LastTenDays EXEC spX_BLDKJC_X_3_Single @asOfDateLastTenDays
	INSERT INTO #LastMonth EXEC spX_BLDKJC_X_3_Single @asOfDateLastMonth
	INSERT INTO #YearStart EXEC spX_BLDKJC_X_3_Single @asOfDateYearStart

	/* Result to output */
	SELECT T.Id, T.Name, T.Amount, DiffLastTenDays = T.Amount - D.Amount, DiffLastMonth = T.Amount - M.Amount, DiffYearStart = T.Amount - Y.Amount
	FROM #Today T
		INNER JOIN #LastTenDays D ON T.Id = D.Id
		INNER JOIN #LastMonth   M ON T.Id = M.Id
		INNER JOIN #YearStart   Y ON T.Id = Y.Id
	ORDER BY T.Id

	DROP TABLE #Today
	DROP TABLE #LastTenDays
	DROP TABLE #LastMonth
	DROP TABLE #YearStart
END

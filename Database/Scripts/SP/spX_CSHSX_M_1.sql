IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_CSHSX_M_1') BEGIN
	DROP PROCEDURE spX_CSHSX_M_1
END
GO

CREATE PROCEDURE spX_CSHSX_M_1
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20151031'--'20150930'

	DECLARE @asOfDateLastMonth as smalldatetime = @asOfDate - DAY(@asOfDate) -- Last day of previous month
	DECLARE @asOfDateYearStart as smalldatetime = CAST(Year(@asOfDate) AS varchar(4)) + '0101'

	SET @asOfDateYearStart = @asOfDateYearStart - 1 --从五级分类方面考虑，取去年年终的日期更合理

	IF OBJECT_ID('tempdb..#Today') IS NOT NULL BEGIN
		DROP TABLE #Today
		DROP TABLE #LastMonth
		DROP TABLE #YearStart
	END
	CREATE TABLE #Today(
		Id int,
		Name nvarchar(50),
		Total decimal(15, 2),
		ZC decimal(15, 2),
		GZ decimal(15, 2),
		CJ decimal(15, 2),
		KY decimal(15, 2),
		SS decimal(15, 2)
	)
	SELECT * INTO #LastMonth FROM #Today WHERE 1=2
	SELECT * INTO #YearStart FROM #Today WHERE 1=2

	INSERT INTO #Today EXEC spX_CSHSX_M_1_Single @asOfDate
	INSERT INTO #LastMonth EXEC spX_CSHSX_M_1_Single @asOfDateLastMonth
	INSERT INTO #YearStart EXEC spX_CSHSX_M_1_Single @asOfDateYearStart

	/* Result to output */
	--各项贷款	较上月增减	较年初增减	正常类贷款	较上月增减	较年初增减	关注类贷款	较上月增减	较年初增减	次级类贷款	较上月增减	较年初增减	可疑类贷款	较上月增减	较年初增减	损失类贷款	较上月增减	较年初增减
	SELECT T.Id, T.Name
		, T.Total
		, Total_DiffLastMonth = T.Total - M.Total
		, Total_DiffYearStart = T.Total - Y.Total
		, T.ZC
		, ZC_DiffLastMonth = T.ZC - M.ZC
		, ZC_DiffYearStart = T.ZC - Y.ZC
		, T.GZ
		, GZ_DiffLastMonth = T.GZ - M.GZ
		, GZ_DiffYearStart = T.GZ - Y.GZ
		, T.CJ
		, CJ_DiffLastMonth = T.CJ - M.CJ
		, CJ_DiffYearStart = T.CJ - Y.CJ
		, T.KY
		, KY_DiffLastMonth = T.KY - M.KY
		, KY_DiffYearStart = T.KY - Y.KY
		, T.SS
		, SS_DiffLastMonth = T.SS - M.SS
		, SS_DiffYearStart = T.SS - Y.SS
	FROM #Today T
		INNER JOIN #LastMonth M ON T.Id = M.Id
		INNER JOIN #YearStart Y ON T.Id = Y.Id
	ORDER BY T.Id

	DROP TABLE #Today
	DROP TABLE #LastMonth
	DROP TABLE #YearStart
END

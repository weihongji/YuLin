IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF1301_081') BEGIN
	DROP PROCEDURE spGF1301_081
END
GO

CREATE PROCEDURE spGF1301_081
	@asOfDate as smalldatetime,
	@type as varchar(20) = 'GZ'
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	IF @type <> 'CJ' AND @type <> 'KY' AND @type <> 'SS' BEGIN
		SET @type = 'GZ'
	END

	SELECT TOP 10 CustomerName, IdCode
		, Balance = CAST(ROUND(ISNULL(Balance, 0), 2) AS money)
		, OweCapital = CAST(ROUND(ISNULL(OweCapital, 0), 2) AS money)
		, OweInterest = CAST(ROUND(ISNULL(OweInterestAmount, 0), 2) AS money)
		, OverdueDays = CASE WHEN OverdueDays > OweInterestDays THEN OverdueDays ELSE OweInterestDays END
	FROM (
			SELECT TOP 10 P.CustomerName, P.OrgCode AS IdCode
				, Balance = SUM(L.CapitalAmount)/10000
				, OweCapital = SUM(L.OweCapital)/10000
				, OweInterestAmount = SUM(L.OweYingShouInterest + L.OweCuiShouInterest)/10000
				, OverdueDays = MAX(CASE WHEN L.LoanEndDate < @asOfDate AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END)
				, OweInterestDays = MAX(P.OweInterestDays)
			FROM ImportPublic P INNER JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%神木%' AND P.OrgName2 NOT LIKE '%府谷%'
				AND (
					@type = 'GZ' AND L.DangerLevel LIKE '关%'
					OR @type = 'CJ' AND L.DangerLevel = '次级'
					OR @type = 'KY' AND L.DangerLevel = '可疑'
					OR @type = 'SS' AND L.DangerLevel = '损失'
				)
			GROUP BY P.CustomerName, P.OrgCode
			ORDER BY Balance DESC
			UNION ALL
			SELECT TOP 10 P.CustomerName, P.IdCardNo AS IdCode
				, Balance = SUM(L.CapitalAmount)/10000
				, OweCapital = SUM(L.OweCapital)/10000
				, OweInterestAmount = SUM(L.OweYingShouInterest + L.OweCuiShouInterest)/10000
				, OverdueDays = MAX(CASE WHEN L.LoanEndDate < @asOfDate AND L.CapitalAmount > 0 THEN DATEDIFF(day, L.LoanEndDate, @asOfDate) ELSE 0 END)
				, OweInterestDays = MAX(P.InterestOverdueDays)
			FROM ImportPrivate P INNER JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%神木%' AND P.OrgName2 NOT LIKE '%府谷%'
				AND (
					@type = 'GZ' AND L.DangerLevel LIKE '关%'
					OR @type = 'CJ' AND L.DangerLevel = '次级'
					OR @type = 'KY' AND L.DangerLevel = '可疑'
					OR @type = 'SS' AND L.DangerLevel = '损失'
				)
			GROUP BY P.CustomerName, P.IdCardNo
			ORDER BY Balance DESC
		) AS X
	ORDER BY Balance DESC, IdCode

END


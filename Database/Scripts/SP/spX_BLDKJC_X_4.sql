IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_BLDKJC_X_4') BEGIN
	DROP PROCEDURE spX_BLDKJC_X_4
END
GO

CREATE PROCEDURE spX_BLDKJC_X_4
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20151031'
	
	DECLARE @asOfDateLastMonth as smalldatetime = @asOfDate - DAY(@asOfDate) -- Last day of previous month
	DECLARE @asOfDateYearStart as smalldatetime = CAST(Year(@asOfDate) AS varchar(4)) + '0101'
	SET @asOfDateYearStart = @asOfDateYearStart - 1 --从五级分类方面考虑，取去年年终的日期更合理

	DECLARE @importId int
	DECLARE @importIdWJFL int
	DECLARE @importIdLastMonth int
	DECLARE @importIdYearStart int

	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate
	SELECT @importIdWJFL = dbo.sfGetImportIdWJFL(@asOfDate)
	SELECT @importIdLastMonth = Id FROM Import WHERE ImportDate = @asOfDateLastMonth
	SELECT @importIdYearStart = Id FROM Import WHERE ImportDate = @asOfDateYearStart

	--SELECT @importId, @importIdWJFL, @importIdLastMonth, @importIdYearStart

	SELECT LoanAccount, DangerLevel, DanBaoFangShi, CustomerType
	INTO #WjflSF_Distinct
	FROM ImportWjflSF
	WHERE ImportId = @importIdWJFL
	GROUP BY LoanAccount, DangerLevel, DanBaoFangShi, CustomerType

	DECLARE @totalBL money
	SELECT @totalBL = SUM(CapitalAmount)/10000
	FROM (
		SELECT L.CapitalAmount
		FROM ImportLoan L
			INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
		WHERE L.ImportId = @importId AND L.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
			AND W.DangerLevel IN ('次级', '可疑', '损失')
		UNION ALL
		SELECT L.CapitalAmount
		FROM ImportLoanSF L
			INNER JOIN ImportLoanSF W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
		WHERE L.ImportId = @importId
			AND W.DangerLevel IN ('次级', '可疑', '损失')
	) AS X

	SELECT TOP 10 CustomerName
		, Balance = CAST(ROUND(ISNULL(Balance, 0), 2) AS money)
		, DiffLastMonth = CAST(ROUND(ISNULL(Balance, 0) - ISNULL(MBalance, 0.0), 2) AS money)
		, DiffYearStart = CAST(ROUND(ISNULL(Balance, 0) - ISNULL(YBalance, 0.0), 2) AS money)
		, Ratio = CASE WHEN ISNULL(@totalBL, 0) = 0 THEN 0.00 ELSE CAST(ROUND(ISNULL(Balance/@totalBL, 0), 4) AS money) END
		, LoanStartDate
		, LoanAmount
		, D.Category
	FROM (
			-- 榆林
			SELECT TOP 10 P.CustomerName, IdCode = P.OrgCode, DanBaoName = MAX(P.VouchTypeName)
				, Balance = SUM(L.CapitalAmount)/10000
				, LoanAmount = SUM(L.LoanAmount)/10000
				, LoanStartDate = MIN(L.LoanStartDate)
				, MBalance = (
					SELECT Balance = SUM(L1.CapitalAmount)/10000
					FROM ImportLoan L1
						INNER JOIN ImportPublic P1 ON L1.LoanAccount = P1.LoanAccount AND P1.ImportId = L1.ImportId
					WHERE L1.ImportId = @importIdLastMonth AND L1.DangerLevel IN ('次级', '可疑', '损失')
						AND ISNULL(P1.OrgCode, '') = ISNULL(P.OrgCode, '') AND P1.CustomerName = P.CustomerName
				)
				, YBalance = (
					SELECT Balance = SUM(L1.CapitalAmount)/10000
					FROM ImportLoan L1
						INNER JOIN ImportPublic P1 ON L1.LoanAccount = P1.LoanAccount AND P1.ImportId = L1.ImportId
					WHERE L1.ImportId = @importIdYearStart AND L1.DangerLevel IN ('次级', '可疑', '损失')
						AND ISNULL(P1.OrgCode, '') = ISNULL(P.OrgCode, '') AND P1.CustomerName = P.CustomerName
				)
			FROM ImportLoan L
				INNER JOIN ImportLoan   W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
				AND W.DangerLevel IN ('次级', '可疑', '损失')
			GROUP BY P.CustomerName, P.OrgCode
			ORDER BY Balance DESC

			UNION ALL

			SELECT TOP 10 P.CustomerName, IdCode = P.IdCardNo, DanBaoName = MAX(P.DanBaoFangShi)
				, Balance = SUM(L.CapitalAmount)/10000
				, LoanAmount = SUM(L.LoanAmount)/10000
				, LoanStartDate = MIN(L.LoanStartDate)
				, MBalance = (
					SELECT Balance = SUM(L1.CapitalAmount)/10000
					FROM ImportLoan L1
						INNER JOIN ImportPrivate P1 ON L1.LoanAccount = P1.LoanAccount AND P1.ImportId = L1.ImportId
					WHERE L1.ImportId = @importIdLastMonth AND L1.DangerLevel IN ('次级', '可疑', '损失')
						AND ISNULL(P1.IdCardNo, '') = ISNULL(P.IdCardNo, '') AND P1.CustomerName = P.CustomerName
				)
				, YBalance = (
					SELECT Balance = SUM(L1.CapitalAmount)/10000
					FROM ImportLoan L1
						INNER JOIN ImportPrivate P1 ON L1.LoanAccount = P1.LoanAccount AND P1.ImportId = L1.ImportId
					WHERE L1.ImportId = @importIdYearStart AND L1.DangerLevel IN ('次级', '可疑', '损失')
						AND ISNULL(P1.IdCardNo, '') = ISNULL(P.IdCardNo, '') AND P1.CustomerName = P.CustomerName
				)
			FROM ImportLoan L
				INNER JOIN ImportLoan    W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
				AND W.DangerLevel IN ('次级', '可疑', '损失')
			GROUP BY P.CustomerName, P.IdCardNo
			ORDER BY Balance DESC
			
			UNION ALL

			-- 神府
			SELECT TOP 10 L.CustomerName, IdCode = '', DanBaoName = MAX(W.DanBaoFangShi)
				, Balance = SUM(L.CapitalAmount)/10000
				, LoanAmount = SUM(L.LoanAmount)/10000
				, LoanStartDate = MIN(L.LoanStartDate)
				, MBalance = (
					SELECT Balance = SUM(L1.CapitalAmount)/10000
					FROM ImportLoanSF L1
					WHERE L1.ImportId = @importIdLastMonth AND L1.DangerLevel IN ('次级', '可疑', '损失')
				)
				, YBalance = (
					SELECT Balance = SUM(L1.CapitalAmount)/10000
					FROM ImportLoanSF L1
					WHERE L1.ImportId = @importIdYearStart AND L1.DangerLevel IN ('次级', '可疑', '损失')
				)
			FROM ImportLoanSF L
				INNER JOIN #WjflSF_Distinct W ON L.LoanAccount = W.LoanAccount
			WHERE L.ImportId = @importId
				AND W.DangerLevel IN ('次级', '可疑', '损失')
			GROUP BY L.CustomerName
			ORDER BY Balance DESC
		) AS X
		LEFT JOIN DanBaoFangShi D ON X.DanBaoName = D.Name
	ORDER BY Balance DESC, IdCode

	DROP TABLE #WjflSF_Distinct
END

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

	DECLARE @totalBL decimal(10, 2)
	SELECT @totalBL = SUM(L.CapitalAmount)/10000
	FROM ImportLoan L
		INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
	WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
		AND W.DangerLevel IN ('次级', '可疑', '损失')

	IF OBJECT_ID('tempdb..#Top10') IS NOT NULL BEGIN
		DROP TABLE #Top10
	END

	SELECT TOP 10 CustomerType, CustomerName, IdCode = ISNULL(IdCode, ''), BLBalance = CAST(ROUND(ISNULL(Balance, 0), 2) AS decimal(10, 2))
	INTO #Top10
	FROM (
			SELECT TOP 10 CustomerType = '对公', P.CustomerName, P.OrgCode AS IdCode
				, Balance = SUM(L.CapitalAmount)/10000
			FROM ImportLoan L
				INNER JOIN ImportLoan   W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
				AND W.DangerLevel IN ('次级', '可疑', '损失')
			GROUP BY P.CustomerName, P.OrgCode
			ORDER BY Balance DESC
			UNION ALL
			SELECT TOP 10 CustomerType = '对私', P.CustomerName, P.IdCardNo AS IdCode
				, Balance = SUM(L.CapitalAmount)/10000
			FROM ImportLoan L
				INNER JOIN ImportLoan    W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgNo NOT IN (SELECT Number FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
				AND W.DangerLevel IN ('次级', '可疑', '损失')
			GROUP BY P.CustomerName, P.IdCardNo
			ORDER BY Balance DESC
		) AS X
	ORDER BY Balance DESC, IdCode

	SELECT IdCode, CustomerName, BLBalance, DiffLastMonth, DiffYearStart
		, BLRatio = CASE WHEN ISNULL(@totalBL, 0) = 0 THEN 0.00 ELSE CAST(ROUND(ISNULL(BLBalance/@totalBL, 0), 4) AS decimal(10, 4)) END
		, LoanStartDate
		, TotalBalance = CAST(ROUND(ISNULL(TotalBalance, 0), 2) AS decimal(10, 2))
		, DanBao = D.Category
	FROM (
			--Publics
			SELECT T.IdCode, T.CustomerName, T.BLBalance
				, DiffLastMonth = T.BLBalance - ISNULL(M.Balance, 0.0)
				, DiffYearStart = T.BLBalance - ISNULL(Y.Balance, 0.0)
				, P.LoanStartDate
				, A.TotalBalance
				, DanBaoName = P.VouchTypeName
			FROM #Top10 T
				LEFT JOIN (
					SELECT T1.CustomerName, T1.IdCode
						, LoanAccount = (SELECT TOP 1 LoanAccount FROM ImportPublic P1 WHERE P1.ImportId = @importIdWJFL AND ISNULL(P1.OrgCode, '') = T1.IdCode AND P1.CustomerName = T1.CustomerName AND P1.LoanStartDate = MIN(L.LoanStartDate) ORDER BY P1.Id)
						, TotalBalance = SUM(L.CapitalAmount)/10000
					FROM ImportLoan L
						INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
						INNER JOIN #Top10 T1 ON ISNULL(P.OrgCode, '') = T1.IdCode AND P.CustomerName = T1.CustomerName
					WHERE L.ImportId = @importId
					GROUP BY T1.CustomerName, T1.IdCode
				) AS A ON T.CustomerName = A.CustomerName AND T.IdCode = A.IdCode
				INNER JOIN ImportPublic P ON A.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
				LEFT JOIN (
					SELECT T1.CustomerName, T1.IdCode, Balance = CAST(ROUND(ISNULL(SUM(L.CapitalAmount)/10000, 0), 2) AS decimal(10, 2))
					FROM ImportLoan L
						INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND P.ImportId = L.ImportId
						INNER JOIN #Top10 T1 ON ISNULL(P.OrgCode, '') = T1.IdCode AND P.CustomerName = T1.CustomerName
					WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('次级', '可疑', '损失')
					GROUP BY T1.CustomerName, T1.IdCode
				) M ON T.CustomerName = M.CustomerName AND T.IdCode = M.IdCode
				LEFT JOIN (
					SELECT T1.CustomerName, T1.IdCode, Balance = CAST(ROUND(ISNULL(SUM(L.CapitalAmount)/10000, 0), 2) AS decimal(10, 2))
					FROM ImportLoan L
						INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND P.ImportId = L.ImportId
						INNER JOIN #Top10 T1 ON ISNULL(P.OrgCode, '') = T1.IdCode AND P.CustomerName = T1.CustomerName
					WHERE L.ImportId = @importIdYearStart AND L.DangerLevel IN ('次级', '可疑', '损失')
					GROUP BY T1.CustomerName, T1.IdCode
				) Y ON T.CustomerName = M.CustomerName AND T.IdCode = M.IdCode
			WHERE T.CustomerType = '对公'
	
			UNION ALL

			--Privates
			SELECT T.IdCode, T.CustomerName, T.BLBalance
				, DiffLastMonth = T.BLBalance - ISNULL(M.Balance, 0.0)
				, DiffYearStart = T.BLBalance - ISNULL(Y.Balance, 0.0)
				, P.ContractStartDate
				, A.TotalBalance
				, P.DanBaoFangShi
			FROM #Top10 T
				LEFT JOIN (
					SELECT T1.CustomerName, T1.IdCode
						, LoanAccount = (SELECT TOP 1 LoanAccount FROM ImportPrivate P1 WHERE P1.ImportId = @importIdWJFL AND ISNULL(P1.IdCardNo, '') = T1.IdCode AND P1.CustomerName = T1.CustomerName AND P1.ContractStartDate = MIN(L.LoanStartDate) ORDER BY P1.Id)
						, TotalBalance = SUM(L.CapitalAmount)/10000
					FROM ImportLoan L
						INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
						INNER JOIN #Top10 T1 ON ISNULL(P.IdCardNo, '') = T1.IdCode AND P.CustomerName = T1.CustomerName
					WHERE L.ImportId = @importId
					GROUP BY T1.CustomerName, T1.IdCode
				) AS A ON T.CustomerName = A.CustomerName AND T.IdCode = A.IdCode
				INNER JOIN ImportPrivate P ON A.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
				LEFT JOIN (
					SELECT T1.CustomerName, T1.IdCode, Balance = CAST(ROUND(ISNULL(SUM(L.CapitalAmount)/10000, 0), 2) AS decimal(10, 2))
					FROM ImportLoan L
						INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = L.ImportId
						INNER JOIN #Top10 T1 ON ISNULL(P.IdCardNo, '') = T1.IdCode AND P.CustomerName = T1.CustomerName
					WHERE L.ImportId = @importIdLastMonth AND L.DangerLevel IN ('次级', '可疑', '损失')
					GROUP BY T1.CustomerName, T1.IdCode
				) M ON T.CustomerName = M.CustomerName AND T.IdCode = M.IdCode
				LEFT JOIN (
					SELECT T1.CustomerName, T1.IdCode, Balance = CAST(ROUND(ISNULL(SUM(L.CapitalAmount)/10000, 0), 2) AS decimal(10, 2))
					FROM ImportLoan L
						INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = L.ImportId
						INNER JOIN #Top10 T1 ON ISNULL(P.IdCardNo, '') = T1.IdCode AND P.CustomerName = T1.CustomerName
					WHERE L.ImportId = @importIdYearStart AND L.DangerLevel IN ('次级', '可疑', '损失')
					GROUP BY T1.CustomerName, T1.IdCode
				) Y ON T.CustomerName = M.CustomerName AND T.IdCode = M.IdCode
			WHERE T.CustomerType = '对私'
		) AS X
		LEFT JOIN DanBaoFangShi D ON X.DanBaoName = D.Name
	ORDER BY BLBalance DESC, IdCode

END

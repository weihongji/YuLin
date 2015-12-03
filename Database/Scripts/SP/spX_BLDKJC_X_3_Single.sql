IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_BLDKJC_X_3_Single') BEGIN
	DROP PROCEDURE spX_BLDKJC_X_3_Single
END
GO

CREATE PROCEDURE spX_BLDKJC_X_3_Single
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20150930'--'20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate
	DECLARE @importIdWJFL int = dbo.sfGetImportIdWJFL(@asOfDate)

	IF OBJECT_ID('tempdb..#YL') IS NOT NULL BEGIN
		DROP TABLE #YL
		DROP TABLE #SF
		DROP TABLE #WjflSF_Distinct
	END
	SELECT * INTO #YL FROM Shell_01 WHERE 1=2
	SELECT * INTO #SF FROM Shell_01 WHERE 1=2

	-- 榆林
	INSERT INTO #YL (Id, Name, Amount)
	SELECT Id, Name AS Direction, CAST(ROUND(ISNULL(Balance, 0)/10000, 2) AS money) AS Balance
	FROM (
			SELECT 0 AS Id, '法人类不良贷款余额' AS Name, SUM(L.CapitalAmount) AS Balance
			FROM ImportLoan L
				INNER JOIN ImportLoan W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND L.CustomerType = '对公'
			UNION ALL
			SELECT D.Id, D.Name, B.Balance
			FROM Direction D
				LEFT JOIN (
					SELECT P.Direction1, SUM(L.CapitalAmount) AS Balance
					FROM ImportLoan L
						INNER JOIN ImportLoan   W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
						INNER JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
					WHERE L.ImportId = @importId AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
						AND W.DangerLevel IN ('次级', '可疑', '损失')
					GROUP BY Direction1
				) AS B ON D.Name = B.Direction1
			WHERE D.Id <= 19
			UNION ALL
			SELECT 101, '信用卡', SUM(L.CapitalAmount)
			FROM ImportLoan L
				INNER JOIN ImportLoan    W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND P.ProductName LIKE '%公务卡%'
			UNION ALL
			SELECT 102, '汽车', SUM(L.CapitalAmount)
			FROM ImportLoan L
				INNER JOIN ImportLoan    W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND P.ProductName LIKE '%汽车%'
			UNION ALL
			SELECT 103, '住房按揭贷款', SUM(L.CapitalAmount)
			FROM ImportLoan L
				INNER JOIN ImportLoan    W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND P.ProductName LIKE '%住房%'
			UNION ALL
			SELECT 104, '个人经营性贷款', SUM(L.CapitalAmount)
			FROM ImportLoan L
				INNER JOIN ImportLoan    W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND P.ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
			UNION ALL
			SELECT 105, '其他', SUM(L.CapitalAmount)
			FROM ImportLoan L
				INNER JOIN ImportLoan    W ON L.LoanAccount = W.LoanAccount AND W.ImportId = @importIdWJFL
				INNER JOIN ImportPrivate P ON L.LoanAccount = P.LoanAccount AND P.ImportId = @importIdWJFL
			WHERE L.ImportId = @importId AND L.OrgId NOT IN (SELECT Id FROM Org WHERE Name LIKE '%神木%' OR Name LIKE '%府谷%')
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND P.ProductName NOT LIKE '%公务卡%'
				AND P.ProductName NOT LIKE '%汽车%'
				AND P.ProductName NOT LIKE '%住房%'
				AND P.ProductName NOT IN ('个人经营贷款', '个人质押贷款(经营类)')
		) AS X

	-- 神府
	SELECT LoanAccount, DangerLevel, Industry, CustomerType
	INTO #WjflSF_Distinct
	FROM ImportWjflSF
	WHERE ImportId = @importIdWJFL
	GROUP BY LoanAccount, DangerLevel, Industry, CustomerType
	
	INSERT INTO #SF (Id, Name, Amount)
	SELECT Id, Name AS Direction, CAST(ROUND(ISNULL(Balance, 0)/10000, 2) AS money) AS Balance
	FROM (
			SELECT 0 AS Id, '法人类不良贷款余额' AS Name, SUM(L.CapitalAmount) AS Balance
			FROM ImportLoanSF L
				INNER JOIN ImportLoanSF W ON L.LoanAccount = W.LoanAccount
			WHERE L.ImportId = @importId
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND L.CustomerType = '对公'
			UNION ALL
			SELECT D.Id, D.Name, B.Balance
			FROM Direction D
				LEFT JOIN (
					SELECT W.Industry, SUM(L.CapitalAmount) AS Balance
					FROM ImportLoanSF L
						INNER JOIN #WjflSF_Distinct W ON L.LoanAccount = W.LoanAccount
					WHERE L.ImportId = @importId
						AND W.DangerLevel IN ('次级', '可疑', '损失')
					GROUP BY Industry
				) AS B ON D.Name = B.Industry
			WHERE D.Id <= 19
			UNION ALL
			SELECT 101, '信用卡', SUM(L.CapitalAmount)
			FROM ImportLoanSF L
				INNER JOIN #WjflSF_Distinct W ON L.LoanAccount = W.LoanAccount
			WHERE L.ImportId = @importId
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND L.CustomerType = '对私'
				AND W.CustomerType LIKE '%公务卡%'
			UNION ALL
			SELECT 102, '汽车', SUM(L.CapitalAmount)
			FROM ImportLoanSF L
				INNER JOIN #WjflSF_Distinct W ON L.LoanAccount = W.LoanAccount
			WHERE L.ImportId = @importId
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND L.CustomerType = '对私'
				AND W.CustomerType LIKE '%汽车%'
			UNION ALL
			SELECT 103, '住房按揭贷款', SUM(L.CapitalAmount)
			FROM ImportLoanSF L
				INNER JOIN #WjflSF_Distinct W ON L.LoanAccount = W.LoanAccount
			WHERE L.ImportId = @importId
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND L.CustomerType = '对私'
				AND W.CustomerType LIKE '%住房%'
			UNION ALL
			SELECT 104, '个人经营性贷款', SUM(L.CapitalAmount)
			FROM ImportLoanSF L
				INNER JOIN #WjflSF_Distinct W ON L.LoanAccount = W.LoanAccount
			WHERE L.ImportId = @importId
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND L.CustomerType = '对私'
				AND W.CustomerType IN ('个人经营贷款', '个人质押贷款(经营类)')
			UNION ALL
			SELECT 105, '其他', SUM(L.CapitalAmount)
			FROM ImportLoanSF L
				INNER JOIN #WjflSF_Distinct W ON L.LoanAccount = W.LoanAccount
			WHERE L.ImportId = @importId
				AND W.DangerLevel IN ('次级', '可疑', '损失')
				AND L.CustomerType = '对私'
				AND W.CustomerType NOT LIKE '%公务卡%'
				AND W.CustomerType NOT LIKE '%汽车%'
				AND W.CustomerType NOT LIKE '%住房%'
				AND W.CustomerType NOT IN ('个人经营贷款', '个人质押贷款(经营类)')
		) AS X

	SELECT Id, Name, SUM(Amount) FROM (
		SELECT * FROM #YL
		UNION ALL
		SELECT * FROM #SF
	) AS Final
	GROUP BY Id, Name
	ORDER BY Id

	DROP TABLE #YL
	DROP TABLE #SF
	DROP TABLE #WjflSF_Distinct
END

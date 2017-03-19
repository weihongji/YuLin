IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spSF6302_131') BEGIN
	DROP PROCEDURE spSF6302_131
END
GO

CREATE PROCEDURE spSF6302_131
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate smalldatetime = '20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT Id
		, A = CAST(ROUND(ISNULL(SUM(A), 0), 2) AS money)
		, B = CAST(ROUND(ISNULL(SUM(B), 0), 2) AS money)
		, C = CAST(ROUND(ISNULL(SUM(C), 0), 2) AS money)
		, D = CAST(ROUND(ISNULL(SUM(D), 0), 2) AS money)
		, E = CAST(ROUND(ISNULL(SUM(E), 0), 2) AS money)
		, F = CAST(ROUND(ISNULL(SUM(F), 0), 2) AS money)
	FROM (
			SELECT Id = 1, Category = '信用'
			UNION ALL
			SELECT Id = 2, Category = '保证'
			UNION ALL
			SELECT Id = 3, Category = '抵押'
			UNION ALL
			SELECT Id = 3, Category = '质押'
			UNION ALL
			SELECT Id = 9, Category = '贴现'
		) AS DBFS
		LEFT JOIN (
			SELECT D.Category
					, A = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
					, B = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
					, C = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
					, D = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
					, E = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
					, F = 0.00
			FROM ImportPublic P
				INNER JOIN DanBaoFangShi D ON P.VouchTypeName = D.Name
				INNER JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
				AND L.DangerLevel IN ('次级', '可疑', '损失')

			UNION ALL

			SELECT D.Category, A = 0.00, B = 0.00, C = 0.00, D = 0.00, E = 0.00, F = P.LoanBalance
			FROM ImportPrivate P
				INNER JOIN DanBaoFangShi D ON P.DanBaoFangShi = D.Name
				INNER JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
				AND ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
				AND L.DangerLevel IN ('次级', '可疑', '损失')

			UNION ALL

			SELECT Category = '贴现'
				, A = CASE WHEN ScopeName = '大型企业' THEN Balance1 ELSE 0.00 END
				, B = CASE WHEN ScopeName = '中型企业' THEN Balance1 ELSE 0.00 END
				, C = CASE WHEN ScopeName = '小型企业' THEN Balance1 ELSE 0.00 END
				, D = CASE WHEN ScopeName = '微型企业' THEN Balance1 ELSE 0.00 END
				, E = CASE WHEN ScopeName IN ('小型企业', '微型企业') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
				, F = 0.00
			FROM ImportPublic P
				INNER JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
				AND BusinessType LIKE '%贴现%'
				AND L.DangerLevel IN ('次级', '可疑', '损失')
		) AS X ON DBFS.Category = X.Category

	GROUP BY DBFS.Id
	ORDER BY DBFS.Id

END

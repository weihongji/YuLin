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
			SELECT Id = 1, Category = '����'
			UNION ALL
			SELECT Id = 2, Category = '��֤'
			UNION ALL
			SELECT Id = 3, Category = '��Ѻ'
			UNION ALL
			SELECT Id = 3, Category = '��Ѻ'
			UNION ALL
			SELECT Id = 9, Category = '����'
		) AS DBFS
		LEFT JOIN (
			SELECT D.Category
					, A = CASE WHEN ScopeName = '������ҵ' THEN Balance1 ELSE 0.00 END
					, B = CASE WHEN ScopeName = '������ҵ' THEN Balance1 ELSE 0.00 END
					, C = CASE WHEN ScopeName = 'С����ҵ' THEN Balance1 ELSE 0.00 END
					, D = CASE WHEN ScopeName = '΢����ҵ' THEN Balance1 ELSE 0.00 END
					, E = CASE WHEN ScopeName IN ('С����ҵ', '΢����ҵ') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
					, F = 0.00
			FROM ImportPublic P
				INNER JOIN DanBaoFangShi D ON P.VouchTypeName = D.Name
				INNER JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
				AND L.DangerLevel IN ('�μ�', '����', '��ʧ')

			UNION ALL

			SELECT D.Category, A = 0.00, B = 0.00, C = 0.00, D = 0.00, E = 0.00, F = P.LoanBalance
			FROM ImportPrivate P
				INNER JOIN DanBaoFangShi D ON P.DanBaoFangShi = D.Name
				INNER JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
				AND ProductName IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
				AND L.DangerLevel IN ('�μ�', '����', '��ʧ')

			UNION ALL

			SELECT Category = '����'
				, A = CASE WHEN ScopeName = '������ҵ' THEN Balance1 ELSE 0.00 END
				, B = CASE WHEN ScopeName = '������ҵ' THEN Balance1 ELSE 0.00 END
				, C = CASE WHEN ScopeName = 'С����ҵ' THEN Balance1 ELSE 0.00 END
				, D = CASE WHEN ScopeName = '΢����ҵ' THEN Balance1 ELSE 0.00 END
				, E = CASE WHEN ScopeName IN ('С����ҵ', '΢����ҵ') AND Balance1 < 500 THEN Balance1 ELSE 0.00 END
				, F = 0.00
			FROM ImportPublic P
				INNER JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs()) AND PublicType = 1
				AND BusinessType LIKE '%����%'
				AND L.DangerLevel IN ('�μ�', '����', '��ʧ')
		) AS X ON DBFS.Category = X.Category

	GROUP BY DBFS.Id
	ORDER BY DBFS.Id

END

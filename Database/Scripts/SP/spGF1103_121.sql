IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF1103_121') BEGIN
	DROP PROCEDURE spGF1103_121
END
GO

CREATE PROCEDURE spGF1103_121
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT DirectionId, Id, Name AS Direction2
		, CAST(ROUND(ISNULL(ZC, 0), 2) AS money) AS ZC
		, CAST(ROUND(ISNULL(GZ, 0), 2) AS money) AS GZ
		, CAST(ROUND(ISNULL(CJ, 0), 2) AS money) AS CJ
		, CAST(ROUND(ISNULL(KY, 0), 2) AS money) AS KY
		, CAST(ROUND(ISNULL(SS, 0), 2) AS money) AS SS
	FROM (
			SELECT DirectionId, Id, MIN(Name) AS Name
				, SUM(ZC) AS ZC, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
			FROM (
					SELECT D.DirectionId, D.Id, D.Name, B.ZC, B.GZ, B.CJ, B.KY, B.SS
					FROM Direction2 D
						LEFT JOIN (
							SELECT Direction2
								, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
								, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
							FROM (
								SELECT Direction2, Balance1 AS Balance
									, GZ = CASE WHEN L.DangerLevel LIKE '关%' THEN Balance1 ELSE 0.00 END
									, CJ = CASE WHEN L.DangerLevel = '次级' THEN Balance1 ELSE 0.00 END
									, KY = CASE WHEN L.DangerLevel = '可疑' THEN Balance1 ELSE 0.00 END
									, SS = CASE WHEN L.DangerLevel = '损失' THEN Balance1 ELSE 0.00 END
								FROM ImportPublic P LEFT JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
								WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
								UNION ALL
								SELECT Direction2, LoanBalance AS Balance
									, GZ = CASE WHEN L.DangerLevel LIKE '关%' THEN LoanBalance ELSE 0.00 END
									, CJ = CASE WHEN L.DangerLevel = '次级' THEN LoanBalance ELSE 0.00 END
									, KY = CASE WHEN L.DangerLevel = '可疑' THEN LoanBalance ELSE 0.00 END
									, SS = CASE WHEN L.DangerLevel = '损失' THEN LoanBalance ELSE 0.00 END
								FROM ImportPrivate P LEFT JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
								WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
									AND P.ProductName IN ('个人经营贷款', '个人质押贷款(经营类)')
							) AS X1
							GROUP BY Direction2
						) AS B ON D.Name = B.Direction2
				) AS X2
			GROUP BY DirectionId, Id

			UNION ALL
			SELECT 0, 101 AS Id, '个人贷款（不含个人经营性贷款）' AS Name
				, (SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS)) AS ZC
				, SUM(GZ) AS GZ, SUM(CJ) AS CJ, SUM(KY) AS KY, SUM(SS) AS SS
			FROM (
				SELECT LoanBalance AS Balance
					, GZ = CASE WHEN L.DangerLevel LIKE '关%' THEN LoanBalance ELSE 0.00 END
					, CJ = CASE WHEN L.DangerLevel = '次级' THEN LoanBalance ELSE 0.00 END
					, KY = CASE WHEN L.DangerLevel = '可疑' THEN LoanBalance ELSE 0.00 END
					, SS = CASE WHEN L.DangerLevel = '损失' THEN LoanBalance ELSE 0.00 END
				FROM ImportPrivate P LEFT JOIN ImportLoanView L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
				WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
					AND P.ProductName NOT IN ('个人经营贷款', '个人质押贷款(经营类)')
			) AS X

		) AS Final
	ORDER BY Id

END

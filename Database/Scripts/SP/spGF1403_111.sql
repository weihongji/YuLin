IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF1403_111') BEGIN
	DROP PROCEDURE spGF1403_111
END
GO

CREATE PROCEDURE spGF1403_111
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT TOP 10 CustomerName, IdCode
		, Balance = CAST(ROUND(ISNULL(Balance, 0), 2) AS decimal(10, 2))
		, ZC = CAST(ROUND(ISNULL(Balance - GZ - CJ - KY - SS, 0), 2) AS decimal(10, 2))
		, GZ = CAST(ROUND(ISNULL(GZ, 0), 2) AS decimal(10, 2))
		, CJ = CAST(ROUND(ISNULL(CJ, 0), 2) AS decimal(10, 2))
		, KY = CAST(ROUND(ISNULL(KY, 0), 2) AS decimal(10, 2))
		, SS = CAST(ROUND(ISNULL(SS, 0), 2) AS decimal(10, 2))
	FROM (
			SELECT TOP 10 CustomerName, IdCode
				, Balance = SUM(Balance), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
					SELECT P.CustomerName, P.OrgCode AS IdCode
						, Balance = P.Balance1
						, GZ = CASE WHEN L.DangerLevel LIKE '关%' THEN P.Balance1 ELSE 0.00 END
						, CJ = CASE WHEN L.DangerLevel = '次级' THEN P.Balance1 ELSE 0.00 END
						, KY = CASE WHEN L.DangerLevel = '可疑' THEN P.Balance1 ELSE 0.00 END
						, SS = CASE WHEN L.DangerLevel = '损失' THEN P.Balance1 ELSE 0.00 END
					FROM ImportPublic P INNER JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
					WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%神木%' AND P.OrgName2 NOT LIKE '%府谷%'
				) AS X
			GROUP BY CustomerName, IdCode
			ORDER BY Balance DESC
			UNION ALL
			SELECT TOP 10 CustomerName, IdCode
				, Balance = SUM(Balance), GZ = SUM(GZ), CJ = SUM(CJ), KY = SUM(KY), SS = SUM(SS)
			FROM (
					SELECT P.CustomerName, P.IdCardNo AS IdCode
						, Balance = P.LoanBalance
						, GZ = CASE WHEN L.DangerLevel LIKE '关%' THEN P.LoanBalance ELSE 0.00 END
						, CJ = CASE WHEN L.DangerLevel = '次级' THEN P.LoanBalance ELSE 0.00 END
						, KY = CASE WHEN L.DangerLevel = '可疑' THEN P.LoanBalance ELSE 0.00 END
						, SS = CASE WHEN L.DangerLevel = '损失' THEN P.LoanBalance ELSE 0.00 END
					FROM ImportPrivate P INNER JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
					WHERE P.ImportId = @importId AND P.OrgName2 NOT LIKE '%神木%' AND P.OrgName2 NOT LIKE '%府谷%'
				) AS X
			GROUP BY CustomerName, IdCode
			ORDER BY Balance DESC
		) AS X
	ORDER BY Balance DESC, IdCode

END

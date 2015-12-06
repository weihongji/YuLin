IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spGF1900_151') BEGIN
	DROP PROCEDURE spGF1900_151
END
GO

CREATE PROCEDURE spGF1900_151
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @asOfDate as smalldatetime = '20150930'

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT D.Id, D.Name
		, ZC = CAST(ROUND(ISNULL(SUM(Balance) - SUM(GZ) - SUM(CJ) - SUM(KY) - SUM(SS), 0), 2) AS money)
		, GZ = CAST(ROUND(ISNULL(SUM(GZ), 0), 2) AS money)
		, CJ = CAST(ROUND(ISNULL(SUM(CJ), 0), 2) AS money)
		, KY = CAST(ROUND(ISNULL(SUM(KY), 0), 2) AS money)
		, SS = CAST(ROUND(ISNULL(SUM(SS), 0), 2) AS money)
	FROM DirectionMix D
		LEFT JOIN (
			SELECT Direction1 = ISNULL(Direction1, '')
				, Direction2 = ISNULL(Direction2, '')
				, Direction3 = ISNULL(Direction3, '')
				, Direction4 = ISNULL(Direction4, '')
				, Balance = Balance1
				, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN Balance1 ELSE 0.00 END
				, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN Balance1 ELSE 0.00 END
				, KY = CASE WHEN L.DangerLevel = '����' THEN Balance1 ELSE 0.00 END
				, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN Balance1 ELSE 0.00 END
			FROM ImportPublic P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
			UNION ALL
			SELECT Direction1 = ISNULL(Direction1, '')
				, Direction2 = ISNULL(Direction2, '')
				, Direction3 = ISNULL(Direction3, '')
				, Direction4 = ISNULL(Direction4, '')
				, Balance = LoanBalance
				, GZ = CASE WHEN L.DangerLevel LIKE '��%' THEN LoanBalance ELSE 0.00 END
				, CJ = CASE WHEN L.DangerLevel = '�μ�' THEN LoanBalance ELSE 0.00 END
				, KY = CASE WHEN L.DangerLevel = '����' THEN LoanBalance ELSE 0.00 END
				, SS = CASE WHEN L.DangerLevel = '��ʧ' THEN LoanBalance ELSE 0.00 END
			FROM ImportPrivate P LEFT JOIN ImportLoan L ON P.ImportId = L.ImportId AND P.LoanAccount = L.LoanAccount
			WHERE P.ImportId = @importId AND P.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())
				AND P.ProductName IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
		) AS X ON D.Name IN (X.Direction1, X.Direction2, X.Direction3, X.Direction4)
	GROUP BY D.Id, D.Name
	ORDER BY Id
END

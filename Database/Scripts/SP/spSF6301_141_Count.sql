IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spSF6301_141_Count') BEGIN
	DROP PROCEDURE spSF6301_141_Count
END
GO

CREATE PROCEDURE spSF6301_141_Count
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	/* 5.����ͻ��� */
	/* 5.3���Ż��� */
	/* 5.3.1���У������ */
	SELECT SUM(Count1) AS Count1, SUM(Count2) AS Count2, SUM(Count3) AS Count3, SUM(Count4) AS Count4, SUM(Count5) AS Count5, SUM(Count6) AS Count6, SUM(Count6) AS Count7
	FROM (
			SELECT Count1 = CASE WHEN MAX(ScopeName) = '������ҵ' THEN 1 ELSE 0 END
				, Count2 = CASE WHEN MAX(ScopeName) = '������ҵ' THEN 1 ELSE 0 END
				, Count3 = CASE WHEN MAX(ScopeName) = 'С����ҵ' THEN 1 ELSE 0 END
				, Count4 = CASE WHEN MAX(ScopeName) = '΢����ҵ' THEN 1 ELSE 0 END
				, Count5 = CASE WHEN MAX(ScopeName) IN ('С����ҵ', '΢����ҵ') AND MAX(Balance1)<500 THEN 1 ELSE 0 END
				, Count6 = 0
			FROM ImportPublic
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%' AND PublicType = 1
			GROUP BY CustomerName
			UNION ALL
			SELECT Count1 = 0, Count2 = 0, Count3 = 0, Count4 = 0, Count5 = 0, 1 AS Count6
			FROM ImportPrivate
			WHERE ImportId = @importId AND OrgName2 NOT LIKE '%��ľ%' AND OrgName2 NOT LIKE '%����%'
				AND ProductName IN ('���˾�Ӫ����', '������Ѻ����(��Ӫ��)')
			GROUP BY CustomerName, IdCardNo
		) AS X
END

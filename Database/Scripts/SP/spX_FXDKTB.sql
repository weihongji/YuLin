IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spX_FXDKTB') BEGIN
	DROP PROCEDURE spX_FXDKTB
END
GO

CREATE PROCEDURE spX_FXDKTB
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT OrgNo, SUM(CapitalAmount) AS Amount, COUNT(*) AS Number, SUM(OweYingShouInterest) + SUM(OweCuiShouInterest) AS OweInterest INTO #Total FROM ImportLoan
	WHERE ImportId = @importId
	GROUP BY OrgNo

	SELECT OrgNo, SUM(CapitalAmount) AS Amount, COUNT(*) AS Number INTO #YQ FROM ImportLoan
	WHERE ImportId = @importId
		AND LoanState IN ('逾期', '部分逾期')
	GROUP BY OrgNo

	SELECT OrgNo, SUM(CapitalAmount) AS Amount, COUNT(*) AS Number INTO #BLDK FROM ImportLoan
	WHERE ImportId = @importId
		AND DangerLevel IN ('次级', '可疑', '损失')
	GROUP BY OrgNo

	SELECT OrgNo, SUM(CapitalAmount) AS Amount, COUNT(*) AS Number INTO #ZQX FROM ImportLoan
	WHERE ImportId = @importId
			AND LoanState = '正常'
			AND OweYingShouInterest + OweCuiShouInterest != 0
	GROUP BY OrgNo

	SELECT O.Alias1, ISNULL(T.Number, 0) AS Total_Count, CAST(ROUND(ISNULL(T.Amount/10000, 0), 2) AS decimal(10, 2)) AS Total_Amount, CAST(ROUND(ISNULL(T.OweInterest/10000, 0), 2) AS decimal(10, 2)) AS Total_Interest
		, ISNULL(Y.Number, 0) AS YQ_Count, CAST(ROUND(ISNULL(Y.Amount/10000, 0), 2) AS decimal(10, 2)) AS YQ_Amount
		, ISNULL(B.Number, 0) AS BLDK_Count, CAST(ROUND(ISNULL(B.Amount/10000, 0), 2) AS decimal(10, 2)) AS BLDK_Amount
		, ISNULL(Z.Number, 0) AS ZQX_Count, CAST(ROUND(ISNULL(Z.Amount/10000, 0), 2) AS decimal(10, 2)) AS ZQX_Amount
	INTO #Result
	FROM Org O
		LEFT JOIN #Total T ON O.Number = T.OrgNo
		LEFT JOIN #YQ    Y ON O.Number = Y.OrgNo
		LEFT JOIN #BLDK  B ON O.Number = B.OrgNo
		LEFT JOIN #ZQX   Z ON O.Number = Z.OrgNo
	WHERE Y.Number > 0 OR B.Number > 0 OR Z.Number > 0

	SELECT Alias1 AS OrgName, Total_Amount
		, YQ_Count, YQ_Amount, YQ_Amount/Total_Amount AS YQ_Percentage
		, BLDK_Count, BLDK_Amount, BLDK_Amount/Total_Amount AS BLDK_Percentage
		, ZQX_Count, ZQX_Amount, ZQX_Amount/Total_Amount AS ZQX_Percentage
		, Total_Interest
		, Y_B_Count = YQ_Count + BLDK_Count, Y_B_Amount = YQ_Amount + BLDK_Amount, Y_B_Percentage = (YQ_Amount + BLDK_Amount)/Total_Amount
	FROM #Result
END


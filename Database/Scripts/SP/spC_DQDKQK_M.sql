IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spC_DQDKQK_M') BEGIN
	DROP PROCEDURE spC_DQDKQK_M
END
GO

CREATE PROCEDURE dbo.spC_DQDKQK_M
	@asOfDate as smalldatetime,
	@tableName as nvarchar(20),
	@customCols as nvarchar(2000)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @startDate smalldatetime = CONVERT(varchar(6), @asOfDate, 112) + '01'
	DECLARE @endDate smalldatetime = DATEADD(MONTH, 1, @startDate) - 1

	DECLARE @importId int = (
		SELECT TOP 1 Id FROM Import I
		WHERE ImportDate <= @asOfDate
			AND EXISTS(SELECT * FROM ImportPrivate P WHERE P.ImportId = I.Id)
			AND EXISTS(SELECT * FROM ImportPublic P WHERE P.ImportId = I.Id)
		ORDER BY ImportDate DESC
	)

	IF @importId IS NULL BEGIN
		SELECT @importId = Id FROM Import WHERE ImportDate = @endDate
	END

	DECLARE @sql nvarchar(2000)
	SET @sql='INSERT INTO #Mapping(ColName) SELECT Col = '''+ REPLACE(@customCols,',',''' UNION ALL SELECT ''')+''''
	CREATE TABLE #Mapping
	(
		Id int NOT NULL IDENTITY (1, 1),
		ColName nvarchar(50) NOT NULL 
	)
	EXEC (@sql)
	
	SET @sql = (
		SELECT
			CASE
				WHEN C.MappingMode IS NOT NULL THEN 'P.[' + C.ColName + '] [' + C.MappingName + '],'
				ELSE ''''' [' +  ISNULL(M.ColName,'')+'],'
			END
		FROM #Mapping M
			LEFT JOIN TableMapping C ON M.ColName = C.ColName AND TableId = @tableName
		FOR XML PATH('')
	)
	
	IF @tableName LIKE '%Public%' BEGIN
		SET @sql = 'SELECT ROW_NUMBER() OVER(ORDER BY P.OrgName2) AS [���], '+ LEFT(@sql, LEN(@sql)-1)
			+ ' FROM ('
			+ '		SELECT OrgName, OrgName2, CustomerName, OrgType, OrgCode, ContractNo, DueBillNo, LoanStartDate, LoanEndDate, IndustryType1, IndustryType2, IndustryType3, IndustryType4, TermMonth, CurrencyType, Direction1, Direction2, Direction3, Direction4, OccurType, BusinessType, SubjectNo'
			+ '			, ClassifyResult = (SELECT DangerLevel FROM ImportLoanView L WHERE L.ImportId = @importId AND L.LoanAccount = P1.LoanAccount)'
			+ '			, CreditLevel, MyBankIndTypeName, ScopeName, OverdueDays, OweInterestDays, Balance1, ActualBusinessRate, RateFloat, VouchTypeName, BailRatio, NormalBalance, OverdueBalance, BadBalance, LoanAccount, IsAgricultureCredit, IsINRZ'
			+ '		FROM ImportPublic P1'
			+ '		WHERE P1.ImportId=@importId AND P1.PublicType = 1 AND LoanEndDate BETWEEN @startDate AND @endDate'
			+ '			AND P1.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())'
			+ ' ) AS P'
			+ ' ORDER BY P.OrgName2'
	END
	ELSE BEGIN
		SET @sql = 'SELECT ROW_NUMBER() OVER(ORDER BY P.OrgName2) AS [���], '+ LEFT(@sql, LEN(@sql)-1)
			+ ' FROM ('
			+ '		SELECT OrgName, OrgName2, ProductName, ProductType, LoanMonths, ZongHeShouXinEDu'
			+ '			, DangerLevel = (SELECT MAX(DangerLevel) FROM ImportLoanView L WHERE L.ImportId = @importId AND L.LoanAccount = P1.LoanAccount)'
			+ '			, RepaymentMethod, CustomerName, IdCardNo, CurrencyType, ContractStartDate, ContractEndDate, InterestRatio, DanBaoFangShi, LoanBalance, Direction1, Direction2, Direction3, Direction4, CapitalOverdueDays, InterestOverdueDays, OweInterestAmount, OverdueBalance, NonAccrualBalance'
			+ '		FROM ImportPrivate P1'
			+ '		WHERE P1.ImportId=@importId AND ContractEndDate BETWEEN @startDate AND @endDate'
			+ '			AND P1.OrgId IN (SELECT Id FROM dbo.sfGetOrgs())'
			+ ' ) AS P'
			+ ' ORDER BY P.OrgName2'
	END
	
	EXEC sp_executesql @sql, N'@importId int, @startDate smalldatetime, @endDate smalldatetime', @importId, @startDate, @endDate
	
	DROP TABLE #Mapping
END


IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Import')) BEGIN
	CREATE TABLE dbo.Import(
		Id int IDENTITY(1,1) NOT NULL,
		ImportDate smalldatetime NOT NULL,
		[State] smallint NOT NULL CONSTRAINT DF_Import_State DEFAULT (0),
		DateStamp datetime NOT NULL CONSTRAINT DF_Import_DateStamp DEFAULT (getdate()),
		ModifyDate datetime NULL,
		CONSTRAINT PK_Import PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportItem')) BEGIN
	CREATE TABLE dbo.ImportItem(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		ItemType smallint NOT NULL,
		FilePath varchar(255) NOT NULL,
		DateStamp datetime NOT NULL CONSTRAINT DF_ImportItem_DateStamp DEFAULT (getdate()),
		ModifyDate datetime NULL,
		CONSTRAINT PK_ImportItem PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportItem  WITH NOCHECK ADD  CONSTRAINT FK_ImportItem_Import FOREIGN KEY(ImportId)
	REFERENCES dbo.Import (Id)

	ALTER TABLE dbo.ImportItem CHECK CONSTRAINT FK_ImportItem_Import
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Org')) BEGIN
	CREATE TABLE dbo.Org(
		Number varchar(50) NOT NULL,
		Name nvarchar(100) NOT NULL,
		Alias1 nvarchar(100) NULL,
		Alias2 nvarchar(100) NULL,
		CONSTRAINT PK_Org PRIMARY KEY CLUSTERED
		(
			Number ASC
		)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportLoan')) BEGIN
	CREATE TABLE dbo.ImportLoan(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NULL,
		OrgNo varchar(50) NULL,
		LoanCatalog nvarchar(100) NULL,
		LoanAccount varchar(50) NULL,
		CustomerName nvarchar(100) NULL,
		CustomerNo varchar(50) NULL,
		CustomerType nvarchar(100) NULL,
		CurrencyType nvarchar(100) NULL,
		LoanAmount nvarchar(100) NULL,
		CapitalAmount nvarchar(100) NULL,
		OweCapital nvarchar(100) NULL,
		OweYingShouInterest nvarchar(100) NULL,
		OweCuiShouInterest nvarchar(100) NULL,
		ColumnM nvarchar(100) NULL,
		DueBillNo nvarchar(100) NULL,
		LoanStartDate smalldatetime NULL,
		LoanEndDate smalldatetime NULL,
		ZhiHuanZhuanRang varchar(10) NULL,
		HeXiaoFlag varchar(10) NULL,
		LoanState nvarchar(100) NULL,
		LoanType varchar(10) NULL,
		LoanTypeName nvarchar(100) NULL,
		Direction nvarchar(100) NULL,
		ZhuanLieYuQi smalldatetime NULL,
		ZhuanLieFYJ smalldatetime NULL,
		InterestEndDate smalldatetime NULL,
		LiLvType nvarchar(50) NULL,
		LiLvSymbol varchar(10) NULL,
		LiLvJiaJianMa nvarchar(100) NULL,
		LiLvYiJu nvarchar(50) NULL,
		YuQiLiLvYiJu nvarchar(50) NULL,
		YuQiLiLvType nvarchar(50) NULL,
		YuQiLiLvSymbol varchar(10) NULL,
		YuQiLiLvJiaJianMa nvarchar(100) NULL,
		ContractInterestRatio nvarchar(100) NULL,
		ContractOverdueInterestRate nvarchar(100) NULL,
		ChargeAccount nvarchar(100) NULL,
		CONSTRAINT PK_ImportLoan PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportLoan WITH CHECK
	ADD CONSTRAINT FK_ImportLoan_ImportItem FOREIGN KEY(ImportItemId) REFERENCES dbo.ImportItem (Id)

	ALTER TABLE dbo.ImportLoan CHECK CONSTRAINT FK_ImportLoan_ImportItem

	CREATE NONCLUSTERED INDEX IX_ImportLoan_LoanState ON dbo.ImportLoan(LoanState ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_CustomerName ON dbo.ImportLoan(CustomerName ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_LoanAccount ON dbo.ImportLoan(LoanAccount ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPrivate')) BEGIN
	CREATE TABLE dbo.ImportPrivate(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NULL,
		OrgNo varchar(50) NULL,
		OrgName nvarchar(100) NULL,
		OrgName2 nvarchar(100) NULL,
		ProductName nvarchar(100) NULL,
		ProductType nvarchar(100) NULL,
		LoanMonths int NULL,
		ZongHeShouXinEDu nvarchar(100) NULL,
		DangerLevel nvarchar(100) NULL,
		RepaymentMethod nvarchar(100) NULL,
		CustomerName nvarchar(20) NULL,
		CurrencyType nvarchar(100) NULL,
		ContractStartDate smalldatetime NULL,
		ContractEndDate smalldatetime NULL,
		InterestRatio nvarchar(100) NULL,
		DanBaoFangShi nvarchar(100) NULL,
		LoanBalance nvarchar(100) NULL,
		Direction1 nvarchar(100) NULL,
		Direction2 nvarchar(100) NULL,
		Direction3 nvarchar(100) NULL,
		Direction4 nvarchar(100) NULL,
		CapitalOverdueDays nvarchar(100) NULL,
		InterestOverdueDays nvarchar(100) NULL,
		OweInterestAmount nvarchar(100) NULL,
		OverdueBalance nvarchar(100) NULL,
		NonAccrualBalance nvarchar(100) NULL,
		CONSTRAINT PK_ImportPrivate PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportPrivate WITH CHECK
	ADD CONSTRAINT FK_ImportPrivate_ImportItem FOREIGN KEY(ImportItemId) REFERENCES dbo.ImportItem (Id)

	ALTER TABLE dbo.ImportPrivate CHECK CONSTRAINT FK_ImportPrivate_ImportItem
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPublic')) BEGIN
	CREATE TABLE dbo.ImportPublic(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NULL,
		PublicType int NULL,
		OrgName nvarchar(100) NULL,
		OrgName2 nvarchar(100) NULL,
		CustomerNo varchar(50) NULL,
		CustomerName nvarchar(100) NULL,
		OrgType nvarchar(100) NULL,
		OrgCode varchar(50) NULL,
		ContractNo nvarchar(100) NULL,
		DueBillNo nvarchar(100) NULL,
		ActualPutOutDate smalldatetime NULL,
		ActualMaturity smalldatetime NULL,
		IndustryType1 nvarchar(100) NULL,
		IndustryType2 nvarchar(100) NULL,
		IndustryType3 nvarchar(100) NULL,
		IndustryType4 nvarchar(100) NULL,
		TermMonth nvarchar(100) NULL,
		CurrencyType nvarchar(100) NULL,
		Direction1 nvarchar(100) NULL,
		Direction2 nvarchar(100) NULL,
		Direction3 nvarchar(100) NULL,
		Direction4 nvarchar(100) NULL,
		OccurType nvarchar(100) NULL,
		BusinessType nvarchar(100) NULL,
		SubjectNo nvarchar(100) NULL,
		Balance nvarchar(100) NULL,
		ClassifyResult nvarchar(100) NULL,
		CreditLevel nvarchar(50) NULL,
		MyBankIndType nvarchar(100) NULL,
		MyBankIndTypeName nvarchar(100) NULL,
		Scope nvarchar(100) NULL,
		ScopeName nvarchar(100) NULL,
		OverdueDays nvarchar(100) NULL,
		OweInterestDays nvarchar(100) NULL,
		Balance1 nvarchar(100) NULL,
		ActualBusinessRate nvarchar(100) NULL,
		RateFloat nvarchar(100) NULL,
		VouchTypeName nvarchar(100) NULL,
		BailRatio nvarchar(100) NULL,
		NormalBalance nvarchar(100) NULL,
		OverdueBalance nvarchar(100) NULL,
		BadBalance nvarchar(100) NULL,
		FContractNo varchar(50) NULL,
		IsAgricultureCredit nvarchar(100) NULL,
		IsINRZ nvarchar(100) NULL,
		CONSTRAINT PK_ImportPublic PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportPublic WITH CHECK
	ADD CONSTRAINT FK_ImportPublic_ImportItem FOREIGN KEY(ImportItemId) REFERENCES dbo.ImportItem (Id)

	ALTER TABLE dbo.ImportPublic CHECK CONSTRAINT FK_ImportPublic_ImportItem
	CREATE NONCLUSTERED INDEX IX_ImportPublic_LoanAccount ON dbo.ImportPublic(FCONTRACTNO ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportNonAccrual')) BEGIN
	CREATE TABLE dbo.ImportNonAccrual(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NULL,
		OrgName nvarchar(100) NULL,
		CustomerName nvarchar(100) NULL,
		LoanBalance nvarchar(100) NULL,
		DangerLevel nvarchar(100) NULL,
		OweInterestAmount nvarchar(100) NULL,
		LoanStartDate smalldatetime NULL,
		LoanEndDate smalldatetime NULL,
		OverdueDays nvarchar(100) NULL,
		InterestOverdueDays nvarchar(100) NULL,
		DanBaoFangShi nvarchar(100) NULL,
		Industry nvarchar(50) NULL,
		CustomerType nvarchar(50) NULL,
		LoanType nvarchar(50) NULL,
		IsNew nvarchar(100) NULL,
		LoanAccount varchar(50) NULL,
		CustomerNo varchar(50) NULL,

		CONSTRAINT PK_ImportNonAccrual PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportNonAccrual WITH CHECK
	ADD CONSTRAINT FK_ImportNonAccrual_ImportItem FOREIGN KEY(ImportItemId) REFERENCES dbo.ImportItem (Id)

	ALTER TABLE dbo.ImportNonAccrual CHECK CONSTRAINT FK_ImportNonAccrual_ImportItem
	CREATE NONCLUSTERED INDEX IX_ImportNonAccrual_LoanAccount ON dbo.ImportNonAccrual(LoanAccount ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportOverdue')) BEGIN
	CREATE TABLE dbo.ImportOverdue(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NULL,
		OrgName nvarchar(100) NULL,
		CustomerName nvarchar(100) NULL,
		LoanAccount varchar(50) NULL,
		CustomerNo varchar(100) NULL,
		LoanType nvarchar(50) NULL,
		LoanStartDate smalldatetime NULL,
		LoanEndDate smalldatetime NULL,
		CapitalOverdueBalance nvarchar(100) NULL,
		InterestBalance nvarchar(100) NULL,
		DanBaoFangShi nvarchar(100) NULL,

		CONSTRAINT PK_ImportOverdue PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportOverdue WITH CHECK
	ADD CONSTRAINT FK_ImportOverdue_ImportItem FOREIGN KEY(ImportItemId) REFERENCES dbo.ImportItem (Id)

	ALTER TABLE dbo.ImportOverdue CHECK CONSTRAINT FK_ImportOverdue_ImportItem
	CREATE NONCLUSTERED INDEX IX_ImportOverdue_LoanAccount ON dbo.ImportOverdue(LoanAccount ASC) ON [PRIMARY]
END


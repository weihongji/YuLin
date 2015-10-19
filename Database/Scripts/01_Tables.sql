
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

	ALTER TABLE dbo.ImportItem  WITH NOCHECK ADD CONSTRAINT FK_ImportItem_Import FOREIGN KEY(ImportId)
	REFERENCES dbo.Import (Id)

	ALTER TABLE dbo.ImportItem CHECK CONSTRAINT FK_ImportItem_Import
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportLoan')) BEGIN
	CREATE TABLE dbo.ImportLoan(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NOT NULL,
		DangerLevel nvarchar(20) NULL,
		OrgNo varchar(50) NOT NULL,
		LoanCatalog nvarchar(100) NULL,
		LoanAccount varchar(50) NOT NULL,
		CustomerName nvarchar(100) NOT NULL,
		CustomerNo varchar(50) NOT NULL,
		CustomerType nvarchar(100) NULL,
		CurrencyType nvarchar(100) NULL,
		LoanAmount money NOT NULL,
		CapitalAmount money NOT NULL,
		OweCapital money NOT NULL,
		OweYingShouInterest money NOT NULL,
		OweCuiShouInterest money NOT NULL,
		ColumnM varchar(50) NULL,
		DueBillNo varchar(50) NOT NULL,
		LoanStartDate smalldatetime NOT NULL,
		LoanEndDate smalldatetime NOT NULL,
		ZhiHuanZhuanRang varchar(10) NULL,
		HeXiaoFlag varchar(10) NULL,
		LoanState nvarchar(50) NULL,
		LoanType varchar(10) NULL,
		LoanTypeName nvarchar(100) NULL,
		Direction nvarchar(100) NULL,
		ZhuanLieYuQi smalldatetime NULL,
		ZhuanLieFYJ smalldatetime NULL,
		InterestEndDate smalldatetime NULL,
		LiLvType nvarchar(50) NULL,
		LiLvSymbol varchar(10) NULL,
		LiLvJiaJianMa decimal(8, 5) NULL,
		YuQiLiLvYiJu nvarchar(50) NULL,
		YuQiLiLvType nvarchar(50) NULL,
		YuQiLiLvSymbol varchar(10) NULL,
		YuQiLiLvJiaJianMa decimal(8, 5) NULL,
		LiLvYiJu nvarchar(50) NULL,
		ContractInterestRatio decimal(8, 5) NULL,
		ContractOverdueInterestRate decimal(8, 5) NULL,
		ChargeAccount varchar(50) NULL,
		CONSTRAINT PK_ImportLoan PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportLoan WITH CHECK
	ADD CONSTRAINT FK_ImportLoan_ImportItem FOREIGN KEY(ImportItemId) REFERENCES dbo.ImportItem (Id)

	ALTER TABLE dbo.ImportLoan CHECK CONSTRAINT FK_ImportLoan_ImportItem
		
	CREATE NONCLUSTERED INDEX IX_ImportLoan_ImportItemId ON dbo.ImportLoan(ImportItemId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_LoanState ON dbo.ImportLoan(LoanState ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_CustomerName ON dbo.ImportLoan(CustomerName ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_LoanAccount ON dbo.ImportLoan(LoanAccount ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPrivate')) BEGIN
	CREATE TABLE dbo.ImportPrivate(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NOT NULL,
		OrgNo varchar(50) NULL,
		OrgName nvarchar(100) NOT NULL,
		OrgName2 nvarchar(100) NOT NULL,
		ProductName nvarchar(100) NOT NULL,
		ProductType nvarchar(100) NOT NULL,
		LoanMonths int NOT NULL,
		ZongHeShouXinEDu decimal(15, 6) NOT NULL,
		DangerLevel nvarchar(50) NULL,
		RepaymentMethod nvarchar(100) NULL,
		CustomerName nvarchar(20) NULL,
		CurrencyType nvarchar(100) NULL,
		ContractStartDate smalldatetime NOT NULL,
		ContractEndDate smalldatetime NOT NULL,
		InterestRatio decimal(8, 5) NULL,
		DanBaoFangShi nvarchar(100) NULL,
		LoanBalance decimal(15, 6) NOT NULL,
		Direction1 nvarchar(100) NULL,
		Direction2 nvarchar(100) NULL,
		Direction3 nvarchar(100) NULL,
		Direction4 nvarchar(100) NULL,
		CapitalOverdueDays smallint NOT NULL,
		InterestOverdueDays smallint NOT NULL,
		OweInterestAmount decimal(10, 4) NOT NULL,
		OverdueBalance decimal(15, 4) NOT NULL,
		NonAccrualBalance decimal(15, 4) NOT NULL,
		CONSTRAINT PK_ImportPrivate PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportPrivate WITH CHECK
	ADD CONSTRAINT FK_ImportPrivate_ImportItem FOREIGN KEY(ImportItemId) REFERENCES dbo.ImportItem (Id)

	ALTER TABLE dbo.ImportPrivate CHECK CONSTRAINT FK_ImportPrivate_ImportItem

	CREATE NONCLUSTERED INDEX IX_ImportPrivate_ImportItemId ON dbo.ImportPrivate(ImportItemId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPublic')) BEGIN
	CREATE TABLE dbo.ImportPublic(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NOT NULL,
		PublicType int NOT NULL,
		OrgName nvarchar(100) NOT NULL,
		OrgName2 nvarchar(100) NOT NULL,
		CustomerNo varchar(50) NOT NULL,
		CustomerName nvarchar(100) NOT NULL,
		OrgType nvarchar(100) NOT NULL,
		OrgCode varchar(50) NULL,
		ContractNo varchar(50) NOT NULL,
		DueBillNo varchar(50) NOT NULL,
		ActualPutOutDate smalldatetime NOT NULL,
		ActualMaturity smalldatetime NOT NULL,
		IndustryType1 nvarchar(100) NULL,
		IndustryType2 nvarchar(100) NULL,
		IndustryType3 nvarchar(100) NULL,
		IndustryType4 nvarchar(100) NULL,
		TermMonth smallint NOT NULL,
		CurrencyType nvarchar(100) NULL,
		Direction1 nvarchar(100) NULL,
		Direction2 nvarchar(100) NULL,
		Direction3 nvarchar(100) NULL,
		Direction4 nvarchar(100) NULL,
		OccurType nvarchar(100) NULL,
		BusinessType nvarchar(50) NOT NULL,
		SubjectNo nvarchar(100) NULL,
		Balance decimal(15, 6) NOT NULL,
		ClassifyResult nvarchar(50) NULL,
		CreditLevel nvarchar(50) NULL,
		MyBankIndType nvarchar(100) NULL,
		MyBankIndTypeName nvarchar(100) NULL,
		Scope varchar(50) NULL,
		ScopeName nvarchar(100) NULL,
		OverdueDays smallint NOT NULL,
		OweInterestDays smallint NOT NULL,
		Balance1 decimal(15, 6) NOT NULL,
		ActualBusinessRate decimal(8, 5) NOT NULL,
		RateFloat decimal(8, 5) NOT NULL,
		VouchTypeName nvarchar(100) NOT NULL,
		BailRatio decimal(8, 5) NOT NULL,
		NormalBalance decimal(15, 6) NOT NULL,
		OverdueBalance decimal(15, 6) NOT NULL,
		BadBalance decimal(15, 6) NOT NULL,
		FContractNo varchar(50) NOT NULL,
		IsAgricultureCredit nvarchar(50) NOT NULL,
		IsINRZ nvarchar(50) NOT NULL,
		CONSTRAINT PK_ImportPublic PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportPublic WITH CHECK
	ADD CONSTRAINT FK_ImportPublic_ImportItem FOREIGN KEY(ImportItemId) REFERENCES dbo.ImportItem (Id)

	ALTER TABLE dbo.ImportPublic CHECK CONSTRAINT FK_ImportPublic_ImportItem
	CREATE NONCLUSTERED INDEX IX_ImportPublic_LoanAccount ON dbo.ImportPublic(FCONTRACTNO ASC) ON [PRIMARY]
		
	CREATE NONCLUSTERED INDEX IX_ImportPublic_ImportItemId ON dbo.ImportPublic(ImportItemId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportNonAccrual')) BEGIN
	CREATE TABLE dbo.ImportNonAccrual(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NOT NULL,
		OrgName nvarchar(100) NOT NULL,
		CustomerName nvarchar(100) NOT NULL,
		LoanBalance decimal(15, 6) NULL,
		DangerLevel nvarchar(50) NULL,
		OweInterestAmount decimal(10, 4) NULL,
		LoanStartDate smalldatetime NULL,
		LoanEndDate smalldatetime NULL,
		OverdueDays smallint NULL,
		InterestOverdueDays smallint NULL,
		DanBaoFangShi nvarchar(100) NULL,
		Industry nvarchar(50) NULL,
		CustomerType nvarchar(50) NULL,
		LoanType nvarchar(50) NULL,
		IsNew nvarchar(50) NULL,
		LoanAccount varchar(50) NOT NULL,
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
	CREATE NONCLUSTERED INDEX IX_ImportNonAccrual_ImportItemId ON dbo.ImportNonAccrual(ImportItemId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportOverdue')) BEGIN
	CREATE TABLE dbo.ImportOverdue(
		Id int IDENTITY(1,1) NOT NULL,
		ImportItemId int NOT NULL,
		OrgName nvarchar(100) NOT NULL,
		CustomerName nvarchar(100) NOT NULL,
		LoanAccount varchar(50) NOT NULL,
		CustomerNo varchar(50) NOT NULL,
		LoanType nvarchar(50) NULL,
		LoanStartDate smalldatetime NOT NULL,
		LoanEndDate smalldatetime NOT NULL,
		CapitalOverdueBalance decimal(15, 4) NOT NULL,
		InterestBalance decimal(10, 4) NOT NULL,
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
	CREATE NONCLUSTERED INDEX IX_ImportOverdue_ImportItemId ON dbo.ImportOverdue(ImportItemId ASC) ON [PRIMARY]
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

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('SourceTable')) BEGIN
	CREATE TABLE dbo.SourceTable(
		Id int NOT NULL,
		Name nvarchar(100) NOT NULL,
		DateStamp datetime NOT NULL CONSTRAINT DF_SourceTable_DateStamp DEFAULT (getdate()),
		CONSTRAINT PK_SourceTable PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('SourceTableSheet')) BEGIN
	CREATE TABLE dbo.SourceTableSheet(
		Id int NOT NULL,
		TableId int NOT NULL,
		[Index] int NOT NULL,
		Name nvarchar(100) NOT NULL,
		RowsBeforeHeader int NOT NULL,
		DataRowEndingFlag nvarchar(100) NOT NULL,
		CONSTRAINT PK_SourceTableSheet PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.SourceTableSheet  WITH NOCHECK ADD CONSTRAINT FK_SourceTableSheet_SourceTable FOREIGN KEY(TableId)
	REFERENCES dbo.SourceTable (Id)
	ALTER TABLE dbo.SourceTableSheet CHECK CONSTRAINT FK_SourceTableSheet_SourceTable
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('SourceTableSheetColumn')) BEGIN
	CREATE TABLE dbo.SourceTableSheetColumn(
		SheetId int NOT NULL,
		[Index] int NOT NULL,
		Name nvarchar(100) NOT NULL,
		CONSTRAINT PK_SourceTableSheetColumn PRIMARY KEY CLUSTERED (SheetId ASC, [Index] ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.SourceTableSheetColumn  WITH NOCHECK ADD CONSTRAINT FK_SourceTableSheetColumn_SourceTableSheet FOREIGN KEY(SheetId)
	REFERENCES dbo.SourceTableSheet (Id)
	ALTER TABLE dbo.SourceTableSheetColumn CHECK CONSTRAINT FK_SourceTableSheetColumn_SourceTableSheet
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TargetTable')) BEGIN
	CREATE TABLE dbo.TargetTable(
		Id int NOT NULL,
		Name nvarchar(100) NOT NULL,
		[FileName] nvarchar(100) NOT NULL,
		DateStamp datetime NOT NULL CONSTRAINT DF_TargetTable_DateStamp DEFAULT (getdate()),
		CONSTRAINT PK_TargetTable PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TargetTableSheet')) BEGIN
	CREATE TABLE dbo.TargetTableSheet(
		Id int NOT NULL,
		TableId int NOT NULL,
		[Index] int NOT NULL,
		[Name] nvarchar(100) NOT NULL,
		RowsBeforeHeader int NOT NULL,
		FooterStartRow int NOT NULL,
		FooterEndRow int NOT NULL
		CONSTRAINT PK_TargetTableSheet PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.TargetTableSheet  WITH NOCHECK ADD CONSTRAINT FK_TargetTableSheet_TargetTable FOREIGN KEY(TableId)
	REFERENCES dbo.TargetTable (Id)
	ALTER TABLE dbo.TargetTableSheet CHECK CONSTRAINT FK_TargetTableSheet_TargetTable

	CREATE UNIQUE NONCLUSTERED INDEX IX_TargetTableSheet_TableId_Index ON dbo.TargetTableSheet (TableId, [Index]) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TargetTableSheetColumn')) BEGIN
	CREATE TABLE dbo.TargetTableSheetColumn(
		SheetId int NOT NULL,
		[Index] int NOT NULL,
		Name nvarchar(100) NOT NULL,
		CONSTRAINT PK_TargetTableColumn PRIMARY KEY CLUSTERED (SheetId ASC, [Index] ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.TargetTableSheetColumn  WITH NOCHECK ADD CONSTRAINT FK_TargetTableSheetColumn_TargetTableSheet FOREIGN KEY(SheetId)
	REFERENCES dbo.TargetTableSheet (Id)

	ALTER TABLE dbo.TargetTableSheetColumn CHECK CONSTRAINT FK_TargetTableSheetColumn_TargetTableSheet
END

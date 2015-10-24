
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
		ImportId int NOT NULL,
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
		DueBillNo varchar(50) NULL,
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
	ADD CONSTRAINT FK_ImportLoan_ImportItem FOREIGN KEY(ImportId) REFERENCES dbo.Import (Id)

	ALTER TABLE dbo.ImportLoan CHECK CONSTRAINT FK_ImportLoan_ImportItem
		
	CREATE NONCLUSTERED INDEX IX_ImportLoan_ImportId ON dbo.ImportLoan(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_LoanState ON dbo.ImportLoan(LoanState ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_CustomerName ON dbo.ImportLoan(CustomerName ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_LoanAccount ON dbo.ImportLoan(LoanAccount ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPrivate')) BEGIN
	CREATE TABLE dbo.ImportPrivate(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgNo varchar(50) NULL,
		OrgName nvarchar(100) NULL,
		OrgName2 nvarchar(100) NULL,
		ProductName nvarchar(100) NULL,
		ProductType nvarchar(100) NULL,
		LoanMonths int NULL,
		ZongHeShouXinEDu decimal(15, 6) NULL,
		DangerLevel nvarchar(50) NULL,
		RepaymentMethod nvarchar(100) NULL,
		CustomerName nvarchar(20) NULL,
		IdCardNo varchar(30) NULL,
		CurrencyType nvarchar(100) NULL,
		ContractStartDate smalldatetime NULL,
		ContractEndDate smalldatetime NULL,
		InterestRatio decimal(8, 5) NULL,
		DanBaoFangShi nvarchar(100) NULL,
		LoanBalance decimal(15, 6) NULL,
		Direction1 nvarchar(100) NULL,
		Direction2 nvarchar(100) NULL,
		Direction3 nvarchar(100) NULL,
		Direction4 nvarchar(100) NULL,
		CapitalOverdueDays smallint NULL,
		InterestOverdueDays smallint NULL,
		OweInterestAmount decimal(10, 4) NULL,
		OverdueBalance decimal(15, 4) NULL,
		NonAccrualBalance decimal(15, 4) NULL,
		CONSTRAINT PK_ImportPrivate PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportPrivate WITH CHECK
	ADD CONSTRAINT FK_ImportPrivate_ImportItem FOREIGN KEY(ImportId) REFERENCES dbo.Import (Id)

	ALTER TABLE dbo.ImportPrivate CHECK CONSTRAINT FK_ImportPrivate_ImportItem

	CREATE NONCLUSTERED INDEX IX_ImportPrivate_ImportId ON dbo.ImportPrivate(ImportId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPublic')) BEGIN
	CREATE TABLE dbo.ImportPublic(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		PublicType int NOT NULL,
		OrgName nvarchar(100) NULL,
		OrgName2 nvarchar(100) NULL,
		CustomerNo varchar(50) NULL,
		CustomerName nvarchar(100) NULL,
		OrgType nvarchar(100) NULL,
		OrgCode varchar(50) NULL,
		ContractNo varchar(50) NULL,
		DueBillNo varchar(50) NULL,
		LoanStartDate smalldatetime NULL,
		LoanEndDate smalldatetime NULL,
		IndustryType1 nvarchar(100) NULL,
		IndustryType2 nvarchar(100) NULL,
		IndustryType3 nvarchar(100) NULL,
		IndustryType4 nvarchar(100) NULL,
		TermMonth smallint NULL,
		CurrencyType nvarchar(100) NULL,
		Direction1 nvarchar(100) NULL,
		Direction2 nvarchar(100) NULL,
		Direction3 nvarchar(100) NULL,
		Direction4 nvarchar(100) NULL,
		OccurType nvarchar(100) NULL,
		BusinessType nvarchar(50) NULL,
		SubjectNo nvarchar(100) NULL,
		Balance decimal(15, 6) NULL,
		ClassifyResult nvarchar(50) NULL,
		CreditLevel nvarchar(50) NULL,
		MyBankIndType nvarchar(100) NULL,
		MyBankIndTypeName nvarchar(100) NULL,
		Scope varchar(50) NULL,
		ScopeName nvarchar(100) NULL,
		OverdueDays smallint NULL,
		OweInterestDays smallint NULL,
		Balance1 decimal(15, 6) NULL,
		ActualBusinessRate decimal(8, 5) NULL,
		RateFloat decimal(8, 5) NULL,
		VouchTypeName nvarchar(100) NULL,
		BailRatio decimal(8, 5) NULL,
		NormalBalance decimal(15, 6) NULL,
		OverdueBalance decimal(15, 6) NULL,
		BadBalance decimal(15, 6) NULL,
		LoanAccount varchar(50) NULL,
		IsAgricultureCredit nvarchar(50) NULL,
		IsINRZ nvarchar(50) NULL,
		CONSTRAINT PK_ImportPublic PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportPublic WITH CHECK
	ADD CONSTRAINT FK_ImportPublic_ImportItem FOREIGN KEY(ImportId) REFERENCES dbo.Import (Id)

	ALTER TABLE dbo.ImportPublic CHECK CONSTRAINT FK_ImportPublic_ImportItem
	CREATE NONCLUSTERED INDEX IX_ImportPublic_LoanAccount ON dbo.ImportPublic(LoanAccount ASC) ON [PRIMARY]
		
	CREATE NONCLUSTERED INDEX IX_ImportPublic_ImportId ON dbo.ImportPublic(ImportId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportNonAccrual')) BEGIN
	CREATE TABLE dbo.ImportNonAccrual(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgName nvarchar(100) NULL,
		CustomerName nvarchar(100) NULL,
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
		LoanAccount varchar(50) NULL,
		CustomerNo varchar(50) NULL,
		CONSTRAINT PK_ImportNonAccrual PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportNonAccrual WITH CHECK
	ADD CONSTRAINT FK_ImportNonAccrual_ImportItem FOREIGN KEY(ImportId) REFERENCES dbo.Import (Id)
	ALTER TABLE dbo.ImportNonAccrual CHECK CONSTRAINT FK_ImportNonAccrual_ImportItem

	CREATE NONCLUSTERED INDEX IX_ImportNonAccrual_LoanAccount ON dbo.ImportNonAccrual(LoanAccount ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportNonAccrual_ImportId ON dbo.ImportNonAccrual(ImportId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportOverdue')) BEGIN
	CREATE TABLE dbo.ImportOverdue(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgName nvarchar(100) NULL,
		CustomerName nvarchar(100) NULL,
		LoanAccount varchar(50) NULL,
		CustomerNo varchar(50) NULL,
		LoanType nvarchar(50) NULL,
		LoanStartDate smalldatetime NULL,
		LoanEndDate smalldatetime NULL,
		CapitalOverdueBalance decimal(15, 4) NULL,
		InterestBalance decimal(10, 4) NULL,
		DanBaoFangShi nvarchar(100) NULL,
		CONSTRAINT PK_ImportOverdue PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportOverdue WITH CHECK
	ADD CONSTRAINT FK_ImportOverdue_ImportItem FOREIGN KEY(ImportId) REFERENCES dbo.Import (Id)
	ALTER TABLE dbo.ImportOverdue CHECK CONSTRAINT FK_ImportOverdue_ImportItem

	CREATE NONCLUSTERED INDEX IX_ImportOverdue_LoanAccount ON dbo.ImportOverdue(LoanAccount ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportOverdue_ImportId ON dbo.ImportOverdue(ImportId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportYWNei')) BEGIN
	CREATE TABLE dbo.ImportYWNei(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		SubjectCode varchar(10) NOT NULL,
		SubjectName nvarchar(100) NULL,
		LastDebitBalance decimal(15,2) NULL,
		LastCreditBalance decimal(15,2) NULL,
		CurrentDebitChange decimal(15,2) NULL,
		CurrentCreditChange decimal(15,2) NULL,
		CurrentDebitBalance decimal(15,2) NULL,
		CurrentCreditBalance decimal(15,2) NULL,
		CONSTRAINT PK_ImportYWNei PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportYWNei WITH CHECK
	ADD CONSTRAINT FK_ImportYWNei_ImportItem FOREIGN KEY(ImportId) REFERENCES dbo.Import (Id)
	ALTER TABLE dbo.ImportYWNei CHECK CONSTRAINT FK_ImportYWNei_ImportItem

	CREATE NONCLUSTERED INDEX IX_ImportYWNei_SubjectCode ON dbo.ImportYWNei(SubjectCode ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportYWNei_ImportId ON dbo.ImportYWNei(ImportId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportYWWai')) BEGIN
	CREATE TABLE dbo.ImportYWWai(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		SubjectCode varchar(10) NOT NULL,
		SubjectName nvarchar(100) NULL,
		LastDebitBalance decimal(15,2) NULL,
		LastCreditBalance decimal(15,2) NULL,
		CurrentDebitChange decimal(15,2) NULL,
		CurrentCreditChange decimal(15,2) NULL,
		CurrentDebitBalance decimal(15,2) NULL,
		CurrentCreditBalance decimal(15,2) NULL,
		CONSTRAINT PK_ImportYWWai PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportYWWai WITH CHECK
	ADD CONSTRAINT FK_ImportYWWai_ImportItem FOREIGN KEY(ImportId) REFERENCES dbo.Import (Id)
	ALTER TABLE dbo.ImportYWWai CHECK CONSTRAINT FK_ImportYWWai_ImportItem

	CREATE NONCLUSTERED INDEX IX_ImportYWWai_SubjectCode ON dbo.ImportYWWai(SubjectCode ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportYWWai_ImportId ON dbo.ImportYWWai(ImportId ASC) ON [PRIMARY]
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

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('DanBaoFangShi')) BEGIN
	CREATE TABLE dbo.DanBaoFangShi(
		Name nvarchar(100) NOT NULL,
		Category nvarchar(50) NULL
		CONSTRAINT PK_DanBaoFangShi PRIMARY KEY CLUSTERED
		(
			Name ASC
		)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Direction')) BEGIN
	CREATE TABLE dbo.Direction(
		Id int NOT NULL,
		Name nvarchar(100) NOT NULL
		CONSTRAINT PK_Direction PRIMARY KEY CLUSTERED
		(
			Id ASC
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

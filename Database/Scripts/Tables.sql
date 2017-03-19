IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Globals')) BEGIN
	CREATE TABLE dbo.Globals(
		SystemVersion varchar(20) NOT NULL,
		DBSchemaLevel int NOT NULL,
		FixedDataLevel int NOT NULL
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Serial')) BEGIN
	CREATE TABLE dbo.Serial(
		Id int NOT NULL,
		CONSTRAINT PK_Serial PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Org')) BEGIN
	CREATE TABLE dbo.Org(
		Id int NOT NULL,
		OrgNo varchar(50) NOT NULL,
		Name nvarchar(100) NOT NULL,
		Alias1 nvarchar(100) NULL,
		Alias2 nvarchar(100) NULL,
		CONSTRAINT PK_Org PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]
	
	CREATE NONCLUSTERED INDEX IX_Org_OrgNo ON dbo.Org(OrgNo ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('OrgOffset')) BEGIN
	CREATE TABLE dbo.OrgOffset(
		Id int IDENTITY(1,1) NOT NULL,
		OrgId int NOT NULL,
		Offset money NOT NULL,
		StartDate smalldatetime NOT NULL,
		EndDate smalldatetime NOT NULL,
		Comment nvarchar(50) NULL,
		DateStamp datetime NOT NULL CONSTRAINT DF_OrgOffset_DateStamp DEFAULT (getdate()),
		CONSTRAINT PK_OrgOffset PRIMARY KEY CLUSTERED
		(
			Id ASC
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

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Direction2')) BEGIN
	CREATE TABLE dbo.Direction2(
		UniqueId int NOT NULL IDENTITY(1,1),
		Id int NOT NULL,
		DirectionId int NOT NULL,
		Name nvarchar(100) NOT NULL
		CONSTRAINT PK_Direction2 PRIMARY KEY CLUSTERED (UniqueId ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.Direction2 WITH CHECK ADD CONSTRAINT FK_Direction2_Direction FOREIGN KEY(DirectionId) REFERENCES dbo.Direction (Id)

	CREATE NONCLUSTERED INDEX IX_Direction2_DirectionId ON dbo.Direction2(DirectionId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('DirectionMix')) BEGIN
	CREATE TABLE dbo.DirectionMix(
		Id int NOT NULL,
		Name nvarchar(100) NOT NULL,
		Code varchar(10) NULL,
		CONSTRAINT PK_DirectionMix PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Import')) BEGIN
	CREATE TABLE dbo.Import(
		Id int IDENTITY(1,1) NOT NULL,
		ImportDate smalldatetime NOT NULL,
		WJFLDate datetime NULL,
		WJFLSFDate datetime NULL,
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

	ALTER TABLE dbo.ImportItem WITH CHECK ADD CONSTRAINT FK_ImportItem_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)
	
	CREATE NONCLUSTERED INDEX IX_ImportItem_ImportId ON dbo.ImportItem(ImportId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportLoan')) BEGIN
	CREATE TABLE dbo.ImportLoan(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgId int NULL,
		OrgId4Report int NULL,
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

	ALTER TABLE dbo.ImportLoan WITH CHECK ADD CONSTRAINT FK_ImportLoan_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)
		
	CREATE NONCLUSTERED INDEX IX_ImportLoan_ImportId ON dbo.ImportLoan(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_LoanState ON dbo.ImportLoan(ImportId ASC, LoanState ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_CustomerName ON dbo.ImportLoan(ImportId ASC, CustomerName ASC, OrgId ASC, LoanStartDate ASC, LoanEndDate ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoan_LoanAccount ON dbo.ImportLoan(ImportId ASC, LoanAccount ASC) INCLUDE (CustomerName, CustomerType, LoanStartDate, LoanEndDate) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPrivate')) BEGIN
	CREATE TABLE dbo.ImportPrivate(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgId int NULL,
		LoanAccount varchar(50) NULL,
		OrgName nvarchar(100) NULL,
		OrgName2 nvarchar(100) NULL,
		ProductName nvarchar(100) NULL,
		ProductType nvarchar(100) NULL,
		LoanMonths int NULL,
		ZongHeShouXinEDu money NULL,
		DangerLevel nvarchar(50) NULL,
		RepaymentMethod nvarchar(100) NULL,
		CustomerName nvarchar(20) NULL,
		IdCardNo varchar(30) NULL,
		CurrencyType nvarchar(100) NULL,
		ContractStartDate smalldatetime NULL,
		ContractEndDate smalldatetime NULL,
		InterestRatio decimal(8, 5) NULL,
		DanBaoFangShi nvarchar(100) NULL,
		LoanBalance money NULL,
		Direction1 nvarchar(100) NULL,
		Direction2 nvarchar(100) NULL,
		Direction3 nvarchar(100) NULL,
		Direction4 nvarchar(100) NULL,
		CapitalOverdueDays int NULL,
		InterestOverdueDays int NULL,
		OweInterestAmount money NULL,
		OverdueBalance money NULL,
		NonAccrualBalance money NULL,
		CONSTRAINT PK_ImportPrivate PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportPrivate WITH CHECK ADD CONSTRAINT FK_ImportPrivate_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)

	CREATE NONCLUSTERED INDEX IX_ImportPrivate_ImportId ON dbo.ImportPrivate(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportPrivate_OrgId ON dbo.ImportPrivate(ImportId ASC, OrgId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportPrivate_LoanAccount ON dbo.ImportPrivate(ImportId ASC, LoanAccount ASC) INCLUDE(DanBaoFangShi) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportPrivate_CustomerName ON dbo.ImportPrivate(ImportId ASC, OrgId ASC, CustomerName ASC, ContractStartDate ASC, ContractEndDate ASC) INCLUDE (Direction1, InterestOverdueDays) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPublic')) BEGIN
	CREATE TABLE dbo.ImportPublic(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		PublicType int NOT NULL,
		OrgId int NULL,
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
		TermMonth int NULL,
		CurrencyType nvarchar(100) NULL,
		Direction1 nvarchar(100) NULL,
		Direction2 nvarchar(100) NULL,
		Direction3 nvarchar(100) NULL,
		Direction4 nvarchar(100) NULL,
		OccurType nvarchar(100) NULL,
		BusinessType nvarchar(50) NULL,
		SubjectNo nvarchar(100) NULL,
		Balance money NULL,
		ClassifyResult nvarchar(50) NULL,
		CreditLevel nvarchar(50) NULL,
		MyBankIndType nvarchar(100) NULL,
		MyBankIndTypeName nvarchar(100) NULL,
		Scope varchar(50) NULL,
		ScopeName nvarchar(100) NULL,
		OverdueDays int NULL,
		OweInterestDays int NULL,
		Balance1 money NULL,
		ActualBusinessRate decimal(8, 5) NULL,
		RateFloat decimal(8, 5) NULL,
		VouchTypeName nvarchar(100) NULL,
		BailRatio decimal(8, 5) NULL,
		NormalBalance money NULL,
		OverdueBalance money NULL,
		BadBalance money NULL,
		LoanAccount varchar(50) NULL,
		IsAgricultureCredit nvarchar(50) NULL,
		IsINRZ nvarchar(50) NULL,
		CONSTRAINT PK_ImportPublic PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportPublic WITH CHECK ADD CONSTRAINT FK_ImportPublic_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)

	CREATE NONCLUSTERED INDEX IX_ImportPublic_ImportId ON dbo.ImportPublic(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportPublic_OrgId ON dbo.ImportPublic(ImportId ASC, OrgId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportPublic_LoanAccount ON dbo.ImportPublic(ImportId ASC, LoanAccount ASC) INCLUDE (MyBankIndTypeName, OweInterestDays, VOUCHTYPENAME) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportNonAccrual')) BEGIN
	CREATE TABLE dbo.ImportNonAccrual(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgName nvarchar(100) NULL,
		CustomerName nvarchar(100) NULL,
		LoanBalance money NULL,
		DangerLevel nvarchar(50) NULL,
		OweInterestAmount money NULL,
		LoanStartDate smalldatetime NULL,
		LoanEndDate smalldatetime NULL,
		OverdueDays int NULL,
		InterestOverdueDays int NULL,
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

	ALTER TABLE dbo.ImportNonAccrual WITH CHECK ADD CONSTRAINT FK_ImportNonAccrual_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)

	CREATE NONCLUSTERED INDEX IX_ImportNonAccrual_ImportId ON dbo.ImportNonAccrual(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportNonAccrual_LoanAccount ON dbo.ImportNonAccrual(ImportId ASC, LoanAccount ASC) INCLUDE(DanBaoFangShi) ON [PRIMARY]
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
		CapitalOverdueBalance money NULL,
		InterestBalance money NULL,
		DanBaoFangShi nvarchar(100) NULL,
		CONSTRAINT PK_ImportOverdue PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportOverdue WITH CHECK ADD CONSTRAINT FK_ImportOverdue_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)

	CREATE NONCLUSTERED INDEX IX_ImportOverdue_ImportId ON dbo.ImportOverdue(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportOverdue_LoanAccount ON dbo.ImportOverdue(ImportId ASC, LoanAccount ASC) INCLUDE(DanBaoFangShi) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportYWNei')) BEGIN
	CREATE TABLE dbo.ImportYWNei(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgId int NOT NULL,
		SubjectCode varchar(10) NOT NULL,
		SubjectName nvarchar(100) NULL,
		LastDebitBalance money NULL,
		LastCreditBalance money NULL,
		CurrentDebitChange money NULL,
		CurrentCreditChange money NULL,
		CurrentDebitBalance money NULL,
		CurrentCreditBalance money NULL,
		CONSTRAINT PK_ImportYWNei PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportYWNei WITH CHECK ADD CONSTRAINT FK_ImportYWNei_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)

	CREATE NONCLUSTERED INDEX IX_ImportYWNei_ImportId ON dbo.ImportYWNei(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportYWNei_OrgId ON dbo.ImportYWNei(ImportId ASC, OrgId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportYWNei_SubjectCode ON dbo.ImportYWNei(ImportId ASC, SubjectCode ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportYWWai')) BEGIN
	CREATE TABLE dbo.ImportYWWai(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgId int NOT NULL,
		SubjectCode varchar(10) NOT NULL,
		SubjectName nvarchar(100) NULL,
		LastDebitBalance money NULL,
		LastCreditBalance money NULL,
		CurrentDebitChange money NULL,
		CurrentCreditChange money NULL,
		CurrentDebitBalance money NULL,
		CurrentCreditBalance money NULL,
		CONSTRAINT PK_ImportYWWai PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportYWWai WITH CHECK ADD CONSTRAINT FK_ImportYWWai_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)

	CREATE NONCLUSTERED INDEX IX_ImportYWWai_ImportId ON dbo.ImportYWWai(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportYWWai_OrgId ON dbo.ImportYWWai(ImportId ASC, OrgId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportYWWai_SubjectCode ON dbo.ImportYWWai(ImportId ASC, SubjectCode ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportLoanSF')) BEGIN
	CREATE TABLE dbo.ImportLoanSF(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		OrgId int NULL,
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
		CONSTRAINT PK_ImportLoanSF PRIMARY KEY CLUSTERED
		(
			Id ASC
		)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportLoanSF WITH CHECK ADD CONSTRAINT FK_ImportLoanSF_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)
		
	CREATE NONCLUSTERED INDEX IX_ImportLoanSF_ImportId ON dbo.ImportLoanSF(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoanSF_LoanState ON dbo.ImportLoanSF(ImportId ASC, LoanState ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoanSF_CustomerName ON dbo.ImportLoanSF(ImportId ASC, CustomerName ASC, OrgId ASC, LoanStartDate ASC, LoanEndDate ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportLoanSF_LoanAccount ON dbo.ImportLoanSF(ImportId ASC, LoanAccount ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportWjflSF')) BEGIN
	CREATE TABLE dbo.ImportWjflSF(
		Id int IDENTITY(1,1) NOT NULL,
		ImportId int NOT NULL,
		WjflType smallint NOT NULL,
		LoanAccount varchar(50),
		OrgId int NULL,
		OrgName nvarchar(100),
		CustomerName nvarchar(20),
		CapitalAmount money,
		OweCapital money,
		DangerLevel nvarchar(20),
		OweInterestAmount money,
		LoanStartDate smalldatetime,
		LoanEndDate smalldatetime,
		OverdueDays int,
		OweInterestDays int,
		DanBaoFangShi nvarchar(100),
		Industry nvarchar(100),
		CustomerType nvarchar(100),
		LoanType nvarchar(100),
		IsNew nvarchar(1),
		[Comment] nvarchar(50)
	) ON [PRIMARY]

	ALTER TABLE dbo.ImportWjflSF WITH CHECK ADD CONSTRAINT FK_ImportWjflSF_Import FOREIGN KEY(ImportId) REFERENCES dbo.Import(Id)
	
	CREATE NONCLUSTERED INDEX IX_ImportWjflSF_ImportId ON dbo.ImportWjflSF(ImportId ASC) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX IX_ImportWjflSF_LoanAccount ON dbo.ImportWjflSF(ImportId ASC, LoanAccount ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Shell_01')) BEGIN
	CREATE TABLE dbo.Shell_01(
		Id int NOT NULL,
		Name nvarchar(100) NULL,
		Amount money NULL
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

	ALTER TABLE dbo.SourceTableSheet WITH CHECK ADD CONSTRAINT FK_SourceTableSheet_SourceTable FOREIGN KEY(TableId) REFERENCES dbo.SourceTable (Id)

	CREATE NONCLUSTERED INDEX IX_SourceTableSheet_TableId ON dbo.SourceTableSheet(TableId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('SourceTableSheetColumn')) BEGIN
	CREATE TABLE dbo.SourceTableSheetColumn(
		SheetId int NOT NULL,
		[Index] int NOT NULL,
		Name nvarchar(100) NOT NULL,
		CONSTRAINT PK_SourceTableSheetColumn PRIMARY KEY CLUSTERED (SheetId ASC, [Index] ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.SourceTableSheetColumn WITH CHECK ADD CONSTRAINT FK_SourceTableSheetColumn_SourceTableSheet FOREIGN KEY(SheetId) REFERENCES dbo.SourceTableSheet (Id)

	CREATE NONCLUSTERED INDEX IX_SourceTableSheetColumn_SheetId ON dbo.SourceTableSheetColumn(SheetId ASC) ON [PRIMARY]
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

	ALTER TABLE dbo.TargetTableSheet WITH CHECK ADD CONSTRAINT FK_TargetTableSheet_TargetTable FOREIGN KEY(TableId) REFERENCES dbo.TargetTable (Id)

	CREATE UNIQUE NONCLUSTERED INDEX IX_TargetTableSheet_TableId_Index ON dbo.TargetTableSheet (TableId, [Index]) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TargetTableSheetColumn')) BEGIN
	CREATE TABLE dbo.TargetTableSheetColumn(
		SheetId int NOT NULL,
		[Index] int NOT NULL,
		Name nvarchar(100) NOT NULL,
		CONSTRAINT PK_TargetTableColumn PRIMARY KEY CLUSTERED (SheetId ASC, [Index] ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.TargetTableSheetColumn WITH CHECK ADD CONSTRAINT FK_TargetTableSheetColumn_TargetTableSheet FOREIGN KEY(SheetId) REFERENCES dbo.TargetTableSheet (Id)

	CREATE NONCLUSTERED INDEX IX_TargetTableSheetColumn_SheetId ON dbo.TargetTableSheetColumn(SheetId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TableMapping')) BEGIN
	CREATE TABLE dbo.TableMapping(
		Id int NOT NULL,
		TableId varchar(20) NOT NULL,
		ColName varchar(50) NOT NULL,
		MappingName nvarchar(50) NOT NULL,
		MappingMode int NOT NULL,
		CONSTRAINT PK_TableMapping PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('AI_ImportTable')) BEGIN
	CREATE TABLE dbo.AI_ImportTable(
		Id int NOT NULL,
		Name varchar(50) NOT NULL
		CONSTRAINT PK_AI_ImportTable PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('AI_ImportColumn')) BEGIN
	CREATE TABLE dbo.AI_ImportColumn(
		Id int IDENTITY(1,1) NOT NULL,
		TableId int NOT NULL,
		[Index] int NOT NULL CONSTRAINT DF_AI_ImportColumn_Index DEFAULT (1),
		Name varchar(50) NOT NULL
		CONSTRAINT PK_AI_ImportColumn PRIMARY KEY CLUSTERED (Id ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.AI_ImportColumn WITH CHECK ADD CONSTRAINT FK_AI_ImportColumn_AI_ImportTable FOREIGN KEY(TableId) REFERENCES dbo.AI_ImportTable (Id)

	CREATE NONCLUSTERED INDEX IX_AI_ImportColumn_TableId ON dbo.AI_ImportColumn(TableId ASC) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('AI_ImportColumnMapping')) BEGIN
	CREATE TABLE dbo.AI_ImportColumnMapping(
		ColumnId int NOT NULL,
		[Index] int NOT NULL CONSTRAINT DF_AI_ImportColumnMapping_Index DEFAULT (1),
		Alias varchar(50) NOT NULL
		CONSTRAINT PK_AI_ImportColumnMapping PRIMARY KEY CLUSTERED (ColumnId ASC, [Index] ASC)
	) ON [PRIMARY]

	ALTER TABLE dbo.AI_ImportColumnMapping WITH CHECK ADD CONSTRAINT FK_AI_ImportColumnMapping_AI_ImportColumn FOREIGN KEY(ColumnId) REFERENCES dbo.AI_ImportColumn (Id)

	CREATE NONCLUSTERED INDEX IX_AI_ImportColumnMapping_TableId ON dbo.AI_ImportColumnMapping(ColumnId ASC) ON [PRIMARY]
END

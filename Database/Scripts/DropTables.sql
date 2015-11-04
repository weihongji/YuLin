IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Org')) BEGIN
	DROP TABLE Org
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('DanBaoFangShi')) BEGIN
	DROP TABLE DanBaoFangShi
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Direction')) BEGIN
	DROP TABLE Direction
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportLoan')) BEGIN
	ALTER TABLE dbo.ImportLoan DROP CONSTRAINT FK_ImportLoan_ImportItem
	DROP TABLE ImportLoan
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPrivate')) BEGIN
	ALTER TABLE dbo.ImportPrivate DROP CONSTRAINT FK_ImportPrivate_ImportItem
	DROP TABLE ImportPrivate
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportPublic')) BEGIN
	ALTER TABLE dbo.ImportPublic DROP CONSTRAINT FK_ImportPublic_ImportItem
	DROP TABLE ImportPublic
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportNonAccrual')) BEGIN
	ALTER TABLE dbo.ImportNonAccrual DROP CONSTRAINT FK_ImportNonAccrual_ImportItem
	DROP TABLE ImportNonAccrual
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportOverdue')) BEGIN
	ALTER TABLE dbo.ImportOverdue DROP CONSTRAINT FK_ImportOverdue_ImportItem
	DROP TABLE ImportOverdue
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('SourceTableSheetColumn')) BEGIN
	ALTER TABLE dbo.SourceTableSheetColumn DROP CONSTRAINT FK_SourceTableSheetColumn_SourceTableSheet
	DROP TABLE SourceTableSheetColumn
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('SourceTableSheet')) BEGIN
	ALTER TABLE dbo.SourceTableSheet DROP CONSTRAINT FK_SourceTableSheet_SourceTable
	DROP TABLE SourceTableSheet
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('SourceTable')) BEGIN
	DROP TABLE SourceTable
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TargetTableSheetColumn')) BEGIN
	ALTER TABLE dbo.TargetTableSheetColumn DROP CONSTRAINT FK_TargetTableSheetColumn_TargetTableSheet
	DROP TABLE TargetTableSheetColumn
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TargetTableSheet')) BEGIN
	ALTER TABLE dbo.TargetTableSheet DROP CONSTRAINT FK_TargetTableSheet_TargetTable
	DROP TABLE TargetTableSheet
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TargetTable')) BEGIN
	DROP TABLE TargetTable
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportYWNei')) BEGIN
	ALTER TABLE dbo.ImportYWNei DROP CONSTRAINT FK_ImportYWNei_ImportItem
	DROP TABLE ImportYWNei
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportYWWai')) BEGIN
	ALTER TABLE dbo.ImportYWWai DROP CONSTRAINT FK_ImportYWWai_ImportItem
	DROP TABLE ImportYWWai
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('ImportItem')) BEGIN
	ALTER TABLE dbo.ImportItem DROP CONSTRAINT FK_ImportItem_Import
	DROP TABLE ImportItem
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Import')) BEGIN
	DROP TABLE Import
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('TableMapping')) BEGIN
	DROP TABLE TableMapping
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('Shell_WJFL')) BEGIN
	DROP TABLE Shell_WJFL
END
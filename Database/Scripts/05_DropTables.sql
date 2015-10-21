ALTER TABLE dbo.ImportItem DROP CONSTRAINT FK_ImportItem_Import
ALTER TABLE dbo.ImportLoan DROP CONSTRAINT FK_ImportLoan_ImportItem
ALTER TABLE dbo.ImportPrivate DROP CONSTRAINT FK_ImportPrivate_ImportItem
ALTER TABLE dbo.ImportPublic DROP CONSTRAINT FK_ImportPublic_ImportItem
ALTER TABLE dbo.ImportNonAccrual DROP CONSTRAINT FK_ImportNonAccrual_ImportItem
ALTER TABLE dbo.ImportOverdue DROP CONSTRAINT FK_ImportOverdue_ImportItem
ALTER TABLE dbo.ImportYWNei DROP CONSTRAINT FK_ImportYWNei_ImportItem
ALTER TABLE dbo.ImportYWNei DROP CONSTRAINT FK_ImportYWWai_ImportItem
ALTER TABLE dbo.SourceTableSheet DROP CONSTRAINT FK_SourceTableSheet_SourceTable
ALTER TABLE dbo.SourceTableSheetColumn DROP CONSTRAINT FK_SourceTableSheetColumn_SourceTableSheet
ALTER TABLE dbo.TargetTableSheet DROP CONSTRAINT FK_TargetTableSheet_TargetTable
ALTER TABLE dbo.TargetTableSheetColumn DROP CONSTRAINT FK_TargetTableSheetColumn_TargetTableSheet
GO

DROP TABLE Org
DROP TABLE DanBaoFangShi
DROP TABLE Import
DROP TABLE ImportItem
DROP TABLE ImportLoan
DROP TABLE ImportPrivate
DROP TABLE ImportPublic
DROP TABLE ImportNonAccrual
DROP TABLE ImportOverdue
DROP TABLE ImportYWNei
DROP TABLE ImportYWWai
DROP TABLE SourceTable
DROP TABLE SourceTableSheet
DROP TABLE SourceTableSheetColumn
DROP TABLE TargetTable
DROP TABLE TargetTableSheet
DROP TABLE TargetTableSheetColumn

/*
TRUNCATE TABLE Org
TRUNCATE TABLE Import
TRUNCATE TABLE ImportItem
TRUNCATE TABLE ImportLoan
TRUNCATE TABLE ImportPrivate
TRUNCATE TABLE ImportPublic
TRUNCATE TABLE ImportNonAccrual
TRUNCATE TABLE ImportOverdue
TRUNCATE TABLE ReportLoanRiskPerMonthFYJ
*/
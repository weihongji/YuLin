/*
DROP TABLE Org
DROP TABLE Import
DROP TABLE ImportItem
DROP TABLE ImportLoan
DROP TABLE ImportPrivate
DROP TABLE ImportPublic
DROP TABLE ImportNonAccrual
DROP TABLE ImportOverdue
*/


ALTER TABLE dbo.ImportItem DROP CONSTRAINT FK_ImportItem_Import
ALTER TABLE dbo.ImportLoan DROP CONSTRAINT FK_ImportLoan_ImportItem
ALTER TABLE dbo.ImportPrivate DROP CONSTRAINT FK_ImportPrivate_ImportItem
ALTER TABLE dbo.ImportPublic DROP CONSTRAINT FK_ImportPublic_ImportItem
ALTER TABLE dbo.ImportNonAccrual DROP CONSTRAINT FK_ImportNonAccrual_ImportItem
ALTER TABLE dbo.ImportOverdue DROP CONSTRAINT FK_ImportOverdue_ImportItem

/*
TRUNCATE TABLE Org
TRUNCATE TABLE Import
TRUNCATE TABLE ImportItem
TRUNCATE TABLE ImportLoan
TRUNCATE TABLE ImportPrivate
TRUNCATE TABLE ImportPublic
TRUNCATE TABLE ImportNonAccrual
TRUNCATE TABLE ImportOverdue
*/
IF OBJECT_ID('Shell_LoanRisk') IS NOT NULL BEGIN
	DROP TABLE Shell_LoanRisk
END

IF NOT EXISTS(SELECT * FROM TargetTableSheetColumn WHERE SheetId = 12 AND [Index] = 16) BEGIN
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (12, 16, '笔数5')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (12, 17, '余额5')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (12, 18, '占比5')
END

IF EXISTS(SELECT * FROM TableMapping WHERE TableId = 'ImportLoanXZ' AND ColName = 'LoanState' AND MappingMode = 2) BEGIN
	UPDATE TableMapping SET MappingMode = 1 WHERE TableId = 'ImportLoanXZ' AND ColName = 'LoanState' AND MappingMode = 2
END

IF EXISTS(SELECT * FROM TableMapping WHERE TableId = 'ImportLoanJQ' AND ColName = 'LoanState' AND MappingMode = 2) BEGIN
	UPDATE TableMapping SET MappingMode = 1 WHERE TableId = 'ImportLoanJQ' AND ColName = 'LoanState' AND MappingMode = 2
END

IF EXISTS(SELECT * FROM TargetTableSheet WHERE TableId = 62 AND [Index] > 1) BEGIN
	DELETE FROM TargetTableSheetColumn WHERE SheetId IN (SELECT Id FROM TargetTableSheet WHERE TableId = 62 AND [Index] > 1)
	DELETE FROM TargetTableSheet WHERE TableId = 62 AND [Index] > 1
	UPDATE TargetTableSheet SET Name = '新增逾期贷款' WHERE TableId = 62 AND [Index] = 1
END

IF EXISTS(SELECT * FROM TargetTableSheet WHERE TableId = 63 AND [Index] > 1) BEGIN
	DELETE FROM TargetTableSheetColumn WHERE SheetId IN (SELECT Id FROM TargetTableSheet WHERE TableId = 63 AND [Index] > 1)
	DELETE FROM TargetTableSheet WHERE TableId = 63 AND [Index] > 1
	UPDATE TargetTableSheet SET Name = '化解' WHERE TableId = 63 AND [Index] = 1
END

IF NOT EXISTS(SELECT * FROM TargetTable WHERE Id = 64) BEGIN
	PRINT 'Initial TargetTable with 五级分类预测...'
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (64, '五级分类预测', '五级分类预测.xls')
	
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (46, 64, 1, 'Sheet1', 2, 6, 6)

	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 1, '行名')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 2, '企业（客户）名称')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 3, '贷款余额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 4, '欠息金额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 5, '放款日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 6, '到期日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 7, '本金逾期天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 8, '欠息天数')
END
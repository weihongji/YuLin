IF OBJECT_ID('Shell_LoanRisk') IS NOT NULL BEGIN
	DROP TABLE Shell_LoanRisk
END

IF NOT EXISTS(SELECT * FROM TargetTableSheetColumn WHERE SheetId = 12 AND [Index] = 16) BEGIN
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (12, 16, '����5')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (12, 17, '���5')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (12, 18, 'ռ��5')
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
	UPDATE TargetTableSheet SET Name = '�������ڴ���' WHERE TableId = 62 AND [Index] = 1
END

IF EXISTS(SELECT * FROM TargetTableSheet WHERE TableId = 63 AND [Index] > 1) BEGIN
	DELETE FROM TargetTableSheetColumn WHERE SheetId IN (SELECT Id FROM TargetTableSheet WHERE TableId = 63 AND [Index] > 1)
	DELETE FROM TargetTableSheet WHERE TableId = 63 AND [Index] > 1
	UPDATE TargetTableSheet SET Name = '����' WHERE TableId = 63 AND [Index] = 1
END

IF NOT EXISTS(SELECT * FROM TargetTable WHERE Id = 64) BEGIN
	PRINT 'Initial TargetTable with �弶����Ԥ��...'
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (64, '�弶����Ԥ��', '�弶����Ԥ��.xls')
	
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (46, 64, 1, 'Sheet1', 2, 6, 6)

	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 1, '����')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 2, '��ҵ���ͻ�������')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 3, '�������')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 4, 'ǷϢ���')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 5, '�ſ�����')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 6, '��������')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 7, '������������')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (46, 8, 'ǷϢ����')
END
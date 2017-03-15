IF NOT EXISTS(SELECT * FROM TargetTable WHERE Id = 65) BEGIN
	PRINT 'Initial TargetTable with GF0102-161...'
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (65, 'GF0102-161', 'GF0102-161.xls')
	
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (47, 65, 1, 'GF0102', 5, 16, 18)
	
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (47, 1, '序号')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (47, 2, '项目')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (47, 3, '本外币合计')
END

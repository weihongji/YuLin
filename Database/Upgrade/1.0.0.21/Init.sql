IF NOT EXISTS(SELECT * FROM Org WHERE Id = 31) BEGIN
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (31, '806050000', '榆林监督分中心', '监督分中心', NULL)
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (32, '806052501', '榆阳西路小微支行', '榆阳西路小微支行', '榆林分行榆阳西路小微支行')
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (33, '806052701', '中赢广场支行', '中赢广场', '榆林分行中赢广场支行')
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (34, '806055555', '榆林分行会计结算部', '会计结算部', NULL)
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (35, '806056666', '长安银行榆林运行中心', '运行中心', NULL)
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (36, '806130001', '神府区域直属支行', '神府直属支行', NULL)
END

UPDATE Org SET Name = '长安银行榆林清算中心', Alias1 = '清算中心' WHERE OrgNo = '806057777' AND Name = '806057777'

IF NOT EXISTS(SELECT * FROM Org WHERE Id = 31) BEGIN
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (31, '806050000', '���ּල������', '�ල������', NULL)
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (32, '806052501', '������·С΢֧��', '������·С΢֧��', '���ַ���������·С΢֧��')
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (33, '806052701', '��Ӯ�㳡֧��', '��Ӯ�㳡', '���ַ�����Ӯ�㳡֧��')
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (34, '806055555', '���ַ��л�ƽ��㲿', '��ƽ��㲿', NULL)
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (35, '806056666', '��������������������', '��������', NULL)
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (36, '806130001', '������ֱ��֧��', '��ֱ��֧��', NULL)
END

UPDATE Org SET Name = '��������������������', Alias1 = '��������' WHERE OrgNo = '806057777' AND Name = '806057777'

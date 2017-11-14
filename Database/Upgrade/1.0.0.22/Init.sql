IF NOT EXISTS(SELECT * FROM Org WHERE Id = 39) BEGIN
	INSERT INTO Org(Id, OrgNo, Name, Alias1, Alias2) VALUES (39 ,'806052900', '榆林学苑支行', '榆林学苑支行', NULL)
END

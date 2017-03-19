IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sfGetOrgs]')) BEGIN
	DROP FUNCTION dbo.sfGetOrgs
END
GO

CREATE FUNCTION dbo.sfGetOrgs()
RETURNS TABLE
AS
--RETURN SELECT Id, OrgNo, Name FROM dbo.sfGetOrgsOf('YL')
RETURN SELECT Id, OrgNo, Name FROM dbo.sfGetOrgsOf('All')

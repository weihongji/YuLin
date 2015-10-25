IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spDQDKQK_M') BEGIN
	DROP PROCEDURE spDQDKQK_M
END
GO

CREATE PROCEDURE dbo.spDQDKQK_M
	@asOfDate as smalldatetime,
	@customCols as nvarchar(2000)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate
	DECLARE @sql nvarchar(2000)
	set @sql='insert into #mapping(colName)  select col='''+ replace(@customCols,',',''' union all select ''')+''''
	create table #mapping
	(
		Id int NOT NULL IDENTITY (1, 1),
		colName varchar(50) COLLATE Chinese_PRC_CI_AS NOT NULL 
		
	)

	exec (@sql)
	
	set @sql=( select case when c.MappingMode is not null then  'p.['+c.ColName+'] ['+ c.MappingName+'],' else ''''' [' +  isnull(m.colName,'')+'],'  end from #mapping m
	left join [TableMapping] c on m.colName  = c.ColName and [TableId]='IMPORTPUBLIC'  for xml path(''))
	
	set @sql='select '+ LEFT(@sql,LEN(@sql)-1) + ' from ImportPublic p where p.ImportId=@importId order by p.OrgName2'

	
	exec sp_executesql @sql ,N'@importId int',@importId
	
	drop table #mapping
END

IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'spSF6301_141') BEGIN
	DROP PROCEDURE spSF6301_141
END
GO

CREATE PROCEDURE spSF6301_141
	@asOfDate as smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @importId int
	DECLARE @importItemIdForPublic int
	DECLARE @importItemIdForLoan int
	DECLARE @importItemIdFoPrivate int
	SELECT @importId = Id FROM Import WHERE ImportDate = @asOfDate

	SELECT @importItemIdForLoan=Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 1
	SELECT @importItemIdForPublic=Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 2
	SELECT @importItemIdFoPrivate=Id FROM ImportItem WHERE ImportId = @importId AND ItemType = 3
	
	CREATE TABLE #resultsTable
	(
		Id int NOT NULL IDENTITY (1, 1),
		TypeId int NOT NULL,
		BigComp numeric(18, 2) ,
		MediumComp numeric(18, 2) ,
		SmallComp numeric(18, 2) ,
		MicroComp numeric(18, 2) ,
		Less500 numeric(18, 2) ,
		personalComp numeric(18, 2) ,
		IndividualComp numeric(18, 2) ,
		CustomField numeric(18, 2) 
	)  
	


	--1,'正常%'
	--2,'关注%'
	--3,'次级%'
	--4,'可疑%'
	--5'损失%'
	
	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(1,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(0,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(0,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(2,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(3,0,0,0,0,0,0,0,0)
	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(4,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(5,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(0,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(6,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(7,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(8,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(9,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(0,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(10,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(11,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(12,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(0,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(13,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(0,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(14,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(14,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(15,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(0,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(0,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(15,0,0,0,0,0,0,0,0)

	insert into #resultsTable(TypeId,BigComp,MediumComp,SmallComp,MicroComp,Less500,personalComp,IndividualComp,CustomField) 
	values(15,0,0,0,0,0,0,0,0)


	
	-- for big company
	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业' and l.DangerLevel like '损失%')
	where TypeId=5

	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业' and l.DangerLevel like '可疑%')
	where TypeId=4

	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业' and l.DangerLevel like '次级%')
	where TypeId=3

	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业' and l.DangerLevel like '关注%')
	where TypeId=2

	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')

	where TypeId=1

	--end

	-- for medium company
	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业' and l.DangerLevel like '损失%')
	where TypeId=5

	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业' and l.DangerLevel like '可疑%')
	where TypeId=4

	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业' and l.DangerLevel like '次级%')
	where TypeId=3

	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业' and l.DangerLevel like '关注%')
	where TypeId=2

	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')

	where TypeId=1

	--end

	-- for small company
	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业' and l.DangerLevel like '损失%')
	where TypeId=5

	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业' and l.DangerLevel like '可疑%')
	where TypeId=4

	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业' and l.DangerLevel like '次级%')
	where TypeId=3

	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业' and l.DangerLevel like '关注%')
	where TypeId=2

	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')

	where TypeId=1

	--end

	-- for micro company
	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业' and l.DangerLevel like '损失%')
	where TypeId=5

	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业' and l.DangerLevel like '可疑%')
	where TypeId=4

	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业' and l.DangerLevel like '次级%')
	where TypeId=3

	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业' and l.DangerLevel like '关注%')
	where TypeId=2

	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')

	where TypeId=1

	--end

	-- for small and micro company which balance less than 5000000
	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000 and l.DangerLevel like '损失%')
	where TypeId=5

	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000 and l.DangerLevel like '可疑%')
	where TypeId=4

	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000 and l.DangerLevel like '次级%')
	where TypeId=3

	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000 and l.DangerLevel like '关注%')
	where TypeId=2

	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	left join  ImportLoan l on l.LoanAccount= p.LoanAccount and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)

	where TypeId=1

	--end

	--  for private company
	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	left join  ImportLoan l on p.CustomerName=l.CustomerName and l.LoanStartDate=p.ContractStartDate and l.LoanEndDate=p.ContractEndDate and l.OrgNo=p.OrgNo and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdFoPrivate and l.DangerLevel like '损失%')
	where TypeId=5

	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	left join  ImportLoan l on p.CustomerName=l.CustomerName and l.LoanStartDate=p.ContractStartDate and l.LoanEndDate=p.ContractEndDate and l.OrgNo=p.OrgNo and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdFoPrivate and l.DangerLevel like '可疑%')
	where TypeId=4

	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	left join  ImportLoan l on p.CustomerName=l.CustomerName and l.LoanStartDate=p.ContractStartDate and l.LoanEndDate=p.ContractEndDate and l.OrgNo=p.OrgNo and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdFoPrivate and l.DangerLevel like '次级%')
	where TypeId=3

	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	left join  ImportLoan l on p.CustomerName=l.CustomerName and l.LoanStartDate=p.ContractStartDate and l.LoanEndDate=p.ContractEndDate and l.OrgNo=p.OrgNo and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdFoPrivate and l.DangerLevel like '关注%')
	where TypeId=2
	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	left join  ImportLoan l on p.CustomerName=l.CustomerName and l.LoanStartDate=p.ContractStartDate and l.LoanEndDate=p.ContractEndDate and l.OrgNo=p.OrgNo and l.ImportItemId=@importItemIdForLoan
	where p.ImportItemId=@importItemIdFoPrivate )
	where TypeId=1

	--end

	--update bigcomp
	--update #resultsTable set BigComp= BigComp- (select isnull(sum(BigComp),0) from #resultsTable where TypeId<>1) where TypeId=1
	--update #resultsTable set MediumComp= MediumComp- (select isnull(sum(MediumComp),0) from #resultsTable where TypeId<>1) where TypeId=1
	--update #resultsTable set SmallComp= SmallComp- (select isnull(sum(SmallComp),0) from #resultsTable where TypeId<>1) where TypeId=1
	--update #resultsTable set MicroComp= MicroComp- (select isnull(sum(MicroComp),0) from #resultsTable where TypeId<>1) where TypeId=1
	--update #resultsTable set Less500= Less500- (select isnull(sum(Less500),0) from #resultsTable where TypeId<>1) where TypeId=1
	--update #resultsTable set personalComp= personalComp- (select isnull(sum(personalComp),0) from #resultsTable where TypeId<>1) where TypeId=1
	--end

	--for danbao fangshi mapping

		--6,'信用'
		--7,'保证'
		--8,'抵押'
		--9,'质押'
		
	--end
		
	--big
	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='信用'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=6
	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='保证'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=7
	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=8

	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=9

	--end

	--medium
	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='信用'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=6
	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='保证'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=7
	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=8

	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=9

	--end

	--small
	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='信用'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=6
	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='保证'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=7
	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=8

	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=9

	--end

	--micro
	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='信用'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=6
	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='保证'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=7
	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=8

	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=9

	--end

	--less500
	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='信用'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=6
	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='保证'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=7
	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=8

	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	join DanBaoFangShi d on d.Name=p.VouchTypeName and d.Category='抵押'
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=9

	--end

	--private  

	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	join DanBaoFangShi d on d.Name=p.DanBaoFangShi and d.Category='信用'
	where p.ImportItemId=@importItemIdFoPrivate )
	where TypeId=6
	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	join DanBaoFangShi d on d.Name=p.DanBaoFangShi and d.Category='保证'
	where p.ImportItemId=@importItemIdFoPrivate )
	where TypeId=7
	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	join DanBaoFangShi d on d.Name=p.DanBaoFangShi and d.Category='抵押'
	where p.ImportItemId=@importItemIdFoPrivate )
	where TypeId=8

	update #resultsTable set personalComp=
	(select  sum(p.LoanBalance) from ImportPrivate p
	join DanBaoFangShi d on d.Name=p.DanBaoFangShi and d.Category='抵押'
	where p.ImportItemId=@importItemIdFoPrivate)
	where TypeId=9

	--end



	--end



	--- loan end day 
	--10,'<=90'
	--11,'>90 and <=360'
	--12,'>360'

	update #resultsTable set BigComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>0 and psub.overdays<=90
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=10
	update #resultsTable set BigComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>90 and psub.overdays<=360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=11
	update #resultsTable set BigComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=12

	--++++++++++++++++++++++++++++++++++++++++
	update #resultsTable set MediumComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>0 and psub.overdays<=90
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=10
	update #resultsTable set MediumComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>90 and psub.overdays<=360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=11
	update #resultsTable set MediumComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=12

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++

	update #resultsTable set SmallComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>0 and psub.overdays<=90
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=10
	update #resultsTable set SmallComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>90 and psub.overdays<=360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=11
	update #resultsTable set SmallComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=12

	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	update #resultsTable set MicroComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>0 and psub.overdays<=90
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=10
	update #resultsTable set MicroComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>90 and psub.overdays<=360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=11
	update #resultsTable set MicroComp=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=12

	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	update #resultsTable set Less500=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>0 and psub.overdays<=90
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=10
	update #resultsTable set Less500=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>90 and psub.overdays<=360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=11
	update #resultsTable set Less500=
	(select SUM(p.Balance1) from importpublic p
	join (select ps.Id, (case when DATEDIFF(day,ps.LoanEndDate, @asOfDate) > ps.OverdueDays then DATEDIFF(day, ps.LoanEndDate, @asOfDate) else ps.OverdueDays end) overdays  from importpublic ps ) psub
	on psub.Id=p.Id and psub.overdays>360
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=12

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	update #resultsTable set personalComp=
	(select SUM(p.LoanBalance) from ImportPrivate p
	join (select ps.Id, (case when DATEDIFF(day,ps.ContractEndDate, @asOfDate) > ps.InterestOverdueDays then DATEDIFF(day, ps.ContractEndDate, @asOfDate) else ps.InterestOverdueDays end) overdays  from ImportPrivate ps ) psub
	on psub.Id=p.Id and psub.overdays>0 and psub.overdays<=90
	where p.ImportItemId=@importItemIdFoPrivate )
	where TypeId=10
	update #resultsTable set personalComp=
	(select SUM(p.LoanBalance) from ImportPrivate p
	join (select ps.Id, (case when DATEDIFF(day,ps.ContractEndDate, @asOfDate) > ps.InterestOverdueDays then DATEDIFF(day, ps.ContractEndDate, @asOfDate) else ps.InterestOverdueDays end) overdays  from ImportPrivate ps ) psub
	on psub.Id=p.Id and psub.overdays>90 and psub.overdays<=360
	where p.ImportItemId=@importItemIdFoPrivate)
	where TypeId=11
	update #resultsTable set personalComp=
	(select SUM(p.LoanBalance) from ImportPrivate p
	join (select ps.Id, (case when DATEDIFF(day,ps.ContractEndDate, @asOfDate) > ps.InterestOverdueDays then DATEDIFF(day, ps.ContractEndDate, @asOfDate) else ps.InterestOverdueDays end) overdays  from ImportPrivate ps ) psub
	on psub.Id=p.Id and psub.overdays>360
	where p.ImportItemId=@importItemIdFoPrivate)
	where TypeId=12


	--end
	


	--+++++++++++++++++++++
	--.地方政府融资平台贷款余额: 13
	update #resultsTable set BigComp=
	(select  sum(p.Balance1) from ImportPublic p
	where p.IsINRZ='是' and p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=13

	update #resultsTable set MediumComp=
	(select  sum(p.Balance1) from ImportPublic p
	where p.IsINRZ='是' and p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=13

	update #resultsTable set SmallComp=
	(select  sum(p.Balance1) from ImportPublic p
	where p.IsINRZ='是' and p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=13

	update #resultsTable set MicroComp=
	(select  sum(p.Balance1) from ImportPublic p
	where p.IsINRZ='是' and p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=13

	update #resultsTable set Less500=
	(select  sum(p.Balance1) from ImportPublic p
	where p.IsINRZ='是' and p.ImportItemId=@importItemIdForPublic  and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=13


	--end


	--++++++++++++++++++++++++++++++++++++++++++++++++++++
	--表外授信余额: 14

	update #resultsTable set BigComp=
	(select  sum(p.NormalBalance) from ImportPublic p
	where p.PublicType=2 and p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业')
	where TypeId=14

	update #resultsTable set MediumComp=
	(select  sum(p.NormalBalance) from ImportPublic p
	where p.PublicType=2 and p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业')
	where TypeId=14

	update #resultsTable set SmallComp=
	(select  sum(p.NormalBalance) from ImportPublic p
	where p.PublicType=2 and p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业')
	where TypeId=14

	update #resultsTable set MicroComp=
	(select  sum(p.NormalBalance) from ImportPublic p
	where p.PublicType=2 and p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业')
	where TypeId=14

	update #resultsTable set Less500=
	(select  sum(p.NormalBalance) from ImportPublic p
	where p.PublicType=2 and p.ImportItemId=@importItemIdForPublic  and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000)
	where TypeId=14

	--end

	--++++++++++++++++++++++++++++++++++++++++++++
	--贷款户数 :15

	update #resultsTable set BigComp=
	(select count(1) from (select  count(1) t from ImportPublic p
	where  p.ImportItemId=@importItemIdForPublic and p.ScopeName='大型企业' group by p.CustomerName) a)
	where TypeId=15

	update #resultsTable set MediumComp=
	(select count(1) from (select  count(1) t from ImportPublic p
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='中型企业' group by p.CustomerName) a)
	where TypeId=15

	update #resultsTable set SmallComp=
	(select count(1) from (select  count(1) t from ImportPublic p
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='小型企业' group by p.CustomerName) a)
	where TypeId=15

	update #resultsTable set MicroComp=
	(select count(1) from (select  count(1) t from ImportPublic p
	where p.ImportItemId=@importItemIdForPublic and p.ScopeName='微型企业' group by p.CustomerName) a)
	where TypeId=15

	update #resultsTable set Less500=
	(select count(1) from (select  count(1) t from ImportPublic p
	where  p.ImportItemId=@importItemIdForPublic  and p.ScopeName IN ('小型企业', '微型企业') AND p.Balance1<=5000000 group by p.CustomerName) a)
	where TypeId=15

	update #resultsTable set personalComp=
	(select count(1) from (select  count(1) t from ImportPrivate p
	where  p.ImportItemId=@importItemIdFoPrivate group by p.IdCardNo ,p.CustomerName) a)
	where TypeId=15

	--end

	
	update #resultsTable set IndividualComp=personalComp;
	
	select * from #resultsTable
	drop table #resultsTable
End
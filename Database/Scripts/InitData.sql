IF NOT EXISTS(SELECT * FROM Org) BEGIN
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050101', '望湖路支行', '望湖路', '榆林分行望湖路支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050201', '榆阳西路支行', '榆阳西路', '榆林分行榆阳西路支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050301', '世纪广场支行', '世纪广场', '榆林分行世纪广场支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050401', '榆林保宁路支行', '保宁路', '榆林分行保宁路支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050501', '榆林开发区支行', '开发区', '榆林分行开发区支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050601', '神木县支行', '神木支行', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050701', '府谷县支行', '府谷支行', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050801', '横山县支行', '横山支行', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050901', '榆林银沙路支行', '银沙路', '榆林分行银沙路支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051001', '靖边县支行', '靖边支行', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051101', '榆林肤施路支行', '肤施路', '榆林分行肤施路支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051201', '神木县大柳塔支行', '神木大柳塔', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051301', '府谷县河滨路支行', '府谷河滨路', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051401', '定边县支行', '定边支行', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051501', '神木县东兴街支行', '神木东兴街', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051601', '榆林青山路社区支行', '青山路', '榆林分行青山路社区支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051701', '榆林上郡路支行', '上郡路', '榆林分行上郡路支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051801', '靖边县长城路小微支行', '靖边长城路', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806051901', '榆林北大街社区支行', '北大街', '榆林分行北大街社区支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806052001', '榆林金沙路社区支行', '金沙路', '榆林分行金沙路社区支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806052101', '横山县北大街小微支行', '横山北大街', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806052201', '府谷县河滨公园小微支行', '府谷河滨公园', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806052301', '神木县麟州路小微支行', '神木麟州路', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806052401', '神木县锦界工业园小微支行', '神木锦界工业园', NULL)
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806058001', '榆林分行营业部', '公司部', '营业部')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806050001', '榆林分行营业部', '公司部', '营业部')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806052601', '榆林明珠大道支行', '明珠大', '榆林分行明珠大道支行')
	INSERT INTO Org(Number, Name, Alias1, Alias2) VALUES ('806057777', '806057777', '806057777', NULL)
END

IF NOT EXISTS(SELECT * FROM DanBaoFangShi) BEGIN
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('信用', '信用')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('(出让)国有土地使用权抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('(划拨)国有土地使用权抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('(开发区内)标准厂房抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('采矿权抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('其他抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('其他设备抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('商品房(商用)产权房期房抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('商品房(商用)产权房现房抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('商品房(住宅)产权房期房抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('商品房(住宅)产权房现房抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('一般厂房抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('在建工程抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('自建办公楼现房抵押', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('交通运输工具(车、船、飞机)', '抵押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('道路收费权质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('非上市公司股权质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('其他质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('商标权质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('我行保本型理财产品质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('我行人民币存款质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('应收账款质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('著作权中的财产权质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('专利权质押', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('上市公司', '质押')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('100%保证金', '保证')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('其他保证', '保证')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('小型企业保证', '保证')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('行政事业单位保证', '保证')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('中型企业保证', '保证')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('自然人保证', '保证')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('担保公司', '保证')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('多户联保', '保证')
	INSERT INTO DanBaoFangShi(Name, Category) VALUES ('大型企业', '保证')
END

IF NOT EXISTS(SELECT * FROM SourceTable) BEGIN
	INSERT INTO SourceTable(Id, Name) VALUES (1, '贷款欠款查询')
	INSERT INTO SourceTable(Id, Name) VALUES (2, '对公')
	INSERT INTO SourceTable(Id, Name) VALUES (3, '个人')
	INSERT INTO SourceTable(Id, Name) VALUES (4, '非应计贷款明细表')
	INSERT INTO SourceTable(Id, Name) VALUES (5, '逾期贷款明细表')
	INSERT INTO SourceTable(Id, Name) VALUES (6, '业务状况表（表内）')
	INSERT INTO SourceTable(Id, Name) VALUES (7, '业务状况表（表外）')
END

IF NOT EXISTS(SELECT * FROM SourceTableSheet) BEGIN
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (1, 1, 1, '贷款欠款查询', 0, '')
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (2, 2, 1, '表内', 1, '')
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (3, 3, 1, '个人', 2, '')
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (4, 4, 1, '非应计贷款明细表', 7, '本页小计')
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (5, 5, 1, '逾期贷款明细表', 8, '本页小计')
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (6, 2, 2, '表外', 0, '')
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (7, 2, 3, '委贷', 0, '')
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (8, 6, 1, '业务状况表（表内）', 8, '10')
	INSERT INTO SourceTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, DataRowEndingFlag) VALUES (9, 7, 1, '业务状况表（表外）', 8, '09')
END

IF NOT EXISTS(SELECT * FROM SourceTableSheetColumn) BEGIN
	/* Loan */
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 1, '机构号码')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 2, '贷款科目')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 3, '贷款帐号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 4, '客户名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 5, '客户编号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 6, '客户类型')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 7, '币种')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 8, '贷款总额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 9, '本金余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 10, '拖欠本金')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 11, '拖欠应收利息')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 12, '拖欠催收利息')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 13, '')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 14, '借据编号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 15, '放款日期')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 16, '到期日期')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 17, '置换/转让')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 18, '核销标志')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 19, '贷款状态')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 20, '贷款种类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 21, '贷款种类说明')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 22, '贷款用途')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 23, '转列逾期')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 24, '转列非应计日期')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 25, '利息计至日')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 26, '利率种类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 27, '利率加减符号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 28, '利率加减码')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 29, '逾期利率依据方式')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 30, '逾期利率种类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 31, '逾期利率加减符号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 32, '逾期利率加减码')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 33, '利率依据方式')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 34, '合同最初计息利率')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 35, '合同最初逾期利率')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (1, 36, '扣款账号')

	/* Public */
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 1, '分行名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 2, '支行名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 3, '')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 4, '客户姓名')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 5, '借款人企业性质')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 6, '组织机构代码')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 7, '合同编号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 8, '借据编号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 9, '借据开始日期')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 10, '借据结束日期')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 11, '行业门类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 12, '行业大类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 13, '行业中类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 14, '行业小类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 15, '贷款期限(月)')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 16, '币种')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 17, '发放后投向行业门类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 18, '发放后投向行业大类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 19, '发放后投向行业中类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 20, '发放后投向行业小类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 21, '业务类别')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 22, '授信品种')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 23, '核算项目名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 24, '')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 25, '七级分类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 26, '客户信用等级')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 27, '')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 28, '客户规模(行内）')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 29, '')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 30, '客户规模(行外）')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 31, '本金逾期天数')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 32, '欠息天数')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 33, '贷款余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 34, '利率')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 35, '浮动利率')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 36, '主要担保方式')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 37, '保证金比例')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 38, '正常余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 39, '逾期余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 40, '非应计余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 41, '贷款账号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 42, '是否涉农')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (2, 43, '是否政府融资平台')

	/* Private */
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 1, '二级分行')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 2, '支行')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 3, '信贷产品名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 4, '产品核算项目')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 5, '贷款期限（月）')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 6, '综合授信额度')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 7, '七级分类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 8, '还款方式')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 9, '客户名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 10, '证件号码')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 11, '币种')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 12, '合同开始日期')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 13, '合同到期日')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 14, '借款利率（执行）')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 15, '担保方式')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 16, '贷款余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 17, '贷款发放后投向')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 18, '贷款发放后投向')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 19, '贷款发放后投向')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 20, '贷款发放后投向')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 21, '本金最长逾期天数')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 22, '利息最长逾期天数')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 23, '拖欠利息')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 24, '逾期余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (3, 25, '非应计余额')

	/* NonAccrual */
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 1, '机构名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 2, '客户名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 3, '贷款帐号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 4, '客户编号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 5, '贷款种类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 6, '贷款发放日')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 7, '贷款到期日')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 8, '贷款余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 9, '利息余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (4, 10, '担保情况')

	/* Overdue */
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 1, '机构名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 2, '客户名称')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 3, '贷款帐号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 4, '客户编号')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 5, '贷款种类')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 6, '贷款发放日')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 7, '贷款到期日')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 8, '逾期本金余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 9, '利息余额')
	INSERT INTO SourceTableSheetColumn(SheetId, [Index], Name) VALUES (5, 10, '担保情况')

	/* YWNei */
	/* YWWai */
END

IF NOT EXISTS(SELECT * FROM TargetTable) BEGIN
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (1, '风险贷款情况表（五级分类）', '榆林分行风险贷款情况表.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (2, '风险贷款通报', '风险贷款通报.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (3, '榆林地区不良贷款监测旬报', '榆林地区不良贷款监测旬报.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (4, '中小企业资金需求及银行业支持情况表', '中小企业资金需求及银行业支持情况表.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (5, '城商行授信情况统计表', '城商行授信情况统计表.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (6, '风险贷款变化情况表', '风险贷款变化情况表.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (7, '榆林分行三张表汇总表', '榆林分行三张表汇总表.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (8, '贷款质量分类情况汇总表', '贷款质量分类情况汇总表.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (20, '风险贷款情况表-行业版', '榆林分行风险贷款情况表-行业版.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (21, 'GF0102-081', 'GF0102-081.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (22, 'GF0107-141', 'GF0107-141.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (23, 'SF6301-141', 'SF6301-141.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (24, 'SF6401-141', 'SF6401-141.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (31, 'GF1101-121', 'GF1101-121.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (32, 'GF1301-081', 'GF1301-081.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (33, 'GF1302-081', 'GF1302-081.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (34, 'GF1303-081', 'GF1303-081.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (35, 'GF1304-081', 'GF1304-081.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (36, 'GF1403-111', 'GF1403-111.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (37, 'SF6302-131', 'SF6302-131.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (38, 'SF6402-131', 'SF6402-131.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (39, 'GF1103-121', 'GF1103-121.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (40, 'GF1200-101', 'GF1200-101.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (61, '信贷数据需求', '信贷数据需求.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (62, '结清贷款明细表', '结清贷款明细表.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (63, '新增贷款明细表', '新增贷款明细表.xls')
	INSERT INTO TargetTable(Id, Name, [FileName]) VALUES (64, '风险贷款变化情况表', '风险贷款变化情况表.xls')
END

IF NOT EXISTS(SELECT * FROM TargetTableSheet) BEGIN
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (1, 1, 1, '非应计', 2, 6, 6)
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (2, 1, 2, '不良贷款', 2, 6, 6)
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (3, 1, 3, '逾期', 2, 6, 6)
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (4, 1, 4, '只欠息', 2, 6, 6)
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (5, 1, 5, '关注贷款', 2, 6, 6)
	INSERT INTO TargetTableSheet(Id, TableId, [Index], Name, RowsBeforeHeader, FooterStartRow, FooterEndRow) VALUES (6, 20, 1, '<yyyy-M>', 0, 4, 4)
END

IF NOT EXISTS(SELECT * FROM TargetTableSheetColumn) BEGIN
	/* 非应计 */
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 1, '行名')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 2, '客户名称')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 3, '贷款余额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 4, '七级分类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 5, '欠息金额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 6, '放款日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 7, '到期日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 8, '逾期天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 9, '欠息天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 10, '担保方式')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 11, '行业')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 12, '客户类型')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 13, '贷款类型')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 14, '是否本月新增')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (1, 15, '备注')

	/* 不良贷款 */
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 1, '行名')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 2, '企业（客户）名称')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 3, '贷款余额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 4, '七级分类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 5, '欠息金额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 6, '发放日')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 7, '到期日')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 8, '逾期天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 9, '欠息天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 10, '担保方式')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 11, '行业')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 12, '客户类型')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 13, '贷款类型')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 14, '是否本月新增')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (2, 15, '备注')

	/* 逾期 */
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 1, '行名')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 2, '客户名称')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 3, '贷款余额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 4, '违约金额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 5, '七级分类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 6, '欠息金额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 7, '放款日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 8, '到期日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 9, '逾期天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 10, '欠息天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 11, '担保方式')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 12, '行业')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 13, '客户类型')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 14, '贷款种类说明')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 15, '是否本月新增')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (3, 16, '备注')

	/* 只欠息 */
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 1, '行名')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 2, '客户名称')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 3, '本金余额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 4, '七级分类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 5, '欠息金额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 6, '放款日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 7, '到期日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 8, '逾期天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 9, '欠息天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 10, '担保方式')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 11, '行业')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 12, '客户类型')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 13, '贷款种类说明')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 14, '是否本月新增')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (4, 15, '备注')

	/* 关注贷款 */
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 1, '行名')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 2, '客户名称')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 3, '贷款余额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 4, '七级分类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 5, '欠息金额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 6, '放款日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 7, '到期日期')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 8, '逾期天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 9, '欠息天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 10, '担保方式')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 11, '行业')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 12, '客户类型')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 13, '贷款类型')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 14, '是否本月新增')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (5, 15, '备注')

	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 1, '所在分行')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 2, '经办机构')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 3, '客户')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 4, '证件号码')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 5, '五级')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 6, '贷款余额')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 7, '企业规模')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 8, '业务种类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 9, '本金逾期天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 10, '欠息天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 11, '最终天数')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 12, '天数范围')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 13, '贷款投向行业门类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 14, '贷款投向行业大类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 15, '贷款投向行业中类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 16, '贷款投向行业小类')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 17, '担保方式')
	INSERT INTO TargetTableSheetColumn(SheetId, [Index], Name) VALUES (6, 18, '是否中长期')
END
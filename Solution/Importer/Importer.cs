﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Data.OleDb;
using System.IO;

namespace Reporting
{
	public class Importer
	{
		protected List<string> targetFileNames = new List<string> { "dummy", "Loan.xls", "Public.xls", "Private.xls", "NonAccrual.xls", "Overdue.xls", "YWNei.xls", "YWWai.xls" };
		private Logger logger = Logger.GetLogger("Importer");
		private readonly string OrgCodeYuLin = "806050000";
		private readonly string OrgCodeSF = "806138000";

		#region Create import instance and backup imported files
		public virtual string CreateImport(DateTime asOfDate, string[] sourceFiles) {
			logger.Debug("");
			var result = string.Empty;
			var importId = GetImportId(asOfDate);
			var importFolder = GetImportFolder(importId);

			// Create/update import items records
			logger.DebugFormat("Copying source files to {0}", importFolder);
			result = ImportLoan(importId, importFolder, sourceFiles[(int)XEnum.ImportItemType.Loan]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}
			result = ImportPublic(importId, importFolder, sourceFiles[(int)XEnum.ImportItemType.Public]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}
			result = ImportPrivate(importId, importFolder, sourceFiles[(int)XEnum.ImportItemType.Private]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}
			result = ImportNonAccrual(importId, importFolder, sourceFiles[(int)XEnum.ImportItemType.NonAccrual]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}
			result = ImportOverdue(importId, importFolder, sourceFiles[(int)XEnum.ImportItemType.Overdue]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}
			result = ImportYWNei(importId, importFolder, sourceFiles[(int)XEnum.ImportItemType.YWNei]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}
			result = ImportYWWai(importId, importFolder, sourceFiles[(int)XEnum.ImportItemType.YWWai]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}
			logger.DebugFormat("Source files copy done", importFolder);

			if (IsAllCopied(asOfDate)) {
				logger.Debug("All copied");
				result = CompleteImport(importId, importFolder);
			}

			logger.DebugFormat("Import #{0} done", importId);
			return result;
		}

		protected int GetImportId(DateTime asOfDate) {
			var dao = new SqlDbHelper();
			var dateString = asOfDate.ToString("yyyyMMdd");
			var sql = new StringBuilder();
			sql.AppendLine(string.Format("SELECT ISNULL(MAX(Id), 0) FROM Import WHERE ImportDate = '{0}'", dateString));
			logger.DebugFormat("Getting existing import id for {0}", dateString);
			var importId = (int)dao.ExecuteScalar(sql.ToString());
			logger.DebugFormat("Existing import id = {0}", importId);
			if (importId == 0) {
				sql.Clear();
				sql.AppendLine(string.Format("INSERT INTO Import (ImportDate) VALUES ('{0}')", dateString));
				sql.AppendLine("SELECT SCOPE_IDENTITY()");
				importId = (int)((decimal)dao.ExecuteScalar(sql.ToString()));
			}
			else {
				sql.Clear();
				sql.AppendLine(string.Format("UPDATE Import SET ModifyDate = getdate() WHERE Id = {0}", importId));
				dao.ExecuteNonQuery(sql.ToString());
			}
			return importId;
		}

		protected string GetImportFolder(int importId) {
			var importRootFolder = System.Environment.CurrentDirectory + "\\Import";
			if (!Directory.Exists(importRootFolder)) {
				Directory.CreateDirectory(importRootFolder);
			}
			var importFolder = importRootFolder + "\\" + importId.ToString();
			if (!Directory.Exists(importFolder)) {
				Directory.CreateDirectory(importFolder);
			}

			return importFolder;
		}

		public virtual string UpdateWJFL(DateTime asOfDate, string sourceFilePath) {
			logger.DebugFormat("Updating WJFL for {0}", asOfDate.ToString("yyyy-MM-dd"));
			var result = string.Empty;

			if (!File.Exists(sourceFilePath)) {
				result = "风险贷款情况表的初表修订结果在这个路径下没找到：\r\n" + sourceFilePath;
				logger.Debug(result);
				return result;
			}

			var dao = new SqlDbHelper();
			var dateString = asOfDate.ToString("yyyyMMdd");
			logger.DebugFormat("Getting existing import id for {0}", dateString);

			var import = Import.GetByDate(asOfDate);
			if (import == null || !import.Items.Exists(x => x.ItemType == XEnum.ImportItemType.Loan)) {
				result = string.Format("{0}的《贷款欠款查询》数据还没导入系统，请先导入这项数据。", asOfDate.ToString("yyyy年M月d日"));
				logger.Debug(result);
				return result;
			}

			var importFolder = System.Environment.CurrentDirectory + "\\Import\\" + import.Id.ToString();
			var targetFileName = "WJFL.xls";

			//Original
			var originalFolder = importFolder + @"\Original\";
			if (!Directory.Exists(originalFolder)) {
				Directory.CreateDirectory(originalFolder);
			}
			File.Copy(sourceFilePath, originalFolder + @"\" + targetFileName, true);

			//Processed
			var processedFolder = importFolder + @"\Processed\";
			if (!Directory.Exists(processedFolder)) {
				Directory.CreateDirectory(processedFolder);
			}
			File.Copy(sourceFilePath, processedFolder + @"\" + targetFileName, true);

			var targetFilePath = processedFolder + @"\" + targetFileName;

			result = ExcelHelper.ProcessWJFL(targetFilePath);
			if (!string.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Updating in database");

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + targetFilePath + ";Extended Properties=Excel 8.0");
			try {
				logger.Debug("Opening connection to " + targetFilePath);
				oconn.Open();
				oleOpened = true;
				logger.Debug("Opened");

				logger.Debug("Reading from No Accrual sheet");
				OleDbCommand ocmd = new OleDbCommand("SELECT [行名], [客户名称], [贷款余额], [放款日期], [到期日期], [七级分类] FROM [非应计$]", oconn);
				OleDbDataReader reader = ocmd.ExecuteReader();
				logger.Debug("Executed");
				result = UpdateWJFLSheet(import.Id, reader);
				if (!string.IsNullOrEmpty(result)) {
					return result;
				}

				logger.Debug("Reading from Overdue sheet");
				ocmd = new OleDbCommand("SELECT [行名], [客户名称], [贷款余额], [放款日期], [到期日期], [七级分类] FROM [逾期$]", oconn);
				reader = ocmd.ExecuteReader();
				logger.Debug("Executed");
				result = UpdateWJFLSheet(import.Id, reader);
				if (!string.IsNullOrEmpty(result)) {
					return result;
				}

				logger.Debug("Reading from ZQX sheet");
				ocmd = new OleDbCommand("SELECT [行名], [客户名称], [贷款余额], [放款日期], [到期日期], [七级分类] FROM [只欠息$]", oconn);
				reader = ocmd.ExecuteReader();
				logger.Debug("Executed");
				result = UpdateWJFLSheet(import.Id, reader);
				if (!string.IsNullOrEmpty(result)) {
					return result;
				}

				logger.Debug("Updating WJFLDate field for import #" + import.Id.ToString());
				dao.ExecuteNonQuery("UPDATE Import SET WJFLDate = GETDATE() WHERE Id = " + import.Id.ToString());
				logger.Debug("Updated");
			}
			catch (Exception ex) {
				logger.Error("Outest catch", ex);
				return ex.Message;
			}
			finally {
				if (oleOpened) {
					oconn.Close();
				}
			}
			return result;
		}

		private string UpdateWJFLSheet(int importId, OleDbDataReader reader) {
			var result = string.Empty;
			try {
				int readRows = 0;
				int updatedRows = 0;
				int failedRows = 0;
				var sql = new StringBuilder();
				var sqlSingle = "";
				var firstColumn = "";
				var dao = new SqlDbHelper();
				var failedCustomers = new StringBuilder();

				while (reader.Read()) {
					firstColumn = DataUtility.GetValue(reader, 0);
					if (string.IsNullOrEmpty(firstColumn) || firstColumn.Replace(" ", "").Equals("合计")) { // Going to end
						break;
					}
					readRows++;
					sql.Clear();
					//替换掉下面两行，解决五级分类中营业部与公司部混乱的问题
					//sql.AppendLine("SELECT Id FROM ImportLoan");
					//sql.AppendLine("WHERE OrgId = dbo.sfGetOrgId('{0}')");
					sql.AppendLine("SELECT L.Id FROM ImportLoan L INNER JOIN Org O ON L.OrgId = O.Id");
					sql.AppendLine("WHERE O.OrgNo = (SELECT OrgNo FROM Org WHERE Id = dbo.sfGetOrgId('{0}'))");
					sql.AppendLine("	AND CustomerName = '{1}'");
					sql.AppendLine("	AND CapitalAmount = {2}");
					if (!string.IsNullOrEmpty(DataUtility.GetValue(reader, 3))) {
						sql.AppendLine("	AND LoanStartDate = '{3}'");
					}
					if (!string.IsNullOrEmpty(DataUtility.GetValue(reader, 4))) {
						sql.AppendLine("	AND LoanEndDate = '{4}'");
					}
					sql.AppendLine("	AND ImportId = '{5}'");
					sqlSingle = string.Format(sql.ToString(), DataUtility.GetValue(reader, 0), DataUtility.GetValue(reader, 1), DataUtility.GetValue(reader, 2), DataUtility.GetValue(reader, 3), DataUtility.GetValue(reader, 4), importId);
					var o = dao.ExecuteScalar(sqlSingle);
					if (o == null) {
						failedRows++;
						if (failedRows <= 10) {
							var msg = GetMismatchMessage(importId, DataUtility.GetValue(reader, 0), DataUtility.GetValue(reader, 1), DataUtility.GetValue(reader, 2), DataUtility.GetValue(reader, 3), DataUtility.GetValue(reader, 4));
							failedCustomers.AppendLine(msg + "\r\n" + new string('-', 60));
							logger.WarnFormat("No record matched for {0}-{1}-{2}-{3}-{4}", DataUtility.GetValue(reader, 0), DataUtility.GetValue(reader, 1), DataUtility.GetValue(reader, 2), DataUtility.GetValue(reader, 3), DataUtility.GetValue(reader, 4));
						}
						else {
							failedCustomers.AppendFormat("还有更多……\r\n", DataUtility.GetValue(reader, 1), DataUtility.GetValue(reader, 2), DataUtility.GetValue(reader, 3), DataUtility.GetValue(reader, 4));
							logger.Warn("Stopped because of more un-matched records.");
							break;
						}
					}
					else {
						int loanId = (int)o;
						sqlSingle = string.Format("UPDATE ImportLoan SET DangerLevel = '{0}' WHERE Id = {1} AND ISNULL(DangerLevel, '') != '{0}'", DataUtility.GetValue(reader, 5), loanId);
						try {
							var affected = dao.ExecuteNonQuery(sqlSingle);
							updatedRows += affected;
							if (affected > 0) {
								logger.DebugFormat("#{0} update to '{1}'", loanId, DataUtility.GetValue(reader, 5));
							}
						}
						catch (Exception ex) {
							logger.Error("Running: " + sql.ToString(), ex);
							throw ex;
						}
					}
				}
				logger.DebugFormat("Rows read in toal: {0}", readRows);
				logger.DebugFormat("Rows updated: {0}", updatedRows);
				logger.DebugFormat("Rows not match: {0}", failedRows);
				if (failedRows == 1) {
					result = Consts.MESSAGE_FORM_PREFIX + "下面客户的五级分类无法导入：\r\n" + failedCustomers.ToString() + "\r\n请确保新修改的五级分类Excel文件中，该客户的贷款余额、放款日期和到期日期格式正确。";
				}
				else if (failedRows > 1) {
					result = Consts.MESSAGE_FORM_PREFIX + "下列客户的五级分类无法导入：\r\n" + (new string('-', 80)) + "\r\n" + failedCustomers.ToString() + "\r\n" + (new string('-', 80)) + "\r\n请确保新修改的五级分类Excel文件中，他们的贷款余额、放款日期和到期日期格式正确。";
				}
			}
			catch (Exception ex) {
				logger.Error("Outest catch", ex);
				return ex.Message;
			}
			return result;
		}

		private string GetMismatchMessage(int importId, string orgName, string customerName, string amount, string startDate, string endDate) {
			logger.DebugFormat("Get mismatch message for importId='{0}', orgName='{1}', customerName='{2}', amount='{3}', startDate='{4}', endDate='{5}'", importId, orgName, customerName, amount, startDate, endDate);
			var msg = "";
			var dao = new SqlDbHelper();
			var sql = new StringBuilder();
			sql.AppendLine("SELECT L.Id FROM ImportLoan L INNER JOIN Org O ON L.OrgId = O.Id");
			sql.AppendLine("WHERE ImportId = '" + importId.ToString() + "'");
			sql.AppendLine("	AND CustomerName = '" + customerName + "'");
			if (dao.ExecuteScalar(sql.ToString()) == null) {
				msg = string.Format("《贷款欠款查询》中，不存在客户“{0}”", customerName);
			}
			if (string.IsNullOrEmpty(msg)) {
				sql.AppendLine("	AND O.OrgNo = (SELECT OrgNo FROM Org WHERE Id = dbo.sfGetOrgId('" + orgName + "'))");
				if (dao.ExecuteScalar(sql.ToString()) == null) {
					if (dao.ExecuteScalar("SELECT dbo.sfGetOrgId('" + orgName + "')") == DBNull.Value) {
						msg = string.Format("银行“{0}”不存在，请用规范的银行名称。", orgName);
					}
					else {
						msg = string.Format("《贷款欠款查询》中，客户{0}的银行不是“{1}”，请修改五级分类中该笔贷款的行名。", customerName, orgName);
					}
				}
			}
			if (string.IsNullOrEmpty(msg)) {
				sql.AppendLine("	AND CapitalAmount = " + amount);
				if (dao.ExecuteScalar(sql.ToString()) == null) {
					msg = string.Format("《贷款欠款查询》中，客户{0}在{1}的贷款余额不是{2}。", customerName, orgName, amount);
				}
			}
			if (string.IsNullOrEmpty(msg) && !string.IsNullOrEmpty(startDate)) {
				sql.AppendLine("	AND LoanStartDate = '" + startDate + "'");
				if (dao.ExecuteScalar(sql.ToString()) == null) {
					msg = string.Format("《贷款欠款查询》中，客户{0}在{1}贷款余额为{2}的贷款放款日期不是{3}。", customerName, orgName, amount, startDate);
				}
			}
			if (string.IsNullOrEmpty(msg) && !string.IsNullOrEmpty(endDate)) {
				sql.AppendLine("	AND LoanEndDate = '" + endDate + "'");
				if (dao.ExecuteScalar(sql.ToString()) == null) {
					msg = string.Format("《贷款欠款查询》中，客户{0}在{1}贷款余额为{2}的贷款到期日期不是{3}。", customerName, orgName, amount, endDate);
				}
			}

			if (msg.Length > 0)
			{
				msg = msg + string.Format("\r\n五级分类信息：\r\n\t行名：{0}, 客户名称：{1}, 贷款余额：{2}, 放款日期：{3}, 到期日期：{4}",  orgName, customerName, amount, startDate, endDate);
			}
			return msg;
		}

		protected bool CopyItem(int importId, string importFolder, string sourceFilePath, XEnum.ImportItemType itemType) {
			int itemTypeId = (int)itemType;

			if (sourceFilePath.Length == 0 || !File.Exists(sourceFilePath)) {
				return false;
			}

			string targetFileName = this.targetFileNames[itemTypeId];
			if (itemType == XEnum.ImportItemType.YWNei || itemType == XEnum.ImportItemType.YWWai || itemType == XEnum.ImportItemType.Loan) {
				var orgId = GetOrgId4YW(sourceFilePath);
				targetFileName = GetYWTargetFileName(itemType, orgId);
			}

			//Original
			var originalFolder = importFolder + @"\Original\";
			if (!Directory.Exists(originalFolder)) {
				Directory.CreateDirectory(originalFolder);
			}
			File.Copy(sourceFilePath, originalFolder + @"\" + targetFileName, true);

			//Processed
			var processedFolder = importFolder + @"\Processed\";
			if (!Directory.Exists(processedFolder)) {
				Directory.CreateDirectory(processedFolder);
			}
			File.Copy(sourceFilePath, processedFolder + @"\" + targetFileName, true);

			logger.Debug("Process copied item for " + itemType.ToString());
			ExcelHelper.ProcessCopiedItem(processedFolder + @"\" + targetFileName, itemType);

			logger.Debug("Updating ImportItem table");
			var dao = new SqlDbHelper();
			var sql = new StringBuilder();
			sql.AppendFormat("SELECT ISNULL(MAX(Id), 0) FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}", importId, itemTypeId);
			var importItemId = (int)dao.ExecuteScalar(sql.ToString());
			if (importItemId == 0) {
				sql.Clear();
				sql.AppendLine(string.Format("INSERT INTO ImportItem (ImportId, ItemType, FilePath) VALUES ({0}, {1}, '{2}')", importId, itemTypeId, sourceFilePath));
				sql.AppendLine("SELECT SCOPE_IDENTITY()");
				importItemId = (int)((decimal)dao.ExecuteScalar(sql.ToString()));
				logger.Debug("New record created. ImportItemId = " + importItemId.ToString());
			}
			else {
				sql.Clear();
				sql.AppendFormat("UPDATE ImportItem SET FilePath = '{0}', ModifyDate = getdate() WHERE Id = {1}", sourceFilePath, importItemId);
				dao.ExecuteNonQuery(sql.ToString());
				logger.Debug("Existing record updated. ImportItemId = " + importItemId.ToString());
			}
			return true;
		}
		#endregion

		#region Import excel data to database
		private string ImportLoan(int importId, string importFolder, string sourceFilePath) {
			logger.Debug("Importing Loan data");
			var result = "";
			var imported = false;
			var filePathes = sourceFilePath.Split('|');
			for (int i = 0; i < filePathes.Length; i++) {
				var filePath = filePathes[i];
				if (string.IsNullOrEmpty(filePath)) {
					logger.Debug("Source file not provided");
					continue;
				}
				var orgId = GetOrgId4YW(filePath);
				// Do this check before any action
				if (orgId == 0) {
					var msg = "不能确定贷款欠款查询的所属银行：" + filePath;
					logger.Error(msg);
					return msg;
				}

				var done = CopyItem(importId, importFolder, filePath, XEnum.ImportItemType.Loan);
				if (!done) {
					logger.Debug("Source file not provided");
					return ""; // Do nothing if user hasn't select a file for this table
				}

				// Import to database
				string targetFilePath = importFolder + "\\Processed\\" + GetYWTargetFileName(XEnum.ImportItemType.Loan, orgId);
				var excelColumns = "[机构号码], [贷款科目], [贷款帐号], [客户名称], [客户编号], [客户类型], [币种], [贷款总额], [本金余额], [拖欠本金], [拖欠应收利息], [拖欠催收利息], [借据编号], [放款日期], [到期日期], [置换/转让], [核销标志], [贷款状态], [贷款种类], [贷款种类说明], [贷款用途], [转列逾期], [转列非应计日期], [利息计至日], [利率种类], [利率加减符号], [利率加减码], [逾期利率依据方式], [逾期利率种类], [逾期利率加减符号], [逾期利率加减码], [利率依据方式], [合同最初计息利率], [合同最初逾期利率], [扣款账号]";
				var dbColumns = "OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, CurrencyType, LoanAmount, CapitalAmount, OweCapital, OweYingShouInterest, OweCuiShouInterest, DueBillNo, LoanStartDate, LoanEndDate, ZhiHuanZhuanRang, HeXiaoFlag, LoanState, LoanType, LoanTypeName, Direction, ZhuanLieYuQi, ZhuanLieFYJ, InterestEndDate, LiLvType, LiLvSymbol, LiLvJiaJianMa, YuQiLiLvYiJu, YuQiLiLvType, YuQiLiLvSymbol, YuQiLiLvJiaJianMa, LiLvYiJu, ContractInterestRatio, ContractOverdueInterestRate, ChargeAccount";
				result = ImportTable(importId, targetFilePath, XEnum.ImportItemType.Loan, excelColumns, dbColumns, 1, i + 1);
				if (string.IsNullOrEmpty(result)) {
					imported = true;
				}
				else {
					return result;
				}
			}
			if (imported) {
				result = AssignOrgId(importId, XEnum.ImportItemType.Loan);
			}
			return result;
		}

		private string ImportPublic(int importId, string importFolder, string sourceFilePath) {
			logger.Debug("Importing Public data");
			var done = CopyItem(importId, importFolder, sourceFilePath, XEnum.ImportItemType.Public);
			if (!done) {
				logger.Debug("Source file not provided");
				return ""; // Do nothing if user hasn't select a file for this table
			}

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.Public];
			var excelColumns = "[分行名称], [支行名称], [客户姓名], [借款人企业性质], [组织机构代码], [合同编号], [借据编号], [借据开始日期], [借据结束日期], [行业门类], [行业大类], [行业中类], [行业小类], [贷款期限(月)], [币种], [发放后投向行业门类], [发放后投向行业大类], [发放后投向行业中类], [发放后投向行业小类], [业务类别], [授信品种], [核算项目名称], [七级分类], [客户信用等级], [客户规模(行内）], [客户规模(行外）], [本金逾期天数], [欠息天数], [贷款余额], [利率], [浮动利率], [主要担保方式], [保证金比例], [正常余额], [逾期余额], [非应计余额], [贷款账号], [是否涉农], [是否政府融资平台]";
			var dbColumns = "OrgName, OrgName2, CustomerName, OrgType, OrgCode, ContractNo, DueBillNo, LoanStartDate, LoanEndDate, IndustryType1, IndustryType2, IndustryType3, IndustryType4, TermMonth, CurrencyType, Direction1, Direction2, Direction3, Direction4, OccurType, BusinessType, SubjectNo, ClassifyResult, CreditLevel, MyBankIndTypeName, ScopeName, OverdueDays, OweInterestDays, Balance1, ActualBusinessRate, RateFloat, VouchTypeName, BailRatio, NormalBalance, OverdueBalance, BadBalance, LoanAccount, IsAgricultureCredit, IsINRZ";
			var result = "";
			var table = SourceTable.GetById(XEnum.ImportItemType.Public);
			for (int sheetIndex = 1; sheetIndex <= table.Sheets.Count; sheetIndex++) {
				result = ImportTable(importId, targetFilePath, XEnum.ImportItemType.Public, excelColumns, dbColumns, "PublicType", sheetIndex, sheetIndex);
				if (!String.IsNullOrEmpty(result)) {
					return result;
				}
			}
			if (string.IsNullOrEmpty(result)) {
				result = AssignOrgId(importId, XEnum.ImportItemType.Public);
			}
			return result;
		}

		private string ImportPrivate(int importId, string importFolder, string sourceFilePath) {
			logger.Debug("Importing Private data");
			var done = CopyItem(importId, importFolder, sourceFilePath, XEnum.ImportItemType.Private);
			if (!done) {
				logger.Debug("Source file not provided");
				return ""; // Do nothing if user hasn't select a file for this table
			}

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.Private];
			var excelColumns = "[二级分行], [支行], [信贷产品名称], [产品核算项目], [贷款期限（月）], [综合授信额度], [七级分类], [还款方式], [客户名称], [证件号码], [币种], [合同开始日期], [合同到期日], [借款利率（执行）], [担保方式], [贷款余额], [贷款发放后投向1], [贷款发放后投向2], [贷款发放后投向3], [贷款发放后投向4], [本金最长逾期天数], [利息最长逾期天数], [拖欠利息], [逾期余额], [非应计余额]";
			var dbColumns = "OrgName, OrgName2, ProductName, ProductType, LoanMonths, ZongHeShouXinEDu, DangerLevel, RepaymentMethod, CustomerName, IdCardNo, CurrencyType, ContractStartDate, ContractEndDate, InterestRatio, DanBaoFangShi, LoanBalance, Direction1, Direction2, Direction3, Direction4, CapitalOverdueDays, InterestOverdueDays, OweInterestAmount, OverdueBalance, NonAccrualBalance";
			var result = ImportTable(importId, targetFilePath, XEnum.ImportItemType.Private, excelColumns, dbColumns);
			if (string.IsNullOrEmpty(result)) {
				result = AssignOrgId(importId, XEnum.ImportItemType.Private);
			}
			return result;
		}

		private string ImportNonAccrual(int importId, string importFolder, string sourceFilePath) {
			logger.Debug("Importing NonAccrual data");
			var done = CopyItem(importId, importFolder, sourceFilePath, XEnum.ImportItemType.NonAccrual);
			if (!done) {
				logger.Debug("Source file not provided");
				return ""; // Do nothing if user hasn't select a file for this table
			}

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.NonAccrual];
			var excelColumns = "[机构名称], [客户名称], [贷款帐号], [担保情况]";
			var dbColumns = "OrgName, CustomerName, LoanAccount, DanBaoFangShi";
			return ImportTable(importId, targetFilePath, XEnum.ImportItemType.NonAccrual, excelColumns, dbColumns);
		}

		private string ImportOverdue(int importId, string importFolder, string sourceFilePath) {
			logger.Debug("Importing Overdue data");
			var done = CopyItem(importId, importFolder, sourceFilePath, XEnum.ImportItemType.Overdue);
			if (!done) {
				logger.Debug("Source file not provided");
				return ""; // Do nothing if user hasn't select a file for this table
			}

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.Overdue];
			var excelColumns = "[机构名称], [客户名称], [贷款帐号], [客户编号], [贷款种类], [贷款发放日], [贷款到期日], [逾期本金余额], [利息余额], [担保情况]";
			var dbColumns = "OrgName, CustomerName, LoanAccount, CustomerNo, LoanType, LoanStartDate, LoanEndDate, CapitalOverdueBalance, InterestBalance, DanBaoFangShi";
			return ImportTable(importId, targetFilePath, XEnum.ImportItemType.Overdue, excelColumns, dbColumns);
		}

		private string ImportYWNei(int importId, string importFolder, string sourceFilePath) {
			return ImportYW(XEnum.ImportItemType.YWNei, importId, importFolder, sourceFilePath);
		}

		private string ImportYWWai(int importId, string importFolder, string sourceFilePath) {
			return ImportYW(XEnum.ImportItemType.YWWai, importId, importFolder, sourceFilePath);
		}

		private string ImportYW(XEnum.ImportItemType itemType, int importId, string importFolder, string sourceFilePath) {
			logger.DebugFormat("Importing {0} data", itemType.ToString());
			var result = "";
			var filePathes = sourceFilePath.Split('|');
			for (int i = 0; i < filePathes.Length; i++) {
				var filePath = filePathes[i];
				if (string.IsNullOrEmpty(filePath)) {
					logger.Debug("Source file not provided");
					continue;
				}
				var orgId = GetOrgId4YW(filePath);
				// Do this check before any action
				if (orgId == 0) {
					var msg = "不能确定业务状况表数据的所属银行：" + filePath;
					logger.Error(msg);
					return msg;
				}

				var done = CopyItem(importId, importFolder, filePath, itemType);
				if (!done) {
					logger.Debug("Source file not provided");
					return ""; // Do nothing if user hasn't select a file for this table
				}

				// Import to database
				string targetFilePath = importFolder + "\\Processed\\" + GetYWTargetFileName(itemType, orgId);
				var excelColumns = "*";
				var dbColumns = "SubjectCode, SubjectName, LastDebitBalance, LastCreditBalance, CurrentDebitChange, CurrentCreditChange, CurrentDebitBalance, CurrentCreditBalance";
				result = ImportTable(importId, targetFilePath, itemType, excelColumns, dbColumns, "OrgId", orgId, 1, i + 1);
				if (!string.IsNullOrEmpty(result)) {
					return result;
				}
			}
			return result;
		}

		private string GetYWTargetFileName(XEnum.ImportItemType itemType, int orgId) {
			string fileName = targetFileNames[(int)itemType];
			var dotIndex = fileName.LastIndexOf('.');
			fileName = string.Format("{0}_{1}{2}", fileName.Substring(0, dotIndex), orgId, fileName.Substring(dotIndex));
			return fileName;
		}

		protected string ImportTable(int importId, string filePath, XEnum.ImportItemType itemType, string excelColumns, string dbColumns, int sheetIndex = 1, int roundIndex = 1) {
			return ImportTable(importId, filePath, itemType, excelColumns, dbColumns, null, null, sheetIndex, roundIndex);
		}

		protected string ImportTable(int importId, string filePath, XEnum.ImportItemType itemType, string excelColumns, string dbColumns, string dbColumns2, object dbValues2, int sheetIndex = 1, int roundIndex = 1) {
			int columnCount = dbColumns.Split(',').Length;
			string suffix = GetTableSuffix(itemType);
			logger.DebugFormat("Importing {0} to database", suffix);
			if (String.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath)) {
				return string.Format("File {0} cannot be found", filePath ?? "<empty>");
			}
			logger.Debug("Getting source table");
			var sourceTable = SourceTable.GetById(itemType);
			var sheetEntry = sourceTable.Sheets[sheetIndex - 1];
			var dataRowEnding = sheetEntry.DataRowEndingFlag;
			logger.DebugFormat("Ending is {0}", dataRowEnding == "" ? "empty string" : dataRowEnding);

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			try {
				logger.Debug("Opening connection to " + filePath);
				oconn.Open();
				oleOpened = true;
				logger.Debug("Opened");

				DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
				string sheet1 = dt.Rows[(sheetIndex - 1) * 2][2].ToString();
				if (!IsSheetMatched(sheet1, sheetEntry.Name)) {
					logger.WarnFormat("Sheet \"{0}\" is not found at index {1}. This may be caused by extra sheets added. Searching in all sheets...", sheetEntry.Name, sheetIndex);
					for (int i = 0; i < dt.Rows.Count; i++) {
						sheet1 = dt.Rows[i][2].ToString();
						if (IsSheetMatched(sheet1, sheetEntry.Name)) {
							logger.WarnFormat("Got sheet \"{0}\"", sheet1.Substring(0, sheet1.Length - 1));
							break;
						}
					}
				}
				if (!IsSheetMatched(sheet1, sheetEntry.Name)) {
					var msg = string.Format("没有找到工作表\"{0}\"", sheetEntry.Name);
					logger.Error(msg);
					return msg;
				}

				logger.Debug("Importing sheet " + sheet1.Substring(0, sheet1.Length - 1));

				var sql = new StringBuilder();
				sql.AppendFormat("SELECT {0} FROM [{1}]", excelColumns, sheet1);
				sql.AppendLine(GetImportWhereSql(itemType));
				var s = sql.ToString();
				OleDbCommand ocmd = new OleDbCommand(s, oconn);
				OleDbDataReader reader = ocmd.ExecuteReader();

				int dataRowIndex = 0;
				var dao = new SqlDbHelper();
				if (sheetIndex == 1 && roundIndex == 1) { // Delete existing records only when importing the first sheet
					dao.ExecuteNonQuery(string.Format("DELETE FROM Import{0} WHERE ImportId = {1}", suffix, importId));
				}

				sql.Clear();
				while (reader.Read()) {
					if (DataUtility.GetValue(reader, 0).Equals(dataRowEnding)) { // Going to end
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql(reader, importId, suffix, columnCount, dbColumns, dbColumns2, dbValues2));
					// Top 1 trial for exception track
					if (dataRowIndex == 1) {
						try {
							dao.ExecuteNonQuery(sql.ToString());
							sql.Clear();
						}
						catch (Exception ex) {
							logger.Error("Running INSERT: " + sql.ToString(), ex);
							throw ex;
						}
					}
					// Batch inserts
					if (dataRowIndex > 1 && dataRowIndex % 1000 == 0) {
						dao.ExecuteNonQuery(sql.ToString());
						sql.Clear();
					}
				}
				if (sql.Length > 0) {
					try {
						dao.ExecuteNonQuery(sql.ToString());
						sql.Clear();
					}
					catch (Exception ex) {
						logger.Error("Running INSERT: " + sql.ToString(), ex);
						throw ex;
					}
				}
				logger.DebugFormat("{0} records imported.", dataRowIndex);

				if (itemType == XEnum.ImportItemType.Loan) {
					// Cleanup zero-records since the oledb query cannot filter them out
					var query = string.Format("DELETE FROM ImportLoan WHERE ImportId = {0} AND ISNULL(CapitalAmount + OweCapital + OweYingShouInterest + OweCuiShouInterest, 0) = 0", importId);
					var cleaned = dao.ExecuteNonQuery(query);
					logger.DebugFormat("{0} records have been cleaned because of 4-zeros.", cleaned);
				}
			}
			catch (Exception ex) {
				logger.Error("Outest catch: ", ex);
				throw ex;
			}
			finally {
				if (oleOpened) {
					oconn.Close();
				}
			}
			return string.Empty;
		}

		private bool IsSheetMatched(string actual, string expected) {
			if (string.IsNullOrEmpty(actual) || string.IsNullOrEmpty(expected)) {
				return false;
			}
			if (expected.Equals("UNKNOWN")) {
				return true;
			}
			bool matched = false;
			int i = 0;
			int maxRetrial = 20;
			while (!matched && ++i < maxRetrial) {
				matched = (actual.EndsWith("$") || actual.EndsWith("$'")) && actual.IndexOf(expected) >= 0;
				if (!matched) {
					if (actual.IndexOf('(') > 0) {
						actual = actual.Replace("(", "（");
					}
					if (actual.IndexOf(')') > 0) {
						actual = actual.Replace(")", "）");
					}
				}
			}
			
			return matched;
		}

		private string GetTableSuffix(XEnum.ImportItemType itemType) {
			var suffix = itemType.ToString();
			var startAt = suffix.LastIndexOf('.');
			suffix = suffix.Substring(startAt + 1);
			return suffix;
		}

		protected virtual string GetImportWhereSql(XEnum.ImportItemType itemType) {
			var sql = "";
			if (itemType == XEnum.ImportItemType.Loan) {
				sql = "WHERE [贷款状态] <> '结清'";
			}
			else if (itemType == XEnum.ImportItemType.Public) {
				sql = "WHERE [分行名称] LIKE '%长安银行榆林分行%'";
			}
			else if (itemType == XEnum.ImportItemType.Private) {
				sql = "WHERE [二级分行] LIKE '%长安银行榆林分行%'";
			}
			else if (itemType == XEnum.ImportItemType.YWNei || itemType == XEnum.ImportItemType.YWWai) {
				sql = "WHERE LEN([科目代号]) > 2";
			}
			return sql;
		}

		private string GetInsertSql(OleDbDataReader reader, int importId, string suffix, int columnCount, string columns) {
			return GetInsertSql(reader, importId, suffix, columnCount, columns, null, null);
		}

		private string GetInsertSql(OleDbDataReader reader, int importId, string suffix, int columnCount, string columns, string columns2, object values2) {
			var values = new StringBuilder();
			values.Append(DataUtility.GetSqlValue(reader, 0));
			for (int i = 1; i < columnCount; i++) {
				values.Append(", " + DataUtility.GetSqlValue(reader, i));
			}
			string values2s = values2 == null ? "" : values2.ToString();
			var sql = "";
			if (string.IsNullOrEmpty(columns2) || string.IsNullOrEmpty(values2s.ToString())) {
				sql = string.Format("INSERT INTO Import{0} (ImportId, {2}) VALUES ({1}, {3})", suffix, importId, columns, values);
			}
			else {
				sql = string.Format("INSERT INTO Import{0} (ImportId, {2}, {4}) VALUES ({1}, {3}, {5})", suffix, importId, columns, values, columns2, values2s);
			}
			return sql;
		}

		protected virtual bool IsAllCopied(DateTime asOfDate) {
			var dao = new SqlDbHelper();
			var importedItems = (string)dao.ExecuteScalar(string.Format("SELECT dbo.sfGetImportStatus('{0}')", asOfDate.ToString("yyyyMMdd")));
			return importedItems.StartsWith("1111111");
		}

		public string CompleteImport(int importId, string importFolder) {
			var result = AssignLoanAccount(importId);
			if (!String.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			result = UpdateOrgId(importId);
			if (!String.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			result = AssignDangerLevel(importId);
			if (!String.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			logger.Debug("Import to database done");

			return string.Empty;
		}

		private string AssignOrgId(int importId, XEnum.ImportItemType itemType) {
			if (!(itemType == XEnum.ImportItemType.Loan || itemType == XEnum.ImportItemType.Public || itemType == XEnum.ImportItemType.Private)) {
				return "Invalid import item: " + itemType.ToString();
			}
			try {
				var dao = new SqlDbHelper();
				var sql = new StringBuilder();
				int count = 0;
				var suffix = GetTableSuffix(itemType);

				logger.Debug("Assigning OrgId column to " + suffix);
				sql.AppendLine("UPDATE Import" + suffix);
				if (itemType == XEnum.ImportItemType.Loan) {
					sql.AppendLine("SET OrgId = dbo.sfGetOrgId(OrgNo)");
				}
				else {
					sql.AppendLine("SET OrgId = dbo.sfGetOrgId(OrgName2)");
				}
				sql.AppendLine("WHERE ImportId = {0} AND OrgId IS NULL");
				count = dao.ExecuteNonQuery(string.Format(sql.ToString(), importId));
				logger.DebugFormat("Done ({0} affected)", count);

				if (itemType == XEnum.ImportItemType.Loan) {
					logger.Debug("Assigning OrgId4Report column to " + suffix);
					sql.Clear();
					sql.AppendLine("UPDATE ImportLoan");
					sql.AppendLine("SET OrgId4Report = CASE WHEN OrgId IN (1, 2) THEN (CASE WHEN LEN(CustomerName) >= 5 THEN 1 ELSE 2 END)  ELSE OrgId END");
					sql.AppendLine("WHERE ImportId = {0} AND OrgId4Report IS NULL");
					count = dao.ExecuteNonQuery(string.Format(sql.ToString(), importId));
					logger.DebugFormat("Done ({0} affected)", count);
				}
			}
			catch (Exception ex) {
				return ex.Message;
			}
			return string.Empty;
		}

		// Run this function after OrgId is assigned
		private string AssignLoanAccount(int importId) {
			try {
				logger.Debug("Assigning LoanAccount column to Private");
				var sql = new StringBuilder();
				sql.AppendLine("UPDATE P SET LoanAccount = L.LoanAccount");
				sql.AppendLine("FROM ImportPrivate P");
				sql.AppendLine("	INNER JOIN ImportLoan L ON P.ImportId = L.ImportId");
				sql.AppendLine("		AND P.CustomerName = L.CustomerName");
				sql.AppendLine("		AND ABS(P.LoanBalance*10000 - L.CapitalAmount) < 1.0");
				sql.AppendLine("		AND P.ContractStartDate = L.LoanStartDate AND P.ContractEndDate = L.LoanEndDate");
				sql.AppendLine("WHERE P.ImportId = {0} AND P.LoanAccount IS NULL");
				var dao = new SqlDbHelper();
				var count = dao.ExecuteNonQuery(string.Format(sql.ToString(), importId));
				logger.DebugFormat("Done ({0} affected)", count);
			}
			catch (Exception ex) {
				return ex.Message;
			}
			return string.Empty;
		}

		// Update the OrgId in Loan to distinguish 公司部 or 营业部
		// Run this section after OrgId assigned to ImportPublic and ImportPrivate
		// And after LoanAccount assigned to ImportPrivate
		private string UpdateOrgId(int importId) {
			try {
				var dao = new SqlDbHelper();
				var sql = new StringBuilder();
				int count = 0;

				logger.Debug("Update OrgId column in Loan");
				sql.Clear();
				sql.AppendLine("UPDATE L");
				sql.AppendLine("SET OrgId = ISNULL(P.OrgId, R.OrgId)");
				sql.AppendLine("FROM ImportLoan L");
				sql.AppendLine("	LEFT JOIN ImportPublic P ON L.LoanAccount = P.LoanAccount AND P.ImportId = L.ImportId");
				sql.AppendLine("	LEFT JOIN ImportPrivate R ON L.LoanAccount = R.LoanAccount AND R.ImportId = L.ImportId");
				sql.AppendLine("WHERE L.ImportId = {0}");
				sql.AppendLine("	AND L.OrgId = 1");
				sql.AppendLine("	AND (P.OrgId = 2 OR R.OrgId = 2)");
				count = dao.ExecuteNonQuery(string.Format(sql.ToString(), importId));
				logger.DebugFormat("Done to update org id from Public & Private. ({0} affected)", count);
			}
			catch (Exception ex) {
				return ex.Message;
			}
			return string.Empty;
		}

		private string AssignDangerLevel(int importId) {
			logger.Debug("Assigning Danger Level to Loan");
			try {
				var dao = new SqlDbHelper();
				var sql = new StringBuilder();
				sql.AppendLine("UPDATE ImportLoan SET DangerLevel = dbo.sfGetDangerLevel({0}, LoanAccount)");
				sql.AppendLine("WHERE ImportId = {0} AND DangerLevel IS NULL");
				dao.ExecuteNonQuery(string.Format(sql.ToString(), importId));
			}
			catch (Exception ex) {
				return ex.Message; ;
			}
			return string.Empty;
		}
		#endregion

		#region Misc Functions
		private int GetOrgId4YW(string fileName) {
			var orgNo = GetOrgNo4YW(fileName);
			if (orgNo.Equals(OrgCodeYuLin)) {
				return (int)XEnum.OrgId.YuLin; // 榆林地区总额 (不含神府)
			}
			else if (orgNo.Equals(OrgCodeSF)) {
				return (int)XEnum.OrgId.ShenFu;
			}
			var dao = new SqlDbHelper();
			var orgId = dao.ExecuteScalar(string.Format("SELECT TOP 1 Id FROM Org WHERE OrgNo = '{0}'", orgNo));
			return orgId == null ? 0 : (int)orgId;
		}

		// Guess org code from file name, like 业务状况表一级科目（表内）-月报_806050000_01_20150930.xls
		private string GetOrgNo4YW(string fileName) {
			int lastSlash = fileName.LastIndexOf('\\');
			if (lastSlash >= 0) {
				if (lastSlash + 1 == fileName.Length) { // Slash is the last character
					return "";
				}
				fileName = fileName.Substring(lastSlash + 1);
			}
			fileName = fileName.Substring(0, fileName.LastIndexOf('.'));
			if (fileName.IndexOf('_') <= 0) {
				return "";
			}

			var orgNo = fileName.Split('_').SingleOrDefault(x => x.StartsWith("806")) ?? "";
			if (orgNo.Equals(OrgCodeYuLin) || orgNo.Equals(OrgCodeSF)) {
				return orgNo;
			}
			else if (orgNo.Equals("806058000")) {
				return "806050001";
			}
			else if (orgNo.EndsWith("00")) {
				return orgNo.Substring(0, orgNo.Length - 1) + "1";
			}
			else {
				return orgNo;
			}
		}
		#endregion
	}
}

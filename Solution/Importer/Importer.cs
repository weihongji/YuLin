using System;
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
		private string[] targetFileNames = { "dummy", "Loan.xls", "Public.xls", "Private.xls", "NonAccrual.xls", "Overdue.xls", "YWNei.xls", "YWWai.xls" };
		private Logger logger = Logger.GetLogger("ExcelImporter");

		#region Create import instance and backup imported files
		public string CreateImport(DateTime asOfDate, string[] sourceFiles) {
			logger.Debug("");
			var result = string.Empty;
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

			var importRootFolder = System.Environment.CurrentDirectory + "\\Import";
			if (!Directory.Exists(importRootFolder)) {
				Directory.CreateDirectory(importRootFolder);
			}
			var importFolder = importRootFolder + "\\" + importId.ToString();
			if (!Directory.Exists(importFolder)) {
				Directory.CreateDirectory(importFolder);
			}

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

			if (IsAllCopied(importId)) {
				logger.Debug("All copied");
				ChangeImportState(importId, XEnum.ImportState.Imported);

				result = CompleteImport(importId, importFolder);
			}

			logger.DebugFormat("Import #{0} done", importId);
			return result;
		}

		public string UpdateWJFL(DateTime asOfDate, string sourceFilePath) {
			var result = string.Empty;
			var dao = new SqlDbHelper();
			var dateString = asOfDate.ToString("yyyyMMdd");
			logger.DebugFormat("Getting existing import id for {0}", dateString);

			var import = Import.GetByDate(asOfDate);
			if (import == null) {
				result = string.Format("{0}的数据还没导入系统", asOfDate.ToString("yyyy年M月d日"));
				logger.Debug(result);
				return result;
			}

			var importFolder = System.Environment.CurrentDirectory + "\\Import\\" + import.Id.ToString();
			var targetFilePath = string.Format("{0}\\Processed\\WJFL.xls", importFolder);
			if (!File.Exists(sourceFilePath)) {
				result = "风险贷款情况表的初表修订结果在这个路径下没找到：\r\n" + sourceFilePath;
				logger.Debug(result);
				return result;
			}

			logger.DebugFormat("Copying WJFL update file into {0}", targetFilePath);
			File.Copy(sourceFilePath, targetFilePath, true);
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

				logger.Debug("Updating WJFLSubmitDate field for import #" + import.Id.ToString());
				dao.ExecuteNonQuery("UPDATE Import SET WJFLSubmitDate = GETDATE() WHERE Id = " + import.Id.ToString());
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
					sql.AppendLine("SELECT Id FROM ImportLoan");
					sql.AppendLine("WHERE OrgNo = dbo.sfGetOrgNo('{0}')");
					sql.AppendLine("	AND CustomerName = '{1}'");
					sql.AppendLine("	AND CapitalAmount = {2}");
					if (!string.IsNullOrEmpty(DataUtility.GetValue(reader, 0))) {
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
							failedCustomers.AppendFormat("{0} （贷款余额：{1}, 放款日期：{2}, 到期日期：{3}）\r\n", DataUtility.GetValue(reader, 1), DataUtility.GetValue(reader, 2), DataUtility.GetValue(reader, 3), DataUtility.GetValue(reader, 4));
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
					result = "下面客户的五级分类无法导入：\r\n" + failedCustomers.ToString() + "\r\n请确保新修改的五级分类Excel文件中，该客户的贷款余额、放款日期和到期日期格式正确。";
				}
				else if (failedRows > 1) {
					result = "下列客户的五级分类无法导入：\r\n" + (new string('-', 20)) + "\r\n" + failedCustomers.ToString() + "\r\n" + (new string('-', 20)) + "\r\n请确保新修改的五级分类Excel文件中，他们的贷款余额、放款日期和到期日期格式正确。";
				}
			}
			catch (Exception ex) {
				logger.Error("Outest catch", ex);
				return ex.Message;
			}
			return result;
		}

		private bool CopyItem(int importId, string importFolder, string sourceFilePath, XEnum.ImportItemType itemType) {
			int itemTypeId = (int)itemType;

			if (sourceFilePath.Length == 0 || !File.Exists(sourceFilePath)) {
				return false;
			}

			//Original
			var originalFolder = importFolder + @"\Original\";
			if (!Directory.Exists(originalFolder)) {
				Directory.CreateDirectory(originalFolder);
			}
			string targetFileName = this.targetFileNames[itemTypeId];
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

		#region "Import excel data to database"
		private string ImportLoan(int importId, string importFolder, string sourceFilePath) {
			logger.Debug("Importing Loan data");
			var done = CopyItem(importId, importFolder, sourceFilePath, XEnum.ImportItemType.Loan);
			if (!done) {
				logger.Debug("Source file not provided");
				return ""; // Do nothing if user hasn't select a file for this table
			}

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.Loan];
			var excelColumns = "[机构号码], [贷款科目], [贷款帐号], [客户名称], [客户编号], [客户类型], [币种], [贷款总额], [本金余额], [拖欠本金], [拖欠应收利息], [拖欠催收利息], [借据编号], [放款日期], [到期日期], [置换/转让], [核销标志], [贷款状态], [贷款种类], [贷款种类说明], [贷款用途], [转列逾期], [转列非应计日期], [利息计至日], [利率种类], [利率加减符号], [利率加减码], [逾期利率依据方式], [逾期利率种类], [逾期利率加减符号], [逾期利率加减码], [利率依据方式], [合同最初计息利率], [合同最初逾期利率], [扣款账号]";
			var dbColumns = "OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, CurrencyType, LoanAmount, CapitalAmount, OweCapital, OweYingShouInterest, OweCuiShouInterest, DueBillNo, LoanStartDate, LoanEndDate, ZhiHuanZhuanRang, HeXiaoFlag, LoanState, LoanType, LoanTypeName, Direction, ZhuanLieYuQi, ZhuanLieFYJ, InterestEndDate, LiLvType, LiLvSymbol, LiLvJiaJianMa, YuQiLiLvYiJu, YuQiLiLvType, YuQiLiLvSymbol, YuQiLiLvJiaJianMa, LiLvYiJu, ContractInterestRatio, ContractOverdueInterestRate, ChargeAccount";
			return ImportTable(importId, targetFilePath, XEnum.ImportItemType.Loan, excelColumns, dbColumns);
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
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + targetFilePath + ";Extended Properties=Excel 8.0");
			oconn.Open();
			DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
			int maxSheets = 3;
			for (int sheetIndex = 0; sheetIndex < maxSheets; sheetIndex++) {
				if (dt.Rows.Count < sheetIndex * 2 + 1) {
					break;
				}
				var result = ImportTable(importId, targetFilePath, XEnum.ImportItemType.Public, excelColumns, dbColumns, sheetIndex + 1);
				if (!String.IsNullOrEmpty(result)) {
					return result;
				}
			}
			return string.Empty;
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
			return ImportTable(importId, targetFilePath, XEnum.ImportItemType.Private, excelColumns, dbColumns);
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
			logger.Debug("Importing YWNei data");
			var done = CopyItem(importId, importFolder, sourceFilePath, XEnum.ImportItemType.YWNei);
			if (!done) {
				logger.Debug("Source file not provided");
				return ""; // Do nothing if user hasn't select a file for this table
			}

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.YWNei];
			var excelColumns = "*";
			var dbColumns = "SubjectCode, SubjectName, LastDebitBalance, LastCreditBalance, CurrentDebitChange, CurrentCreditChange, CurrentDebitBalance, CurrentCreditBalance";
			return ImportTable(importId, targetFilePath, XEnum.ImportItemType.YWNei, excelColumns, dbColumns);
		}

		private string ImportYWWai(int importId, string importFolder, string sourceFilePath) {
			logger.Debug("Importing YWWai data");
			var done = CopyItem(importId, importFolder, sourceFilePath, XEnum.ImportItemType.YWWai);
			if (!done) {
				logger.Debug("Source file not provided");
				return ""; // Do nothing if user hasn't select a file for this table
			}

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.YWWai];
			var excelColumns = "*";
			var dbColumns = "SubjectCode, SubjectName, LastDebitBalance, LastCreditBalance, CurrentDebitChange, CurrentCreditChange, CurrentDebitBalance, CurrentCreditBalance";
			return ImportTable(importId, targetFilePath, XEnum.ImportItemType.YWWai, excelColumns, dbColumns);
		}

		private string ImportTable(int importId, string filePath, XEnum.ImportItemType itemType, string excelColumns, string dbColumns, int sheetIndex = 1) {
			int columnCount = dbColumns.Split(',').Length;
			string suffix = GetTableSuffix(itemType);
			logger.DebugFormat("Importing {0} to database", suffix);
			if (String.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath)) {
				return string.Format("File {0} cannot be found", filePath ?? "<empty>");
			}
			logger.Debug("Getting source table");
			var sourceTable = SourceTable.GetById(itemType);
			var dataRowEnding = sourceTable.Sheets[sheetIndex - 1].DataRowEndingFlag;
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
				logger.Debug("Importing sheet " + sheet1.Substring(0, sheet1.Length - 1));

				var sql = new StringBuilder();
				sql.AppendFormat("SELECT {0} FROM [{1}]", excelColumns, sheet1);
				if (itemType == XEnum.ImportItemType.Loan) {
					sql.Append(" WHERE [贷款状态] <> '结清'");
				}
				else if (itemType == XEnum.ImportItemType.Public) {
					sql.Append(" WHERE [分行名称] = '长安银行榆林分行'");
				}
				else if (itemType == XEnum.ImportItemType.Private) {
					sql.Append(" WHERE [二级分行] = '长安银行榆林分行'");
				}
				else if (itemType == XEnum.ImportItemType.YWNei || itemType == XEnum.ImportItemType.YWWai) {
					sql.Append(" WHERE LEN([科目代号]) > 2");
				}
				OleDbCommand ocmd = new OleDbCommand(sql.ToString(), oconn);
				OleDbDataReader reader = ocmd.ExecuteReader();

				int dataRowIndex = 0;
				var dao = new SqlDbHelper();
				if (itemType == XEnum.ImportItemType.Public && sheetIndex > 1) {
					// Don't delete existing records when importing sheet2 or later
				}
				else {
					dao.ExecuteNonQuery(string.Format("DELETE FROM Import{0} WHERE ImportId = {1}", suffix, importId));
				}

				sql.Clear();
				while (reader.Read()) {
					if (DataUtility.GetValue(reader, 0).Equals(dataRowEnding)) { // Going to end
						break;
					}
					dataRowIndex++;
					if (itemType == XEnum.ImportItemType.Public) {
						sql.AppendLine(GetInsertSql4Public(reader, importId, suffix, columnCount, dbColumns, sheetIndex));
					}
					else {
						sql.AppendLine(GetInsertSql(reader, importId, suffix, columnCount, dbColumns));
					}
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
				logger.Error("Outest catch", ex);
				return ex.Message;
			}
			finally {
				if (oleOpened) {
					oconn.Close();
				}
			}
			return string.Empty;
		}

		private string GetTableSuffix(XEnum.ImportItemType itemType) {
			var suffix = itemType.ToString();
			var startAt = suffix.LastIndexOf('.');
			suffix = suffix.Substring(startAt + 1);
			return suffix;
		}

		private string GetInsertSql(OleDbDataReader reader, int importId, string suffix, int columnCount, string columns) {
			var values = new StringBuilder();
			values.Append(DataUtility.GetSqlValue(reader, 0));
			for (int i = 1; i < columnCount; i++) {
				values.Append(", " + DataUtility.GetSqlValue(reader, i));
			}
			var sql = string.Format("INSERT INTO Import{0} (ImportId, {1}) VALUES ({2}, {3})", suffix, columns, importId, values);
			return sql;
		}

		private string GetInsertSql4Public(OleDbDataReader reader, int importId, string suffix, int columnCount, string columns, int type) {
			var values = new StringBuilder();
			values.Append(DataUtility.GetSqlValue(reader, 0));
			for (int i = 1; i < columnCount; i++) {
				values.Append(", " + DataUtility.GetSqlValue(reader, i));
			}
			var sql = string.Format("INSERT INTO Import{0} (ImportId, PublicType, {1}) VALUES ({2}, {3}, {4})", suffix, columns, importId, type, values);
			return sql;
		}

		private bool IsAllCopied(int importId) {
			var dao = new SqlDbHelper();
			var count = (int)dao.ExecuteScalar(string.Format("SELECT COUNT(*) FROM ImportItem WHERE ImportId = {0}", importId));
			return count == 7;
		}

		public string CompleteImport(int importId, string importFolder) {
			var result = AssignOrgNo(importId);
			if (!String.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			result = AssignLoanAccount(importId);
			if (!String.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			result = AssignDangerLevel(importId);
			if (!String.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			logger.Debug("Changing import state to Complete");
			ChangeImportState(importId, XEnum.ImportState.Complete);
			logger.Debug("Import to database done");

			return string.Empty;
		}

		private string AssignOrgNo(int importId) {
			try {
				logger.Debug("Assigning OrgNo column to Private");
				var sql = new StringBuilder();
				sql.AppendLine("UPDATE ImportPrivate");
				sql.AppendLine("SET OrgNo = (");
				sql.AppendLine("	SELECT TOP 1 Number FROM Org O");
				sql.AppendLine("	WHERE ImportPrivate.OrgName2 IN (O.Name, O.Alias1, O.Alias2)");
				sql.AppendLine("		OR REPLACE(ImportPrivate.OrgName2, '榆林分行', '') IN (O.Name, O.Alias1, O.Alias2)");
				sql.AppendLine(")");
				sql.AppendLine("WHERE ImportId = {0} AND OrgNo IS NULL");
				var dao = new SqlDbHelper();
				dao.ExecuteNonQuery(string.Format(sql.ToString(), importId));
				logger.Debug("Done");

				logger.Debug("Assigning OrgNo column to Public");
				sql.Clear();
				sql.AppendLine("UPDATE ImportPublic");
				sql.AppendLine("SET OrgNo = (");
				sql.AppendLine("	SELECT TOP 1 Number FROM Org O");
				sql.AppendLine("	WHERE ImportPublic.OrgName2 IN (O.Name, O.Alias1, O.Alias2)");
				sql.AppendLine("		OR REPLACE(ImportPublic.OrgName2, '榆林分行', '') IN (O.Name, O.Alias1, O.Alias2)");
				sql.AppendLine(")");
				sql.AppendLine("WHERE ImportId = {0} AND OrgNo IS NULL");
				dao.ExecuteNonQuery(string.Format(sql.ToString(), importId));
				logger.Debug("Done");
			}
			catch (Exception ex) {
				return ex.Message;
			}
			return string.Empty;
		}

		// Run this function after OrgNo is assigned
		private string AssignLoanAccount(int importId) {
			try {
				logger.Debug("Assigning LoanAccount column to Private");
				var sql = new StringBuilder();
				sql.AppendLine("UPDATE P SET LoanAccount = L.LoanAccount");
				sql.AppendLine("FROM ImportPrivate P");
				sql.AppendLine("	INNER JOIN ImportLoan L ON P.ImportId = L.ImportId AND L.CustomerType = '对私'");
				sql.AppendLine("		AND P.OrgNo = L.OrgNo AND P.CustomerName = L.CustomerName AND P.ContractStartDate = L.LoanStartDate AND P.ContractEndDate = L.LoanEndDate");
				sql.AppendLine("WHERE P.ImportId = {0} AND P.LoanAccount IS NULL");
				var dao = new SqlDbHelper();
				dao.ExecuteNonQuery(string.Format(sql.ToString(), importId));
				logger.Debug("Done");
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

		private XEnum.ImportState ChangeImportState(int importId, XEnum.ImportState toState) {

			var sql = new StringBuilder();
			sql.AppendLine("UPDATE Import SET State = {1} WHERE Id = {0} AND State < {1}");
			sql.AppendLine("SELECT State FROM Import WHERE Id = {0}");
			var dao = new SqlDbHelper();
			var state = (short)dao.ExecuteScalar(string.Format(sql.ToString(), importId, (int)toState));
			return (XEnum.ImportState)state;
		}
		#endregion
	}
}

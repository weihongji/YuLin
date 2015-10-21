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
			CopyItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.Loan);
			CopyItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.Public);
			CopyItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.Private);
			CopyItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.NonAccrual);
			CopyItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.Overdue);
			CopyItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.YWNei);
			CopyItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.YWWai);
			logger.DebugFormat("Source files copy done", importFolder);

			if (IsAllCopied(importId)) {
				logger.Debug("All copied");
				ChangeImportState(importId, XEnum.ImportState.AllCopied);

				//Import data into database
				result = ImportToDatabase(importId, importFolder);
			}

			logger.DebugFormat("Import #{0} done", importId);
			return result;
		}

		private void CopyItem(int importId, string importFolder, string[] sourceFiles, XEnum.ImportItemType itemType) {
			int itemTypeId = (int)itemType;

			string sourceFilePath = sourceFiles[itemTypeId];
			string targetFileName = this.targetFileNames[itemTypeId];

			if (sourceFilePath.Length > 0) {
				int importItemId;

				if (File.Exists(sourceFilePath)) {
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
					importItemId = (int)dao.ExecuteScalar(sql.ToString());
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
				}
			}
		}
		#endregion

		#region "Import excel data to database"
		public string ImportToDatabase(int importId, string importFolder) {
			importFolder += "\\Processed";
			logger.Debug("Importing Loan to database");
			var result = ImportLoan(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.Loan]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Importing Public to database");
			result = ImportPublic(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.Public]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Importing Private to database");
			result = ImportPrivate(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.Private]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Importing NonAccrual to database");
			result = ImportNonAccrual(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.NonAccrual]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Importing Overdue to database");
			result = ImportOverdue(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.Overdue]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Importing YWNei to database");
			result = ImportYWNei(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.YWNei]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Importing YWWai to database");
			result = ImportYWWai(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.YWWai]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Assigning org number to Private");
			result = AssignOrgNo(importId);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Assigning Danger Level to Loan");
			result = AssignDangerLevel(importId);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Changing import state to Imported (completed)");
			ChangeImportState(importId, XEnum.ImportState.Imported);
			logger.Debug("Import to database done");

			return string.Empty;
		}

		public string ImportLoan(int importId, string filePath) {
			var excelColumns = "[机构号码], [贷款科目], [贷款帐号], [客户名称], [客户编号], [客户类型], [贷款总额], [本金余额], [拖欠本金], [拖欠应收利息], [拖欠催收利息], [放款日期], [到期日期], [贷款状态], [贷款种类说明], [贷款用途]";
			var dbColumns = "OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, LoanAmount, CapitalAmount, OweCapital, OweYingShouInterest, OweCuiShouInterest, LoanStartDate, LoanEndDate, LoanState, LoanTypeName, Direction";
			return ImportTable(importId, filePath, XEnum.ImportItemType.Loan, excelColumns, dbColumns, 16);
		}

		public string ImportPublic(int importId, string filePath) {
			var excelColumns = "[支行名称], [客户姓名], [借款人企业性质], [组织机构代码], [合同编号], [借据开始日期], [借据结束日期], [发放后投向行业门类], [发放后投向行业大类], [发放后投向行业中类], [发放后投向行业小类], [授信品种], [七级分类], [客户规模(行内）], [客户规模(行外）], [本金逾期天数], [欠息天数], [贷款余额], [主要担保方式], [正常余额], [逾期余额], [非应计余额], [贷款账号], [是否政府融资平台]";
			var dbColumns = "OrgName2, CustomerName, OrgType, OrgCode, ContractNo, LoanStartDate, LoanEndDate, Direction1, Direction2, Direction3, Direction4, BusinessType, ClassifyResult, MyBankIndTypeName, ScopeName, OverdueDays, OweInterestDays, Balance1, VouchTypeName, NormalBalance, OverdueBalance, BadBalance, LoanAccount, IsINRZ";

			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			oconn.Open();
			DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
			int maxSheets = 3;
			for (int sheetIndex = 0; sheetIndex < maxSheets; sheetIndex++) {
				if (dt.Rows.Count < sheetIndex * 2 + 1) {
					break;
				}
				var result = ImportTable(importId, filePath, XEnum.ImportItemType.Public, excelColumns, dbColumns, 24, sheetIndex + 1);
				if (!String.IsNullOrEmpty(result)) {
					return result;
				}
			}
			return string.Empty;
		}

		public string ImportPrivate(int importId, string filePath) {
			var excelColumns = "[支行], [信贷产品名称], [产品核算项目], [客户名称], [证件号码], [合同开始日期], [合同到期日], [担保方式], [贷款余额], [贷款发放后投向1], [贷款发放后投向2], [贷款发放后投向3], [贷款发放后投向4], [本金最长逾期天数], [利息最长逾期天数], [拖欠利息], [逾期余额], [非应计余额]";
			var dbColumns = "OrgName2, ProductName, ProductType, CustomerName, IdCardNo, ContractStartDate, ContractEndDate, DanBaoFangShi, LoanBalance, Direction1, Direction2, Direction3, Direction4, CapitalOverdueDays, InterestOverdueDays, OweInterestAmount, OverdueBalance, NonAccrualBalance";
			return ImportTable(importId, filePath, XEnum.ImportItemType.Private, excelColumns, dbColumns, 18);
		}

		public string ImportNonAccrual(int importId, string filePath) {
			var excelColumns = "[机构名称], [客户名称], [贷款帐号], [担保情况]";
			var dbColumns = "OrgName, CustomerName, LoanAccount, DanBaoFangShi";
			return ImportTable(importId, filePath, XEnum.ImportItemType.NonAccrual, excelColumns, dbColumns, 4);
		}

		public string ImportOverdue(int importId, string filePath) {
			var excelColumns = "[机构名称], [客户名称], [贷款帐号], [客户编号], [贷款种类], [贷款发放日], [贷款到期日], [逾期本金余额], [利息余额], [担保情况]";
			var dbColumns = "OrgName, CustomerName, LoanAccount, CustomerNo, LoanType, LoanStartDate, LoanEndDate, CapitalOverdueBalance, InterestBalance, DanBaoFangShi";
			return ImportTable(importId, filePath, XEnum.ImportItemType.Overdue, excelColumns, dbColumns, 10);
		}

		public string ImportYWNei(int importId, string filePath) {
			var excelColumns = "*";
			var dbColumns = "SubjectCode, SubjectName, LastDebitBalance, LastCreditBalance, CurrentDebitChange, CurrentCreditChange, CurrentDebitBalance, CurrentCreditBalance";
			return ImportTable(importId, filePath, XEnum.ImportItemType.YWNei, excelColumns, dbColumns, 8);
		}

		public string ImportYWWai(int importId, string filePath) {
			var excelColumns = "*";
			var dbColumns = "SubjectCode, SubjectName, LastDebitBalance, LastCreditBalance, CurrentDebitChange, CurrentCreditChange, CurrentDebitBalance, CurrentCreditBalance";
			return ImportTable(importId, filePath, XEnum.ImportItemType.YWWai, excelColumns, dbColumns, 8);
		}

		public string ImportTable(int importId, string filePath, XEnum.ImportItemType itemType, string excelColumns, string dbColumns, int columnCount, int sheetIndex = 1) {
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
				else if (itemType == XEnum.ImportItemType.YWNei || itemType == XEnum.ImportItemType.YWWai) {
					sql.Append(" WHERE LEN([科目代号]) > 2");
				}
				OleDbCommand ocmd = new OleDbCommand(sql.ToString(), oconn);
				OleDbDataReader reader = ocmd.ExecuteReader();

				int dataRowIndex = 0;
				var dao = new SqlDbHelper();
				var importItemIdObject = dao.ExecuteScalar(string.Format("SELECT Id FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}", importId, (int)itemType));
				int importItemId = importItemIdObject == DBNull.Value ? 0 : (int)importItemIdObject;
				if (itemType == XEnum.ImportItemType.Public && sheetIndex > 1) {
					// Don't delete existing records when importing sheet2 or later
				}
				else {
					dao.ExecuteNonQuery(string.Format("DELETE FROM Import{0} WHERE ImportItemId = {1}", suffix, importItemId));
				}

				sql.Clear();
				while (reader.Read()) {
					if (DataUtility.GetValue(reader, 0).Equals(dataRowEnding)) { // Going to end
						break;
					}
					dataRowIndex++;
					if (itemType == XEnum.ImportItemType.Public) {
						sql.AppendLine(GetInsertSql4Public(reader, importItemId, suffix, columnCount, dbColumns, sheetIndex));
					}
					else {
						sql.AppendLine(GetInsertSql(reader, importItemId, suffix, columnCount, dbColumns));
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
					var query = string.Format("DELETE FROM ImportLoan WHERE ImportItemId = {0} AND ISNULL(CapitalAmount + OweCapital + OweYingShouInterest + OweCuiShouInterest, 0) = 0", importItemId);
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

		private string GetInsertSql(OleDbDataReader reader, int importItemId, string suffix, int columnCount, string columns) {
			var values = new StringBuilder();
			values.Append(DataUtility.GetSqlValue(reader, 0));
			for (int i = 1; i < columnCount; i++) {
				values.Append(", " + DataUtility.GetSqlValue(reader, i));
			}
			var sql = string.Format("INSERT INTO Import{0} (ImportItemId, {1}) VALUES ({2}, {3})", suffix, columns, importItemId, values);
			return sql;
		}

		private string GetInsertSql4Public(OleDbDataReader reader, int importItemId, string suffix, int columnCount, string columns, int type) {
			var values = new StringBuilder();
			values.Append(DataUtility.GetSqlValue(reader, 0));
			for (int i = 1; i < columnCount; i++) {
				values.Append(", " + DataUtility.GetSqlValue(reader, i));
			}
			var sql = string.Format("INSERT INTO Import{0} (ImportItemId, PublicType, {1}) VALUES ({2}, {3}, {4})", suffix, columns, importItemId, type, values);
			return sql;
		}

		public string AssignOrgNo(int importId) {
			try {
				//Assign OrgNo column
				var sql = new StringBuilder();
				sql.AppendLine("UPDATE ImportPrivate");
				sql.AppendLine("SET OrgNo = (");
				sql.AppendLine("	SELECT TOP 1 Number FROM Org O");
				sql.AppendLine("	WHERE ImportPrivate.OrgName2 IN (O.Name, O.Alias1, O.Alias2)");
				sql.AppendLine("		OR REPLACE(ImportPrivate.OrgName2, '榆林分行', '') IN (O.Name, O.Alias1, O.Alias2)");
				sql.AppendLine(")");
				sql.AppendLine("WHERE ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}) AND OrgNo IS NULL");
				var dao = new SqlDbHelper();
				dao.ExecuteNonQuery(string.Format(sql.ToString(), importId, (int)XEnum.ImportItemType.Private));
			}
			catch (Exception ex) {
				return ex.Message;
			}
			return string.Empty;
		}

		public bool IsAllCopied(int importId) {
			var dao = new SqlDbHelper();
			var count = (int)dao.ExecuteScalar(string.Format("SELECT COUNT(*) FROM ImportItem WHERE ImportId = {0}", importId));
			return count == 7;
		}

		public string AssignDangerLevel(int importId) {
			try {
				var dao = new SqlDbHelper();
				var sql = new StringBuilder();
				sql.AppendLine("UPDATE ImportLoan SET DangerLevel = dbo.sfGetDangerLevel({0}, LoanAccount)");
				sql.AppendLine("WHERE LoanState != '结清'");
				sql.AppendLine("	AND ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = {0} AND ItemType = {1})");
				dao.ExecuteNonQuery(string.Format(sql.ToString(), importId, (int)XEnum.ImportItemType.Loan));
			}
			catch (Exception ex) {
				return ex.Message; ;
			}
			return string.Empty;
		}

		public XEnum.ImportState ChangeImportState(int importId, XEnum.ImportState toState) {

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

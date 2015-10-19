using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Data.OleDb;
using System.IO;

using DataAccess;
using Entities;
using Logging;
using Helper;

namespace Importer
{
	public class ExcelImporter
	{
		private string[] targetFileNames = { "dummy", "Loan.xls", "Public.xls", "Private.xls", "NonAccrual.xls", "Overdue.xls" };
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
			logger.DebugFormat("Source files copy done", importFolder);

			if (IsAllCopied(importId)) {
				logger.Debug("All copied");
				ChangeImportState(importId, XEnum.ImportState.AllCopied);

				//Import data into database
				result = ImportToDatabase(importId, importFolder);
				PopulateReportLoanRiskPerMonthFYJ(importId);
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

			//Assigning org number ...
			logger.Debug("Assigning org number to Private");
			result = AssignOrgNo(importId);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			//Assigning Danger Level
			logger.Debug("Assigning Danger Level to Loan");
			result = AssignDangerLevel(importId);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			ChangeImportState(importId, XEnum.ImportState.Imported);
			logger.Debug("Import to database done");

			return string.Empty;
		}

		public string ImportLoan(int importId, string filePath) {
			if (String.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath)) {
				return string.Format("File {0} cannot be found", filePath ?? "<empty>");
			}

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			try {
				logger.Debug("Opening connection to " + filePath);
				oconn.Open();
				oleOpened = true;
				logger.Debug("Opened");

				DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
				string sheet1 = dt.Rows[0][2].ToString();

				OleDbCommand ocmd = new OleDbCommand(string.Format("select * from [{0}]", sheet1), oconn);
				OleDbDataReader reader = ocmd.ExecuteReader();
				int dataRowIndex = 0;
				var sql = new StringBuilder();
				var dao = new SqlDbHelper();
				var importItemIdObject = dao.ExecuteScalar(string.Format("SELECT Id FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}", importId, (int)XEnum.ImportItemType.Loan));
				int importItemId = importItemIdObject == DBNull.Value ? 0 : (int)importItemIdObject;
				dao.ExecuteNonQuery("DELETE FROM ImportLoan WHERE ImportItemId = " + importItemId.ToString());
				while (reader.Read()) {
					if (string.IsNullOrWhiteSpace(DataUtility.GetValue(reader, 0))) { // Going to end
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql4Loan(reader, importItemId));
					// Top 3 trial for exception track
					if (dataRowIndex == 3) {
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

		public string ImportPublic(int importId, string filePath) {
			if (String.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath)) {
				return string.Format("没有找到文件 {0}", filePath ?? "<empty>");
			}

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			try {
				logger.Debug("Opening connection to " + filePath);
				oconn.Open();
				oleOpened = true;
				logger.Debug("Opened");

				DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
				string sheetName;
				int maxSheets = 3;
				for (int sheetIndex = 0; sheetIndex < maxSheets; sheetIndex++) {
					if (dt.Rows.Count < sheetIndex * 2 + 1) {
						break;
					}
					sheetName = dt.Rows[sheetIndex * 2][2].ToString();
					logger.Debug("Importing sheet " + (sheetName.EndsWith("$") ? sheetName.Substring(0, sheetName.Length - 1) : sheetName));

					OleDbCommand ocmd = new OleDbCommand(string.Format("select * from [{0}]", sheetName), oconn);
					OleDbDataReader reader = ocmd.ExecuteReader();
					int skipRows = sheetIndex == 0 ? 1 : 0;
					for (int i = 0; i < skipRows && reader.Read(); i++) {
						// Loop until get to the header row
					}
					int dataRowIndex = 0;
					var sql = new StringBuilder();
					var dao = new SqlDbHelper();
					var importItemIdObject = dao.ExecuteScalar(string.Format("SELECT Id FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}", importId, (int)XEnum.ImportItemType.Public));
					int importItemId = importItemIdObject == DBNull.Value ? 0 : (int)importItemIdObject;
					dao.ExecuteNonQuery("DELETE FROM ImportPublic WHERE ImportItemId = " + importItemId.ToString());
					while (reader.Read()) {
						if (string.IsNullOrWhiteSpace(DataUtility.GetValue(reader, 0))) { // Going to end
							break;
						}
						dataRowIndex++;
						sql.AppendLine(GetInsertSql4Public(reader, importItemId, sheetIndex));
						// Top 3 trial for exception track
						if (dataRowIndex == 3) {
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
						}
						catch (Exception ex) {
							logger.Error("Running INSERT: " + sql.ToString(), ex);
							throw ex;
						}
					}
					logger.DebugFormat("{0} records imported.", dataRowIndex);
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

		public string ImportPrivate(int importId, string filePath) {
			if (String.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath)) {
				return string.Format("File {0} cannot be found", filePath ?? "<empty>");
			}

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			try {
				logger.Debug("Opening connection to " + filePath);
				oconn.Open();
				oleOpened = true;
				logger.Debug("Opened");

				DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
				string sheet1 = dt.Rows[0][2].ToString();

				OleDbCommand ocmd = new OleDbCommand(string.Format("select * from [{0}]", sheet1), oconn);
				OleDbDataReader reader = ocmd.ExecuteReader();
				int skipRows = 2;
				for (int i = 0; i < skipRows && reader.Read(); i++) {
					// Loop until get to the header row
				}
				int dataRowIndex = 0;
				var sql = new StringBuilder();
				var dao = new SqlDbHelper();
				var importItemIdObject = dao.ExecuteScalar(string.Format("SELECT Id FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}", importId, (int)XEnum.ImportItemType.Private));
				int importItemId = importItemIdObject == DBNull.Value ? 0 : (int)importItemIdObject;
				dao.ExecuteNonQuery("DELETE FROM ImportPrivate WHERE ImportItemId = " + importItemId.ToString());
				while (reader.Read()) {
					if (string.IsNullOrWhiteSpace(DataUtility.GetValue(reader, 0))) {
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql4Private(reader, importItemId));
					// Top 3 trial for exception track
					if (dataRowIndex == 3) {
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

		public string ImportNonAccrual(int importId, string filePath) {
			if (String.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath)) {
				return string.Format("File {0} cannot be found", filePath ?? "<empty>");
			}

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			try {
				logger.Debug("Opening connection to " + filePath);
				oconn.Open();
				oleOpened = true;
				logger.Debug("Opened");

				DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
				string sheet1 = dt.Rows[0][2].ToString();

				OleDbCommand ocmd = new OleDbCommand(string.Format("select * from [{0}]", sheet1), oconn);
				OleDbDataReader reader = ocmd.ExecuteReader();
				int dataRowIndex = 0;
				var sql = new StringBuilder();
				var dao = new SqlDbHelper();
				var importItemIdObject = dao.ExecuteScalar(string.Format("SELECT Id FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}", importId, (int)XEnum.ImportItemType.NonAccrual));
				int importItemId = importItemIdObject == DBNull.Value ? 0 : (int)importItemIdObject;
				dao.ExecuteNonQuery("DELETE FROM ImportNonAccrual WHERE ImportItemId = " + importItemId.ToString());
				while (reader.Read()) {
					if (DataUtility.GetValue(reader, 0).Equals("本页小计")) { // Going to end
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql4NonAccrual(reader, importItemId));
					// Top 3 trial for exception track
					if (dataRowIndex == 3) {
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

		public string ImportOverdue(int importId, string filePath) {
			if (String.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath)) {
				return string.Format("File {0} cannot be found", filePath ?? "<empty>");
			}

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			try {
				logger.Debug("Opening connection to " + filePath);
				oconn.Open();
				oleOpened = true;
				logger.Debug("Opened");

				DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
				string sheet1 = dt.Rows[0][2].ToString();

				OleDbCommand ocmd = new OleDbCommand(string.Format("select * from [{0}A9:J9999]", sheet1), oconn);
				OleDbDataReader reader = ocmd.ExecuteReader();
				int dataRowIndex = 0;
				var sql = new StringBuilder();
				var dao = new SqlDbHelper();
				var importItemIdObject = dao.ExecuteScalar(string.Format("SELECT Id FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}", importId, (int)XEnum.ImportItemType.Overdue));
				int importItemId = importItemIdObject == DBNull.Value ? 0 : (int)importItemIdObject;
				dao.ExecuteNonQuery("DELETE FROM ImportOverdue WHERE ImportItemId = " + importItemId.ToString());
				while (reader.Read()) {
					if (DataUtility.GetValue(reader, 0).Equals("本页小计")) { // Going to end
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql4Overdue(reader, importItemId));
					// Top 3 trial for exception track
					if (dataRowIndex == 3) {
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

		private string GetInsertSql4Loan(OleDbDataReader reader, int importItemId) {
			var pattern = "INSERT INTO ImportLoan (ImportItemId, OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, CurrencyType, LoanAmount, CapitalAmount, OweCapital, OweYingShouInterest, OweCuiShouInterest, ColumnM, DueBillNo, LoanStartDate, LoanEndDate, ZhiHuanZhuanRang, HeXiaoFlag, LoanState, LoanType, LoanTypeName, Direction, ZhuanLieYuQi, ZhuanLieFYJ, InterestEndDate, LiLvType, LiLvSymbol, LiLvJiaJianMa, YuQiLiLvYiJu, YuQiLiLvType, YuQiLiLvSymbol, YuQiLiLvJiaJianMa, LiLvYiJu, ContractInterestRatio, ContractOverdueInterestRate, ChargeAccount) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}, {25}, {26}, {27}, {28}, {29}, {30}, {31}, {32}, {33}, {34}, {35}, {36})";
			return string.Format(pattern, importItemId, DataUtility.GetSqlValue(reader, 0), DataUtility.GetSqlValue(reader, 1), DataUtility.GetSqlValue(reader, 2), DataUtility.GetSqlValue(reader, 3), DataUtility.GetSqlValue(reader, 4), DataUtility.GetSqlValue(reader, 5), DataUtility.GetSqlValue(reader, 6), DataUtility.GetSqlValue(reader, 7), DataUtility.GetSqlValue(reader, 8), DataUtility.GetSqlValue(reader, 9), DataUtility.GetSqlValue(reader, 10), DataUtility.GetSqlValue(reader, 11), DataUtility.GetSqlValue(reader, 12), DataUtility.GetSqlValue(reader, 13), DataUtility.GetSqlValue(reader, 14), DataUtility.GetSqlValue(reader, 15), DataUtility.GetSqlValue(reader, 16), DataUtility.GetSqlValue(reader, 17), DataUtility.GetSqlValue(reader, 18), DataUtility.GetSqlValue(reader, 19), DataUtility.GetSqlValue(reader, 20), DataUtility.GetSqlValue(reader, 21), DataUtility.GetSqlValue(reader, 22), DataUtility.GetSqlValue(reader, 23), DataUtility.GetSqlValue(reader, 24), DataUtility.GetSqlValue(reader, 25), DataUtility.GetSqlValue(reader, 26), DataUtility.GetSqlValue(reader, 27), DataUtility.GetSqlValue(reader, 28), DataUtility.GetSqlValue(reader, 29), DataUtility.GetSqlValue(reader, 30), DataUtility.GetSqlValue(reader, 31), DataUtility.GetSqlValue(reader, 32), DataUtility.GetSqlValue(reader, 33), DataUtility.GetSqlValue(reader, 34), DataUtility.GetSqlValue(reader, 35));
		}

		private string GetInsertSql4Public(OleDbDataReader reader, int importItemId, int type) {
			var pattern = "INSERT INTO ImportPublic (ImportItemId, PublicType, OrgName, OrgName2, CustomerNo, CustomerName, OrgType, OrgCode, ContractNo, DueBillNo, ActualPutOutDate, ActualMaturity, IndustryType1, IndustryType2, IndustryType3, IndustryType4, TermMonth, CurrencyType, Direction1, Direction2, Direction3, Direction4, OccurType, BusinessType, SubjectNo, Balance, ClassifyResult, CreditLevel, MyBankIndType, MyBankIndTypeName, Scope, ScopeName, OverdueDays, OweInterestDays, Balance1, ActualBusinessRate, RateFloat, VouchTypeName, BailRatio, NormalBalance, OverdueBalance, BadBalance, FContractNo, IsAgricultureCredit, IsINRZ) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}, {25}, {26}, {27}, {28}, {29}, {30}, {31}, {32}, {33}, {34}, {35}, {36}, {37}, {38}, {39}, {40}, {41}, {42}, {43}, {44})";
			return string.Format(pattern, importItemId, type, DataUtility.GetSqlValue(reader, 0), DataUtility.GetSqlValue(reader, 1), DataUtility.GetSqlValue(reader, 2), DataUtility.GetSqlValue(reader, 3), DataUtility.GetSqlValue(reader, 4), "NULL", DataUtility.GetSqlValue(reader, 6), DataUtility.GetSqlValue(reader, 7), DataUtility.GetSqlValue(reader, 8), DataUtility.GetSqlValue(reader, 9), DataUtility.GetSqlValue(reader, 10), DataUtility.GetSqlValue(reader, 11), DataUtility.GetSqlValue(reader, 12), DataUtility.GetSqlValue(reader, 13), DataUtility.GetSqlValue(reader, 14), DataUtility.GetSqlValue(reader, 15), DataUtility.GetSqlValue(reader, 16), DataUtility.GetSqlValue(reader, 17), DataUtility.GetSqlValue(reader, 18), DataUtility.GetSqlValue(reader, 19), DataUtility.GetSqlValue(reader, 20), DataUtility.GetSqlValue(reader, 21), DataUtility.GetSqlValue(reader, 22), DataUtility.GetSqlValue(reader, 23), DataUtility.GetSqlValue(reader, 24), DataUtility.GetSqlValue(reader, 25), DataUtility.GetSqlValue(reader, 26), DataUtility.GetSqlValue(reader, 27), DataUtility.GetSqlValue(reader, 28), DataUtility.GetSqlValue(reader, 29), DataUtility.GetSqlValue(reader, 30), DataUtility.GetSqlValue(reader, 31), DataUtility.GetSqlValue(reader, 32), DataUtility.GetSqlValue(reader, 33), DataUtility.GetSqlValue(reader, 34), DataUtility.GetSqlValue(reader, 35), DataUtility.GetSqlValue(reader, 36), DataUtility.GetSqlValue(reader, 37), DataUtility.GetSqlValue(reader, 38), DataUtility.GetSqlValue(reader, 39), DataUtility.GetSqlValue(reader, 40), DataUtility.GetSqlValue(reader, 41), DataUtility.GetSqlValue(reader, 42));
		}

		private string GetInsertSql4Private(OleDbDataReader reader, int importItemId) {
			var pattern = "INSERT INTO ImportPrivate (ImportItemId, OrgName, OrgName2, ProductName, ProductType, LoanMonths, ZongHeShouXinEDu, DangerLevel, RepaymentMethod, CustomerName, CurrencyType, ContractStartDate, ContractEndDate, InterestRatio, DanBaoFangShi, LoanBalance, Direction1, Direction2, Direction3, Direction4, CapitalOverdueDays, InterestOverdueDays, OweInterestAmount, OverdueBalance, NonAccrualBalance) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24})";
			return string.Format(pattern, importItemId, DataUtility.GetSqlValue(reader, 0), DataUtility.GetSqlValue(reader, 1), DataUtility.GetSqlValue(reader, 2), DataUtility.GetSqlValue(reader, 3), DataUtility.GetSqlValue(reader, 4), DataUtility.GetSqlValue(reader, 5), DataUtility.GetSqlValue(reader, 6), DataUtility.GetSqlValue(reader, 7), DataUtility.GetSqlValue(reader, 8), DataUtility.GetSqlValue(reader, 10), DataUtility.GetSqlValue(reader, 11), DataUtility.GetSqlValue(reader, 12), DataUtility.GetSqlValue(reader, 13), DataUtility.GetSqlValue(reader, 14), DataUtility.GetSqlValue(reader, 15), DataUtility.GetSqlValue(reader, 16), DataUtility.GetSqlValue(reader, 17), DataUtility.GetSqlValue(reader, 18), DataUtility.GetSqlValue(reader, 19), DataUtility.GetSqlValue(reader, 20), DataUtility.GetSqlValue(reader, 21), DataUtility.GetSqlValue(reader, 22), DataUtility.GetSqlValue(reader, 23), DataUtility.GetSqlValue(reader, 24));
		}

		private string GetInsertSql4NonAccrual(OleDbDataReader reader, int importItemId) {
			//var pattern = "INSERT INTO ImportNonAccrual (ImportItemId, OrgName, CustomerName, LoanBalance, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, InterestOverdueDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, LoanAccount, CustomerNo) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16})";
			//return string.Format(pattern, importItemId, DataUtility.GetSqlValue(reader, 0), DataUtility.GetSqlValue(reader, 1), DataUtility.GetSqlValue(reader, 2), DataUtility.GetSqlValue(reader, 3), DataUtility.GetSqlValue(reader, 4), DataUtility.GetSqlValue(reader, 5), DataUtility.GetSqlValue(reader, 6), DataUtility.GetSqlValue(reader, 7), DataUtility.GetSqlValue(reader, 8), DataUtility.GetSqlValue(reader, 9), DataUtility.GetSqlValue(reader, 10), DataUtility.GetSqlValue(reader, 11), DataUtility.GetSqlValue(reader, 12), DataUtility.GetSqlValue(reader, 13), DataUtility.GetSqlValue(reader, 14), DataUtility.GetSqlValue(reader, 15));
			var pattern = "INSERT INTO ImportNonAccrual (ImportItemId, OrgName, CustomerName, LoanAccount, DanBaoFangShi) VALUES ({0}, {1}, {2}, {3}, {4})";
			return string.Format(pattern, importItemId, DataUtility.GetSqlValue(reader, 0), DataUtility.GetSqlValue(reader, 1), DataUtility.GetSqlValue(reader, 2), DataUtility.GetSqlValue(reader, 9));
		}

		private string GetInsertSql4Overdue(OleDbDataReader reader, int importItemId) {
			var pattern = "INSERT INTO ImportOverdue (ImportItemId, OrgName, CustomerName, LoanAccount, CustomerNo, LoanType, LoanStartDate, LoanEndDate, CapitalOverdueBalance, InterestBalance, DanBaoFangShi) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10})";
			return string.Format(pattern, importItemId, DataUtility.GetSqlValue(reader, 0), DataUtility.GetSqlValue(reader, 1), DataUtility.GetSqlValue(reader, 2), DataUtility.GetSqlValue(reader, 3), DataUtility.GetSqlValue(reader, 4), DataUtility.GetSqlValue(reader, 5), DataUtility.GetSqlValue(reader, 6), DataUtility.GetSqlValue(reader, 7), DataUtility.GetSqlValue(reader, 8), DataUtility.GetSqlValue(reader, 9));
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
			return count == 5;
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
				return ex.Message;;
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

		private void PopulateReportLoanRiskPerMonthFYJ(int importId) {
			logger.Debug("Populating table ReportLoanRiskPerMonthFYJ");
			var dao = new SqlDbHelper();
			var rowCount = dao.ExecuteNonQuery(string.Format("EXEC spPopulateNoAccrual {0}", importId));
			logger.DebugFormat("{0} rows inserted into ReportLoanRiskPerMonthFYJ for import #{1}", rowCount, importId);
		}
		#endregion
	}
}

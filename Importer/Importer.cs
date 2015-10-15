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

namespace Importer
{
	public class ExcelImporter
	{
		#region Create import instance and backup imported files
		private string[] targetFileNames = { "Loan.xls", "Public.xls", "Private.xls", "NonAccrual.xls", "Overdue.xls" };
		public string CreateImport(DateTime asOfDate, string[] sourceFiles) {
			var result = string.Empty;
			var dao = new SqlDbHelper();
			var dateString = asOfDate.ToString("yyyyMMdd");
			var sql = new StringBuilder();
			sql.AppendLine(string.Format("SELECT ISNULL(MAX(Id), 0) FROM Import WHERE ImportDate = '{0}'", dateString));
			var importId = (int)dao.ExecuteScalar(sql.ToString());
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
			ImportItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.Loan);
			ImportItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.Public);
			ImportItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.Private);
			ImportItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.NonAccrual);
			ImportItem(importId, importFolder, sourceFiles, XEnum.ImportItemType.Overdue);

			if (IsAllCopied(importId)) {
				ChangeImportState(importId, XEnum.ImportState.AllCopied);

				//Import data into database
				result = ImportToDatabase(importId, importFolder);
			}

			return result;
		}

		private void ImportItem(int importId, string importFolder, string[] sourceFiles, XEnum.ImportItemType itemType) {
			int itemTypeId = (int)itemType;

			string sourceFilePath = sourceFiles[itemTypeId];
			string targetFileName = this.targetFileNames[itemTypeId];

			if (sourceFilePath.Length > 0) {
				var dao = new SqlDbHelper();
				var sql = new StringBuilder();
				int importItemId;

				if (File.Exists(sourceFilePath)) {
					File.Copy(sourceFilePath, importFolder + "\\" + targetFileName, true);
					sql.Clear();
					sql.AppendLine(string.Format("SELECT ISNULL(MAX(Id), 0) FROM ImportItem WHERE ImportId = {0} AND ItemType = {1}", importId, itemTypeId));
					importItemId = (int)dao.ExecuteScalar(sql.ToString());
					if (importItemId == 0) {
						sql.Clear();
						sql.AppendLine(string.Format("INSERT INTO ImportItem (ImportId, ItemType, FilePath) VALUES ({0}, {1}, '{2}')", importId, itemTypeId, sourceFilePath));
						sql.AppendLine("SELECT SCOPE_IDENTITY()");
						importItemId = (int)((decimal)dao.ExecuteScalar(sql.ToString()));
					}
					else {
						sql.Clear();
						sql.AppendLine(string.Format("UPDATE ImportItem SET FilePath = '{0}', ModifyDate = getdate() WHERE Id = {1}", sourceFilePath, importItemId));
						dao.ExecuteNonQuery(sql.ToString());
					}
				}
			}
		}
		#endregion

		#region "Import excel data to database"
		public string ImportToDatabase(int importId, string importFolder) {
			var result = ImportLoan(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.Loan]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			result = ImportPublic(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.Public]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			result = ImportPrivate(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.Private]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			result = ImportNonAccrual(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.NonAccrual]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			result = ImportOverdue(importId, importFolder + "\\" + targetFileNames[(int)XEnum.ImportItemType.Overdue]);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			//Assigning org number ...
			result = AssignOrgNo(importId);
			if (!String.IsNullOrEmpty(result)) {
				return result;
			}

			ChangeImportState(importId, XEnum.ImportState.Imported);

			return string.Empty;
		}

		public string ImportLoan(int importId, string filePath) {
			if (String.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath)) {
				return string.Format("File {0} cannot be found", filePath ?? "<empty>");
			}

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			try {
				oconn.Open();
				oleOpened = true;

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
					if (string.IsNullOrWhiteSpace(GetValue(reader, 0))) { // Going to end
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql4Loan(reader, importItemId));
					if (dataRowIndex > 1 && dataRowIndex % 1000 == 0) {
						dao.ExecuteNonQuery(sql.ToString());
						sql.Clear();
					}
				}
				if (sql.Length > 0) {
					dao.ExecuteNonQuery(sql.ToString());
				}
			}
			catch (DataException ee) {
				return ee.Message;
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
				return string.Format("File {0} cannot be found", filePath ?? "<empty>");
			}

			var oleOpened = false;
			OleDbConnection oconn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			try {
				oconn.Open();
				oleOpened = true;

				DataTable dt = oconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
				string sheet1;
				for (int sheetIndex = 0; sheetIndex < 3; sheetIndex++) {
					sheet1 = dt.Rows[sheetIndex * 2][2].ToString();

					OleDbCommand ocmd = new OleDbCommand(string.Format("select * from [{0}]", sheet1), oconn);
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
						if (string.IsNullOrWhiteSpace(GetValue(reader, 0))) { // Going to end
							break;
						}
						dataRowIndex++;
						sql.AppendLine(GetInsertSql4Public(reader, importItemId, sheetIndex));
						if (dataRowIndex > 1 && dataRowIndex % 1000 == 0) {
							dao.ExecuteNonQuery(sql.ToString());
							sql.Clear();
						}
					}
					if (sql.Length > 0) {
						dao.ExecuteNonQuery(sql.ToString());
					}
				}
			}
			catch (DataException ee) {
				return ee.Message;
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
				oconn.Open();
				oleOpened = true;

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
					if (string.IsNullOrWhiteSpace(GetValue(reader, 0))) {
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql4Private(reader, importItemId));
					if (dataRowIndex > 1 && dataRowIndex % 1000 == 0) {
						dao.ExecuteNonQuery(sql.ToString());
						sql.Clear();
					}
				}
				if (sql.Length > 0) {
					dao.ExecuteNonQuery(sql.ToString());
				}
			}
			catch (DataException ee) {
				return ee.Message;
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
				oconn.Open();
				oleOpened = true;

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
					if (GetValue(reader, 0).Equals("本页小计")) { // Going to end
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql4NonAccrual(reader, importItemId));
					if (dataRowIndex > 1 && dataRowIndex % 1000 == 0) {
						dao.ExecuteNonQuery(sql.ToString());
						sql.Clear();
					}
				}
				if (sql.Length > 0) {
					dao.ExecuteNonQuery(sql.ToString());
				}
			}
			catch (DataException ee) {
				return ee.Message;
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
				oconn.Open();
				oleOpened = true;

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
					if (GetValue(reader, 0).Equals("本页小计")) { // Going to end
						break;
					}
					dataRowIndex++;
					sql.AppendLine(GetInsertSql4Overdue(reader, importItemId));
					if (dataRowIndex > 200) {
						break;
					}
				}
				dao.ExecuteNonQuery(sql.ToString());
			}
			catch (DataException ee) {
				return ee.Message;
			}
			finally {
				if (oleOpened) {
					oconn.Close();
				}
			}
			return string.Empty;
		}

		private string GetInsertSql4Loan(OleDbDataReader reader, int importItemId) {
			var pattern = "INSERT INTO ImportLoan (ImportItemId, OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, CurrencyType, LoanAmount, CapitalAmount, OweCapital, OweYingShouInterest, OweCuiShouInterest, ColumnM, DueBillNo, LoanStartDate, LoanEndDate, ZhiHuanZhuanRang, HeXiaoFlag, LoanState, LoanType, LoanTypeName, Direction, ZhuanLieYuQi, ZhuanLieFYJ, InterestEndDate, LiLvType, LiLvSymbol, LiLvJiaJianMa, LiLvYiJu, YuQiLiLvYiJu, YuQiLiLvType, YuQiLiLvSymbol, YuQiLiLvJiaJianMa, ContractInterestRatio, ContractOverdueInterestRate, ChargeAccount) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}, {25}, {26}, {27}, {28}, {29}, {30}, {31}, {32}, {33}, {34}, {35}, {36})";
			return string.Format(pattern, importItemId, GetSqlValue(reader, 0), GetSqlValue(reader, 1), GetSqlValue(reader, 2), GetSqlValue(reader, 3), GetSqlValue(reader, 4), GetSqlValue(reader, 5), GetSqlValue(reader, 6), GetSqlValue(reader, 7), GetSqlValue(reader, 8), GetSqlValue(reader, 9), GetSqlValue(reader, 10), GetSqlValue(reader, 11), GetSqlValue(reader, 12), GetSqlValue(reader, 13), GetSqlValue(reader, 14), GetSqlValue(reader, 15), GetSqlValue(reader, 16), GetSqlValue(reader, 17), GetSqlValue(reader, 18), GetSqlValue(reader, 19), GetSqlValue(reader, 20), GetSqlValue(reader, 21), GetSqlValue(reader, 22), GetSqlValue(reader, 23), GetSqlValue(reader, 24), GetSqlValue(reader, 25), GetSqlValue(reader, 26), GetSqlValue(reader, 27), GetSqlValue(reader, 28), GetSqlValue(reader, 29), GetSqlValue(reader, 30), GetSqlValue(reader, 31), GetSqlValue(reader, 32), GetSqlValue(reader, 33), GetSqlValue(reader, 34), GetSqlValue(reader, 35));
		}

		private string GetInsertSql4Public(OleDbDataReader reader, int importItemId, int type) {
			if (type == 0) { //表内
				var pattern = "INSERT INTO ImportPublic (ImportItemId, PublicType, OrgName, OrgName2, CustomerNo, CustomerName, OrgType, OrgCode, ContractNo, DueBillNo, ActualPutOutDate, ActualMaturity, IndustryType1, IndustryType2, IndustryType3, IndustryType4, TermMonth, CurrencyType, Direction1, Direction2, Direction3, Direction4, OccurType, BusinessType, SubjectNo, Balance, ClassifyResult, CreditLevel, MyBankIndType, MyBankIndTypeName, Scope, ScopeName, OverdueDays, OweInterestDays, Balance1, ActualBusinessRate, RateFloat, VouchTypeName, BailRatio, NormalBalance, OverdueBalance, BadBalance, FContractNo, IsAgricultureCredit, IsINRZ) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}, {25}, {26}, {27}, {28}, {29}, {30}, {31}, {32}, {33}, {34}, {35}, {36}, {37}, {38}, {39}, {40}, {41}, {42}, {43}, {44})";
				return string.Format(pattern, importItemId, type, GetSqlValue(reader, 0), GetSqlValue(reader, 1), GetSqlValue(reader, 2), GetSqlValue(reader, 3), GetSqlValue(reader, 4), "NULL", GetSqlValue(reader, 5), GetSqlValue(reader, 6), GetSqlValue(reader, 7), GetSqlValue(reader, 8), GetSqlValue(reader, 9), GetSqlValue(reader, 10), GetSqlValue(reader, 11), GetSqlValue(reader, 12), GetSqlValue(reader, 13), GetSqlValue(reader, 14), GetSqlValue(reader, 15), GetSqlValue(reader, 16), GetSqlValue(reader, 17), GetSqlValue(reader, 18), GetSqlValue(reader, 19), GetSqlValue(reader, 20), GetSqlValue(reader, 21), GetSqlValue(reader, 22), GetSqlValue(reader, 23), GetSqlValue(reader, 24), GetSqlValue(reader, 25), GetSqlValue(reader, 26), GetSqlValue(reader, 27), GetSqlValue(reader, 28), GetSqlValue(reader, 29), GetSqlValue(reader, 30), GetSqlValue(reader, 31), GetSqlValue(reader, 32), GetSqlValue(reader, 33), GetSqlValue(reader, 34), GetSqlValue(reader, 35), GetSqlValue(reader, 36), GetSqlValue(reader, 37), GetSqlValue(reader, 38), GetSqlValue(reader, 39), GetSqlValue(reader, 40), GetSqlValue(reader, 41));
			}
			else {
				var pattern = "INSERT INTO ImportPublic (ImportItemId, PublicType, OrgName, OrgName2, CustomerNo, CustomerName, OrgType, OrgCode, ContractNo, DueBillNo, ActualPutOutDate, ActualMaturity, IndustryType1, IndustryType2, IndustryType3, IndustryType4, TermMonth, CurrencyType, Direction1, Direction2, Direction3, Direction4, OccurType, BusinessType, SubjectNo, Balance, ClassifyResult, CreditLevel, MyBankIndType, MyBankIndTypeName, Scope, ScopeName, OverdueDays, OweInterestDays, Balance1, ActualBusinessRate, RateFloat, VouchTypeName, BailRatio, NormalBalance, OverdueBalance, BadBalance, FContractNo, IsAgricultureCredit, IsINRZ) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}, {25}, {26}, {27}, {28}, {29}, {30}, {31}, {32}, {33}, {34}, {35}, {36}, {37}, {38}, {39}, {40}, {41}, {42}, {43}, {44})";
				return string.Format(pattern, importItemId, type, GetSqlValue(reader, 0), GetSqlValue(reader, 1), GetSqlValue(reader, 2), GetSqlValue(reader, 3), GetSqlValue(reader, 4), GetSqlValue(reader, 5), GetSqlValue(reader, 6), GetSqlValue(reader, 7), GetSqlValue(reader, 8), GetSqlValue(reader, 9), GetSqlValue(reader, 10), GetSqlValue(reader, 11), GetSqlValue(reader, 12), GetSqlValue(reader, 13), GetSqlValue(reader, 14), GetSqlValue(reader, 15), GetSqlValue(reader, 16), GetSqlValue(reader, 17), GetSqlValue(reader, 18), GetSqlValue(reader, 19), GetSqlValue(reader, 20), GetSqlValue(reader, 21), GetSqlValue(reader, 22), GetSqlValue(reader, 23), GetSqlValue(reader, 24), GetSqlValue(reader, 25), GetSqlValue(reader, 26), GetSqlValue(reader, 27), GetSqlValue(reader, 28), GetSqlValue(reader, 29), GetSqlValue(reader, 30), GetSqlValue(reader, 31), GetSqlValue(reader, 32), GetSqlValue(reader, 33), GetSqlValue(reader, 34), GetSqlValue(reader, 35), GetSqlValue(reader, 36), GetSqlValue(reader, 37), GetSqlValue(reader, 38), GetSqlValue(reader, 39), GetSqlValue(reader, 40), GetSqlValue(reader, 41), GetSqlValue(reader, 42));
			}
		}

		private string GetInsertSql4Private(OleDbDataReader reader, int importItemId) {
			var pattern = "INSERT INTO ImportPrivate (ImportItemId, OrgName, OrgName2, ProductName, ProductType, LoanMonths, ZongHeShouXinEDu, DangerLevel, RepaymentMethod, CustomerName, CurrencyType, ContractStartDate, ContractEndDate, InterestRatio, DanBaoFangShi, LoanBalance, Direction1, Direction2, Direction3, Direction4, CapitalOverdueDays, InterestOverdueDays, OweInterestAmount, OverdueBalance, NonAccrualBalance) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24})";
			return string.Format(pattern, importItemId, GetSqlValue(reader, 0), GetSqlValue(reader, 1), GetSqlValue(reader, 2), GetSqlValue(reader, 3), GetSqlValue(reader, 4), GetSqlValue(reader, 5), GetSqlValue(reader, 6), GetSqlValue(reader, 7), GetSqlValue(reader, 8), GetSqlValue(reader, 9), GetSqlValue(reader, 10), GetSqlValue(reader, 11), GetSqlValue(reader, 12), GetSqlValue(reader, 13), GetSqlValue(reader, 14), GetSqlValue(reader, 15), GetSqlValue(reader, 16), GetSqlValue(reader, 17), GetSqlValue(reader, 18), GetSqlValue(reader, 19), GetSqlValue(reader, 20), GetSqlValue(reader, 21), GetSqlValue(reader, 22), GetSqlValue(reader, 23));
		}

		private string GetInsertSql4NonAccrual(OleDbDataReader reader, int importItemId) {
			var pattern = "INSERT INTO ImportNonAccrual (ImportItemId, OrgName, CustomerName, LoanBalance, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, InterestOverdueDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, LoanAccount, CustomerNo) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16})";
			return string.Format(pattern, importItemId, GetSqlValue(reader, 0), GetSqlValue(reader, 1), GetSqlValue(reader, 2), GetSqlValue(reader, 3), GetSqlValue(reader, 4), GetSqlValue(reader, 5), GetSqlValue(reader, 6), GetSqlValue(reader, 7), GetSqlValue(reader, 8), GetSqlValue(reader, 9), GetSqlValue(reader, 10), GetSqlValue(reader, 11), GetSqlValue(reader, 12), GetSqlValue(reader, 13), GetSqlValue(reader, 14), GetSqlValue(reader, 15));
		}

		private string GetInsertSql4Overdue(OleDbDataReader reader, int importItemId) {
			var pattern = "INSERT INTO ImportOverdue (ImportItemId, OrgName, CustomerName, LoanAccount, CustomerNo, LoanType, LoanStartDate, LoanEndDate, CapitalOverdueBalance, InterestBalance, DanBaoFangShi) VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10})";
			return string.Format(pattern, importItemId, GetSqlValue(reader, 0), GetSqlValue(reader, 1), GetSqlValue(reader, 2), GetSqlValue(reader, 3), GetSqlValue(reader, 4), GetSqlValue(reader, 5), GetSqlValue(reader, 6), GetSqlValue(reader, 7), GetSqlValue(reader, 8), GetSqlValue(reader, 9));
		}

		public string GetValue(OleDbDataReader reader, int column) {
			object val = reader[column];
			var s = string.Empty;
			if (val != DBNull.Value) {
				s = val.ToString().Trim();
			}
			return s;
		}

		public string GetSqlValue(OleDbDataReader reader, int column) {
			object val = reader[column];
			var s = string.Empty;
			if (val != DBNull.Value) {
				s = val.ToString().Trim().Replace("'", "''");
			}
			return "'" + s + "'";
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

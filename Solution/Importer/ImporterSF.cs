using System;
using System.Collections.Generic;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class ImporterSF : Importer
	{
		private Logger logger = Logger.GetLogger("ImporterSF");

		public ImporterSF() {
			targetFileNames.AddRange(new string[] { "LoanSF.xls", "WJFLSF.xls" });
		}

		public override string CreateImport(DateTime asOfDate, string[] sourceFiles) {
			var result = base.CreateImport(asOfDate, sourceFiles);
			if (string.IsNullOrEmpty(result)) {
				var importId = GetImportId(asOfDate);
				var importFolder = GetImportFolder(importId);
				result = ImportLoanSF(importId, importFolder, sourceFiles[(int)XEnum.ImportItemType.LoanSF]);
				if (!String.IsNullOrEmpty(result)) {
					return result;
				}
			}
			return result;
		}

		private string ImportLoanSF(int importId, string importFolder, string sourceFilePath) {
			logger.Debug("Importing LoanSF data");
			var done = CopyItem(importId, importFolder, sourceFilePath, XEnum.ImportItemType.LoanSF);
			if (!done) {
				logger.Debug("Source file not provided");
				return ""; // Do nothing if user hasn't select a file for this table
			}

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.LoanSF];
			var excelColumns = "[机构号码], [贷款科目], [贷款帐号], [客户名称], [客户编号], [客户类型], [币种], [贷款总额], [本金余额], [拖欠本金], [拖欠应收利息], [拖欠催收利息], [借据编号], [放款日期], [到期日期], [置换/转让], [核销标志], [贷款状态], [贷款种类], [贷款种类说明], [贷款用途], [转列逾期], [转列非应计日期], [利息计至日], [利率种类], [利率加减符号], [利率加减码], [逾期利率依据方式], [逾期利率种类], [逾期利率加减符号], [逾期利率加减码], [利率依据方式], [合同最初计息利率], [合同最初逾期利率], [扣款账号]";
			var dbColumns = "OrgNo, LoanCatalog, LoanAccount, CustomerName, CustomerNo, CustomerType, CurrencyType, LoanAmount, CapitalAmount, OweCapital, OweYingShouInterest, OweCuiShouInterest, DueBillNo, LoanStartDate, LoanEndDate, ZhiHuanZhuanRang, HeXiaoFlag, LoanState, LoanType, LoanTypeName, Direction, ZhuanLieYuQi, ZhuanLieFYJ, InterestEndDate, LiLvType, LiLvSymbol, LiLvJiaJianMa, YuQiLiLvYiJu, YuQiLiLvType, YuQiLiLvSymbol, YuQiLiLvJiaJianMa, LiLvYiJu, ContractInterestRatio, ContractOverdueInterestRate, ChargeAccount";
			var result = ImportTable(importId, targetFilePath, XEnum.ImportItemType.LoanSF, excelColumns, dbColumns);
			if (!string.IsNullOrEmpty(result)) {
				return result;
			}

			logger.Debug("Assigning OrgId to LoanSF");
			var dao = new SqlDbHelper();
			var sql = string.Format("UPDATE ImportLoanSF SET OrgId = dbo.sfGetOrgId(OrgNo) WHERE ImportId = {0}", importId);
			var count = dao.ExecuteNonQuery(sql);
			logger.DebugFormat("Done. {0} rows affected", count);

			return "";
		}

		protected override string GetImportWhereSql(XEnum.ImportItemType itemType) {
			if (itemType == XEnum.ImportItemType.LoanSF) {
				return "WHERE [贷款状态] <> '结清'";
			}
			else {
				return base.GetImportWhereSql(itemType);
			}
		}

		private string ImportWjflSF(int importId, string importFolder) {
			logger.Debug("Importing WjflSF data");

			// Import to database
			string targetFilePath = importFolder + "\\Processed\\" + targetFileNames[(int)XEnum.ImportItemType.WjflSF];
			var table = SourceTable.GetById(XEnum.ImportItemType.WjflSF);
			for (int sheetIndex = 1; sheetIndex <= table.Sheets.Count; sheetIndex++) {
				var excelColumns = "[行名], [客户名称], [贷款余额], [违约金额], [七级分类], [欠息金额], [放款日期], [到期日期], [逾期天数], [欠息天数], [担保方式], [行业], [客户类型], [贷款类型], [是否本月新增], [备注]";
				var dbColumns = "OrgName, CustomerName, CapitalAmount, OweCapital, DangerLevel, OweInterestAmount, LoanStartDate, LoanEndDate, OverdueDays, OweInterestDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, [Comment]";
				if (sheetIndex > 1) {
					excelColumns = excelColumns.Replace(", [违约金额]", "");
					dbColumns = dbColumns.Replace(", OweCapital", "");
				}
				var result = ImportTable(importId, targetFilePath, XEnum.ImportItemType.WjflSF, excelColumns, dbColumns, "WjflType", sheetIndex, sheetIndex);
				if (!String.IsNullOrEmpty(result)) {
					return result;
				}
			}
			logger.Debug("Importing WjflSF done");

			logger.Debug("Assigning OrgId to WjflSF");
			var dao = new SqlDbHelper();
			var sql = string.Format("UPDATE ImportWjflSF SET OrgId = dbo.sfGetOrgId(OrgName) WHERE ImportId = {0}", importId);
			var count = dao.ExecuteNonQuery(sql);
			logger.DebugFormat("Done. {0} rows affected", count);

			return "";
		}

		private string CreateImportItem(int importId, string sourceFilePath) {
			logger.Debug("Updating ImportItem table");
			int itemTypeId = (int)XEnum.ImportItemType.WjflSF;
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
			return string.Empty;
		}

		public override string UpdateWJFL(DateTime asOfDate, string sourceFilePath) {
			logger.DebugFormat("Updating WJFL for {0}", asOfDate.ToString("yyyy-MM-dd"));
			var result = string.Empty;

			if (!File.Exists(sourceFilePath)) {
				result = "风险贷款情况表的初表修订结果在这个路径下没找到：\r\n" + sourceFilePath;
				logger.Error(result);
				return result;
			}

			var dao = new SqlDbHelper();
			var dateString = asOfDate.ToString("yyyyMMdd");
			logger.DebugFormat("Getting existing import id for {0}", dateString);

			var import = Import.GetByDate(asOfDate);
			if (import == null || !import.Items.Exists(x => x.ItemType == XEnum.ImportItemType.LoanSF)) {
				result = string.Format("神府{0}的《贷款欠款查询》数据还没导入系统，请先导入这项数据。", asOfDate.ToString("yyyy年M月d日"));
				logger.Debug(result);
				return result;
			}

			var importFolder = System.Environment.CurrentDirectory + "\\Import\\" + import.Id.ToString();
			var targetFileName = "WJFLSF.xls";

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

			File.Copy(sourceFilePath, targetFilePath, true);
			result = ExcelHelper.ProcessWJFLSF(targetFilePath);
			if (!string.IsNullOrEmpty(result)) {
				return result;
			}

			result = CreateImportItem(import.Id, sourceFilePath);
			if (!string.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			result = ImportWjflSF(import.Id, importFolder);
			if (!string.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			logger.Debug("Updating WJFL to LoanSF");
			var sql = new StringBuilder(); //"SELECT Id, OrgId, CustomerName, CapitalAmount, LoanStartDate, LoanEndDate, DangerLevel FROM ImportWjflSF WHERE ImportId = {0} AND WjflType = {1}";
			sql.AppendLine("UPDATE L SET DangerLevel = W.DangerLevel");
			sql.AppendLine("FROM ImportLoanSF L");
			sql.AppendLine("	INNER JOIN ImportWjflSF W ON L.ImportId = W.ImportId");
			sql.AppendLine("		AND L.CustomerName = W.CustomerName");
			//sql.AppendLine("		AND L.CapitalAmount = W.CapitalAmount");
			sql.AppendLine("		AND L.LoanStartDate = W.LoanStartDate");
			sql.AppendLine("		AND L.LoanEndDate = W.LoanEndDate");
			sql.AppendLine("WHERE L.ImportId = {0} AND ISNULL(L.DangerLevel, '') != ISNULL(W.DangerLevel, '')");
			sql.AppendLine("	AND W.WjflType = {1}");

			logger.Debug("Updating from No Accrual sheet");
			var count = dao.ExecuteNonQuery(string.Format(sql.ToString(), import.Id, (int)XEnum.WjflSheetSF.FYJ));
			logger.DebugFormat("Done. {0} rows affected", count);

			logger.Debug("Updating from Overdue sheet");
			count = dao.ExecuteNonQuery(string.Format(sql.ToString(), import.Id, (int)XEnum.WjflSheetSF.YQ));
			logger.DebugFormat("Done. {0} rows affected", count);

			logger.Debug("Updating from ZQX sheet");
			count = dao.ExecuteNonQuery(string.Format(sql.ToString(), import.Id, (int)XEnum.WjflSheetSF.ZQX));
			logger.DebugFormat("Done. {0} rows affected", count);

			logger.Debug("Assigning LoanAccount to ImportWjflSF");
			sql.Clear();
			sql.AppendLine("UPDATE W SET LoanAccount = L.LoanAccount");
			sql.AppendLine("FROM ImportWjflSF W");
			sql.AppendLine("	INNER JOIN ImportLoanSF L ON W.ImportId = L.ImportId");
			sql.AppendLine("		AND W.OrgId = L.OrgId");
			sql.AppendLine("		AND W.CustomerName = L.CustomerName");
			sql.AppendLine("		AND W.CapitalAmount = L.CapitalAmount");
			sql.AppendLine("		AND W.LoanStartDate = L.LoanStartDate");
			sql.AppendLine("		AND W.LoanEndDate = L.LoanEndDate");
			sql.AppendLine("WHERE W.ImportId = {0} AND W.LoanAccount IS NULL");
			count = dao.ExecuteNonQuery(string.Format(sql.ToString(), import.Id));
			logger.DebugFormat("Done. {0} rows affected", count);

			return result;
		}
	}
}

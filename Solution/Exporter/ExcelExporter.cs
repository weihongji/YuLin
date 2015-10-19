using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Configuration;
using Microsoft.Office.Interop.Excel;

using DataAccess;
using Entities;
using Logging;
using Helper;

namespace Exporter
{
	public class ExcelExporter
	{
		public DateTime AsOfDate { get; set; }

		private static readonly int NonAccrualColumnCount = 15;
		private Logger logger = Logger.GetLogger("ExcelExporter");

		public ExcelExporter(DateTime asOfDate) {
			this.AsOfDate = asOfDate;
		}

		public string ExportData() {
			logger.Debug("");
			var report = TargetTable.GetById(XEnum.ReportType.LoanRiskPerMonth);
			var sheets = report.Sheets;
			var filePath = InitReportFile();
			foreach (var sheet in sheets) {
				populateSheet(filePath, sheet);
			}
			return string.Empty;
		}

		private void populateSheet(string filePath, TargetTableSheet sheet) {
			ExcelHelper.CreateDataSheet(filePath, sheet);

			var oleConn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			oleConn.Open();
			var reader = GetReader();
			int dataRowIndex = 0;
			while (reader.Read()) {
				if (string.IsNullOrWhiteSpace(DataUtility.GetValue(reader, 0))) { // Going to end
					break;
				}
				dataRowIndex++;
				var sql = GetInsertSql4LoanRiskPerMonth_FYJ(reader);
				try {
					OleDbCommand cmd = new OleDbCommand(sql, oleConn);
					cmd.ExecuteNonQuery();
				}
				catch (Exception ex) {
					logger.ErrorFormat("Running INSERT {0}:\r\n{1}", dataRowIndex, sql.ToString());
					logger.Error(ex);
					throw ex;
				}
			}
			oleConn.Close();
			logger.DebugFormat("{0} records exported.", dataRowIndex);

			ExcelHelper.FormatReport4LoanRiskPerMonth_FYJ(filePath, sheet, dataRowIndex, this.AsOfDate);
		}

		private string GetInsertSql4LoanRiskPerMonth_FYJ(SqlDataReader reader) {
			var sql = new StringBuilder();
			sql.AppendLine("INSERT INTO [非应计$] ([行名], [客户名称], [贷款余额], [七级分类], [欠息金额], [放款日期], [到期日期], [逾期天数], [欠息天数], [担保方式], [行业], [客户类型], [贷款类型], [是否本月新增], [备注])");
			sql.AppendLine("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}");
			return string.Format(sql.ToString(), DataUtility.GetSqlValue(reader, 0), DataUtility.GetSqlValue(reader, 1), DataUtility.GetSqlValue(reader, 2), DataUtility.GetSqlValue(reader, 3), DataUtility.GetSqlValue(reader, 4), DataUtility.GetSqlValue(reader, 5), DataUtility.GetSqlValue(reader, 6), DataUtility.GetSqlValue(reader, 7), DataUtility.GetSqlValue(reader, 8), DataUtility.GetSqlValue(reader, 9), DataUtility.GetSqlValue(reader, 10), DataUtility.GetSqlValue(reader, 11), DataUtility.GetSqlValue(reader, 12), DataUtility.GetSqlValue(reader, 13), DataUtility.GetSqlValue(reader, 14));
		}

		public SqlDataReader GetReader() {
			var sql = new StringBuilder();
			sql.AppendLine("SELECT OrgName, CustomerName, LoanBalance, DangerLevel, OweInterestAmount,  CONVERT(VARCHAR(8), LoanStartDate, 112), CONVERT(VARCHAR(8), LoanEndDate, 112), OverdueDays, InterestOverdueDays, DanBaoFangShi, Industry, CustomerType, LoanType, IsNew, LoanState");
			sql.AppendLine("FROM ReportLoanRiskPerMonthFYJ");
			sql.AppendLine("WHERE ImportId = (SELECT Id FROM Import WHERE ImportDate = '" + this.AsOfDate.ToString("yyyyMMdd") + "')");
			var dao = new SqlDbHelper();
			var reader = dao.ExecuteReader(sql.ToString());
			return reader;
		}

		public static string GetReportFolder() {
			var dir = (ConfigurationManager.AppSettings["ReportDirectory"] ?? "").Trim().Replace("/", @"\");
			if (dir.IndexOf(':') > 0) { // full path
				return dir;
			}

			// Get full path
			if (dir.IndexOf('\\') == 0) {
				dir = dir.Substring(1);
			}
			if (dir.Length == 0) {
				dir = "Report";
			}
			return System.Environment.CurrentDirectory + "\\" + dir;
		}

		private string InitReportFile() {
			var template = @"Template\榆林分行月末风险贷款情况表.xls";

			var reportFolder = GetReportFolder();
			if (!Directory.Exists(reportFolder)) {
				Directory.CreateDirectory(reportFolder);
			}
			var report = string.Format(@"{0}\榆林分行{1}月末风险贷款情况表.xls", reportFolder, this.AsOfDate.Month);
			if (File.Exists(template)) {
				File.Copy(template, report, true);
			}
			else {
				throw new FileNotFoundException("Excel template directory doesn't exist.");
			}
			return report;
		}
	}
}

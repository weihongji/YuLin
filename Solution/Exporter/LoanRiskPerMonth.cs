using System;
using System.Collections.Generic;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.Office.Interop.Excel;

using DataAccess;
using Entities;
using Helper;

namespace Exporter
{
	public class LoanRiskPerMonth : BaseReport
	{
		public LoanRiskPerMonth(DateTime asOfDate):base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = string.Format("榆林分行{0}月末风险贷款情况表.xls", this.AsOfDate.Month);
			Logger.Debug("Generating " + fileName);

			var report = TargetTable.GetById(XEnum.ReportType.LoanRiskPerMonth);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			foreach (var sheet in report.Sheets) {
				PopulateSheet(filePath, sheet);
			}

			ExcelHelper.ActivateSheet(filePath);

			return string.Empty;
		}

		private void PopulateSheet(string filePath, TargetTableSheet sheet) {
			Logger.Debug("Initializing sheet " + sheet.Name);
			ExcelHelper.InitSheet(filePath, sheet);

			var oleConn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			Logger.Debug("Openning connction to " + filePath);
			oleConn.Open();
			var sql = string.Format("EXEC spReportLoanRiskPerMonth{0} '{1}'", GetSheetSuffix(sheet), this.AsOfDate.ToString("yyyyMMdd"));
			var dao = new SqlDbHelper();
			Logger.Debug("Running " + sql);
			var reader = dao.ExecuteReader(sql);

			int rowCount = 0;
			while (reader.Read()) {
				rowCount++;
				sql = GetInsertSql(reader, sheet);
				try {
					OleDbCommand cmd = new OleDbCommand(sql, oleConn);
					cmd.ExecuteNonQuery();
				}
				catch (Exception ex) {
					Logger.ErrorFormat("Error while inserting row #{0}:\r\n{1}", rowCount, sql);
					Logger.Error(ex);
					throw ex;
				}
			}
			oleConn.Close();
			Logger.DebugFormat("{0} records exported.", rowCount);

			ExcelHelper.FormatReport4LoanRiskPerMonth(filePath, sheet, rowCount, this.AsOfDate);
		}

		private string GetSheetSuffix(TargetTableSheet sheet) {
			var suffix = "";
			switch (sheet.Index) {
				case 1:
					suffix = "FYJ";
					break;
				case 2:
					suffix = "BLDK";
					break;
				case 3:
					suffix = "YQ";
					break;
				case 4:
					suffix = "ZQX";
					break;
				case 5:
					suffix = "GZDK";
					break;
				default:
					Logger.Error("Unknown sheet index: " + sheet.Index.ToString());
					throw new Exception("Unknown sheet index: " + sheet.Index.ToString());
			}
			return suffix;
		}

		private string GetInsertSql(SqlDataReader reader, TargetTableSheet sheet) {
			Logger.Debug("Building INSERT statement");
			var fields = new StringBuilder();
			var values = new StringBuilder();
			fields.AppendFormat("[{0}]", sheet.Columns[0].Name);
			values.Append(DataUtility.GetSqlValue(reader, 0));
			for (int i = 1; i < sheet.Columns.Count; i++) {
				fields.AppendFormat(", [{0}]", sheet.Columns[i].Name);
				values.Append(", " + DataUtility.GetSqlValue(reader, i));
			}

			var sql = new StringBuilder();
			sql.AppendLine(string.Format("INSERT INTO [{0}$] ({1})", sheet.Name, fields.ToString()));
			sql.AppendLine(string.Format("SELECT {0}", values.ToString()));
			return sql.ToString();
		}
	}
}

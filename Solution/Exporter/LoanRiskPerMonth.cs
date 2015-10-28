using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class LoanRiskPerMonth : BaseReport
	{
		public LoanRiskPerMonth(DateTime asOfDate):base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var import = Import.GetByDate(this.AsOfDate);
			if (import == null) {
				var msg = string.Format("{0}的数据还没导入系统", this.AsOfDate.ToString("yyyy年M月d日"));
				Logger.Debug(msg);
				return msg;
			}
			var fileName = string.Format("榆林分行{0}月末风险贷款情况表 - {1}.xls", this.AsOfDate.Month, import.WJFLSubmitDate == null ? "初" : "终");
			Logger.Debug("Generating " + fileName);

			var report = TargetTable.GetById(XEnum.ReportType.X_WJFL_M);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			foreach (var sheet in report.Sheets) {
				if (sheet.Name.Equals("累收累增")) {
					PopulateSheetVS(filePath, sheet);
				}
				else {
					PopulateSheet(filePath, sheet);
				}
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
			var sql = string.Format("EXEC spReportLoanRiskPerMonth '{0}', '{1}'", GetSheetSuffix(sheet), this.AsOfDate.ToString("yyyyMMdd"));
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

		private string PopulateSheetVS(string filePath, TargetTableSheet sheet) {
			var result = "";
			var dao = new SqlDbHelper();
			var sql = string.Format("EXEC spX_WJFL_M_vs '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			Logger.Debug("Running " + sql);
			var table = dao.ExecuteDataTable(sql);
			result = ExcelHelper.PopulateX_WJFL_M_VS(filePath, sheet, this.AsOfDate, table);
			return result;
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

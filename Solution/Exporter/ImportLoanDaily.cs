using System;
using System.Collections.Generic;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class ImportLoanDaily : BaseReport
	{
		private XEnum.ReportType ReportType;
		private string ReportFileName;
		private string SPName;
		private string DbColumnNames;
		private List<TableMapping> Columns;
		private DateTime AsOfDate2 { get; set; }

		public ImportLoanDaily(XEnum.ReportType report, DateTime asOfDate, DateTime asOfDate2, List<TableMapping> columns)
			: base(asOfDate) {

			this.ReportType = report;
			this.AsOfDate2 = asOfDate2;
			Columns = new List<TableMapping>(columns);
			this.DbColumnNames = string.Join(", ", this.Columns.Select(x => x.ColName));
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			if (this.ReportType == XEnum.ReportType.C_XZDKMX_D) {
				this.ReportFileName = "新增贷款明细表.xls";
				this.SPName = "spC_XZDKMX_D";
			}
			else if (this.ReportType == XEnum.ReportType.C_JQDKMX_D) {
				this.ReportFileName = "结清贷款明细表.xls";
				this.SPName = "spC_JQDKMX_D";
			}
			else {
				var msg = "Unknown Import loan daily report type: " + this.ReportType.ToString();
				Logger.Error(msg);
				return msg;
			}

			var fileName = this.ReportFileName;
			Logger.Debug("Generating " + fileName);
			Logger.Debug("Selected columns Loan: " + string.Join(", ", this.DbColumnNames));

			var report = TargetTable.GetById(this.ReportType);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			foreach (var sheet in report.Sheets) {
				PopulateSheet(filePath, sheet);
			}
			ExcelHelper.ActivateSheet(filePath);

			return string.Empty;
		}

		private void PopulateSheet(string filePath, TargetTableSheet sheet) {
			Logger.Debug("Initializing sheet " + sheet.EvaluateName(this.AsOfDate));

			var columnNames = this.Columns.Select(x => x.MappingName).ToList();
			ExcelHelper.InitSheet(filePath, sheet, columnNames);
			Logger.Debug("Openning connction to " + filePath);
			var oleConn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			oleConn.Open();

			var sql = string.Format("EXEC {0} '{1}', '{2}', '{3}', '{4}'", this.SPName, GetSheetSuffix(sheet), this.AsOfDate.ToString("yyyyMMdd"), this.AsOfDate2.ToString("yyyyMMdd"), DbColumnNames);
			var dao = new SqlDbHelper();
			Logger.Debug("Running: " + sql);
			var reader = dao.ExecuteReader(sql);
			int rowCount = 0;
			while (reader.Read()) {
				rowCount++;
				sql = GetInsertSql(reader, sheet, columnNames);
				try {
					OleDbCommand cmd = new OleDbCommand(sql, oleConn);
					cmd.ExecuteNonQuery();
				}
				catch (Exception ex) {
					Logger.ErrorFormat("Error while inserting row #{0}:\r\n{1}", rowCount, sql);
					Logger.Error(ex);
					oleConn.Close();
					throw ex;
				}
			}
			oleConn.Close();
			Logger.DebugFormat("{0} records exported.", rowCount);

			ExcelHelper.FinalizeSheet(filePath, sheet, rowCount, this.AsOfDate, this.AsOfDate2);
		}

		private string GetInsertSql(SqlDataReader reader, TargetTableSheet sheet, List<string> cols) {
			var fields = new StringBuilder();
			var values = new StringBuilder();
			fields.AppendFormat("[{0}]", cols[0]);
			values.Append(DataUtility.GetSqlValue(reader, 0));
			for (int i = 1; i < cols.Count; i++) {
				fields.AppendFormat(", [{0}]", cols[i]);
				values.Append(", " + DataUtility.GetSqlValue(reader, i));
			}

			var sql = new StringBuilder();
			sql.AppendLine(string.Format("INSERT INTO [{0}$] ({1})", sheet.Name, fields.ToString()));
			sql.AppendLine(string.Format("SELECT {0}", values.ToString()));
			return sql.ToString();
		}

		private string GetSheetSuffix(TargetTableSheet sheet) {
			var suffix = "";
			switch (sheet.Index) {
				case 1:
					suffix = "FYJ";
					break;
				case 2:
					suffix = "YQ";
					break;
				case 3:
					suffix = "ZQX";
					break;
				default:
					Logger.Error("Unknown sheet index: " + sheet.Index.ToString());
					throw new Exception("Unknown sheet index: " + sheet.Index.ToString());
			}
			return suffix;
		}
	}
}

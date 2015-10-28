using System;
using System.Collections.Generic;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class C_DQDJQK_M : BaseReport
	{
		private string PublicColumns;
		private string PrivateColumns;

		public C_DQDJQK_M(DateTime asOfDate, List<string> publicColumns, List<string> privateColumns)
			: base(asOfDate) {
			PublicColumns = string.Join(",", publicColumns);
			PrivateColumns = string.Join(",", privateColumns);
		}
		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = string.Format("{0}月到期贷款情况.xls", this.AsOfDate.ToString("M.dd"));
			Logger.Debug("Generating " + fileName);
			Logger.Debug("Selected columns Public: " + string.Join(", ", this.PublicColumns));
			Logger.Debug("Selected columns Private: " + string.Join(", ", this.PrivateColumns));

			var report = TargetTable.GetById(XEnum.ReportType.C_DQDJQK_M);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			foreach (var sheet in report.Sheets) {
				PopulateSheet(filePath, sheet);
			}
			ExcelHelper.ActivateSheet(filePath);

			return string.Empty;
		}
		private void PopulateSheet(string filePath, TargetTableSheet sheet) {
			Logger.Debug("Initializing sheet " + sheet.EvaluateName(this.AsOfDate));

			var sql = string.Format("EXEC spDQDKQK_M '{0}', '{1}', '{2}'", this.AsOfDate.ToString("yyyyMMdd")
				, sheet.Index == 1 ? "ImportPublic" : "ImportPrivate"
				, sheet.Index == 1 ? PublicColumns : PrivateColumns);
			var dao = new SqlDbHelper();
			Logger.Debug("Running: " + sql);
			var reader = dao.ExecuteReader(sql);
			var columnNames = new List<string>();
			for (int i = 0; i < reader.FieldCount; i++) {
				columnNames.Add(reader.GetName(i));
			}
			int rowCount = 0;

			ExcelHelper.InitSheet(filePath, sheet, columnNames);
			Logger.Debug("Openning connction to " + filePath);
			var oleConn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");

			oleConn.Open();
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

			ExcelHelper.FormatReport4LoanRiskPerMonth(filePath, sheet, rowCount, this.AsOfDate);
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
	}
}

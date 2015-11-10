using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class X_ZXQYZJXQ_S : BaseReport
	{
		public X_ZXQYZJXQ_S(DateTime asOfDate):base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = "中小企业资金需求及银行业支持情况报表.xls";
			Logger.Debug("Generating " + fileName);

			var report = TargetTable.GetById(XEnum.ReportType.X_ZXQYZJXQ_S);
			var filePath = CreateReportFile(report.TemplateName, fileName);
			PopulateSheet(filePath, report.Sheets[0]);

			return string.Empty;
		}

		private void PopulateSheet(string filePath, TargetTableSheet sheet) {
			Logger.Debug("Initializing sheet " + sheet.Name);
			ExcelHelper.InitSheet(filePath, sheet);

			var oleConn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			Logger.Debug("Openning connction to " + filePath);
			oleConn.Open();
			var sql = string.Format("EXEC spX_ZXQYZJXQ_S '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
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

			ExcelHelper.FinalizeSheet(filePath, sheet, rowCount, this.AsOfDate);
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

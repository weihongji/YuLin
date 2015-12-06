using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class X_FXDKBH_D : BaseReport
	{

		public X_FXDKBH_D(DateTime asOfDate)
			: base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = "风险贷款变化情况表.xls";
			Logger.Debug("Generating " + fileName);

			// Check YWNei import
			var dao = new SqlDbHelper();
			var sql = string.Format("SELECT COUNT(*) FROM ImportYWNei WHERE ImportId = (SELECT Id FROM Import I WHERE I.ImportDate = '{0}') AND OrgId < 100", this.AsOfDate.ToString("yyyyMMdd"));
			var count = (int)dao.ExecuteScalar(sql);
			if (count == 0) {
				Logger.Error("支行业务状况表还没导入");
				return string.Format("导入各支行{0}的业务状况表（表内）之后才能导出此报表。", this.AsOfDate.ToString("yyyy-M-d"));
			}

			var report = TargetTable.GetById(XEnum.ReportType.X_FXDKBH_D);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			foreach (var sheet in report.Sheets) {
				PopulateSheet(filePath, sheet);
			}

			return string.Empty;
		}

		private void PopulateSheet(string filePath, TargetTableSheet sheet) {
			Logger.Debug("Initializing sheet " + sheet.EvaluateName(this.AsOfDate));
			ExcelHelper.InitSheet(filePath, sheet);

			var oleConn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			Logger.Debug("Openning connction to " + filePath);
			oleConn.Open();
			var sql = string.Format("EXEC spX_FXDKBH_D '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
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
					oleConn.Close();
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

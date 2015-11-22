using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class X_CSHSX_M : BaseReport
	{

		public X_CSHSX_M(DateTime asOfDate)
			: base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = string.Format("城商行榆林地区{0}月授信情况统计表.xls", this.AsOfDate.Month);
			Logger.Debug("Generating " + fileName);
			var report = TargetTable.GetById(XEnum.ReportType.X_CSHSX_M);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			var result = string.Empty;
			foreach (var sheet in report.Sheets) {
				switch (sheet.Index) {
					case 1:
						result = PopulateSheet1(filePath, sheet);
						break;
					case 2:
						result = PopulateSheet2(filePath, sheet);
						break;
					case 3:
						PopulateSheet3(filePath, sheet);
						break;
					case 4:
						result = PopulateSheet4(filePath, sheet);
						break;
					default:
						break;
				}

				if (!string.IsNullOrEmpty(result)) {
					break;
				}
			}

			ExcelHelper.ActivateSheet(filePath);

			return result;
		}

		private string PopulateSheet1(string filePath, TargetTableSheet sheet) {
			var result = "";
			var dao = new SqlDbHelper();
			var sql = string.Format("EXEC spX_CSHSX_M_1 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			Logger.Debug("Running " + sql);
			var table = dao.ExecuteDataTable(sql);
			if (table != null) {
				result = ExcelHelper.PopulateX_CSHSX_M_1(filePath, sheet, this.AsOfDate, table);
			}
			else {
				result = "Procedure returned zero rows";
			}
			return result;
		}

		private string PopulateSheet2(string filePath, TargetTableSheet sheet) {
			var result = "";
			var dao = new SqlDbHelper();
			var sql = string.Format("EXEC spX_CSHSX_M_2 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			Logger.Debug("Running " + sql);
			var table = dao.ExecuteDataTable(sql);
			if (table != null) {
				result = ExcelHelper.PopulateX_CSHSX_M_2(filePath, sheet, this.AsOfDate, table);
			}
			else {
				result = "Procedure returned zero rows";
			}
			return result;
		}

		private void PopulateSheet3(string filePath, TargetTableSheet sheet) {
			Logger.Debug("Initializing sheet " + sheet.EvaluateName(this.AsOfDate));
			ExcelHelper.InitSheet(filePath, sheet);

			var oleConn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			Logger.Debug("Openning connction to " + filePath);
			oleConn.Open();
			var sql = string.Format("EXEC spX_CSHSX_M_3 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
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
				if (i == 8) {
					values.Append(", '" + GetDates(reader[i].ToString()) + "'");
				}
				else {
					values.Append(", " + DataUtility.GetSqlValue(reader, i));
				}
			}

			var sql = new StringBuilder();
			sql.AppendLine(string.Format("INSERT INTO [{0}$] ({1})", sheet.Name, fields.ToString()));
			sql.AppendLine(string.Format("SELECT {0}", values.ToString()));
			return sql.ToString();
		}

		private string GetDates(string dates) {
			var result = "";
			DateTime date1, date2;
			var pieces = dates.Split('|');
			if (pieces != null && pieces.Length == 2) {
				if (DateTime.TryParse(pieces[0], out date1) && DateTime.TryParse(pieces[1], out date2)) {
					result = string.Format("{0}至{1}", date1.ToString("yyyy年MM月dd日"), date2.ToString("yyyy年MM月dd日"));
				}
			}
			return result;
		}

		private string PopulateSheet4(string filePath, TargetTableSheet sheet) {
			var result = "";
			var dao = new SqlDbHelper();
			var sql = string.Format("EXEC spX_CSHSX_M_4 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			Logger.Debug("Running " + sql);
			var table = dao.ExecuteDataTable(sql);
			if (table != null) {
				result = ExcelHelper.PopulateX_CSHSX_M_4(filePath, sheet, this.AsOfDate, table);
			}
			else {
				result = "Procedure returned zero rows";
			}
			return result;
		}
	}
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class X_BLDKJC_X : BaseReport
	{
		public X_BLDKJC_X(DateTime asOfDate):base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = string.Format("{0}新榆林地区不良贷款监测旬报（旬报）.xls", this.AsOfDate.ToString("M.dd"));
			Logger.Debug("Generating " + fileName);

			var report = TargetTable.GetById(XEnum.ReportType.X_BLDKJC_X);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			foreach (var sheet in report.Sheets) {
				if (sheet.Name.Equals("附表1")) {
					PopulateSheet1(filePath, sheet);
				}
				else if (sheet.Name.Equals("附表2")) {
					PopulateSheet2(filePath, sheet);
				}
				else if (sheet.Name.Equals("附表3")) {
					PopulateSheet3(filePath, sheet);
				}
			}

			ExcelHelper.ActivateSheet(filePath);

			return string.Empty;
		}

		private string PopulateSheet1(string filePath, TargetTableSheet sheet) {
			var result = "";
			var dao = new SqlDbHelper();
			var sql = string.Format("EXEC spX_BLDKJC_X_1 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			Logger.Debug("Running " + sql);
			var table = dao.ExecuteDataTable(sql);
			result = ExcelHelper.PopulateX_BLDKJC_X_1(filePath, sheet, this.AsOfDate, table);
			return result;
		}

		private string PopulateSheet2(string filePath, TargetTableSheet sheet) {
			var result = "";
			var dao = new SqlDbHelper();
			var sql = string.Format("EXEC spX_BLDKJC_X_2 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			Logger.Debug("Running " + sql);
			var table = dao.ExecuteDataTable(sql);
			result = ExcelHelper.PopulateX_BLDKJC_X_2(filePath, sheet, this.AsOfDate, table);
			return result;
		}

		private string PopulateSheet3(string filePath, TargetTableSheet sheet) {
			var result = "";
			var dao = new SqlDbHelper();
			var sql = string.Format("EXEC spX_BLDKJC_X_3 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			Logger.Debug("Running " + sql);
			var table = dao.ExecuteDataTable(sql);
			result = ExcelHelper.PopulateX_BLDKJC_X_3(filePath, sheet, this.AsOfDate, table);
			return result;
		}
	}
}

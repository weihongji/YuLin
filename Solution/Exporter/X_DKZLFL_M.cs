using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class X_DKZLFL_M : BaseReport
	{

		public X_DKZLFL_M(DateTime asOfDate)
			: base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = string.Format("{0}贷款质量分类情况汇总表.xls", this.AsOfDate.ToString("yyyy年M月"));
			Logger.Debug("Generating " + fileName);
			var report = TargetTable.GetById(XEnum.ReportType.X_DKZLFL_M);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			var sql = string.Format("EXEC spX_DKZLFL_M '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			var dao = new SqlDbHelper();
			Logger.Debug("Running " + sql);
			var table = dao.ExecuteDataTable(sql);
			var result = ExcelHelper.PopulateX_DKZLFL_M(filePath, report.Sheets[0], this.AsOfDate, table);

			return result;
		}
	}
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class GF0107_141 : BaseReport
	{

		public GF0107_141(DateTime asOfDate)
			: base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = "GF0107-141-境内汇总数据-月-人民币.xls";
			Logger.Debug("Generating " + fileName);
			var report = TargetTable.GetById(XEnum.ReportType.F_GF0107_141_M);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			var sql = string.Format("EXEC spGF0107_141 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			var dao = new SqlDbHelper();
			Logger.Debug("Running " + sql);
			var result = "";
			var table = dao.ExecuteDataTable(sql);
			if (table != null) {
				result = ExcelHelper.PopulateGF0107_141(filePath, report.Sheets[0], this.AsOfDate, table);
			}
			else {
				result = "Procedure returned zero rows";
			}
			return result;
		}
	}
}

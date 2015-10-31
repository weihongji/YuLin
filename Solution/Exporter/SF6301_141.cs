using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class SF6301_141 : BaseReport
	{

		public SF6301_141(DateTime asOfDate)
			: base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var result = "";
			var fileName = "SF6301-141-境内汇总数据-月-人民币.xls";
			Logger.Debug("Generating " + fileName);
			var report = TargetTable.GetById(XEnum.ReportType.F_SF6301_141_M);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			var sql = string.Format("EXEC spSF6301_141 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			var dao = new SqlDbHelper();
			Logger.Debug("Running " + sql);
			var table1 = dao.ExecuteDataTable(sql);
			sql = string.Format("EXEC spSF6301_141_Count '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			Logger.Debug("Running " + sql);
			var table2 = dao.ExecuteDataTable(sql);
			if (table1 != null && table2 != null) {
				result = ExcelHelper.PopulateSF6301_141(filePath, report.Sheets[0], this.AsOfDate, table1, table2);
			}
			else {
				result = "Procedure returned zero rows";
			}
			return result;
		}
	}
}

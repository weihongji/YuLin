using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class GF0102_161 : BaseReport
	{

		public GF0102_161(DateTime asOfDate)
			: base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = "GF0102-161-境内汇总数据-月-人民币.xls";
			Logger.Debug("Generating " + fileName);
			var report = TargetTable.GetById(XEnum.ReportType.F_GF0102_161_M);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			var sql = string.Format("EXEC spGF0102_161 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			var dao = new SqlDbHelper();
			Logger.Debug("Running " + sql);
			var result = "";
			var reader = dao.ExecuteReader(sql);
			if (reader.Read()) {
				result = ExcelHelper.PopulateGF0102_161(filePath, report.Sheets[0], this.AsOfDate, (decimal)reader[0], (decimal)reader[1], (decimal)reader[2], (decimal)reader[3], (decimal)reader[4], (decimal)reader[5]);
			}
			else {
				result = "Procedure returned zero rows";
			}
			return result;
		}
	}
}

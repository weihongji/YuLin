﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class GF1301_081 : BaseReport
	{

		public GF1301_081(DateTime asOfDate)
			: base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = "GF1301-081-境内汇总数据-季-人民币.xls";
			Logger.Debug("Generating " + fileName);
			var report = TargetTable.GetById(XEnum.ReportType.F_GF1301_081_S);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			var sql = string.Format("EXEC spGF1301_081 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			var dao = new SqlDbHelper();
			Logger.Debug("Running " + sql);
			var result = "";
			var table = dao.ExecuteDataTable(sql);
			if (table != null) {
				result = ExcelHelper.PopulateGF1301_081(filePath, report.Sheets[0], this.AsOfDate, table);
			}
			else {
				result = "Procedure returned zero rows";
			}
			return result;
		}
	}
}

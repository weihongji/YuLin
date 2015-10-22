﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;
using System.Data.SqlClient;

namespace Reporting
{
	public class GF0102_081 : BaseReport
	{

		public GF0102_081(DateTime asOfDate)
			: base(asOfDate) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}

		public override string GenerateReport() {
			var fileName = "GF0102-081-境内汇总数据-月-人民币.xls";
			Logger.Debug("Generating " + fileName);
			var report = TargetTable.GetById(XEnum.ReportType.FM_GF0102_081);
			var filePath = CreateReportFile(report.TemplateName, fileName);

			var sql = string.Format("EXEC spGF0102_081 '{0}'", this.AsOfDate.ToString("yyyyMMdd"));
			var dao = new SqlDbHelper();
			Logger.Debug("Running " + sql);
			var result = "";
			var reader = dao.ExecuteReader(sql);
			if (reader.Read()) {
				result = ExcelHelper.PopulateGF0102_081(filePath, report.Sheets[0], this.AsOfDate, (decimal)reader[0], (decimal)reader[1], (decimal)reader[2], (decimal)reader[3], (decimal)reader[4]);
			}
			else {
				result = "Procedure returned zero rows";
			}
			return result;
		}
	}
}

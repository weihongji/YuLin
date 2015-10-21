using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using Microsoft.Office.Interop.Excel;

namespace Reporting
{
	public class ExcelExporter
	{
		private Logger logger = Logger.GetLogger("Exporter.ExcelExporter");

		public ExcelExporter() {
		}

		public string ExportData(XEnum.ReportType report, DateTime asOfDate) {
			var result = string.Empty;
			switch (report) {
				case XEnum.ReportType.X_WJFL:
					result = new LoanRiskPerMonth(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_HYB:
					result = new LoanRiskPerMonthHYB(asOfDate).GenerateReport();
					break;
				default:
					result = "Unknown report type: " + report;
					break;
			} return result;
		}
	}
}

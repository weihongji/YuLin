using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using Microsoft.Office.Interop.Excel;

namespace Reporting
{
	public class Exporter
	{
		private Logger logger = Logger.GetLogger("Exporter.ExcelExporter");

		public Exporter() {
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
				case XEnum.ReportType.FM_GF0102_081:
					result = new GF0102_081(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.FM_GF0107_141:
					result = new GF0107_141(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.FM_SF6301_141:
					result = new SF6301_141(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.FM_SF6401_141:
					result = new SF6401_141(asOfDate).GenerateReport();
                    break;
                case XEnum.ReportType.X_FXDKTB:
                    result = new X_FXDKTB(asOfDate).GenerateReport();
                    break;
				default:
					result = "Unknown report type: " + report;
					break;
			} return result;
		}
	}
}

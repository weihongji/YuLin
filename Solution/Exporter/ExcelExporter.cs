using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using Microsoft.Office.Interop.Excel;

using Entities;
using Logging;

namespace Exporter
{
	public class ExcelExporter
	{
		private Logger logger = Logger.GetLogger("Exporter.ExcelExporter");

		public ExcelExporter() {
		}

		public string ExportData(List<XEnum.ReportType> reportTypes, DateTime asOfDate) {
			var result = string.Empty;
			foreach (var type in reportTypes) {
				switch (type) {
					case XEnum.ReportType.LoanRiskPerMonth:
						result = new LoanRiskPerMonth(asOfDate).GenerateReport();
						break;
					default:
						result = "Unknown report type: " + type;
						break;
				}
				if (result.Length > 0) {
					break;
				}
			}
			return result;
		}
	}
}

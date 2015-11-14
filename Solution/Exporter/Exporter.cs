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

		public DateTime AsOfDate { get; set; }
		public DateTime AsOfDate2 { get; set; }
		public List<TableMapping> Columns { get; set; }
		public List<TableMapping> Columns2 { get; set; }

		public Exporter() {
		}

		public string ExportData(XEnum.ReportType report, DateTime asOfDate) {
			return ExportData(report, asOfDate, new DateTime(1900, 1, 1), null, null);
		}

		public string ExportData(XEnum.ReportType report, DateTime asOfDate, List<string> columnNames) {
			return ExportData(report, asOfDate, new DateTime(1900, 1, 1), columnNames, null);
		}

		public string ExportData(XEnum.ReportType report, DateTime asOfDate, DateTime asOfDate2, List<string> columnNames, List<string> columnNames2) {
			this.AsOfDate = asOfDate;

			var dao = new SqlDbHelper();
			var countobject = dao.ExecuteScalar(string.Format("SELECT State FROM Import WHERE ImportDate = '{0}'", asOfDate.ToString("yyyyMMdd")));
			if (countobject == null) {
				return string.Format("{0}的数据还没导入系统", asOfDate.ToString("M月d日"));
			}

			var result = string.Empty;
			switch (report) {
				case XEnum.ReportType.X_WJFL_M:
					result = new LoanRiskPerMonth(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_HYB_M:
					result = new LoanRiskPerMonthHYB(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_GF0102_081_M:
					result = new GF0102_081(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_GF0107_141_M:
					result = new GF0107_141(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_SF6301_141_M:
					result = new SF6301_141(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_SF6401_141_M:
					result = new SF6401_141(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.X_FXDKTB_D:
					result = new X_FXDKTB_D(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.X_FXDKBH_D:
					result = new X_FXDKBH_D(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.C_DQDKQK_M:
					result = new C_DQDKQK_M(asOfDate, columnNames, columnNames2).GenerateReport();
					break;
				case XEnum.ReportType.C_XZDKMX_D:
					result = new C_XZDKMX_D(this.AsOfDate, this.AsOfDate2, Columns).GenerateReport();
					break;
				case XEnum.ReportType.C_JQDKMX_D:
					result = new C_JQDKMX_D(this.AsOfDate, this.AsOfDate2, Columns).GenerateReport();
					break;
				case XEnum.ReportType.X_ZXQYZJXQ_S:
					result = new X_ZXQYZJXQ_S(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.X_DKZLFL_M:
					result = new X_DKZLFL_M(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_GF1101_121_S:
					result = new GF1101_121(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_GF1301_081_S:
					result = new GF1301_081(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_GF1302_081_S:
					result = new GF1302_081(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_GF1303_081_S:
					result = new GF1303_081(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.F_GF1304_081_S:
					result = new GF1304_081(asOfDate).GenerateReport();
					break;
				default:
					result = "Unknown report type: " + report;
					break;
			} return result;
		}
	}
}

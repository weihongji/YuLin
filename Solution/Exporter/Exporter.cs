﻿using System;
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
			return ExportData(report, asOfDate, null, null);
		}

		public string ExportData(XEnum.ReportType report, DateTime asOfDate, List<string> columnNames) {
			return ExportData(report, asOfDate, columnNames, null);
		}

		public string ExportData(XEnum.ReportType report, DateTime asOfDate, List<string> columnNames, List<string> columnNames2) {
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
					result = new X_FXDKTB(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.R_WJFL_M:
					result = new R_DKQKCX_D(asOfDate).GenerateReport();
					break;
				case XEnum.ReportType.C_DQDJQK_M:
					result = new C_DQDJQK_M(asOfDate, columnNames, columnNames2).GenerateReport();
					break;
				default:
					result = "Unknown report type: " + report;
					break;
			} return result;
		}
	}
}
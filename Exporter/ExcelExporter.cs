using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Configuration;
using Microsoft.Office.Interop.Excel;

using DataAccess;
using Entities;

namespace Exporter
{
	public class ExcelExporter
	{
		private readonly int NonAccrualColumnCount = 15;

		public DateTime AsOfDate { get; set; }

		public ExcelExporter(DateTime asOfDate) {
			this.AsOfDate = asOfDate;
		}

		public string ExportData() {
			OutExcel();
			return string.Empty;
		}

		private string GetReportFolder() {
			var dir = (ConfigurationManager.AppSettings["ReportDirectory"] ?? "").Trim().Replace("/", @"\");
			if (dir.IndexOf(':') > 0) { // full path
				return dir;
			}

			// Get full path
			if (dir.IndexOf('\\') == 0) {
				dir = dir.Substring(1);
			}
			if (dir.Length == 0) {
				dir = "Report";
			}
			return System.Environment.CurrentDirectory + "\\" + dir;
		}

		private string GetReportFile() {
			var template = @"Template\榆林分行月末风险贷款情况表.xls";

			var reportFolder = GetReportFolder();
			if (!Directory.Exists(reportFolder)) {
				Directory.CreateDirectory(reportFolder);
			}
			var report = string.Format(@"{0}\榆林分行{1}月末风险贷款情况表.xls", reportFolder, this.AsOfDate.Month);
			if (File.Exists(template)) {
				File.Copy(template, report, true);
			}
			else {
				throw new FileNotFoundException("Excel template directory doesn't exist.");
			}
			return report;
		}

		private void OutExcel() {
			var filePath = GetReportFile();
			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = theExcelApp.Workbooks.Open(filePath);
			Worksheet theSheet = (Worksheet)theExcelBook.ActiveSheet;
			var reader = GetReader();
			for (int i = 4; reader.Read(); i++) {
				for (int j = 0; j < NonAccrualColumnCount; j++) {
					((Range)theSheet.Cells[i, j + 1]).Value2 = reader[j];
				}
			}

			/*****************************将生成的Excel报表存储到Export文件夹中*****************************/
			theExcelBook.Save();
			theExcelBook.Close(false, null, null);
			theExcelApp.Quit();
			System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheet);
			System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
			System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
			GC.Collect();
		}

		public SqlDataReader GetReader() {
			var sql = new StringBuilder();
			sql.AppendLine("DECLARE @importId as int");
			sql.AppendLine("SELECT @importId = Id FROM Import WHERE ImportDate = '" + this.AsOfDate.ToString("yyyyMMdd") + "'");
			sql.AppendLine("DECLARE @monthLastDay as smalldatetime = '" + this.AsOfDate.ToString("yyyyMMdd") + "'");
			sql.AppendLine("SELECT O.Alias1, L.CustomerName, L.CapitalAmount, 'xxx' AS DangerLevel");
			sql.AppendLine("	, OweInterestAmount = OweYingShouInterest + OweCuiShouInterest");
			sql.AppendLine("	, L.LoanStartDate, L.LoanEndDate");
			sql.AppendLine("	, OverdueDays = CASE WHEN L.LoanEndDate < @monthLastDay THEN DATEDIFF(day, L.LoanEndDate, @monthLastDay) ELSE 0 END");
			sql.AppendLine("	, OweInterestDays = CASE WHEN L.CustomerType = '对私' THEN PV.InterestOverdueDays ELSE PB.OweInterestDays END");
			sql.AppendLine("	, DanBaoFangShi = ISNULL(NA.DanBaoFangShi, OD.DanBaoFangShi)");
			sql.AppendLine("	, Industry = ISNULL(PV.Direction1, PB.Direction1)");
			sql.AppendLine("	, CustomerType = ISNULL(PV.ProductName, PB.MyBankIndTypeName)");
			sql.AppendLine("	, LoanType = L.LoanTypeName");
			sql.AppendLine("	, IsNew = 'xxx'");
			sql.AppendLine("	, Comment = L.LoanState");
			sql.AppendLine("FROM ImportLoan L");
			sql.AppendLine("	LEFT JOIN Org O ON L.OrgNo = O.Number");
			sql.AppendLine("	LEFT JOIN ImportPrivate PV ON PV.CustomerName = L.CustomerName AND PV.ContractStartDate = L.LoanStartDate AND PV.ContractEndDate = L.LoanEndDate AND PV.OrgNo = L.OrgNo AND PV.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = {1})");
			sql.AppendLine("	LEFT JOIN ImportPublic PB ON PB.FContractNo = L.LoanAccount AND PB.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = {2})");
			sql.AppendLine("	LEFT JOIN ImportNonAccrual NA ON L.LoanAccount = NA.LoanAccount AND NA.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = {3})");
			sql.AppendLine("	LEFT JOIN ImportOverdue OD ON L.LoanAccount = OD.LoanAccount AND OD.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = {4})");
			sql.AppendLine("WHERE LoanState = '非应计' AND L.ImportItemId = (SELECT Id FROM ImportItem WHERE ImportId = @importId AND ItemType = {0})");
			//sql.AppendLine("	AND L.CustomerName = '李世平'");
			sql.AppendLine("ORDER BY L.Id");
			var dao = new SqlDbHelper();
			var reader = dao.ExecuteReader(string.Format(sql.ToString(), (int)XEnum.ImportItemType.Loan, (int)XEnum.ImportItemType.Private, (int)XEnum.ImportItemType.Public, (int)XEnum.ImportItemType.NonAccrual, (int)XEnum.ImportItemType.Overdue));
			return reader;
		}
	}
}

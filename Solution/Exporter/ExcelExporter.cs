using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Configuration;
using Microsoft.Office.Interop.Excel;

using DataAccess;
using Entities;
using Logging;

namespace Exporter
{
	public class ExcelExporter
	{
		private static readonly int NonAccrualColumnCount = 15;
		private Logger logger = Logger.GetLogger("Importer");

		public DateTime AsOfDate { get; set; }

		public ExcelExporter(DateTime asOfDate) {
			this.AsOfDate = asOfDate;
		}

		public string ExportData() {
			OutExcelx();
			return string.Empty;
		}
		public static void TestInsertRow2() {
			Microsoft.Office.Interop.Excel.Application excelApp = new Microsoft.Office.Interop.Excel.Application();
			excelApp.DisplayAlerts = false;

			string workbookPath = @"E:\Project\2015\YuLin\Git\Solution\WinForm\bin\Report\a.xls";

			Microsoft.Office.Interop.Excel.Workbook excelWorkbook = excelApp.Workbooks.Open(workbookPath,
					0, false, 5, "", "", false, Microsoft.Office.Interop.Excel.XlPlatform.xlWindows, "",
					true, false, 0, true, false, false);

			Microsoft.Office.Interop.Excel.Sheets worksheets = excelWorkbook.Worksheets;

			worksheets[1].Delete();

			worksheets[1].Name = "Total Monthly";

			excelWorkbook.Save();

			excelWorkbook.Close();

			System.Runtime.InteropServices.Marshal.ReleaseComObject(worksheets);

			excelApp.Quit();
		}

		public static void TestInsertRow() {
			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			theExcelApp.DisplayAlerts = false;

			bool excelOpened = false;
			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			Worksheet theSheetTemplate = null;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(@"E:\Project\2015\YuLin\Git\Solution\WinForm\bin\Report\a.xls");
				excelOpened = true;

				theSheet = (Worksheet)theExcelBook.Worksheets[1];
				theSheet.Delete();

				//Range oRange;
				//theSheet = (Worksheet)theExcelBook.Sheets[1];
				//oRange = (Range)theSheet.get_Range("1:3");
				//oRange.Delete();
				////((Range)theSheet.Cells[1, 1]).Select();

				//theSheet = (Worksheet)theExcelBook.Sheets[3];
				//oRange = (Range)theSheet.get_Range("1:3");
				//oRange.Delete();


				//int sheetCount = theExcelBook.Sheets.Count;
				//for (int i = sheetCount; i >= 1; i--) {
				//	theSheet = (Worksheet)theExcelBook.Sheets[i];
				//	theSheet.Copy(Type.Missing, theSheet);
				//	((Worksheet)theExcelBook.Sheets[i + 1]).Name = theSheet.Name + "Template";
				//}

				//Range r = theSheet.get_Range("A1", "C10"); //theSheet.get_Range("A1", "A1").EntireRow;
				//r.Insert(Microsoft.Office.Interop.Excel.XlInsertShiftDirection.xlShiftDown);
				//((Range)theSheet.Cells[1, 1]).Value2 = "xxx";

				//int startrow = 1;
				//var oRange = (Range)theSheet.get_Range(String.Format("{0}:{0}", startrow), System.Type.Missing);
				//oRange.Select();
				//oRange.Copy();
				////oApp.Selection.Copy();

				//oRange = theSheet.get_Range(String.Format("{0}:{1}", startrow + 1, startrow + 6 - 1), System.Type.Missing);
				//oRange.Select();
				//oRange.Insert();
				//((Range)theSheet.Cells[1, 1]).Select();

				//theSheetTemplate.Activate();
				//var oRange = (Range)theSheetTemplate.get_Range("1:3");
				//oRange.Select();
				//oRange.Copy();

				//theSheet.Activate();
				//oRange = theSheet.get_Range("1:1");
				//oRange.Select();
				//oRange.Insert();
				//((Range)theSheet.Cells[1, 1]).Select();



				/*****************************将生成的Excel报表存储到Export文件夹中*****************************/
			}
			catch (Exception ex) {
				//SHOULD BE REMOVED SINCE DUPLICATE WITH finally BLOCK
				//SHOULD BE REMOVED SINCE DUPLICATE WITH finally BLOCK
				//SHOULD BE REMOVED SINCE DUPLICATE WITH finally BLOCK
				//SHOULD BE REMOVED SINCE DUPLICATE WITH finally BLOCK
				//SHOULD BE REMOVED SINCE DUPLICATE WITH finally BLOCK
				if (excelOpened) {
					theExcelBook.Save();
					theExcelBook.Close(false, null, null);
					theExcelApp.Quit();
					if (theSheet != null) {
						System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheet);
					}
					if (theSheetTemplate != null) {
						System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheetTemplate);
					}
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
					GC.Collect();
				}
				throw ex;
			}
			finally {
				if (excelOpened) {
					theExcelBook.Save();
					theExcelBook.Close(false, null, null);
					theExcelApp.Quit();
					if (theSheet != null) {
						System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheet);
					}
					if (theSheetTemplate != null) {
						System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheetTemplate);
					}
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
					GC.Collect();
				}
			}
		}

		private void OutExcel() {
			var filePath = InitReportFile();
			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = theExcelApp.Workbooks.Open(filePath);
			Worksheet theSheet = (Worksheet)theExcelBook.ActiveSheet;
			var reader = GetReader();
			int i;
			decimal totalLoanBalance = 0, totalOweInterest = 0, tmp_decimal;
			for (i = 4; reader.Read(); i++) {
				for (int j = 0; j < NonAccrualColumnCount; j++) {
					((Range)theSheet.Cells[i, j + 1]).Value2 = reader[j];
				}
				if (decimal.TryParse(reader[2].ToString(), out tmp_decimal)) {
					totalLoanBalance += tmp_decimal;
				}
				if (decimal.TryParse(reader[4].ToString(), out tmp_decimal)) {
					totalOweInterest += tmp_decimal;
				}
			}

			//Totals
			if (i > 4) { // At least one row of data
				((Range)theSheet.Cells[i, 1]).Value2 = "合计";
				((Range)theSheet.Cells[i, 1]).HorizontalAlignment = XlHAlign.xlHAlignCenter;

				((Range)theSheet.Cells[i, 3]).Value2 = totalLoanBalance;
				((Range)theSheet.Cells[i, 5]).Value2 = totalOweInterest;
			}

			//绘制数据部分的表格线
			if (i > 4) { // At least one row of data
				theSheet.Range[theSheet.Cells[4, 1], theSheet.Cells[i, NonAccrualColumnCount]].Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
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

		private void OutExcelx() {
			var filePath = InitReportFile();
			int rowsBeforeColumnHeader = 2;
			CreateDataSheet(filePath, 1, rowsBeforeColumnHeader);

			var oleConn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=Excel 8.0");
			oleConn.Open();
			decimal totalLoanBalance = 0, totalOweInterest = 0, tmp_decimal;
			var reader = GetReader();
			int dataRowIndex = 0;
			while (reader.Read()) {
				if (string.IsNullOrWhiteSpace(DataUtility.GetValue(reader, 0))) { // Going to end
					break;
				}
				dataRowIndex++;
				var sql = GetInsertSql4LoanRiskPerMonth_FYJ(reader);
				try {
					OleDbCommand cmd = new OleDbCommand(sql, oleConn);
					cmd.ExecuteNonQuery();
				}
				catch (Exception ex) {
					logger.Error("Running INSERT: " + sql.ToString(), ex);
					throw ex;
				}
				// Calculate totals
				if (decimal.TryParse(reader[2].ToString(), out tmp_decimal)) {
					totalLoanBalance += tmp_decimal;
				}
				if (decimal.TryParse(reader[4].ToString(), out tmp_decimal)) {
					totalOweInterest += tmp_decimal;
				}
			}
			oleConn.Close();
			logger.DebugFormat("{0} records exported.", dataRowIndex);

			FormatReport4LoanRiskPerMonth_FYJ(filePath, dataRowIndex, totalLoanBalance, totalOweInterest);
		}

		private void FormatReport4LoanRiskPerMonth_FYJ(string filePath, int dataRowCount, decimal totalLoanBalance, decimal totalOweInterest) {
			if (dataRowCount == 0) {
				return;
			}
			int sheetIndex = 1;
			int rowsBeforeColumnHeader = 2;
			int rowsBeforeData = rowsBeforeColumnHeader + 1;

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			theExcelApp.DisplayAlerts = false; // Without this line, the template sheet cannot be deleted.
			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			Worksheet theSheetTemplate = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				theSheet = (Worksheet)theExcelBook.Sheets[sheetIndex];
				theSheetTemplate = (Worksheet)theExcelBook.Sheets[sheetIndex + 1];

				//Header
				theSheetTemplate.Activate();
				var oRange = (Range)theSheetTemplate.get_Range("1:" + rowsBeforeColumnHeader.ToString());
				oRange.Select();
				oRange.Copy();

				theSheet.Activate();
				oRange = theSheet.get_Range("1:1");
				oRange.Select();
				oRange.Insert();

				//Totals
				int totalRowIndex = rowsBeforeData + dataRowCount + 1;
				((Range)theSheet.Cells[totalRowIndex, 1]).Value2 = "合计";
				((Range)theSheet.Cells[totalRowIndex, 1]).HorizontalAlignment = XlHAlign.xlHAlignCenter;
				((Range)theSheet.Cells[totalRowIndex, 3]).Value2 = totalLoanBalance;
				((Range)theSheet.Cells[totalRowIndex, 5]).Value2 = totalOweInterest;

				//绘制数据部分的表格线
				int dataRowStartIndex = rowsBeforeData + 1;
				Range dataRange = theSheet.Range[theSheet.Cells[dataRowStartIndex, 1], theSheet.Cells[totalRowIndex, NonAccrualColumnCount]];
				dataRange.Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
				dataRange.Font.Size = 10;

				theSheetTemplate.Delete();

				theExcelBook.Save();
			}
			catch (Exception ex) {
				logger.Error(ex);
				throw;
			}
			finally {
				if (excelOpened) {
					theExcelBook.Close(false, null, null);
				}
				theExcelApp.Quit();
				if (theSheet != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheet);
				}
				if (theSheetTemplate != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheetTemplate);
				}
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
		}

		private string GetInsertSql4LoanRiskPerMonth_FYJ(SqlDataReader reader) {
			var sql = new StringBuilder();
			sql.AppendLine("INSERT INTO [非应计$] ([行名], [客户名称], [贷款余额], [七级分类], [欠息金额], [放款日期], [到期日期], [逾期天数], [欠息天数], [担保方式], [行业], [客户类型], [贷款类型], [是否本月新增], [备注])");
			sql.AppendLine("SELECT {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}");
			return string.Format(sql.ToString(), DataUtility.GetSqlValue(reader, 0), DataUtility.GetSqlValue(reader, 1), DataUtility.GetSqlValue(reader, 2), DataUtility.GetSqlValue(reader, 3), DataUtility.GetSqlValue(reader, 4), DataUtility.GetSqlValue(reader, 5), DataUtility.GetSqlValue(reader, 6), DataUtility.GetSqlValue(reader, 7), DataUtility.GetSqlValue(reader, 8), DataUtility.GetSqlValue(reader, 9), DataUtility.GetSqlValue(reader, 10), DataUtility.GetSqlValue(reader, 11), DataUtility.GetSqlValue(reader, 12), DataUtility.GetSqlValue(reader, 13), DataUtility.GetSqlValue(reader, 14));
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

		public static string GetReportFolder() {
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

		private string InitReportFile() {
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

		private void CreateDataSheet(string filePath, int sheetIndex, int rowsBeforeColumnHeader) {
			if (rowsBeforeColumnHeader == 0) {
				return;
			}
			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			Worksheet theSheetTemplate = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				theSheet = (Worksheet)theExcelBook.Sheets[sheetIndex];
				theSheet.Copy(Type.Missing, theSheet);
				((Worksheet)theExcelBook.Sheets[sheetIndex + 1]).Name = theSheet.Name + "Template";

				// Make the column header row as the first row
				var range = (Range)theSheet.get_Range("1:" + rowsBeforeColumnHeader.ToString());
				range.Delete();

				theExcelBook.Save();
			}
			finally {
				if (excelOpened) {
					theExcelBook.Close(false, null, null);
				}
				theExcelApp.Quit();
				if (theSheet != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheet);
				}
				if (theSheetTemplate != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theSheetTemplate);
				}
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
		}
	}
}

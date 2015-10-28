using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Microsoft.Office.Interop.Excel;

namespace Reporting
{
	public class ExcelHelper
	{
		private static Logger logger = Logger.GetLogger("ExcelHelper");

		public static void ProcessCopiedItem(string filePath, XEnum.ImportItemType itemType) {
			logger.Debug("Removing rows about column header row for " + filePath.Substring(filePath.LastIndexOf('\\') + 1));
			var table = SourceTable.GetById((int)itemType);
			var sheets = table.Sheets;
			if (sheets.All(x => x.RowsBeforeHeader == 0)) {
				logger.Debug("No sheet need to remove rows");
				return;
			}

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			theExcelApp.DisplayAlerts = false;

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				foreach (var sheetEntity in sheets) {
					if (sheetEntity.RowsBeforeHeader == 0) {
						continue;
					}
					theSheet = (Worksheet)theExcelBook.Sheets[sheetEntity.Index];
					theSheet.Activate();
					var range = (Range)theSheet.get_Range("1:" + sheetEntity.RowsBeforeHeader.ToString());
					range.Select();
					logger.DebugFormat("Removing {0} rows from sheet: {1}", sheetEntity.RowsBeforeHeader, theSheet.Name);
					range.Delete(XlDeleteShiftDirection.xlShiftUp);

					if (itemType == XEnum.ImportItemType.Private) {
						int direction = 0;
						for (int i = 1; i < 100; i++) {
							var cell = ((Range)theSheet.Cells[1, i]);
							string val = cell.Value2;
							if (string.IsNullOrEmpty(val)) {
								break;
							}
							else if (val.Equals("贷款发放后投向")) {
								cell.Value2 = val + (++direction).ToString();
							}
						}
					}

					if (itemType == XEnum.ImportItemType.YWNei || itemType == XEnum.ImportItemType.YWWai) {
						logger.DebugFormat("Fixing column headers for {0}", theSheet.Name);
						((Range)theSheet.Cells[1, 1]).Value2 = "科目代号";
						((Range)theSheet.Cells[1, 2]).Value2 = "科目名称";
					}
				}

				theExcelBook.Save();
				logger.Debug("Remove done");
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
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
		}

		public static void ProcessWJFL(string filePath) {
			logger.Debug("Removing rows about column header row for " + filePath.Substring(filePath.LastIndexOf('\\') + 1));

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			theExcelApp.DisplayAlerts = false;

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				theSheet = (Worksheet)theExcelBook.Sheets["非应计"];
				theSheet.Activate();
				var range = (Range)theSheet.get_Range("1:2");
				range.Select();
				logger.Debug("Removing rows from sheet 非应计");
				range.Delete(XlDeleteShiftDirection.xlShiftUp);

				theSheet = (Worksheet)theExcelBook.Sheets["逾期"];
				theSheet.Activate();
				range = (Range)theSheet.get_Range("1:2");
				range.Select();
				logger.Debug("Removing rows from sheet 逾期");
				range.Delete(XlDeleteShiftDirection.xlShiftUp);

				theSheet = (Worksheet)theExcelBook.Sheets["只欠息"];
				theSheet.Activate();
				range = (Range)theSheet.get_Range("1:2");
				range.Select();
				logger.Debug("Removing rows from sheet 只欠息");
				range.Delete(XlDeleteShiftDirection.xlShiftUp);

				theExcelBook.Save();
				logger.Debug("Remove done");
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
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
		}

		public static string GetImportDateFromWJFL(string filePath, out DateTime date) {
			logger.Debug("Getting import date from WJFL");

			var result = string.Empty;
			date = new DateTime(1900, 1, 1);

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				theSheet = (Worksheet)theExcelBook.Sheets["非应计"];
				string val = ((Range)theSheet.Cells[1, 1]).Value2;
				if (string.IsNullOrEmpty(val)) {
					result = "在非应计工作表中没有找到标题";
				}
				else if (val.IndexOf("月") < 0) {
					result = "在非应计工作表的标题中没有找到数据日期";
				}
				else {
					var dateString = val.Substring(0, val.IndexOf("月")).Replace("年", "/") + "/1";
					if (DateTime.TryParse(dateString, out date)) {
						date = DateHelper.GetLastDayInMonth(date);
					}
					else {
						result = "在非应计工作表的标题中没有找到正确的数据日期";
					}
				}
				if (result.Length > 0) {
					logger.Debug(result);
				}
				else {
					logger.Debug("Got date: " + date.ToString("yyyy-MM-dd"));
				}
				return result;
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
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
		}

		public static void InitSheet(string filePath, TargetTableSheet sheet) {
			InitSheet(filePath, sheet, null);
		}

		public static void InitSheet(string filePath, TargetTableSheet sheet, List<string> columnNames) {
			if (sheet.RowsBeforeHeader == 0 && sheet.FooterStartRow == 0) {
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

				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];
				theSheet.Copy(Type.Missing, theSheet);
				((Worksheet)theExcelBook.Sheets[sheet.Index + 1]).Name = theSheet.Name + "Template";
				Range range = null;

				// Remove footer
				if (sheet.FooterStartRow > 0) {
					range = (Range)theSheet.get_Range(string.Format("{0}:{1}", sheet.FooterStartRow, sheet.FooterEndRow));
					range.Delete();
				}

				// Make the column header row as the first row
				if (sheet.RowsBeforeHeader > 0) {
					range = (Range)theSheet.get_Range("1:" + sheet.RowsBeforeHeader.ToString());
					range.Delete();
				}
				if (columnNames != null) {
					for (int i = 1; i <= columnNames.Count; i++) {
						theSheet.Cells[1, i] = columnNames[i - 1];
					}
				}
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

		public static void ActivateSheet(string filePath, int sheetIndex = 1) {
			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				theSheet = (Worksheet)theExcelBook.Sheets[sheetIndex];
				theSheet.Activate();
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
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
		}

		public static void FormatReport4LoanRiskPerMonth(string filePath, TargetTableSheet sheet, int dataRowCount, DateTime asOfDate) {
			int sheetIndex = sheet.Index;

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

				bool dummyHeader = false;
				int dummyHeaderRows = 0;
				if (sheet.TableId == (int)XEnum.ReportType.X_FXDKTB_D) {
					dummyHeader = true;
					dummyHeaderRows = 1;
				}

				//Remove data rows left by template
				Range oRange;
				var sampleRows = (sheet.FooterStartRow - 1) - sheet.RowsBeforeHeader - 1; // (sheet.FooterStartRow - 1) is the last sample row if there is
				if (sampleRows > 0) {
					int removeRowFrom = dummyHeader ? 1 : 2;
					int removeRowTo = dummyHeader ? removeRowFrom + sampleRows : removeRowFrom + sampleRows - 1;
					oRange = (Range)theSheet.get_Range(string.Format("{0}:{1}", removeRowFrom, removeRowTo));
					oRange.Delete();
				}

				//Header
				if (sheet.RowsBeforeHeader > 0) {
					theSheetTemplate.Activate();
					oRange = (Range)theSheetTemplate.get_Range("1:" + sheet.RowsBeforeHeader.ToString());
					oRange.Select();
					oRange.Copy();

					theSheet.Activate();
					oRange = theSheet.get_Range("1:1");
					oRange.Select();
					oRange.Insert();
				}

				var columnCount = sheet.Columns.Count;
				for (int i = 1; i <= sheet.RowsBeforeHeader; i++) {
					for (int j = 1; j <= columnCount; j++) {
						var cell = ((Range)theSheet.Cells[i, j]);
						string val = cell.Value2;
						if (!string.IsNullOrWhiteSpace(val)) {
							if (val.IndexOf("year") >= 0) {
								val = val.Replace("year", asOfDate.Year.ToString());
							}
							if (val.IndexOf("month") >= 0) {
								val = val.Replace("month", asOfDate.Month.ToString());
							}
							if (val.IndexOf("day") >= 0) {
								val = val.Replace("day", asOfDate.Day.ToString());
							}
							if (!val.Equals((string)cell.Value2)) {
								cell.Value2 = val;
							}
						}
					}
				}

				//Totals
				int dataRowFrom = sheet.RowsBeforeHeader + 2 - dummyHeaderRows;
				int footerRowFrom = dataRowFrom + dataRowCount;

				if (sheet.TableId == (int)XEnum.ReportType.X_FXDKTB_D) {
					// Copy the footer back
					if (sheet.FooterStartRow > 0) {
						theSheetTemplate.Activate();
						oRange = (Range)theSheetTemplate.get_Range(string.Format("{0}:{1}", sheet.FooterStartRow, sheet.FooterEndRow));
						oRange.Select();
						oRange.Copy();

						theSheet.Activate();
						oRange = theSheet.get_Range(string.Format("{0}:{0}", footerRowFrom));
						oRange.Select();
						oRange.Insert();
					}
				}

				if (sheet.TableId == (int)XEnum.ReportType.X_WJFL_M) {
					((Range)theSheet.Cells[footerRowFrom, 1]).Value2 = "合计";
					((Range)theSheet.Cells[footerRowFrom, 1]).HorizontalAlignment = XlHAlign.xlHAlignCenter;
					if (sheet.Name.Equals("逾期")) {
						((Range)theSheet.Cells[footerRowFrom, 3]).Value2 = string.Format("=SUM(C{0}:C{1})", dataRowFrom, footerRowFrom - 1);
						((Range)theSheet.Cells[footerRowFrom, 4]).Value2 = string.Format("=SUM(D{0}:D{1})", dataRowFrom, footerRowFrom - 1);
						((Range)theSheet.Cells[footerRowFrom, 6]).Value2 = string.Format("=SUM(F{0}:F{1})", dataRowFrom, footerRowFrom - 1);
					}
					else {
						((Range)theSheet.Cells[footerRowFrom, 3]).Value2 = string.Format("=SUM(C{0}:C{1})", dataRowFrom, footerRowFrom - 1);
						((Range)theSheet.Cells[footerRowFrom, 5]).Value2 = string.Format("=SUM(E{0}:E{1})", dataRowFrom, footerRowFrom - 1);
					}
				}
				else if (sheet.TableId == (int)XEnum.ReportType.F_HYB_M) {
					((Range)theSheet.Cells[footerRowFrom, 1]).Value2 = "合计";
					((Range)theSheet.Cells[footerRowFrom, 1]).HorizontalAlignment = XlHAlign.xlHAlignCenter;
					((Range)theSheet.Cells[footerRowFrom, 6]).Value2 = string.Format("=SUM(F{0}:F{1})", dataRowFrom, footerRowFrom - 1);
				}
				else if (sheet.TableId == (int)XEnum.ReportType.X_FXDKTB_D) {
					for (int i = 2; i <= 15; i++) {
						((Range)theSheet.Cells[footerRowFrom, i]).Value2 = string.Format("=SUM({0}{1}:{0}{2})", (char)(64 + i), dataRowFrom, footerRowFrom - 1);
					}

				}

				if (sheet.TableId == (int)XEnum.ReportType.X_WJFL_M || sheet.TableId == (int)XEnum.ReportType.F_HYB_M) {
					//绘制数据部分的表格线
					int dataRowStartIndex = sheet.RowsBeforeHeader + 1 + 1;
					Range dataRange = theSheet.Range[theSheet.Cells[dataRowStartIndex, 1], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
					dataRange.Font.Size = 10;
				}
				else if (sheet.TableId == (int)XEnum.ReportType.X_FXDKTB_D) {
					int dataRowStartIndex = sheet.RowsBeforeHeader + 1 + 1;
					Range dataRange = theSheet.Range[theSheet.Cells[dataRowStartIndex, 1], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.RowHeight = 24;
				}
				else if (sheet.TableId == (int)XEnum.ReportType.C_DQDJQK_M) {
					columnCount = 2;
					while (true) {
						if (string.IsNullOrEmpty(((Range)theSheet.Cells[sheet.RowsBeforeHeader + 1, columnCount]).Value2)) {
							break;
						}
						else {
							columnCount++;
						}
					}
					columnCount--;
					int headerStartIndex = sheet.RowsBeforeHeader + 1;
					Range dataRange = theSheet.Range[theSheet.Cells[headerStartIndex, 1], theSheet.Cells[headerStartIndex, columnCount]];
					dataRange.Interior.Color = System.Drawing.Color.FromArgb(204, 204, 255);
					dataRange = theSheet.Range[theSheet.Cells[headerStartIndex, 1], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
					dataRange.Font.Size = 10;

					((Range)theSheet.Cells[footerRowFrom, 2]).Value2 = "合计";
					((Range)theSheet.Cells[footerRowFrom, 2]).HorizontalAlignment = XlHAlign.xlHAlignCenter;
					if (sheet.Name.Equals("对公已展期")) {
						((Range)theSheet.Cells[footerRowFrom, 6]).Value2 = string.Format("=SUM(F{0}:F{1})", dataRowFrom, footerRowFrom - 1);
					}
					else if (sheet.Name.IndexOf("个人") >= 0) {
						((Range)theSheet.Cells[footerRowFrom, 8]).Value2 = string.Format("=SUM(H{0}:H{1})", dataRowFrom, footerRowFrom - 1);
					}
				}

				SubstituteReportHeader(theSheet, sheet, asOfDate);

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

		public static bool SubstituteReportHeader(Worksheet theSheet, TargetTableSheet sheet, DateTime asOfDate) {
			var changed = false;
			var columnCount = sheet.Columns.Count;
			for (int i = 1; i <= sheet.RowsBeforeHeader; i++) {
				for (int j = 1; j <= columnCount; j++) {
					var cell = ((Range)theSheet.Cells[i, j]);
					string val = cell.Value2;
					if (!string.IsNullOrWhiteSpace(val)) {
						if (val.IndexOf("year") >= 0) {
							val = val.Replace("year", asOfDate.Year.ToString());
						}
						if (val.IndexOf("month") >= 0) {
							val = val.Replace("month", asOfDate.Month.ToString());
						}
						if (val.IndexOf("day") >= 0) {
							val = val.Replace("day", asOfDate.Day.ToString());
						}
						if (!val.Equals((string)cell.Value2)) {
							cell.Value2 = val;
							changed = true;
						}
					}
				}
			}
			return changed;
		}

		public static string PopulateGF0102_081(string filePath, TargetTableSheet sheet, DateTime asOfDate, decimal total, decimal guanZhu, decimal ciJi, decimal keYi, decimal sunShi) {
			logger.Debug("Populating GF0102_081");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];
				((Range)theSheet.Cells[6, 3]).Value2 = total;
				((Range)theSheet.Cells[8, 3]).Value2 = guanZhu;
				((Range)theSheet.Cells[9, 3]).Value2 = ciJi;
				((Range)theSheet.Cells[10, 3]).Value2 = keYi;
				((Range)theSheet.Cells[11, 3]).Value2 = sunShi;

				SubstituteReportHeader(theSheet, sheet, asOfDate);

				theExcelBook.Save();
				logger.Debug("Population done");
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
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
			return string.Empty;
		}

		public static string PopulateGF0107_141(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating GF0107_141");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				// 2.1 - 2.20
				int rowStartAt = 10;
				for (int i = 0; i < 20; i++) {
					((Range)theSheet.Cells[rowStartAt + i, 3]).Value2 = dataTable.Rows[i]["Balance"];
				}
				// 2.21 个人贷款(不含个人经营性贷款)
				rowStartAt = 31;
				for (int i = 0; i < 4; i++) {
					((Range)theSheet.Cells[rowStartAt + i, 3]).Value2 = dataTable.Rows[i + 20]["Balance"];
				}
				// 4. 个人经营性贷款
				((Range)theSheet.Cells[38, 3]).Value2 = dataTable.Rows[24]["Balance"];

				SubstituteReportHeader(theSheet, sheet, asOfDate);

				theExcelBook.Save();
				logger.Debug("Population done");
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
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
			return string.Empty;
		}

		public static string PopulateSF6401_141(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable, System.Data.DataTable dataTable2) {
			logger.Debug("Populating SF6401_141");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				// 1.1 - 1.20
				int rowStartAt = 7;
				for (int i = 0; i < 20; i++) {
					for (int j = 1; j <= 6; j++) {
						((Range)theSheet.Cells[rowStartAt + i, 2 + j]).Value2 = dataTable.Rows[i]["Balance" + j.ToString()];
					}
					((Range)theSheet.Cells[rowStartAt + i, 9]).Value2 = dataTable.Rows[i]["Balance6"];
				}
				// 2. 贷款当年累计发放额
				for (int j = 1; j <= 6; j++) {
					((Range)theSheet.Cells[29, 2 + j]).Value2 = dataTable.Rows[20]["Balance" + j.ToString()];
				}

				// 3. 贷款当年累计发放户数
				// 4. 贷款当年累计申请户数
				for (int j = 1; j <= 6; j++) {
					((Range)theSheet.Cells[30, 2 + j]).Value2 = dataTable2.Rows[0]["Count" + j.ToString()];
					((Range)theSheet.Cells[31, 2 + j]).Value2 = dataTable2.Rows[0]["Count" + j.ToString()];
				}

				SubstituteReportHeader(theSheet, sheet, asOfDate);

				theExcelBook.Save();
				logger.Debug("Population done");
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
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
			return string.Empty;
		}

		public static string PopulateSF6301_141(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating SF6301_141");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int rowStartAt = 6;
				for (int i = 0; i < 26; i++) {
					if ((int)dataTable.Rows[i][1] == 0) {
						continue;
					}
					for (int j = 1; j <= 7; j++) {
						if (dataTable.Rows[i][j + 1] == DBNull.Value) {
							((Range)theSheet.Cells[rowStartAt + i, 2 + j]).Value2 = "0.00";
						}
						else {
							((Range)theSheet.Cells[rowStartAt + i, 2 + j]).Value2 = dataTable.Rows[i][j + 1];
						}
					}
				}

				SubstituteReportHeader(theSheet, sheet, asOfDate);

				theExcelBook.Save();
				logger.Debug("Population done");
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
				if (theExcelBook != null) {
					System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelBook);
				}
				System.Runtime.InteropServices.Marshal.ReleaseComObject(theExcelApp);
				GC.Collect();
			}
			return string.Empty;
		}

		#region tests
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
			//theExcelApp.DisplayAlerts = false;

			bool excelOpened = false;
			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			Worksheet theSheetTemplate = null;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(@"E:\Project\2015\YuLin\Git\Solution\WinForm\bin\Report\a.xls");
				excelOpened = true;

				// Insert column
				theSheet = (Worksheet)theExcelBook.Worksheets[1];
				((Range)theSheet.Columns[3]).Insert();
				for (int i = 1; i <= 2; i++) {
					((Range)theSheet.Cells[i, 3]).Value2 = i.ToString();
				}

				//theSheet = (Worksheet)theExcelBook.Worksheets[1];
				//theSheet.Delete();

				//theSheet = (Worksheet)theExcelBook.Worksheets[1];
				//theSheet.Activate();
				//var range = (Range)theSheet.get_Range("1:2");
				//range.Select();
				//range.Delete(XlDeleteShiftDirection.xlShiftUp);

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
		#endregion
	}
}

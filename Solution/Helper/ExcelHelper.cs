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
			logger.Debug("Processing copied file: " + filePath.Substring(filePath.LastIndexOf('\\') + 1));
			var table = SourceTable.GetById((int)itemType);
			var sheets = table.Sheets;

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			theExcelApp.DisplayAlerts = false;

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				foreach (var sheetEntity in sheets) {
					theSheet = (Worksheet)theExcelBook.Sheets[sheetEntity.Index];
					theSheet.Activate();

					//Remove rows above the column header row
					if (sheetEntity.Id == 1) { // 贷款欠款查询
						if (((Range)theSheet.Cells[1, 1]).Value2 == "机构号码") {
							sheetEntity.RowsBeforeHeader = 0;
						}
					}

					//修改RowsBeforeHeader，以适应变化多端的客户表结构
					if (itemType == XEnum.ImportItemType.Public) {
						for (int i = 1; i <= 5; i++) {
							var cell = ((Range)theSheet.Cells[i, 1]);
							string val = cell.Value2;
							if (val != null && val.Equals("分行名称")) {
								sheetEntity.RowsBeforeHeader = i - 1;
								break;
							}
						}
					}
					if (itemType == XEnum.ImportItemType.Private) {
						for (int i = 1; i <= 5; i++) {
							var cell = ((Range)theSheet.Cells[i, 1]);
							string val = cell.Value2;
							if (val != null && val.Equals("二级分行")) {
								sheetEntity.RowsBeforeHeader = i - 1;
								break;
							}
						}
					}
					if (sheetEntity.RowsBeforeHeader > 0) {
						var range = (Range)theSheet.get_Range("1:" + sheetEntity.RowsBeforeHeader.ToString());
						range.Select();
						logger.DebugFormat("Removing {0} rows from sheet: {1}", sheetEntity.RowsBeforeHeader, theSheet.Name);
						range.Delete(XlDeleteShiftDirection.xlShiftUp);
					}

					// Fix column header names
					if (itemType == XEnum.ImportItemType.Private) {
						logger.DebugFormat("Fixing direction columns headers for {0}", theSheet.Name);
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

					if (itemType == XEnum.ImportItemType.Public) {
						logger.DebugFormat("Fixing direction columns headers for {0}", theSheet.Name);
						var columns = AI_ImportColumn.GetList(itemType);
						var previousBlanks = 0;
						for (int i = 1; i < 100; i++) {
							var cell = ((Range)theSheet.Cells[1, i]);
							string val = cell.Value2;
							if (val != null) {
								val = val.Trim();
							}
							if (string.IsNullOrEmpty(val)) {
								if (previousBlanks > 0) {
									break;
								}
								else {
									previousBlanks++;
									continue;
								}
							}

							previousBlanks = 0;
							if (!columns.Exists(x=>x.Name.Equals(val))) {
								var c = AI_ImportColumn.GetByAlias(itemType, val);
								if (c != null) {
									val = c.Name;
								}
							}
							if (!val.Equals(cell.Value2)) {
								cell.Value2 = val;
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
				logger.Debug("Processing done");
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

		public static string ProcessWJFL(string filePath) {
			logger.Debug("Processing WJFL");
			var result = "";
			var expectedNames = new List<string> { "非应计", "逾期", "只欠息" };
			result = UnifySheetNames(filePath, expectedNames);
			if (!string.IsNullOrEmpty(result)) {
				logger.Error(result);
				return result;
			}

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			theExcelApp.DisplayAlerts = false;

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				logger.Debug("Removing rows about column header row for " + filePath.Substring(filePath.LastIndexOf('\\') + 1));
				foreach (var sheetName in expectedNames) {
					result = UnifyColumnHeader4WJFL(theExcelBook, sheetName);
					if (!string.IsNullOrEmpty(result)) {
						logger.Error(result);
						return result;
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
			return result;
		}

		private static string UnifySheetNames(string filePath, List<string> expectedNames) {
			logger.Debug("Unifying sheet names");
			var result = "";

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			theExcelApp.DisplayAlerts = false;

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			bool changed = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				var actualNames = new List<string>();
				for (int i = 0; i < theExcelBook.Sheets.Count; i++) {
					actualNames.Add(((Worksheet)theExcelBook.Sheets[i + 1]).Name);
				}
				var clonedExpectedNames = expectedNames.Select(x => x).ToList();
				var clonedActualNames = actualNames.Select(x => x).ToList();
				for (int i = clonedExpectedNames.Count - 1; i >= 0; i--) {
					var name = clonedExpectedNames[i];
					if (clonedActualNames.Contains(name)) {
						clonedActualNames.Remove(name);
						clonedExpectedNames.Remove(name);
					}
				}

				// Trim spaces
				if (clonedExpectedNames.Count > 0) {
					for (int i = clonedExpectedNames.Count - 1; i >= 0; i--) {
						var name = clonedExpectedNames[i];
						for (int j = 0; j < clonedActualNames.Count; j++) {
							if (clonedActualNames[j].Trim().Equals(name)) {
								logger.WarnFormat("Triming spaces for \"{0}\" sheet", clonedActualNames[j]);
								var sheet = (Worksheet)theExcelBook.Sheets[1 + actualNames.IndexOf(clonedActualNames[j])];
								if (sheet.Name.Equals(clonedActualNames[j])) {
									sheet.Name = name;
									changed = true;
								}
								clonedActualNames.RemoveAt(j);
								clonedExpectedNames.Remove(name);
							}
						}
					}
				}

				// Check partial matches
				if (clonedExpectedNames.Count > 0) { // One or more expected names are not exactly matched
					for (int i = clonedExpectedNames.Count - 1; i >= 0; i--) {
						var name = clonedExpectedNames[i];
						logger.WarnFormat("Hasn't found {0} sheet. Searching possible ...", name);
						var matches = clonedActualNames.Where(x => x.IndexOf(name) >= 0).ToList();
						if (matches.Count() == 0) {
							logger.Warn("No possible sheet found.");
							result = string.Format("没找到\"{0}\"工作表", name);
							break;
						}
						else if (matches.Count() == 1) {
							clonedActualNames.Remove(matches[0]);
							clonedExpectedNames.Remove(name);
							logger.WarnFormat("Got {0}. Renaming it as {1}", matches[0], name);
							var sheet = (Worksheet)theExcelBook.Sheets[1 + actualNames.IndexOf(matches[0])];
							if (sheet.Name.Equals(matches[0])) {
								sheet.Name = name;
								changed = true;
							}
						}
						else {
							logger.WarnFormat("{0} possible sheets found. Cannot identify the correct one.", matches.Count());
							result = string.Format("{0}个工作表名字带有\"{1}\"字样，无法判断到底哪个是{1}", matches.Count(), name);
							break;
						}
					}
				}

				if (changed) {
					theExcelBook.Save();
					logger.Debug("Saved changes");
				}
				logger.Debug("Unify sheet names done");
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
			return result;
		}

		private static string UnifyColumnHeader4WJFL(Workbook excelBook, string sheetName) {
			logger.DebugFormat("Unifying column headers for sheet {0}", sheetName);
			var theSheet = (Worksheet)excelBook.Sheets[sheetName];
			theSheet.Activate();
			int headerRow = GetColumnHeaderRow(theSheet, "行名", 5);
			var result = "";
			Range range = null;
			if (headerRow == 0) {
				result = "在" + sheetName + "工作表中没有找到列名";
				logger.Error(result);
				return result;
			}
			else if (headerRow > 1) {
				range = (Range)theSheet.get_Range(string.Format("1:{0}", headerRow - 1));
				range.Select();
				logger.Debug("Removing rows from sheet " + sheetName);
				range.Delete(XlDeleteShiftDirection.xlShiftUp);
				logger.Debug("Done");
			}
			int i = 1;
			while (++i < 20) {
				var cell = ((Range)theSheet.Cells[1, i]);
				if (string.IsNullOrEmpty(cell.Value2)) {
					break;
				}
				else if (cell.Value2 == "企业（客户）名称") {
					cell.Value2 = "客户名称";
				}
				else if (cell.Value2 == "发放日") {
					cell.Value2 = "放款日期";
				}
				else if (cell.Value2 == "到期日") {
					cell.Value2 = "到期日期";
				}
				else if (cell.Value2 == "本金余额") {
					cell.Value2 = "贷款余额";
				}
			}
			return result;
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
				logger.DebugFormat("Title in 非应计 sheet: {0}", string.IsNullOrEmpty(val) ? "Empty" : val);
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
				return ex.Message;
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

		#region WJFL SF

		public static string ProcessWJFLSF(string filePath) {
			var result = "";
			logger.Debug("Removing rows about column header row for " + filePath.Substring(filePath.LastIndexOf('\\') + 1));

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			theExcelApp.DisplayAlerts = false;

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				result = UnifyColumnHeader4WJFLSF(theExcelBook, "逾期贷款");
				if (!string.IsNullOrEmpty(result)) {
					logger.Error(result);
					return result;
				}
				result = UnifyColumnHeader4WJFLSF(theExcelBook, "不良贷款");
				if (!string.IsNullOrEmpty(result)) {
					logger.Error(result);
					return result;
				}
				result = UnifyColumnHeader4WJFLSF(theExcelBook, "非应计贷款");
				if (!string.IsNullOrEmpty(result)) {
					logger.Error(result);
					return result;
				}
				result = UnifyColumnHeader4WJFLSF(theExcelBook, "只欠息贷款");
				if (!string.IsNullOrEmpty(result)) {
					logger.Error(result);
					return result;
				}
				result = UnifyColumnHeader4WJFLSF(theExcelBook, "关注类贷款");
				if (!string.IsNullOrEmpty(result)) {
					logger.Error(result);
					return result;
				}

				theExcelBook.Save();
				logger.Debug("Remove done");
			}
			catch (Exception ex) {
				logger.Error(ex);
				return ex.Message;
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
			return result;
		}

		private static string UnifyColumnHeader4WJFLSF(Workbook excelBook, string sheetName) {
			logger.DebugFormat("Unifying column headers for sheet {0}", sheetName);
			var theSheet = (Worksheet)excelBook.Sheets[sheetName];
			theSheet.Activate();
			int headerRow = GetColumnHeaderRow(theSheet, "序号", 5);
			var result = "";
			Range range = null;
			if (headerRow == 0) {
				result = "在\"" + sheetName + "\"工作表中没有找到列名";
				logger.Error(result);
				return result;
			}
			else if (headerRow > 1) {
				range = (Range)theSheet.get_Range(string.Format("1:{0}", headerRow - 1));
				range.Select();
				logger.Debug("Removing rows from sheet " + sheetName);
				range.Delete(XlDeleteShiftDirection.xlShiftUp);
				logger.Debug("Done");
			}
			int i = 1;
			while (++i < 20) {
				var cell = ((Range)theSheet.Cells[1, i]);
				if (string.IsNullOrEmpty(cell.Value2)) {
					break;
				}
				else if (cell.Value2 == "企业（客户）名称") {
					cell.Value2 = "客户名称";
				}
				else if (cell.Value2 == "发放日") {
					cell.Value2 = "放款日期";
				}
				else if (cell.Value2 == "到期日") {
					cell.Value2 = "到期日期";
				}
				else if (cell.Value2 == "本金余额") {
					cell.Value2 = "贷款余额";
				}
			}
			return result;
		}

		public static string GetImportDateFromWJFLSF(string filePath, out DateTime date) {
			logger.Debug("Getting import date from WJFL SF");

			var result = string.Empty;
			date = new DateTime(1900, 1, 1);

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;

				theSheet = (Worksheet)theExcelBook.Sheets["非应计贷款"];
				string val = ((Range)theSheet.Cells[1, 2]).Value2;
				logger.DebugFormat("Title in 非应计 sheet: {0}", string.IsNullOrEmpty(val) ? "Empty" : val);
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
				return ex.Message;
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
		#endregion

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
				if (!theSheet.Name.Equals(sheet.Name)) {
					theSheet.Name = sheet.Name;
				}
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

		public static void FinalizeSheet(string filePath, TargetTableSheet sheet, int dataRowCount, DateTime asOfDate) {
			FinalizeSheet(filePath, sheet, dataRowCount, asOfDate, new DateTime(1900, 1, 1));
		}

		public static void FinalizeSheet(string filePath, TargetTableSheet sheet, int dataRowCount, DateTime asOfDate, DateTime asOfDate2) {
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
				if (sheet.TableId == (int)XEnum.ReportType.X_FXDKTB_D
						|| sheet.TableId == (int)XEnum.ReportType.X_FXDKBH_D
						|| sheet.TableId == (int)XEnum.ReportType.X_CSHSX_M && sheet.Index == 3
					) {
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
				if (sheet.TableId == (int)XEnum.ReportType.X_CSHSX_M && sheet.Index == 3) {
					columnCount = 27;
				}

				//Totals
				int dataRowFrom = sheet.RowsBeforeHeader + 2 - dummyHeaderRows;
				int footerRowFrom = dataRowFrom + dataRowCount;
				int footerRowTo = footerRowFrom + (sheet.FooterEndRow - sheet.FooterStartRow);

				// Copy the footer back
				if (sheet.TableId == (int)XEnum.ReportType.X_FXDKTB_D
						|| sheet.TableId == (int)XEnum.ReportType.X_ZXQYZJXQ_S
						|| sheet.TableId == (int)XEnum.ReportType.X_CSHSX_M && sheet.Index == 3
					) {
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
					if (sheet.TableId == (int)XEnum.ReportType.X_CSHSX_M && sheet.Index == 3) {
						oRange = theSheet.get_Range("A7:A7");
						oRange.Select();
					}
				}

				if (sheet.TableId == (int)XEnum.ReportType.X_WJFL_M) {
					((Range)theSheet.Cells[footerRowFrom, 1]).Value2 = "合计";
					((Range)theSheet.Cells[footerRowFrom, 1]).HorizontalAlignment = XlHAlign.xlHAlignCenter;
					if (dataRowCount > 0) {
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
				}
				else if (sheet.TableId == (int)XEnum.ReportType.F_HYB_M) {
					((Range)theSheet.Cells[footerRowFrom, 1]).Value2 = "合计";
					((Range)theSheet.Cells[footerRowFrom, 1]).HorizontalAlignment = XlHAlign.xlHAlignCenter;
					if (dataRowCount > 0) {
						((Range)theSheet.Cells[footerRowFrom, 6]).Value2 = string.Format("=SUM(F{0}:F{1})", dataRowFrom, footerRowFrom - 1);
					}
				}
				else if (sheet.TableId == (int)XEnum.ReportType.X_FXDKTB_D || sheet.TableId == (int)XEnum.ReportType.X_FXDKBH_D) {
					if (dataRowCount > 0) {
						for (int i = 2; i <= sheet.Columns.Count; i++) {
							if (i == 5 || i == 8 || i == 11 || i == 15) {
								((Range)theSheet.Cells[footerRowFrom, i]).Value2 = string.Format("={0}{1}/B{1}", GetColumnCharacters(i - 1), footerRowFrom);
							}
							else {
								((Range)theSheet.Cells[footerRowFrom, i]).Value2 = string.Format("=SUM({0}{1}:{0}{2})", GetColumnCharacters(i), dataRowFrom, footerRowFrom - 1);
							}
						}
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
					dataRange.RowHeight = 21;
				}
				else if (sheet.TableId == (int)XEnum.ReportType.X_FXDKBH_D) {
					Range dataRange = theSheet.Range[theSheet.Cells[dataRowFrom, 1], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
					dataRange.RowHeight = 24;
					// amount & numbers
					dataRange = theSheet.Range[theSheet.Cells[dataRowFrom, 2], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.HorizontalAlignment = XlHAlign.xlHAlignRight;

					dataRange = theSheet.Range[theSheet.Cells[footerRowFrom, 1], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.Interior.Color = System.Drawing.Color.FromArgb(192, 192, 192);

					((Range)theSheet.Cells[footerRowFrom, 1]).Value2 = "总计";
					((Range)theSheet.Cells[footerRowFrom, 1]).HorizontalAlignment = XlHAlign.xlHAlignCenter;
				}
				else if (sheet.TableId == (int)XEnum.ReportType.C_DQDKQK_D) {
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
					if (dataRowCount > 0) {
						if (sheet.Name.IndexOf("对公") >= 0) {
							((Range)theSheet.Cells[footerRowFrom, 6]).Value2 = string.Format("=SUM(F{0}:F{1})", dataRowFrom, footerRowFrom - 1);
						}
						else if (sheet.Name.IndexOf("个人") >= 0) {
							((Range)theSheet.Cells[footerRowFrom, 8]).Value2 = string.Format("=SUM(H{0}:H{1})", dataRowFrom, footerRowFrom - 1);
						}
					}
				}
				else if (sheet.TableId == (int)XEnum.ReportType.C_XZDKMX_D || sheet.TableId == (int)XEnum.ReportType.C_JQDKMX_D) {
					columnCount = 1;
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
					// Column Header
					Range dataRange = theSheet.Range[theSheet.Cells[headerStartIndex, 1], theSheet.Cells[headerStartIndex, columnCount]];
					dataRange.Font.Bold = true;
					// Data Rows & Footer
					dataRange = theSheet.Range[theSheet.Cells[headerStartIndex, 1], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
					dataRange.HorizontalAlignment = XlHAlign.xlHAlignCenter;
					dataRange.Font.Size = 10;

					// Footer
					dataRange = theSheet.Range[theSheet.Cells[footerRowFrom, 1], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.Interior.Color = System.Drawing.Color.FromArgb(192, 192, 192);

					((Range)theSheet.Cells[footerRowFrom, 1]).Value2 = "总计";
					((Range)theSheet.Cells[footerRowFrom, 1]).HorizontalAlignment = XlHAlign.xlHAlignCenter;
					if (sheet.TableId == (int)XEnum.ReportType.C_XZDKMX_D) {
						if (dataRowCount > 0) {
							((Range)theSheet.Cells[footerRowFrom, 3]).Value2 = string.Format("=SUM(C{0}:C{1})", dataRowFrom, footerRowFrom - 1);
							((Range)theSheet.Cells[footerRowFrom, 9]).Value2 = string.Format("=SUM(I{0}:I{1})", dataRowFrom, footerRowFrom - 1);
						}
						else {
							((Range)theSheet.Cells[footerRowFrom, 3]).Value2 = "0.00";
							((Range)theSheet.Cells[footerRowFrom, 9]).Value2 = "0.00";
						}
					}
					else if (sheet.TableId == (int)XEnum.ReportType.C_JQDKMX_D) {
						if (dataRowCount > 0) {
							((Range)theSheet.Cells[footerRowFrom, 3]).Value2 = string.Format("=SUM(C{0}:C{1})", dataRowFrom, footerRowFrom - 1);
							((Range)theSheet.Cells[footerRowFrom, 4]).Value2 = string.Format("=SUM(D{0}:D{1})", dataRowFrom, footerRowFrom - 1);
							((Range)theSheet.Cells[footerRowFrom, 10]).Value2 = string.Format("=SUM(J{0}:J{1})", dataRowFrom, footerRowFrom - 1);
							((Range)theSheet.Cells[footerRowFrom, 11]).Value2 = string.Format("=SUM(K{0}:K{1})", dataRowFrom, footerRowFrom - 1);
						}
						else {
							((Range)theSheet.Cells[footerRowFrom, 3]).Value2 = "0.00";
							((Range)theSheet.Cells[footerRowFrom, 4]).Value2 = "0.00";
							((Range)theSheet.Cells[footerRowFrom, 10]).Value2 = "0.00";
							((Range)theSheet.Cells[footerRowFrom, 11]).Value2 = "0.00";
						}
					}
				}
				else if (sheet.TableId == (int)XEnum.ReportType.X_ZXQYZJXQ_S) {
					int dataRowStartIndex = sheet.RowsBeforeHeader + 1 + 1;
					Range dataRange = theSheet.Range[theSheet.Cells[dataRowStartIndex, 1], theSheet.Cells[footerRowTo, columnCount]];
					dataRange.Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
					dataRange.Font.Size = 10;

					var lastYear = asOfDate.Year - 1;
					var lastSeason = asOfDate.Month / 3;
					if (lastSeason == 0) { // as_of_date = 2016-1-31
						lastYear--;
						lastSeason = 4;
					}
					var season = "";
					if (lastSeason == 1 || lastSeason == 3) {
						season = string.Format("{0}年度第{1}季度", lastYear + 1, lastSeason);
					}
					else {
						season = string.Format("{0}年{1}半年发放余额", lastYear + 1, (lastSeason == 2 ? "上" : "下"));
					}
					((Range)theSheet.Cells[sheet.RowsBeforeHeader + 1, columnCount - 1]).Value2 = string.Format("{0}年末发放余额", lastYear);
					((Range)theSheet.Cells[sheet.RowsBeforeHeader + 1, columnCount]).Value2 = season;

					((Range)theSheet.Cells[1, 1]).Select();
				}
				else if (sheet.TableId == (int)XEnum.ReportType.X_CSHSX_M && sheet.Index == 3) {
					//绘制数据部分的表格线
					int dataRowStartIndex = sheet.RowsBeforeHeader + 1 + 1;
					Range dataRange = theSheet.Range[theSheet.Cells[dataRowStartIndex, 1], theSheet.Cells[footerRowFrom, columnCount]];
					dataRange.Borders.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Black);
				}

				SubstituteReportHeader(theSheet, sheet, asOfDate, asOfDate2);

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
			return SubstituteReportHeader(theSheet, sheet, asOfDate, new DateTime(1900, 1, 1));
		}

		public static bool SubstituteReportHeader(Worksheet theSheet, TargetTableSheet sheet, DateTime asOfDate, DateTime asOfDate2) {
			var changed = false;
			var columnCount = sheet.Columns.Count;
			for (int i = 1; i <= sheet.RowsBeforeHeader; i++) {
				for (int j = 1; j <= columnCount; j++) {
					var cell = ((Range)theSheet.Cells[i, j]);
					string val = "";
					try {
						val = cell.Value2;
					}
					catch { }
					if (!string.IsNullOrWhiteSpace(val)) {
						if (asOfDate2.Year > 2001) {
							if (val.IndexOf("year2") >= 0) {
								val = val.Replace("year2", asOfDate2.Year.ToString());
							}
							if (val.IndexOf("month2") >= 0) {
								val = val.Replace("month2", asOfDate2.Month.ToString());
							}
							if (val.IndexOf("day2") >= 0) {
								val = val.Replace("day2", asOfDate2.Day.ToString());
							}
						}

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

		public static string PopulateGF0102_161(string filePath, TargetTableSheet sheet, DateTime asOfDate, decimal total, decimal guanZhu, decimal ciJi, decimal keYi, decimal sunShi, decimal overdue90) {
			logger.Debug("Populating GF0102_161");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];
				((Range)theSheet.Cells[6, 3]).Value2 = total;
				((Range)theSheet.Cells[9, 3]).Value2 = guanZhu;
				((Range)theSheet.Cells[11, 3]).Value2 = ciJi;
				((Range)theSheet.Cells[12, 3]).Value2 = keYi;
				((Range)theSheet.Cells[13, 3]).Value2 = sunShi;
				((Range)theSheet.Cells[15, 3]).Value2 = overdue90;

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

				// 1.1 - 1.21
				int rowStartAt = 7;
				for (int i = 0; i < 21; i++) {
					for (int j = 1; j <= 6; j++) {
						((Range)theSheet.Cells[rowStartAt + i, 2 + j]).Value2 = dataTable.Rows[i]["Balance" + j.ToString()];
					}
					((Range)theSheet.Cells[rowStartAt + i, 9]).Value2 = dataTable.Rows[i]["Balance6"];
				}
				// 2. 贷款当年累计发放额
				for (int j = 1; j <= 6; j++) {
					((Range)theSheet.Cells[29, 2 + j]).Value2 = dataTable.Rows[21]["Balance" + j.ToString()];
				}
				((Range)theSheet.Cells[29, 9]).Value2 = dataTable.Rows[21]["Balance6"];

				// 3. 贷款当年累计发放户数
				// 4. 贷款当年累计申请户数
				for (int j = 1; j <= 6; j++) {
					((Range)theSheet.Cells[30, 2 + j]).Value2 = dataTable2.Rows[0]["Count" + j.ToString()];
					((Range)theSheet.Cells[31, 2 + j]).Value2 = dataTable2.Rows[0]["Count" + j.ToString()];
				}
				((Range)theSheet.Cells[30, 9]).Value2 = dataTable2.Rows[0]["Count6"];
				((Range)theSheet.Cells[31, 9]).Value2 = dataTable2.Rows[0]["Count6"];

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

		public static string PopulateSF6301_141(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable, System.Data.DataTable dataTable2) {
			logger.Debug("Populating SF6301_141");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int rowsBeforeStart = 5;
				int r = 0;
				for (int i = 1; i <= 21; i++) {
					if (i == 2 || i == 3 || i == 8 || i == 13 || i == 17 || i == 19) {
						continue;
					}
					for (int j = 1; j <= 7; j++) {
						if (dataTable.Rows[r][j + 1] == DBNull.Value) {
							((Range)theSheet.Cells[rowsBeforeStart + i, 2 + j]).Value2 = "0.00";
						}
						else {
							((Range)theSheet.Cells[rowsBeforeStart + i, 2 + j]).Value2 = dataTable.Rows[r][j + 1];
						}
					}
					r++;
				}

				// 授信户数
				for (int j = 1; j <= 7; j++) {
					((Range)theSheet.Cells[rowsBeforeStart + 25, 2 + j]).Value2 = dataTable2.Rows[0]["Count" + j.ToString()];
					((Range)theSheet.Cells[rowsBeforeStart + 26, 2 + j]).Value2 = dataTable2.Rows[0]["Count" + j.ToString()];
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

		public static string PopulateGF1302_081(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			return PopulateGF1301_081(filePath, sheet, asOfDate, dataTable);
		}

		public static string PopulateGF1303_081(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			return PopulateGF1301_081(filePath, sheet, asOfDate, dataTable);
		}

		public static string PopulateGF1304_081(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			return PopulateGF1301_081(filePath, sheet, asOfDate, dataTable);
		}

		public static string PopulateGF1301_081(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating " + ((XEnum.ReportType)sheet.TableId).ToString());

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int rowStartAt = 6;
				for (int i = 0; i < dataTable.Rows.Count && i < 10; i++) {
					for (int j = 0; j < 6; j++) {
						((Range)theSheet.Cells[rowStartAt + i, j + 2]).Value2 = dataTable.Rows[i][j];
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

		public static string PopulateX_WJFL_M_VS(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_WJFL_M_VS");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int rowStartAt = 6;
				for (int i = 0; i < 3; i++) {
					for (int j = 0; j < 12; j++) {
						((Range)theSheet.Cells[rowStartAt + i, 2 + j]).Value2 = dataTable.Rows[i][j];
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

		public static string PopulateX_DKZLFL_M(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_DKZLFL_M");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int rowStartAt = 7;
				for (int i = 0; i < 7; i++) {
					((Range)theSheet.Cells[rowStartAt + i, 2]).Value2 = dataTable.Rows[i][0];
					((Range)theSheet.Cells[rowStartAt + i, 6]).Value2 = dataTable.Rows[i][1];
					((Range)theSheet.Cells[rowStartAt + i, 7]).Value2 = dataTable.Rows[i][2];
					((Range)theSheet.Cells[rowStartAt + i, 8]).Value2 = dataTable.Rows[i][3];
					((Range)theSheet.Cells[rowStartAt + i, 10]).Value2 = dataTable.Rows[i][4];
					((Range)theSheet.Cells[rowStartAt + i, 11]).Value2 = dataTable.Rows[i][5];
					((Range)theSheet.Cells[rowStartAt + i, 12]).Value2 = dataTable.Rows[i][6];
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

		public static string PopulateGF1101_121(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating GF1101_121");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int excelRow = 10;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					((Range)theSheet.Cells[excelRow, 5]).Value2 = dataTable.Rows[i]["ZC"];
					((Range)theSheet.Cells[excelRow, 6]).Value2 = dataTable.Rows[i]["GZ"];
					((Range)theSheet.Cells[excelRow, 8]).Value2 = dataTable.Rows[i]["CJ"];
					((Range)theSheet.Cells[excelRow, 9]).Value2 = dataTable.Rows[i]["KY"];
					((Range)theSheet.Cells[excelRow, 10]).Value2 = dataTable.Rows[i]["SS"];
					if (excelRow == 29) { // 2.1 - 2.20 end
						excelRow = 31;
					}
					else if (excelRow == 35) { // 2.22买断式转贴现 end
						excelRow = 38;
					}
					else if (excelRow == 38) { // 7. 个人经营性贷款 end
						excelRow = 40;
					}
					else {
						excelRow++;
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

		public static string PopulateGF1103_121(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating GF1103_121");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int excelRow = 8;
				int lastDirectionId = 0;
				for (int i = 0; i < 97; i++) {
					if ((int)dataTable.Rows[i]["DirectionId"] > 0 && (int)dataTable.Rows[i]["DirectionId"] != lastDirectionId) {
						excelRow += 1; // 此行用公式计算, 跳过
						lastDirectionId = (int)dataTable.Rows[i]["DirectionId"];
					}
					((Range)theSheet.Cells[excelRow, 5]).Value2 = dataTable.Rows[i]["ZC"];
					((Range)theSheet.Cells[excelRow, 6]).Value2 = dataTable.Rows[i]["GZ"];
					((Range)theSheet.Cells[excelRow, 8]).Value2 = dataTable.Rows[i]["CJ"];
					((Range)theSheet.Cells[excelRow, 9]).Value2 = dataTable.Rows[i]["KY"];
					((Range)theSheet.Cells[excelRow, 10]).Value2 = dataTable.Rows[i]["SS"];
					if (excelRow == 123) { // 20.1国际组织 end
						excelRow = 126;
					}
					else {
						excelRow++;
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

		public static string PopulateGF1200_101(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating GF1200_101");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int excelRow = 7;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					if (i > 0) {
						((Range)theSheet.Cells[excelRow, 4]).Value2 = dataTable.Rows[i]["JS"];
					}
					((Range)theSheet.Cells[excelRow, 5]).Value2 = dataTable.Rows[i]["ZC"];
					((Range)theSheet.Cells[excelRow, 6]).Value2 = dataTable.Rows[i]["GZ"];
					((Range)theSheet.Cells[excelRow, 7]).Value2 = dataTable.Rows[i]["CJ"];
					((Range)theSheet.Cells[excelRow, 8]).Value2 = dataTable.Rows[i]["KY"];
					((Range)theSheet.Cells[excelRow, 9]).Value2 = dataTable.Rows[i]["SS"];
					excelRow++;
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

		public static string PopulateGF1403_111(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating GF1403_111");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int rowStartAt = 8;
				for (int i = 0; i < dataTable.Rows.Count && i < 10; i++) {
					((Range)theSheet.Cells[rowStartAt + i, 3]).Value2 = dataTable.Rows[i]["CustomerName"];
					((Range)theSheet.Cells[rowStartAt + i, 4]).Value2 = dataTable.Rows[i]["IdCode"];
					((Range)theSheet.Cells[rowStartAt + i, 5]).Value2 = dataTable.Rows[i]["Balance"];
					((Range)theSheet.Cells[rowStartAt + i, 6]).Value2 = dataTable.Rows[i]["Balance"];
					((Range)theSheet.Cells[rowStartAt + i, 8]).Value2 = dataTable.Rows[i]["ZC"];
					((Range)theSheet.Cells[rowStartAt + i, 9]).Value2 = dataTable.Rows[i]["GZ"];
					((Range)theSheet.Cells[rowStartAt + i, 10]).Value2 = dataTable.Rows[i]["CJ"];
					((Range)theSheet.Cells[rowStartAt + i, 11]).Value2 = dataTable.Rows[i]["KY"];
					((Range)theSheet.Cells[rowStartAt + i, 12]).Value2 = dataTable.Rows[i]["SS"];
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

		public static string PopulateGF1900_151(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating GF1900_151");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int rowStartAt = 7;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					for (int j = 0; j < 5; j++) {
						((Range)theSheet.Cells[rowStartAt + i, 14 + j]).Value2 = dataTable.Rows[i][2 + j];
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

		public static string PopulateSF6302_131(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating SF6302_131");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[1];

				int rowStartAt = 6;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					for (int j = 0; j < 6; j++) {
						((Range)theSheet.Cells[rowStartAt + i, 3 + j]).Value2 = dataTable.Rows[i][1 + j];
					}
					((Range)theSheet.Cells[rowStartAt + i, 9]).Value2 = dataTable.Rows[i]["F"];
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

		public static string PopulateSF6402_131(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating SF6402_131");

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

		public static string PopulateX_BLDKJC_X_1(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_BLDKJC_X_1");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int excelRow = 7;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					for (int j = 0; j < 4; j++) {
						if (excelRow >= 24) {
							((Range)theSheet.Cells[excelRow, 2 + j]).Value2 = ((decimal)dataTable.Rows[i][2 + j] / 100);
						}
						else {
							((Range)theSheet.Cells[excelRow, 2 + j]).Value2 = dataTable.Rows[i][2 + j];
						}
					}
					if (excelRow == 8) { // 关注类贷款余额 starts
						excelRow = 10;
					}
					else if (excelRow == 11) { // 法人类不良贷款余额 starts
						excelRow = 17;
					}
					else if (excelRow == 19) { // 个人类不良贷款余额 starts
						excelRow = 21;
					}
					else {
						excelRow++;
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

		public static string PopulateX_BLDKJC_X_2(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_BLDKJC_X_2");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int excelRow = 6;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					for (int j = 0; j < 4; j++) {
						((Range)theSheet.Cells[excelRow, 2 + j]).Value2 = dataTable.Rows[i][2 + j];
					}
					if (excelRow == 6) { // 不良贷款余额 ends
						excelRow = 8;
					}
					else {
						excelRow++;
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

		public static string PopulateX_BLDKJC_X_3(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_BLDKJC_X_3");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int excelRow = 6;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					for (int j = 0; j < 4; j++) {
						((Range)theSheet.Cells[excelRow, 2 + j]).Value2 = dataTable.Rows[i][2 + j];
					}
					if (excelRow == 25) { // 公共管理、社会保障和社会组织 ends
						excelRow = 28;
					}
					else {
						excelRow++;
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

		public static string PopulateX_BLDKJC_X_4(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_BLDKJC_X_4");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int excelRow = 6;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					for (int j = 0; j < 8; j++) {
						((Range)theSheet.Cells[excelRow, 2 + j]).Value2 = dataTable.Rows[i][j];
					}
					excelRow++;
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

		public static string PopulateX_CSHSX_M_1(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_CSHSX_M_1");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int excelRow = 5;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					for (int j = 0; j < 18; j++) {
						((Range)theSheet.Cells[excelRow, 3 + j]).Value2 = dataTable.Rows[i][2 + j];
					}
					excelRow++;
					if (excelRow == 6) { // 1.按贷款担保方式
						excelRow = 7;
					}
					else if (excelRow == 8) { // 1.2保证贷款 --留给excel公式计算
						i++;
						excelRow = 9;
					}
					else if (excelRow == 11) { // 2.按贷款逾期情况
						excelRow = 12;
					}
					else if (excelRow == 15) { // 3.按贷款对象
						excelRow = 16;
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

		public static string PopulateX_CSHSX_M_2(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_CSHSX_M_2");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int rowStartAt = 7;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					int excelColumn = 2;
					for (int j = 0; j < 12; j++) {
						if (j == 7) { // 借款开始日
							((Range)theSheet.Cells[rowStartAt + i, excelColumn]).Value2 = string.Format("{0}至{1}", ((DateTime)dataTable.Rows[i][j]).ToString("yyyy年MM月dd日"), ((DateTime)dataTable.Rows[i][j + 1]).ToString("yyyy年MM月dd日"));
							j++; // 跳过借款到期日
						}
						else {
							((Range)theSheet.Cells[rowStartAt + i, excelColumn]).Value2 = dataTable.Rows[i][j];
						}
						excelColumn++;
						if (excelColumn == 6) { // 现金流覆盖情况（如是平台，填报）
							excelColumn = 7;
						}
						else if (excelColumn == 10) { // 如为房地产及其他固定资产贷款
							excelColumn = 12;
						}
						else if (excelColumn == 14) { // 担保情况, N-S列
							excelColumn = 20;
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

		public static string PopulateX_CSHSX_M_4(string filePath, TargetTableSheet sheet, DateTime asOfDate, System.Data.DataTable dataTable) {
			logger.Debug("Populating X_CSHSX_M_4");

			Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();

			Workbook theExcelBook = null;
			Worksheet theSheet = null;
			bool excelOpened = false;
			try {
				theExcelBook = theExcelApp.Workbooks.Open(filePath);
				excelOpened = true;
				theSheet = (Worksheet)theExcelBook.Sheets[sheet.Index];

				int rowStartAt = 7;
				for (int i = 0; i < dataTable.Rows.Count; i++) {
					int excelColumn = 2;
					for (int j = 0; j < dataTable.Columns.Count; j++) {
						if (j == 6) { // 借款开始日
							((Range)theSheet.Cells[rowStartAt + i, excelColumn]).Value2 = string.Format("{0}至{1}", ((DateTime)dataTable.Rows[i][j]).ToString("yyyy年MM月dd日"), ((DateTime)dataTable.Rows[i][j + 1]).ToString("yyyy年MM月dd日"));
							j++; // 跳过借款到期日
						}
						else {
							((Range)theSheet.Cells[rowStartAt + i, excelColumn]).Value2 = dataTable.Rows[i][j];
						}
						excelColumn++;
						if (excelColumn == 8) { // 首付比例
							excelColumn = 10;
						}
						else if (excelColumn == 12) { // 担保情况, L-Q列
							excelColumn = 18;
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

		private static int GetColumnHeaderRow(Worksheet sheet, string firstColumnName, int maxRow) {
			int row = 0;
			while (++row <= maxRow) {
				string val = ((Range)sheet.Cells[row, 1]).Value2;
				if (!string.IsNullOrEmpty(val) && val.Equals(firstColumnName)) {
					return row;
				}
			}
			return 0;
		}

		private static string GetColumnCharacters(int index) {
			var s = "";
			while (index > 0) {
				int c = index % 26;
				if (c == 0) {
					c = 26;
				}
				s = ((char)(64 + c)).ToString() + s;
				index = (index - c) / 26;
			}
			if (s == "") {
				s = "A";
			}
			return s;
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

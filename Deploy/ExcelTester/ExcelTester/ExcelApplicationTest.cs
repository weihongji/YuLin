using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Microsoft.Office.Interop.Excel;

namespace ExcelTester
{
	public class ExcelApplicationTest
	{
		public static string Test() {
			bool success = true;
			var msg = new StringBuilder();
			try {
				msg.AppendLine("Creating Excel.Application");
				Microsoft.Office.Interop.Excel.Application theExcelApp = new Microsoft.Office.Interop.Excel.Application();
				msg.AppendLine("Created");

				Workbook theExcelBook = null;
				Worksheet theSheet = null;
				bool excelOpened = false;
				try {
					msg.AppendLine("Openning excel file");
					theExcelBook = theExcelApp.Workbooks.Open(System.Environment.CurrentDirectory + "\\a.xls");
					msg.AppendLine("Opened");
					excelOpened = true;

					msg.AppendLine("Openning the 1st sheet");
					theSheet = (Worksheet)theExcelBook.Sheets[1];
					msg.AppendLine("Opened");

					msg.AppendLine("Reading cell [1, 1]");
					var cell = ((Range)theSheet.Cells[1, 1]);
					msg.AppendLine("Got value: " + cell.Value2);
				}
				catch (Exception ex1) {
					success = false;
					msg.AppendLine("Error below:");
					msg.AppendLine(new string('=', 40));
					msg.AppendLine(ex1.Message);
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
			catch (Exception ex) {
				success = false;
				msg.AppendLine("Error below:");
				msg.AppendLine(new string('=', 40));
				msg.AppendLine(ex.Message);
			}

			return (success ? "Success" : "Failed") + "\r\n" + (new string('-', 40)) + "\r\n" + msg.ToString();
		}
	}
}

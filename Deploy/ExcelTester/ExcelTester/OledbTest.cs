using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.OleDb;

namespace ExcelTester
{
	public class OledbTest
	{
		public static string Test() {
			bool success = true;
			var msg = new StringBuilder();
			msg.AppendLine("Creating OleDbConnection object");
			OleDbConnection cnn = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=a.xls;Extended Properties=Excel 8.0");
			msg.AppendLine("Created");
			try {
				msg.AppendLine("Openning Ole connection");
				cnn.Open();
				msg.AppendLine("Opened");

				OleDbCommand ocmd = new OleDbCommand("select * from [Sheet1$]", cnn);
				msg.AppendLine("Execting command");
				OleDbDataReader reader = ocmd.ExecuteReader();
				msg.AppendLine("Executed");

				string fname = "";
				string lname = "";
				string mobnum = "";
				msg.AppendLine("Reading rows");
				msg.AppendLine(new string('-', 20));
				int i = 0;
				while (reader.Read() && i < 10) {
					msg.AppendLine("Row " + (++i).ToString() + ":");
					fname = reader[0].ToString();
					lname = reader[1].ToString();
					mobnum = reader[2].ToString();
					msg.AppendLine(string.Format("{0}, {1}, {2}", fname, lname, mobnum));
				}
				msg.AppendLine(new string('-', 20));
				msg.AppendLine(i.ToString() + " rows has been read");
				msg.AppendLine("Closing connection");
				cnn.Close();
				msg.AppendLine("Closed");
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

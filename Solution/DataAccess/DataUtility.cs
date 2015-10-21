using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class DataUtility
	{
		public static string GetValue(DbDataReader reader, int column) {
			object val = reader[column];
			var s = string.Empty;
			if (val != DBNull.Value) {
				s = val.ToString().Trim();
			}
			return s;
		}

		public static string GetSqlValue(DbDataReader reader, int column) {
			object val = reader[column];
			var s = string.Empty;
			if (val == DBNull.Value) {
				s = "NULL";
			}
			else {
				s = "'" + val.ToString().Trim().Replace("'", "''") + "'";
			}
			return s;
		}
	}
}

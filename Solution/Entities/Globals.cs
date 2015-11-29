using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class Globals : EntityBase
	{
		public string SystemVersion { get; set; }
		public int DBSchemaLevel { get; set; }
		public int FixedDataLevel { get; set; }

		private static Globals _info;

		public static Globals Info {
			get {
				if (_info == null) {
					_info = GetGlobals();
				}
				return _info;
			}
		}

		private Globals(DataRow row) {
			this.SystemVersion = (string)row["SystemVersion"];
			this.DBSchemaLevel = (int)row["DBSchemaLevel"];
			this.FixedDataLevel = (int)row["FixedDataLevel"];
		}

		private static Globals GetGlobals() {
			var table = dao.ExecuteDataTable("SELECT * FROM Globals");
			if (table.Rows.Count > 0) {
				return new Globals((DataRow)table.Rows[0]);
			}
			return null;
		}
	}
}

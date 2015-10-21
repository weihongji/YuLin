using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class TargetTableSheetColumn
	{
		public int SheetId { get; set; }
		public int Index { get; set; }
		public string Name { get; set; }

		public TargetTableSheetColumn() {
		}

		public TargetTableSheetColumn(DataRow row) {
			this.SheetId = (int)row["SheetId"];
			this.Index = (int)row["Index"];
			this.Name = (string)row["Name"];
		}
	}
}

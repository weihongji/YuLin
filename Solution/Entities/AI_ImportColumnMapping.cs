using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class AI_ImportColumnMapping
	{
		public int ColumnId { get; set; }
		public int Index { get; set; }
		public string Name { get; set; }

		public AI_ImportColumnMapping() {
		}

		public AI_ImportColumnMapping(DataRow row) {
			this.ColumnId = (int)row["ColumnId"];
			this.Index = (int)row["Index"];
			this.Name = (string)row["Name"];
		}
	}
}

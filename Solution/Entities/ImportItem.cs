using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class ImportItem : EntityBase
	{
		public int Id { get; set; }
		public int ImportId { get; set; }
		public XEnum.ImportItemType ItemType { get; set; }
		public string FilePath { get; set; }

		public ImportItem() {
		}

		public ImportItem(DataRow row) {
			this.Id = (int)row["Id"];
			this.ImportId = (int)row["ImportId"];
			this.ItemType = (XEnum.ImportItemType)((short)row["ItemType"]);
			this.FilePath = (string)row["FilePath"];
		}
	}
}

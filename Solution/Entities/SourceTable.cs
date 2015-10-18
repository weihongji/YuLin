using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using DataAccess;

namespace Entities
{
	public class SourceTable : EntityBase
	{
		public int Id { get; set; }
		public string Name { get; set; }

		private List<SourceTableSheet> _sheets;

		public SourceTable() {
		}

		public SourceTable(DataRow row) {
			this.Id = (int)row["Id"];
			this.Name = (string)row["Name"];
		}

		public List<SourceTableSheet> Sheets {
			get {
				if (_sheets == null) {
					_sheets = GetSheets();
				}
				return _sheets;
			}
		}

		public static List<SourceTable> GetList() {
			var list = new List<SourceTable>();
			var table = dao.ExecuteDataTable("SELECT * FROM SourceTable");
			foreach (DataRow row in table.Rows) {
				list.Add(new SourceTable(row));
			}
			return list;
		}

		public static SourceTable GetById(XEnum.ImportItemType sourceType) {
			return GetById((int)sourceType);
		}

		public static SourceTable GetById(int Id) {
			var list = new List<SourceTable>();
			var table = dao.ExecuteDataTable("SELECT * FROM SourceTable WHERE Id = " + Id);
			if (table.Rows.Count > 0) {
				return new SourceTable((DataRow)table.Rows[0]);
			}
			return null;
		}

		private List<SourceTableSheet> GetSheets() {
			var list = new List<SourceTableSheet>();
			var table = dao.ExecuteDataTable("SELECT * FROM SourceTableSheet WHERE TableId = " + this.Id);
			foreach (DataRow row in table.Rows) {
				list.Add(new SourceTableSheet(row));
			}
			return list;
		}
	}
}

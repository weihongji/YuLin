using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class Import : EntityBase
	{
		public int Id { get; set; }
		public DateTime ImportDate { get; set; }
		public DateTime? WJFLDate { get; set; }
		public DateTime? WJFLSFDate { get; set; }

		private List<ImportItem> _items;

		public Import() {
		}

		public Import(DataRow row) {
			this.Id = (int)row["Id"];
			this.ImportDate = (DateTime)row["ImportDate"];
			if (row["WJFLDate"] != DBNull.Value) {
				this.WJFLDate = (DateTime)row["WJFLDate"];
			}
			if (row["WJFLSFDate"] != DBNull.Value) {
				this.WJFLSFDate = (DateTime)row["WJFLSFDate"];
			}
		}

		public List<ImportItem> Items {
			get {
				if (_items == null) {
					_items = GetItems();
				}
				return _items;
			}
		}

		public static List<Import> GetList() {
			var list = new List<Import>();
			var table = dao.ExecuteDataTable("SELECT * FROM Import");
			foreach (DataRow row in table.Rows) {
				list.Add(new Import(row));
			}
			return list;
		}

		public static Import GetById(int Id) {
			var table = dao.ExecuteDataTable("SELECT * FROM Import WHERE Id = " + Id);
			if (table.Rows.Count > 0) {
				return new Import((DataRow)table.Rows[0]);
			}
			return null;
		}

		public static Import GetByDate(DateTime importDate) {
			var list = new List<Import>();
			var table = dao.ExecuteDataTable(string.Format("SELECT * FROM Import WHERE ImportDate = '{0}'", importDate.ToString("yyyyMMdd")));
			if (table.Rows.Count > 0) {
				return new Import((DataRow)table.Rows[0]);
			}
			return null;
		}

		private List<ImportItem> GetItems() {
			var list = new List<ImportItem>();
			var table = dao.ExecuteDataTable("SELECT * FROM ImportItem WHERE ImportId = " + this.Id);
			foreach (DataRow row in table.Rows) {
				list.Add(new ImportItem(row));
			}
			return list;
		}
	}
}

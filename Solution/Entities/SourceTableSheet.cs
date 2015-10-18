using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using DataAccess;

namespace Entities
{
	public class SourceTableSheet : EntityBase
	{
		public int Id { get; set; }
		public int TableId { get; set; }
		public int Index { get; set; }
		public string Name { get; set; }
		public int RowsBeforeHeader { get; set; }
		public string DataRowEndingFlag { get; set; }

		private List<SourceTableSheetColumn> _columns;

		public SourceTableSheet() {
		}

		public SourceTableSheet(DataRow row) {
			this.Id = (int)row["Id"];
			this.TableId = (int)row["TableId"];
			this.Index = (int)row["Index"];
			this.Name = (string)row["Name"];
			this.RowsBeforeHeader = (int)row["RowsBeforeHeader"];
			this.DataRowEndingFlag = (string)row["DataRowEndingFlag"];
		}

		public List<SourceTableSheetColumn> Columns {
			get {
				if (_columns == null) {
					_columns = GetColumns();
				}
				return _columns;
			}
		}

		public static List<SourceTableSheet> GetList() {
			var list = new List<SourceTableSheet>();
			var table = dao.ExecuteDataTable("SELECT * FROM SourceTableSheet");
			foreach (DataRow row in table.Rows) {
				list.Add(new SourceTableSheet(row));
			}
			return list;
		}

		public static SourceTableSheet GetById(int Id) {
			var list = new List<SourceTableSheet>();
			var table = dao.ExecuteDataTable("SELECT * FROM SourceTableSheet WHERE Id = " + Id);
			if (table.Rows.Count > 0) {
				return new SourceTableSheet((DataRow)table.Rows[0]);
			}
			return null;
		}

		private List<SourceTableSheetColumn> GetColumns() {
			var list = new List<SourceTableSheetColumn>();
			var table = dao.ExecuteDataTable("SELECT * FROM SourceTableSheetColumn WHERE SheetId = " + this.Id);
			foreach (DataRow row in table.Rows) {
				list.Add(new SourceTableSheetColumn(row));
			}
			return list;
		}
	}
}

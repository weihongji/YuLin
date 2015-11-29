using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class TargetTableSheet : EntityBase
	{
		public int Id { get; set; }
		public int TableId { get; set; }
		public int Index { get; set; }
		public string Name { get; set; }
		public int RowsBeforeHeader { get; set; }
		public int FooterStartRow { get; set; }
		public int FooterEndRow { get; set; }
		
		private List<TargetTableSheetColumn> _columns;

		public TargetTableSheet() {
		}

		public TargetTableSheet(DataRow row) {
			this.Id = (int)row["Id"];
			this.TableId = (int)row["TableId"];
			this.Index = (int)row["Index"];
			this.Name = (string)row["Name"];
			this.RowsBeforeHeader = (int)row["RowsBeforeHeader"];
			this.FooterStartRow = (int)row["FooterStartRow"];
			this.FooterEndRow = (int)row["FooterEndRow"];
		}

		public List<TargetTableSheetColumn> Columns {
			get {
				if (_columns == null) {
					_columns = GetColumns();
				}
				return _columns;
			}
		}

		public static List<TargetTableSheet> GetList() {
			var list = new List<TargetTableSheet>();
			var table = dao.ExecuteDataTable("SELECT * FROM TargetTableSheet");
			foreach (DataRow row in table.Rows) {
				list.Add(new TargetTableSheet(row));
			}
			return list;
		}

		public static TargetTableSheet GetById(int Id) {
			var table = dao.ExecuteDataTable("SELECT * FROM TargetTableSheet WHERE Id = " + Id);
			if (table.Rows.Count > 0) {
				return new TargetTableSheet((DataRow)table.Rows[0]);
			}
			return null;
		}

		private List<TargetTableSheetColumn> GetColumns() {
			var list = new List<TargetTableSheetColumn>();
			var table = dao.ExecuteDataTable("SELECT * FROM TargetTableSheetColumn WHERE SheetId = " + this.Id);
			foreach (DataRow row in table.Rows) {
				list.Add(new TargetTableSheetColumn(row));
			}
			return list;
		}

		public string EvaluateName(DateTime asOfDate) {
			if (this.Name.StartsWith("<") && this.Name.EndsWith(">")) {
				this.Name = asOfDate.ToString(this.Name.Substring(1, this.Name.Length - 2));
			}
			return this.Name;
		}
	}
}

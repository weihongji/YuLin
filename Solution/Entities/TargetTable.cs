using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Entities
{
	public class TargetTable : EntityBase
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public string TemplateName { get; set; }

		private List<TargetTableSheet> _sheets;

		public TargetTable() {
		}

		public TargetTable(DataRow row) {
			this.Id = (int)row["Id"];
			this.Name = (string)row["Name"];
			this.TemplateName = (string)row["FileName"];
		}

		public List<TargetTableSheet> Sheets {
			get {
				if (_sheets == null) {
					_sheets = GetSheets();
				}
				return _sheets;
			}
		}

		public static List<TargetTable> GetList() {
			var list = new List<TargetTable>();
			var table = dao.ExecuteDataTable("SELECT * FROM TargetTable");
			foreach (DataRow row in table.Rows) {
				list.Add(new TargetTable(row));
			}
			return list;
		}

		public static TargetTable GetById(XEnum.ReportType reportType) {
			return GetById((int)reportType);
		}

		public static TargetTable GetById(int Id) {
			var list = new List<TargetTable>();
			var table = dao.ExecuteDataTable("SELECT * FROM TargetTable WHERE Id = " + Id);
			if (table.Rows.Count > 0) {
				return new TargetTable((DataRow)table.Rows[0]);
			}
			return null;
		}

		private List<TargetTableSheet> GetSheets() {
			var list = new List<TargetTableSheet>();
			var table = dao.ExecuteDataTable("SELECT * FROM TargetTableSheet WHERE TableId = " + this.Id);
			foreach (DataRow row in table.Rows) {
				list.Add(new TargetTableSheet(row));
			}
			return list;
		}
	}
}

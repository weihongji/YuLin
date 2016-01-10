using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class AI_ImportColumn : EntityBase
	{
		public int Id { get; set; }
		public int TableId { get; set; }
		public int Index { get; set; }
		public string Name { get; set; }

		public AI_ImportColumn() {
		}

		public AI_ImportColumn(DataRow row) {
			this.Id = (int)row["Id"];
			this.TableId = (int)row["TableId"];
			this.Index = (int)row["Index"];
			this.Name = (string)row["Name"];
		}

		public static List<AI_ImportColumn> GetList(XEnum.ImportItemType itemType) {
			return GetList((int)itemType);
		}

		public static List<AI_ImportColumn> GetList(int tableId) {
			var list = new List<AI_ImportColumn>();
			var table = dao.ExecuteDataTable("SELECT * FROM AI_ImportColumn WHERE TableId = " + tableId.ToString());
			foreach (DataRow row in table.Rows) {
				list.Add(new AI_ImportColumn(row));
			}
			return list;
		}

		public static AI_ImportColumn GetByAlias(XEnum.ImportItemType itemType, string alias) {
			return GetByAlias((int)itemType, alias);
		}

		public static AI_ImportColumn GetByAlias(int tableId, string alias) {
			var sql = new StringBuilder();
			sql.AppendLine("SELECT C.* FROM AI_ImportColumnMapping M INNER JOIN AI_ImportColumn C ON M.ColumnId = C.Id");
			sql.AppendLine(string.Format("WHERE C.TableId = {0} AND M.Alias = '{1}'", tableId, alias));
			var table = dao.ExecuteDataTable(sql.ToString());
			if (table.Rows.Count > 0) {
				return new AI_ImportColumn((DataRow)table.Rows[0]);
			}
			return null;
		}
	}
}

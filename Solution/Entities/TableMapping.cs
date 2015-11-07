using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace Reporting
{
	public enum MappingMode
	{
		UnKnown=0,
		Frozen=1,
		Custom=2
	}
	public static class EnumHelper
	{
		public static string GetString(this MappingMode mode) {
			var str = "空白列";
			switch (mode) {
				case MappingMode.Custom:
					str = "定制列";
					break;
				case MappingMode.Frozen:
					str = "固定列";
					break;
			}
			return str;
		}
	}
	public class TableMapping : EntityBase
	{
		public int Id { get; set; }
		public string TableId { get; set; }
		public string ColName { get; set; }
		public string MappingName { get; set; }
		public MappingMode Mode { get; set; }
		public TableMapping(string empcol) {
			Mode = MappingMode.UnKnown;
			MappingName = empcol;
			ColName = empcol;
		}
		public TableMapping(DataRow row) {
			this.Id = (int)row["Id"];
			this.TableId = (string)row["TableId"];
			this.ColName = (string)row["ColName"];
			this.MappingName = (string)row["MappingName"];
			this.Mode = (MappingMode)(int)row["MappingMode"];
		}
		public override string ToString() {
			return MappingName; // string.Format("{0}({1})", MappingName, Mode.GetString());
		}

		public static List<TableMapping> GetMappingList(string tableName) {
			var list = new List<TableMapping>();
			var p = new SqlParameter("@tableName", tableName);
			p.SqlDbType=SqlDbType.VarChar;
			p.Size = 20;
			var table = dao.ExecuteDataTable("SELECT * FROM TableMapping where tableId=@tableName",new SqlParameter[] {p});
			foreach (DataRow row in table.Rows) {
				list.Add(new TableMapping(row));
			}
		
			return list;
		}

		public static List<string> GetFrozenColumnNames(string tableName) {
			var list = new List<string>();
			var p = new SqlParameter("@tableName", tableName);
			p.SqlDbType = SqlDbType.VarChar;
			p.Size = 20;
			var table = dao.ExecuteDataTable("SELECT ColName FROM TableMapping WHERE TableId=@tableName AND MappingMode=1 ORDER BY Id", new SqlParameter[] { p });
			foreach (DataRow row in table.Rows) {
				list.Add((string)row["ColName"]);
			}
			return list;
		}

		public static List<TableMapping> GetFrozenColumns(string tableName) {
			var list = new List<TableMapping>();
			var p = new SqlParameter("@tableName", tableName);
			p.SqlDbType = SqlDbType.VarChar;
			p.Size = 20;
			var table = dao.ExecuteDataTable("SELECT * FROM TableMapping WHERE TableId=@tableName AND MappingMode=1 ORDER BY Id", new SqlParameter[] { p });
			foreach (DataRow row in table.Rows) {
				list.Add(new TableMapping(row));
			}
			return list;
		}
	}
}

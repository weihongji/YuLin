using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Reporting
{
	public partial class frmImportHistory : Form
	{
		public frmImportHistory() {
			InitializeComponent();
		}

		private void frmImportHistory_Load(object sender, EventArgs e) {
			LoadData();
		}

		private void btnRefresh_Click(object sender, EventArgs e) {
			LoadData();
		}

		private void btnClose_Click(object sender, EventArgs e) {
			this.Close();
		}

		private void LoadData() {
			var dao = new SqlDbHelper();
			var sql = new StringBuilder();
			sql.AppendLine("SELECT ImportDate AS [数据日期]");
			sql.AppendLine("	, CASE WHEN WJFLSubmitDate IS NOT NULL THEN '是' ELSE '' END AS [五级分类]");
			sql.AppendLine("	, DateStamp AS [导入时间]");
			sql.AppendLine("FROM Import");
			sql.AppendLine("ORDER BY ImportDate DESC");
			var table = dao.ExecuteDataTable(sql.ToString());
			this.dataGridView1.DataSource = table;
			this.dataGridView1.Columns[0].DefaultCellStyle.Format = "yyyy-MM-dd";

			this.dataGridView1.Columns[1].Width = 80;
			//this.dataGridView1.Columns[1].SortMode = DataGridViewColumnSortMode.NotSortable;
			this.dataGridView1.Columns[1].HeaderCell.Style.Alignment = DataGridViewContentAlignment.MiddleCenter;
			this.dataGridView1.Columns[1].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
	
			this.dataGridView1.Columns[2].DefaultCellStyle.Format = "yyyy-MM-dd HH:mm:ss";
			this.dataGridView1.Columns[2].Width = 140;
		}
	}
}

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
		private Logger logger = Logger.GetLogger("frmImportHistory");

		public frmImportHistory() {
			InitializeComponent();
		}

		private void frmImportHistory_Load(object sender, EventArgs e) {
			LoadData();
		}

		private void frmImportHistory_KeyDown(object sender, KeyEventArgs e) {
			if (e.KeyCode == Keys.F5) {
				btnRefresh_Click(null, null);
			}
		}

		private void btnRefresh_Click(object sender, EventArgs e) {
			LoadData();
		}

		private void btnClose_Click(object sender, EventArgs e) {
			this.Close();
		}

		private void LoadData() {
			try {
				var dao = new SqlDbHelper();
				var sql = new StringBuilder();
				sql.AppendLine("SELECT ImportDate AS [数据日期]");
				sql.AppendLine("	, Id AS [编号]");
				sql.AppendLine("	, DateStamp AS [创建时间]");
				sql.AppendLine("	, WJFLDate AS [五级分类]");
				sql.AppendLine("	, SUBSTRING(dbo.sfGetImportStatus(ImportDate), 1, 9) AS [导入状况]");
				sql.AppendLine("FROM Import");
				sql.AppendLine("ORDER BY ImportDate");
				var table = dao.ExecuteDataTable(sql.ToString());
				this.dataGridView1.DataSource = table;
				this.dataGridView1.Columns[0].DefaultCellStyle.Format = "yyyy-MM-dd";

				this.dataGridView1.Columns[1].Width = 60;
				this.dataGridView1.Columns[1].HeaderCell.Style.Alignment = DataGridViewContentAlignment.MiddleCenter;
				this.dataGridView1.Columns[1].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;

				this.dataGridView1.Columns[2].DefaultCellStyle.Format = "yyyy-MM-dd HH:mm:ss";
				this.dataGridView1.Columns[2].Width = 140;

				this.dataGridView1.Columns[3].DefaultCellStyle.Format = "yyyy-MM-dd HH:mm:ss";
				this.dataGridView1.Columns[3].Width = 140;
				this.dataGridView1.Columns[3].SortMode = DataGridViewColumnSortMode.NotSortable;

				this.dataGridView1.Columns[4].Width = 100;
				this.dataGridView1.Columns[4].SortMode = DataGridViewColumnSortMode.NotSortable;
			}
			catch (System.Data.SqlClient.SqlException ex) {
				logger.Error("Error in LoadData:\r\n", ex);
				ShowError("数据库访问发生错误，请确保数据库可以访问。");
			}
			catch (Exception ex) {
				logger.Error("Error in ShowReport:\r\n", ex);
				ShowError(ex.Message);
			}
		}

		private void ShowError(string msg) {
			if (string.IsNullOrEmpty(msg)) {
				return;
			}
			if (msg.IndexOf("Exception") >= 0) {
				msg = "发生错误";
			}
			frmMain.ShowErrorDialog(msg, this.Text);
		}
	}
}

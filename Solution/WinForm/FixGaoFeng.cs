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
	public partial class frmFixGaoFeng : Form
	{
		public frmFixGaoFeng() {
			InitializeComponent();
		}

		private void frmFixGaoFeng_Load(object sender, EventArgs e) {
			var dao = new SqlDbHelper();
			var table = dao.ExecuteDataTable("SELECT ImportDate FROM Import ORDER BY ImportDate DESC");
			this.cmbDate.Items.Clear();
			if (table != null) {
				foreach (DataRow row in table.Rows) {
					var value = ((DateTime)row[0]).ToString("yyyy-MM-dd");
					this.cmbDate.Items.Add(value);
				}

				if (this.cmbDate.Items.Count > 0) {
					if (this.cmbDate.SelectedIndex < 0) {
						this.cmbDate.SelectedIndex = 0;
					}
				}
			}
		}

		private void btnFix_Click(object sender, EventArgs e) {
			DateTime date;
			if (DateTime.TryParse(this.cmbDate.Text, out date)) {
				var dao = new SqlDbHelper();
				var importId = (int) dao.ExecuteScalar(string.Format("SELECT ISNULL(MAX(Id), 0) FROM Import WHERE ImportDate = '{0}'", date.ToString("yyyyMMdd")));
				if (importId == 0) {
					MessageBox.Show(string.Format("无效的导入日期。没有找到{0}日的数据", date), this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
					return;
				}
				var affected = dao.ExecuteNonQuery("UPDATE ImportPrivate SET CustomerName = '高峰' WHERE CustomerName = '高锋' AND ImportId = " + importId.ToString());
				affected += dao.ExecuteNonQuery("UPDATE ImportLoan SET CustomerName = '高峰' WHERE CustomerName = '高锋' AND ImportId = " + importId.ToString());
				affected += dao.ExecuteNonQuery("UPDATE ImportNonAccrual SET CustomerName = '高峰' WHERE CustomerName = '高锋' AND ImportId = " + importId.ToString());
				affected += dao.ExecuteNonQuery("UPDATE ImportOverdue SET CustomerName = '高峰' WHERE CustomerName = '高锋' AND ImportId = " + importId.ToString());
				if (affected > 0) {
					MessageBox.Show("修改完毕。", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
				}
				else {
					MessageBox.Show("没有发现'高锋'，可能已经修改过了。", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
				}
			}
		}
	}
}

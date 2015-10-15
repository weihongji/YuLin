using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using Entities;
using Importer;
using Exporter;

namespace WinForm
{
	public partial class Main : Form
	{
		#region "Form level members"

		public Main() {
			InitializeComponent();
			SwitchToPanel("none");
		}

		private void SwitchToPanel(string panel) {
			panelImport.Visible = false;
			panelReport.Visible = false;

			switch (panel) {
				case "import":
					panelImport.Visible = true;
					break;
				case "report":
					panelReport.Visible = true;
					break;
				case "none":
					// Show nothing in the content area
					break;
				default:
					MessageBox.Show("Invalid panel name.", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
					break;
			}
		}

		private DateTime GetLastDayInMonth(DateTime date) {
			var dt = new DateTime(date.Year, date.Month, 1);
			return dt.AddMonths(1).AddDays(-1);
		}
		#endregion

		#region "Import Menu"
		private void menu_Mgmt_Import_Click(object sender, EventArgs e) {
			InitImportPanel();
			SwitchToPanel("import");
		}

		private void InitImportPanel() {
			var asOfDate = GetLastDayInMonth(DateTime.Today).AddMonths(-1);
			this.cmbYear.Text = asOfDate.Year.ToString();
			this.cmbMonth.Text = asOfDate.Month.ToString();

			this.lblImportLoan.Text = "";
			this.lblImportPublic.Text = "";
			this.lblImportPrivate.Text = "";
			this.lblImportNonAccrual.Text = "";
			this.lblImportOverdue.Text = "";
		}

		private void btnImportOK_Click(object sender, EventArgs e) {
			DateTime asOfDate;
			if (IsValidToImport(out asOfDate)) {
				if (MessageBox.Show(string.Format("确定您导入的数据是{0}的吗？", asOfDate.ToString("yyyy年M月")), this.Text, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No) {
					return;
				}

				string[] sourceFiles = {
						this.lblImportLoan.Text, 
						this.lblImportPublic.Text, this.lblImportPrivate.Text,
						this.lblImportNonAccrual.Text, this.lblImportOverdue.Text
					};
				var importer = new ExcelImporter();
				this.Cursor = Cursors.WaitCursor;
				try {
					var result = importer.CreateImport(asOfDate, sourceFiles);
					if (string.IsNullOrEmpty(result)) {
						MessageBox.Show(asOfDate.ToString("yyyy-MM") + "月份数据导入完毕", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
						InitImportPanel();
					}
					else {
						MessageBox.Show("Error: " + result, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
					}
				}
				catch (Exception ex) {
					MessageBox.Show(ex.Message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
					throw;
				}
				finally {
					this.Cursor = Cursors.Default;
				}
			}
		}

		private bool IsValidToImport(out DateTime asOfDate) {
			asOfDate = new DateTime(1900, 1, 1);

			if (cmbYear.Text == "") {
				MessageBox.Show("需要填写导入数据的年份", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				cmbYear.Focus();
				return false;
			}
			if (cmbMonth.Text == "") {
				MessageBox.Show("需要填写导入数据的月份", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				cmbMonth.Focus();
				return false;
			}

			string dateString = string.Format("{0}/{1}/1", cmbYear.Text, cmbMonth.Text);
			if (!DateTime.TryParse(dateString, out asOfDate)) {
				MessageBox.Show("数据的年份或月份无效", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				cmbYear.Focus();
				return false;
			}
			else if (asOfDate.Year < 2000 || GetLastDayInMonth(asOfDate) > DateTime.Today) {
				MessageBox.Show("年份或月份超出范围", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				cmbYear.Focus();
				return false;
			}

			if (this.lblImportLoan.Text == ""
					&& this.lblImportPublic.Text == "" && this.lblImportPrivate.Text == ""
					&& this.lblImportNonAccrual.Text == "" && this.lblImportOverdue.Text == ""
				) {
				MessageBox.Show("需要至少选择一个需要导入的源数据表", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				return false;
			}

			return true;
		}

		private void btnImportLoan_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportLoan.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportLoan.Text = "";
			}
		}

		private void btnImportPublic_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportPublic.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportPublic.Text = "";
			}
		}

		private void btnImportPrivate_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportPrivate.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportPrivate.Text = "";
			}
		}

		private void btnImportNonAccrual_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportNonAccrual.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportNonAccrual.Text = "";
			}
		}

		private void btnImportOverdue_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportOverdue.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportOverdue.Text = "";
			}
		}
		#endregion

		#region "Exit Menu"
		private void menu_Mgmt_Exit_Click(object sender, EventArgs e) {
			Application.Exit();
		}
		#endregion

		#region "Report Menu"
		private void InitReportPanel() {
			var dao = new SqlDbHelper();
			var table = dao.ExecuteDataTable("SELECT ImportDate, State FROM Import ORDER BY ImportDate DESC");
			this.cmbReportMonth.Items.Clear();
			if (table != null) {
				foreach (DataRow row in table.Rows) {
					var value = ((DateTime)row[0]).ToString("yyyy-MM");
					if ((short)row[1] != (short)XEnum.ImportState.Imported) {
						value += " *";
					}
					this.cmbReportMonth.Items.Add(value);
				}
			}
		}

		private bool IsValidToExport(out DateTime asOfDate) {
			asOfDate = new DateTime(1900, 1, 1);

			if (this.cmbReportMonth.Text == "") {
				MessageBox.Show("需要填写导入数据的月份", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				cmbReportMonth.Focus();
				return false;
			}
			else if (this.cmbReportMonth.Text.IndexOf('*') >= 0) {
				MessageBox.Show(this.cmbReportMonth.Text.Replace(" *", "") + "月份的数据的尚未全部导入系统", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				cmbReportMonth.Focus();
				return false;
			}

			var dateString = this.cmbReportMonth.Text.Replace("-", "/") + "/1";

			if (!DateTime.TryParse(dateString, out asOfDate)) {
				MessageBox.Show("数据月份无效", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				cmbReportMonth.Focus();
				return false;
			}
			else if (asOfDate.Year < 2000 || asOfDate.Year > DateTime.Today.Year) {
				MessageBox.Show("月份超出范围", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
				cmbReportMonth.Focus();
				return false;
			}

			return true;
		}

		private void menu_Report_LoanRisk_Click(object sender, EventArgs e) {
			InitReportPanel();
			SwitchToPanel("report");
		}

		private void btnExport_Click(object sender, EventArgs e) {
			DateTime asOfDate;
			if (IsValidToExport(out asOfDate)) {
				var exporter = new ExcelExporter(asOfDate);
				this.Cursor = Cursors.WaitCursor;
				try {
					var result = exporter.ExportData();
					if (string.IsNullOrEmpty(result)) {
						MessageBox.Show(asOfDate.ToString("yyyy-MM") + "月份报表已经导出到Excel文件", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
						InitImportPanel();
					}
					else {
						MessageBox.Show("Error: " + result, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
					}
				}
				catch (Exception ex) {
					MessageBox.Show(ex.Message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
					throw;
				}
				finally {
					this.Cursor = Cursors.Default;
				}
			}
		}
		#endregion
	}
}

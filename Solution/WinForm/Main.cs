﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Reporting
{
	public partial class Main : Form
	{
		#region "Form level members"
		private Logger logger = Logger.GetLogger("Main");
		private XEnum.ReportType currentReport = XEnum.ReportType.None;
		private List<TargetTable> _reports;

		public List<TargetTable> Reports {
			get {
				if (_reports == null) {
					_reports = TargetTable.GetList();
				}
				return _reports;
			}
		}

		public Main() {
			InitializeComponent();
			SwitchToPanel("none");
		}

		private void Main_Load(object sender, EventArgs e) {
			this.calendar.Left = 206;
			this.calendar.Visible = false;
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
					ShowError("Invalid panel name.");
					break;
			}
		}
		#endregion

		#region "Import Menu"
		private void menu_Mgmt_Import_Click(object sender, EventArgs e) {
			InitImportPanel();
			SwitchToPanel("import");
		}

		private void InitImportPanel() {
			this.lblImportLoan.Text = "";
			this.lblImportPublic.Text = "";
			this.lblImportPrivate.Text = "";
			this.lblImportNonAccrual.Text = "";
			this.lblImportOverdue.Text = "";
			this.lblImportYWNei.Text = "";
			this.lblImportYWWai.Text = "";
		}
		
		private void btnCalendar_Click(object sender, EventArgs e) {
			this.calendar.Show();
			this.calendar.Focus();
		}

		private void btnImportOK_Click(object sender, EventArgs e) {
			DateTime asOfDate;
			if (IsValidToImport(out asOfDate)) {
				if (MessageBox.Show(string.Format("确定您导入的数据是{0}的吗？", asOfDate.ToString("yyyy-M-d")), this.Text, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No) {
					return;
				}

				string[] sourceFiles = {
						"dummy", // 1-based array is required
						this.lblImportLoan.Text,
						this.lblImportPublic.Text, this.lblImportPrivate.Text,
						this.lblImportNonAccrual.Text, this.lblImportOverdue.Text,
						this.lblImportYWNei.Text, this.lblImportYWWai.Text
					};
				var importer = new Importer();
				this.Cursor = Cursors.WaitCursor;
				try {
					var startTime = DateTime.Now;
					var result = importer.CreateImport(asOfDate, sourceFiles);
					this.Cursor = Cursors.Default;
					if (string.IsNullOrEmpty(result)) {
						var seconds = Math.Round((DateTime.Now - startTime).TotalSeconds);
						var timeSpan = seconds > 3 ? string.Format("({0}秒)", seconds) : "";
						ShowInfo(string.Format("{0}月份数据导入完毕。{1}", asOfDate.ToString("yyyy-MM"), timeSpan));
					}
					else {
						ShowError(result);
					}
				}
				catch (Exception ex) {
					ShowError(ex.Message);
					logger.Error(ex);
				}
				finally {
					this.Cursor = Cursors.Default;
				}
			}
		}

		private bool IsValidToImport(out DateTime asOfDate) {
			asOfDate = new DateTime(1900, 1, 1);

			if (this.txtAsOfDate.Text == "") {
				ShowStop("需要填写数据日期");
				this.btnCalendar.Focus();
				return false;
			}

			string dateString = this.txtAsOfDate.Text;
			if (!DateTime.TryParse(dateString, out asOfDate)) {
				ShowStop("数据的日期无效");
				this.btnCalendar.Focus();
				return false;
			}
			if (asOfDate.Year < 2000 || asOfDate > DateTime.Today) {
				ShowStop("数据的日期超出范围");
				this.btnCalendar.Focus();
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

		private void btnImportYWNei_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportYWNei.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportYWNei.Text = "";
			}
		}

		private void btnImportYWWai_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportYWWai.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportYWWai.Text = "";
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
			var report = this.Reports.Single(x => x.Id == (int)currentReport);
			if (report == null) {
				ShowStop("Failed to get entity of current report.");
				return;
			}
			this.lblReportTitle.Text = report.Name;

			var dao = new SqlDbHelper();
			var table = dao.ExecuteDataTable("SELECT ImportDate, State FROM Import WHERE DAY(ImportDate + 1) = 1 ORDER BY ImportDate DESC");
			this.cmbReportMonth.Items.Clear();
			if (table != null) {
				foreach (DataRow row in table.Rows) {
					var value = ((DateTime)row[0]).ToString("yyyy-MM");
					if ((short)row[1] != (short)XEnum.ImportState.Imported) {
						value += " *";
					}
					this.cmbReportMonth.Items.Add(value);
				}

				// Select the latest one by default
				if (this.cmbReportMonth.Items.Count > 0) {
					if (this.cmbReportMonth.SelectedIndex < 0) {
						this.cmbReportMonth.SelectedIndex = 0;
					}
				}
			}
			this.txtReportPath.Text = BaseReport.GetReportFolder();
		}

		private bool IsValidToExport(out DateTime asOfDate) {
			asOfDate = new DateTime(1900, 1, 1);

			if (this.cmbReportMonth.Text == "") {
				ShowStop("需要填写导入数据的月份");
				cmbReportMonth.Focus();
				return false;
			}
			else if (this.cmbReportMonth.Text.IndexOf('*') >= 0) {
				ShowStop(this.cmbReportMonth.Text.Replace(" *", "") + "月份的数据的尚未全部导入系统");
				cmbReportMonth.Focus();
				return false;
			}

			var dateString = this.cmbReportMonth.Text.Replace("-", "/") + "/1";

			if (!DateTime.TryParse(dateString, out asOfDate)) {
				ShowStop("数据月份无效");
				cmbReportMonth.Focus();
				return false;
			}
			asOfDate = DateHelper.GetLastDayInMonth(asOfDate);
			if (asOfDate.Year < 2000 || asOfDate.Year > DateTime.Today.Year) {
				ShowStop("月份超出范围");
				cmbReportMonth.Focus();
				return false;
			}

			return true;
		}

		private void menu_Report_Item_Click(object sender, EventArgs e) {
			if (!(sender is ToolStripMenuItem)) {
				ShowStop("Un-expected sender.");
				return;
			}

			// Get current report type
			var reportMenuName = ((ToolStripMenuItem)sender).Name;
			var position = reportMenuName.IndexOf('_');
			if (position < 0) {
				ShowStop(string.Format("Incorrect report menu name '{0}' not following naming convention.", reportMenuName));
				return;
			}
			var nameCore = reportMenuName.Substring(position + 1);
			var reportType = XEnum.ReportType.None;
			if (Enum.TryParse<XEnum.ReportType>(nameCore, out reportType)) {
				this.currentReport = reportType;
			}
			else {
				ShowStop("Unknown report menu name: " + reportMenuName);
				return;
			}

			// Show report UI
			InitReportPanel();
			SwitchToPanel("report");
		}

		private void btnExport_Click(object sender, EventArgs e) {
			DateTime asOfDate;
			if (!IsValidToExport(out asOfDate)) {
				return;
			}
			this.Cursor = Cursors.WaitCursor;
			try {
				var exporter = new Exporter();
				var startTime = DateTime.Now; // Use to count time cost
				var result = exporter.ExportData(this.currentReport, asOfDate);
				this.Cursor = Cursors.Default;
				if (string.IsNullOrEmpty(result)) {
					var seconds = Math.Round((DateTime.Now - startTime).TotalSeconds);
					var timeSpan = seconds > 3 ? string.Format("({0}秒)", seconds) : ""; // Show time cost if longer than 3s
					ShowInfo(string.Format("报表导出完毕。{0}", timeSpan));
				}
				else {
					ShowError(result);
				}
			}
			catch (Exception ex) {
				logger.Error(ex);
				ShowError(ex.Message);
			}
			finally {
				this.Cursor = Cursors.Default;
			}
		}

		private void btnOpenReportFolder_Click(object sender, EventArgs e) {
			var path = this.txtReportPath.Text;
			if (string.IsNullOrWhiteSpace(path) || !Directory.Exists(path)) {
				ShowInfo("此目录尚不存在，请您导出报表后再打开此目录");
				return;
			}
			Process process = new Process();
			process.StartInfo.FileName = "explorer";
			process.StartInfo.Arguments = path;
			process.Start();
			process.WaitForExit();
			process.Close();
		}
		#endregion

		#region Utility functions
		private void ShowInfo(string msg) {
			MessageBox.Show(msg, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
		}

		private void ShowStop(string msg) {
			MessageBox.Show(msg, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Stop);
		}

		private void ShowError(string msg) {
			MessageBox.Show(msg, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
		}
		#endregion

		#region Calendar
		private void calendar_DateSelected(object sender, DateRangeEventArgs e) {
			this.txtAsOfDate.Text = this.calendar.SelectionStart.ToString("yyyy-M-d");
			this.calendar.Hide();
		}

		private void calendar_Leave(object sender, EventArgs e) {
			this.calendar.Hide();
		}

		private void panelImport_Click(object sender, EventArgs e) {
			this.calendar.Hide();
		}

		private void calendar_KeyDown(object sender, KeyEventArgs e) {
			if (e.KeyCode == Keys.Escape) {
				this.calendar.Hide();
			}
		}
		#endregion
	}
}

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Reporting
{
	public partial class frmMain : Form
	{
		#region "Form level members"
		private Logger logger = Logger.GetLogger("Main");
		private XEnum.ReportType currentReport = XEnum.ReportType.None;
		private List<TargetTable> _reports;
		private List<TableMapping> _selectedColumns;
		private List<string> _publicColumns;
		private List<string> _privateColumns;

		public List<TargetTable> Reports {
			get {
				if (_reports == null) {
					_reports = TargetTable.GetList();
				}
				return _reports;
			}
		}

		public List<TableMapping> SelectedColumns {
			get {
				if (_selectedColumns == null) {
					_selectedColumns = new List<TableMapping>();
				}
				return _selectedColumns;
			}
		}

		public List<string> SelectedColumns1 {
			get {
				if (_publicColumns == null) {
					_publicColumns = new List<string>();
				}
				return _publicColumns;
			}
		}

		public List<string> SelectedColumns2 {
			get {
				if (_privateColumns == null) {
					_privateColumns = new List<string>();
				}
				return _privateColumns;
			}
		}

		public frmMain() {
			InitializeComponent();
		}

		private void Main_Load(object sender, EventArgs e) {
 			this.calendarImport.Left = 206;
			this.calendarImport.Visible = false;
			this.btnSelectColumns.Visible = false;

			var defaultPanel = ConfigurationManager.AppSettings["defaultScreen"] ?? "about";
			if (defaultPanel.Equals("import")) {
				menuImport_Source_Click(null, null);
			}
			else if (defaultPanel.Equals("report")) {
				ShowReport(XEnum.ReportType.X_FXDKTB_D);
			}
			else {
				menuSystem_About_Click(null, null);
			}
		}

		private void menuSystem_About_Click(object sender, EventArgs e) {
			SwitchToPanel("about");
		}

		private void SwitchToPanel(string panel) {
			panelAbout.Visible = false;
			panelImport.Visible = false;
			panelReport.Visible = false;
			panelImportWJFL.Visible = false;

			switch (panel) {
				case "about":
					panelAbout.Visible = true;
					break;
				case "import":
					panelImport.Visible = true;
					break;
				case "report":
					panelReport.Visible = true;
					break;
				case "import_WJFL":
					panelImportWJFL.Visible = true;
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
		private void menuImport_Source_Click(object sender, EventArgs e) {
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
			this.txtImportDate.Text = "";
		}

		private void btnImport_Click(object sender, EventArgs e) {
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
						ShowInfo(string.Format("{0}的数据导入完毕。{1}", asOfDate.ToString("yyyy年M月d日"), timeSpan));
						InitImportPanel();
					}
					else {
						ShowError("导入发生错误");
					}
				}
				catch (Exception ex) {
					ShowError("导入发生错误");
					logger.Error(ex);
				}
				finally {
					this.Cursor = Cursors.Default;
				}
			}
		}

		private bool IsValidToImport(out DateTime asOfDate) {
			asOfDate = new DateTime(1900, 1, 1);

			if (this.txtImportDate.Text == "") {
				ShowStop("需要填写数据日期");
				this.txtImportDate.Focus();
				return false;
			}

			string dateString = this.txtImportDate.Text;
			if (!DateTime.TryParse(dateString, out asOfDate)) {
				ShowStop("数据的日期无效");
				this.txtImportDate.Focus();
				return false;
			}
			if (asOfDate.Year < 2000 || asOfDate > DateTime.Today) {
				ShowStop("数据的日期超出范围");
				this.txtImportDate.Focus();
				return false;
			}

			if (this.lblImportLoan.Text.Length > 0) {
				DateTime dt = DateHelper.Look4Date(this.lblImportLoan.Text);
				if (dt.Year > 2000) {
					if (dt != asOfDate) {
						ShowStop("《贷款欠款查询》的文件命名显示日期与所选的数据日期不一致。\r\n请检查输入的数据日期是否正确。");
						this.txtImportDate.Focus();
						return false;
					}
				}
			}

			return true;
		}

		private void btnImportLoan_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportLoan.Text = this.openFileDialog1.FileName;
				// Guess date from file name, like 贷款欠款查询_806050000_20151007.xls
				DateTime dt = DateHelper.Look4Date(this.openFileDialog1.FileName);
				if (dt.Year > 2000) {
					if (this.txtImportDate.Text == "") {
						this.txtImportDate.Text = dt.ToString("yyyy-M-d");
					}
				}
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

		private void menuImport_WJFL_Click(object sender, EventArgs e) {
			InitImportWJFLPanel();
			SwitchToPanel("import_WJFL");
		}

		private void btnImportWJFLOpener_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportWJFLPath.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportWJFLPath.Text = "";
			}
		}

		private void btnImportWJFL_Click(object sender, EventArgs e) {
			if (!IsValidToImportWJFL()) {
				return;
			}
			var filePath = this.lblImportWJFLPath.Text;
			DateTime asOfDate;
			var result = ExcelHelper.GetImportDateFromWJFL(filePath, out asOfDate);
			if (!string.IsNullOrEmpty(result)) {
				ShowError("导入发生错误");
				return;
			}
			var importer = new Importer();
			this.Cursor = Cursors.WaitCursor;
			try {
				var startTime = DateTime.Now;
				result = importer.UpdateWJFL(asOfDate, filePath);
				this.Cursor = Cursors.Default;
				if (string.IsNullOrEmpty(result)) {
					var seconds = Math.Round((DateTime.Now - startTime).TotalSeconds);
					var timeSpan = seconds > 3 ? string.Format("({0}秒)", seconds) : "";
					ShowInfo(string.Format("{0}数据的七级分类已经更新完毕。{1}", asOfDate.ToString("yyyy年M月d日"), timeSpan));
				}
				else {
					ShowError("导入发生错误");
				}
			}
			catch (Exception ex) {
				ShowError("导入发生错误");
				logger.Error(ex);
			}
			finally {
				this.Cursor = Cursors.Default;
			}
		}

		private bool IsValidToImportWJFL() {
			var filePath = this.lblImportWJFLPath.Text;
			if (filePath == "") {
				ShowStop("请选择风险贷款情况表的初表");
				this.btnImportWJFLOpener.Focus();
				return false;
			}
			else if (filePath.IndexOf(" - ") < 0) {
				if (MessageBox.Show("确定您所选择的文件为修订七级分类之后的风险贷款情况表吗？", this.Text, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No) {
					return false;
				}
			}

			return true;
		}

		private void InitImportWJFLPanel() {
			this.lblImportWJFLPath.Text = "";
		}

		private void menuImport_History_Click(object sender, EventArgs e) {
			var form = new frmImportHistory();
			form.Show();
		}
		#endregion

		#region "Exit Menu"
		private void menuSystem_Exit_Click(object sender, EventArgs e) {
			Application.Exit();
		}
		#endregion

		#region "Report Menu"
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
				ShowReport(reportType);
			}
			else {
				ShowStop("Unknown report menu name: " + reportMenuName);
				return;
			}
		}

		private void ShowAsOfDate2() {
			if (this.currentReport == XEnum.ReportType.C_XZDKMX_D || this.currentReport == XEnum.ReportType.C_JQDKMX_D) {
				this.cmbReportMonth2.Visible = true;
			}
			else {
				this.cmbReportMonth2.Visible = false;
			}
		}

		private void ShowSelectColumnButton() {
			if (this.currentReport.ToString().StartsWith("C_")) {
				this.btnSelectColumns.Visible = true;
			}
			else {
				this.btnSelectColumns.Visible = false;
			}
		}

		private void ShowReport(XEnum.ReportType reportType) {
			this.currentReport = reportType;

			// Show report UI
			InitReportPanel();
			SwitchToPanel("report");
		}

		private void InitReportPanel() {
			var report = this.Reports.Single(x => x.Id == (int)currentReport);
			if (report == null) {
				ShowStop("Failed to get entity of current report.");
				return;
			}

			this.lblReportTitle.Text = report.Name;
			this.SelectedColumns.Clear();
			this.SelectedColumns1.Clear();
			this.SelectedColumns2.Clear();
			ShowAsOfDate2();
			ShowSelectColumnButton();

			var dao = new SqlDbHelper();
			if (IsMonthly()) {
				this.lblExportDate.Text = "数据月份：";
				var table = dao.ExecuteDataTable("SELECT ImportDate, State FROM Import WHERE DAY(ImportDate + 1) = 1 ORDER BY ImportDate DESC");
				this.cmbReportMonth.Items.Clear();
				if (table != null) {
					foreach (DataRow row in table.Rows) {
						var value = ((DateTime)row[0]).ToString("yyyy-MM");
						if ((short)row[1] != (short)XEnum.ImportState.Complete) {
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
			}
			else {
				this.lblExportDate.Text = "数据日期：";
				var table = dao.ExecuteDataTable("SELECT ImportDate, State FROM Import ORDER BY ImportDate DESC");
				this.cmbReportMonth.Items.Clear();
				this.cmbReportMonth2.Items.Clear();
				if (table != null) {
					foreach (DataRow row in table.Rows) {
						var value = ((DateTime)row[0]).ToString("yyyy-MM-dd");
						this.cmbReportMonth.Items.Add(value);
						this.cmbReportMonth2.Items.Add(value);
					}

					// Select the latest one by default
					if (this.cmbReportMonth.Items.Count > 0) {
						if (this.cmbReportMonth.SelectedIndex < 0) {
							this.cmbReportMonth.SelectedIndex = 0;
						}
					}
					if (this.cmbReportMonth2.Items.Count > 0) {
						if (this.cmbReportMonth2.SelectedIndex < 0) {
							this.cmbReportMonth2.SelectedIndex = 0;
						}
					}
				}
			}

			this.txtReportPath.Text = BaseReport.GetReportFolder();
		}

		private bool IsValidToExport(out DateTime asOfDate, out DateTime asOfDate2) {
			asOfDate = new DateTime(1900, 1, 1);
			asOfDate2 = new DateTime(1900, 1, 1);

			var monthly = IsMonthly();
			var dateText = this.cmbReportMonth.Text;

			if (dateText == "") {
				ShowStop("需要填写导出数据的月份");
				this.cmbReportMonth.Focus();
				return false;
			}
			else if (dateText.IndexOf('*') >= 0) {
				ShowStop(dateText.Replace(" *", "") + "月份的数据的尚未全部导入系统");
				this.cmbReportMonth.Focus();
				return false;
			}

			if (monthly) {
				dateText = dateText.Replace("-", "/") + "/1";
			}

			if (!DateTime.TryParse(dateText, out asOfDate)) {
				ShowStop("填写的月份格式错误");
				this.cmbReportMonth.Focus();
				return false;
			}

			if (monthly) {
				asOfDate = DateHelper.GetLastDayInMonth(asOfDate);
			}

			if (asOfDate.Year < 2000 || asOfDate > DateTime.Today) {
				ShowStop("日期超出范围");
				this.cmbReportMonth.Focus();
				return false;
			}

			if (this.cmbReportMonth2.Visible) {
				if (!DateTime.TryParse(this.cmbReportMonth2.Text, out asOfDate2)) {
					ShowStop("第二个日期的格式错误");
					this.cmbReportMonth2.Focus();
					return false;
				}
			}

			if (asOfDate == asOfDate2) {
				ShowStop("相同日期不能比较");
				this.cmbReportMonth.Focus();
				return false;
			}

			return true;
		}

		private bool IsMonthly() {
			return currentReport.ToString().EndsWith("_M") || currentReport.ToString().EndsWith("_S");
		}

		private void btnExport_Click(object sender, EventArgs e) {
			DateTime asOfDate, asOfDate2;
			if (!IsValidToExport(out asOfDate, out asOfDate2)) {
				return;
			}
			var exporter = new Exporter();
			if (this.currentReport == XEnum.ReportType.C_DQDKQK_M) {
				if (this.SelectedColumns1.Count == 0) {
					this.SelectedColumns1.AddRange(TableMapping.GetFrozenColumnNames("ImportPublic"));
					this.SelectedColumns1.AddRange(new string[] { "彻底从我行退出", "倒贷", "逾期", "化解方案" });
				}
				if (this.SelectedColumns2.Count == 0) {
					this.SelectedColumns2.AddRange(TableMapping.GetFrozenColumnNames("ImportPrivate"));
					this.SelectedColumns2.AddRange(new string[] { "彻底从我行退出", "倒贷", "展期", "逾期", "化解方案" });
				}
			}
			else if (this.currentReport == XEnum.ReportType.C_XZDKMX_D) {
				if (this.SelectedColumns.Count == 0) {
					this.SelectedColumns.AddRange(TableMapping.GetFrozenColumns(Consts.C_XZDKMX_D));
				}
				exporter.AsOfDate2 = asOfDate2;
				exporter.Columns = this.SelectedColumns;
			}
			else if (this.currentReport == XEnum.ReportType.C_JQDKMX_D) {
				if (this.SelectedColumns.Count == 0) {
					this.SelectedColumns.AddRange(TableMapping.GetFrozenColumns(Consts.C_JQDKMX_D));
				}
				exporter.AsOfDate2 = asOfDate2;
				exporter.Columns = this.SelectedColumns;
			}
			this.Cursor = Cursors.WaitCursor;
			try {
				var startTime = DateTime.Now; // Use to count time cost
				var result = exporter.ExportData(this.currentReport, asOfDate, asOfDate2, this.SelectedColumns1, this.SelectedColumns2);
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
			catch (IOException ex) {
				if (ex.Message.IndexOf("it is being used by another process") > 0) {
					ShowError("原来报表文件已经被打开，请先从Excel里关闭该报表然后再导出。");
				}
				else {
					ShowError("请关闭所有excel，然后再尝试导出报表。");
				}
				logger.Error(ex);
			}
			catch (Exception ex) {
				logger.Error(ex);
				ShowError("导出发生错误");
			}
			finally {
				this.Cursor = Cursors.Default;
			}
		}

		private void btnSelectColumns_Click(object sender, EventArgs e) {
			if (this.currentReport == XEnum.ReportType.C_DQDKQK_M) {
				var form = new frmCustomizeDQDK(this.SelectedColumns1, this.SelectedColumns2);
				var result = form.ShowDialog(this);
				if (result == System.Windows.Forms.DialogResult.OK) {
					this.SelectedColumns1.Clear();
					this.SelectedColumns2.Clear();
					this.SelectedColumns1.AddRange(TableMapping.GetFrozenColumnNames("ImportPublic"));
					this.SelectedColumns1.AddRange(form.PublicColumns);
					this.SelectedColumns1.AddRange(new string[] { "彻底从我行退出", "倒贷", "逾期", "化解方案" });

					this.SelectedColumns2.AddRange(TableMapping.GetFrozenColumnNames("ImportPrivate"));
					this.SelectedColumns2.AddRange(form.PrivateColumns);
					this.SelectedColumns2.AddRange(new string[] { "彻底从我行退出", "倒贷", "展期", "逾期", "化解方案" });
				}
			}
			else if (this.currentReport == XEnum.ReportType.C_XZDKMX_D) {
				var form = new frmCustomizeOne(this.SelectedColumns) { MappingTable = Consts.C_XZDKMX_D, FormTitle = "新增贷款明细表自定义" };
				var result = form.ShowDialog(this);
				if (result == System.Windows.Forms.DialogResult.OK) {
					this.SelectedColumns.Clear();
					this.SelectedColumns.AddRange(TableMapping.GetFrozenColumns(Consts.C_XZDKMX_D));
					this.SelectedColumns.AddRange(form.Columns);
				}
			}
			else if (this.currentReport == XEnum.ReportType.C_JQDKMX_D) {
				var form = new frmCustomizeOne(this.SelectedColumns) { MappingTable = Consts.C_JQDKMX_D, FormTitle = "结清贷款明细表自定义" };
				var result = form.ShowDialog(this);
				if (result == System.Windows.Forms.DialogResult.OK) {
					this.SelectedColumns.Clear();
					this.SelectedColumns.AddRange(TableMapping.GetFrozenColumns(Consts.C_JQDKMX_D));
					this.SelectedColumns.AddRange(form.Columns);
				}
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

		private void btnCalendarImport_Click(object sender, EventArgs e) {
			this.calendarImport.Show();
			this.calendarImport.Focus();
		}

		private void calendarImport_DateSelected(object sender, DateRangeEventArgs e) {
			this.txtImportDate.Text = this.calendarImport.SelectionStart.ToString("yyyy-M-d");
			this.calendarImport.Hide();
		}

		private void calendarImport_Leave(object sender, EventArgs e) {
			this.calendarImport.Hide();
		}

		private void panelImport_Click(object sender, EventArgs e) {
			this.calendarImport.Hide();
		}

		private void calendarImport_KeyDown(object sender, KeyEventArgs e) {
			if (e.KeyCode == Keys.Escape) {
				this.calendarImport.Hide();
			}
		}

		#endregion
	}
}

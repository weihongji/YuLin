using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading;
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
		private string[] importYWNeiFiles, importYWWaiFiles;

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
			StartSqlServer();

			this.calendarImport.Left = 206;
			this.calendarImport.Visible = false;
			this.btnSelectColumns.Visible = false;

			var defaultPanel = ConfigurationManager.AppSettings["defaultScreen"] ?? "about";
			if (defaultPanel.Equals("import")) {
				menuImport_Source_Click(null, null);
			}
			else if (defaultPanel.StartsWith("report")) {
				if (defaultPanel.IndexOf('|') > 0) {
					ShowReport(defaultPanel.Substring(defaultPanel.IndexOf('|') + 1));
				}
				else {
					ShowReport(XEnum.ReportType.X_FXDKTB_D);
				}
			}
			else {
				menuSystem_About_Click(null, null);
			}
			var version = new Version(Application.ProductVersion);
			if (version != null) {
				this.lblVersion.Text = string.Format("系统版本：{0}", version);
			}
			object[] attributes = Assembly.GetExecutingAssembly().GetCustomAttributes(typeof(AssemblyTitleAttribute), false);
			if (attributes.Length > 0) {
				AssemblyTitleAttribute titleAttribute = (AssemblyTitleAttribute)attributes[0];
				if (titleAttribute.Title != "")
					this.lblReleaseDate.Text = string.Format("发布日期：{0}", titleAttribute.Title);
			}

			var licenseTo = ConfigurationManager.AppSettings["LicenseTo"];
			if (!string.IsNullOrEmpty(licenseTo) && licenseTo.Length == 6) {
				licenseTo = string.Format("20{0}-{1}-{2}", licenseTo.Substring(0, 2), licenseTo.Substring(2, 2), licenseTo.Substring(4, 2));
				DateTime licenseDate;
				if (DateTime.TryParse(licenseTo, out licenseDate)) {
					if (DateTime.Today > licenseDate.AddMonths(-1) && DateTime.Today <= licenseDate) {
						ShowInfo(string.Format("报表系统将于{0}到期，请尽快联系售后服务解决，以免影响您的使用。", licenseDate.ToString("M月d日")));
					}
					else if (DateTime.Today > licenseDate) {
						ShowInfo("报表系统使用期限已经结束，请联系该系统的售后服务。");
						menuSystem_Exit_Click(null, null);
					}
				}
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
			this.lblImportLoanSF.Text = "";

			this.importYWNeiFiles = new string[0];
			this.importYWWaiFiles = new string[0];
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
						string.Join("|", importYWNeiFiles),
						string.Join("|", importYWWaiFiles),
						this.lblImportLoanSF.Text
					};
				var importer = new ImporterSF();
				this.Cursor = Cursors.WaitCursor;
				try {
					var startTime = DateTime.Now;
					var result = importer.CreateImport(asOfDate, sourceFiles);
					this.Cursor = Cursors.Default;
					if (string.IsNullOrEmpty(result)) {
						var seconds = Math.Round((DateTime.Now - startTime).TotalSeconds);
						var timeSpan = seconds > 3 ? string.Format("({0}秒)", seconds) : "";
						ShowInfo(string.Format("{0}的数据导入完毕。{1}", asOfDate.ToString("yyyy年M月d日"), timeSpan));
						logger.DebugFormat("Import done. {0} seconds costed.", seconds);
						InitImportPanel();
					}
					else {
						ShowError(result);
					}
				}
				catch (System.Data.SqlClient.SqlException ex) {
					logger.Error("Error in btnImport_Click:\r\n", ex);
					ShowError("数据库访问发生错误，请确保数据库可以访问。");
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

			if (this.lblImportLoanSF.Text.Length > 0) {
				DateTime dt = DateHelper.Look4Date(this.lblImportLoanSF.Text);
				if (dt.Year > 2000) {
					if (dt != asOfDate) {
						ShowStop("《贷款欠款查询（神府）》的文件命名显示日期与所选的数据日期不一致。\r\n请检查输入的数据日期是否正确。");
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

		private void btnImportLoanSF_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportLoanSF.Text = this.openFileDialog1.FileName;
				// Guess date from file name, like 贷款欠款查询_806050000_20151007.xls
				DateTime dt = DateHelper.Look4Date(this.openFileDialog1.FileName);
				if (dt.Year > 2000) {
					if (this.txtImportDate.Text == "") {
						this.txtImportDate.Text = dt.ToString("yyyy-M-d");
					}
				}
			}
			else {
				this.lblImportLoanSF.Text = "";
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
			if (this.openFileMultiSelect.ShowDialog() == DialogResult.OK) {
				if (this.openFileMultiSelect.FileNames.Length == 1) {
					this.lblImportYWNei.Text = this.openFileMultiSelect.FileNames[0];
				}
				else {
					this.lblImportYWNei.Text = string.Format("{0} 个文件被选中", this.openFileMultiSelect.FileNames.Length);
				}
				this.importYWNeiFiles = this.openFileMultiSelect.FileNames;
			}
			else {
				this.lblImportYWNei.Text = "";
				this.importYWNeiFiles = new string[0];
			}
		}

		private void btnImportYWWai_Click(object sender, EventArgs e) {
			if (this.openFileMultiSelect.ShowDialog() == DialogResult.OK) {
				if (this.openFileMultiSelect.FileNames.Length == 1) {
					this.lblImportYWWai.Text = this.openFileMultiSelect.FileNames[0];
				}
				else {
					this.lblImportYWWai.Text = string.Format("{0} 个文件被选中", this.openFileMultiSelect.FileNames.Length);
				}
				this.importYWWaiFiles = this.openFileMultiSelect.FileNames;
			}
			else {
				this.lblImportYWWai.Text = "";
				this.importYWWaiFiles = new string[0];
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

		private void btnImportWJFLOpenerSF_Click(object sender, EventArgs e) {
			if (this.openFileDialog1.ShowDialog() == DialogResult.OK) {
				this.lblImportWJFLPathSF.Text = this.openFileDialog1.FileName;
			}
			else {
				this.lblImportWJFLPathSF.Text = "";
			}
		}

		private void btnImportWJFL_Click(object sender, EventArgs e) {
			ImportWJFL_YL();
			ImportWJFL_SF();
		}

		private void ImportWJFL_YL() {
			if (!IsValidToImportWJFL(this.lblImportWJFLPath.Text)) {
				return;
			}
			var filePath = this.lblImportWJFLPath.Text;
			DateTime asOfDate;
			var result = ExcelHelper.GetImportDateFromWJFL(filePath, out asOfDate);
			if (!string.IsNullOrEmpty(result)) {
				ShowError(result);
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
					ShowInfo(string.Format("榆林{0}数据的七级分类已经更新完毕。{1}", asOfDate.ToString("yyyy年M月d日"), timeSpan));
				}
				else {
					ShowError(result);
				}
			}
			catch (IOException ex) {
				if (ex.Message.IndexOf("it is being used by another process") > 0) {
					ShowError("五级分类文件已经被打开，请先从Excel里关闭该报表然后再导入。");
				}
				else {
					ShowError("文件处理发生错误，可能路径不存在或者excel文件正在被使用。");
				}
				logger.Error(ex);
			}
			catch (System.Data.SqlClient.SqlException ex) {
				logger.Error("Error in ImportWJFL_YL:\r\n", ex);
				ShowError("数据库访问发生错误，请确保数据库可以访问。");
			}
			catch (Exception ex) {
				ShowError("导入发生错误");
				logger.Error(ex);
			}
			finally {
				this.Cursor = Cursors.Default;
			}
		}

		private void ImportWJFL_SF() {
			if (!IsValidToImportWJFL(this.lblImportWJFLPathSF.Text)) {
				return;
			}
			var filePath = this.lblImportWJFLPathSF.Text;
			DateTime asOfDate;
			var result = ExcelHelper.GetImportDateFromWJFLSF(filePath, out asOfDate);
			if (!string.IsNullOrEmpty(result)) {
				ShowError(result);
				return;
			}
			var importer = new ImporterSF();
			this.Cursor = Cursors.WaitCursor;
			try {
				var startTime = DateTime.Now;
				result = importer.UpdateWJFL(asOfDate, filePath);
				this.Cursor = Cursors.Default;
				if (string.IsNullOrEmpty(result)) {
					var seconds = Math.Round((DateTime.Now - startTime).TotalSeconds);
					var timeSpan = seconds > 3 ? string.Format("({0}秒)", seconds) : "";
					ShowInfo(string.Format("神府{0}数据的七级分类已经更新完毕。{1}", asOfDate.ToString("yyyy年M月d日"), timeSpan));
				}
				else {
					ShowError(result);
				}
			}
			catch (IOException ex) {
				if (ex.Message.IndexOf("it is being used by another process") > 0) {
					ShowError("五级分类文件已经被打开，请先从Excel里关闭该报表然后再导入。");
				}
				else {
					ShowError("请关闭所有excel，然后再尝试导出报表。");
				}
				logger.Error(ex);
			}
			catch (System.Data.SqlClient.SqlException ex) {
				logger.Error("Error in ImportWJFL_SF:\r\n", ex);
				ShowError("数据库访问发生错误，请确保数据库可以访问。");
			}
			catch (Exception ex) {
				ShowError("导入发生错误");
				logger.Error(ex);
			}
			finally {
				this.Cursor = Cursors.Default;
			}
		}

		private bool IsValidToImportWJFL(string filePath) {
			if (filePath == "") {
				//ShowStop("请选择风险贷款情况表的初表");
				//this.btnImportWJFLOpener.Focus();
				return false;
			}
			//else if (filePath.IndexOf(" - ") < 0) {
			//	if (MessageBox.Show("确定您所选择的文件为修订七级分类之后的风险贷款情况表吗？", this.Text, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No) {
			//		return false;
			//	}
			//}

			return true;
		}

		private void InitImportWJFLPanel() {
			this.lblImportWJFLPath.Text = "";
			this.lblImportWJFLPathSF.Text = "";
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
			ShowReport(nameCore);
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

		private void ShowReport(string reportName) {
			var reportType = XEnum.ReportType.None;
			if (Enum.TryParse<XEnum.ReportType>(reportName, out reportType)) {
				try {
					ShowReport(reportType);
				}
				catch (System.Data.SqlClient.SqlException ex) {
					logger.Error("Error in ShowReport:\r\n", ex);
					ShowError("数据库访问发生错误，请确保数据库可以访问。");
				}
				catch (Exception ex) {
					logger.Error("Error in ShowReport:\r\n", ex);
					ShowError(ex.Message);
				}
			}
			else {
				ShowStop("Unknown report menu name: " + reportName);
				return;
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
			var lastSelectValue = "";
			var lastSelectValue2 = "";
			if (IsMonthly()) {
				this.lblExportDate.Text = "数据月份：";
				var table = dao.ExecuteDataTable("SELECT ImportDate, dbo.sfGetImportStatus(ImportDate) AS status FROM Import WHERE DAY(ImportDate + 1) = 1 ORDER BY ImportDate DESC");
				if (this.cmbReportMonth.SelectedIndex >= 0) {
					lastSelectValue = this.cmbReportMonth.Text;
				}
				this.cmbReportMonth.Items.Clear();
				if (table != null) {
					foreach (DataRow row in table.Rows) {
						var value = ((DateTime)row[0]).ToString("yyyy-MM");
						if (!((string)row[1]).StartsWith("1111111")) {
							value += " *";
						}
						this.cmbReportMonth.Items.Add(value);
						if (!string.IsNullOrEmpty(lastSelectValue) && value.Equals(lastSelectValue)) {
							this.cmbReportMonth.Text = value;
						}
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
				var table = dao.ExecuteDataTable("SELECT ImportDate FROM Import ORDER BY ImportDate DESC");
				if (this.cmbReportMonth.SelectedIndex >= 0) {
					lastSelectValue = this.cmbReportMonth.Text;
				}
				if (this.cmbReportMonth2.SelectedIndex >= 0) {
					lastSelectValue2 = this.cmbReportMonth2.Text;
				}
				this.cmbReportMonth.Items.Clear();
				this.cmbReportMonth2.Items.Clear();
				if (table != null) {
					foreach (DataRow row in table.Rows) {
						var value = ((DateTime)row[0]).ToString("yyyy-MM-dd");
						this.cmbReportMonth.Items.Add(value);
						this.cmbReportMonth2.Items.Add(value);
						if (!string.IsNullOrEmpty(lastSelectValue) && value.Equals(lastSelectValue)) {
							this.cmbReportMonth.Text = value;
						}
						if (!string.IsNullOrEmpty(lastSelectValue2) && value.Equals(lastSelectValue2)) {
							this.cmbReportMonth2.Text = value;
						}
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

		private bool IsValidToExport(out DateTime asOfDate, out DateTime asOfDate2, bool quiet = false) {
			asOfDate = new DateTime(1900, 1, 1);
			asOfDate2 = new DateTime(1900, 1, 1);

			var monthly = IsMonthly();
			var dateText = this.cmbReportMonth.Text;

			if (dateText == "") {
				if (!quiet) {
					ShowStop("需要填写导出数据的月份");
					this.cmbReportMonth.Focus();
				}
				return false;
			}
			else if (dateText.IndexOf('*') >= 0) {
				if (!quiet) {
					ShowStop(dateText.Replace(" *", "") + "月份的数据的尚未全部导入系统");
					this.cmbReportMonth.Focus();
				}
				return false;
			}

			if (monthly) {
				dateText = dateText.Replace("-", "/") + "/1";
			}

			if (!DateTime.TryParse(dateText, out asOfDate)) {
				if (!quiet) {
					ShowStop("填写的月份格式错误");
					this.cmbReportMonth.Focus();
				}
				return false;
			}

			if (monthly) {
				asOfDate = DateHelper.GetLastDayInMonth(asOfDate);
			}

			if (asOfDate.Year < 2000 || asOfDate > DateTime.Today) {
				if (!quiet) {
					ShowStop("日期超出范围");
					this.cmbReportMonth.Focus();
				}
				return false;
			}

			if (this.cmbReportMonth2.Visible) {
				if (!DateTime.TryParse(this.cmbReportMonth2.Text, out asOfDate2)) {
					if (!quiet) {
						ShowStop("第二个日期的格式错误");
						this.cmbReportMonth2.Focus();
					}
					return false;
				}
			}

			if (asOfDate == asOfDate2) {
				if (!quiet) {
					ShowStop("相同日期不能比较");
					this.cmbReportMonth.Focus();
				}
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
					ShowError("报表文件已经被打开，请先从Excel里关闭该报表然后再导出。");
				}
				else {
					ShowError("导出发生错误");
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
			DateTime asOfDate, asOfDate2;
			if (IsValidToExport(out asOfDate, out asOfDate2, true)) {
				if (asOfDate2 > asOfDate) {
					asOfDate = asOfDate2;
				}
				var path2 = BaseReport.GetReportFolder(asOfDate);
				if (Directory.Exists(path2)) {
					path = path2;
				}
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
			if (string.IsNullOrEmpty(msg)) {
				return;
			}
			if (msg.IndexOf("Exception") >= 0) {
				msg = "发生错误";
			}
			ShowErrorDialog(msg, this.Text);
		}

		public static void ShowErrorDialog(string msg, string title) {
			MessageBox.Show(msg, title, MessageBoxButtons.OK, MessageBoxIcon.Error);
		}

		private void StartSqlServer() {
			var o = new BackgroundThread();
			var thread = new Thread(new ThreadStart(o.StartSqlServer));
			thread.Start();
			// Spin for a while waiting for the started thread to become alive
			while (!thread.IsAlive);
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

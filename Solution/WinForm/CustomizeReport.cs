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
	public partial class frmCustomizeReport : Form
	{
		const string TABLENAME = "IMPORTPUBLIC";
		private List<TableMapping> colmMapping;
		private XEnum.ReportType currentReport;

		private DateTime _asOfDate { get; set; }

		public frmCustomizeReport(DateTime asOfDate) {
			InitializeComponent();
			currentReport = XEnum.ReportType.C_DQDJQK_M;
			this._asOfDate = asOfDate;
			this.Text = this._asOfDate.Month.ToString() + "月到期贷款情况表";
			this.lblReportTitle.Text = this.Text;
		}

		private void InitialForm() {
			colmMapping = TableMapping.GetMappingList(TABLENAME);

			colmMapping.Where(x => x.Mode == MappingMode.Custom);
			BindListBox(optionalColList, colmMapping.Where(x => x.Mode != MappingMode.Frozen));
			var customList = colmMapping.Where(x => x.Mode == MappingMode.Custom);
			BindListBox(selectedColList, colmMapping.Where(x => x.Mode == MappingMode.Frozen));
		}
		private void BindListBox(ListBox box, IEnumerable<TableMapping> list) {
			box.Items.Clear();
			box.Items.AddRange(list.ToArray());
		}

		private void Form1_Load(object sender, EventArgs e) {
			InitialForm();
		}

		private void btnAdd_Click(object sender, EventArgs e) {
			MoveBoxItem(optionalColList, selectedColList);

		}
		private void MoveBoxItem(ListBox src, ListBox dest) {
			if (src.SelectedItem == null) {
				return;
			}
			if (((TableMapping)src.SelectedItem).Mode == MappingMode.Frozen) {
				return;
			}
			var selIndex = src.SelectedIndex - 1;
			dest.Items.Add(src.SelectedItem);
			src.Items.Remove(src.SelectedItem);
			if (src.Items.Count > 0) {
				src.SelectedIndex = selIndex < 0 ? 0 : selIndex;
			}
			src.Focus();
		}

		private void btnRemove_Click(object sender, EventArgs e) {
			MoveBoxItem(selectedColList, optionalColList);
		}

		private void runReport_Click(object sender, EventArgs e) {
			var exporter = new Exporter();
			var colList = new List<string>();
			var empList = new List<string>();

			foreach (TableMapping itm in selectedColList.Items) {
				colList.Add(itm.ColName);
			}
			colList.AddRange(new string[] { "彻底从我行退出", "倒贷", "逾期", "化解方案" });

			var result = exporter.ExportData(this.currentReport, this._asOfDate, string.Join(",", colList));
			if (string.IsNullOrEmpty(result)) {
				MessageBox.Show(this.Text + "导出完毕", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
				this.Close();
			}
			else {
				MessageBox.Show(result, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}
	}
}

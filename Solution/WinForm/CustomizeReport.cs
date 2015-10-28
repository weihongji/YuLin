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
		public List<string> SelectedColumns { get; set; }
		private List<TableMapping> colmMapping;

		public frmCustomizeReport() {
			InitializeComponent();
			this.SelectedColumns = new List<string>();
			this.Text = "期贷款情况表自定义";
			this.lblReportTitle.Text = this.Text;
		}

		private void InitialForm() {
			colmMapping = TableMapping.GetMappingList(TABLENAME);

			colmMapping.Where(x => x.Mode == MappingMode.Custom);
			BindListBox(optionalColList, colmMapping.Where(x => x.Mode != MappingMode.Frozen));
			var customList = colmMapping.Where(x => x.Mode == MappingMode.Custom);
			//BindListBox(selectedColList, colmMapping.Where(x => x.Mode == MappingMode.Frozen));
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
			var seletedItems = new List<object>();
			foreach (var item in src.SelectedItems) {
				seletedItems.Add(item);
			}
			dest.Items.AddRange(seletedItems.ToArray());
			foreach (var item in seletedItems) {
				src.Items.Remove(item);
			}
			if (src.Items.Count > 0) {
				src.SelectedIndex = selIndex < 0 ? 0 : selIndex;
			}
			src.Focus();
		}

		private void btnRemove_Click(object sender, EventArgs e) {
			MoveBoxItem(selectedColList, optionalColList);
		}

		private void runReport_Click(object sender, EventArgs e) {
			this.SelectedColumns.Clear();
			foreach (TableMapping itm in selectedColList.Items) {
				this.SelectedColumns.Add(itm.ColName);
			}

			this.Close();
		}
	}
}

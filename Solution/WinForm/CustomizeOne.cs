﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Reporting
{
	public partial class frmCustomizeOne : Form
	{
		public List<TableMapping> Columns { get; set; }
		private List<TableMapping> mappings;

		public string FormTitle { get; set; }
		public string MappingTable { get; set; }

		public frmCustomizeOne() {
			InitializeComponent();
			this.Columns = new List<TableMapping>();
		}

		private void frmCustomizeReport_Load(object sender, EventArgs e) {
			InitialForm();
		}

		private void InitialForm() {
			this.Text = FormTitle;
			mappings = TableMapping.GetMappingList(MappingTable);
			BindListBox(listBoxCandidates, mappings.Where(x => x.Mode == MappingMode.Custom));
		}

		private void BindListBox(ListBox box, IEnumerable<TableMapping> list) {
			box.Items.Clear();
			box.Items.AddRange(list.ToArray());
		}

		private void btnAdd_Click(object sender, EventArgs e) {
			MoveBoxItem(listBoxCandidates, listBoxSelection);
		}

		private void btnRemove_Click(object sender, EventArgs e) {
			MoveBoxItem(listBoxSelection, listBoxCandidates);
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

		private void btnOK_Click(object sender, EventArgs e) {
			this.Columns.Clear();
			foreach (TableMapping item in listBoxSelection.Items) {
				this.Columns.Add(item);
			}

			this.Close();
		}
	}
}

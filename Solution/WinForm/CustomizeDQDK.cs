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
	public partial class frmCustomizeDQDK : Form
	{
		public List<string> PublicColumns { get; private set; }
		public List<string> PrivateColumns { get; private set; }

		private List<TableMapping> publicMappings;
		private List<TableMapping> privateMappings;

		public frmCustomizeDQDK() : this(null, null) { }

		public frmCustomizeDQDK(List<string> publics, List<string> privates) {
			InitializeComponent();
			this.PublicColumns = new List<string>();
			this.PrivateColumns = new List<string>();
			SetColumns(publics, privates);
		}

		private void frmCustomizeReport_Load(object sender, EventArgs e) {
			InitialForm();
		}

		private void InitialForm() {
			publicMappings = TableMapping.GetMappingList("ImportPublic");
			privateMappings = TableMapping.GetMappingList("ImportPrivate");

			BindListBox(listBoxPublicCandidates, publicMappings.Where(x => x.Mode == MappingMode.Custom));
			BindListBox(listBoxPrivateCandidates, privateMappings.Where(x => x.Mode == MappingMode.Custom));

			// Load selected columns
			for (int i = 0; i < this.listBoxPublicCandidates.Items.Count; i++) {
				var item = (TableMapping)this.listBoxPublicCandidates.Items[i];
				if (this.PublicColumns.Any(x => x.Equals(item.ColName))) {
					this.listBoxPublicCandidates.Items.RemoveAt(i--);
					this.listBoxPublicSelection.Items.Add(item);
				}
			}
			for (int i = 0; i < this.listBoxPrivateCandidates.Items.Count; i++) {
				var item = (TableMapping)this.listBoxPrivateCandidates.Items[i];
				if (this.PrivateColumns.Any(x => x.Equals(item.ColName))) {
					this.listBoxPrivateCandidates.Items.RemoveAt(i--);
					this.listBoxPrivateSelection.Items.Add(item);
				}
			}
		}

		private void BindListBox(ListBox box, IEnumerable<TableMapping> list) {
			box.Items.Clear();
			box.Items.AddRange(list.ToArray());
		}

		// Selected
		private void btnPublicAdd_Click(object sender, EventArgs e) {
			MoveBoxItem(listBoxPublicCandidates, listBoxPublicSelection);
		}

		private void btnPublicRemove_Click(object sender, EventArgs e) {
			MoveBoxItem(listBoxPublicSelection, listBoxPublicCandidates);
		}

		private void btnPrivateAdd_Click(object sender, EventArgs e) {
			MoveBoxItem(listBoxPrivateCandidates, listBoxPrivateSelection);
		}

		private void btnPrivateRemove_Click(object sender, EventArgs e) {
			MoveBoxItem(listBoxPrivateSelection, listBoxPrivateCandidates);
		}

		// ALL
		private void btnPublicAddAll_Click(object sender, EventArgs e) {
			SelectAllItems(listBoxPublicCandidates);
			MoveBoxItem(listBoxPublicCandidates, listBoxPublicSelection);
		}

		private void btnPublicRemoveAll_Click(object sender, EventArgs e) {
			SelectAllItems(listBoxPublicSelection);
			MoveBoxItem(listBoxPublicSelection, listBoxPublicCandidates);
		}

		private void btnPrivateAddAll_Click(object sender, EventArgs e) {
			SelectAllItems(listBoxPrivateCandidates);
			MoveBoxItem(listBoxPrivateCandidates, listBoxPrivateSelection);
		}

		private void btnPrivateRemoveAll_Click(object sender, EventArgs e) {
			SelectAllItems(listBoxPrivateSelection);
			MoveBoxItem(listBoxPrivateSelection, listBoxPrivateCandidates);
		}

		private void SelectAllItems(ListBox listBox) {
			for (int i = 0; i < listBox.Items.Count; i++) {
				listBox.SelectedItems.Add(listBox.Items[i]);
			}
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
			this.PublicColumns.Clear();
			foreach (TableMapping itm in listBoxPublicSelection.Items) {
				this.PublicColumns.Add(itm.ColName);
			}

			this.PrivateColumns.Clear();
			foreach (TableMapping itm in listBoxPrivateSelection.Items) {
				this.PrivateColumns.Add(itm.ColName);
			}
			this.DialogResult = System.Windows.Forms.DialogResult.OK;
			this.Close();
		}

		private void btnCancel_Click(object sender, EventArgs e) {
			this.Close();
		}

		public void SetColumns(List<string> publics, List<string> privates) {
			this.PublicColumns.Clear();
			this.PrivateColumns.Clear();
			if (publics != null && publics.Count > 0) {
				this.PublicColumns.AddRange(publics);
			}
			if (privates != null && privates.Count > 0) {
				this.PrivateColumns.AddRange(privates);
			}
		}
	}
}

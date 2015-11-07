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
		public List<string> PublicColumns { get; set; }
		public List<string> PrivateColumns { get; set; }

		private List<TableMapping> publicMappings;
		private List<TableMapping> privateMappings;

		public frmCustomizeDQDK() {
			InitializeComponent();
			this.PublicColumns = new List<string>();
			this.PrivateColumns = new List<string>();
		}

		private void frmCustomizeReport_Load(object sender, EventArgs e) {
			InitialForm();
		}

		private void InitialForm() {
			publicMappings = TableMapping.GetMappingList("ImportPublic");
			privateMappings = TableMapping.GetMappingList("ImportPrivate");

			BindListBox(listBoxPublicCandidates, publicMappings.Where(x => x.Mode == MappingMode.Custom));
			BindListBox(listBoxPrivateCandidates, privateMappings.Where(x => x.Mode == MappingMode.Custom));
		}

		private void BindListBox(ListBox box, IEnumerable<TableMapping> list) {
			box.Items.Clear();
			box.Items.AddRange(list.ToArray());
		}

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
			this.Close();
		}
	}
}

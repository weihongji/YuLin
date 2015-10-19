using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace ExcelTester
{
	public partial class MainForm : Form
	{
		public MainForm() {
			InitializeComponent();
		}

		private void btnReadCell_Click(object sender, EventArgs e) {
			var msg = ExcelApplicationTest.Test();
			MessageBox.Show(msg);
		}

		private void btnOleRows_Click(object sender, EventArgs e) {
			var msg = OledbTest.Test();
			MessageBox.Show(msg);
		}

		private void btnExit_Click(object sender, EventArgs e) {
			Application.Exit();
		}


	}
}

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.Configuration;
using System.IO;
using System.Diagnostics;

namespace Deployer
{
	public partial class FormMain : Form
	{
		public FormMain() {
			InitializeComponent();
		}

		private void FormMain_Load(object sender, EventArgs e) {
			this.lblVersionText.Text = ConfigurationManager.AppSettings["Version"];
			this.lblDateText.Text = ConfigurationManager.AppSettings["ReleaseDate"];
		}

		private void btnUpgrade_Click(object sender, EventArgs e) {
			try {
				var appPath = ConfigurationManager.AppSettings["AppPath"];
				var binPath = Path.Combine(appPath, "Bin");
				var dbPath = Path.Combine(appPath, "Database");
				var upgradePath = System.Environment.CurrentDirectory;

				var dao = new SqlDbHelper(ConfigurationManager.ConnectionStrings["master"].ConnectionString);
				dao.ExecuteNonQuery("DROP DATABASE YuLin");
				File.Copy(Path.Combine(upgradePath, @"database\YuLin.mdf"), Path.Combine(dbPath, "YuLin.mdf"), true);
				dao.ExecuteNonQuery(string.Format("CREATE DATABASE YuLin ON (FILENAME='{0}') FOR ATTACH", Path.Combine(dbPath, "YuLin.mdf")));

				Directory.Move(binPath, binPath + DateTime.Now.ToString("_yyMMddHHmmss"));
				Directory.CreateDirectory(binPath);

				Process process = new Process();
				process.StartInfo.FileName = "cmd";
				process.StartInfo.Arguments = string.Format("/k xcopy /E \"{0}\" \"{1}\"&&exit", Path.Combine(upgradePath, "bin"), binPath);
				process.Start();
				process.WaitForExit();
				process.Close();

				MessageBox.Show("部署完毕", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
			}
			catch (Exception ex) {
				MessageBox.Show(ex.Message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}
	}
}

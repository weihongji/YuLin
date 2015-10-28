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
			// Button will become to be "Close" after deployment is done.
			if (this.btnUpgrade.Text == "关闭") {
				Application.Exit();
				return;
			}

			if (MessageBox.Show(string.Format("您确定要部署{0}版本吗？", this.lblVersionText.Text), this.Text, MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) {
				return;
			}
			try {
				var appPath = ConfigurationManager.AppSettings["AppPath"];
				if (!Directory.Exists(appPath)) {
					MessageBox.Show("报表系统的安装路径不存在：\r\n" + appPath, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
					return;
				}
				var binPath = Path.Combine(appPath, "Bin");
				var dbPath = Path.Combine(appPath, "Database");
				var upgradePath = System.Environment.CurrentDirectory;
				var backupPath = Path.Combine(appPath, DateTime.Now.ToString("yyMMddHHmmss"));

				// Backups
				DetachDB();
				if (Directory.Exists(dbPath)) {
					if (!Directory.Exists(backupPath)) {
						Directory.CreateDirectory(backupPath);
					}
					Directory.Move(dbPath, Path.Combine(backupPath, "Database"));
				}
				if (Directory.Exists(binPath)) {
					if (!Directory.Exists(backupPath)) {
						Directory.CreateDirectory(backupPath);
					}
					Directory.Move(binPath, Path.Combine(backupPath, "Bin"));
				}

				// Create new db
				var dbPathInfo = Directory.CreateDirectory(dbPath);

				File.Copy(Path.Combine(upgradePath, @"database\YuLin.mdf"), Path.Combine(dbPath, "YuLin.mdf"), true);
				var dao = new SqlDbHelper(ConfigurationManager.ConnectionStrings["master"].ConnectionString);
				dao.ExecuteNonQuery(string.Format("CREATE DATABASE YuLin ON (FILENAME='{0}') FOR ATTACH", Path.Combine(dbPath, "YuLin.mdf")));

				// Create new bin
				Directory.CreateDirectory(binPath);
				Process process = new Process();
				process.StartInfo.FileName = "cmd";
				process.StartInfo.Arguments = string.Format("/k xcopy /E \"{0}\" \"{1}\"&&exit", Path.Combine(upgradePath, "bin"), binPath);
				process.Start();
				process.WaitForExit();
				process.Close();

				MessageBox.Show("部署完毕", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
				this.btnUpgrade.Text = "关闭";
			}
			catch (Exception ex) {
				if (ex.Message.IndexOf("Operating system error 5") > 0) {
					MessageBox.Show("无权限挂载数据库，请把SQL Server服务的启动帐号加入系统管理员用户群组，然后重启该服务。", this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
				}
				else {
					MessageBox.Show(ex.Message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
				}
			}
		}

		private void DetachDB() {
			var dao = new SqlDbHelper(ConfigurationManager.ConnectionStrings["master"].ConnectionString);
			var table = dao.ExecuteDataTable("select spid from sys.sysprocesses where dbid = DB_ID('YuLin')");
			foreach (var row in table.Rows) {
				dao.ExecuteNonQuery("kill " + ((DataRow) row)[0]);
			}
			var sql = new StringBuilder();
			sql.AppendLine("IF DB_ID('YuLin') IS NOT NULL BEGIN");
			sql.AppendLine("	EXEC sp_detach_db 'YuLin'");
			sql.AppendLine("END");
			dao.ExecuteNonQuery(sql.ToString());
		}
	}
}

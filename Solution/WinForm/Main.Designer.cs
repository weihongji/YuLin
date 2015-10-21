namespace WinForm
{
	partial class Main
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing) {
			if (disposing && (components != null)) {
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent() {
			this.components = new System.ComponentModel.Container();
			this.panelMenu = new System.Windows.Forms.Panel();
			this.menuStrip1 = new System.Windows.Forms.MenuStrip();
			this.menuMgmt = new System.Windows.Forms.ToolStripMenuItem();
			this.menu_Mgmt_Import = new System.Windows.Forms.ToolStripMenuItem();
			this.menu_Mgmt_Exit = new System.Windows.Forms.ToolStripMenuItem();
			this.menuReports = new System.Windows.Forms.ToolStripMenuItem();
			this.menu_Report_LoanRisk = new System.Windows.Forms.ToolStripMenuItem();
			this.panelContent = new System.Windows.Forms.Panel();
			this.panelImport = new System.Windows.Forms.Panel();
			this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
			this.label10 = new System.Windows.Forms.Label();
			this.lblImportOverdue = new System.Windows.Forms.Label();
			this.lblImportNonAccrual = new System.Windows.Forms.Label();
			this.lblImportPrivate = new System.Windows.Forms.Label();
			this.lblImportPublic = new System.Windows.Forms.Label();
			this.lblImportLoan = new System.Windows.Forms.Label();
			this.label7 = new System.Windows.Forms.Label();
			this.btnImportOK = new System.Windows.Forms.Button();
			this.btnImportOverdue = new System.Windows.Forms.Button();
			this.label6 = new System.Windows.Forms.Label();
			this.btnImportNonAccrual = new System.Windows.Forms.Button();
			this.label5 = new System.Windows.Forms.Label();
			this.btnImportPrivate = new System.Windows.Forms.Button();
			this.label4 = new System.Windows.Forms.Label();
			this.btnImportPublic = new System.Windows.Forms.Button();
			this.label3 = new System.Windows.Forms.Label();
			this.btnImportLoan = new System.Windows.Forms.Button();
			this.label2 = new System.Windows.Forms.Label();
			this.cmbMonth = new System.Windows.Forms.ComboBox();
			this.cmbYear = new System.Windows.Forms.ComboBox();
			this.label1 = new System.Windows.Forms.Label();
			this.panelReport = new System.Windows.Forms.Panel();
			this.flowLayoutPanel3 = new System.Windows.Forms.FlowLayoutPanel();
			this.txtReportPath = new System.Windows.Forms.Label();
			this.btnOpenReportFolder = new System.Windows.Forms.Button();
			this.label12 = new System.Windows.Forms.Label();
			this.flowLayoutPanel2 = new System.Windows.Forms.FlowLayoutPanel();
			this.label11 = new System.Windows.Forms.Label();
			this.cmbReportMonth = new System.Windows.Forms.ComboBox();
			this.label9 = new System.Windows.Forms.Label();
			this.btnExport = new System.Windows.Forms.Button();
			this.label8 = new System.Windows.Forms.Label();
			this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
			this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
			this.label13 = new System.Windows.Forms.Label();
			this.btnImportYWNei = new System.Windows.Forms.Button();
			this.lblImportYWNei = new System.Windows.Forms.Label();
			this.label15 = new System.Windows.Forms.Label();
			this.btnImportYWWai = new System.Windows.Forms.Button();
			this.lblImportYWWai = new System.Windows.Forms.Label();
			this.panelMenu.SuspendLayout();
			this.menuStrip1.SuspendLayout();
			this.panelContent.SuspendLayout();
			this.panelImport.SuspendLayout();
			this.flowLayoutPanel1.SuspendLayout();
			this.panelReport.SuspendLayout();
			this.flowLayoutPanel3.SuspendLayout();
			this.flowLayoutPanel2.SuspendLayout();
			this.SuspendLayout();
			// 
			// panelMenu
			// 
			this.panelMenu.Controls.Add(this.menuStrip1);
			this.panelMenu.Dock = System.Windows.Forms.DockStyle.Top;
			this.panelMenu.Location = new System.Drawing.Point(0, 0);
			this.panelMenu.Name = "panelMenu";
			this.panelMenu.Size = new System.Drawing.Size(695, 35);
			this.panelMenu.TabIndex = 1;
			// 
			// menuStrip1
			// 
			this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuMgmt,
            this.menuReports});
			this.menuStrip1.Location = new System.Drawing.Point(0, 0);
			this.menuStrip1.Name = "menuStrip1";
			this.menuStrip1.Size = new System.Drawing.Size(695, 25);
			this.menuStrip1.TabIndex = 0;
			this.menuStrip1.Text = "menuStrip1";
			// 
			// menuMgmt
			// 
			this.menuMgmt.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menu_Mgmt_Import,
            this.menu_Mgmt_Exit});
			this.menuMgmt.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.menuMgmt.Name = "menuMgmt";
			this.menuMgmt.Size = new System.Drawing.Size(65, 21);
			this.menuMgmt.Text = "管理 (&G)";
			// 
			// menu_Mgmt_Import
			// 
			this.menu_Mgmt_Import.Name = "menu_Mgmt_Import";
			this.menu_Mgmt_Import.Size = new System.Drawing.Size(144, 22);
			this.menu_Mgmt_Import.Text = "导入数据 (&I)";
			this.menu_Mgmt_Import.Click += new System.EventHandler(this.menu_Mgmt_Import_Click);
			// 
			// menu_Mgmt_Exit
			// 
			this.menu_Mgmt_Exit.Name = "menu_Mgmt_Exit";
			this.menu_Mgmt_Exit.Size = new System.Drawing.Size(144, 22);
			this.menu_Mgmt_Exit.Text = "退出系统 (&X)";
			this.menu_Mgmt_Exit.Click += new System.EventHandler(this.menu_Mgmt_Exit_Click);
			// 
			// menuReports
			// 
			this.menuReports.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menu_Report_LoanRisk});
			this.menuReports.Name = "menuReports";
			this.menuReports.Size = new System.Drawing.Size(84, 21);
			this.menuReports.Text = "导出报表(&R)";
			// 
			// menu_Report_LoanRisk
			// 
			this.menu_Report_LoanRisk.Name = "menu_Report_LoanRisk";
			this.menu_Report_LoanRisk.Size = new System.Drawing.Size(244, 22);
			this.menu_Report_LoanRisk.Text = "末风险贷款情况表（五级分类）";
			this.menu_Report_LoanRisk.Click += new System.EventHandler(this.menu_Report_LoanRisk_Click);
			// 
			// panelContent
			// 
			this.panelContent.Controls.Add(this.panelImport);
			this.panelContent.Controls.Add(this.panelReport);
			this.panelContent.Dock = System.Windows.Forms.DockStyle.Fill;
			this.panelContent.Location = new System.Drawing.Point(0, 35);
			this.panelContent.Name = "panelContent";
			this.panelContent.Size = new System.Drawing.Size(695, 551);
			this.panelContent.TabIndex = 2;
			// 
			// panelImport
			// 
			this.panelImport.Controls.Add(this.flowLayoutPanel1);
			this.panelImport.Controls.Add(this.lblImportYWWai);
			this.panelImport.Controls.Add(this.lblImportYWNei);
			this.panelImport.Controls.Add(this.lblImportOverdue);
			this.panelImport.Controls.Add(this.lblImportNonAccrual);
			this.panelImport.Controls.Add(this.lblImportPrivate);
			this.panelImport.Controls.Add(this.lblImportPublic);
			this.panelImport.Controls.Add(this.lblImportLoan);
			this.panelImport.Controls.Add(this.label7);
			this.panelImport.Controls.Add(this.btnImportOK);
			this.panelImport.Controls.Add(this.btnImportYWWai);
			this.panelImport.Controls.Add(this.label15);
			this.panelImport.Controls.Add(this.btnImportYWNei);
			this.panelImport.Controls.Add(this.label13);
			this.panelImport.Controls.Add(this.btnImportOverdue);
			this.panelImport.Controls.Add(this.label6);
			this.panelImport.Controls.Add(this.btnImportNonAccrual);
			this.panelImport.Controls.Add(this.label5);
			this.panelImport.Controls.Add(this.btnImportPrivate);
			this.panelImport.Controls.Add(this.label4);
			this.panelImport.Controls.Add(this.btnImportPublic);
			this.panelImport.Controls.Add(this.label3);
			this.panelImport.Controls.Add(this.btnImportLoan);
			this.panelImport.Controls.Add(this.label2);
			this.panelImport.Controls.Add(this.cmbMonth);
			this.panelImport.Controls.Add(this.cmbYear);
			this.panelImport.Controls.Add(this.label1);
			this.panelImport.Dock = System.Windows.Forms.DockStyle.Fill;
			this.panelImport.Location = new System.Drawing.Point(0, 0);
			this.panelImport.Name = "panelImport";
			this.panelImport.Size = new System.Drawing.Size(695, 551);
			this.panelImport.TabIndex = 0;
			// 
			// flowLayoutPanel1
			// 
			this.flowLayoutPanel1.Controls.Add(this.label10);
			this.flowLayoutPanel1.Location = new System.Drawing.Point(373, 417);
			this.flowLayoutPanel1.Name = "flowLayoutPanel1";
			this.flowLayoutPanel1.Size = new System.Drawing.Size(224, 66);
			this.flowLayoutPanel1.TabIndex = 12;
			// 
			// label10
			// 
			this.label10.AutoSize = true;
			this.label10.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label10.Location = new System.Drawing.Point(4, 4);
			this.label10.Margin = new System.Windows.Forms.Padding(4);
			this.label10.Name = "label10";
			this.label10.Size = new System.Drawing.Size(212, 34);
			this.label10.TabIndex = 12;
			this.label10.Text = "导入过程可能需要几分钟或更多，请您耐心等待导入完毕。";
			// 
			// lblImportOverdue
			// 
			this.lblImportOverdue.AutoEllipsis = true;
			this.lblImportOverdue.Location = new System.Drawing.Point(301, 273);
			this.lblImportOverdue.Name = "lblImportOverdue";
			this.lblImportOverdue.Size = new System.Drawing.Size(350, 12);
			this.lblImportOverdue.TabIndex = 10;
			this.lblImportOverdue.Text = "C:\\xxx.xls";
			// 
			// lblImportNonAccrual
			// 
			this.lblImportNonAccrual.AutoEllipsis = true;
			this.lblImportNonAccrual.Location = new System.Drawing.Point(301, 240);
			this.lblImportNonAccrual.Name = "lblImportNonAccrual";
			this.lblImportNonAccrual.Size = new System.Drawing.Size(350, 12);
			this.lblImportNonAccrual.TabIndex = 9;
			this.lblImportNonAccrual.Text = "C:\\xxx.xls";
			// 
			// lblImportPrivate
			// 
			this.lblImportPrivate.AutoEllipsis = true;
			this.lblImportPrivate.Location = new System.Drawing.Point(301, 206);
			this.lblImportPrivate.Name = "lblImportPrivate";
			this.lblImportPrivate.Size = new System.Drawing.Size(350, 12);
			this.lblImportPrivate.TabIndex = 8;
			this.lblImportPrivate.Text = "C:\\xxx.xls";
			// 
			// lblImportPublic
			// 
			this.lblImportPublic.AutoEllipsis = true;
			this.lblImportPublic.Location = new System.Drawing.Point(301, 172);
			this.lblImportPublic.Name = "lblImportPublic";
			this.lblImportPublic.Size = new System.Drawing.Size(350, 12);
			this.lblImportPublic.TabIndex = 7;
			this.lblImportPublic.Text = "C:\\xxx.xls";
			// 
			// lblImportLoan
			// 
			this.lblImportLoan.AutoEllipsis = true;
			this.lblImportLoan.Location = new System.Drawing.Point(301, 138);
			this.lblImportLoan.Name = "lblImportLoan";
			this.lblImportLoan.Size = new System.Drawing.Size(350, 12);
			this.lblImportLoan.TabIndex = 6;
			this.lblImportLoan.Text = "C:\\xxx.xls";
			// 
			// label7
			// 
			this.label7.AutoSize = true;
			this.label7.Font = new System.Drawing.Font("Microsoft YaHei", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label7.Location = new System.Drawing.Point(223, 24);
			this.label7.Name = "label7";
			this.label7.Size = new System.Drawing.Size(106, 21);
			this.label7.TabIndex = 5;
			this.label7.Text = "导入源数据表";
			// 
			// btnImportOK
			// 
			this.btnImportOK.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnImportOK.Location = new System.Drawing.Point(204, 417);
			this.btnImportOK.Name = "btnImportOK";
			this.btnImportOK.Size = new System.Drawing.Size(130, 40);
			this.btnImportOK.TabIndex = 8;
			this.btnImportOK.Text = "导入";
			this.btnImportOK.UseVisualStyleBackColor = true;
			this.btnImportOK.Click += new System.EventHandler(this.btnImportOK_Click);
			// 
			// btnImportOverdue
			// 
			this.btnImportOverdue.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnImportOverdue.Location = new System.Drawing.Point(212, 268);
			this.btnImportOverdue.Name = "btnImportOverdue";
			this.btnImportOverdue.Size = new System.Drawing.Size(75, 23);
			this.btnImportOverdue.TabIndex = 7;
			this.btnImportOverdue.Text = "选择 ...";
			this.btnImportOverdue.UseVisualStyleBackColor = true;
			this.btnImportOverdue.Click += new System.EventHandler(this.btnImportOverdue_Click);
			// 
			// label6
			// 
			this.label6.AutoSize = true;
			this.label6.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label6.Location = new System.Drawing.Point(97, 274);
			this.label6.Name = "label6";
			this.label6.Size = new System.Drawing.Size(92, 17);
			this.label6.TabIndex = 2;
			this.label6.Text = "逾期贷款明细表";
			// 
			// btnImportNonAccrual
			// 
			this.btnImportNonAccrual.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnImportNonAccrual.Location = new System.Drawing.Point(212, 235);
			this.btnImportNonAccrual.Name = "btnImportNonAccrual";
			this.btnImportNonAccrual.Size = new System.Drawing.Size(75, 23);
			this.btnImportNonAccrual.TabIndex = 6;
			this.btnImportNonAccrual.Text = "选择 ...";
			this.btnImportNonAccrual.UseVisualStyleBackColor = true;
			this.btnImportNonAccrual.Click += new System.EventHandler(this.btnImportNonAccrual_Click);
			// 
			// label5
			// 
			this.label5.AutoSize = true;
			this.label5.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label5.Location = new System.Drawing.Point(97, 240);
			this.label5.Name = "label5";
			this.label5.Size = new System.Drawing.Size(104, 17);
			this.label5.TabIndex = 2;
			this.label5.Text = "非应计贷款明细表";
			// 
			// btnImportPrivate
			// 
			this.btnImportPrivate.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnImportPrivate.Location = new System.Drawing.Point(212, 201);
			this.btnImportPrivate.Name = "btnImportPrivate";
			this.btnImportPrivate.Size = new System.Drawing.Size(75, 23);
			this.btnImportPrivate.TabIndex = 5;
			this.btnImportPrivate.Text = "选择 ...";
			this.btnImportPrivate.UseVisualStyleBackColor = true;
			this.btnImportPrivate.Click += new System.EventHandler(this.btnImportPrivate_Click);
			// 
			// label4
			// 
			this.label4.AutoSize = true;
			this.label4.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label4.Location = new System.Drawing.Point(97, 206);
			this.label4.Name = "label4";
			this.label4.Size = new System.Drawing.Size(32, 17);
			this.label4.TabIndex = 2;
			this.label4.Text = "个人";
			// 
			// btnImportPublic
			// 
			this.btnImportPublic.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnImportPublic.Location = new System.Drawing.Point(212, 167);
			this.btnImportPublic.Name = "btnImportPublic";
			this.btnImportPublic.Size = new System.Drawing.Size(75, 23);
			this.btnImportPublic.TabIndex = 4;
			this.btnImportPublic.Text = "选择 ...";
			this.btnImportPublic.UseVisualStyleBackColor = true;
			this.btnImportPublic.Click += new System.EventHandler(this.btnImportPublic_Click);
			// 
			// label3
			// 
			this.label3.AutoSize = true;
			this.label3.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label3.Location = new System.Drawing.Point(97, 172);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size(32, 17);
			this.label3.TabIndex = 2;
			this.label3.Text = "对公";
			// 
			// btnImportLoan
			// 
			this.btnImportLoan.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnImportLoan.Location = new System.Drawing.Point(212, 133);
			this.btnImportLoan.Name = "btnImportLoan";
			this.btnImportLoan.Size = new System.Drawing.Size(75, 23);
			this.btnImportLoan.TabIndex = 3;
			this.btnImportLoan.Text = "选择 ...";
			this.btnImportLoan.UseVisualStyleBackColor = true;
			this.btnImportLoan.Click += new System.EventHandler(this.btnImportLoan_Click);
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label2.Location = new System.Drawing.Point(97, 138);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(80, 17);
			this.label2.TabIndex = 2;
			this.label2.Text = "贷款欠款查询";
			// 
			// cmbMonth
			// 
			this.cmbMonth.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.cmbMonth.FormattingEnabled = true;
			this.cmbMonth.Items.AddRange(new object[] {
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12"});
			this.cmbMonth.Location = new System.Drawing.Point(297, 78);
			this.cmbMonth.Name = "cmbMonth";
			this.cmbMonth.Size = new System.Drawing.Size(53, 25);
			this.cmbMonth.TabIndex = 2;
			// 
			// cmbYear
			// 
			this.cmbYear.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.cmbYear.FormattingEnabled = true;
			this.cmbYear.ItemHeight = 17;
			this.cmbYear.Items.AddRange(new object[] {
            "2014",
            "2015"});
			this.cmbYear.Location = new System.Drawing.Point(212, 78);
			this.cmbYear.Name = "cmbYear";
			this.cmbYear.Size = new System.Drawing.Size(75, 25);
			this.cmbYear.TabIndex = 1;
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label1.Location = new System.Drawing.Point(97, 83);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(44, 17);
			this.label1.TabIndex = 0;
			this.label1.Text = "月份：";
			// 
			// panelReport
			// 
			this.panelReport.Controls.Add(this.flowLayoutPanel3);
			this.panelReport.Controls.Add(this.label12);
			this.panelReport.Controls.Add(this.flowLayoutPanel2);
			this.panelReport.Controls.Add(this.cmbReportMonth);
			this.panelReport.Controls.Add(this.label9);
			this.panelReport.Controls.Add(this.btnExport);
			this.panelReport.Controls.Add(this.label8);
			this.panelReport.Dock = System.Windows.Forms.DockStyle.Fill;
			this.panelReport.Location = new System.Drawing.Point(0, 0);
			this.panelReport.Name = "panelReport";
			this.panelReport.Size = new System.Drawing.Size(695, 551);
			this.panelReport.TabIndex = 1;
			// 
			// flowLayoutPanel3
			// 
			this.flowLayoutPanel3.Controls.Add(this.txtReportPath);
			this.flowLayoutPanel3.Controls.Add(this.btnOpenReportFolder);
			this.flowLayoutPanel3.Location = new System.Drawing.Point(196, 320);
			this.flowLayoutPanel3.Name = "flowLayoutPanel3";
			this.flowLayoutPanel3.Size = new System.Drawing.Size(455, 52);
			this.flowLayoutPanel3.TabIndex = 19;
			// 
			// txtReportPath
			// 
			this.txtReportPath.AutoSize = true;
			this.txtReportPath.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.txtReportPath.Location = new System.Drawing.Point(3, 8);
			this.txtReportPath.Margin = new System.Windows.Forms.Padding(3, 8, 3, 0);
			this.txtReportPath.Name = "txtReportPath";
			this.txtReportPath.Size = new System.Drawing.Size(63, 17);
			this.txtReportPath.TabIndex = 18;
			this.txtReportPath.Text = "E:\\Report";
			// 
			// btnOpenReportFolder
			// 
			this.btnOpenReportFolder.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnOpenReportFolder.Location = new System.Drawing.Point(72, 3);
			this.btnOpenReportFolder.Name = "btnOpenReportFolder";
			this.btnOpenReportFolder.Size = new System.Drawing.Size(74, 24);
			this.btnOpenReportFolder.TabIndex = 17;
			this.btnOpenReportFolder.Text = "打开目录";
			this.btnOpenReportFolder.UseVisualStyleBackColor = true;
			this.btnOpenReportFolder.Click += new System.EventHandler(this.btnOpenReportFolder_Click);
			// 
			// label12
			// 
			this.label12.AutoSize = true;
			this.label12.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label12.Location = new System.Drawing.Point(112, 328);
			this.label12.Name = "label12";
			this.label12.Size = new System.Drawing.Size(92, 17);
			this.label12.TabIndex = 14;
			this.label12.Text = "报表存放路径：";
			// 
			// flowLayoutPanel2
			// 
			this.flowLayoutPanel2.Controls.Add(this.label11);
			this.flowLayoutPanel2.Location = new System.Drawing.Point(388, 240);
			this.flowLayoutPanel2.Name = "flowLayoutPanel2";
			this.flowLayoutPanel2.Size = new System.Drawing.Size(224, 66);
			this.flowLayoutPanel2.TabIndex = 13;
			// 
			// label11
			// 
			this.label11.AutoSize = true;
			this.label11.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label11.Location = new System.Drawing.Point(4, 4);
			this.label11.Margin = new System.Windows.Forms.Padding(4);
			this.label11.Name = "label11";
			this.label11.Size = new System.Drawing.Size(212, 34);
			this.label11.TabIndex = 12;
			this.label11.Text = "导出过程可能需要几分钟或更多，请您耐心等待导入完毕。";
			// 
			// cmbReportMonth
			// 
			this.cmbReportMonth.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.cmbReportMonth.FormattingEnabled = true;
			this.cmbReportMonth.Items.AddRange(new object[] {
            "2015-09",
            "2015-08",
            "2015-07"});
			this.cmbReportMonth.Location = new System.Drawing.Point(226, 113);
			this.cmbReportMonth.Name = "cmbReportMonth";
			this.cmbReportMonth.Size = new System.Drawing.Size(116, 25);
			this.cmbReportMonth.TabIndex = 0;
			// 
			// label9
			// 
			this.label9.AutoSize = true;
			this.label9.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label9.Location = new System.Drawing.Point(162, 118);
			this.label9.Name = "label9";
			this.label9.Size = new System.Drawing.Size(68, 17);
			this.label9.TabIndex = 8;
			this.label9.Text = "数据月份：";
			// 
			// btnExport
			// 
			this.btnExport.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnExport.Location = new System.Drawing.Point(203, 237);
			this.btnExport.Name = "btnExport";
			this.btnExport.Size = new System.Drawing.Size(152, 34);
			this.btnExport.TabIndex = 1;
			this.btnExport.Text = "导出 Excel";
			this.btnExport.UseVisualStyleBackColor = true;
			this.btnExport.Click += new System.EventHandler(this.btnExport_Click);
			// 
			// label8
			// 
			this.label8.AutoSize = true;
			this.label8.Font = new System.Drawing.Font("Microsoft YaHei", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label8.Location = new System.Drawing.Point(161, 39);
			this.label8.Name = "label8";
			this.label8.Size = new System.Drawing.Size(218, 21);
			this.label8.TabIndex = 6;
			this.label8.Text = "榆林分行月末风险贷款情况表";
			// 
			// openFileDialog1
			// 
			this.openFileDialog1.Filter = "Excel文件|*.xls";
			// 
			// label13
			// 
			this.label13.AutoSize = true;
			this.label13.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label13.Location = new System.Drawing.Point(97, 306);
			this.label13.Name = "label13";
			this.label13.Size = new System.Drawing.Size(116, 17);
			this.label13.TabIndex = 2;
			this.label13.Text = "业务状况表（表内）";
			// 
			// btnImportYWNei
			// 
			this.btnImportYWNei.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnImportYWNei.Location = new System.Drawing.Point(212, 300);
			this.btnImportYWNei.Name = "btnImportYWNei";
			this.btnImportYWNei.Size = new System.Drawing.Size(75, 23);
			this.btnImportYWNei.TabIndex = 7;
			this.btnImportYWNei.Text = "选择 ...";
			this.btnImportYWNei.UseVisualStyleBackColor = true;
			this.btnImportYWNei.Click += new System.EventHandler(this.btnImportYWNei_Click);
			// 
			// lblImportYWNei
			// 
			this.lblImportYWNei.AutoEllipsis = true;
			this.lblImportYWNei.Location = new System.Drawing.Point(301, 305);
			this.lblImportYWNei.Name = "lblImportYWNei";
			this.lblImportYWNei.Size = new System.Drawing.Size(350, 12);
			this.lblImportYWNei.TabIndex = 10;
			this.lblImportYWNei.Text = "C:\\xxx.xls";
			// 
			// label15
			// 
			this.label15.AutoSize = true;
			this.label15.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label15.Location = new System.Drawing.Point(97, 337);
			this.label15.Name = "label15";
			this.label15.Size = new System.Drawing.Size(116, 17);
			this.label15.TabIndex = 2;
			this.label15.Text = "业务状况表（表外）";
			// 
			// btnImportYWWai
			// 
			this.btnImportYWWai.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnImportYWWai.Location = new System.Drawing.Point(212, 331);
			this.btnImportYWWai.Name = "btnImportYWWai";
			this.btnImportYWWai.Size = new System.Drawing.Size(75, 23);
			this.btnImportYWWai.TabIndex = 7;
			this.btnImportYWWai.Text = "选择 ...";
			this.btnImportYWWai.UseVisualStyleBackColor = true;
			this.btnImportYWWai.Click += new System.EventHandler(this.btnImportYWWai_Click);
			// 
			// lblImportYWWai
			// 
			this.lblImportYWWai.AutoEllipsis = true;
			this.lblImportYWWai.Location = new System.Drawing.Point(301, 336);
			this.lblImportYWWai.Name = "lblImportYWWai";
			this.lblImportYWWai.Size = new System.Drawing.Size(350, 12);
			this.lblImportYWWai.TabIndex = 10;
			this.lblImportYWWai.Text = "C:\\xxx.xls";
			// 
			// Main
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(695, 586);
			this.Controls.Add(this.panelContent);
			this.Controls.Add(this.panelMenu);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.MaximizeBox = false;
			this.Name = "Main";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "报表系统";
			this.panelMenu.ResumeLayout(false);
			this.panelMenu.PerformLayout();
			this.menuStrip1.ResumeLayout(false);
			this.menuStrip1.PerformLayout();
			this.panelContent.ResumeLayout(false);
			this.panelImport.ResumeLayout(false);
			this.panelImport.PerformLayout();
			this.flowLayoutPanel1.ResumeLayout(false);
			this.flowLayoutPanel1.PerformLayout();
			this.panelReport.ResumeLayout(false);
			this.panelReport.PerformLayout();
			this.flowLayoutPanel3.ResumeLayout(false);
			this.flowLayoutPanel3.PerformLayout();
			this.flowLayoutPanel2.ResumeLayout(false);
			this.flowLayoutPanel2.PerformLayout();
			this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.Panel panelMenu;
		private System.Windows.Forms.MenuStrip menuStrip1;
		private System.Windows.Forms.ToolStripMenuItem menuMgmt;
		private System.Windows.Forms.ToolStripMenuItem menu_Mgmt_Import;
		private System.Windows.Forms.ToolStripMenuItem menuReports;
		private System.Windows.Forms.ToolStripMenuItem menu_Report_LoanRisk;
		private System.Windows.Forms.Panel panelContent;
		private System.Windows.Forms.Panel panelImport;
		private System.Windows.Forms.Button btnImportOverdue;
		private System.Windows.Forms.Label label6;
		private System.Windows.Forms.Button btnImportNonAccrual;
		private System.Windows.Forms.Label label5;
		private System.Windows.Forms.Button btnImportPrivate;
		private System.Windows.Forms.Label label4;
		private System.Windows.Forms.Button btnImportPublic;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.Button btnImportLoan;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.ComboBox cmbMonth;
		private System.Windows.Forms.ComboBox cmbYear;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.OpenFileDialog openFileDialog1;
		private System.Windows.Forms.Label label7;
		private System.Windows.Forms.Button btnImportOK;
		private System.Windows.Forms.Panel panelReport;
		private System.Windows.Forms.Label label8;
		private System.Windows.Forms.Button btnExport;
		private System.Windows.Forms.ToolStripMenuItem menu_Mgmt_Exit;
		private System.Windows.Forms.ComboBox cmbReportMonth;
		private System.Windows.Forms.Label label9;
		private System.Windows.Forms.Label lblImportOverdue;
		private System.Windows.Forms.Label lblImportNonAccrual;
		private System.Windows.Forms.Label lblImportPrivate;
		private System.Windows.Forms.Label lblImportPublic;
		private System.Windows.Forms.Label lblImportLoan;
		private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
		private System.Windows.Forms.Label label10;
		private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel2;
		private System.Windows.Forms.Label label11;
		private System.Windows.Forms.Label label12;
		private System.Windows.Forms.ToolTip toolTip1;
		private System.Windows.Forms.Button btnOpenReportFolder;
		private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel3;
		private System.Windows.Forms.Label txtReportPath;
		private System.Windows.Forms.Label lblImportYWWai;
		private System.Windows.Forms.Label lblImportYWNei;
		private System.Windows.Forms.Button btnImportYWWai;
		private System.Windows.Forms.Label label15;
		private System.Windows.Forms.Button btnImportYWNei;
		private System.Windows.Forms.Label label13;


	}
}


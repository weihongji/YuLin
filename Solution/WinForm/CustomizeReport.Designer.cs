namespace Reporting
{
	partial class frmCustomizeReport
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
			this.panel1 = new System.Windows.Forms.Panel();
			this.runReport = new System.Windows.Forms.Button();
			this.btnRemove = new System.Windows.Forms.Button();
			this.btnAdd = new System.Windows.Forms.Button();
			this.label2 = new System.Windows.Forms.Label();
			this.label1 = new System.Windows.Forms.Label();
			this.selectedColList = new System.Windows.Forms.ListBox();
			this.optionalColList = new System.Windows.Forms.ListBox();
			this.lblReportTitle = new System.Windows.Forms.Label();
			this.panel1.SuspendLayout();
			this.SuspendLayout();
			// 
			// panel1
			// 
			this.panel1.Controls.Add(this.lblReportTitle);
			this.panel1.Controls.Add(this.runReport);
			this.panel1.Controls.Add(this.btnRemove);
			this.panel1.Controls.Add(this.btnAdd);
			this.panel1.Controls.Add(this.label2);
			this.panel1.Controls.Add(this.label1);
			this.panel1.Controls.Add(this.selectedColList);
			this.panel1.Controls.Add(this.optionalColList);
			this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
			this.panel1.Location = new System.Drawing.Point(0, 0);
			this.panel1.Name = "panel1";
			this.panel1.Size = new System.Drawing.Size(639, 562);
			this.panel1.TabIndex = 0;
			// 
			// runReport
			// 
			this.runReport.Location = new System.Drawing.Point(408, 500);
			this.runReport.Name = "runReport";
			this.runReport.Size = new System.Drawing.Size(115, 36);
			this.runReport.TabIndex = 6;
			this.runReport.Text = "确定";
			this.runReport.UseVisualStyleBackColor = true;
			this.runReport.Click += new System.EventHandler(this.runReport_Click);
			// 
			// btnRemove
			// 
			this.btnRemove.Location = new System.Drawing.Point(269, 245);
			this.btnRemove.Name = "btnRemove";
			this.btnRemove.Size = new System.Drawing.Size(75, 36);
			this.btnRemove.TabIndex = 5;
			this.btnRemove.Text = "<<";
			this.btnRemove.UseVisualStyleBackColor = true;
			this.btnRemove.Click += new System.EventHandler(this.btnRemove_Click);
			// 
			// btnAdd
			// 
			this.btnAdd.Location = new System.Drawing.Point(269, 180);
			this.btnAdd.Name = "btnAdd";
			this.btnAdd.Size = new System.Drawing.Size(75, 36);
			this.btnAdd.TabIndex = 4;
			this.btnAdd.Text = ">>";
			this.btnAdd.UseVisualStyleBackColor = true;
			this.btnAdd.Click += new System.EventHandler(this.btnAdd_Click);
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label2.Location = new System.Drawing.Point(366, 75);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(80, 17);
			this.label2.TabIndex = 3;
			this.label2.Text = "已选数据列：";
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label1.Location = new System.Drawing.Point(46, 75);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(80, 17);
			this.label1.TabIndex = 3;
			this.label1.Text = "可选数据列：";
			// 
			// selectedColList
			// 
			this.selectedColList.FormattingEnabled = true;
			this.selectedColList.Location = new System.Drawing.Point(366, 100);
			this.selectedColList.Name = "selectedColList";
			this.selectedColList.Size = new System.Drawing.Size(203, 381);
			this.selectedColList.TabIndex = 2;
			// 
			// optionalColList
			// 
			this.optionalColList.FormattingEnabled = true;
			this.optionalColList.Location = new System.Drawing.Point(46, 100);
			this.optionalColList.Name = "optionalColList";
			this.optionalColList.Size = new System.Drawing.Size(203, 381);
			this.optionalColList.TabIndex = 1;
			// 
			// lblReportTitle
			// 
			this.lblReportTitle.AutoSize = true;
			this.lblReportTitle.Font = new System.Drawing.Font("Microsoft YaHei", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.lblReportTitle.Location = new System.Drawing.Point(253, 26);
			this.lblReportTitle.Name = "lblReportTitle";
			this.lblReportTitle.Size = new System.Drawing.Size(132, 21);
			this.lblReportTitle.TabIndex = 7;
			this.lblReportTitle.Text = "X月到期贷款情况";
			// 
			// frmCustomizeReport
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(639, 562);
			this.Controls.Add(this.panel1);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.MaximizeBox = false;
			this.Name = "frmCustomizeReport";
			this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
			this.Text = "X月到期贷款情况";
			this.Load += new System.EventHandler(this.Form1_Load);
			this.panel1.ResumeLayout(false);
			this.panel1.PerformLayout();
			this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.Panel panel1;
		private System.Windows.Forms.Button runReport;
		private System.Windows.Forms.Button btnRemove;
		private System.Windows.Forms.Button btnAdd;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.ListBox selectedColList;
		private System.Windows.Forms.ListBox optionalColList;
		private System.Windows.Forms.Label lblReportTitle;
	}
}
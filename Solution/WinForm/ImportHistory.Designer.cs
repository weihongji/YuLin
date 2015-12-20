namespace Reporting
{
	partial class frmImportHistory
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
			this.panelCommand = new System.Windows.Forms.Panel();
			this.btnRefresh = new System.Windows.Forms.Button();
			this.lblTitle = new System.Windows.Forms.Label();
			this.btnClose = new System.Windows.Forms.Button();
			this.panelData = new System.Windows.Forms.Panel();
			this.dataGridView1 = new System.Windows.Forms.DataGridView();
			this.statusBar = new System.Windows.Forms.StatusStrip();
			this.toolStripStatusTotal = new System.Windows.Forms.ToolStripStatusLabel();
			this.toolStripStatusTime = new System.Windows.Forms.ToolStripStatusLabel();
			this.toolStripStatusSelected = new System.Windows.Forms.ToolStripStatusLabel();
			this.panelCommand.SuspendLayout();
			this.panelData.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
			this.statusBar.SuspendLayout();
			this.SuspendLayout();
			// 
			// panelCommand
			// 
			this.panelCommand.Controls.Add(this.btnRefresh);
			this.panelCommand.Controls.Add(this.lblTitle);
			this.panelCommand.Controls.Add(this.btnClose);
			this.panelCommand.Dock = System.Windows.Forms.DockStyle.Top;
			this.panelCommand.Location = new System.Drawing.Point(0, 0);
			this.panelCommand.Name = "panelCommand";
			this.panelCommand.Size = new System.Drawing.Size(684, 61);
			this.panelCommand.TabIndex = 1;
			// 
			// btnRefresh
			// 
			this.btnRefresh.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnRefresh.Location = new System.Drawing.Point(439, 17);
			this.btnRefresh.Name = "btnRefresh";
			this.btnRefresh.Size = new System.Drawing.Size(91, 26);
			this.btnRefresh.TabIndex = 1;
			this.btnRefresh.Text = "刷新 (&R)";
			this.btnRefresh.UseVisualStyleBackColor = true;
			this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
			// 
			// lblTitle
			// 
			this.lblTitle.AutoSize = true;
			this.lblTitle.Font = new System.Drawing.Font("Microsoft YaHei", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.lblTitle.Location = new System.Drawing.Point(203, 20);
			this.lblTitle.Name = "lblTitle";
			this.lblTitle.Size = new System.Drawing.Size(138, 21);
			this.lblTitle.TabIndex = 0;
			this.lblTitle.Text = "数据导入记录查询";
			// 
			// btnClose
			// 
			this.btnClose.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnClose.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnClose.Location = new System.Drawing.Point(564, 17);
			this.btnClose.Name = "btnClose";
			this.btnClose.Size = new System.Drawing.Size(91, 26);
			this.btnClose.TabIndex = 2;
			this.btnClose.Text = "关闭 (&C)";
			this.btnClose.UseVisualStyleBackColor = true;
			this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
			// 
			// panelData
			// 
			this.panelData.Controls.Add(this.dataGridView1);
			this.panelData.Dock = System.Windows.Forms.DockStyle.Fill;
			this.panelData.Location = new System.Drawing.Point(0, 61);
			this.panelData.Name = "panelData";
			this.panelData.Size = new System.Drawing.Size(684, 501);
			this.panelData.TabIndex = 2;
			// 
			// dataGridView1
			// 
			this.dataGridView1.AllowUserToAddRows = false;
			this.dataGridView1.AllowUserToDeleteRows = false;
			this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
			this.dataGridView1.Dock = System.Windows.Forms.DockStyle.Fill;
			this.dataGridView1.Location = new System.Drawing.Point(0, 0);
			this.dataGridView1.Name = "dataGridView1";
			this.dataGridView1.ReadOnly = true;
			this.dataGridView1.RowTemplate.Height = 23;
			this.dataGridView1.RowTemplate.ReadOnly = true;
			this.dataGridView1.RowTemplate.Resizable = System.Windows.Forms.DataGridViewTriState.False;
			this.dataGridView1.Size = new System.Drawing.Size(684, 501);
			this.dataGridView1.TabIndex = 0;
			this.dataGridView1.SelectionChanged += new System.EventHandler(this.dataGridView1_SelectionChanged);
			// 
			// statusBar
			// 
			this.statusBar.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusTime,
            this.toolStripStatusTotal,
            this.toolStripStatusSelected});
			this.statusBar.Location = new System.Drawing.Point(0, 536);
			this.statusBar.Name = "statusBar";
			this.statusBar.Size = new System.Drawing.Size(684, 26);
			this.statusBar.TabIndex = 3;
			// 
			// toolStripStatusTotal
			// 
			this.toolStripStatusTotal.BorderSides = System.Windows.Forms.ToolStripStatusLabelBorderSides.Left;
			this.toolStripStatusTotal.Name = "toolStripStatusTotal";
			this.toolStripStatusTotal.Size = new System.Drawing.Size(141, 21);
			this.toolStripStatusTotal.Text = "Count of total records";
			// 
			// toolStripStatusTime
			// 
			this.toolStripStatusTime.Name = "toolStripStatusTime";
			this.toolStripStatusTime.Size = new System.Drawing.Size(145, 21);
			this.toolStripStatusTime.Text = "Time records loaded at";
			// 
			// toolStripStatusSelected
			// 
			this.toolStripStatusSelected.BorderSides = System.Windows.Forms.ToolStripStatusLabelBorderSides.Left;
			this.toolStripStatusSelected.Name = "toolStripStatusSelected";
			this.toolStripStatusSelected.Size = new System.Drawing.Size(146, 21);
			this.toolStripStatusSelected.Text = "Count of selected rows";
			this.toolStripStatusSelected.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// frmImportHistory
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.CancelButton = this.btnClose;
			this.ClientSize = new System.Drawing.Size(684, 562);
			this.Controls.Add(this.statusBar);
			this.Controls.Add(this.panelData);
			this.Controls.Add(this.panelCommand);
			this.KeyPreview = true;
			this.MinimumSize = new System.Drawing.Size(400, 300);
			this.Name = "frmImportHistory";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "数据导入查询";
			this.Load += new System.EventHandler(this.frmImportHistory_Load);
			this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.frmImportHistory_KeyDown);
			this.panelCommand.ResumeLayout(false);
			this.panelCommand.PerformLayout();
			this.panelData.ResumeLayout(false);
			((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
			this.statusBar.ResumeLayout(false);
			this.statusBar.PerformLayout();
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Panel panelCommand;
		private System.Windows.Forms.Label lblTitle;
		private System.Windows.Forms.Button btnClose;
		private System.Windows.Forms.Button btnRefresh;
		private System.Windows.Forms.Panel panelData;
		private System.Windows.Forms.DataGridView dataGridView1;
		private System.Windows.Forms.StatusStrip statusBar;
		private System.Windows.Forms.ToolStripStatusLabel toolStripStatusTotal;
		private System.Windows.Forms.ToolStripStatusLabel toolStripStatusTime;
		private System.Windows.Forms.ToolStripStatusLabel toolStripStatusSelected;
	}
}
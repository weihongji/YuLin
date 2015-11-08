﻿namespace Reporting
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
			this.panelDataGrid = new System.Windows.Forms.Panel();
			this.panelCommand = new System.Windows.Forms.Panel();
			this.btnRefresh = new System.Windows.Forms.Button();
			this.lblTitle = new System.Windows.Forms.Label();
			this.btnClose = new System.Windows.Forms.Button();
			this.dataGridView1 = new System.Windows.Forms.DataGridView();
			this.panelDataGrid.SuspendLayout();
			this.panelCommand.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
			this.SuspendLayout();
			// 
			// panelDataGrid
			// 
			this.panelDataGrid.Controls.Add(this.dataGridView1);
			this.panelDataGrid.Dock = System.Windows.Forms.DockStyle.Bottom;
			this.panelDataGrid.Location = new System.Drawing.Point(0, 61);
			this.panelDataGrid.Name = "panelDataGrid";
			this.panelDataGrid.Size = new System.Drawing.Size(684, 501);
			this.panelDataGrid.TabIndex = 0;
			// 
			// panelCommand
			// 
			this.panelCommand.Controls.Add(this.btnRefresh);
			this.panelCommand.Controls.Add(this.lblTitle);
			this.panelCommand.Controls.Add(this.btnClose);
			this.panelCommand.Dock = System.Windows.Forms.DockStyle.Fill;
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
			this.btnRefresh.TabIndex = 2;
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
			this.lblTitle.TabIndex = 1;
			this.lblTitle.Text = "数据导入记录查询";
			// 
			// btnClose
			// 
			this.btnClose.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnClose.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnClose.Location = new System.Drawing.Point(564, 17);
			this.btnClose.Name = "btnClose";
			this.btnClose.Size = new System.Drawing.Size(91, 26);
			this.btnClose.TabIndex = 0;
			this.btnClose.Text = "关闭 (&C)";
			this.btnClose.UseVisualStyleBackColor = true;
			this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
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
			this.dataGridView1.Size = new System.Drawing.Size(684, 501);
			this.dataGridView1.TabIndex = 0;
			// 
			// frmImportHistory
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.CancelButton = this.btnClose;
			this.ClientSize = new System.Drawing.Size(684, 562);
			this.Controls.Add(this.panelCommand);
			this.Controls.Add(this.panelDataGrid);
			this.Name = "frmImportHistory";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "数据导入查询";
			this.Load += new System.EventHandler(this.frmImportHistory_Load);
			this.panelDataGrid.ResumeLayout(false);
			this.panelCommand.ResumeLayout(false);
			this.panelCommand.PerformLayout();
			((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
			this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.Panel panelDataGrid;
		private System.Windows.Forms.Panel panelCommand;
		private System.Windows.Forms.Label lblTitle;
		private System.Windows.Forms.Button btnClose;
		private System.Windows.Forms.Button btnRefresh;
		private System.Windows.Forms.DataGridView dataGridView1;
	}
}
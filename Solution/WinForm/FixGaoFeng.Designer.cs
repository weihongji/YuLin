namespace Reporting
{
	partial class frmFixGaoFeng
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
			this.label1 = new System.Windows.Forms.Label();
			this.label2 = new System.Windows.Forms.Label();
			this.cmbDate = new System.Windows.Forms.ComboBox();
			this.btnFix = new System.Windows.Forms.Button();
			this.SuspendLayout();
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Font = new System.Drawing.Font("Microsoft YaHei", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label1.Location = new System.Drawing.Point(134, 19);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(138, 21);
			this.label1.TabIndex = 0;
			this.label1.Text = "将高锋修改成高峰";
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.label2.Location = new System.Drawing.Point(100, 83);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(68, 17);
			this.label2.TabIndex = 1;
			this.label2.Text = "数据日期：";
			// 
			// cmbDate
			// 
			this.cmbDate.FormattingEnabled = true;
			this.cmbDate.Location = new System.Drawing.Point(185, 80);
			this.cmbDate.Name = "cmbDate";
			this.cmbDate.Size = new System.Drawing.Size(121, 20);
			this.cmbDate.TabIndex = 2;
			// 
			// btnFix
			// 
			this.btnFix.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnFix.Location = new System.Drawing.Point(158, 157);
			this.btnFix.Name = "btnFix";
			this.btnFix.Size = new System.Drawing.Size(90, 32);
			this.btnFix.TabIndex = 3;
			this.btnFix.Text = "修改";
			this.btnFix.UseVisualStyleBackColor = true;
			this.btnFix.Click += new System.EventHandler(this.btnFix_Click);
			// 
			// frmFixGaoFeng
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(406, 230);
			this.Controls.Add(this.btnFix);
			this.Controls.Add(this.cmbDate);
			this.Controls.Add(this.label2);
			this.Controls.Add(this.label1);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.MaximizeBox = false;
			this.Name = "frmFixGaoFeng";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "修改高锋";
			this.Load += new System.EventHandler(this.frmFixGaoFeng_Load);
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.ComboBox cmbDate;
		private System.Windows.Forms.Button btnFix;
	}
}
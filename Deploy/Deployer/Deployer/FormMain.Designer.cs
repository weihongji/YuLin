namespace Deployer
{
	partial class FormMain
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
			this.btnUpgrade = new System.Windows.Forms.Button();
			this.lblVersionLabel = new System.Windows.Forms.Label();
			this.lblDateLabel = new System.Windows.Forms.Label();
			this.lblVersionText = new System.Windows.Forms.Label();
			this.lblDateText = new System.Windows.Forms.Label();
			this.SuspendLayout();
			// 
			// btnUpgrade
			// 
			this.btnUpgrade.Font = new System.Drawing.Font("Microsoft YaHei", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnUpgrade.Location = new System.Drawing.Point(118, 146);
			this.btnUpgrade.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
			this.btnUpgrade.Name = "btnUpgrade";
			this.btnUpgrade.Size = new System.Drawing.Size(149, 51);
			this.btnUpgrade.TabIndex = 0;
			this.btnUpgrade.Text = "升级到最新版本";
			this.btnUpgrade.UseVisualStyleBackColor = true;
			this.btnUpgrade.Click += new System.EventHandler(this.btnUpgrade_Click);
			// 
			// lblVersionLabel
			// 
			this.lblVersionLabel.AutoSize = true;
			this.lblVersionLabel.Font = new System.Drawing.Font("Microsoft YaHei", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.lblVersionLabel.Location = new System.Drawing.Point(59, 37);
			this.lblVersionLabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
			this.lblVersionLabel.Name = "lblVersionLabel";
			this.lblVersionLabel.Size = new System.Drawing.Size(107, 25);
			this.lblVersionLabel.TabIndex = 1;
			this.lblVersionLabel.Text = "最新版本：";
			// 
			// lblDateLabel
			// 
			this.lblDateLabel.AutoSize = true;
			this.lblDateLabel.Font = new System.Drawing.Font("Microsoft YaHei", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.lblDateLabel.Location = new System.Drawing.Point(59, 72);
			this.lblDateLabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
			this.lblDateLabel.Name = "lblDateLabel";
			this.lblDateLabel.Size = new System.Drawing.Size(107, 25);
			this.lblDateLabel.TabIndex = 1;
			this.lblDateLabel.Text = "发布时间：";
			// 
			// lblVersionText
			// 
			this.lblVersionText.AutoSize = true;
			this.lblVersionText.Font = new System.Drawing.Font("Microsoft YaHei", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.lblVersionText.Location = new System.Drawing.Point(168, 37);
			this.lblVersionText.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
			this.lblVersionText.Name = "lblVersionText";
			this.lblVersionText.Size = new System.Drawing.Size(71, 25);
			this.lblVersionText.TabIndex = 1;
			this.lblVersionText.Text = "1.0.0.1";
			// 
			// lblDateText
			// 
			this.lblDateText.AutoSize = true;
			this.lblDateText.Font = new System.Drawing.Font("Microsoft YaHei", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.lblDateText.Location = new System.Drawing.Point(168, 72);
			this.lblDateText.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
			this.lblDateText.Name = "lblDateText";
			this.lblDateText.Size = new System.Drawing.Size(157, 25);
			this.lblDateText.TabIndex = 1;
			this.lblDateText.Text = "2015年10月29日";
			// 
			// FormMain
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(384, 262);
			this.Controls.Add(this.lblDateText);
			this.Controls.Add(this.lblDateLabel);
			this.Controls.Add(this.lblVersionText);
			this.Controls.Add(this.lblVersionLabel);
			this.Controls.Add(this.btnUpgrade);
			this.Font = new System.Drawing.Font("Microsoft YaHei", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
			this.MaximizeBox = false;
			this.Name = "FormMain";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "长安银行报表系统部署工具";
			this.Load += new System.EventHandler(this.FormMain_Load);
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Button btnUpgrade;
		private System.Windows.Forms.Label lblVersionLabel;
		private System.Windows.Forms.Label lblDateLabel;
		private System.Windows.Forms.Label lblVersionText;
		private System.Windows.Forms.Label lblDateText;
	}
}


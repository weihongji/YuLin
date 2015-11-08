namespace Reporting
{
	partial class frmCustomizeDQDK
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
			this.btnOK = new System.Windows.Forms.Button();
			this.groupBox1 = new System.Windows.Forms.GroupBox();
			this.btnPublicRemove = new System.Windows.Forms.Button();
			this.btnPublicAdd = new System.Windows.Forms.Button();
			this.label2 = new System.Windows.Forms.Label();
			this.label1 = new System.Windows.Forms.Label();
			this.listBoxPublicSelection = new System.Windows.Forms.ListBox();
			this.listBoxPublicCandidates = new System.Windows.Forms.ListBox();
			this.groupBox2 = new System.Windows.Forms.GroupBox();
			this.btnPrivateRemove = new System.Windows.Forms.Button();
			this.btnPrivateAdd = new System.Windows.Forms.Button();
			this.label3 = new System.Windows.Forms.Label();
			this.label4 = new System.Windows.Forms.Label();
			this.listBoxPrivateSelection = new System.Windows.Forms.ListBox();
			this.listBoxPrivateCandidates = new System.Windows.Forms.ListBox();
			this.btnCancel = new System.Windows.Forms.Button();
			this.groupBox1.SuspendLayout();
			this.groupBox2.SuspendLayout();
			this.SuspendLayout();
			// 
			// btnOK
			// 
			this.btnOK.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnOK.Location = new System.Drawing.Point(579, 527);
			this.btnOK.Name = "btnOK";
			this.btnOK.Size = new System.Drawing.Size(115, 33);
			this.btnOK.TabIndex = 2;
			this.btnOK.Text = "确定";
			this.btnOK.UseVisualStyleBackColor = true;
			this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
			// 
			// groupBox1
			// 
			this.groupBox1.Controls.Add(this.btnPublicRemove);
			this.groupBox1.Controls.Add(this.btnPublicAdd);
			this.groupBox1.Controls.Add(this.label2);
			this.groupBox1.Controls.Add(this.label1);
			this.groupBox1.Controls.Add(this.listBoxPublicSelection);
			this.groupBox1.Controls.Add(this.listBoxPublicCandidates);
			this.groupBox1.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.groupBox1.Location = new System.Drawing.Point(19, 20);
			this.groupBox1.Name = "groupBox1";
			this.groupBox1.Size = new System.Drawing.Size(417, 490);
			this.groupBox1.TabIndex = 0;
			this.groupBox1.TabStop = false;
			this.groupBox1.Text = "对公数据列";
			// 
			// btnPublicRemove
			// 
			this.btnPublicRemove.Font = new System.Drawing.Font("SimSun", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnPublicRemove.Location = new System.Drawing.Point(174, 221);
			this.btnPublicRemove.Name = "btnPublicRemove";
			this.btnPublicRemove.Size = new System.Drawing.Size(63, 33);
			this.btnPublicRemove.TabIndex = 2;
			this.btnPublicRemove.Text = "<-";
			this.btnPublicRemove.UseVisualStyleBackColor = true;
			this.btnPublicRemove.Click += new System.EventHandler(this.btnPublicRemove_Click);
			// 
			// btnPublicAdd
			// 
			this.btnPublicAdd.Font = new System.Drawing.Font("SimSun", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnPublicAdd.Location = new System.Drawing.Point(174, 161);
			this.btnPublicAdd.Name = "btnPublicAdd";
			this.btnPublicAdd.Size = new System.Drawing.Size(63, 33);
			this.btnPublicAdd.TabIndex = 1;
			this.btnPublicAdd.Text = "->";
			this.btnPublicAdd.UseVisualStyleBackColor = true;
			this.btnPublicAdd.Click += new System.EventHandler(this.btnPublicAdd_Click);
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label2.Location = new System.Drawing.Point(287, 31);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(68, 17);
			this.label2.TabIndex = 14;
			this.label2.Text = "已选数据列";
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label1.Location = new System.Drawing.Point(57, 31);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(68, 17);
			this.label1.TabIndex = 15;
			this.label1.Text = "可选数据列";
			// 
			// listBoxPublicSelection
			// 
			this.listBoxPublicSelection.FormattingEnabled = true;
			this.listBoxPublicSelection.ItemHeight = 17;
			this.listBoxPublicSelection.Location = new System.Drawing.Point(246, 54);
			this.listBoxPublicSelection.Name = "listBoxPublicSelection";
			this.listBoxPublicSelection.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
			this.listBoxPublicSelection.Size = new System.Drawing.Size(150, 412);
			this.listBoxPublicSelection.TabIndex = 3;
			// 
			// listBoxPublicCandidates
			// 
			this.listBoxPublicCandidates.FormattingEnabled = true;
			this.listBoxPublicCandidates.ItemHeight = 17;
			this.listBoxPublicCandidates.Location = new System.Drawing.Point(16, 54);
			this.listBoxPublicCandidates.Name = "listBoxPublicCandidates";
			this.listBoxPublicCandidates.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
			this.listBoxPublicCandidates.Size = new System.Drawing.Size(150, 412);
			this.listBoxPublicCandidates.TabIndex = 0;
			// 
			// groupBox2
			// 
			this.groupBox2.Controls.Add(this.btnPrivateRemove);
			this.groupBox2.Controls.Add(this.btnPrivateAdd);
			this.groupBox2.Controls.Add(this.label3);
			this.groupBox2.Controls.Add(this.label4);
			this.groupBox2.Controls.Add(this.listBoxPrivateSelection);
			this.groupBox2.Controls.Add(this.listBoxPrivateCandidates);
			this.groupBox2.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.groupBox2.Location = new System.Drawing.Point(472, 20);
			this.groupBox2.Name = "groupBox2";
			this.groupBox2.Size = new System.Drawing.Size(417, 490);
			this.groupBox2.TabIndex = 1;
			this.groupBox2.TabStop = false;
			this.groupBox2.Text = "个人数据列";
			// 
			// btnPrivateRemove
			// 
			this.btnPrivateRemove.Font = new System.Drawing.Font("SimSun", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnPrivateRemove.Location = new System.Drawing.Point(174, 221);
			this.btnPrivateRemove.Name = "btnPrivateRemove";
			this.btnPrivateRemove.Size = new System.Drawing.Size(63, 33);
			this.btnPrivateRemove.TabIndex = 2;
			this.btnPrivateRemove.Text = "<-";
			this.btnPrivateRemove.UseVisualStyleBackColor = true;
			this.btnPrivateRemove.Click += new System.EventHandler(this.btnPrivateRemove_Click);
			// 
			// btnPrivateAdd
			// 
			this.btnPrivateAdd.Font = new System.Drawing.Font("SimSun", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
			this.btnPrivateAdd.Location = new System.Drawing.Point(174, 161);
			this.btnPrivateAdd.Name = "btnPrivateAdd";
			this.btnPrivateAdd.Size = new System.Drawing.Size(63, 33);
			this.btnPrivateAdd.TabIndex = 1;
			this.btnPrivateAdd.Text = "->";
			this.btnPrivateAdd.UseVisualStyleBackColor = true;
			this.btnPrivateAdd.Click += new System.EventHandler(this.btnPrivateAdd_Click);
			// 
			// label3
			// 
			this.label3.AutoSize = true;
			this.label3.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label3.Location = new System.Drawing.Point(288, 31);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size(68, 17);
			this.label3.TabIndex = 14;
			this.label3.Text = "已选数据列";
			// 
			// label4
			// 
			this.label4.AutoSize = true;
			this.label4.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label4.Location = new System.Drawing.Point(57, 31);
			this.label4.Name = "label4";
			this.label4.Size = new System.Drawing.Size(68, 17);
			this.label4.TabIndex = 15;
			this.label4.Text = "可选数据列";
			// 
			// listBoxPrivateSelection
			// 
			this.listBoxPrivateSelection.FormattingEnabled = true;
			this.listBoxPrivateSelection.ItemHeight = 17;
			this.listBoxPrivateSelection.Location = new System.Drawing.Point(247, 54);
			this.listBoxPrivateSelection.Name = "listBoxPrivateSelection";
			this.listBoxPrivateSelection.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
			this.listBoxPrivateSelection.Size = new System.Drawing.Size(150, 412);
			this.listBoxPrivateSelection.TabIndex = 3;
			// 
			// listBoxPrivateCandidates
			// 
			this.listBoxPrivateCandidates.FormattingEnabled = true;
			this.listBoxPrivateCandidates.ItemHeight = 17;
			this.listBoxPrivateCandidates.Location = new System.Drawing.Point(16, 54);
			this.listBoxPrivateCandidates.Name = "listBoxPrivateCandidates";
			this.listBoxPrivateCandidates.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
			this.listBoxPrivateCandidates.Size = new System.Drawing.Size(150, 412);
			this.listBoxPrivateCandidates.TabIndex = 0;
			// 
			// btnCancel
			// 
			this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnCancel.Location = new System.Drawing.Point(754, 527);
			this.btnCancel.Name = "btnCancel";
			this.btnCancel.Size = new System.Drawing.Size(115, 33);
			this.btnCancel.TabIndex = 3;
			this.btnCancel.Text = "取消";
			this.btnCancel.UseVisualStyleBackColor = true;
			this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
			// 
			// frmCustomizeDQDK
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.CancelButton = this.btnCancel;
			this.ClientSize = new System.Drawing.Size(914, 582);
			this.Controls.Add(this.btnCancel);
			this.Controls.Add(this.groupBox2);
			this.Controls.Add(this.groupBox1);
			this.Controls.Add(this.btnOK);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.MaximizeBox = false;
			this.Name = "frmCustomizeDQDK";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "到期贷款情况自定义";
			this.Load += new System.EventHandler(this.frmCustomizeReport_Load);
			this.groupBox1.ResumeLayout(false);
			this.groupBox1.PerformLayout();
			this.groupBox2.ResumeLayout(false);
			this.groupBox2.PerformLayout();
			this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.Button btnOK;
		private System.Windows.Forms.GroupBox groupBox1;
		private System.Windows.Forms.Button btnPublicRemove;
		private System.Windows.Forms.Button btnPublicAdd;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.ListBox listBoxPublicSelection;
		private System.Windows.Forms.ListBox listBoxPublicCandidates;
		private System.Windows.Forms.GroupBox groupBox2;
		private System.Windows.Forms.Button btnPrivateRemove;
		private System.Windows.Forms.Button btnPrivateAdd;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.Label label4;
		private System.Windows.Forms.ListBox listBoxPrivateSelection;
		private System.Windows.Forms.ListBox listBoxPrivateCandidates;
		private System.Windows.Forms.Button btnCancel;

	}
}
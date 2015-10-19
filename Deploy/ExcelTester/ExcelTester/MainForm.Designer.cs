namespace ExcelTester
{
	partial class MainForm
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
			this.btnReadCell = new System.Windows.Forms.Button();
			this.btnOleRows = new System.Windows.Forms.Button();
			this.btnExit = new System.Windows.Forms.Button();
			this.SuspendLayout();
			// 
			// btnReadCell
			// 
			this.btnReadCell.Location = new System.Drawing.Point(133, 52);
			this.btnReadCell.Name = "btnReadCell";
			this.btnReadCell.Size = new System.Drawing.Size(141, 42);
			this.btnReadCell.TabIndex = 0;
			this.btnReadCell.Text = "Read Cell";
			this.btnReadCell.UseVisualStyleBackColor = true;
			this.btnReadCell.Click += new System.EventHandler(this.btnReadCell_Click);
			// 
			// btnOleRows
			// 
			this.btnOleRows.Location = new System.Drawing.Point(133, 131);
			this.btnOleRows.Name = "btnOleRows";
			this.btnOleRows.Size = new System.Drawing.Size(141, 42);
			this.btnOleRows.TabIndex = 1;
			this.btnOleRows.Text = "OLEDB Rows";
			this.btnOleRows.UseVisualStyleBackColor = true;
			this.btnOleRows.Click += new System.EventHandler(this.btnOleRows_Click);
			// 
			// btnExit
			// 
			this.btnExit.Location = new System.Drawing.Point(133, 240);
			this.btnExit.Name = "btnExit";
			this.btnExit.Size = new System.Drawing.Size(141, 42);
			this.btnExit.TabIndex = 1;
			this.btnExit.Text = "E&xit";
			this.btnExit.UseVisualStyleBackColor = true;
			this.btnExit.Click += new System.EventHandler(this.btnExit_Click);
			// 
			// MainForm
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(407, 328);
			this.Controls.Add(this.btnExit);
			this.Controls.Add(this.btnOleRows);
			this.Controls.Add(this.btnReadCell);
			this.Name = "MainForm";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "Excel Functionality Tester";
			this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.Button btnReadCell;
		private System.Windows.Forms.Button btnOleRows;
		private System.Windows.Forms.Button btnExit;
	}
}


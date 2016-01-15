using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Reporting
{
	public partial class MessageForm : Form
	{
		public MessageForm() {
			InitializeComponent();
		}

		public MessageForm(string title, string message)
			: this(0, 0, title, message) {
		}

		public MessageForm(int height, string title, string message)
			: this(0, height, title, message) {
		}

		public MessageForm(int width, int height, string title, string message)
			: this() {

			if (width > 0) {
				this.Width = width;
			}
			if (height > 0) {
				this.Height = height;
			}
			this.Text = title;
			this.txtMessage.Text = message;
		}
	}
}

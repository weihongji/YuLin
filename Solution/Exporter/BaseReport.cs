using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Configuration;
using System.IO;

namespace Reporting
{
	public abstract class BaseReport
	{
		public DateTime AsOfDate { get; set; }

		private Logger _logger;

		public Logger Logger {
			get {
				if (_logger == null) {
					_logger = Logger.GetLogger(GetClassName4Log());
				}
				return _logger;
			}
		}

		public BaseReport(DateTime asOfDate) {
			this.AsOfDate = asOfDate;
		}

		public abstract string GenerateReport();

		public static string GetReportFolder() {
			return GetReportFolder(new DateTime(2000, 1, 1));
		}

		public static string GetReportFolder(DateTime asOfDate) {
			var dir = (ConfigurationManager.AppSettings["ReportDirectory"] ?? "").Trim().Replace("/", @"\");
			if (dir.IndexOf(':') > 0) { // full path, such as C:\Report
				return dir;
			}

			if (dir.IndexOf('\\') == 0) {
				dir = dir.Substring(1);
			}
			if (dir.Length == 0) {
				dir = "Report";
			}
			if (asOfDate.Year > 2010) {
				dir += "\\" + asOfDate.ToString("yyyyMM");
			}
			return System.Environment.CurrentDirectory + "\\" + dir;
		}

		public string CreateReportFile(string templateName, string targetName) {
			return CreateReportFile(templateName, targetName, this.AsOfDate);
		}

		public string CreateReportFile(string templateName, string targetName, DateTime date) {
			var template = @"Template\" + templateName;

			var folder = GetReportFolder(date);
			if (!Directory.Exists(folder)) {
				Directory.CreateDirectory(folder);
			}
			var filePath = folder + "\\" + targetName;
			if (File.Exists(template)) {
				File.Copy(template, filePath, true);
			}
			else {
				throw new FileNotFoundException("Excel template file doesn't exist. Target: " + template);
			}
			return filePath;
		}

		public virtual string GetClassName4Log() {
			return this.ToString();
		}
	}
}

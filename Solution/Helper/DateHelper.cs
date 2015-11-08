using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class DateHelper
	{
		public static DateTime GetLastDayInMonth(DateTime date) {
			var dt = new DateTime(date.Year, date.Month, 1);
			return dt.AddMonths(1).AddDays(-1);
		}

		public static DateTime Look4Date(string fileName) {
			DateTime dt = new DateTime(1900, 1, 1);
			int lastSlash = fileName.LastIndexOf('\\');
			if (lastSlash >= 0) {
				if (lastSlash + 1 == fileName.Length) { // Slash is the last character
					return dt;
				}
				fileName = fileName.Substring(lastSlash + 1);
			}
			fileName = fileName.Substring(0, fileName.LastIndexOf('.'));
			int startAt = fileName.IndexOf("20");
			while (startAt >= 0) {
				if (startAt > 0) {
					var c = fileName.Substring(startAt - 1, 1)[0];
					if (char.IsDigit(c)) {
						fileName = fileName.Substring(startAt + 2);
					}
					else {
						fileName = fileName.Substring(startAt);
						if (ParseDate(fileName, out dt)) {
							return dt;
						}
						else {
							fileName = fileName.Substring(2);
						}
					}
				}
				else {
					if (ParseDate(fileName, out dt)) {
						return dt;
					}
					else {
						fileName = fileName.Substring(2);
					}
				}
				startAt = fileName.IndexOf("20");
			}
			return dt;
		}

		private static bool ParseDate(string s, out DateTime dt) {
			dt = new DateTime(1900, 1, 1);
			if (s.Length == 8 || (s.Length > 8 && !char.IsDigit(s[8]))) {
				s = string.Format("{0}/{1}/{2}", s.Substring(0, 4), s.Substring(4, 2), s.Substring(6, 2));
				if (DateTime.TryParse(s, out dt)) {
					if (dt.Year > 2010) {
						return true;
					}
				}
			}
			return false;
		}
	}
}

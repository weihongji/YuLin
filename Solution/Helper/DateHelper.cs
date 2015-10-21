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
	}
}

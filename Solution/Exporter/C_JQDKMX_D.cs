using System;
using System.Collections.Generic;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class C_JQDKMX_D : ImportLoanDaily
	{
		public C_JQDKMX_D(DateTime asOfDate, DateTime asOfDate2, List<TableMapping> columns)
			: base(XEnum.ReportType.C_JQDKMX_D, asOfDate, asOfDate2, columns) {
		}

		public override string GetClassName4Log() {
			return this.ToString();
		}
	}
}

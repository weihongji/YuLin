using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Entities;

namespace Exporter
{
	interface IExporter
	{
		string ExportData(XEnum.ReportType exportType, List<object> list);
	}
}

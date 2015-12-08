using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class BackgroundThread
	{
		private Logger logger = Logger.GetLogger("BackgroundThread");

		/// <summary>
		/// Try to start SQL Server service if it is not running.
		/// </summary>
		/// <remarks>
		/// This is used to handle the issue that SQL Server service stops for unknown reason.
		/// </remarks>
		/// <returns>
		/// 0: Already running, nothing to do
		/// 1: Success to start
		/// 2: Failed to start
		/// </returns>
		public void StartSqlServer() {
			logger.Debug("Checking sql server service...");
			int result = 0;
			Process[] sqlservers = Process.GetProcessesByName("sqlservr");
			if (sqlservers.Length == 0) {
				try {
					var sqlinstance = GetSqlServerInstance();
					Process process = new Process();
					process.StartInfo.FileName = "net";
					process.StartInfo.Arguments = "start " + sqlinstance;
					process.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
					process.Start();
					process.WaitForExit();
					process.Close();
					sqlservers = Process.GetProcessesByName("sqlservr");
					if (sqlservers.Length > 0) {
						result = 1;
						logger.Info("Sql server started");
					}
					else {
						result = 2;
						logger.Info("Sql server failed to start");
					}
				}
				catch (Exception ex) {
					logger.Error("Failed to start sql server.\r\n", ex);
					result = 2;
				}
			}
			logger.Debug("Starting service result: " + result.ToString());
		}

		private string GetSqlServerInstance() {
			var result = "MSSQLSERVER";
			try {
				var cnnStr = ConfigurationManager.ConnectionStrings["conn"].ConnectionString;
				var cnn = new System.Data.SqlClient.SqlConnection(cnnStr);
				var server = cnn.DataSource;
				if (server.IndexOf("\\") > 0) {
					result = string.Format("MSSQL${0}", server.Substring(server.IndexOf("\\") + 1));
				}
			}
			catch (Exception ex) {
				logger.Error("Failed when getting sql server instance name:\r\n", ex);
			}
			return result;
		}
	}
}

using System;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;

namespace Reporting
{
	/// <summary>
	/// 针对SQL Server数据库操作的通用类
	/// </summary>
	public class SqlDbHelper
	{
		private string connectionString;

		public string ConnectionString {
			get { return connectionString;  }
			set { connectionString = value; }
		}

		public SqlDbHelper() {
			//#warning 注意，如果采用这种方式构建实例，必须在web.config中配置“conn”的数据库连接字符串
			connectionString = ConfigurationManager.ConnectionStrings["conn"].ConnectionString;
		}

		public SqlDbHelper(string connectionString) {
			this.connectionString = connectionString;
		}

		public DataTable ExecuteDataTable(string sql, CommandType commandType, SqlParameter[] parameters) {
			DataTable data = new DataTable();
			using (SqlConnection connection = new SqlConnection(connectionString)) {
				using (SqlCommand command = new SqlCommand(sql, connection)) {
					command.CommandType = commandType;
					if (parameters != null) {
						foreach (SqlParameter parameter in parameters) {
							command.Parameters.Add(parameter);
						}
					}
					SqlDataAdapter adapter = new SqlDataAdapter(command);
					adapter.Fill(data);
					command.Parameters.Clear();
				}
			}
			return data;
		}

		public DataTable ExecuteDataTable(string sql) {
			return ExecuteDataTable(sql, CommandType.Text, null);
		}

		public DataTable ExecuteDataTable(string sql, SqlParameter[] parameters) {
			return ExecuteDataTable(sql, CommandType.Text, parameters);
		}

		public DataTable ExecuteDataTable(string sql, CommandType commandType) {
			return ExecuteDataTable(sql, commandType, null);
		}

		public SqlDataReader ExecuteReader(string sql, CommandType commandType, SqlParameter[] parameters) {
			SqlConnection connection = new SqlConnection(connectionString);
			SqlCommand command = new SqlCommand(sql, connection);
			if (parameters != null) {
				foreach (SqlParameter parameter in parameters) {
					command.Parameters.Add(parameter);
				}
			}
			connection.Open();
			return command.ExecuteReader(CommandBehavior.CloseConnection);
		}

		public SqlDataReader ExecuteReader(string sql) {
			return ExecuteReader(sql, CommandType.Text, null);
		}

		public SqlDataReader ExecuteReader(string sql, SqlParameter[] parameters) {
			return ExecuteReader(sql, CommandType.Text, parameters);
		}

		public SqlDataReader ExecuteReader(string sql, CommandType commandType) {
			return ExecuteReader(sql, commandType, null);
		}

		public Object ExecuteScalar(string sql, CommandType commandType, SqlParameter[] parameters) {
			object result = null;
			using (SqlConnection connection = new SqlConnection(connectionString)) {
				using (SqlCommand command = new SqlCommand(sql, connection)) {
					command.CommandType = commandType;
					command.Parameters.Clear();
					if (parameters != null) {
						foreach (SqlParameter parameter in parameters) {
							command.Parameters.Add(parameter);
						}
					}
					connection.Open();
					result = command.ExecuteScalar();
					command.Parameters.Clear();
				}
			}
			return result;
		}

		public Object ExecuteScalar(string sql) {
			return ExecuteScalar(sql, CommandType.Text, null);
		}

		public Object ExecuteScalar(string sql, SqlParameter[] parameters) {
			return ExecuteScalar(sql, CommandType.Text, parameters);
		}

		public Object ExecuteScalar(string sql, CommandType commandType) {
			return ExecuteScalar(sql, commandType, null);
		}

        /// <summary>
        /// ////////////
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="commandType"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
		public int ExecuteNonQuery(string sql, CommandType commandType, SqlParameter[] parameters) {
			int count = 0;
			using (SqlConnection connection = new SqlConnection(connectionString)) {
				using (SqlCommand command = new SqlCommand(sql, connection)) {
					command.CommandType = commandType;
					if (parameters != null) {
						foreach (SqlParameter parameter in parameters) {
							command.Parameters.Add(parameter);
						}
					}
					connection.Open();
					count = command.ExecuteNonQuery();
					command.Parameters.Clear();
				}
			}
			return count;
		}

		public int ExecuteNonQuery(string sql) {
			return ExecuteNonQuery(sql, CommandType.Text, null);
		}

		public int ExecuteNonQuery(string sql, SqlParameter[] parameters) {
			return ExecuteNonQuery(sql, CommandType.Text, parameters);
		}

		public int ExecuteNonQuery(string sql, CommandType commandType) {
			return ExecuteNonQuery(sql, commandType, null);
		}

		public DataTable GetTables() {
			DataTable data = null;
			using (SqlConnection connection = new SqlConnection(connectionString)) {
				connection.Open();
				data = connection.GetSchema("Tables");
			}
			return data;
		}
	}
}

﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Reporting
{
	public abstract class EntityBase
	{
		private static SqlDbHelper _dao;

		protected static SqlDbHelper dao {
			get {
				if (_dao == null) {
					_dao = new SqlDbHelper();
				}
				return _dao;
			}
		}
	}
}

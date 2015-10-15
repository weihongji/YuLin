using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Entities
{
	public class XEnum
	{
		public enum ImportItemType
		{
			Loan = 0, // 贷款欠款查询
			Public = 1, // 对公
			Private = 2, // 个人
			NonAccrual = 3, // 非应计贷款明细表
			Overdue = 4 // 逾期贷款明细表
		}

		public enum ReportType
		{
			LoanRiskPerMonth = 0 // 榆林分行9月末风险贷款情况表（五级分类）
		}

		public enum ImportState
		{
			Initial = 0,
			AllCopied = 1,
			Imported = 2
		}
	}
}

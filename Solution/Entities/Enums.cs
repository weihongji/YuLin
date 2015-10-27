using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class XEnum
	{
		public enum ImportItemType
		{
			Loan = 1, // 贷款欠款查询
			Public = 2, // 对公
			Private = 3, // 个人
			NonAccrual = 4, // 非应计贷款明细表
			Overdue = 5, // 逾期贷款明细表
			YWNei = 6, // 业务状况表一级科目（表内）
			YWWai = 7 // 业务状况表一级科目（表外）
		}

		public enum ReportType
		{
			None = 0,

			// Fix
			X_WJFL_M = 1,			// 风险贷款情况表（五级分类）
			X_FXDKTB_D = 2,			// 风险贷款通报（日报）
			X_BLDKJC_X = 3,			// 榆林地区不良贷款监测旬报（旬报）
			X_ZXQYZJXQ_S = 4,		// 中小企业资金需求及银行业支持情况表（季报）
			X_CSHSX_M = 5,			// 城商行授信情况统计表
			X_FXDKBH_D = 6,			// 风险贷款变化情况表
			X_SZHZ_M = 7,			// 榆林分行三张表汇总表（月报）
			X_DKZLFL_M = 8,			// 贷款质量分类情况汇总表

			// Finacial
			F_HYB_M = 20,			// 风险贷款情况表-行业版

			// Finacial - Month
			F_GF0102_081_M = 21,	// GF0102-081
			F_GF0107_141_M = 22,	// GF0107-141
			F_SF6301_141_M = 23,	// SF6301-141
			F_SF6401_141_M = 24,	// SF6401-141

			// Finacial - Season
			F_GF1101_121_S = 31,	// GF1101-121
			F_GF1301_081_S = 32,	// GF1301-081
			F_GF1302_081_S = 33,	// GF1302-081
			F_GF1303_081_S = 34,	// GF1303-081
			F_GF1304_081_S = 35,	// GF1304-081
			F_GF1403_111_S = 36,	// GF1403-111
			F_SF6302_131_S = 37,	// SF6302-131
			F_SF6402_131_S = 38,	// SF6402-131
			F_GF1103_121_S = 39,	// GF1103-121
			F_GF1200_101_S = 40,	// GF1200-101

			// Customize
			C_DQDJQK_M = 61,		// 到期贷款情况
			C_JQDKMX_M = 62,		// 结清贷款明细表
			C_XZDKMX_M = 63,		// 新增贷款明细表
			C_FXDKBH_D = 64,		// 风险贷款变化情况表

			// Reserved
			R_WJFL_M = 71,			// 五级分类
		}

		public enum ImportState
		{
			Initial = 0,
			Imported = 1, // All sourc tables imported, but Danger Leve in Loan and OrgNo in Private haven't been assigned.
			Complete = 2
		}
	}
}

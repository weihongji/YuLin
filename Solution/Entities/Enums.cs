using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Reporting
{
	public class XEnum
	{
		public enum OrgArea
		{
			YuLin = 1, // 榆林
			ShenFu = 2 // 神府
		}

		public enum ImportItemType
		{
			None = 0,
			Loan = 1, // 贷款欠款查询（榆林）
			Public = 2, // 对公
			Private = 3, // 个人
			NonAccrual = 4, // 非应计贷款明细表
			Overdue = 5, // 逾期贷款明细表
			YWNei = 6, // 业务状况表一级科目（表内）
			YWWai = 7, // 业务状况表一级科目（表外）
			LoanSF = 8, // 贷款欠款查询（神府）
			WjflSF = 9 // 五级分类（神府）
		}

		public enum WjflSheetSF
		{
			YQ = 1, // 逾期
			BL = 2, // 不良
			FYJ = 3, // 非应计
			ZQX = 4, // 只欠息
			GZ = 5 // 关注
		}

		public enum ReportType
		{
			None = 0,

			// Fix
			X_WJFL_M = 1,			// 风险贷款情况表（五级分类）
			X_FXDKTB_D = 2,			// 风险贷款通报（日报）
			X_BLDKJC_X = 3,			// 榆林地区不良贷款监测旬报（旬报）
			X_ZXQYZJXQ_S = 4,		// 中小企业资金需求及银行业支持情况报表（季报）
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
			F_GF1103_121_S = 32,	// GF1103-121
			F_GF1200_101_S = 33,	// GF1200-101
			F_GF1301_081_S = 34,	// GF1301-081
			F_GF1302_081_S = 35,	// GF1302-081
			F_GF1303_081_S = 36,	// GF1303-081
			F_GF1304_081_S = 37,	// GF1304-081
			F_GF1403_111_S = 38,	// GF1403-111
			F_GF1900_151_S = 39,	// GF1900-151
			F_SF6302_131_S = 40,	// SF6302-131
			F_SF6402_131_S = 41,	// SF6402-131
			F_SF6700_151_S = 42,	// SF6700-151

			// Customize
			C_DQDKQK_M = 61,		// 到期贷款情况
			C_XZDKMX_D = 62,		// 新增贷款明细表
			C_JQDKMX_D = 63,		// 结清贷款明细表
		}
	}
}

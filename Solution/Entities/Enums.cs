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
			X_WJFL = 1,	// 风险贷款情况表（五级分类）
			X_FXDKTB = 2,			// 风险贷款通报
			X_BLDKJCXB = 3,			// 榆林地区不良贷款监测旬报
			X_ZXQYZJXQ = 4,			// 中小企业资金需求及银行业支持情况表
			X_CSHSX = 5,			// 城商行授信情况统计表
			X_FXDKBH = 6,			// 风险贷款变化情况表
			X_SZHZ = 7,				// 榆林分行三张表汇总表
			X_DKZLFL = 8,			// 贷款质量分类情况汇总表

			// Finacial
			F_HYB = 20,		   // 风险贷款情况表-行业版

			// Finacial - Month
			FM_GF0102_081 = 21, // GF0102-081
			FM_GF0107_141 = 22, // GF0107-141
			FM_SF6301_141 = 23, // SF6301-141
			FM_SF6401_141 = 24, // SF6401-141

			// Finacial - Season
			FS_GF1101_121 = 31, // GF1101-121
			FS_GF1301_081 = 32, // GF1301-081
			FS_GF1302_081 = 33, // GF1302-081
			FS_GF1303_081 = 34, // GF1303-081
			FS_GF1304_081 = 35, // GF1304-081
			FS_GF1403_111 = 36, // GF1403-111
			FS_SF6302_131 = 37, // SF6302-131
			FS_SF6402_131 = 38, // SF6402-131
			FS_GF1103_121 = 39, // GF1103-121
			FS_GF1200_101 = 40, // GF1200-101

			// Customize
			C_XDSJXQ = 61, // 信贷数据需求
			C_JQDKMX = 62, // 结清贷款明细表
			C_XZDKMX = 63, // 新增贷款明细表
			C_FXDKBH = 64, // 风险贷款变化情况表
		}

		public enum ImportState
		{
			Initial = 0,
			AllCopied = 1,
			Imported = 2
		}
	}
}

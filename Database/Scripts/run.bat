@echo off
choice /M "Run db scripts?"
IF ERRORLEVEL 2 GOTO END

echo Creating and initializing tables...
sqlcmd -S .\SQL2012 -d YuLin -i Tables.sql
sqlcmd -S .\SQL2012 -d YuLin -i InitData.sql
echo Done

echo Creating stored functions...
cd SF
sqlcmd -S .\SQL2012 -d YuLin -i sfGetDangerLevel.sql
sqlcmd -S .\SQL2012 -d YuLin -i sfGetImportIdWJFL.sql
sqlcmd -S .\SQL2012 -d YuLin -i sfGetImportStatus.sql
sqlcmd -S .\SQL2012 -d YuLin -i sfGetLoanBalance.sql
sqlcmd -S .\SQL2012 -d YuLin -i sfGetOrgId.sql
echo Done

echo Creating stored procedures...
cd ..\SP
sqlcmd -S .\SQL2012 -d YuLin -i spLoanRiskDaily.sql
sqlcmd -S .\SQL2012 -d YuLin -i spReportLoanRiskPerMonth.sql
sqlcmd -S .\SQL2012 -d YuLin -i spC_DQDKQK_M.sql
sqlcmd -S .\SQL2012 -d YuLin -i spC_JQDKMX_D.sql
sqlcmd -S .\SQL2012 -d YuLin -i spC_XZDKMX_D.sql
sqlcmd -S .\SQL2012 -d YuLin -i spGF0102_081.sql
sqlcmd -S .\SQL2012 -d YuLin -i spGF0107_141.sql
sqlcmd -S .\SQL2012 -d YuLin -i spGF1101_121.sql
sqlcmd -S .\SQL2012 -d YuLin -i spGF1103_121.sql
sqlcmd -S .\SQL2012 -d YuLin -i spGF1301_081.sql
sqlcmd -S .\SQL2012 -d YuLin -i spGF1403_111.sql
sqlcmd -S .\SQL2012 -d YuLin -i spGF1900_151.sql
sqlcmd -S .\SQL2012 -d YuLin -i spSF6301_141.sql
sqlcmd -S .\SQL2012 -d YuLin -i spSF6301_141_Count.sql
sqlcmd -S .\SQL2012 -d YuLin -i spSF6302_131.sql
sqlcmd -S .\SQL2012 -d YuLin -i spSF6401_141.sql
sqlcmd -S .\SQL2012 -d YuLin -i spSF6401_141_Count.sql
sqlcmd -S .\SQL2012 -d YuLin -i spSF6402_131.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_BLDKJC_X_1.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_BLDKJC_X_2.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_BLDKJC_X_3_Single.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_BLDKJC_X_3.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_BLDKJC_X_4.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_CSHSX_M_1_Single.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_CSHSX_M_1.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_CSHSX_M_2.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_CSHSX_M_3.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_CSHSX_M_4.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_DKZLFL_M.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_FXDKBH_D.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_FXDKTB_D.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_WJFL_M.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_WJFL_M_vs.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_ZXQYZJXQ_S.sql
echo Done

pause
:END
@echo off
choice /M "Run db scripts?"
echo.
IF ERRORLEVEL 2 GOTO END

echo Initializing tables...
sqlcmd -S .\SQL2012 -d YuLin -i UpdateInitData.sql
echo Done
echo.

echo Updating stored procedures...
sqlcmd -S .\SQL2012 -d YuLin -i spX_FXDKTB_D.sql
sqlcmd -S .\SQL2012 -d YuLin -i spC_JQDKMX_D.sql
sqlcmd -S .\SQL2012 -d YuLin -i spC_XZDKMX_D.sql
sqlcmd -S .\SQL2012 -d YuLin -i spX_WJFLPRD_D.sql
echo Done
echo.

pause
:END
exit
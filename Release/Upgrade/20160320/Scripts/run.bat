@echo off
choice /M "Run db scripts?"
echo.
IF ERRORLEVEL 2 GOTO END

echo Initializing tables...
sqlcmd -S .\SQL2012 -d YuLin -i Init.sql
echo Done
echo.

echo Updating stored procedures and functions ...
sqlcmd -S .\SQL2012 -d YuLin -i sfGetMonthsInFuture.sql
sqlcmd -S .\SQL2012 -d YuLin -i spC_DQDKQK_M.sql
echo Done
echo.

pause
:END
exit
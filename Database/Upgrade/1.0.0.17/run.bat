@echo off
choice /M "Run db scripts?"
echo.
IF ERRORLEVEL 2 GOTO END

echo Initializing tables...
sqlcmd -S .\SQL2012 -d YuLin -i Init.sql
echo Done
echo.

echo Updating stored procedures...
sqlcmd -S .\SQL2012 -d YuLin -i spC_DQDKQK_D.sql
echo Done
echo.

pause
:END
exit
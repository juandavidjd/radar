@echo off
REM =============== RadarPremios :: cargar_db.bat =================
call "%~dp0env.bat" >nul

echo [INFO] Ejecutando: "%~f0"
echo ===============================================
echo Cargar DB desde CSVs limpios
echo   PY     : "%PY%"
echo   DB     : "%RP_DB%"
echo   DIR    : "%RP_LIMPIO%"
echo   SCRIPT : "%RP_SCRIPTS%\cargar_db.py"
echo ===============================================

%PY% "%RP_SCRIPTS%\cargar_db.py" --db "%RP_DB%" --dir "%RP_LIMPIO%"
exit /b %ERRORLEVEL%

@echo off
rem ================================================================
rem  RadarPremios - check_db.bat
rem  Ejecuta chequeos de calidad sobre la base SQLite
rem ================================================================
setlocal

rem 1) Cargar entorno
call "%~dp0env.bat" || exit /b 1

rem 2) Validaciones básicas
if not exist "%RP_SCRIPTS%\check_db.py" (
  echo [ERROR] No existe "%RP_SCRIPTS%\check_db.py"
  exit /b 2
)

if not exist "%RP_DB%" (
  echo [ERROR] No existe la base de datos "%RP_DB%"
  exit /b 3
)

if not exist "%RP_REPORTS%" (
  mkdir "%RP_REPORTS%" 1>nul 2>nul
)

rem 3) Header informativo
echo ===============================================
echo Chequeo de Base de Datos (check_db.py)
echo   PY     : %PY%
echo   DB     : "%RP_DB%"
echo   OUTDIR : "%RP_REPORTS%"
echo   SCRIPT : "%RP_SCRIPTS%\check_db.py"
echo ===============================================

rem 4) Ejecutar chequeos
%PY% "%RP_SCRIPTS%\check_db.py" ^
  --db "%RP_DB%" ^
  --out "%RP_REPORTS%"

set RC=%ERRORLEVEL%
if not "%RC%"=="0" (
  echo [ERROR] check_db.py RC=%RC%
  exit /b %RC%
)

rem 5) Éxito
echo [OK] Chequeos completados correctamente.
exit /b 0

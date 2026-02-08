@echo off
rem ================================================================
rem  RadarPremios - apply_fix_inconsistencias.bat
rem  Ejecuta saneamiento automatizado con autofix_db.py
rem ================================================================
setlocal

rem 1) Cargar entorno
call "%~dp0env.bat" || exit /b 1

rem 2) Validaciones
set "PYF=%RP_SCRIPTS%\autofix_db.py"

echo ===============================================
echo Aplicando saneamiento de inconsistencias
echo   DB : "%RP_DB%"
echo   PY : %PY%
echo   PYF: "%PYF%"
echo ===============================================

if not exist "%PYF%" (
  echo [ERROR] No se encuentra "%PYF%".
  echo         Asegurate de tener "autofix_db.py" en %RP_SCRIPTS%
  exit /b 2
)

if not exist "%RP_DB%" (
  echo [ERROR] No existe la base de datos "%RP_DB%"
  exit /b 3
)

rem 3) Ejecutar Python
%PY% "%PYF%" --db "%RP_DB%"
set RC=%ERRORLEVEL%
if not "%RC%"=="0" (
  echo [ERROR] Saneamiento falló. RC=%RC%
  exit /b %RC%
)

echo [OK] Saneamiento completado
exit /b 0

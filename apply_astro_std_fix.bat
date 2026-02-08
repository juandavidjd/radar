@echo off
setlocal EnableExtensions

set "RP_ROOT=%~dp0.."
set "RP_SCRIPTS=%RP_ROOT%\scripts"
set "DB=%RP_ROOT%\radar_premios.db"
set "PY=python -X utf8"
set "SQL=%RP_SCRIPTS%\astro_std_fix.sql"
set "HELPER=%RP_SCRIPTS%\apply_sql_safe.py"

echo ===============================================
echo Aplicando ASTRO_LUNA_STD FIX (modo seguro)
echo   DB  : "%DB%"
echo   SQL : "%SQL%"
echo   PY  : %PY%
echo   HELPER: "%HELPER%"
echo ===============================================

%PY% "%HELPER%" --db "%DB%" --sql "%SQL%"
if errorlevel 1 (
  echo [ERROR] Fallo aplicando ASTRO_LUNA_STD FIX
  exit /b 1
)

REM (Opcional) reconstituir all_std por si dependía de esta vista
if exist "%RP_SCRIPTS%\apply_extend_all_std.bat" (
  call "%RP_SCRIPTS%\apply_extend_all_std.bat"
)

echo [OK ] ASTRO_LUNA_STD FIX aplicado.
exit /b 0

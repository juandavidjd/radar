@echo off
setlocal
echo ===============================================
echo Autofix de base de datos (trim + dedup exacto)
echo   DB : "C:\RadarPremios\radar_premios.db"
echo   PY : python
echo ===============================================

set "DB=C:\RadarPremios\radar_premios.db"

python "%~dp0autofix_db.py" --db "%DB%"
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
  echo [ERROR] Python devolvio RC=%RC%
) else (
  echo [OK] Autofix completado
)
exit /b %RC%

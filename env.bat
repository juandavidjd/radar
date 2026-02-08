@echo off
setlocal

rem --- Raíz y carpetas ---
set "RP_ROOT=%~dp0.."
for %%# in ("%RP_ROOT%") do set "RP_ROOT=%%~f#"
set "RP_SCRIPTS=%RP_ROOT%\scripts"
set "RP_LOGS=%RP_ROOT%\logs"
set "RP_DATA_CRUDO=%RP_ROOT%\data\crudo"
set "RP_DATA_LIMPIO=%RP_ROOT%\data\limpio"
set "RP_BACKUPS=%RP_ROOT%\backups"
set "RP_REPORTS=%RP_ROOT%\reports"
set "RP_DB=%RP_ROOT%\radar_premios.db"
set "PY=python -X utf8"

rem --- Crear carpetas si no existen ---
for %%D in ("%RP_LOGS%" "%RP_DATA_CRUDO%" "%RP_DATA_LIMPIO%" "%RP_BACKUPS%" "%RP_REPORTS%") do (
  if not exist "%%~D" mkdir "%%~D"
)

endlocal & (
  set "RP_ROOT=%RP_ROOT%"
  set "RP_SCRIPTS=%RP_SCRIPTS%"
  set "RP_LOGS=%RP_LOGS%"
  set "RP_DATA_CRUDO=%RP_DATA_CRUDO%"
  set "RP_DATA_LIMPIO=%RP_DATA_LIMPIO%"
  set "RP_BACKUPS=%RP_BACKUPS%"
  set "RP_REPORTS=%RP_REPORTS%"
  set "RP_DB=%RP_DB%"
  set "PY=%PY%"
)

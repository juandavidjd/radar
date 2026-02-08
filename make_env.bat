@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ========= Config por defecto =========
if not defined RP_ROOT set "RP_ROOT=C:\RadarPremios"
set "RP_SCRIPTS=%RP_ROOT%\scripts"
set "RP_DATA=%RP_ROOT%\data"
set "RP_DB=%RP_ROOT%\radar_premios.db"
set "RP_LOGS=%RP_ROOT%\logs"
set "RP_REPORTS=%RP_ROOT%\reports"

rem ========= Python =========
if not defined PY (
  where python >nul 2>&1
  if not errorlevel 1 (
    set "PY=python -X utf8"
  ) else (
    rem fallback al launcher de Python
    set "PY=py -3 -X utf8"
  )
)

rem ========= Directorios =========
for %%D in ("%RP_ROOT%" "%RP_SCRIPTS%" "%RP_DATA%" "%RP_LOGS%" "%RP_REPORTS%") do (
  if not exist "%%~D" mkdir "%%~D" >nul 2>&1
)

rem ========= Exportar al caller =========
endlocal & (
  set "RP_ROOT=%RP_ROOT%"
  set "RP_SCRIPTS=%RP_SCRIPTS%"
  set "RP_DATA=%RP_DATA%"
  set "RP_DB=%RP_DB%"
  set "RP_LOGS=%RP_LOGS%"
  set "RP_REPORTS=%RP_REPORTS%"
  set "PY=%PY%"
)
exit /b 0

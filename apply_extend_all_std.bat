@echo off
setlocal
if not defined PY set "PY=python -X utf8"
if not defined RP_SCRIPTS set "RP_SCRIPTS=%~dp0"
if not defined RP_DB set "RP_DB=%~dp0..\radar_premios.db"
set "SQL=%RP_SCRIPTS%\sql\extend_all_std.sql"
if not exist "%SQL%" (
  echo [WARN] EXT ALL_STD: no hay "%SQL%". Omitido.
  exit /b 0
)
%PY% "%RP_SCRIPTS%\apply_sql_safe.py" --db "%RP_DB%" --file "%SQL%"
exit /b %ERRORLEVEL%

@echo off
setlocal

set "RP_ROOT=C:\RadarPremios"
set "RP_DB=%RP_ROOT%\radar_premios.db"
set "RP_SQL=%RP_ROOT%\scripts\fix_radar_premios.sql"
set "PY=python -X utf8"
set "HELPER=%RP_ROOT%\scripts\apply_sql_safe.py"

echo(===============================================
echo(Aplicando SQL a SQLite (modo seguro)
echo(  DB  : "%RP_DB%"
echo(  SQL : "%RP_SQL%"
echo(  PY  : %PY%
echo(  HELPER: "%HELPER%"
echo(===============================================

%PY% "%HELPER%" --db "%RP_DB%" --sql "%RP_SQL%"
exit /b %ERRORLEVEL%

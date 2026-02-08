@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ===================== PATHS / ENV ==========================
set "RP_ROOT=%~dp0"
if "%RP_ROOT:~-1%"=="\" set "RP_ROOT=%RP_ROOT:~0,-1%"
set "RP_SCRIPTS=%RP_ROOT%\scripts"
set "RP_DB=%RP_ROOT%\radar_premios.db"
set "RP_LOGS=%RP_ROOT%\logs"
set "RP_DATA_CRUDO=%RP_ROOT%\data\crudo"
set "RP_DATA_LIMPIO=%RP_ROOT%\data\limpio"
set "RP_BACKUPS=%RP_ROOT%\backups"
set "RP_REPORTS=%RP_ROOT%\reports"
set "RP_SQL_APPLY=%RP_SCRIPTS%\sql\apply"
set "PY=py -3 -X utf8 -B -I"

if not exist "%RP_LOGS%" md "%RP_LOGS%" >nul 2>&1
if not exist "%RP_DATA_CRUDO%" md "%RP_DATA_CRUDO%" >nul 2>&1
if not exist "%RP_DATA_LIMPIO%" md "%RP_DATA_LIMPIO%" >nul 2>&1
if not exist "%RP_BACKUPS%" md "%RP_BACKUPS%" >nul 2>&1
if not exist "%RP_REPORTS%" md "%RP_REPORTS%" >nul 2>&1

for /f "tokens=1-3 delims=/.- " %%a in ('date /t') do set _d=%%a%%b%%c
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set _t=%%a%%b
set "RP_LOGFILE=%RP_LOGS%\run_%_d%_%_t%.log"

call :banner

rem ===================== SCRAPERS ==============================
call :log "[RUN] Scrapers Baloto/Revancha y 4D"
call :log "  - Baloto resultados"
call :run_py "%RP_SCRIPTS%\scraper_baloto_resultados.py" --out "%RP_DATA_CRUDO%\baloto_resultados.csv" || goto :fail

call :log "  - Baloto premios"
call :run_py "%RP_SCRIPTS%\scraper_baloto_premios.py" --out "%RP_DATA_CRUDO%\baloto_premios.csv" || goto :fail

call :log "  - Revancha resultados"
call :run_py "%RP_SCRIPTS%\scraper_revancha_resultados.py" --out "%RP_DATA_CRUDO%\revancha_resultados.csv" || goto :fail

call :log "  - Revancha premios"
call :run_py "%RP_SCRIPTS%\scraper_revancha_premios.py" --out "%RP_DATA_CRUDO%\revancha_premios.csv" || goto :fail

call :log "  - 4D regionales"
call :run_py "%RP_SCRIPTS%\scraper_loterias.py" --outdir "%RP_DATA_CRUDO%" || goto :fail

rem ===================== SANEADO / VALIDACION ==================
call :log "[RUN] Sanitize CSVs"
call :run_py "%RP_SCRIPTS%\sanitize_csvs.py" --src "%RP_DATA_CRUDO%" --dst "%RP_DATA_LIMPIO%" || goto :fail

call :log "[RUN] Validate CSVs"
call :run_py "%RP_SCRIPTS%\validate_csvs.py" --src "%RP_DATA_LIMPIO%" || goto :fail

rem ===================== CARGA DB ==============================
call :log "[RUN] Cargar DB"
call :run_py "%RP_SCRIPTS%\load_to_db.py" --db "%RP_DB%" --src "%RP_DATA_LIMPIO%" || goto :fail

rem ===================== APPLY SQL ============================
for %%F in ("%RP_SQL_APPLY%\*.sql") do (
  call :log "[RUN] SQL: %%~nxF"
  call :run_py "%RP_SCRIPTS%\sql_exec.py" --db "%RP_DB%" --file "%%~fF" || goto :fail
)

rem ===================== REPORTES =============================
call :log "[RUN] Reportes"
call :run_py "%RP_SCRIPTS%\four_d_light.py" --db "%RP_DB%" --out "%RP_REPORTS%\four_d_light.html" || goto :fail
call :run_py "%RP_SCRIPTS%\four_d_advanced.py" --db "%RP_DB%" --out "%RP_REPORTS%\four_d_advanced.html" || goto :fail

rem ===================== BACKUP ===============================
call :log "[RUN] Backup DB"
copy /y "%RP_DB%" "%RP_BACKUPS%\radar_premios_%_d%_%_t%.db" >nul
if errorlevel 1 goto :fail

echo.
echo ================================================================
echo  PIPELINE COMPLETADO  (log: %RP_LOGFILE%)
echo ================================================================
exit /b 0

:fail
echo.
echo [ERROR] Fallo en el paso anterior. Revisa el log:
echo         %RP_LOGFILE%
exit /b 1

:banner
echo ================================================================
echo [ENV] RP_ROOT       = %RP_ROOT%
echo [ENV] RP_SCRIPTS    = %RP_SCRIPTS%
echo [ENV] RP_DB         = %RP_DB%
echo [ENV] Logs          = %RP_LOGS%
echo [ENV] Data_crudo    = %RP_DATA_CRUDO%
echo [ENV] Data_limpio   = %RP_DATA_LIMPIO%
echo [ENV] Backups       = %RP_BACKUPS%
echo [ENV] Reports       = %RP_REPORTS%
echo [ENV] SQL apply     = %RP_SQL_APPLY%
echo [ENV] Python        = %PY%
echo [ENV] Logfile       = %RP_LOGFILE%
echo ================================================================
echo [LOG] Registrando en: %RP_LOGFILE%> "%RP_LOGFILE%"
echo [LOG] Registrando en: %RP_LOGFILE%>> "%RP_LOGFILE%"
exit /b 0

rem =============== helpers ==========================
:log
echo %*
>> "%RP_LOGFILE%" echo %*
exit /b 0

:run_py
rem Ejecuta Python sin entrada (stdin->NUL), con log y retorno de rc.
set "CMD=%PY% %~1 %~2 %~3 %~4 %~5"
call :log "[CMD] %CMD%"
rem Redirigimos stdout/stderr al log; consola verá solo OK/FAIL
cmd /c "%CMD% <NUL >> "%RP_LOGFILE%" 2>&1"
set "rc=%ERRORLEVEL%"
if not "%rc%"=="0" (
  call :log "[FAIL] rc=%rc% en %~nx1"
  exit /b %rc%
)
call :log "[OK] %~nx1"
exit /b 0

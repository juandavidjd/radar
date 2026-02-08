@echo off
setlocal ENABLEDELAYEDEXPANSION
title RadarPremios :: Master (debug tee)

call "%~dp0env.bat" || (echo [FATAL] No se pudo cargar env.bat & exit /b 1)

for /f %%I in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmm')"') do set "TS=%%I"
set "LOG=%RP_LOGS%\master_%TS%_debug.log.txt"

> "%LOG%" (
  echo =================================================
  echo === Master pipeline iniciado %DATE% %TIME% ===
  echo Base: %RP_DB%
  echo Log : %LOG%
  echo =================================================
)

REM Función inline: ejecuta y tee-a salida a consola y LOG
set "PS=PowerShell -NoProfile -Command"
set "TEE=%PS% \"$input | Tee-Object -FilePath '%LOG%' -Append\""

call :run "Scraper LOTERIAS"                 %PY% "%RP_SCRIPTS%\scraper_loterias.py"                            || goto :fail
call :run "Scraper ASTRO LUNA"               %PY% "%RP_SCRIPTS%\scraper_astroluna.py"                           || goto :fail
call :run "Scraper BALOTO premios"           %PY% "%RP_SCRIPTS%\scraper_baloto_premios.py"                      || goto :fail
call :run "Scraper BALOTO resultados"        %PY% "%RP_SCRIPTS%\scraper_baloto_resultados.py"                   || goto :fail
call :run "Scraper REVANCHA premios"         %PY% "%RP_SCRIPTS%\scraper_revancha_premios.py"                    || goto :fail
call :run "Scraper REVANCHA resultados"      %PY% "%RP_SCRIPTS%\scraper_revancha_resultados.py"                 || goto :fail

call :run "LIMPIAR CSVs crudo a limpio"      %PY% "%RP_SCRIPTS%\limpiar_csvs.py" --src "%RP_CRUDO%" --out "%RP_LIMPIO%"  || goto :fail
call :run "CARGAR DB"                         %PY% "%RP_SCRIPTS%\cargar_db.py" --db "%RP_DB%" --dir "%RP_LIMPIO%"        || goto :fail

call :run "GENERAR MATRIZ ASTRO LUNA"         %PY% "%RP_SCRIPTS%\generar_matriz_astro_luna.py"                   || goto :fail
call :run "CARGAR DB post-matriz"             %PY% "%RP_SCRIPTS%\cargar_db.py" --db "%RP_DB%" --dir "%RP_LIMPIO%"        || goto :fail

call :run "FIX SCHEMA"                        %PY% "%RP_SCRIPTS%\fix_schema.py" --db "%RP_DB%"                   || goto :fail
call :run "APLICAR STD VIEWS"                 cmd /c "%RP_SCRIPTS%\apply_std_views.bat"                          || goto :fail

call :run "MANTENIMIENTO DB"                  %PY% "%RP_ROOT%\db_maintenance.py" --db "%RP_DB%"                  || goto :fail
call :run "POST-FIX backup y check"           cmd /c "%RP_SCRIPTS%\post_fix.bat"                                 || goto :fail

set "EXP_TOP=%RP_ROOT%\candidatos_scored_%TS%.csv"
set "EXP_ALL=%RP_ROOT%\candidatos_all_%TS%.csv"
set "REP_HTML=%RP_ROOT%\candidatos_scored_%TS%.html"
call :run "SCORING CANDIDATOS"                %PY% "%RP_ROOT%\score_candidates.py" --db "%RP_DB%" --gen 100 --seed 12345 --top 15 --shortlist 5 --export "%EXP_TOP%" --export-all "%EXP_ALL%" --report "%REP_HTML%" || goto :fail

call :run "EVALUAR RUN RECIENTE"              %PY% "%RP_SCRIPTS%\eval_last_run.py" --db "%RP_DB%"                 || goto :fail

echo === Master pipeline FINALIZADO %DATE% %TIME% === | %TEE%
echo Log en: %LOG%
exit /b 0

:run
setlocal
set "STEP=%~1"
shift
set "CMDLINE=%*"
echo [STEP] %STEP% | %TEE%
echo [CMD ] %CMDLINE% | %TEE%
%CMDLINE% 2>&1 | %TEE%
if errorlevel 1 (echo [ERROR] %STEP% RC=1 | %TEE% & endlocal & exit /b 1)
echo [OK  ] %STEP% RC=0 | %TEE%
endlocal & exit /b 0

:fail
echo === Master pipeline ABORTADO %DATE% %TIME% === | %TEE%
echo Log en: %LOG%
exit /b 1

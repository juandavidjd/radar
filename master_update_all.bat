@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================
rem =           CONFIGURACIÓN BÁSICA           =
rem ============================================
rem Ruta base (carpeta raíz del proyecto)
set "ROOT=C:\RadarPremios"
rem Carpeta de scripts
set "SCRIPTS=%ROOT%\scripts"
rem Ruta de la base de datos
set "DB=%ROOT%\radar_premios.db"
rem Ejecutable de Python (cámbialo si usas venv)
set "PYTHON=python"

rem ============================================
rem =           LOG Y TIMESTAMPS               =
rem ============================================
set "LOGDIR=%ROOT%\logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmmss"') do set "TS=%%~I"
set "LOGFILE=%LOGDIR%\master_%TS%.log.txt"

rem Exportamos LOGFILE al entorno para que los scripts lo puedan leer si quieren
setx LOGFILE "%LOGFILE%" >nul 2>&1
set "LOGFILE=%LOGFILE%"

rem ============================================
rem =           FORZAR UTF-8 LIMPIO            =
rem ============================================
rem Guardar codepage actual sin romper con “de”
for /f "tokens=2 delims=:" %%C in ('chcp') do set "_OLDCP=%%C"
set "_OLDCP=%_OLDCP: =%"
chcp 65001 >nul

rem ============================================
rem =           CABECERA DE EJECUCIÓN          =
rem ============================================
echo === Master pipeline iniciado ===
echo Base: %DB%
echo Log:  %LOGFILE%
echo === Master pipeline iniciado ===>> "%LOGFILE%"
echo Base: %DB%>> "%LOGFILE%"
echo Log:  %LOGFILE%>> "%LOGFILE%"
echo.>> "%LOGFILE%"

rem ============================================
rem =           HELPERS / FUNCIONES            =
rem ============================================
rem RUNSTEP "Nombre del paso" "comando a ejecutar"
rem Muestra [STEP]/[CMD] y usa PowerShell + Tee-Object para ver en consola y log.
:RUNSTEP
set "_STEPNAME=%~1"
set "_CMDTOEXEC=%~2"
echo. | tee >nul
echo [STEP] %_STEPNAME%
echo [STEP] %_STEPNAME%>> "%LOGFILE%"
echo [CMD ] %_CMDTOEXEC%
echo [CMD ] %_CMDTOEXEC%>> "%LOGFILE%"

rem Exportar CMDSTR y LOGFILE al proceso de PowerShell
set "CMDSTR=%_CMDTOEXEC%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "& { $ErrorActionPreference='Continue'; ^
       $cmd = [Environment]::GetEnvironmentVariable('CMDSTR','Process'); ^
       $log = [Environment]::GetEnvironmentVariable('LOGFILE','Process'); ^
       & cmd.exe /c $cmd 2>&1 ^| Tee-Object -FilePath $log -Append; ^
       exit $LASTEXITCODE }"
set "RC=%ERRORLEVEL%"

if "%RC%"=="0" (
  echo [OK  ] %_STEPNAME%  RC=0
  echo [OK  ] %_STEPNAME%  RC=0>> "%LOGFILE%"
) else (
  echo [ERROR] %_STEPNAME%  RC=%RC%  -- ver log
  echo [ERROR] %_STEPNAME%  RC=%RC%>> "%LOGFILE%"
)
exit /b %RC%

rem ============================================
rem =              PIPELINE                    =
rem ============================================

rem 1) Scraper LOTERÍAS
call :RUNSTEP "Scraper LOTERÍAS" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\scraper_loterias.py\""
rem Continuamos siempre
rem ------------------------------------------------------------

rem 2) Scraper ASTRO LUNA
call :RUNSTEP "Scraper ASTRO LUNA" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\scraper_astroluna.py\""
rem ------------------------------------------------------------

rem 3) Scraper BALOTO premios
call :RUNSTEP "Scraper BALOTO premios" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\scraper_baloto_premios.py\""
rem ------------------------------------------------------------

rem 4) Scraper BALOTO resultados
call :RUNSTEP "Scraper BALOTO resultados" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\scraper_baloto_resultados.py\""
rem ------------------------------------------------------------

rem 5) Scraper REVANCHA premios
call :RUNSTEP "Scraper REVANCHA premios" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\scraper_revancha_premios.py\""
rem ------------------------------------------------------------

rem 6) Scraper REVANCHA resultados
call :RUNSTEP "Scraper REVANCHA resultados" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\scraper_revancha_resultados.py\""
rem ------------------------------------------------------------

rem 7) LIMPIAR CSVs
rem NOTA: el script acepta --src y --dst opcionales. Por defecto usa C:\RadarPremios\data\crudos -> \data\limpio
call :RUNSTEP "LIMPIAR CSVs" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\limpiar_csvs.py\""
rem Si no existe origen, el script retorna 0 y registra “Nada que limpiar”
rem ------------------------------------------------------------

rem 8) CARGAR DB
call :RUNSTEP "CARGAR DB" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\cargar_db.py\""
rem Si falla, aún así seguimos para no dejar a medias (ajusta si quieres “fail-fast”)
rem ------------------------------------------------------------

rem 9) GENERAR MATRIZ ASTRO LUNA
call :RUNSTEP "GENERAR MATRIZ ASTRO LUNA" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\generar_matriz_astro_luna.py\""
rem ------------------------------------------------------------

rem 10) CARGAR DB post-matriz
call :RUNSTEP "CARGAR DB post-matriz" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\cargar_db.py\""
rem ------------------------------------------------------------

rem 11) ACTUALIZAR_BASE_ASTROLUNA
call :RUNSTEP "ACTUALIZAR_BASE_ASTROLUNA" ^
"%PYTHON% -X utf8 \"%ROOT%\actualizar_base_astroluna.py\" --db \"%DB%\" --todo-join inner"
rem ------------------------------------------------------------

rem 12) MANTENIMIENTO DB
call :RUNSTEP "MANTENIMIENTO DB" ^
"%PYTHON% -X utf8 \"%ROOT%\db_maintenance.py\" --db \"%DB%\" --todo-join inner"
rem ------------------------------------------------------------

rem 13) SCORING CANDIDATOS
rem (los warnings de SyntaxWarning no rompen la ejecución)
call :RUNSTEP "SCORING CANDIDATOS" ^
"%PYTHON% -X utf8 \"%ROOT%\score_candidates.py\" --db \"%DB%\" --gen 100 --seed 12345 --top 15 --shortlist 5 --export \"%ROOT%\candidatos_scored.csv\" --export-all \"%ROOT%\candidatos_all.csv\" --report \"%ROOT%\candidatos_scored.html\" --w-hotcold 0.25 --w-cal 0.20 --w-dp 0.20 --w-exact 0.35 --cap-digitpos 60 --cap-exact 180 --cal-horizon 30"
rem ------------------------------------------------------------

rem 14) EVALUAR RUN RECIENTE
call :RUNSTEP "EVALUAR RUN RECIENTE" ^
"%PYTHON% -X utf8 \"%SCRIPTS%\eval_last_run.py\" --db \"%DB%\""
rem ------------------------------------------------------------

rem ============================================
rem =                 FIN                      =
rem ============================================
echo.>> "%LOGFILE%"
echo === Master pipeline FINALIZADO ===
echo Log en: %LOGFILE%
echo === Master pipeline FINALIZADO ===>> "%LOGFILE%"
echo Log en: %LOGFILE%>> "%LOGFILE%"

rem Restaurar codepage original si existía
if defined _OLDCP chcp %_OLDCP% >nul

endlocal
exit /b 0

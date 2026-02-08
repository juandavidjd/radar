@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Usage: collect_scoring_reports.bat [TIMESTAMP]
set "TS=%~1"
if "%TS%"=="" (
  set "TS=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%_%TIME: =0%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
  set "TS=%TS::=%"
)

REM Derivar RP_ROOT desde la ruta de este script
set "THIS_DIR=%~dp0"
for %%A in ("%THIS_DIR%\..") do set "RP_ROOT=%%~fA"

set "SRC1=%RP_ROOT%"
set "SRC2=%RP_ROOT%\reports"
set "OUTDIR=%RP_ROOT%\reports\scoring_%TS%"

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

echo ===============================================
echo Collector de Scoring Reports
echo  ROOT  : "%RP_ROOT%"
echo  OUT   : "%OUTDIR%"
echo  TS    : %TS%
echo ===============================================

set "COUNT=0"

REM Buscar HTMLs en raíz y en subcarpeta reports (por si alguno escribe directo allí)
for %%S in ("%SRC1%" "%SRC2%") do (
  if exist "%%~S" (
    for /r "%%~S" %%F in (*.html) do (
      REM Filtrar solo los de scoring/candidatos
      echo %%~nxF | findstr /I /R "candidatos_scored_.*\.html" >nul
      if not errorlevel 1 (
         copy /Y "%%~fF" "%OUTDIR%\%%~nxF" >nul
         if not errorlevel 1 (
            set /a COUNT+=1
         )
      )
    )
  )
)

echo [OK ] Copiados !COUNT! HTML de scoring a "%OUTDIR%"
exit /b 0

@echo off
setlocal EnableExtensions

set "RP_ROOT=C:\RadarPremios"
set "REPORTS=%RP_ROOT%\reports"
if not exist "%REPORTS%" mkdir "%REPORTS%" >nul 2>nul

for /f %%I in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"') do set "TS=%%I"
set "DST=%REPORTS%\scoring_%TS%"
mkdir "%DST%" >nul 2>nul

echo ===============================================
echo Collector de HTML de scoring
echo   Origen: %RP_ROOT%
echo   Destino: %DST%
echo ===============================================

for %%F in ("%RP_ROOT%\candidatos_scored_*.html") do (
  if exist "%%~fF" (
    copy /y "%%~fF" "%DST%\" >nul
    echo [OK ] Copiado: %%~nxF
  )
)

echo [DONE] Collector terminado.
exit /b 0

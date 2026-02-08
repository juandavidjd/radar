@echo off
setlocal EnableExtensions

REM Recibe %1 = TS (yyyyMMdd_HHmmss)
set "TS=%~1"
if "%TS%"=="" (
  for /f "usebackq delims=" %%i in (`powershell -NoP -C "(Get-Date).ToString('yyyyMMdd_HHmmss')"`) do set "TS=%%i"
)

set "RP_ROOT=%~dp0.."
if "%RP_ROOT:~-1%"=="\" set "RP_ROOT=%RP_ROOT:~0,-1%"
set "DEST=%RP_ROOT%\reports\scoring_%TS%"

mkdir "%DEST%" >nul 2>&1

REM Copia todos los HTML de scoring generados en raíz a la carpeta del lote
for %%F in ("%RP_ROOT%\candidatos_scored_*.html") do (
  copy /y "%%~fF" "%DEST%" >nul
)

echo [OK] Collector: HTML de scoring copiados a "%DEST%"
exit /b 0

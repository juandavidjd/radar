@echo off
setlocal
REM Uso: check_history.bat <game> <min>
REM Asegura que %PY% y %RP_DB% se pasen correctamente (incluye espacios como "-X utf8")
if "%~1"=="" (
  echo Uso: check_history.bat ^<game^> ^<min^>
  exit /b 2
)
if "%~2"=="" (
  echo Uso: check_history.bat ^<game^> ^<min^>
  exit /b 2
)

"%PY%" "%RP_SCRIPTS%\check_history.py" --db "%RP_DB%" --game "%~1" --min "%~2"
exit /b %ERRORLEVEL%

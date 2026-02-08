@echo off
rem ================================================================
rem  RadarPremios - backup_db.bat
rem  Crea respaldo con timestamp y aplica retención
rem ================================================================
setlocal

rem 1) Cargar entorno
call "%~dp0env.bat" || exit /b 1

rem 2) Defaults por si no están en env.bat
if not defined RP_BACKUPS set "RP_BACKUPS=%RP_ROOT%\backups"
if not defined RP_BACKUPS_KEEP set "RP_BACKUPS_KEEP=10"

rem 3) Validaciones
if not exist "%RP_DB%" (
  echo [ERROR] No existe la base de datos "%RP_DB%"
  exit /b 2
)
if not exist "%RP_BACKUPS%" (
  mkdir "%RP_BACKUPS%" 1>nul 2>nul
)

rem 4) Timestamp estable
for /f %%I in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"') do set "TS=%%I"

set "DEST=%RP_BACKUPS%\radar_premios_%TS%.db"

echo ===============================================
echo Respaldo de base de datos RadarPremios
echo   DB     : "%RP_DB%"
echo   OUT    : "%RP_BACKUPS%"
echo   OUTPUT : "%DEST%"
echo   KEEP   : %RP_BACKUPS_KEEP%
echo ===============================================

rem 5) Copia
copy /y "%RP_DB%" "%DEST%" >nul
if errorlevel 1 (
  echo [ERROR] Fallo copiando a "%DEST%"
  exit /b 3
)
echo [OK ] Backup creado: "%DEST%"

rem 6) SHA256
set "HASH="
for /f "usebackq delims=" %%H in (`certutil -hashfile "%DEST%" SHA256 ^| findstr /R "^[0-9A-F]"`) do (
  set "HASH=%%H"
  goto :hashdone
)
:hashdone
if defined HASH (
  echo [OK ] SHA256: %HASH%
) else (
  echo [WARN] No se pudo obtener SHA256 (certutil no disponible?)
)

rem 7) Política de retención (mantener N más recientes)
set /a _idx=0
for /f "usebackq delims=" %%F in (`dir /b /o-d "%RP_BACKUPS%\radar_premios_*.db"`) do (
  set /a _idx+=1
  if %_idx% gtr %RP_BACKUPS_KEEP% (
    del /q "%RP_BACKUPS%\%%F" 2>nul
  )
)
echo [DONE] Respaldo completo.
exit /b 0

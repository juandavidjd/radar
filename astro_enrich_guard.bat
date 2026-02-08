@echo off
setlocal EnableExtensions
if not defined PY set "PY=python -X utf8"
if not defined RP_ROOT set "RP_ROOT=%~dp0.."
if not defined RP_SCRIPTS set "RP_SCRIPTS=%~dp0"

for /f "delims=" %%f in ('dir /b /a:-d "%RP_ROOT%\astroluna_top_*.csv" 2^>nul') do set "HAS_ASTRO=1"
if not defined HAS_ASTRO (
  echo [WARN] AstroLuna: no hay archivos "astroluna_top_*.csv". Omitido.
  exit /b 0
)

if exist "%RP_SCRIPTS%\astro_enrich.py" (
  %PY% "%RP_SCRIPTS%\astro_enrich.py" --root "%RP_ROOT%"
  exit /b %ERRORLEVEL%
) else (
  echo [WARN] AstroLuna: falta "%RP_SCRIPTS%\astro_enrich.py". Omitido.
  exit /b 0
)

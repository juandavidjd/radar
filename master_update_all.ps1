<# ======================================================================
  master_update_all.ps1
  Pipeline maestro RadarPremios (PowerShell)
  - UTF-8, logging, control RC por paso
  - Sin dependencias externas (usa Tee-Object)
====================================================================== #>

# ----- Configuración básica -----
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$ErrorActionPreference = 'Continue'

# Rutas base
$ROOT     = 'C:\RadarPremios'
$SCRIPTS  = Join-Path $ROOT 'scripts'
$DATA     = Join-Path $ROOT 'data'
$DB       = Join-Path $ROOT 'radar_premios.db'
$PYTHON   = 'python'  # o ruta completa a tu intérprete

# Carpeta de logs
$LOGDIR = Join-Path $ROOT 'logs'
if (-not (Test-Path $LOGDIR)) { New-Item -ItemType Directory -Force -Path $LOGDIR | Out-Null }

# Nombre de log con timestamp
$ts      = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$LOGFILE = Join-Path $LOGDIR "master_${ts}.log.txt"

# ----- Utilidades -----
function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','OK','ERROR','STEP','HEAD','CMD','WARN')]
        [string]$Level = 'INFO'
    )
    $line =
        if ($Level -eq 'HEAD') { $Message }
        elseif ($Level -eq 'CMD') { "[CMD ] $Message" }
        elseif ($Level -eq 'STEP') { "[STEP] $Message" }
        elseif ($Level -eq 'OK')   { "[OK  ] $Message" }
        elseif ($Level -eq 'ERROR'){ "[ERROR] $Message" }
        elseif ($Level -eq 'WARN') { "[WARN] $Message" }
        else { "[$Level] $Message" }
    Write-Host $line
    $line | Out-File -FilePath $LOGFILE -Append
}

function Show-Header {
    Write-Log -Level HEAD "=== Master pipeline iniciado ==="
    Write-Log -Level INFO "Base:  $DB"
    Write-Log -Level INFO "Log:   $LOGFILE`n"
}

# Construye una cadena amigable y con comillas para loguear el comando exacto
function CmdString {
    param([Parameter(Mandatory)][string]$Exe,
          [Parameter(Mandatory)][string[]]$Args)
    $quoted = $Args | ForEach-Object {
        if ($_ -match '[\s;,:\\/"'']') { '"' + ($_ -replace '"','\"') + '"' } else { $_ }
    }
    return @($Exe + ' ' + ($quoted -join ' ')).Trim()
}

# Ejecuta un paso, duplica salida a consola y log, y devuelve RC
function Run-Step {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$CmdForLog,
        [Parameter(Mandatory)][scriptblock]$Action
    )
    Write-Log -Level STEP $Name
    Write-Log -Level CMD  $CmdForLog

    $global:LASTEXITCODE = 0
    try {
        & $Action 2>&1 | Tee-Object -FilePath $LOGFILE -Append | ForEach-Object { $_ | Out-Host }
    } catch {
        $_.ToString() | Tee-Object -FilePath $LOGFILE -Append | Out-Host
        $global:LASTEXITCODE = 1
    }

    $rc = $global:LASTEXITCODE
    if ($rc -eq 0) { Write-Log -Level OK "$Name  RC=0`n" }
    else           { Write-Log -Level ERROR "$Name  RC=$rc  -- ver log`n" }
    return $rc
}

# ----- Inicio -----
Show-Header

# 1) Scraper LOTERÍAS
$null = Run-Step -Name 'Scraper LOTERÍAS' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'scraper_loterias.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'scraper_loterias.py') }

# 2) Scraper ASTRO LUNA
$null = Run-Step -Name 'Scraper ASTRO LUNA' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'scraper_astroluna.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'scraper_astroluna.py') }

# 3) Scraper BALOTO premios
$null = Run-Step -Name 'Scraper BALOTO premios' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'scraper_baloto_premios.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'scraper_baloto_premios.py') }

# 4) Scraper BALOTO resultados
$null = Run-Step -Name 'Scraper BALOTO resultados' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'scraper_baloto_resultados.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'scraper_baloto_resultados.py') }

# 5) Scraper REVANCHA premios
$null = Run-Step -Name 'Scraper REVANCHA premios' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'scraper_revancha_premios.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'scraper_revancha_premios.py') }

# 6) Scraper REVANCHA resultados
$null = Run-Step -Name 'Scraper REVANCHA resultados' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'scraper_revancha_resultados.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'scraper_revancha_resultados.py') }

# 7) LIMPIAR CSVs (idempotente)
$null = Run-Step -Name 'LIMPIAR CSVs' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'limpiar_csvs.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'limpiar_csvs.py') }

# 8) CARGAR DB
$null = Run-Step -Name 'CARGAR DB' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'cargar_db.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'cargar_db.py') }

# 9) GENERAR MATRIZ ASTRO LUNA
$null = Run-Step -Name 'GENERAR MATRIZ ASTRO LUNA' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'generar_matriz_astro_luna.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'generar_matriz_astro_luna.py') }

# 10) CARGAR DB post-matriz
$null = Run-Step -Name 'CARGAR DB post-matriz' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'cargar_db.py'))) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'cargar_db.py') }

# 11) ACTUALIZAR_BASE_ASTROLUNA
$null = Run-Step -Name 'ACTUALIZAR_BASE_ASTROLUNA' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $ROOT 'actualizar_base_astroluna.py'), '--db', $DB, '--todo-join', 'inner')) `
    -Action { & $PYTHON -X utf8 (Join-Path $ROOT 'actualizar_base_astroluna.py') --db $DB --todo-join inner }

# 12) MANTENIMIENTO DB
$null = Run-Step -Name 'MANTENIMIENTO DB' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $ROOT 'db_maintenance.py'), '--db', $DB, '--todo-join', 'inner')) `
    -Action { & $PYTHON -X utf8 (Join-Path $ROOT 'db_maintenance.py') --db $DB --todo-join inner }

# 13) SCORING CANDIDATOS (suprime SyntaxWarning de Python en log)
$oldWarn = $env:PYTHONWARNINGS
$env:PYTHONWARNINGS = 'ignore::SyntaxWarning'
$null = Run-Step -Name 'SCORING CANDIDATOS' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8',
        (Join-Path $ROOT 'score_candidates.py'),
        '--db', $DB,
        '--gen','100','--seed','12345','--top','15','--shortlist','5',
        '--export', (Join-Path $ROOT 'candidatos_scored.csv'),
        '--export-all', (Join-Path $ROOT 'candidatos_all.csv'),
        '--report', (Join-Path $ROOT 'candidatos_scored.html'),
        '--w-hotcold','0.25','--w-cal','0.20','--w-dp','0.20','--w-exact','0.35',
        '--cap-digitpos','60','--cap-exact','180','--cal-horizon','30'
    )) `
    -Action {
        & $PYTHON -X utf8 (Join-Path $ROOT 'score_candidates.py') `
            --db $DB --gen 100 --seed 12345 --top 15 --shortlist 5 `
            --export (Join-Path $ROOT 'candidatos_scored.csv') `
            --export-all (Join-Path $ROOT 'candidatos_all.csv') `
            --report (Join-Path $ROOT 'candidatos_scored.html') `
            --w-hotcold 0.25 --w-cal 0.20 --w-dp 0.20 --w-exact 0.35 `
            --cap-digitpos 60 --cap-exact 180 --cal-horizon 30
    }
$env:PYTHONWARNINGS = $oldWarn

# 14) EVALUAR RUN RECIENTE (suprime SyntaxWarning)
$oldWarn = $env:PYTHONWARNINGS
$env:PYTHONWARNINGS = 'ignore::SyntaxWarning'
$null = Run-Step -Name 'EVALUAR RUN RECIENTE' `
    -CmdForLog (CmdString $PYTHON @('-X','utf8', (Join-Path $SCRIPTS 'eval_last_run.py'), '--db', $DB)) `
    -Action { & $PYTHON -X utf8 (Join-Path $SCRIPTS 'eval_last_run.py') --db $DB }
$env:PYTHONWARNINGS = $oldWarn

# ----- Final -----
Write-Log -Level HEAD "=== Master pipeline FINALIZADO ==="
Write-Log -Level INFO ("Log en: {0}" -f $LOGFILE)

@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title ProdIA pro - Iniciar todo / Start All
cd /d "%~dp0"

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║   ProdIA pro - Inicio Completo / Full Start              ║
echo ║   Setup + Gradio API + Backend + Frontend                ║
echo ║   (con soporte LoRA / with LoRA support)                 ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

REM ─── Rutas / Paths ──────────────────────────────────────────
set "ACESTEP_DIR=%~dp0ACE-Step-1.5_"
set "UI_DIR=%~dp0ace-step-ui"
set "PRO_UI_DIR=%~dp0ace-step-ui-pro"
set "VENV=%ACESTEP_DIR%\.venv"

REM ─── Verificar Node.js / Check Node.js ──────────────────────
echo [PRE-CHECK] Verificando herramientas / Checking tools...
where node >nul 2>&1
if !errorlevel! neq 0 (
    echo.
    echo  [ERROR] Node.js no encontrado / Node.js not found.
    echo          Instala Node.js 18+ desde / Install from:
    echo          https://nodejs.org/
    echo.
    pause
    exit /b 1
)
echo  ✓ Node.js encontrado / found

REM ─── Detectar Python / Detect Python ────────────────────────
set "PYTHON="
set "BASE_PYTHON="

if exist "%ACESTEP_DIR%\python_embeded\python.exe" (
    set "PYTHON=%ACESTEP_DIR%\python_embeded\python.exe"
    echo  ✓ Python embebido / Embedded Python encontrado / found
    goto :PYTHON_OK
)

if exist "%VENV%\Scripts\python.exe" (
    set "PYTHON=%VENV%\Scripts\python.exe"
    echo  ✓ Virtual environment encontrado / found
    goto :PYTHON_OK
)

python --version >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('where python') do set "BASE_PYTHON=%%i" & goto :GOT_SYS_PYTHON
    :GOT_SYS_PYTHON
    echo  ✓ System Python encontrado / found
    goto :CREATE_VENV
)

py --version >nul 2>&1
if !errorlevel! equ 0 (
    set "BASE_PYTHON=py"
    echo  ✓ Python launcher encontrado / found
    goto :CREATE_VENV
)

echo.
echo  [ERROR] Python no encontrado / not found.
echo          Instala Python 3.10 o 3.11 desde / Install from:
echo          https://www.python.org/downloads/
echo          IMPORTANTE / IMPORTANT: Marca "Add Python to PATH"
echo.
pause
exit /b 1

:CREATE_VENV
echo.
echo [SETUP] Creando entorno virtual / Creating virtual environment...
if exist "%VENV%" (
    echo  Ya existe, omitiendo / Already exists, skipping.
) else (
    "%BASE_PYTHON%" -m venv "%VENV%" 2>nul
    if !errorlevel! neq 0 (
        echo  [ERROR] No se pudo crear venv / Could not create venv.
        echo          Intenta instalar Python manualmente / Try installing Python manually.
        pause
        exit /b 1
    )
    echo  Creado / Created successfully.
)
set "PYTHON=%VENV%\Scripts\python.exe"

:PYTHON_OK

REM ─── Instalar dependencias Python ─────────────────────────────
set "PY_MARKER=%ACESTEP_DIR%\.deps_installed"
set "NEED_PY_INSTALL=0"

if not exist "%PY_MARKER%" (
    set "NEED_PY_INSTALL=1"
) else (
    REM Comprobar si requirements.txt es mas nuevo
    for /f "tokens=*" %%a in ('powershell -NoProfile -Command "if ((Get-Item \"%ACESTEP_DIR%\requirements.txt\" -ErrorAction SilentlyContinue).LastWriteTime -gt (Get-Item \"%PY_MARKER%\" -ErrorAction SilentlyContinue).LastWriteTime) { Write-Output 'yes' }"') do (
        if "%%a"=="yes" set "NEED_PY_INSTALL=1"
    )
)

if !NEED_PY_INSTALL! equ 1 (
    echo.
    echo [SETUP] Instalando dependencias Python / Installing Python dependencies...
    echo         Esto puede tardar varios minutos / This may take several minutes...
    echo.
    
    REM Intentar actualizar pip con reintentos
    "%PYTHON%" -m pip install --upgrade pip --quiet 2>nul || "%PYTHON%" -m pip install --upgrade pip
    
    if exist "%ACESTEP_DIR%\requirements.txt" (
        REM Intentar instalacion normal primero
        "%PYTHON%" -m pip install -r "%ACESTEP_DIR%\requirements.txt" 2>nul
        if !errorlevel! neq 0 (
            echo.
            echo [RETRY] Usando cache y offine / Using cache and offline...
            "%PYTHON%" -m pip install -r "%ACESTEP_DIR%\requirements.txt" --prefer-binary --no-index --find-links %temp% 2>nul
            if !errorlevel! neq 0 (
                echo [WARNING] Algunos paquetes fallaron / Some packages failed
                echo           Intenta manualmente o verifica tu conexion / Try manually or check connection
                echo.
            ) else (
                echo. > "%PY_MARKER%"
                echo  ✓ Dependencias instaladas / Dependencies installed
            )
        ) else (
            echo. > "%PY_MARKER%"
            echo  ✓ Dependencias instaladas / Dependencies installed
        )
    )
) else (
    echo  ✓ Dependencias Python ya instaladas / Python deps already installed.
)

REM ─── Instalar dependencias Node.js ───────────────────────────
echo.
echo [SETUP] Verificando dependencias Node.js / Checking Node.js deps...

if not exist "%UI_DIR%\node_modules" (
    echo [!] Instalando UI deps / Installing...
    cd /d "%UI_DIR%" || exit /b 1
    call npm install 2>nul || call npm install
    if !errorlevel! neq 0 (
        echo  [ERROR] npm install UI fallo / failed.
        pause
        exit /b 1
    )
    cd /d "%~dp0"
) else (
    echo  ✓ UI dependencies ya instaladas / already installed
)

if not exist "%UI_DIR%\server\node_modules" (
    echo [!] Instalando backend deps / Installing...
    cd /d "%UI_DIR%\server" || exit /b 1
    call npm install 2>nul || call npm install
    if !errorlevel! neq 0 (
        echo  [ERROR] npm install backend fallo / failed.
        pause
        exit /b 1
    )
    cd /d "%~dp0"
) else (
    echo  ✓ Backend dependencies ya instaladas / already installed
)

if exist "%PRO_UI_DIR%\package.json" (
    if not exist "%PRO_UI_DIR%\node_modules" (
        echo [!] Instalando Pro UI deps / Installing...
        cd /d "%PRO_UI_DIR%" || exit /b 1
        call npm install 2>nul || call npm install
        if !errorlevel! neq 0 (
            echo  [ERROR] npm install Pro UI fallo / failed.
            pause
            exit /b 1
        )
        cd /d "%~dp0"
    ) else (
        echo  ✓ Pro UI dependencies ya instaladas / already installed
    )
)

cd /d "%~dp0"

REM ─── Matar procesos previos / Kill previous processes ────────
echo.
echo [STARTUP] Liberando puertos / Freeing ports (8001, 3001, 3000, 3002)...
for /f "tokens=5" %%p in ('netstat -aon 2^>nul ^| findstr ":8001 " ^| findstr "LISTENING"') do (
    taskkill /F /PID %%p >nul 2>&1
)
for /f "tokens=5" %%p in ('netstat -aon 2^>nul ^| findstr ":3001 " ^| findstr "LISTENING"') do (
    taskkill /F /PID %%p >nul 2>&1
)
for /f "tokens=5" %%p in ('netstat -aon 2^>nul ^| findstr ":3000 " ^| findstr "LISTENING"') do (
    taskkill /F /PID %%p >nul 2>&1
)
for /f "tokens=5" %%p in ('netstat -aon 2^>nul ^| findstr ":3002 " ^| findstr "LISTENING"') do (
    taskkill /F /PID %%p >nul 2>&1
)
timeout /t 2 /nobreak >nul

REM ─── Obtener IP local / Get local IP ────────────────────────
set LOCAL_IP=
for /f "tokens=2 delims=:" %%a in ('ipconfig 2^>nul ^| findstr /c:"IPv4"') do (
    for /f "tokens=1" %%b in ("%%a") do set LOCAL_IP=%%b
)

REM ─── Variables de entorno heredadas / Inherited env vars ─────
set "ACESTEP_CACHE_DIR=%ACESTEP_DIR%.cache\acestep"
set "HF_HOME=%ACESTEP_DIR%.cache\huggingface"
set "ACESTEP_PATH=%ACESTEP_DIR%"
set "DATASETS_DIR=%ACESTEP_DIR%\datasets"

REM ─── Crear lanzadores temporales / Create temp launchers ─────
set "LAUNCHER_DIR=%TEMP%\acestep_launchers"
if not exist "%LAUNCHER_DIR%" mkdir "%LAUNCHER_DIR%"

> "%LAUNCHER_DIR%\_gradio.cmd" (
    echo @echo off
    echo title ACE-Step Gradio API
    echo cd /d "%ACESTEP_DIR%"
    echo "%PYTHON%" -m acestep.acestep_v15_pipeline --port 8001 --enable-api --backend pt --server-name 127.0.0.1 --config_path acestep-v15-turbo
    echo pause
)

> "%LAUNCHER_DIR%\_backend.cmd" (
    echo @echo off
    echo title ACE-Step Backend
    echo cd /d "%UI_DIR%\server"
    echo npm run dev
    echo pause
)

> "%LAUNCHER_DIR%\_frontend.cmd" (
    echo @echo off
    echo title ACE-Step Frontend
    echo cd /d "%UI_DIR%"
    echo npm run dev
    echo pause
)

> "%LAUNCHER_DIR%\_proui.cmd" (
    echo @echo off
    echo title ACE-Step Pro UI
    echo cd /d "%PRO_UI_DIR%"
    echo npm run dev
    echo pause
)

echo.
echo [1/4] Iniciando / Starting ACE-Step Gradio API (puerto/port 8001)...
start "ACE-Step Gradio API" "%LAUNCHER_DIR%\_gradio.cmd"

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║   CARGANDO MODELO DE IA / LOADING AI MODEL                   ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║   Primera vez: 2-5 minutos / First time: 2-5 minutes        ║
echo ║   Siguientes: 1-2 minutos / Subsequent: 1-2 minutes        ║
echo ║   Por favor, espera / Please wait...                        ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

set READY=0
set ATTEMPTS=0
set MAX_ATTEMPTS=120

:WAIT_GRADIO
set /a ATTEMPTS+=1
if !ATTEMPTS! gtr !MAX_ATTEMPTS! (
    echo.
    echo  [WARNING] Gradio no respondio / did not respond after 10 min. Continuando / Continuing...
    goto GRADIO_CONTINUE
)

netstat -aon 2>nul | findstr ":8001 " | findstr "LISTENING" >nul 2>&1
if !errorlevel! equ 0 (
    REM Puerto abierto, verificar HTTP
    powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:8001/gradio_api/info' -TimeoutSec 3 -ErrorAction Stop | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
    if !errorlevel! equ 0 (
        set READY=1
        goto GRADIO_READY
    )
)

set /a SECS=!ATTEMPTS! * 5
if !ATTEMPTS! leq 6 (
    echo    [!SECS!s] Iniciando Python / Starting Python...
) else if !ATTEMPTS! leq 12 (
    echo    [!SECS!s] Cargando pesos DiT / Loading DiT weights...
) else if !ATTEMPTS! leq 25 (
    echo    [!SECS!s] Inicializando LM / Initializing LM...
) else (
    echo    [!SECS!s] Cargando modelo... / Loading model... (sistema lento? / slow system?)
)

timeout /t 5 /nobreak >nul
goto WAIT_GRADIO

:GRADIO_READY
echo.
echo  ✓ MODELO LISTO / MODEL READY!
echo.

:GRADIO_CONTINUE
echo [2/4] Iniciando / Starting Backend (puerto/port 3001)...
start "ACE-Step Backend" "%LAUNCHER_DIR%\_backend.cmd"
timeout /t 5 /nobreak >nul

echo [3/4] Iniciando / Starting Frontend (puerto/port 3000)...
start "ACE-Step Frontend" "%LAUNCHER_DIR%\_frontend.cmd"
timeout /t 3 /nobreak >nul

echo [4/4] Iniciando / Starting Pro UI (puerto/port 3002)...
if exist "%PRO_UI_DIR%\package.json" (
    start "ACE-Step Pro UI" "%LAUNCHER_DIR%\_proui.cmd"
) else (
    echo  Pro UI no encontrada / not found. Omitiendo / Skipping.
)

timeout /t 3 /nobreak >nul

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║   SERVICIOS LISTOS / ALL SERVICES READY                 ║
echo ╠══════════════════════════════════════════════════════════╣
echo ║                                                          ║
echo ║   Gradio API:  http://localhost:8001                     ║
echo ║   Backend:     http://localhost:3001                     ║
echo ║   Classic UI:  http://localhost:3000                     ║
echo ║   Pro UI:      http://localhost:3002                     ║
echo ║                                                          ║
if defined LOCAL_IP (
echo ║   LAN:         http://%LOCAL_IP%:3002                    ║
echo ║                                                          ║
)
echo ║   Puedes cambiar entre :3000 y :3002 en el navegador     ║
echo ║   You can switch between :3000 and :3002 in browser      ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

echo Abriendo navegador en 3 segundos / Opening browser...
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo Pulsa cualquier tecla para cerrar / Press any key to close
echo (Los servicios seguiran corriendo / Services will keep running)
pause >nul

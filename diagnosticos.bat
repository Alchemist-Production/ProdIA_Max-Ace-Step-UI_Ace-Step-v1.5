@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title ProdIA-MAX - Diagnosticos / Diagnostics
cd /d "%~dp0"

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║      ProdIA-MAX - DIAGNOSTICOS / DIAGNOSTICS v1.0             ║
echo ║   Verificando todas las dependencias e instalaciones          ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

set "DIAGNOSTICS_PASSED=1"
set "ACESTEP_DIR=%~dp0ACE-Step-1.5_"
set "UI_DIR=%~dp0ace-step-ui"
set "PRO_UI_DIR=%~dp0ace-step-ui-pro"
set "VENV=%ACESTEP_DIR%\.venv"

REM ════════════════════════════════════════════════════════════════
REM 1. DIRECTORIO BASE
REM ════════════════════════════════════════════════════════════════
echo.
echo [1/12] Verificando estructura de directorios / Checking directory structure...
if exist "%ACESTEP_DIR%" (
    echo  ✓ ACE-Step-1.5_ encontrado / found
) else (
    echo  ✗ ACE-Step-1.5_ NO ENCONTRADO / NOT FOUND
    set "DIAGNOSTICS_PASSED=0"
)

if exist "%UI_DIR%" (
    echo  ✓ ace-step-ui encontrado / found
) else (
    echo  ✗ ace-step-ui NO ENCONTRADO / NOT FOUND
    set "DIAGNOSTICS_PASSED=0"
)

if exist "%PRO_UI_DIR%" (
    echo  ✓ ace-step-ui-pro encontrado / found
) else (
    echo  ✗ ace-step-ui-pro NO ENCONTRADO / NOT FOUND - (opcional / optional)
)

REM ════════════════════════════════════════════════════════════════
REM 2. PYTHON
REM ════════════════════════════════════════════════════════════════
echo.
echo [2/12] Detectando Python / Detecting Python...
set "PYTHON_FOUND=0"
set "PYTHON_PATH="

if exist "%ACESTEP_DIR%\python_embeded\python.exe" (
    set "PYTHON_PATH=%ACESTEP_DIR%\python_embeded\python.exe"
    set "PYTHON_FOUND=1"
    echo  ✓ Python embebido encontrado / Embedded Python found
    for /f "tokens=*" %%i in ('"!PYTHON_PATH!" --version') do echo    Version: %%i
    goto :PYTHON_OK
)

if exist "%VENV%\Scripts\python.exe" (
    set "PYTHON_PATH=%VENV%\Scripts\python.exe"
    set "PYTHON_FOUND=1"
    echo  ✓ Virtual environment encontrado / found
    for /f "tokens=*" %%i in ('"!PYTHON_PATH!" --version') do echo    Version: %%i
    goto :PYTHON_OK
)

python --version >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('where python') do set "PYTHON_PATH=%%i"
    set "PYTHON_FOUND=1"
    echo  ✓ Python del sistema / System Python encontrado / found
    for /f "tokens=*" %%i in ('python --version') do echo    Version: %%i
    goto :PYTHON_OK
)

py --version >nul 2>&1
if !errorlevel! equ 0 (
    set "PYTHON_PATH=py"
    set "PYTHON_FOUND=1"
    echo  ✓ Python launcher encontrado / found
    for /f "tokens=*" %%i in ('py --version') do echo    Version: %%i
    goto :PYTHON_OK
)

:PYTHON_OK
if !PYTHON_FOUND! equ 0 (
    echo  ✗ Python NO ENCONTRADO / NOT FOUND - CRITICO / CRITICAL
    set "DIAGNOSTICS_PASSED=0"
) else (
    REM Verificar que sea 3.10+
    for /f "tokens=2" %%v in ('"!PYTHON_PATH!" --version 2^>^&1') do (
        echo  Python version: %%v
    )
)

REM ════════════════════════════════════════════════════════════════
REM 3. NODE.JS
REM ════════════════════════════════════════════════════════════════
echo.
echo [3/12] Detectando Node.js / Detecting Node.js...
where node >nul 2>&1
if !errorlevel! equ 0 (
    echo  ✓ Node.js encontrado / found
    for /f "tokens=*" %%i in ('node --version') do echo    Version: %%i
) else (
    echo  ✗ Node.js NO ENCONTRADO / NOT FOUND - CRITICO / CRITICAL
    echo      Descarga desde / Download from: https://nodejs.org/
    set "DIAGNOSTICS_PASSED=0"
)

REM ════════════════════════════════════════════════════════════════
REM 4. NPM
REM ════════════════════════════════════════════════════════════════
echo.
echo [4/12] Detectando npm / Detecting npm...
where npm >nul 2>&1
if !errorlevel! equ 0 (
    echo  ✓ npm encontrado / found
    for /f "tokens=*" %%i in ('npm --version') do echo    Version: %%i
) else (
    echo  ✗ npm NO ENCONTRADO / NOT FOUND
    set "DIAGNOSTICS_PASSED=0"
)

REM ════════════════════════════════════════════════════════════════
REM 5. CUDA (opcional pero recomendado / optional but recommended)
REM ════════════════════════════════════════════════════════════════
echo.
echo [5/12] Verificando CUDA / Checking CUDA...
nvidia-smi >nul 2>&1
if !errorlevel! equ 0 (
    echo  ✓ NVIDIA GPU detectada / Detected
    for /f "tokens=3" %%i in ('nvidia-smi ^| findstr /i "driver"') do echo    Driver version: %%i
) else (
    echo  ⚠ NVIDIA GPU NO DETECTADA / NOT DETECTED
    echo    La app funcionará MAS LENTAMENTE sin GPU / App will be MUCH SLOWER without GPU
    echo    Recomendado: Instala drivers NVIDIA con CUDA 12.8
    echo    Recommended: Install NVIDIA drivers with CUDA 12.8
)

REM ════════════════════════════════════════════════════════════════
REM 6. REQUIREMENTS.TXT
REM ════════════════════════════════════════════════════════════════
echo.
echo [6/12] Verificando requirements.txt / Checking requirements.txt...
if exist "%ACESTEP_DIR%\requirements.txt" (
    echo  ✓ requirements.txt encontrado / found
) else (
    echo  ✗ requirements.txt NO ENCONTRADO / NOT FOUND
    set "DIAGNOSTICS_PASSED=0"
)

REM ════════════════════════════════════════════════════════════════
REM 7. PAQUETES PYTHON
REM ════════════════════════════════════════════════════════════════
echo.
echo [7/12] Verificando paquetes Python instalados / Checking Python packages...
if !PYTHON_FOUND! equ 1 (
    "!PYTHON_PATH!" -m pip list >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=1" %%p in ('"!PYTHON_PATH!" -m pip list ^| findstr /i torch') do (
            if "%%p"=="torch" (
                echo  ✓ PyTorch encontrado / found
                goto :TORCH_OK
            )
        )
        echo  ⚠ PyTorch posiblemente no instalado / may not be installed
        echo    Se instalará automaticamente en el siguiente inicio
        echo    Will be installed automatically on next startup
        :TORCH_OK
    ) else (
        echo  ⚠ No se pudo verificar paquetes / Could not verify packages
    )
) else (
    echo  ✗ No se puede verificar (Python no encontrado / not found)
)

REM ════════════════════════════════════════════════════════════════
REM 8. NODE MODULES UI
REM ════════════════════════════════════════════════════════════════
echo.
echo [8/12] Verificando dependencias UI / Checking UI dependencies...
if exist "%UI_DIR%\node_modules" (
    echo  ✓ UI node_modules encontrado / found
) else (
    echo  ⚠ UI node_modules NO ENCONTRADO / NOT FOUND
    echo    Se instalará automaticamente en el siguiente inicio
    echo    Will be installed automatically on next startup
)

REM ════════════════════════════════════════════════════════════════
REM 9. NODE MODULES BACKEND
REM ════════════════════════════════════════════════════════════════
echo.
echo [9/12] Verificando dependencias backend / Checking backend dependencies...
if exist "%UI_DIR%\server\node_modules" (
    echo  ✓ Backend node_modules encontrado / found
) else (
    echo  ⚠ Backend node_modules NO ENCONTRADO / NOT FOUND
    echo    Se instalará automaticamente en el siguiente inicio
    echo    Will be installed automatically on next startup
)

REM ════════════════════════════════════════════════════════════════
REM 10. NODE MODULES PRO UI
REM ════════════════════════════════════════════════════════════════
echo.
echo [10/12] Verificando dependencias Pro UI / Checking Pro UI dependencies...
if exist "%PRO_UI_DIR%\node_modules" (
    echo  ✓ Pro UI node_modules encontrado / found
) else (
    echo  ⚠ Pro UI node_modules NO ENCONTRADO / NOT FOUND (opcional / optional)
    echo    Se instalará automaticamente si se necesita
    echo    Will be installed automatically if needed
)

REM ════════════════════════════════════════════════════════════════
REM 11. PUERTOS DISPONIBLES
REM ════════════════════════════════════════════════════════════════
echo.
echo [11/12] Verificando puertos / Checking ports...
netstat -aon 2>nul | findstr ":8001 " | findstr "LISTENING" >nul 2>&1
if !errorlevel! neq 0 (
    echo  ✓ Puerto 8001 disponible / available
) else (
    echo  ⚠ Puerto 8001 en uso / in use - Se liberará automáticamente / Will be freed automatically
)

netstat -aon 2>nul | findstr ":3001 " | findstr "LISTENING" >nul 2>&1
if !errorlevel! neq 0 (
    echo  ✓ Puerto 3001 disponible / available
) else (
    echo  ⚠ Puerto 3001 en uso / in use
)

netstat -aon 2>nul | findstr ":3002 " | findstr "LISTENING" >nul 2>&1
if !errorlevel! neq 0 (
    echo  ✓ Puerto 3002 disponible / available
) else (
    echo  ⚠ Puerto 3002 en uso / in use
)

REM ════════════════════════════════════════════════════════════════
REM 12. ESPACIO EN DISCO
REM ════════════════════════════════════════════════════════════════
echo.
echo [12/12] Verificando espacio en disco / Checking disk space...
for /f "tokens=3" %%s in ('dir %ACESTEP_DIR% ^| find "bytes free"') do (
    if %%s GTR 10000000000 (
        echo  ✓ Espacio en disco suficiente / Sufficient disk space
    ) else (
        echo  ⚠ Espacio en disco bajo / Low disk space
    )
)

REM ════════════════════════════════════════════════════════════════
REM RESUMEN / SUMMARY
REM ════════════════════════════════════════════════════════════════
echo.
echo.
if !DIAGNOSTICS_PASSED! equ 1 (
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║        ✓ DIAGNOSTICOS COMPLETADOS / DIAGNOSTICS PASSED       ║
    echo ║                                                              ║
    echo ║  Tu instalación se ve BIEN. Puedes ejecutar:                 ║
    echo ║  Your setup looks GOOD. You can run:                         ║
    echo ║                                                              ║
    echo ║    [4] Iniciar Pro UI solamente / Start Pro UI Only          ║
    echo ║                                                              ║
    echo ║  O ejecuta: iniciar_pro.bat                                  ║
    echo ║            iniciar_todo.bat                                  ║
    echo ╚════════════════════════════════════════════════════════════════╝
) else (
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║     ✗ DIAGNOSTICOS CON PROBLEMAS / DIAGNOSTICS WITH ISSUES   ║
    echo ║                                                              ║
    echo ║  Se encontraron problemas. Por favor, instala:               ║
    echo ║  Issues found. Please install:                               ║
    echo ║                                                              ║
    echo ║    1. Python 3.11 desde / from: https://www.python.org       ║
    echo ║    2. Node.js 18+ desde / from: https://nodejs.org          ║
    echo ║    3. NVIDIA GPU Drivers + CUDA 12.8 (recomendado)           ║
    echo ║                                                              ║
    echo ║  Luego ejecuta: [2] Instalar dependencias / Install Deps     ║
    echo ╚════════════════════════════════════════════════════════════════╝
)

echo.
pause
exit /b 0

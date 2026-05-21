@echo off
setlocal enabledelayedexpansion
title ProdIA-MAX Setup & Launch

REM ============================================================================
REM ProdIA-MAX Main Launcher for Windows
REM ============================================================================
REM This script handles:
REM  - Python virtual environment (venv) creation/activation
REM  - Dependency verification and installation
REM  - Service startup (Gradio API, Node backend, frontend)
REM  - Port management and cleanup
REM ============================================================================

cd /d "%~dp0"

echo.
echo ============================================================================
echo  ProdIA-MAX Setup and Launch
echo ============================================================================
echo.

REM Check for required tools
call :check_requirements
if !errorlevel! neq 0 exit /b 1

REM Main menu
:menu
cls
echo.
echo ============================================================================
echo  ProdIA-MAX Main Menu
echo ============================================================================
echo.
echo  [1] Quick Start (Recommended)
echo      Automatic setup and launch Pro UI only
echo.
echo  [2] Install/Setup
echo      Create Python virtual environment, install all dependencies
echo.
echo  [3] Start Services Only
echo      Start existing services (skips setup)
echo.
echo  [4] Diagnostics
echo      Check installation and system requirements
echo.
echo  [5] Clean User Data
echo      Delete database and generated audio (keeps models and code)
echo.
echo  [6] Full Uninstall
echo      Remove all dependencies and cache (keeps models and source)
echo.
echo  [0] Exit
echo.
set /p choice="Enter your choice [0-6]: "

if "%choice%"=="1" goto quick_start
if "%choice%"=="2" goto install_deps
if "%choice%"=="3" goto start_services
if "%choice%"=="4" goto diagnostics
if "%choice%"=="5" goto clean_data
if "%choice%"=="6" goto uninstall_all
if "%choice%"=="0" (
    echo.
    echo Goodbye!
    exit /b 0
)

echo.
echo ERROR: Invalid choice. Please enter 0-6.
echo.
pause
goto menu

REM ============================================================================
REM QUICK START - Full setup and launch
REM ============================================================================
:quick_start
cls
echo.
echo ============================================================================
echo  Quick Start: Full Setup + Launch
echo ============================================================================
echo.

call :setup_python_env
if !errorlevel! neq 0 goto menu

call :install_all_dependencies
if !errorlevel! neq 0 goto menu

call :start_all_services
exit /b 0

REM ============================================================================
REM INSTALL DEPENDENCIES
REM ============================================================================
:install_deps
cls
echo.
echo ============================================================================
echo  Installation ^& Setup
echo ============================================================================
echo.

call :setup_python_env
if !errorlevel! neq 0 goto menu

call :install_all_dependencies
if !errorlevel! neq 0 goto menu

echo.
echo Installation complete!
echo.
pause
goto menu

REM ============================================================================
REM START SERVICES ONLY
REM ============================================================================
:start_services
cls
echo.
echo ============================================================================
echo  Starting Services
echo ============================================================================
echo.

call :start_all_services
exit /b 0

REM ============================================================================
REM DIAGNOSTICS
REM ============================================================================
:diagnostics
cls
echo.
echo ============================================================================
echo  System Diagnostics
echo ============================================================================
echo.

echo Checking Python installation...
python --version
if !errorlevel! neq 0 (
    echo [ERROR] Python not found or not in PATH
    goto diag_end
)
echo [OK] Python found

echo.
echo Checking Node.js installation...
node --version
if !errorlevel! neq 0 (
    echo [ERROR] Node.js not found or not in PATH
    goto diag_end
)
echo [OK] Node.js found

echo.
echo Checking NVIDIA CUDA (optional but recommended)...
nvidia-smi >nul 2>&1
if !errorlevel! neq 0 (
    echo [WARNING] NVIDIA GPU not detected or CUDA not installed
    echo [INFO] The app will fall back to CPU (slower)
) else (
    echo [OK] NVIDIA GPU detected
    nvidia-smi --query-gpu=name --format=csv,noheader
)

echo.
echo Checking virtual environment...
if exist "ACE-Step-1.5_\.venv" (
    echo [OK] Python virtual environment found
) else (
    echo [WARNING] Python virtual environment not found
    echo [INFO] Run 'Install/Setup' from the main menu to create it
)

echo.
echo Checking Node.js dependencies...
if exist "ace-step-ui\node_modules" (
    echo [OK] ace-step-ui dependencies found
) else (
    echo [WARNING] ace-step-ui/node_modules not found
)

if exist "ace-step-ui\server\node_modules" (
    echo [OK] ace-step-ui/server dependencies found
) else (
    echo [WARNING] ace-step-ui/server/node_modules not found
)

if exist "ace-step-ui-pro\node_modules" (
    echo [OK] ace-step-ui-pro dependencies found
) else (
    echo [WARNING] ace-step-ui-pro/node_modules not found
)

:diag_end
echo.
echo Diagnostics complete!
echo.
pause
goto menu

REM ============================================================================
REM CLEAN USER DATA
REM ============================================================================
:clean_data
cls
echo.
echo ============================================================================
echo  Clean User Data
echo ============================================================================
echo.
echo This will delete:
echo  - User database
echo  - Generated audio files
echo.
echo This will KEEP:
echo  - AI models
echo  - Source code
echo  - Dependencies
echo.
set /p confirm="Are you sure? (yes/no): "
if /i not "%confirm%"=="yes" (
    echo Cancelled.
    pause
    goto menu
)

echo Cleaning user data...

if exist "ace-step-ui\server\data" (
    echo Deleting database folder...
    rmdir /s /q "ace-step-ui\server\data" >nul 2>&1
)

if exist "ace-step-ui\server\uploads" (
    echo Deleting uploads folder...
    rmdir /s /q "ace-step-ui\server\uploads" >nul 2>&1
)

if exist "ACE-Step-1.5_\generated_audios" (
    echo Deleting generated audio folder...
    rmdir /s /q "ACE-Step-1.5_\generated_audios" >nul 2>&1
)

echo.
echo User data cleaned successfully!
echo.
pause
goto menu

REM ============================================================================
REM FULL UNINSTALL
REM ============================================================================
:uninstall_all
cls
echo.
echo ============================================================================
echo  Full Uninstall
echo ============================================================================
echo.
echo This will delete:
echo  - Python virtual environment (.venv)
echo  - Node.js node_modules
echo  - User database
echo  - Generated audio files
echo  - Cache and temporary files
echo.
echo This will KEEP:
echo  - AI models (checkpoints)
echo  - Source code
echo.
set /p confirm="Are you absolutely sure? (yes/no): "
if /i not "%confirm%"=="yes" (
    echo Cancelled.
    pause
    goto menu
)

echo Uninstalling...
call :kill_all_ports

echo Removing Python virtual environment...
if exist "ACE-Step-1.5_\.venv" (
    rmdir /s /q "ACE-Step-1.5_\.venv" >nul 2>&1
)

echo Removing Node.js dependencies...
if exist "ace-step-ui\node_modules" (
    rmdir /s /q "ace-step-ui\node_modules" >nul 2>&1
)
if exist "ace-step-ui\server\node_modules" (
    rmdir /s /q "ace-step-ui\server\node_modules" >nul 2>&1
)
if exist "ace-step-ui-pro\node_modules" (
    rmdir /s /q "ace-step-ui-pro\node_modules" >nul 2>&1
)

echo Removing user data...
if exist "ace-step-ui\server\data" (
    rmdir /s /q "ace-step-ui\server\data" >nul 2>&1
)
if exist "ace-step-ui\server\uploads" (
    rmdir /s /q "ace-step-ui\server\uploads" >nul 2>&1
)
if exist "ACE-Step-1.5_\generated_audios" (
    rmdir /s /q "ACE-Step-1.5_\generated_audios" >nul 2>&1
)

echo.
echo Uninstall complete!
echo Models and source code are preserved.
echo.
pause
goto menu

REM ============================================================================
REM HELPER FUNCTIONS
REM ============================================================================

:check_requirements
echo Checking system requirements...
echo.

REM Check Python
python --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] Python 3.11 is required but not found.
    echo.
    echo Please install Python from: https://www.python.org/downloads/
    echo Important: Check "Add Python to PATH" during installation!
    echo.
    pause
    exit /b 1
)

REM Check Node.js
node --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] Node.js 18+ is required but not found.
    echo.
    echo Please install Node.js from: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo [OK] Python found
echo [OK] Node.js found
echo.
exit /b 0

:setup_python_env
echo.
echo Setting up Python virtual environment...

if exist "ACE-Step-1.5_\.venv" (
    echo Virtual environment already exists. Skipping creation.
    exit /b 0
)

echo Creating virtual environment in ACE-Step-1.5_\.venv...
cd "ACE-Step-1.5_"
python -m venv .venv
if !errorlevel! neq 0 (
    echo [ERROR] Failed to create virtual environment
    pause
    cd ..
    exit /b 1
)
cd ..

echo [OK] Virtual environment created
exit /b 0

:install_all_dependencies
echo.
echo Installing all dependencies...
echo.

REM Activate Python venv and install packages
echo Installing Python packages...
cd "ACE-Step-1.5_"
call .venv\Scripts\activate.bat
if !errorlevel! neq 0 (
    echo [ERROR] Failed to activate virtual environment
    pause
    cd ..
    exit /b 1
)

echo Upgrading pip, setuptools, and wheel...
python -m pip install --upgrade pip setuptools wheel >nul 2>&1
if !errorlevel! neq 0 (
    echo [WARNING] pip upgrade had issues, but continuing...
)

echo.
echo Installing requirements from requirements.txt...
echo This may take several minutes - please be patient...
pip install -r requirements.txt --no-cache-dir
if !errorlevel! neq 0 (
    echo [ERROR] Failed to install Python requirements
    echo [INFO] Please check your internet connection and try again
    pause
    cd ..
    exit /b 1
)
echo.
echo [OK] Python packages installed successfully
cd ..

REM Install Node.js dependencies
echo.
echo Installing Node.js dependencies...

cd "ace-step-ui"
call npm install --legacy-peer-deps
if !errorlevel! neq 0 (
    echo [ERROR] Failed to install ace-step-ui dependencies
    pause
    cd ..
    exit /b 1
)
cd "server"
call npm install --legacy-peer-deps
if !errorlevel! neq 0 (
    echo [ERROR] Failed to install server dependencies
    pause
    cd ..\..
    exit /b 1
)
cd "..\..\"

cd "ace-step-ui-pro"
call npm install --legacy-peer-deps
if !errorlevel! neq 0 (
    echo [ERROR] Failed to install ace-step-ui-pro dependencies
    pause
    cd ..
    exit /b 1
)
cd ..

echo [OK] Node.js packages installed
echo.
echo ============================================================================
echo All dependencies installed successfully!
echo ============================================================================
exit /b 0

:start_all_services
echo.
echo Preparing to start services...
echo.

REM Kill existing processes on required ports
call :kill_all_ports

REM Activate Python venv
cd "ACE-Step-1.5_"
call .venv\Scripts\activate.bat
cd ..

echo.
echo Starting Gradio API (port 8001)...
start "ProdIA-MAX Gradio API" cmd /k "cd ACE-Step-1.5_ && call .venv\Scripts\activate.bat && python -m acestep --port 8001 --server-name 127.0.0.1"

REM Wait for API to start
timeout /t 5 /nobreak >nul

echo.
echo Starting Express backend (port 3001)...
start "ProdIA-MAX Backend" cmd /k "cd ace-step-ui\server && npm run dev"

REM Wait for backend to start
timeout /t 3 /nobreak >nul

echo.
echo Starting React frontend (port 3002)...
start "ProdIA-MAX Frontend Pro" cmd /k "cd ace-step-ui-pro && npm run dev"

REM Wait for frontend to start
timeout /t 5 /nobreak >nul

echo.
echo ============================================================================
echo  Services started successfully!
echo ============================================================================
echo.
echo Frontend (Pro UI):  http://localhost:3002
echo Backend API:       http://localhost:3001
echo Gradio API:        http://localhost:8001
echo.
echo Keep these terminal windows open while using the application.
echo.
echo Opening browser in 3 seconds...
timeout /t 3 /nobreak >nul
start http://localhost:3002

exit /b 0

:kill_all_ports
REM Kill processes on required ports
for /f "tokens=5" %%a in ('netstat -ano -p TCP ^| findstr ":8001 "') do (
    taskkill /PID %%a /F >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano -p TCP ^| findstr ":3001 "') do (
    taskkill /PID %%a /F >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano -p TCP ^| findstr ":3000 "') do (
    taskkill /PID %%a /F >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano -p TCP ^| findstr ":3002 "') do (
    taskkill /PID %%a /F >nul 2>&1
)
exit /b 0

endlocal

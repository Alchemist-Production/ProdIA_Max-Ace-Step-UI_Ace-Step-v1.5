@echo off
chcp 65001 >nul 2>&1
title ProdIA-MAX - Menu Principal / Main Menu
cd /d "%~dp0"

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║          ProdIA-MAX - MENU PRINCIPAL / MAIN MENU              ║
echo ║   Enhanced AI Music Production Suite for Windows              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.
echo  Selecciona una opcion / Select an option:
echo.
echo  [1] Diagnosticos / Diagnostics
echo      Verifica que todo este instalado correctamente
echo      Verify installation and dependencies
echo.
echo  [2] Instalar dependencias / Install Dependencies
echo      Instala Python, Node.js y paquetes necesarios
echo      Install all required packages
echo.
echo  [3] Iniciar todo / Start All (Classic + Pro UI)
echo      Inicia Gradio + Backend + Classic UI + Pro UI
echo      Full stack with both interfaces
echo.
echo  [4] Iniciar Pro UI solamente / Start Pro UI Only [RECOMMENDED]
echo      Inicia Gradio + Backend + Pro UI (mas rapido)
echo      Faster startup - Pro UI only
echo.
echo  [5] Limpiar datos de usuario / Clean User Data
echo      Elimina database y audio generado (mantiene modelos)
echo      Delete database and audio, keeps models
echo.
echo  [6] Desinstalar / Uninstall
echo      Limpia todo excepto modelos y codigo fuente
echo      Full cleanup, keeps models and source
echo.
echo  [0] Salir / Exit
echo.

set /p choice="Opcion / Choice: "

if "%choice%"=="1" (
    call diagnosticos.bat
    goto end
)
if "%choice%"=="2" (
    call instalar_dependencias.bat
    goto end
)
if "%choice%"=="3" (
    call iniciar_todo.bat
    goto end
)
if "%choice%"=="4" (
    call iniciar_pro.bat
    goto end
)
if "%choice%"=="5" (
    call limpiar_datos_usuario.bat
    goto end
)
if "%choice%"=="6" (
    call desinstalar.bat
    goto end
)
if "%choice%"=="0" (
    echo Adios / Goodbye!
    exit /b 0
)

echo.
echo  [ERROR] Opcion invalida / Invalid choice. Por favor, intenta de nuevo / Try again.
echo.
pause
cls
goto :eof

:end
pause
exit /b 0

@echo off
setlocal
REM ====================================================================
REM  Kit para bloquear contenido adulto (capa Windows)
REM  Comprobacion del estado. No necesita administrador.
REM ====================================================================

set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SCRIPT=%~dp0comprobar.ps1"
if not exist "%SCRIPT%" (
    echo No se encuentra comprobar.ps1 junto a este archivo.
    pause
    exit /b 1
)

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"

echo.
echo Pulsa una tecla para cerrar esta ventana.
pause >nul
endlocal

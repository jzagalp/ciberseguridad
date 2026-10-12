@echo off
rem ------------------------------------------------------------------
rem  Kit para bloquear contenido adulto - llaves
rem  Lanza nueva-llave.ps1 con Windows PowerShell 5.1.
rem  -ExecutionPolicy Bypass solo afecta a esta ejecucion: no cambia
rem  la configuracion de Windows. -STA hace falta para el portapapeles.
rem  No necesita permisos de administrador.
rem  Puedes pasarle opciones, por ejemplo:
rem     EJECUTAR-llave.bat -Para "Router" -Longitud 16
rem     EJECUTAR-llave.bat -ConSimbolo
rem     EJECUTAR-llave.bat -PorTrozos
rem ------------------------------------------------------------------
setlocal
cd /d "%~dp0"
if not exist "%~dp0nueva-llave.ps1" (
    echo No encuentro nueva-llave.ps1 junto a este archivo.
    echo Si has abierto el kit dentro del ZIP, primero descomprimelo:
    echo clic derecho en el ZIP, "Extraer todo", y abre la carpeta llaves extraida.
    echo.
    pause
    exit /b 1
)
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0nueva-llave.ps1" %*
echo.
pause
endlocal

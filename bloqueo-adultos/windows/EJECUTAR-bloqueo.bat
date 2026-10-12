@echo off
setlocal
REM ====================================================================
REM  Kit para bloquear contenido adulto (capa Windows)
REM  Este lanzador pide permiso de administrador (UAC) y ejecuta
REM  bloquear-pc.ps1. Opciones (escribelas detras, en una ventana cmd):
REM    -ActualizarLista   descarga la lista de dominios mas reciente
REM    -SinCuentas        no toca las cuentas
REM    -IfeoExtra         friccion extra contra Tor/Opera/Psiphon portables
REM    -DohWindows11      cifra el DNS en Windows 11 (opcional)
REM ====================================================================

set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "ELEVADO="
set "ARGS=%*"
if /i "%~1"=="ELEVADO" (
    set "ELEVADO=1"
    set "ARGS=%ARGS:~8%"
)

REM fltmc solo funciona con permisos de administrador.
fltmc >nul 2>&1
if errorlevel 1 (
    if defined ELEVADO (
        echo No se han podido obtener permisos de administrador. No se ha cambiado nada.
        pause
        exit /b 1
    )
    echo Pidiendo permisos de administrador...
    "%PS%" -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList 'ELEVADO %ARGS%' -Verb RunAs"
    if errorlevel 1 (
        echo No se concedio el permiso. No se ha cambiado nada.
        pause
    )
    exit /b
)

set "SCRIPT=%~dp0bloquear-pc.ps1"
if not exist "%SCRIPT%" (
    echo No se encuentra bloquear-pc.ps1 junto a este archivo.
    echo Descomprime el kit entero antes de usarlo.
    pause
    exit /b 1
)

echo.
echo Ejecutando el bloqueo. Sigue las instrucciones en pantalla.
echo.
"%PS%" -NoProfile -ExecutionPolicy Bypass -Sta -File "%SCRIPT%" %ARGS%

echo.
echo Terminado. Pulsa una tecla para cerrar esta ventana.
pause >nul
endlocal

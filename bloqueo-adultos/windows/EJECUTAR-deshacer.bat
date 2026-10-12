@echo off
setlocal
REM ====================================================================
REM  Kit para bloquear contenido adulto (capa Windows)
REM  DESHACER: usalo cuando llegue la llave de tu capsula del tiempo.
REM  Windows te pedira usuario y contrasena de administrador:
REM  elige GuardianBloqueo y teclea la llave con sus guiones.
REM ====================================================================

set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "ELEVADO="
set "ARGS=%*"
if /i "%~1"=="ELEVADO" (
    set "ELEVADO=1"
    set "ARGS=%ARGS:~8%"
)

fltmc >nul 2>&1
if errorlevel 1 (
    if defined ELEVADO (
        echo No se han podido obtener permisos de administrador. No se ha cambiado nada.
        pause
        exit /b 1
    )
    echo Windows te va a pedir usuario y contrasena de administrador.
    echo Elige GuardianBloqueo - o pulsa Mas opciones - y teclea la llave.
    "%PS%" -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList 'ELEVADO %ARGS%' -Verb RunAs"
    if errorlevel 1 (
        echo No se concedio el permiso. No se ha cambiado nada.
        pause
    )
    exit /b
)

set "SCRIPT=%~dp0deshacer-pc.ps1"
if not exist "%SCRIPT%" (
    echo No se encuentra deshacer-pc.ps1 junto a este archivo.
    pause
    exit /b 1
)

echo.
echo Deshaciendo el bloqueo de la capa Windows. Sigue las instrucciones.
echo.
"%PS%" -NoProfile -ExecutionPolicy Bypass -Sta -File "%SCRIPT%" %ARGS%

echo.
echo Terminado. Pulsa una tecla para cerrar esta ventana.
pause >nul
endlocal

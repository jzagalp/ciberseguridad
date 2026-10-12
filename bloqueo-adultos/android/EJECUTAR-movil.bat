@echo off
rem ------------------------------------------------------------------
rem  Kit para bloquear contenido adulto - capa Android
rem  Lanza configurar-movil.ps1 con Windows PowerShell 5.1.
rem  -ExecutionPolicy Bypass solo afecta a esta ejecucion: no cambia
rem  la configuracion de Windows. -STA hace falta para el portapapeles.
rem  Puedes pasarle opciones, por ejemplo:  EJECUTAR-movil.bat -Deshacer
rem ------------------------------------------------------------------
setlocal
cd /d "%~dp0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0configurar-movil.ps1" %*
echo.
pause
endlocal

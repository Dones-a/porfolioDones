@echo off
echo Iniciando servidor web en puerto 5500...
echo.
echo Abre tu navegador y ve a: http://localhost:5500
echo.
echo Presiona Ctrl+C para detener el servidor
echo.
powershell -ExecutionPolicy Bypass -File server.ps1
pause


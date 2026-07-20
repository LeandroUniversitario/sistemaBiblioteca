@echo off
color 0A
echo ===================================================
echo     INICIANDO SISTEMA DE BIBLIOTECA EN INTERNET
echo ===================================================
echo.

echo [1/4] Iniciando el Servidor Backend (Java Spring Boot)...
start "Backend (Java)" cmd /k "cd backend && .\apache-maven-3.9.6\bin\mvn.cmd spring-boot:run"

echo [2/4] Iniciando el Servidor Frontend (Python)...
start "Frontend (Web)" cmd /k "python -m http.server 5500"

echo [3/4] Abriendo tunel hacia internet para la API...
start "Tunel API" cmd /k "npx localtunnel --port 8080 --subdomain unp-biblioteca-api"

echo [4/4] Abriendo tunel hacia internet para la pagina Web...
start "Tunel Web" cmd /k "npx localtunnel --port 5500 --subdomain unp-biblioteca-web"

echo.
echo ===================================================
echo TODO LISTO. EL SISTEMA ESTA ONLINE.
echo Comparte este enlace con tus companeros:
echo 👉 https://unp-biblioteca-web.loca.lt
echo ===================================================
echo.
pause

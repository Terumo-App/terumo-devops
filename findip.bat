@echo off
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| find "IPv4"') do set ip=%%i
echo Seu endereço IP da rede local é %ip:~1%
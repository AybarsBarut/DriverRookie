@echo off
echo [*] Driver Updater Baslatiliyor...
echo.

:: Yonetici haklari (opsiyonel ama bazi suruculeri okumak icin faydali olabilir) 
:: Burada sadece ExecutionPolicy'yi asarak mevcut dizindeki scripti calistiriyoruz.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DriverUpdater.ps1"

echo.
pause

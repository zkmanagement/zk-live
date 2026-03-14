@echo off
title StreamFlow Auto Installer
color 0A
setlocal EnableDelayedExpansion

echo.
echo  =====================================================
echo   StreamFlow AUTO INSTALLER FOR WINDOWS RDP
echo   github.com/zkmanagement/streamflow
echo  =====================================================
echo.

:: --- Check Administrator ---
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo  [ERROR] Jalankan script ini sebagai ADMINISTRATOR!
    echo  Klik kanan file .bat ini lalu pilih "Run as Administrator"
    echo.
    pause
    exit /b 1
)
echo  [OK] Running sebagai Administrator
echo.

:: ============================================================
::  STEP 1 - INSTALL CHOCOLATEY
:: ============================================================
echo  [1/6] Mengecek Chocolatey...
where choco >nul 2>&1
if %errorLevel% EQU 0 (
    echo  [OK] Chocolatey sudah terinstall, skip...
) else (
    echo  [INFO] Menginstall Chocolatey...
    @powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    echo  [OK] Chocolatey berhasil diinstall!
)
echo.

:: ============================================================
::  STEP 2 - INSTALL NODE.JS
:: ============================================================
echo  [2/6] Mengecek Node.js...
where node >nul 2>&1
if %errorLevel% EQU 0 (
    echo  [OK] Node.js sudah terinstall, skip...
) else (
    echo  [INFO] Menginstall Node.js...
    choco install nodejs -y
    echo  [OK] Node.js berhasil diinstall!
)
echo.

:: ============================================================
::  STEP 3 - INSTALL GIT
:: ============================================================
echo  [3/6] Mengecek Git...
where git >nul 2>&1
if %errorLevel% EQU 0 (
    echo  [OK] Git sudah terinstall, skip...
) else (
    echo  [INFO] Menginstall Git...
    choco install git -y
    echo  [OK] Git berhasil diinstall!
)
echo.

:: ============================================================
::  STEP 4 - INSTALL FFMPEG
:: ============================================================
echo  [4/6] Mengecek FFmpeg...
where ffmpeg >nul 2>&1
if %errorLevel% EQU 0 (
    echo  [OK] FFmpeg sudah terinstall, skip...
) else (
    echo  [INFO] Menginstall FFmpeg...
    choco install ffmpeg -y
    echo  [OK] FFmpeg berhasil diinstall!
)
echo.

:: ============================================================
::  STEP 5 - OPEN FIREWALL PORT 7575
:: ============================================================
echo  [5/6] Membuka port 7575 di Windows Firewall...
netsh advfirewall firewall show rule name="StreamFlow 7575" >nul 2>&1
if %errorLevel% EQU 0 (
    echo  [OK] Rule firewall sudah ada, skip...
) else (
    netsh advfirewall firewall add rule name="StreamFlow 7575" dir=in action=allow protocol=TCP localport=7575
    echo  [OK] Port 7575 berhasil dibuka!
)
echo.

:: ============================================================
::  STEP 6 - CLONE & SETUP StreamFlow
:: ============================================================
echo  [6/6] Setup StreamFlow...

:: Refresh PATH agar node/git bisa dipakai setelah install
call refreshenv >nul 2>&1

set INSTALL_DIR=%USERPROFILE%\zk-live

if exist "%INSTALL_DIR%" (
    echo  [INFO] Folder sudah ada di: %INSTALL_DIR%
    echo  [INFO] Melakukan git pull untuk update...
    cd /d "%INSTALL_DIR%"
    git pull origin main
) else (
    echo  [INFO] Clone repo StreamFlow...
    git clone https://github.com/zkmanagement/zk-live.git "%INSTALL_DIR%"
    echo  [OK] Clone selesai!
)

cd /d "%INSTALL_DIR%"

echo  [INFO] Menginstall dependencies (npm install)...
call npm install

:: Buat .env dari .env.example jika belum ada
if not exist ".env" (
    if exist ".env.example" (
        copy .env.example .env
        echo  [OK] File .env dibuat dari .env.example
        echo  [WARN] Silakan edit file .env sesuai kebutuhan sebelum menjalankan app!
    ) else (
        echo  [WARN] File .env.example tidak ditemukan, buat .env secara manual
    )
) else (
    echo  [OK] File .env sudah ada, skip...
)

:: Tampilkan IP server
echo.
echo  [INFO] IP Address server ini:
powershell -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' } | Select-Object -ExpandProperty IPAddress"

echo.
echo  =====================================================
echo   INSTALASI SELESAI!
echo  =====================================================
echo.
echo  Lokasi folder : %INSTALL_DIR%
echo  Jalankan app  : cd %INSTALL_DIR% lalu ketik "npm start"
echo  Akses browser : http://[IP-SERVER]:7575
echo.
echo  PENTING: Edit file .env sebelum jalankan app!
echo.

set /p RUNAPP= Jalankan StreamFlow sekarang? (y/n): 
if /i "%RUNAPP%"=="y" (
    echo.
    echo  [INFO] Menjalankan StreamFlow...
    echo  [INFO] Buka browser ke: http://[IP-SERVER]:7575
    echo  [INFO] Tekan CTRL+C untuk stop
    echo.
    npm start
)

pause

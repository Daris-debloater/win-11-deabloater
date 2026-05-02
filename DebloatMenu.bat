@echo off
title Windows Debloater Utility
color 0A

:: Auto-elevate to admin
>nul 2>&1 net session || (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:MENU
cls
echo ================================
echo      WINDOWS DEBLOATER UI
echo ================================
echo.
echo 1) Remove Microsoft Edge
echo 2) Remove Microsoft Store
echo 3) Disable Cortana
echo 4) Disable Widgets
echo 5) Remove OneDrive
echo 6) Disable Web Search in Start Menu
echo 7) Disable Telemetry
echo 8) Performance Tweaks
echo 9) Restore Edge
echo 10) Restore Microsoft Store
echo 11) Disable Windows Updates
echo 12) Enable Windows Updates (Undo)
echo 13) Disable Windows Defender (VM Mode)
echo 14) Enable Windows Defender (Undo)
echo 15) Full On Debloat (Minimal Mode)
echo 0) Exit
echo.
set /p choice="Select an option: "

if "%choice%"=="1" goto RemoveEdge
if "%choice%"=="2" goto RemoveStore
if "%choice%"=="3" goto DisableCortana
if "%choice%"=="4" goto DisableWidgets
if "%choice%"=="5" goto RemoveOneDrive
if "%choice%"=="6" goto DisableWebSearch
if "%choice%"=="7" goto DisableTelemetry
if "%choice%"=="8" goto PerformanceTweaks
if "%choice%"=="9" goto RestoreEdge
if "%choice%"=="10" goto RestoreStore
if "%choice%"=="11" goto DisableWindowsUpdates
if "%choice%"=="12" goto EnableWindowsUpdates
if "%choice%"=="13" goto DisableDefender
if "%choice%"=="14" goto EnableDefender
if "%choice%"=="15" goto FullDebloatMenu
if "%choice%"=="0" exit
goto MENU


:: -------------------------
:: REMOVE EDGE
:: -------------------------
:RemoveEdge
echo Removing Microsoft Edge...
powershell -Command "Get-AppxPackage *MicrosoftEdge* | Remove-AppxPackage"
pause
goto MENU


:: -------------------------
:: REMOVE STORE
:: -------------------------
:RemoveStore
echo Removing Microsoft Store...
powershell -Command "Get-AppxPackage *WindowsStore* | Remove-AppxPackage"
pause
goto MENU


:: -------------------------
:: DISABLE CORTANA
:: -------------------------
:DisableCortana
echo Disabling Cortana...
powershell -Command "Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage"
pause
goto MENU


:: -------------------------
:: DISABLE WIDGETS
:: -------------------------
:DisableWidgets
echo Disabling Widgets...
powershell -Command "Get-AppxPackage *WebExperience* | Remove-AppxPackage"
pause
goto MENU


:: -------------------------
:: REMOVE ONEDRIVE
:: -------------------------
:RemoveOneDrive
echo Removing OneDrive...
taskkill /f /im OneDrive.exe
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
pause
goto MENU


:: -------------------------
:: DISABLE WEB SEARCH
:: -------------------------
:DisableWebSearch
echo Disabling Bing Web Search in Start Menu...
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f
pause
goto MENU


:: -------------------------
:: DISABLE TELEMETRY
:: -------------------------
:DisableTelemetry
echo Disabling Telemetry...
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
pause
goto MENU


:: -------------------------
:: PERFORMANCE TWEAKS
:: -------------------------
:PerformanceTweaks
echo Applying performance tweaks...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v EnablePrefetcher /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v EnableSuperfetch /t REG_DWORD /d 0 /f
pause
goto MENU


:: -------------------------
:: RESTORE EDGE
:: -------------------------
:RestoreEdge
echo Restoring Microsoft Edge...
powershell -Command "Start-Process 'msedge.exe' -ErrorAction SilentlyContinue"
pause
goto MENU


:: -------------------------
:: RESTORE STORE
:: -------------------------
:RestoreStore
echo Restoring Microsoft Store...
powershell -Command "Get-AppxPackage -allusers Microsoft.WindowsStore | Add-AppxPackage -register ((Get-AppxPackage -allusers Microsoft.WindowsStore).InstallLocation + '\AppxManifest.xml')"
pause
goto MENU


:: -------------------------
:: DISABLE WINDOWS UPDATES
:: -------------------------
:DisableWindowsUpdates
echo Disabling Windows Updates...

net stop wuauserv /y
net stop bits /y
net stop usosvc /y

sc config wuauserv start= disabled
sc config bits start= disabled
sc config usosvc start= disabled

schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable
schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\Automatic App Update" /Disable
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Disable
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" /Disable
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\UpdateModelTask" /Disable

echo Windows Updates disabled.
pause
goto MENU


:: -------------------------
:: ENABLE WINDOWS UPDATES
:: -------------------------
:EnableWindowsUpdates
echo Enabling Windows Updates...

sc config wuauserv start= demand
sc config bits start= demand
sc config usosvc start= demand

net start wuauserv
net start bits
net start usosvc

schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Enable
schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\Automatic App Update" /Enable
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Enable
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" /Enable
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\UpdateModelTask" /Enable

echo Windows Updates enabled.
pause
goto MENU


:: -------------------------
:: DISABLE DEFENDER (SAFE VM MODE)
:: -------------------------
:DisableDefender
echo Disabling Windows Defender (VM Mode)...
echo Tamper Protection must be OFF manually.

powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -DisableBehaviorMonitoring $true"
powershell -Command "Set-MpPreference -DisableIOAVProtection $true"
powershell -Command "Set-MpPreference -DisableScriptScanning $true"
powershell -Command "Set-MpPreference -DisableBlockAtFirstSeen $true"

powershell -Command "Set-MpPreference -MAPSReporting 0"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"

sc stop WinDefend
sc config WinDefend start= disabled

schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable

echo Defender disabled.
pause
goto MENU


:: -------------------------
:: ENABLE DEFENDER
:: -------------------------
:EnableDefender
echo Enabling Windows Defender...

sc config WinDefend start= auto
sc start WinDefend

powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false"
powershell -Command "Set-MpPreference -DisableBehaviorMonitoring $false"
powershell -Command "Set-MpPreference -DisableIOAVProtection $false"
powershell -Command "Set-MpPreference -DisableScriptScanning $false"
powershell -Command "Set-MpPreference -DisableBlockAtFirstSeen $false"

powershell -Command "Set-MpPreference -MAPSReporting 2"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 1"

schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Enable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Enable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Enable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /Enable

echo Defender enabled.
pause
goto MENU


:: ============================================================
:: FULL ON DEBLOAT SUBMENU
:: ============================================================
:FullDebloatMenu
cls
echo ===============================
echo        FULL ON DEBLOAT
echo        (Minimal Mode)
echo ===============================
echo.
echo 1) Disable Defender (VM Mode)
echo 2) Disable Windows Updates
echo 3) Remove Bloat Apps
echo 4) Disable Telemetry
echo 5) Disable Non-Critical Services
echo 6) Disable Background Tasks
echo 7) Apply Performance Tweaks
echo 8) Apply UI/Animation Tweaks
echo 9) Apply Network Tweaks
echo 10) RUN ALL (Full Minimal Mode)
echo 0) Back
echo.
set /p fd="Select an option: "

if "%fd%"=="1" goto DisableDefender
if "%fd%"=="2" goto DisableWindowsUpdates
if "%fd%"=="3" goto RemoveBloatApps
if "%fd%"=="4" goto DisableTelemetry
if "%fd%"=="5" goto DisableNonCriticalServices
if "%fd%"=="6" goto DisableBackgroundTasks
if "%fd%"=="7" goto PerformanceTweaks
if "%fd%"=="8" goto UITweaks
if "%fd%"=="9" goto NetworkTweaks
if "%fd%"=="10" goto FullDebloatRunAll
if "%fd%"=="0" goto MENU
goto FullDebloatMenu


:: -------------------------
:: REMOVE BLOAT APPS
:: -------------------------
:RemoveBloatApps
echo Removing bloat apps...
powershell -Command "Get-AppxPackage *MicrosoftEdge* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *WindowsStore* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *WebExperience* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage"
taskkill /f /im OneDrive.exe
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
echo Done.
pause
goto FullDebloatMenu


:: -------------------------
:: DISABLE NON-CRITICAL SERVICES
:: -------------------------
:DisableNonCriticalServices
echo Disabling non-critical services...

sc config XboxGipSvc start= disabled
sc config XblAuthManager start= disabled
sc config XblGameSave start= disabled
sc config XboxNetApiSvc start= disabled
sc config Spooler start= disabled
sc config WSearch start= disabled
sc config DiagTrack start= disabled

echo Done.
pause
goto FullDebloatMenu


:: -------------------------
:: DISABLE BACKGROUND TASKS
:: -------------------------
:DisableBackgroundTasks
echo Disabling background scheduled tasks...

schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
schtasks /Change /TN "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Disable

echo Done.
pause
goto FullDebloatMenu


:: -------------------------
:: UI TWEAKS
:: -------------------------
:UITweaks
echo Applying UI/animation tweaks...

reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f

echo Done.
pause
goto FullDebloatMenu


:: -------------------------
:: NETWORK TWEAKS
:: -------------------------
:NetworkTweaks
echo Applying network tweaks...

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f

echo Done.
pause
goto FullDebloatMenu


:: -------------------------
:: RUN ALL (FULL MINIMAL MODE)
:: -------------------------
:FullDebloatRunAll
call :DisableDefender
call :DisableWindowsUpdates
call :RemoveBloatApps
call :DisableTelemetry
call :DisableNonCriticalServices
call :DisableBackgroundTasks
call :PerformanceTweaks
call :UITweaks
call :NetworkTweaks
echo.
echo FULL ON DEBLOAT COMPLETE.
pause
goto MENU

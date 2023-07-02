@echo off
title IT-HELPER
color 0a
set date=date >> %date%
set time=time >> %time%
set host=localhost
set database=postgres
set port=5432
set user=postgres

:start
mode 70, 20
cls
echo.
echo    ==========   M E N U   ==========
echo.
echo      1- Load Backup
echo      2- Transfer Backup
echo      3- Uninstall MS Office
echo      4- Log Device Info
echo      5- Info
echo      6- Exit
echo.

choice /c 123456 /n /m ">:"

if %ERRORLEVEL%==6 goto :exit
if %ERRORLEVEL%==5 goto :info
if %ERRORLEVEL%==4 goto :logdevices
if %ERRORLEVEL%==3 goto :uninstall
if %ERRORLEVEL%==2 goto :transfer
if %ERRORLEVEL%==1 goto :load

:load
if NOT EXIST "devices.csv" (
for %%a in ("devices.csv") do (
echo Date;Time;Operation_Type;Computer_Name;User_Domain;User_Name;Root_Drive;Processor_Type;Processor_Architecture;Number_of_Cores;Windows_Dir >> devices.csv))

for %%j in ("devices.csv") do (
echo %date%;%time%;Backup Load;%COMPUTERNAME%;%USERDOMAIN%;%USERNAME%;%SYSTEMDRIVE%;%PROCESSOR_IDENTIFIER%;%PROCESSOR_ARCHITECTURE%;%NUMBER_OF_PROCESSORS%;%SYSTEMROOT% >> devices.csv)

if NOT EXIST %COMPUTERNAME%-BACKUP\ (mkdir %COMPUTERNAME%-BACKUP)

cd .\%COMPUTERNAME%-BACKUP

if NOT EXIST %USERNAME%-BACKUP\ (mkdir %USERNAME%-BACKUP)

echo USER BACKUP:
xcopy %SYSTEMDRIVE%\Users\%USERNAME% .\%USERNAME%-BACKUP /s /e /v /y /c

if %ERRORLEVEL%==4 goto :lowmemory
if %ERRORLEVEL%==2 goto :abort
if %ERRORLEVEL%==0 goto :finished

:userdata
if NOT EXIST "%USERNAME% ChromeUserData-BACKUP\" (mkdir "%USERNAME% ChromeUserData-BACKUP")

echo BACKUP CHROME USER DATA:
xcopy %localappdata%\Google\Chrome .\"%USERNAME% ChromeUserData-BACKUP" /s /e /v /y /c

if %ERRORLEVEL%==4 goto :lowmemory
if %ERRORLEVEL%==2 goto :abort
if %ERRORLEVEL%==0 (
echo.
echo Backup Finished
echo.
pause
cd ..
goto :start)

:transfer
choice /c sn /n /m "Transfer files to: %SYSTEMDRIVE%\Users\%USERNAME%? (s, n)"

if %ERRORLEVEL%==1 (
if NOT EXIST "devices.csv" (
for %%a in ("devices.csv") do (
echo Date;Time;Operation_Type;Computer_Name;User_Domain;User_Name;Root_Drive;Processor_Type;Processor_Architecture;Number_of_Cores;Windows_Dir >> devices.csv))

for %%j in ("devices.csv") do (
echo %date%;%time%;Backup Transfer;%COMPUTERNAME%;%USERDOMAIN%;%USERNAME%;%SYSTEMDRIVE%;%PROCESSOR_IDENTIFIER%;%PROCESSOR_ARCHITECTURE%;%NUMBER_OF_PROCESSORS%;%SYSTEMROOT% >> devices.csv)

xcopy .\%COMPUTERNAME%-BACKUP\%USERNAME%-BACKUP %SYSTEMDRIVE%\Users\%USERNAME% /s /e /v /y /c

xcopy .\%COMPUTERNAME%-BACKUP\"%USERNAME% ChromeUserData-BACKUP" %localappdata%\Google\Chrome /s /e /v /y /c

echo.
echo Backup Transfer Successful
echo.
pause
goto start)

goto start

:lowmemory
echo.
echo Process Interrupted, Insufficient Memory Space to Copy...
echo.
pause
cd ..
goto start

:abort
echo.
echo Process Interrupted, User Aborted with Ctrl+C...
echo.
pause
cd ..
goto start

:finished
echo.
echo Backup Finished
echo.
goto userdata

:info
mode 85, 20
cls
echo.
echo    ====================     IT - HELPER      VERSION 0.3     =====================
echo.
echo    NOTES: * COMPUTER NAME AND USER NAME FROM SOURCE MUST MATCH THE DESTINATION'S !
echo           * POSTGRESQL REQUIRED TO LOG DEVICES
echo.
echo    CURRENT:    COMPUTER NAME: %COMPUTERNAME%    USER NAME: %USERNAME%
echo                (Default:localhost) DB HOST: %host%
echo                (Default:postgres)  DATABASE: %database%
echo                (Default:5432)      PORT: %port%
echo                (Default:postgres)  DB USER: %user%
echo.
pause
goto start

:uninstall
if NOT EXIST "devices.csv" (
for %%a in ("devices.csv") do (
echo Date;Time;Operation_Type;Computer_Name;User_Domain;User_Name;Root_Drive;Processor_Type;Processor_Architecture;Number_of_Cores;Windows_Dir >> devices.csv))

for %%j in ("devices.csv") do (
echo %date%;%time%;Office Uninstall;%COMPUTERNAME%;%USERDOMAIN%;%USERNAME%;%SYSTEMDRIVE%;%PROCESSOR_IDENTIFIER%;%PROCESSOR_ARCHITECTURE%;%NUMBER_OF_PROCESSORS%;%SYSTEMROOT% >> devices.csv)

cls
cd _Utils\SaRACmd
SaRAcmd.exe -S OfficeScrubScenario -AcceptEula -OfficeVersion All

echo.
if %ERRORLEVEL%==1 echo Error: Something Went Wrong...
if %ERRORLEVEL%==00 echo Successfully Uninstalled MS Office
if %ERRORLEVEL%==68 echo Error: No Office Product Found
if %ERRORLEVEL%==06 echo Error: Existant Office Files Running
if %ERRORLEVEL%==08 echo Error: Multiple Office Versions Found
if %ERRORLEVEL%==09 echo Error: Failure to Remove
if %ERRORLEVEL%==10 echo Error: Not in Elevated Mode
if %ERRORLEVEL%==66 echo Error: Command / Detected Version Mismatch
if %ERRORLEVEL%==67 echo Error: Invalid Command Office Version
echo.
cd..
cd..

pause
goto start

:logdevices
echo.
choice /c sn /n /m "Log Device Info into Database? Current:%host%|%database% (s, n)"

if %ERRORLEVEL%==1 (
cls
mode 225, 25
psql -h %host% -d %database% -p %port% -U %user% -f "DBManager.bat"

echo.
echo System Info Logged Successfuly
echo.
pause
goto start)

echo.
pause
goto start

:exit
exit
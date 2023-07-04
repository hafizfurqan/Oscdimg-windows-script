@echo off
:: Setting Toolkit environment path variables
set "Bin=%~dp0Bin"
if "%PROCESSOR_ARCHITECTURE%" equ "x86" set "Arch=x86"
if "%PROCESSOR_ARCHITECTURE%" equ "AMD64" set "Arch=x64"
set \='%~dp0'
if exist "%WinDir%\SysWOW64" (set "HostArchitecture=x64") else (set "HostArchitecture=x86")
set "Oscdimg=%Bin%\%HostArchitecture%\oscdimg.exe"
set "Imagex=%Bin%\%HostArchitecture%\imagex.exe"
:start

cls

echo.===============================================================================
echo.##############################  ISOCreator v1  ################################
echo.===============================================================================
echo.
echo.
echo.          Bootable ISO creator using oscdimg.exe for uefi and bios
echo.       this is a guided process so provide it with files and folders
echo.              it requires to generate bootable iso image
echo.              This is used to generate only Windows iso.
echo.
echo.
echo.===============================================================================

echo.-------------------------------------------------------------------------------
echo.###################### Getting DVD ISO Image Details ##########################
echo.-------------------------------------------------------------------------------
echo.
echo. Arch=%HostArchitecture%
echo.
echo. Oscdimg=%Oscdimg%
echo.
:: Getting Source Directory
:source
set /p DVD=Enter the Source Directory or Drag n Drop  :
::-------------------------------------------------------------------------------------------
:: Function to Make a DVD ISO Image for Burning to DVD Disc
::-------------------------------------------------------------------------------------------

setlocal

set "BIOSBoot=%DVD%\boot\etfsboot.com"
set "UEFIBoot=%DVD%\efi\microsoft\boot\efisys.bin"
set ISOLabel=
set ISOFileName=

:: Checking whether Windows Source DVD folder is empty
if not exist "%BIOSBoot%" (
	echo.Windows Boot files not found...
	echo.
	echo.Please copy associated boot files to source directory...
	goto :Source
)

:: Getting ISO Label Name
set /p ISOLabel=Enter the ISO Volume Label : 


:: Getting ISO File Name
set /p ISOFileName=Enter the ISO File Name : 

:: Getting ISO Output Path
set /p ISO=Enter the ISO Output Path : 

:report
echo.-------------------------------------------------------------------------------
echo.###################### Generating Short Report ################################
echo.-------------------------------------------------------------------------------
echo. BiosBoot = %BIOSBoot%
if exist "%UEFIBoot%" (
	echo. UEFIBoot = Yes
)
echo. Source = %DVD%
echo. Output = %ISO%\
echo. ISO File Name = %ISOFileName%.iso
echo. ISO Label = %ISOLabel%
choice /C YN /M "Is everything looking good?"
if %errorlevel% EQU 2 goto change
if %errorlevel% EQU 1 goto begin
:change
echo.-------------------------------------------------------------------------------
echo.############################### Changes #######################################
echo.-------------------------------------------------------------------------------
echo. ISO  [L]abel 
echo. ISO  [F]ilename, 
echo. ISO  [O]utput, 
echo. Quit [Q]
echo ..
Choice /C FLOQ /N /M "What would you like to change?"
if %errorlevel% EQU 4 goto end
if %errorlevel% EQU 3 goto out
if %errorlevel% EQU 2 goto label
if %errorlevel% EQU 1 goto filename
:begin
echo.-------------------------------------------------------------------------------
echo.###################### Building a DVD ISO Image ###############################
echo.-------------------------------------------------------------------------------
if "%ISOLabel%" equ "" (
	if exist "%UEFIBoot%" "%Oscdimg%" -bootdata:2#p0,e,b"%BIOSBoot%"#pEF,e,b"%UEFIBoot%" -o -h -m -u2 -udfver102 "%DVD%" "%ISO%\%ISOFileName%.iso"
	if not exist "%UEFIBoot%" "%Oscdimg%" -bootdata:1#p0,e,b"%BIOSBoot%" -o -h -m -u2 -udfver102 "%DVD%" "%ISO%\%ISOFileName%.iso"
)

if "%ISOLabel%" neq "" (
	if exist "%UEFIBoot%" "%Oscdimg%" -bootdata:2#p0,e,b"%BIOSBoot%"#pEF,e,b"%UEFIBoot%" -o -h -m -u2 -udfver102 -l"%ISOLabel%" "%DVD%" "%ISO%\%ISOFileName%.iso"
	if not exist "%UEFIBoot%" "%Oscdimg%" -bootdata:1#p0,e,b"%BIOSBoot%" -o -h -m -u2 -udfver102 "%DVD%" "%ISO%\%ISOFileName%.iso"
)
echo.
echo.-------------------------------------------------------------------------------
echo.#################### Finished Building a DVD ISO Image ########################
echo.-------------------------------------------------------------------------------
:Stop
echo.
echo.===============================================================================
echo.
pause

set BIOSBoot=
set UEFIBoot=
set ISOLabel=
set ISOFileName=

endlocal
pause
goto question
:end
echo.-------------------------------------------------------------------------------
echo.########################### Do visit again ####################################
echo.-------------------------------------------------------------------------------
echo "Do visit again"
timeout 5
exit
:Question
::-------------------------------------------------------------------------------------------
:: Make more or done
::-------------------------------------------------------------------------------------------
choice /C YN /M "Create more?"
if %errorlevel% EQU 2 goto end
if %errorlevel% EQU 1 goto start

:label
:: Getting ISO Label Name
choice /C CR /M "[C]hange label or [R]emove?"
if %errorlevel% EQU 1 (
	set /p ISOLabel=Enter the ISO Volume Label : 
	goto report
)
if %errorlevel% EQU 2 (
	set ISOLabel=
	goto report	
)
:filename
:: Getting ISO File Name
set /p ISOFileName=Enter the ISO File Name : 
goto report

:outputpath
:: Getting ISO Output Path
set /p ISO=Enter the ISO Output Path : 
goto report
@echo off
setlocal EnableDelayedExpansion
echo Use this installer by dragging your param file onto it.
echo.
:: Specify your massedit scripts here, multiple scripts are okay, separated by a space,
:: i.e. ".\script1.massedit" ".\script2.massedit"
:: Accepted extensions are .txt and .massedit
set MASSEDIT_FILES=".\mymod.massedit"
:: These are massedit files that contain row additions.
:: They will be processed before other massedit scripts.
set MASSEDIT_WITH_ADDITIONS=
:: Specify CSV edits here, they will be processed before all massedit scripts.
:: CSV files must be named according to the param they were exported from
:: i.e. ".\SpEffectParam.csv"
:: It is recommended to only use CSV files for adding new rows.
:: To convert CSV edits to massedit scripts, use the -C2M switch with DSMSPortable
set CSV_FILES=
:: Code indicating which game is being modified. Options are as follows:
:: DS1R  Dark Souls Remastered    DS2  Dark Souls 2    DS3     Dark Souls 3
:: ER    Elden Ring               BB   Bloodborne      SEKIRO  Sekiro
:: DS1   Dark Souls PTDE          DES  Demon's Souls
set GAMETYPE=ER
:: Relative path to the DSMSPortable.exe file from this installer.
set DSMSP_PATH=..
:: Use the MOD_PATH if you have to add additional commands to this script, see comments below
set MOD_PATH=%~dp1
set PARAM_FILE="%1"
set PARAM_FILE=%PARAM_FILE:"=%
cd "%DSMSP_PATH%"
set DSMSP_PATH=%CD%
cd "%~dp0"
:: Check DSMSP
if not exist %DSMSP_PATH%\DSMSPortable.exe (
	echo Could not find DSMSPortable.exe
	echo Please specify the relative path to DSMSPortable.exe in
	echo %0
	pause
	exit
)
:: Check .NET version
:verifydotnet
"%DSMSP_PATH%\DSMSPortable.exe" -? > nul 2>&1
if not %ERRORLEVEL%==0 (
	echo.
	echo .NET 6.0 Desktop Runtime not found, please install it before continuing
	timeout 3 > nul
	where /q winget
	if !ERRORLEVEL!==0 (
		winget install Microsoft.DotNet.DesktopRuntime.6
		goto verifydotnet
	)
	explorer "https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-aspnetcore-6.0.11-windows-hosting-bundle-installer"
	pause
	goto verifydotnet
)
:: Use -G function to grab the default paramfile name and relative path for the selected game
for /f tokens^=2 %%E in ('%DSMSP_PATH%\DSMSPortable.exe -G %GAMETYPE%^|findstr ParamfileName:') do set PARAM_FILE_NAME=%%E
for /f tokens^=2 %%E in ('%DSMSP_PATH%\DSMSPortable.exe -G %GAMETYPE%^|findstr ParamfileRelativePath:') do set PARAM_FILE_RELPATH=%%E
if "%PARAM_FILE_RELPATH%"=="" set PARAM_FILE_RELPATH=%PARAM_FILE_NAME%
:verifygamepath
if not exist "%DSMSP_PATH%\gamepath.txt" echo Steam\steamapps\common\ELDEN RING\Game>"%DSMSP_PATH%\gamepath.txt"
set /p GAMEPATH=<"%DSMSP_PATH%\gamepath.txt"
if exist "%PROGRAMFILES%\%GAMEPATH%\%PARAM_FILE_RELPATH%" ( set GAMEPATH="%PROGRAMFILES%\%GAMEPATH%"
) else if exist "%PROGRAMFILES(X86)%\%GAMEPATH%\%PARAM_FILE_RELPATH%" ( set GAMEPATH="%PROGRAMFILES(X86)%\%GAMEPATH%"
) else if not exist "%GAMEPATH%\%PARAM_FILE_RELPATH%" (
	if exist "%GAMEPATH%\Game\%PARAM_FILE_RELPATH%" (
		echo|set /p="%GAMEPATH%\Game">"%DSMSP_PATH%\gamepath.txt"
		goto verifygamepath
	)
	echo.
	echo Warning: Could not find %GAME_NAME% install directory, please open gamepath.txt and input the full path to your %GAME_NAME% Game folder, and save it before continuing
	echo Note: running this patcher "as administrator" may cause issues detecting necessary files
	timeout 3 > nul
	start notepad "%DSMSP_PATH%\gamepath.txt"
	pause
	goto verifygamepath
)
set GAMEPATH=%GAMEPATH:"=%
:: Check oo2core
if not exist "%DSMSP_PATH%\oo2core_6_win64.dll" xcopy "%GAMEPATH%\oo2core_6_win64.dll" "%DSMSP_PATH%"
:: Check paramfile
if not exist "%PARAM_FILE%" (
	choice /M "No %PARAM_FILE_NAME% specified. Patch vanilla %PARAM_FILE_NAME% instead"
	if !ERRORLEVEL!==1 ( 
		echo.
		xcopy "%GAMEPATH%\%PARAM_FILE_RELPATH%" .
		set PARAM_FILE=.\%PARAM_FILE_NAME%
	) else exit
)
:: Patch paramfile
"%DSMSP_PATH%\DSMSPortable.exe" "%PARAM_FILE%" -G %GAMETYPE% -C %CSV_FILES% -M+ %MASSEDIT_WITH_ADDITIONS% -M %MASSEDIT_FILES%
::"%DSMSP_PATH%\DSMSPortable.exe" --fmgmerge -G %GAMETYPE% "%MOD_PATH%\msg\______.msgbnd.dcx" [your FMG files] [-I]
::"%DSMSP_PATH%\DSMSPortable.exe" --texturemerge -G %GAMETYPE% "%MOD_PATH%\menu\_.tpf.dcx" [your DDS files] [-I]
::"%DSMSP_PATH%\DSMSPortable.exe" --layoutmerge -G %GAMETYPE% "%MOD_PATH%\menu\__.sblytbnd.dcx" [your layout files] [-I]
:: Workaround in case an anti-virus blocks DSMSPortable.exe from overwriting files
if exist "%PARAM_FILE%.temp" move /Y "%PARAM_FILE%.temp" "%PARAM_FILE%"
:: Rename backup if no original backup has already been made
if not exist "%PARAM_FILE%.bak" move /Y "%PARAM_FILE%.prev" "%PARAM_FILE%.bak"
echo.
echo Patching complete!
pause
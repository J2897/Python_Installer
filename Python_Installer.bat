:: Download and install 32-Bit Python 2.7.5 if it's not already installed in the default folder...

@echo OFF
pushd "%~dp0"
cls

REM Is Python installed?
if exist %CD:~0,3%Python27\ (echo Python is already installed.) && (goto :End)

ver | find "Version 6." > nul
if %ERRORLEVEL% == 0 (
	REM Do OPENFILES to check for administrative privileges
	openfiles > nul
	if errorlevel 1 (
		color cf
		echo Right-click on this file and select 'Run as administrator'.
		pause
		exit /b 1
		)
	)

set PYVER=2.7.5
set FN=python-%PYVER%.msi
set URL=http://www.python.org/ftp/python/%PYVER%/%FN%

REM Does the installation file already exist?
if exist "%USERPROFILE%\Downloads\%FN%" (set TEMP_PYTHON_MSI="%USERPROFILE%\Downloads\%FN%") else (
	if exist "%TEMP%\%FN%" (set TEMP_PYTHON_MSI="%TEMP%\%FN%") else (set TEMP_PYTHON_MSI="%TEMP%\%FN%") && (goto :Download)
)

REM Is the MD5 Hash valid?

	REM Get the OS #-Bit...
	set BIT=64
	if %PROCESSOR_ARCHITECTURE% == x86 (
		if not defined PROCESSOR_ARCHITEW6432 (set BIT=32)
	)

	REM Set the appropriate md5deep executable...
	if %BIT% == 64 (
		set MD5DEEP_EXE="%CD%\md5deep\md5deep64.exe"
	) else (
		set MD5DEEP_EXE="%CD%\md5deep\md5deep.exe"
	)

	REM Verify the MD5 Hash...
	set HASH_DB="%CD%\hashes.dat"
	%MD5DEEP_EXE% -M %HASH_DB% -b %TEMP_PYTHON_MSI%
	if %ERRORLEVEL% LEQ 1 (echo MD5 hash verified.) && (goto :Install) else (
		echo MD5 mismatch. Attempting to continue the download . . .
	)

:Continue
curl\curl.exe -C - %URL% -o %TEMP_PYTHON_MSI% && (goto :Install) || (
	(echo Failed to continue curling.) && (echo Restarting download . . .) && (del %TEMP_PYTHON_MSI%)
)

:Download
curl\curl.exe %URL% -o %TEMP_PYTHON_MSI% || (
	(echo Failed to curl.) && (goto :End)
)

:Install
echo Installing . . .
msiexec /i %TEMP_PYTHON_MSI% /qn ALLUSERS=1 || (echo Failed to install Python.)

:End
echo.
echo Finished.
echo.
pause
if defined TEMP_PYTHON_MSI (
	if exist %TEMP_PYTHON_MSI% (del %TEMP_PYTHON_MSI%)
)
popd

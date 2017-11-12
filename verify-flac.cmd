@echo off
setlocal EnableExtensions DisableDelayedExpansion

if not exist "%~1" (
	call :usage
	endlocal & exit /b 1
)
if not exist "%~2" (
	call :usage
	endlocal & exit /b 1
)

set "encoder=%~s2"

call :analyze "%~1"
for /f "delims=" %%D in ('dir /a:d /b /s "%~1"') do (
	call :analyze "%%D"
)

endlocal & exit /b 0

:analyze (
	echo --------------------------------------------------------------------------------
	echo -- Analyzing "%~1"
	echo --------------------------------------------------------------------------------
	pushd "%~1"
	set "files="
	:: 8dot3 filenames are preferable due to limitations on the length of a string value
	:: storable in a Batch variable. We quote the filenames to protect against errors in
	:: case they contain shell metacharacters:
	for %%F in (*.flac) do (
		call :append "%%~nxsF"
	)
	if not "%files%" == "" (
		call :verify
	)
	popd
	exit /b
)

:append (
	:: Filenames must be quote-delimited, else filenames containing shell metacharacters
	:: '&' or '^' can cause errors. The '/' is invalid in filenames, making it a suitable
	:: dummy delimiter to be later replaced by a double-quote:
	set "files=%files% /%~1/"
	exit /b
)

:verify (
	:: We could strip off the spurious leading space from %files% if we cared:
	:: set "files=%files:~1%"
	:: We undo any caret duplication in %files%:
	set "files=%files:^^=^%"
	:: Finally, we replace each '/' in %files% with a quote:
	"%encoder%" -t %files:/="%
	echo(
	exit /b
)

:usage (
	echo Call %~nx0 with arguments:
	echo ^(1^) Path to recursively traverse for .FLAC files to verify
	echo ^(2^) Path to FLAC encoder ^(flac.exe^) to use for verification
	for %%P in ("C:\Program Files (x86)\foobar2000\encoders\flac.exe") do set ex_encoder=%%~P
	echo Example: call "%~f0" "%USERPROFILE%\Music" "%ex_encoder%"
	exit /b
)
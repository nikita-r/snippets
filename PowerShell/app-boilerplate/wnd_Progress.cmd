@if -%1-==-- runas /trustlevel:0x20000 "cmd /c \"\"%~0\"\" -" & GoTo :EoF
@title %~n0
pushd "%~dp0"
pwsh.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%~n0.ps1"
@rem @echo exe.ExitCode=%ErrorLevel%
@if %ErrorLevel% EQU 0 GoTo :EoF
@PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File .\aux_Win32\ShowConsoleWindow.ps1
pause

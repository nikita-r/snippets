@rem @if -%1-==-- runas /trustlevel:0x20000 "cmd /c \"\"%~0\"\" -" & GoTo :EoF
@title %~n0
@echo Launched on %date% at %time: =0%
@prompt $$$+$G$S
pushd "%~dp0"
@if %ErrorLevel% NEQ 0 GoTo :lErr
PowerShell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%~n0.ps1"
@echo ErrorLevel=%ErrorLevel%
@if %ErrorLevel% EQU 0 exit
@if %ErrorLevel% EQU -1073741819 exit
@PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\aux_Win32\ShowConsoleWindow.ps1"
:lErr
pause

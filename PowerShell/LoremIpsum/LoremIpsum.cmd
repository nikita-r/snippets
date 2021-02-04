@if -%1-==-- runas /trustlevel:0x20000 "cmd /c \"\"%~0\"\" -" & GoTo :EoF
@title %~n0
@echo Launched on %date% at %time%
@prompt $$$+$G$S
pushd "%~dp0"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~n0.ps1"
@echo exe.ExitCode=%ErrorLevel%
pause

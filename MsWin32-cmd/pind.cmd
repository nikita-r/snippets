@if -%1-==-- runas /trustlevel:0x20000 "cmd /k \"\"%~0\"\" -" & goto:eof
@if -%1-==--- title %~0&goto:dash
cd /d %*
@goto:exit%ErrorLevel%
:exit0
title %*
:dash
cls
@echo CMD reset on %date% at %time: =0%
@prompt $$$+$G$S
@goto:eof
:exit1

@if -%1-==-- runas /trustlevel:0x20000 "cmd /k \"\"%~0\"\" - %~n0" & goto:eof
set @=%*
@set @=%@:~2%
@if -%1-==--- title %@%&goto:dash
cd /d %*
@goto:exit%ErrorLevel%
:exit0
title %*
:dash
cls
@echo CMD reset on %date% at %time: =0%
@chcp 65001
@prompt $$$+›$S
@goto:eof
:exit1

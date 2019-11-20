@echo off & SetLocal EnableExtensions EnableDelayedExpansion

set CurScr=%~nx0
set ArgStr=%CurScr:.cmd=%

set "Arg0=%ArgStr:*Args~=%"
set i=1
set "Arg!i!=%Arg0:;=" & set /A i+=1 & set "Arg!i!=%"

EndLocal & goto :EoF

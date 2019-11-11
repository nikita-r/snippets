@echo off

rem for /f "tokens=*" %? in ('wmic os get LocalDateTime /value ^| find "="') do set "%?"

for /f "usebackq skip=1 tokens=*" %%? in (`wmic os get LocalDateTime ^| findstr /r /v "^$"`) do set "date=%%?"

rem : remove trailing whitespace
set date=%date:~0,-3%

rem : date_strlen=25, but file size=27
rem echo.%date%>date.tmp.txt
rem for %%? in (date.tmp.txt) do set "date_strlen=%%~z?"
rem echo %date_strlen%

set date=%date:~0,8%
echo %date%

rem WinHlp32.exe for Windows 10

takeown /f "%SystemRoot%\en-us\winhlp32.exe.mui"
icacls "%SystemRoot%\en-us\winhlp32.exe.mui" /grant "%UserName%":f
takeown /f "%SystemRoot%\winhlp32.exe"
icacls "%SystemRoot%\winhlp32.exe" /grant "%UserName%":f

md msu-extracted
expand Windows8.1-KB917607-x64.msu /f:* .\msu-extracted
cd msu-extracted
md cab-extracted
expand Windows8.1-KB917607-x64.cab /f:* .\cab-extracted
cd cab-extracted
cd amd64_microsoft-windows-winhstb.resources_31bf3856ad364e35_6.3.9600.20470_en-us_c3a9a33a1aee3495
ren "%SystemRoot%\en-us\winhlp32.exe.mui" winhlp32.exe.mui.w10
copy winhlp32.exe.mui "%SystemRoot%\en-us\winhlp32.exe.mui"
cd ..\amd64_microsoft-windows-winhstb_31bf3856ad364e35_6.3.9600.20470_none_1a54d9f2f676f6c2
ren "%SystemRoot%\winhlp32.exe" winhlp32.exe.w10
copy winhlp32.exe "%SystemRoot%\winhlp32.exe"


# access the Ctrl+Alt+End menu via VBS
$tmp = New-TemporaryFile
'CreateObject("Shell.Application").WindowsSecurity' | Out-File $tmp
. $env:windir\System32\cscript.exe //B //E:VBS $tmp


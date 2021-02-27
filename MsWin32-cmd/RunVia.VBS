'
' Let us run an exe with the property Compatibility: Run this program as an administrator
'       on startup (from "shell:startup"); the UAC prompt will be presented upon userinit.
'
Set obj = CreateObject("WScript.Shell")
obj.Run """C:\Program Files\AutoHotkey\AutoHotkey.exe"" ""%UserProfile%\AutoHotkey.ahk""", 0
Set obj = Nothing

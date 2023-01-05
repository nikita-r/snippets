#Requires AutoHotkey <2.0

#IfWinActive, ahk_exe EXCEL.EXE

+WheelUp::
SetScrollLockState, On
SendInput {Left}
SetScrollLockState, Off
return

+WheelDown::
SetScrollLockState, On
SendInput {Right}
SetScrollLockState, Off
return

#if

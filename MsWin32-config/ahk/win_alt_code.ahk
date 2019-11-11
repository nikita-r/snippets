;·win_alt_code.ahk
#NoEnv
#KeyHistory 0
SendMode InputThenPlay

OnError("DoSomething")
DoSomething(exception) {
    MsgBox % "Error at Line " exception.Line
           . "`n" "* " RTrim(exception.Extra, " `r`n")
           . "`n" exception.Message
    return true
}

IsInteger(Var) {
  static Integer := "Integer"
  if Var is Integer
    return True
  return False
}


#if false

#z::
+#z::
CoordMode, Mouse, Screen
MouseGetPos, m_x, m_y
InputBox, N, Alt Code,,, -1, 100, m_x+24, m_y+8
if not ErrorLevel
  Send {asc %N%}
return

#if


#z::
+#z::

Gui, +AlwaysOnTop -Disabled -SysMenu +Owner
Gui, Font, s11, Constantia
Gui, Add, Edit, vN
Gui, Add, Button, default section, okay
Gui, Add, Button, default ys, cancel

CoordMode, Mouse, Screen
MouseGetPos, x, y
x+=24, y+=8
Gui, Show, X%x% Y%y%, alt code

return


ButtonOkay:
#IfWinActive ahk_class AutoHotkeyGUI
Enter::
NumpadEnter::
#If
Gui, Submit
Gui, Destroy
p := -1
StringGetPos, p, N, x
if (p=0)
    N := 0 . N
;if (ErrorLevel=0) and p=0
if (N ~= "i)^0x[a-f\d]+$")
    Send {U+%N%}
else if IsInteger(N)
    Send {asc %N%}
else
    MsgBox, 0x10,, Bad input: %N%
return


ButtonCancel:
#IfWinActive ahk_class AutoHotkeyGUI
Esc::
#If
Gui, Destroy
return


;ExitApp

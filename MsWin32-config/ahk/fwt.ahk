;·fwt.ahk


#w::
MouseGetPos,,, hwnd
DllCall("SetWindowPos"
, "UInt", hwnd, "UInt", 0
, "Int",  1914 ; x
, "Int",     1 ; y
, "Int", 0, "Int", 0
, "UInt", 0x0001) ; SWP_NOSIZE
return


SwpMon(WinID)
{
  WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %WinID%

  SysGet, MonA, Monitor, 1
  SysGet, MonB, Monitor, 2

  WinCenter := WinX + (WinWidth / 2)
  if (WinCenter > MonALeft and WinCenter < MonARight) {
    WinX := MonBLeft + (WinX - MonALeft)
  } else if (WinCenter > MonBLeft and WinCenter < MonBRight) {
    WinX := MonALeft + (WinX - MonBLeft)
  }

  WinMove, ahk_id %WinID%, , %WinX%, %WinY%
}

#s::
MouseGetPos,,, hwnd
SwpMon(hwnd)
return



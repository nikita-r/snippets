;·#w.ahk

FlashW(hWnd)
{
  WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %hWnd%

  if (WinX = -6 and WinY = 1) {
    WinX := 1920 + 6 - WinWidth
    WinY := 1
  } else {
    WinX := -6
    WinY := 1
  }

  WinMove, ahk_id %hWnd%, , %WinX%, %WinY%
}

#w::
MouseGetPos,,, hWnd
FlashW(hWnd)
return

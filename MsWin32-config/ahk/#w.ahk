;·#w.ahk

FlashW(hWnd)
{
  WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %hWnd%

  ScreensWidth := 1920
  FirstOff := -6 ; invisible 6px border around most windows

  Off := FirstOff
  if ((WinX - Off) < 0) {
    Off -= ScreensWidth
  } else {
    while ((WinX - Off) + (WinWidth + FirstOff) > ScreensWidth) {
      Off += ScreensWidth
    }
  }

  WinX -= Off
  if (WinX = 0 and WinY = 1) {
    WinX := ScreensWidth - (WinWidth + FirstOff)
    WinY := 1
  } else {
    WinX := 0
    WinY := 1
  }
  WinX += Off

  WinMove, ahk_id %hWnd%, , %WinX%, %WinY%
}

#w::
MouseGetPos,,, hWnd
FlashW(hWnd)
return

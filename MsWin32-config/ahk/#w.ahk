;·#w.ahk

FlashW(hWnd)
{
  WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %hWnd%

  ScreensWidth := 1920
  FirstOff := -7 ; invisible 7px border

  Off := FirstOff
  if ((WinX - Off) < 0) {
    Off -= ScreensWidth
  } else {
    while ((WinX - Off) > ScreensWidth) {
      Off += ScreensWidth
    }
  }

  WinX -= Off
  if (WinX = 1 and WinY = 1) {
    WinX := ScreensWidth - (WinWidth + FirstOff)
    WinY := 1
  } else {
    WinX := 1
    WinY := 1
  }
  WinX += Off

  WinMove, ahk_id %hWnd%, , %WinX%, %WinY%
}

#w::
MouseGetPos,,, hWnd
FlashW(hWnd)
return

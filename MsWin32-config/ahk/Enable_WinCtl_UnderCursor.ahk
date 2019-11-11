
~LButton::Enable_WinCtl_UnderCursor

Enable_WinCtl_UnderCursor() {
	MouseGetPos,,, WinHndl, CtlHndl, 2

	WinGet, Style, Style, ahk_id %WinHndl%
	if (Style & 0x8000000) { ; WS_DISABLED
		WinSet, Enable, , ahk_id %WinHndl%
	}

	WinGet, Style, Style, ahk_id %CtlHndl%
	if (Style & 0x8000000) { ; WS_DISABLED
		WinSet, Enable, , ahk_id %CtlHndl%
	}
}


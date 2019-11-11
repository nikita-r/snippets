; ActOnChromeUrl.ahk


#IfWinActive ahk_class Chrome_WidgetWin_1

!Left::
	RegExMatch(GetActiveBrowserUrl(), "O)^(?<Protocol>https?|ftp)://(?<Domain>(?:[\w-]+\.)+\w\w+)(?::(?<Port>\d+))?/?(?<Path>(?:[^:/?# ]*/?)+)(?:\?(?<Query>[^#]+)?)?(?:\#(?<Hash>.+)?)?$", oMatch)
	If (oMatch.Domain != "ra.moodys.com")
		SendInput {Browser_Back}
Return

#IfWinActive


GetActiveBrowserUrl() {
	WinGetClass, sClass, A
	Return GetBrowserUrl_Acc(sClass)
}

GetBrowserUrl_Acc(sClass) {
	global nWindow, accAddressBar
	If (nWindow != WinExist("ahk_class " sClass)) { ; will re-use accAddressBar if it is the same window
		nWindow := WinExist("ahk_class " sClass)
		accAddressBar := GetAddressBar(Acc_ObjectFromWindow(nWindow))
	}
	Try sUrl := accAddressBar.accValue(0)
	If (sUrl == "") {
		WinGet, nWindows, List, % "ahk_class " sClass
		If (nWindows > 1) {
			accAddressBar := GetAddressBar(Acc_ObjectFromWindow(Null))
			Try sUrl := accAddressBar.accValue(0)
		}
	}
	If (sUrl == "")
		nWindow := -1 ; forget the window if there is no URL
	Return sUrl
}

GetAddressBar(accObj) {
	Try If ((accObj.accRole(0) == 42) and IsUrl(accObj.accValue(0))) ; ? IsUrl("http://" accObj.accValue(0))
		Return accObj
	For nChild, accChild in Acc_Children(accObj)
		If IsObject(accAddressBar := GetAddressBar(accChild))
			Return accAddressBar
}

IsUrl(sUrl) {
	Return RegExMatch(sUrl, "^(?<Protocol>https?|ftp)://(?<Domain>(?:[\w-]+\.)+\w\w+)(?::(?<Port>\d+))?/?(?<Path>(?:[^:/?# ]*/?)+)(?:\?(?<Query>[^#]+)?)?(?:\#(?<Hash>.+)?)?$")
}


Acc_Init() {
	static h
	If Not h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}

Acc_ObjectFromWindow(hWnd, idObject = 0) {
	Acc_Init()
	If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	Return ComObjEnwrap(9,pacc,1)
}

Acc_Query(Acc) {
	Try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}

Acc_Children(Acc) {
	If ComObjType(Acc,"Name") != "IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	Else {
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren%
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
			Return Children.MaxIndex()?Children:
		} Else
			ErrorLevel := "AccessibleChildren DllCall Failed"
	}
}


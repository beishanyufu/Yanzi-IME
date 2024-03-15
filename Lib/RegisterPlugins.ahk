#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force
ListLines, Off
SendMode, Input
SetBatchLines,-1
OnExit, Exit
If !(A_Args[1]~="^\d+$")||!(A_Args[2]~="\{.+\}")
	ExitApp
Else If IsObject(YzPlugins)
	ObjRegisterActive(YzPlugins, A_Args[2])
Else
	ExitApp
SetTimer, scriptexit, 5000
Return

ObjRegisterActive(Object, CLSID, Flags:=0){
    static cookieJar := {}
    If (!CLSID) {
        If (cookie := cookieJar.Remove(Object)) != ""
            DllCall("oleaut32\RevokeActiveObject", "uInt", cookie, "Ptr", 0)
        Return
    }
    If cookieJar[Object]
        Throw Exception("Object is already registered", -1)
    VarSetCapacity(_clsid, 16, 0)
    If (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "Ptr", &_clsid)) < 0
        Throw Exception("Invalid CLSID", -1, CLSID)
    hr := DllCall("oleaut32\RegisterActiveObject"
        , "Ptr", &Object, "Ptr", &_clsid, "uInt", Flags, "uInt*", cookie
        , "uInt")
    If hr < 0
        Throw Exception(Format("Error 0x{:x}", hr), -1)
    cookieJar[Object] := cookie
}

scriptexit:
	Process, Exist, % A_Args[1]
	If !ErrorLevel
		ExitApp
Return

Exit:
	ObjRegisterActive(YzPlugins, "")
	ExitApp
Return

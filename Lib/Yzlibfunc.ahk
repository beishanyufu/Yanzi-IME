; 发送消息等待答复
SendMessage(Msg, wParam, lParam, WinTitle:="A", Control:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:=5000){
	SendMessage Msg, wParam, lParam, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%, Timeout
}
; 投递消息
PostMessage(Msg, wParam, lParam, WinTitle:="A", Control:="", WinText:="", ExcludeTitle:="", ExcludeText:=""){
	PostMessage Msg, wParam, lParam, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
; 激活指定的窗口
WinActivate(WinTitle, WinText:="", ExcludeTitle:="", ExcludeText:=""){
	WinActivate %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
; 对控件进行各种改变
Control(SubCommand, Value, Control, WinTitle:="A", WinText:="", ExcludeTitle:="", ExcludeText:=""){
	Control %SubCommand%, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
; 后台点击
ControlClick(Control_or_Pos, WinTitle:="A", WinText:="", WhichButton:="", ClickCount:="", Options:="", ExcludeTitle:="", ExcludeText:=""){
	ControlClick, %Control_or_Pos%, %WinTitle%, %WinText%, %WhichButton%, %ClickCount%, %Options%, %ExcludeTitle%, %ExcludeText%
}
ClickByAutomationId(AutomationID, WinTitle:="A", Control:="", WinText:="", ExcludeTitle:="", ExcludeText:=""){
	PostMessage 0x111, AutomationID, 0, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
; 对指定的窗口进行各种设置,置顶、透明、样式、到其他窗口底部
WinSet(SubCommand, Value, WinTitle:="A", WinText:="", ExcludeTitle:="", ExcludeText:=""){
	WinSet, %SubCommand%, %Value%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
; UI接口界面点击(兼容QT等界面)
AccClick(ChildPaths="", Child:=0, WinTitle="", Control:="", WinText="", ExcludeTitle="", ExcludeText="", ClickCount:=1){
	If (Control+0 ~= "^\d+$" && !(hwnd:=DllCall("IsWindow", "Ptr", Control)?Control:0)){
		Throw Exception("无效句柄", -1)
	} Else If (Control){
		ControlGet, hwnd, Hwnd,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
		If (!hwnd)
			Throw Exception("未找到目标控件", -1)
	} Else If !(hwnd:=WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
		Throw Exception("未找到目标窗口", -1)
	RegExMatch(Child, "(\D*)(\d*)", Child), Child2:=Child2?Child2:0
	Loop, Parse, ChildPaths, |
	{
		Acc:=Acc_Get("Object", A_LoopField, 0, "ahk_id" hwnd)
		Try role:=Acc_Role(Acc, Child2)
		If (role="invalid object" || role=""){
			Ret := "路径指向无效对象"
			Continue
		} Else If (Child1 != "" && Acc.accName(Child2) != Child1){
			Ret := "未找到目标元素"
			Continue
		}

		Try {
			If (Acc.accDefaultAction(Child2) = "")
				Throw
			Acc.accDoDefaultAction(Child2)
		} Catch
			Gosub AhkClick
		If (!Ret)
			Break
	}
	If (Ret)
		Throw Exception(Ret, -1)
	Return
	AhkClick:
		If (Acc.accState(Child2) & 0x8000)
			Throw Exception("目标不可见", -1)
		Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), Child2)
		x:=NumGet(x,0,"int"), y:=NumGet(y,0,"int"), w:=NumGet(w,0,"int"), h:=NumGet(h,0,"int")
		WinGetPos, x0, y0, , , ahk_id%hwnd%
		x-=x0, y-=y0
		If (x>=0 && y>=0){
			x+=w/2, y+=h/2
			Loop %ClickCount%
				ControlClick x%x% y%y%, ahk_id%hwnd%,,,, Pos NA
		} Else
			Throw Exception("点击目标不在可见区域", -1)
	Return
}
; 打开指定好友、群
qqchat(id, isgroup:=0, fuin:=""){
	If (isgroup){
		p := "tencent://groupwpa/?subcmd=all&param="
		o := "{""ExtParam"":{""appId"":""21""},""groupUin"":" . id . ",""visitor"":1}"
		Loop, Parse, o
			p .= Format("{1:02X}", Ord(A_LoopField))
	} Else
		p := "tencent://message/?uin=" . id
	If (fuin)
		p .= "&fuin=" fuin
	Run % p
}
; 读取文本文件，识别不含bom的utf8
FileRead(path,Line:=0){
	file:=FileOpen(path, "r"), len:=file.RawRead(sbin, 512), file.Close()
	If (NumGet(sbin, 0, "UChar")=0xFE&&NumGet(sbin, 1, "UChar")=0xFF){	; UTF16BE
		MsgBox, 16, 错误, 不支持UTF-16BE编码的文本
	} Else {
		If (NumGet(sbin, 0, "UChar")=0xFF&&NumGet(sbin, 1, "UChar")=0xFE){
			FileEncoding CP1200
		} Else If (NumGet(sbin, 0, "UChar")=0xEF&&NumGet(sbin, 1, "UChar")=0xBB&&NumGet(sbin, 2, "UChar")=0xBF){
			FileEncoding CP65001
		} Else {
			FileEncoding CP65001
			_start_:=0
			While (_start_<len){
				t:=NumGet(sbin, _start_, "UChar")
				If (t=0x0){
					FileEncoding CP1200
					Break
				} Else If (t<0x80){
					_start_++
				} Else If (t<0xC0){
					FileEncoding CP0
					Break
				} Else If (t<0xE0){
					If (_start_>=len-1)
						Break
					If (NumGet(sbin, _start_ + 1, "UChar") & 0xC0 != 0x80){
						FileEncoding CP0
						Break
					}
					_start_+=2
				} Else If (t<0xF0){
					If (_start_>=len-2)
						Break
					If ((NumGet(sbin, _start_ + 1, "UChar") & 0xC0 != 0x80) || (NumGet(sbin, _start_ + 2, "UChar") & 0xC0 != 0x80)){
						FileEncoding CP0
						Break
					}
					_start_+=3
				} Else If (t<0xF8){
					If (_start_>=len-3)
						Break
					If ((NumGet(sbin, _start_ + 1, "UChar") & 0xC0 != 0x80) || (NumGet(sbin, _start_ + 2, "UChar") & 0xC0 != 0x80)
					|| (NumGet(sbin, _start_ + 3, "UChar") & 0xC0 != 0x80)){
						FileEncoding CP0
						Break
					}
					_start_+=4
				} Else If (t<0xFC){
					If (_start_>=len-4)
						Break
					If ((NumGet(sbin, _start_ + 1, "UChar") & 0xC0 != 0x80) || (NumGet(sbin, _start_ + 2, "UChar") & 0xC0 != 0x80)
					|| (NumGet(sbin, _start_ + 3, "UChar") & 0xC0 != 0x80) || (NumGet(sbin, _start_ + 4, "UChar") & 0xC0 != 0x80)){
						FileEncoding CP0
						Break
					}
					_start_+=5
				} Else {
					If (_start_>=len-5)
						Break
					If ((NumGet(sbin, _start_ + 1, "UChar") & 0xC0 != 0x80) || (NumGet(sbin, _start_ + 2, "UChar") & 0xC0 != 0x80)
						|| (NumGet(sbin, _start_ + 3, "UChar") & 0xC0 != 0x80) || (NumGet(sbin, _start_ + 4, "UChar") & 0xC0 != 0x80)
					|| (NumGet(sbin, _start_ + 5, "UChar") & 0xC0 != 0x80)){
						FileEncoding CP0
						Break
					}
					_start_+=6
				}
			}
		}
		If (Line){
			If (Line<0){
				tt:="", s:=""
				Loop % (-Line)
				{
					FileReadLine, s, %path%, %A_Index%
					tt .= s "`n"
				}
			} Else
			FileReadLine, tt, %path%, %Line%
		} Else
		FileRead, tt, %path%
		Return tt
	}
}
; 获取文件大小
FileGetSize(file){
	FileGetSize, size, %file%
	Return size
}
; 下载
UrlDownloadToFile(URL, FilePath){
	ComObjError(1)
	If RegExMatch(LTrim(FilePath, "\"), "(.*\\)?([^\\]+)$", FilePath){
		If (FilePath1&&!FileExist(FilePath1)){
			FileCreateDir, %FilePath1%
			If ErrorLevel
				Return 0
		}
		WebRequest:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("GET", URL, 1)
		Try {
			WebRequest.Send()
			WebRequest.WaitForResponse(-1)
		} Catch
			Return 0
		If !WebRequest.ResponseBody()
			Return 0
		ADO:=ComObjCreate("adodb.stream"), ADO.Type:=1, ADO.Mode:=3, ADO.Open()
		Try ADO.Write(WebRequest.ResponseBody())
		Try ADO.SaveToFile(FilePath,2)
		ADO.Close(), WebRequest:=ADO:=""
		Return 1
	} Else
	Return 0
}
; Base64解码
Base64toStr(sString){
	DllCall("crypt32\CryptStringToBinary", "str", sString, "Uint", 0, "Uint", 1, "ptr", 0, "Uint*", nSize, "ptr", 0, "ptr", 0)
	VarSetCapacity(sbin, nSize)
	DllCall("crypt32\CryptStringToBinary", "str", sString, "Uint", 0, "Uint", 1, "ptr", &sbin, "Uint*", nSize, "ptr", 0, "ptr", 0)
	Return StrGet(&sbin, "utf-8")
}
Base64toBin(sString, ByRef sbin){
	DllCall("crypt32\CryptStringToBinary", "str", sString, "Uint", 0, "Uint", 1, "ptr", 0, "Uint*", Bytes, "ptr", 0, "ptr", 0)
	VarSetCapacity(sbin, Bytes)
	DllCall("crypt32\CryptStringToBinary", "str", sString, "Uint", 0, "Uint", 1, "ptr", &sbin, "Uint*", Bytes, "ptr", 0, "ptr", 0)
	Return Bytes
}
; Base64编码
StrToBase64(sString, Flags:=0x40000001){
	sStrlen:=StrPutVar(sString, sbin, "utf-8")
	Return BinToBase64(&sbin, sStrlen, Flags)
}
BinToBase64(binpointer, bytes, Flags:=0x40000001){
	DllCall("crypt32\CryptBinaryToString", "Ptr", binpointer, "Uint", bytes, "Uint", Flags, "Ptr", 0, "Uint*", nSize)
	VarSetCapacity(sString, nSize*2)
	DllCall("crypt32\CryptBinaryToString", "Ptr", binpointer, "Uint", bytes, "Uint", Flags, "str", sString, "Uint*", nSize)
	Return StrGet(&sString, (A_IsUnicode ? "utf-16" : "cp0"))
}
; 字符集转码
StrPutVar(sVar, ByRef sbin, encoding){
	VarSetCapacity(sbin, StrPut(sVar, encoding)* ((encoding="utf-16"||encoding="cp1200") ? 2 : 1))
	Return (StrPut(sVar, &sbin, encoding) -1)* ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
}
; 下载到变量
SendRequest(url, Method="GET", postData=""){ 
	static WebRequest:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.SetTimeouts(100, 100, 100, 100)
	WebRequest.Open(Method, url, (Method="POST" ? 1 : 0))
	WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
	WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
	Try WebRequest.Send(postData), WebRequest.WaitForResponse(-1)
	Try Return WebRequest.ResponseText
}
; 运行JS脚本
JScript(update := false){
	static doc, eval
	if (!doc || update) {
		ComObjError(1)
		Script := getJSscript()
		doc:=ComObjCreate("htmlfile"), doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'><body><script>" Script "</script></body>")
		Return eval := ObjBindMethod(doc.parentWindow, "eval")
	}
	Return eval
}
; 7z解压
7Zip(source, dest, wait:=1){
	If !FileExist(A_ScriptDir "\Lib\7za.exe")
		UrlDownloadToFile("https://gitee.com/orz707/Yzime/raw/zip/7za.exe", A_ScriptDir "\Lib\7za.exe")
	If (wait)
		RunWait %A_ScriptDir%\Lib\7za.exe x "%source%" -o"%dest%" -aoa, , Hide
	Else
		Run %A_ScriptDir%\Lib\7za.exe x "%source%" -o"%dest%" -aoa, , Hide
}

;==================================================
; Acc.ahk - thanks Sean, jethrow, jeeswg, teadrinker
Acc_Get(Cmd, ChildPath="", ChildID:=0, WinTitle="", WinText="", ExcludeTitle="", ExcludeText=""){
	static properties := {Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut"}
	AccObj := IsObject(WinTitle) ? WinTitle
		: Acc_ObjectFromWindow(WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0)
	If ComObjType(AccObj, "Name") != "IAccessible"
		ErrorLevel := "Could not access an IAccessible Object"
	Else
	{
		StringReplace, ChildPath, ChildPath, _, %A_Space%, All
		AccError:=Acc_Error(), Acc_Error(true)
		Loop Parse, ChildPath, ., %A_Space%
			Try
			{
				If A_LoopField is digit
					Children:=Acc_Children(AccObj), m2:=A_LoopField ; mimic "m2" output In Else-statement
				Else
					RegExMatch(A_LoopField, "(\D*)(\d*)", m)
				, Children:=Acc_ChildrenByRole(AccObj, m1), m2:=(m2?m2:1)
				If Not Children.HasKey(m2)
					Throw
				AccObj := Children[m2]
			}
			Catch
			{
				ErrorLevel:="Cannot access ChildPath Item #" A_Index " -> " A_LoopField, Acc_Error(AccError)
				If Acc_Error()
					Throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
				Return
			}
		Acc_Error(AccError)
		StringReplace, Cmd, Cmd, %A_Space%, , All
		properties.HasKey(Cmd)? Cmd:=properties[Cmd]:""
		Try
		{
			If (Cmd = "Location")
				AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0)
			, ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
			, ret_val := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int")
			. " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
			Else If (Cmd = "Object")
				ret_val := AccObj
			Else If Cmd In Role,State
				ret_val := Acc_%Cmd%(AccObj, ChildID+0)
			Else If Cmd In ChildCount,Selection,Focus
				ret_val := AccObj["acc" Cmd]
			Else
				ret_val := AccObj["acc" Cmd](ChildID+0)
		}
		Catch
		{
			ErrorLevel := """" Cmd """ Cmd Not Implemented"
			If Acc_Error()
				Throw Exception("Cmd Not Implemented", -1, Cmd)
			Return
		}
		Return ret_val, ErrorLevel:=0
	}
	If Acc_Error()
		Throw Exception(ErrorLevel,-1)
}

Acc_GetAccPath(Acc){
	Static DesktopHwnd := DllCall("User32.dll\GetDesktopWindow", "ptr")
	arr := []
	ComObjError(False)
	While Hwnd := Acc_WindowFromObject(Parent := Acc_Parent(Acc)) { 
		If (DesktopHwnd != Hwnd)
			t1 := GetEnumIndex(Acc)
		If t1 = -1
			Return arr := ""
		If (PrHwnd != "" && Hwnd != PrHwnd) {
			PrHwnd := Format("0x{:06x}", PrHwnd)
			WinGetClass, WinClass, ahk_id %PrHwnd%
			WinGet, ProcessName, ProcessName, ahk_id %PrHwnd%
			arr.InsertAt(1, {Hwnd: PrHwnd, Path: SubStr(t2, 1, -1), WinClass: WinClass, ProcessName: ProcessName})
		}
		If (t1 = "" || Hwnd = DesktopHwnd)
			Break
		t2 := t1 "." t2
		PrHwnd := Hwnd
		Acc := Parent
	}
	ComObjError(True)
	Return {AccObj: Acc, Hwnd: arr[1].Hwnd, Path: arr[1].Path}
}

GetEnumIndex(Acc) {	
	For Each, child in Acc_Children(Acc_Parent(Acc))
	{
		If IsObject(child) 
		&& (Acc_Location(child) = Acc_Location(Acc))
		&& (child.accDefaultAction(0) = Acc.accDefaultAction(0)) 	
		&& (child.accDescription(0) = Acc.accDescription(0)) 	
		&& (child.accHelp(0) = Acc.accHelp(0)) 	
		&& (child.accKeyboardShortcut(0) = Acc.accKeyboardShortcut(0)) 
		
		&& (child.accChildCount = Acc.accChildCount) 
		&& (child.accName(0) = Acc.accName(0)) 	
		&& (child.accRole(0) = Acc.accRole(0)) 	
		&& (child.accState(0) = Acc.accState(0)) 
		&& (child.accValue(0) = Acc.accValue(0))
			Return A_Index
	}
}

Acc_Location(Acc, ChildId=0){
	Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
	Catch
		Return
	Return {x:NumGet(x,0,"int"), y:NumGet(y,0,"int"), w:NumGet(w,0,"int"), h:NumGet(h,0,"int")
		, pos:"x" NumGet(x,0,"int")" y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")}
}

Acc_Parent(Acc){
	Try parent:=Acc.accParent
	Return parent?Acc_Query(parent):""
}

Acc_Child(Acc, ChildId=0){
	Try child:=Acc.accChild(ChildId)
	Return child?Acc_Query(child):""
}

Acc_Init(){
	Static h
	If (!h && !(h:=DllCall("GetModuleHandle", "Str", "oleacc", "Ptr")))
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}

Acc_WindowFromObject(pacc){
	Acc_Init()
	If (DllCall("oleacc\WindowFromAccessibleObject", "Ptr"
		, IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0)
		Return hWnd
}

Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild){
	Acc_Init()
	If (DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd
		, "UInt", idObject, "UInt", idChild, "Ptr*", pacc, "Ptr"
		, VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0)
		Return ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = ""){
	Acc_Init()
	If (DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""
		? 0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc
		, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0)
		Return ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromWindow(hWnd, idObject := -4){
	Acc_Init()
	If DllCall("oleacc\AccessibleObjectFromWindow"
		, "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", (VarSetCapacity(IID,16)
	+NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64")
	+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,IID,8,"Int64"))*0
	+&IID, "Ptr*", pacc)=0
	Return ComObjEnwrap(9,pacc,1)
}

Acc_Children(Acc){
	If (ComObjType(Acc,"Name") != "IAccessible")
		ErrorLevel := "Invalid IAccessible Object"
	Else
	{
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0
			, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0
		+&varChildren, "Int*",cChildren)=0
		{
			Loop %cChildren%
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i)
			, Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child)
			, NumGet(varChildren,i-8)=9?ObjRelease(child):""
			Return Children.MaxIndex()?Children:""
		} Else
		ErrorLevel := "AccessibleChildren DllCall Failed"
	}
	If Acc_Error()
		Throw Exception(ErrorLevel,-1)
}

Acc_ChildrenByRole(Acc, Role){
	If (ComObjType(Acc,"Name")!="IAccessible")
		ErrorLevel := "Invalid IAccessible Object"
	Else
	{
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc)
			, "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren
		, cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0
		{
			Loop %cChildren%
			{
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i)
				If NumGet(varChildren,i-8)=9
					AccChild:=Acc_Query(child), ObjRelease(child)
				, Acc_Role(AccChild)=Role?Children.Insert(AccChild):""
				Else
					Acc_Role(Acc, child)=Role?Children.Insert(child):""
			}
			Return Children.MaxIndex()?Children:"", ErrorLevel:=0
		} Else
		ErrorLevel := "AccessibleChildren DllCall Failed"
	}
	If Acc_Error()
		Throw Exception(ErrorLevel,-1)
}

Acc_Query(Acc){
	Try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}

Acc_Role(Acc, ChildId=0){
	Try Return ComObjType(Acc,"Name")="IAccessible"
		? Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
}
	
Acc_State(Acc, ChildId=0){
	Try Return ComObjType(Acc,"Name")="IAccessible"
		? Acc_GetStateText(Acc.accState(ChildId)):"invalid object"
}
	
Acc_GetRoleText(nRole){
	Acc_Init()
	nSize := DllCall("oleacc\GetRoleText", "Uint", nRole, "Ptr", 0, "Uint", 0)
	VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetRoleText", "Uint", nRole, "str", sRole, "Uint", nSize+1)
	Return sRole
}

Acc_GetStateText(nState){
	Acc_Init()
	nSize := DllCall("oleacc\GetStateText", "Uint", nState, "Ptr", 0, "Uint", 0)
	VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetStateText", "Uint", nState, "str", sState, "Uint", nSize+1)
	Return sState
}

Acc_Error(p=""){
	static setting:=0
	Return p=""?setting:setting:=p
}
#Persistent
#NoTrayIcon
#SingleInstance, Force
If (InStr(A_AhkPath, "_UIA.exe")||A_Args[1]="")
	ExitApp
Else
	SetTimer, scriptexit, 10000
OnMessage(0x4a, "Receive_WM_COPYDATA")
EmptyMem()
Return
scriptexit(){
	Process, Exist, % A_Args[1]
	If !ErrorLevel
		ExitApp
}
EmptyMem(PID="AHK Rocks"){
	pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
	h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
}
RunFromQuery(exeName, params:=""){
	static ev:=0
	If (!ev){
		; If (!FileExist(A_ScriptDir "\..\Dll_x" (A_PtrSize=4?"86":"64") "\Everything.dll"))
		; 	UrlDownloadToFile("https://gitee.com/orz707/Yzime/raw/master/Lib/Dll_x" (A_PtrSize=4?"86":"64") "/Everything.dll", A_ScriptDir "\..\Dll_x" (A_PtrSize=4?"86":"64") "\Everything.dll")
		Try ev := new everything(A_ScriptDir "\..\Dll_x" (A_PtrSize=4?"86":"64") "\Everything.dll")
		Catch
			ExitApp
	}
	str := exeName . " !C:\Windows* !?:\*cache* !?:\*log* !?:\$RECYCLE.BIN* !?:\*scoop\shims*"
	EverythingPath := ""
	;查询字串设为全字匹配
	ev.SetMatchWholeWord(true)
	refind:
	ev.SetSearch(str)
	;执行搜索
	ev.Query()
	exePath := ev.GetResultFullPathName(0)
	SplitPath, exePath, , OutDir
	If (exePath=""){
		evhasrun:=0
		For process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name like 'everything%'"){
			evhasrun:=1
			Break
		}
		If (!evhasrun){
			Try {
				Run %EverythingPath%, , , PID
				WinWait, ahk_pid%PID%, , 2
				If (!ErrorLevel&&PID)
					Goto refind
				Else {
					MsgBox, 64, 提示, Everything服务未启动！
					Return
				}
			}
		}
	}
	Ret:=Old:=0
	If (A_PtrSize=4)
		Ret := DllCall("Kernel32.dll\Wow64DisableWow64FsRedirection", "Ptr*", Old)
	Try	Run, % """" exePath """ " params, %OutDir%
	Catch errinfo {
		ToolTip % exePath "`n" errinfo.Extra, A_CaretX + 10 , A_CaretY + 20
		SetTimer, ToolTipOff, -2000
	}
	If (Ret)
		DllCall("Kernel32.dll\Wow64RevertWow64FsRedirection", "Ptr", Old)
	Return
	ToolTipOff:
		ToolTip
	Return
}
Receive_WM_COPYDATA(wParam, lParam){
	static CopyOfData
	StringAddress := NumGet(lParam + 2*A_PtrSize)  ; 获取 CopyDataStruct 的 lpData 成员.
	CopyOfData := StrGet(StringAddress)  ; 从结构中复制字符串.
	SetTimer RunFromQuery, -10
	Return true  ; 返回 1 (true) 是回复此消息的传统方式.
	RunFromQuery:
		t:=StrSplit(CopyOfData, "`t", "`t ")
		RunFromQuery(t[1],t[2]), CopyOfData:=""
	Return
}
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
Class Everything
{
	__New(DllPath){
		this.hModule := DllCall("LoadLibrary", "Str", this.DllPath:=DllPath)
	}
	__Get(aName){
	}
	__Set(aName, aValue){
	}
	__Delete(){
		DllCall("FreeLibrary", "UInt", this.hModule) 
		Return
	}
	SetSearch(aValue){
		this.eSearch := aValue
		DllCall(this.DllPath "\Everything_SetSearch","Str",aValue)
		Return
	}
	;设置全字匹配
	SetMatchWholeWord(aValue){
		this.eMatchWholeWord := aValue
		DllCall(this.DllPath "\Everything_SetMatchWholeWord","Int",aValue)
		Return
	}
	;执行搜索动作
	Query(aValue=1){
		DllCall(this.DllPath "\Everything_Query","Int",aValue)
		Return
	}
	;返回匹配总数
	GetTotResults(){
		Return DllCall(this.DllPath "\Everything_GetTotResults")
	}
	;返回文件名
	GetResultFileName(aValue){
		Return strget(DllCall(this.DllPath "\Everything_GetResultFileName","Int",aValue))
	}
	;返回文件全路径
	GetResultFullPathName(aValue,cValue=128){
		VarSetCapacity(bValue,cValue*2)
		DllCall(this.DllPath "\Everything_GetResultFullPathName","Int",aValue,"Str",bValue,"Int",cValue)
		Return bValue
	}
}
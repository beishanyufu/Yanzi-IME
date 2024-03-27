; ##################################################################################################################################################################
; # 声明：此文件基于开源仓库 <https://gitee.com/orz707/Yzime> (Commit:d1d0d9b15062de7381d1e7649693930c34fca53d) 
; # 中的同名文件修改而来，并使用相同的开源许可 GPL-2.0 进行开源，具体的权利、义务和免责条款可查看根目录下的 LICENSE 文件
; # 修改者：北山愚夫
; # 修改时间：2024年3月15日 
; ##################################################################################################################################################################

srf_init:
	;读取配置	
	NumPut(VarSetCapacity(SystemDefaultFont, A_IsUnicode ? 504 : 344, 0), SystemDefaultFont, 0, "UInt")
	DllCall("SystemParametersInfo", "UInt", 0x29, "UInt", 0, "Ptr", &SystemDefaultFont, "UInt", 0)
	global srf_default_value, Gbuffer, DataPath:=A_ScriptDir "\Data\", Yzimeini:=class_EasyIni(DataPath "Yzime.ini"), DllFolder:=A_ScriptDir "\Lib\Dll_" (A_PtrSize=4?"x86":"x64"), TSFMem:=new MemMap("WXppbWVUU0ZNRU0=")
		, AhkPath:=A_IsCompiled?A_ScriptDir "\Yzime.exe":A_AhkPath, YzimePID:=DllCall("GetCurrentProcessId"), SystemDefaultFont:=StrGet(&SystemDefaultFont + 52)
	srf_default_value:={Settings:{Startingup:0, Autoupdatefg:0, UIAccess:0, CloudInput:0, DebugLevel:1, fuzhuma:0, SendDelay:0, ClipHistory:0, Imagine:0, MemoryDB:0, Settingsbak:"", MouseCross:0, dwxg:0
		, Magicstring:0, Superrun:0, Wordfrequency:1, fixedword:0, Learning:0, Inputscheme:"pinyin", chaojijp:0, Traditional:0, Showquanpin:0, mhy:"0000000000", fyfz:0, bmhg:0, dgsp:0, FirstNotSave:0
		, lspy:0, simasp:1, wumaqc:1, wumasp:1, Different:1, IMEmode:2, ClipWindows:"", IMECnWindows:"", IMEEnWindows:"", EnSymbol:0, SaveCloud:0, ShowCdode:0, Singleword:0, zigen:0, TSFmode:0
	, decfre:0, Tofirst:0, Useless:0, tfuzhuma:1, ShowFZM:0, FirstZi:1, ConnectIMEandCursor:1, ShowLogo:1}
		, Func:{CustomFuncName:"{""fanyi"":""fy"",""label"":""l"",""magic"":""s"",""mode"":""m"",""run"":""r"",""scheme"":""sc"",""soso"":""ss""}"}
		, GuiStyle:{TextFont:SystemDefaultFont, SymbolFont:"Segoe UI Symbol", FontBold:0, FontSize:20, BorderColor:"F9ECE2", CodeColor:"0080FF", TextColor:"0080FF"
		, BackgroundColor:"FFFFFF", ListNum:5, Textdirection:"Horizontal", FocusBackColor:"FFFFFF", FocusColor:"FF8000"
		, LogoSize:8, ToolTipStyle:(A_OSVersion="WIN_XP"?1:2), Lockedposition:0}
		, Hotkey:{Double:0, Switch:"Shift", Enterfg:2, Escfg:1, Shiftfg:3, fanyefg:",.", 23hx:"", ycdzfg:""}
		, DBFile:{main:"Data\ciku.db", extend:"Data\ciku_extend.db"}
		, Version:{Version:"1.0.0"}}
	LoadIni()
	EnableUIAccess()
	DownloadRes()
	DllCall("ChangeWindowMessageFilterEx", "Ptr", A_ScriptHwnd, "UInt", 0x444, "UInt", 1, "Ptr", 0)
	DllCall("ChangeWindowMessageFilter", "Uint", 0x49, "Uint", 1), DllCall("ChangeWindowMessageFilter", "Uint", 0x233, "Uint", 1)
	srf_inputing:=srf_mode:=pToken_:=Eventhook:=0, GUIFont:=SystemDefaultFont, TickCount(0, 1), TickCount(0, 2)
	Eventhook:=DllCall("SetWinEventHook", "UInt", 0x03, "UInt", 0x17, "Ptr", 0, "Ptr", _:=RegisterCallback("_EventProc"), "UInt", 0, "UInt", 0, "UInt", 0)
	valueindex:=Traditional?5:2, SendDelaymode:=(SendDelay?"{Text}{Delay," SendDelay*10 ",0}":""), localpos:=1, srf_mode:=!!(IMEmode-1)
	waitnum:=Learnfg:=0, ClipSaved:="", MethodTable:={sanma:"sanma",lianda:"lianda"}, AppIMEtable:=[], history_field_array:=[]
	pinyinec:={pinyin:"全拼",dnsp:"大牛双拼",xhsp:"小鹤双拼",zrmsp:"自然码双拼",abcsp:"ABC双拼",sgsp:"搜狗双拼",wrsp:"微软双拼",jjsp:"加加双拼"}, pinyince:=[], customspjm:=[]
	Function_for_select:=[], save_field_array:=[], SQL_buffer:=[], srf_Plugins:=[], srf_last_input:=[], srf_Custom_Func:=[], srf_for_select_obj:=[], srf_all_input_:=[], custommhy:=[]
	Gosub TRAYMENU
	Gosub LoadLogo
	_EventProc(0, 3, WinExist("A"))
	Gosub LoadDB
	ChangeDB()
	Gosub module_functions
	Gosub houxuankuangguicreate
	Gosub Registrationhotkey
	#Include *i Data\usercustoms.ahk
	_init_:
	Try srf_Custom_Func:=JSON.Load(CustomFuncName)
	shurulei:=MethodTable[Inputscheme]?MethodTable[Inputscheme]:Inputscheme~="sp$|pinyin"?"pinyin":"xingma", pinyinlist:=""
	setmohuyingobj()
	Gosub Registrationfuncandlabel
	For Key,Value In customspjm
		pinyinec[Key]:=customspjm[Key,"1"], pinyince[customspjm[Key,"1"]]:=Key
	For Key,Value In pinyinec
		pinyince[Value]:=Key, pinyinlist .= "|" Value
	If (fuzhuma||tfuzhuma)	; 载入辅助码
		Gosub Loadfuzhuma
	If Autoupdatefg
		SetTimer, srfAutoupdatefg, -10
	If A_Args[1]
		Gosub help
	JScript()
	If (ConnectIMEandCursor){
		DirectIMEandCursor(srf_mode)
		OnClipboardChange("CheckClipboard",-1)
	}
	Else{
		OnClipboardChange("CheckClipboard",0)
	}
Return
DownloadRes(){
	global
	local ver
	; If (!FileExist(DataPath "Yzime.icl")){
	; 	Progress, B2 ZH-1 ZW-1 FS12, 正在下载图标库，请稍后...
	; 	ZIPDownloadToFile("https://gitee.com/orz707/Yzime/raw/zip/Yzimeicl.7z", DataPath "Yzimeicl.7z")
	; 	Progress, Off
	; }
	; If !FileExist(DllFolder "\SQLite3.dll"){
	; 	Progress, B2 ZH-1 ZW-1 FS12, 正在下载SQLite3.dll，请稍后...
	; 	If !ZIPDownloadToFile("https://gitee.com/orz707/Yzime/raw/zip/Dll_x" (A_PtrSize=4?"86":"64") ".7z",A_ScriptDir "\Lib\Dll_x" (A_PtrSize=4?"86":"64") "\Dll.7z"){
	; 		Progress, Off
	; 		MsgBox, 16, 错误, SQLite3.dll下载失败！`n请手动下载后放在%DllFolder%。
	; 		ExitApp
	; 	}
	; 	Progress, Off
	; }
	; If (!FileExist(A_ScriptDir "\Lib\tools\EnableUIAccess.ahk"))
	; 	ZIPDownloadToFile("https://gitee.com/orz707/Yzime/raw/zip/tools.7z", A_ScriptDir "\Lib\tools.7z")
	TSFmode:=(DllCall(A_ScriptDir "\tsf\Yzime" (A_PtrSize=8?"64":"") ".dll\IsYzimeInstall")=1)
	; If (TSFmode:=(DllCall(A_ScriptDir "\tsf\Yzime" (A_PtrSize=8?"64":"") ".dll\IsYzimeInstall")=1)){
	; 	switch UpdateTSF("2.0.5.0")
	; 	{
	; 	case 1:
	; 		TrayTip, 影子输入法, % "TSF更新完成需注销后生效！", 3
	; 	case 0:
	; 		MsgBox, 16, 错误, 更新TSF失败请手动下载！
	; 	}
	; }
	FileCreateDir %A_Temp%\Yzime
	; Loop Files, %A_ScriptDir%\tsf\*.old
	; 	FileDelete %A_LoopFilePath%
	refindckdb:
	If (!FileExist(main)){
		If (!FileExist("ciku_demo.db")){
			Run https://wwi.lanzoui.com/id81bpi
			Sleep 1000
			MsgBox 50, 提示, 未找到词库！`n请前往下载或继续？
			IfMsgBox Retry
				Goto refindckdb
			IfMsgBox Abort
				ExitApp
		}
		If (FileExist("ciku_demo.db")){
			FileCopy, ciku_demo.db, %main%
			If (ErrorLevel){
				Try	{
					If A_IsCompiled
						Run *RunAs "%A_ScriptFullPath%" /restart
					Else
						Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
				}
				ExitApp
			}
		}
		SetTimer DBinit, -1000
	}
	Return
	DBinit:
		Progress, B2 ZH-1 ZW-1 FS12, 词库初始化。。。
		DB.GetTable("SELECT name FROM sqlite_master WHERE type='table' AND name NOT IN ('sqlite_sequence','hebing','Cliphistory')",Result)
		Loop % Result.RowCount
			DB.Exec("CREATE INDEX IF NOT EXISTS ""sy_" Result.Rows[A_Index,1] """ ON """ Result.Rows[A_Index,1] """ (""" (Result.Rows[A_Index,1]="pinyin"?"jp":"key") """);")
		Progress, Off
		Gosub Help
		; MsgBox, 64, 提示, 词库、配置文件在Data文件夹，手动更新时可直接替换该文件夹迁移配置！`n输入流畅程度取决于硬盘读写速度，如遇到输入卡顿的现象，可尝试开启内存数据库选项`n或关闭自学习和调频选项！
	Return
}
_EventProc(phook, Msg, Hwnd){
	global YzimePID, AppIMEtable, Different, srf_mode, IMEmode, srf_inputing, SendDelay
		, SendDelaymode, IMEEnWindows, IMECnWindows, ClipWindows, TSFmode, curwininfo
	static htype:=0, lastexe, lastmode:=-1, firstEnterVSCode:=1
	If (A_IsSuspended || (Msg = 3 && hwnd != WinExist("A")))
		Return
	if (Msg = 3) {
		if (TSFmode && curwininfo.tick = 0 && curwininfo.hwnd)
			WM_TSFMSG(404, 0)
		curwininfo := {hwnd: Hwnd, tick: A_TickCount}
	}
	If (msg = 3 && firstEnterVSCode && WinActive("Visual Studio Code")) {
		SetTimer, _DirectIMEandCursor, -200
		firstEnterVSCode:=0
	}
	Switch Msg
	{
	Case 0x3, 0x17:				; EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_MINIMIZEEND
		If (lastmode!=-1)
			Return
		If (Different){
			If (Msg=3&&lastexe)
				cleanappimetable(lastexe)
			SetTimer detectwindows, -10
		} Else If (srf_mode!=IMEmode-1)
			Gosub Switchstate
		Else 
			DirectIMEandCursor(srf_mode)
		If (!srf_inputing){
			SetTimer, _SetYzLogo, -50
			SetTimer, ToolTipInputStatus, -50
		}
	Case 0x16:
		If (Different)
			SetTimer detectwindows, -20
	Case 0x6:	; EVENT_SYSTEM_MENUPOPUPSTART
		If (lastmode:=srf_mode){
			WinGetClass cl, ahk_id%Hwnd%
			If (cl~="[;\-\[\]]")
				Return lastmode:=-1
			SetYzLogo(srf_mode:=0, 0)
			If (srf_inputing)
				Gosub srf_value_off
		}
	Case 0x7:	; EVENT_SYSTEM_MENUPOPUPEND
		If (lastmode>-1)
			SetYzLogo(srf_mode:=lastmode, 0), lastmode:=-1
	}
	Return
	detectwindows:
		WinGet, activeexe, ProcessName, A
		WinGetClass, activeclass, A
		SendDelaymode:=(SendDelay?"{Text}{Delay," SendDelay*10 ",0}":"")
		Switch (checkactivewindow(htype,activeexe,activeclass)^srf_mode){
			Case 1:
				If (!srf_inputing)
					Gosub Switchstate
			Case -2,-1:
				If (AppIMEtable[activeexe]=""){
					AppIMEtable[activeexe]:=IMEmode-1
					If (!srf_inputing&&srf_mode!=IMEmode-1)
						Gosub Switchstate
				} Else If (!srf_inputing&&AppIMEtable[activeexe]!=srf_mode)
					Gosub Switchstate
			Case -4,-3:
				SendDelaymode:="{Fast}"
		}
			If (htype=-1&&srf_inputing)
				Gosub Switchstate
		lastexe:=activeexe
	Return
	detectcaret:
		If (!A_IsSuspended)
			Return
		If (GetCaretPos().t!="Mouse")
			SendInput {vke0}
		Else
			SetTimer detectcaret, -100
	Return
}

checkactivewindow(ByRef type,arr*){
	local
	global IMECnWindows,IMEEnWindows,ClipWindows
	If (IMEEnWindows)
		For Key,Value In arr
			If Value In %IMEEnWindows%
				Return 0, type:=Key
	If (arr[2]~="^(#\d+|Edit)"){
		ControlGetFocus, curCtrl, A
		If !(curCtrl~="i)Edit")
			Return 0, type:=-1
	} Else If (arr[1]="mstsc.exe"){
		Gosub srfsuspend
		Return 0, type:=-1
	}

	If (ClipWindows)
		For Key,Value In arr
			If Value In %ClipWindows%
				Return -3, type:=Key
	If (IMECnWindows)
		For Key,Value In arr
			If Value In %IMECnWindows%
				Return 1, type:=Key
	Return -1, type:=0
}
cleanappimetable(exe){
	global AppIMEtable
	static history:=""
	If history&&!WinExist("ahk_exe" history)
		AppIMEtable.Delete(history)
	history:=exe
}
ChangeDB(){
	local
	global DB
	DB.GetTable("SELECT 1 FROM sqlite_master WHERE type='table' AND tbl_name='pinyin' AND NOT instr(sql,'jp')", Result)
	If (Result.Rows[1,1]){
		MsgBox, 308, 词库调整, 本次更新将调整pinyin词库结构，优化文件占用空间，如有重要信息，请注意备份词库！`n是否继续？
		IfMsgBox, No
			ExitApp
		Progress, B2 ZH-1 ZW-1 FS12, 调整词库中，请稍后...
		DB.Exec("BEGIN TRANSACTION;")
		DB.Exec("DROP TABLE IF EXISTS 'main'.'hebing';")
		DB.Exec("CREATE TABLE 'main'.'hebing' (""jp"" TEXT,""Key"" TEXT,""Value"" TEXT,""weight"" INTEGER DEFAULT 0);")
		DB.Exec("INSERT INTO 'main'.'hebing' SELECT szm(Key),Key,Value,max(weight) FROM 'main'.'pinyin' GROUP by Key,Value ORDER by ROWID;")
		DB.Exec("DROP TABLE 'main'.'pinyin';ALTER TABLE 'main'.'hebing' RENAME TO 'pinyin';")
		DB.Exec("CREATE INDEX 'main'.'sy_pinyin' ON 'pinyin' ('jp');")
		DB.Exec("DROP TABLE IF EXISTS 'main'.'jianpin';")
		DB.Exec("COMMIT TRANSACTION;")
		DB.Exec("VACUUM")
		Progress, Off
		MsgBox 调整完成
	}
	DB.GetTable("SELECT tbl_name,count(*) as n FROM sqlite_master WHERE name!='sqlite_sequence' GROUP by tbl_name HAVING n=1",Result)
	If (Result.RowCount){
		Loop % Result.RowCount
			DB.Exec("CREATE INDEX ""sy_" Result.Rows[A_Index,1] """ ON """ Result.Rows[A_Index,1] """ (""" (Result.Rows[A_Index,1]="pinyin"?"jp":"key") """)")
	}
}

Loadfuzhuma:
ReLoadfuzhuma:
	srf_fzm_fancha_table:=[]
	If !FileExist(DataPath "@fzm.txt"){
		fuzhuma:=tfuzhuma:=0
		GuiControl, 3:, fuzhuma, 0
		GuiControl, 3:, tfuzhuma, 0
		If (A_ThisLabel="ReLoadfuzhuma")
			MsgBox, 48, 提示, 辅助码文件不存在，请在Data目录下放置辅助码文件@fzm.txt，文本编码为UTF-8-Bom或ANSI
	} Else {
		tvar:=FileRead(DataPath "@fzm.txt")
		Loop, Parse, tvar, `n, `r
		{
			If (A_LoopField=""||SubStr(A_LoopField,1,1)="#")
				Continue
			srf_fzm_fancha_table[(tarr:=StrSplit(A_LoopField, "="))[1]]:=tarr[2]
		}
		Key:=tvar:=""
		; OutputDebug, % srf_fzm_fancha_table.Count()
	}
Return
FuncHotkey:
	srf_all_input:=srf_func_hk[A_ThisHotkey] func_key, Begininput()
	Gosub srf_tooltip
Return
Registrationfuncandlabel:	; 注册内置函数
	srf_func_table:=[], srf_func_hk:=[]
	; Hotkey If, srf_mode
	For Key,Value In srf_Default_Func
		If RegExMatch(srf_Custom_Func[Value[1]],"^&\K.+$",Match){
			srf_func_table[Value[1]]:=Func(Key)
			Try {
				Hotkey, %Match%, FuncHotkey, On
				srf_func_hk[Match]:=Value[1]
			}
		} Else
			srf_func_table[srf_Custom_Func[Value[1]]?srf_Custom_Func[Value[1]]:Value[1]]:=Func(Key)
	; Hotkey If
	; For Key,Value In srf_func_hk
	; 	Hotkey, %Key%, FuncHotkey, On
Return

;备份
Backup(){
	If (FileExist(A_ScriptDir "\backups")="D")
		FileRemoveDir, %A_ScriptDir%\backups, 1
	FileCreateDir, %A_ScriptDir%\backups
	FileCopyDir, %A_ScriptDir%\Lib, %A_ScriptDir%\backups\Lib, 1
	FileCopyDir, %A_ScriptDir%\Plugins, %A_ScriptDir%\backups\Plugins, 1
	FileCopyDir, %A_ScriptDir%\Data, %A_ScriptDir%\backups\Data, 1
}
;更新
srfAutoupdatefg:
srfUpdate:
	;获取更新信息
	; If (!DllCall("Wininet.dll\InternetCheckConnection", "Str", "https://gitee.com/orz707/Yzime/raw/zip", "UInt", 0x1, "UInt", 0x0, "Int")){
	; 	If (A_ThisLabel="srfUpdate")
	; 		MsgBox, 16, 检查更新, 网络异常,将无法更新脚本！, 5
	; } Else {
	; 	If !RegExMatch(var:=SendRequest("https://gitee.com/orz707/Yzime/raw/zip/Yzime.ini"), "i)Version=\K[\d\.]+", UpdateVersion){
	; 		If (A_ThisLabel="srfUpdate")
	; 			MsgBox, 16, 检查更新, 获取版本信息失败！, 5
	; 	} Else If (Version>=UpdateVersion){
	; 		If (A_ThisLabel="srfUpdate")
	; 			MsgBox, 64, 检查更新, 影子输入法已经是最新版本了。, 5
	; 	} Else If (Version<UpdateVersion){
	; 		MsgBox, 36, 检查更新, % "检测到影子输入法有新版本`n`n" Version "`t版本更新后=>`t" UpdateVersion "`n`n更新说明：`n" RegExReplace(SendRequest("https://gitee.com/orz707/Yzime/raw/master/change.txt"), "im).*v" RegExReplace(UpdateVersion,"^(\d+\.\d+.\d+)(\.\d)?","$1") "([^" Chr(2) "]+).*", "$1") "`n是否更新到最新版本？"
	; 		IfMsgBox Yes
	; 		{
	; 			Backup()
	; 			If !ZIPDownloadToFile("https://gitee.com/orz707/Yzime/raw/zip/Yzime.7z", A_ScriptDir "\Yzime.7z"){
	; 				MsgBox, 48, 检查更新, 下载影子输入法失败, 2
	; 				Return
	; 			}
	; 			Version:=Yzimeini.Version["Version"]:=UpdateVersion, Yzimeini.Save()
	; 			If RegExMatch(var, "i)TSFdll=\K[\d\.]+", UpdateVersion), var:=""
	; 				tvar:=UpdateTSF(UpdateVersion)>0?"TSF":""
	; 			If A_IsCompiled
	; 				Run "%A_ScriptFullPath%" /restart update %tvar%
	; 			Else
	; 				Run "%AhkPath%" /restart "%A_ScriptFullPath%" update %tvar%
	; 			ExitApp
	; 		}
	; 	}
	; }
Return
UpdateTSF(version){
	; local
	; If (DllCall(A_ScriptDir "\tsf\Yzime" (A_PtrSize=8?"64":"") ".dll\IsYzimeInstall")=1){
	; 	FileGetVersion, ver, %A_ScriptDir%\tsf\Yzime.dll
	; 	oldname:=[]
	; 	If (ver < version){
	; 		For _, FilePath In [A_ScriptDir "\tsf\Yzime",A_ScriptDir "\tsf\Yzime64"]
	; 		{
	; 			i:=1
	; 			While (FileExist(_:=FilePath "_" i ".old"))
	; 				i++
	; 			FileMove, %FilePath%.dll, %_%
	; 			oldname.Push(_)
	; 		}
	; 		If (!ZIPDownloadToFile("https://gitee.com/orz707/Yzime/raw/zip/tsf.7z", A_ScriptDir "\tsf\tsf.7z")){
	; 			Loop % oldname.Length()
	; 				FileMove % oldname[A_Index], % RegExReplace(oldname[A_Index], "i)_\d+\.old$", ".dll")
	; 			Return False
	; 		} Else
	; 			Return True
	; 	}
	; }
	Return -1
}
ZIPDownloadToFile(URL,File){
	Folder:=RegExReplace(File, "i)[^\\]+$")
	If (!FileExist(Folder))
		FileCreateDir %Folder%
	If UrlDownloadToFile(URL,File){
		f:=FileOpen(File, "r"), f.RawRead(t, 2), f.Close()
		If ((File~="i)\.7z$"&&Ord(t)!=0x7a37)
			|| (File~="i)\.exe$"&&Ord(t)!=0x5a4d)){
			FileDelete %File%
			Return 0
		}
		If (File~="i)Yzime\.(zip|7z)"){
			7Zip(File,A_Temp "\Yzime\Source")
			FileCopy %A_Temp%\Yzime\Source\*.ahk, %A_ScriptDir%, 1
			FileCopy %A_Temp%\Yzime\Source\Lib\*.ahk, %A_ScriptDir%\Lib, 1
			FileCopy %A_Temp%\Yzime\Source\tools\*.ahk, %A_ScriptDir%\Lib\tools, 1
			FileRemoveDir %A_Temp%\Yzime\Source, 1
		} Else
			7Zip(File,RegExReplace(File,"i)\\[^\\]+\.(zip|7z)"))
		FileDelete %File%
		Return 1
	}
	Return 0
}
DataInCDrive(){
	global DataPath, main
	CDrive:=StrReplace(A_ProgramFiles, " (x86)")
	Loop Files, %DataPath%\*.*
	{
		If InStr(A_LoopFileLongPath, CDrive)
			Return true
		break
	}
	Loop Files, %main%
	{
		If InStr(A_LoopFileLongPath, CDrive)
			Return true
	}
	Return false
}
; 界面
;------------------------------------------------------------------------------------------------------------------------
; 选词框gui、ToolTip
houxuankuangguicreate:
	TT_Height:=60
	If (Caret="")
		Caret:={X:A_ScreenWidth//2-A_ScreenWidth//8, Y:A_ScreenHeight-20-TT_Height*(InStr(ToolTipText,"`n")?2.5:4)}
	If (ToolTipStyle=1)
		DrawHXGUI("", "Shutdown"), @TSF:=ToolTip(1, "", "Q1 B" BackgroundColor " T" TextColor " S" FontSize, TextFont, FontBold)
	Else
		DrawHXGUI("", "init"), ToolTip()
Return

;托盘按钮
TRAYMENU:
	Menu, Tray, NoStandard                                         ;去掉标准托盘按钮
	Menu, Tray, DeleteAll                                              ;清空托盘按钮
	Menu, Tray, Add, 词库管理, cikuManager
	Menu, Tray, Icon, 词库管理, %DataPath%Yzime.icl, 3
	Menu, Tray, Add
	Menu, Tray, Add, 选项, Option
	Menu, Tray, Icon, 选项, %DataPath%Yzime.icl, 4
	; Menu, Tools, Add, AhkSpy, AhkSpy
	; Menu, Tools, Icon, AhkSpy, Shell32.dll, % (A_OSVersion = "WIN_XP" ? 222 : 278)
	; Menu, Tray, Add, 工具, :Tools
	; Menu, Tray, Icon, 工具, %DataPath%Yzime.icl, 11
	; Menu, Tray, Add, 更新, srfUpdate
	; Menu, Tray, Icon, 更新, %DataPath%Yzime.icl, 5
	Menu, Games, Add, 就怕害虫有文化（孵化中）, DetectBugs
	Menu, Tray, Add, 游戏, :Games
	Menu, Tray, Icon, 游戏, %DataPath%Yzime.icl, 11
	Menu, Tray, Add, 帮助, Help
	Menu, Tray, Icon, 帮助, %DataPath%Yzime.icl, 6	
	Menu, Tray, Add
	; Menu, Tray, Add, 禁用, srfsuspend
	; Menu, Tray, Icon, 禁用, %DataPath%Yzime.icl, 14
	Menu, Tray, Add, 重启, srfreload
	Menu, Tray, Icon, 重启, %DataPath%Yzime.icl, 8
	Menu, Tray, Add, 退出, EXIT
	Menu, Tray, Icon, 退出, %DataPath%Yzime.icl, 9
	Menu, Tray, Default, 选项
	Menu, Tray, Tip, 燕子输入法`n`n单击右键以查看更多选项
	Menu, Tray, Icon, %DataPath%Yzime.icl, 2, 1
	Menu, Tray, Click, 2
	Menu, MyContextMenu, Add, 新建(&N), NewRow
	Menu, MyContextMenu, Add, 复制(&C), CopyRow
	Menu, MyContextMenu, Add, 删除(&D), DelRow
	Menu, MyContextMenu, Add, 刷新(&R), Refresh2
	Menu, MyContextMenu, Add, 撤销(&U), Revoke
	Menu, appContextMenu, Add, 剪贴板`tAlt+D, 剪贴板
	Menu, appContextMenu, Add, 中文`tAlt+C, 中文
	Menu, appContextMenu, Add, 英文`tAlt+E, 英文
	Menu, appContextMenu, Add, 删除`tDel, 删除
Return
AhkSpy:
	Run, % """" AhkPath """ """ A_ScriptDir "\Lib\tools\AhkSpy.ahk""", %A_ScriptDir%
Return
DetectBugs:
	MsgBox, 0x40, 燕子输入法之就怕害虫有文化（孵化中）, % "哎呀，还没孵出来呢——等我出壳之后再跟你玩ヾ(≧▽≦*)o"
Return
LoadLogo:
	SetYzLogo(srf_mode)
Return

; 加载数据库
LoadDB:
	If (DB._Handle)
		DB.CloseDB()
	DB:="", DB:=new SQLiteDB
	If (MemoryDB){
		Suspend, On
		Progress, B2 ZH-1 ZW-1 FS12, 载入内存数据库中，请稍后...
		If !(DB.OpenDB("")&&DB.LoadOrSaveDb(main)){
			MsgBox, 16, 数据库错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
			ExitApp
		}
		Suspend, Off
		Progress, Off
	} Else If !DB.OpenDB(main){
		MsgBox, 16, 数据库错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
		ExitApp
	}
	DB.CreateScalarFunc("REGEXP", 2, RegisterCallback("SQLiteDB_RegExp", "C"))
	DB.CreateScalarFunc("szm", 1, RegisterCallback("shouzimu", "C"))
	DB.CreateScalarFunc("t2s", 1, RegisterCallback("trad2simp", "C"))
	; DB.CreateScalarFunc("erjiayi", 2, RegisterCallback("erjiayi", "C"))
	DB.Exec("DROP TABLE IF EXISTS 'main'.''")
	DB.AttachDB(extend, "extend")
	If (extend!=main)&&DB.GetTable("SELECT name FROM sqlite_master WHERE type='table' AND tbl_name IN ('English','functions','hotstrings','customs','symbol')",TableInfo){
		Loop % TableInfo.RowCount {
			If (TableInfo.Rows[A_Index,1]="English"), TableName:=TableInfo.Rows[A_Index,1]
				_SQL = CREATE TABLE 'extend'.'English' ("key" TEXT COLLATE NOCASE,"weight" INTEGER DEFAULT 0);
			Else If (TableName ~= "functions|hotstrings|symbol|customs")
				_SQL = CREATE TABLE 'extend'.'%TableName%' ("key" TEXT,"value" TEXT,"comment" TEXT);
			If DB.Exec(_SQL)
				DB.Exec("INSERT INTO 'extend'.'" TableName "' SELECT * FROM 'main'.'" TableName "'"), DB.Exec("DROP TABLE 'main'.'" TableInfo.Rows[A_Index, 1] "'")
		}
	}
Return

96GuiEscape:
	99GuiEscape:
	Gui Hide
Return

Help:
	Gui, 96:Destroy
	; If DllCall("Wininet.dll\InternetCheckConnection", "Str", "https://gitee.com/orz707/Yzime/wikis/pages", "UInt", 0x1, "UInt", 0x0, "Int"){
	; 	If (A_Args[1]="update") {
	; 		Run % "https://gitee.com/orz707/Yzime/wikis/pages?sort_id=1811043&doc_id=434278"
	; 		TrayTip, 影子输入法, % "更新完成" (A_Args[2]="TSF"?"，TSF需注销后生效！":"！"), 3
	; 	} Else
	; 		Run % "https://gitee.com/orz707/Yzime/wikis/pages"
	; 	A_Args:=[]
	; 	Return
	; }
	Gui, 96:Margin, 20, 20
	; Gui, 96:Add, Picture, xm w18 h-1 Icon1, %DataPath%Yzime.icl
	; Gui, 96:Font, s13 Bold c888888, %GUIFont%
	; Gui, 96:Add, Text, x+10 yp, 简易帮助
	; Gui, 96:Font
	Gui, 96:Font, s11, %GUIFont%
	Gui, 96:Font, s11 Bold, %GUIFont%
	Gui, 96:Add, Text, y+5 cRed, 找到我
	Gui, 96:Font, s11 norm, %GUIFont%
	Gui, 96:Add, Text, y+5, - 我在右下方的托盘区，就是显示为“中”或“英”的图标（之一）,如被隐藏可以拖出来。右键点击会弹出选项菜单
	Gui, 96:Add, Text, y+5, - 屏幕顶部的彩条也是我，鼠标可穿透，所以不能操作，仅用来指示中英文输入状态（可在设置中调整粗细或关闭）
	Gui, 96:Font, s11 Bold, %GUIFont%
	Gui, 96:Add, Text, y+5 cRed, 快捷键
	Gui, 96:Font, s11 norm, %GUIFont%
	Gui, 96:Add, Text, y+5, 【Shift】切换输入模式（可在选项中设置）
	Gui, 96:Add, Text, y+5, 【Space】上屏首选；【Enter】上屏键入的全部字符（含间接辅助码，但不包括小燕子:）
	Gui, 96:Add, Text, y+5, 【, .】翻页（可设置）。不过——
	Gui, 96:Font, s11 italic, %GUIFont%
	Gui, 96:Add, Text, y+5, 更建议您在需要翻页时优先使用辅助码，因为“筛选”远比“翻找”来得轻松高效。问题是辅助码的使用一直比较小众，
	Gui, 96:Add, Link, y+5, 而燕子尝试凭借“高易用性”将其带给大众。详见 <a href="https://github.com/beishanyufu/Yanzi-IME#燕子辅助码">README.md 中 “燕子辅助码” 一节 </a> 
	Gui, 96:Font, s11 norm, %GUIFont%
	Gui, 96:Add, Text, y+5, 【/】输入特殊符号等（输入顿号用【\】键）
	Gui, 96:Add, Text, y+5, 【Ctrl + 1、2、3、……】调节对应项到首选，长按调至指定位置
	Gui, 96:Add, Text, y+5, 【Ctrl + Alt + 1、2、3、……】删除对应词条
	; Gui, 96:Add, Text, y+5, 【Left、Right、Ctrl + 字母】调整插入位置
	; Gui, 96:Add, Text, y+5, 【Ctrl + =】快捷造词
	Gui, 96:Font, s11 Bold, %GUIFont%
	Gui, 96:Add, Text, y+5 cRed, 查帮助
	Gui, 96:Font, s11 norm, %GUIFont%
	Gui, 96:Add, Text, y+5, - 在选项或词库管理窗口中，鼠标移至控件上并驻留会显示详细说明
	Gui, 96:Add, Text, y+5, - 您可以随时右键点击本输入法在右下方托盘中的图标，从弹出的菜单中选择“帮助”，`n  或使用快捷键【Ctrl + Shift + Alt + F1】来打开此帮助窗口
	Gui, 96:Add, Link, y+5, - <a href="https://github.com/beishanyufu/Yanzi-IME">燕子输入法详细说明和源码 https://github.com/beishanyufu/Yanzi-IME</a>

	; Gui, 96:Add, Picture, xm y+20 w13 h-1 Icon11, %DataPath%Yzime.icl
	; Gui, 96:Font, s11 Bold, %GUIFont%
	; Gui, 96:Add, Text, x+10 yp, 详细帮助
	Gui, 96:Font
	Gui, 96:Font, s11, %GUIFont%
	; Gui, 96:Add, Link, y+5, <a href="https://gitee.com/orz707/Yzime/wikis">影子帮助文档</a>
	Gui, 96:Show, , 燕子输入法 简易帮助
Return

_SetYzLogo(){
	global srf_mode
	SetYzLogo(srf_mode, 0)
}
SetYzLogo(fg, state:=1){
	static Hwnd:=0, Size:=0
	global pToken_, LogoSize, Yzimeini, Different, AppIMEtable, TSFMem, TSFmode, ShowLogo
    If (ShowLogo) {
		If (!pToken_)&&(!pToken_:=Gdip_Startup()){
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			ExitApp
		}

		If (!Hwnd){
			Gui, 2:-Caption +E0x8080088 +ToolWindow +LastFound -DPIScale +HwndHwnd
			Gui, 2:Show, NA
			WinSet, ExStyle, +0x20, ahk_id%Hwnd%
		}

		If (MonInfo:=MDMF_GetInfo(MDMF_FromPoint((Caret_:=GetCaretPos()).X,Caret_.Y)))
			MonLeft:=MonInfo.Left, MonTop:=MonInfo.Top, MonRight:=MonInfo.Right, MonBottom:=MonInfo.Bottom
		Else
			SysGet, Mon, Monitor

		hbm:=CreateDIBSection(BW:=MonRight-MonLeft, LogoSize), hdc:=CreateCompatibleDC()
		obm:=SelectObject(hdc, hbm), G:=Gdip_GraphicsFromHDC(hdc) ;, Gdip_SetInterpolationMode(G, 7)
		pBrush := []
		pBrush[1] := Gdip_BrushCreateSolid("0xFF0060FF")
		pBrush[3] := Gdip_BrushCreateSolid("0xFFFFFFFF")
		pBrush[2] := Gdip_BrushCreateSolid("0xFFFF3838")
		pBrush[4] := Gdip_BrushCreateSolid("0xFFFFFF00")
		Gdip_FillRoundedRectangle(G, pBrush[1+fg], 0, 0, BW//4, LogoSize, 0)
		Gdip_FillRoundedRectangle(G, pBrush[3+fg], BW//4, 0, BW//4, LogoSize, 0)
		Gdip_FillRoundedRectangle(G, pBrush[1+fg], BW//2, 0, BW//2, LogoSize, 0)
		UpdateLayeredWindow(Hwnd, hdc, MonLeft, MonTop, BW, LogoSize)
		SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)    ; , Gdip_DisposeImage(pBitmap)
		For __,_value in pBrush
			Gdip_DeleteBrush(_value)
	} Else If (Hwnd){
		Gui, 2:Destroy
		Hwnd:=0
	}
	; 切换托盘图标
	If (fg){
		Menu, Tray, Icon, %DataPath%Yzime.icl, 1, 1
    } Else {
		Menu, Tray, Icon, %DataPath%Yzime.icl, 2, 1
	}
	; DirectIMEandCursor(fg)
	TSFMem.SetFlags(!A_IsSuspended&&fg?1:0)

	If (Different&&state){
		WinGet, exe, ProcessName, A
		AppIMEtable[exe]:=fg
	}
}
; 通知 vscode 切换光标
DirectIMEandCursor(fg){
	global ConnectIMEandCursor
	SetTitleMatchMode 2
	If (ConnectIMEandCursor && WinActive("Visual Studio Code")){
		; Send, % "^+#!" (fg?"c":"e")
		If (fg){
			; OutputDebug, toCh `n
			send, +#!c
		} Else {
			; OutputDebug, toEn `n
			send, +#!e
		}
	}
}

_DirectIMEandCursor:
    DirectIMEandCursor(srf_mode)
Return
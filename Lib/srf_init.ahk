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
		, Magicstring:0, Superrun:0, Wordfrequency:0, fixedword:0, Learning:0, Inputscheme:"pinyin", chaojijp:0, Traditional:0, Showquanpin:0, mhy:"0000000000", fyfz:0, bmhg:0, dgsp:0, FirstNotSave:0
		, lspy:0, simasp:1, wumaqc:1, wumasp:1, Different:1, IMEmode:2, ClipWindows:"", IMECnWindows:"", IMEEnWindows:"", EnSymbol:0, SaveCloud:0, ShowCdode:0, Singleword:0, zigen:0, TSFmode:0
		, decfre:0, Tofirst:0, Useless:0}
		, Func:{CustomFuncName:"{""fanyi"":""fy"",""label"":""l"",""magic"":""s"",""mode"":""m"",""run"":""r"",""scheme"":""sc"",""soso"":""ss""}"}
		, GuiStyle:{TextFont:SystemDefaultFont, SymbolFont:"Segoe UI Symbol", FontBold:0, FontSize:20, BorderColor:"444444", CodeColor:"C9E47E", TextColor:"EEECE2"
		, BackgroundColor:"444444", ListNum:5, Textdirection:"Horizontal", FocusBackColor:"CAE682", FocusColor:"070C0D"
		, LogoSize:100, ToolTipStyle:(A_OSVersion="WIN_XP"?1:2), Lockedposition:0}
		, Hotkey:{Double:0, Switch:"Shift", Enterfg:2, Escfg:1, Shiftfg:3, fanyefg:",.", 23hx:"", ycdzfg:""}
		, DBFile:{main:"Data\ciku.db", extend:"Data\ciku_extend.db"}
		, Version:{Version:"2.1.0"}}
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
	tfuzhuma:=1 ;间接辅助码开关
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
	static htype:=0, lastexe, lastmode:=-1
	If (A_IsSuspended || (Msg = 3 && hwnd != WinExist("A")))
		Return
	if (Msg = 3) {
		if (TSFmode && curwininfo.tick = 0 && curwininfo.hwnd)
			WM_TSFMSG(404, 0)
		curwininfo := {hwnd: Hwnd, tick: A_TickCount}
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
		If (!srf_inputing)
			SetTimer, ToolTipInputStatus, -50
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
		If (A_ThisLabel="ReLoadfuzhuma")
			MsgBox, 48, 提示, 辅助码文件不存在，请在Data目录下放置辅助码文件@fzm.txt，格式如下：`n吖=k`n阿=e`n啊=k`n文本编码为UTF-8-Bom或ANSI
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
;加载logo
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
	Gui, 96:Add, Picture, xm w13 h-1 Icon1, %DataPath%Yzime.icl
	Gui, 96:Font, s11 Bold, %GUIFont%
	Gui, 96:Add, Text, x+10 yp, 简易帮助
	Gui, 96:Font
	Gui, 96:Font, s11, %GUIFont%
	Gui, 96:Add, Text, y+5, LShift切换输入模式
	Gui, 96:Add, Text, y+5, Space首选上屏, Enter英文字符上屏
	Gui, 96:Add, Text, y+5, /键 内置功能键
	Gui, 96:Add, Text, y+5, 1、2、3、……、，、。候选上屏
	Gui, 96:Add, Text, y+5, Ctrl + 1、2、3、……调节对应项到首选，`n长按调至指定位置
	Gui, 96:Add, Text, y+5, Ctrl + Alt + 1、2、3、……删除对应词条
	Gui, 96:Add, Text, y+5, Left、Right、Ctrl + 字母 调整插入位置
	Gui, 96:Add, Text, y+5, Ctrl + = 快捷造词
	Gui, 96:Add, Text, y+5, Ctrl + Shift + Alt + F1 帮助
	Gui, 96:Add, Text, y+5, 在选项、词库管理的控件处停留0.5秒`n显示详细说明
	Gui, 96:Add, Text, y+5, 选项 - 控制 - 命令管理 - 模式切换`n有更多便捷的设置
	; Gui, 96:Add, Picture, xm y+20 w13 h-1 Icon11, %DataPath%Yzime.icl
	; Gui, 96:Font, s11 Bold, %GUIFont%
	; Gui, 96:Add, Text, x+10 yp, 详细帮助
	Gui, 96:Font
	Gui, 96:Font, s11, %GUIFont%
	; Gui, 96:Add, Link, y+5, <a href="https://gitee.com/orz707/Yzime/wikis">影子帮助文档</a>
	Gui, 96:Show, , 燕子输入法 帮助
Return

SetYzLogo(fg, state:=1){
	static Hwnd:=0, Size:=0
	global pToken_, LogoSize, Yzimeini, Different, AppIMEtable, TSFMem, TSFmode
	WinGetPos,,,, TrayWnd_Height, ahk_class Shell_TrayWnd
	If (A_OSVersion="WIN_XP"){
		Gui, 2:Destroy
		Gui, 2:-Caption +E0x8000088 -DPIScale +HwndHwnd
		If FileExist(DataPath "Yzime.png")
			Gui, 2:Add, Picture, , %DataPath%Yzime.png
		Else
			Gui, 2:Add, Picture, Icon1, %DataPath%Yzime.icl
		Gui, 2:Show, % "NA x" (Yzimeini["Hidden","X"]?Yzimeini["Hidden","X"]:A_ScreenWidth-A_ScreenWidth//5-(64*LogoSize//200)) " y" (Yzimeini["Hidden","Y"]?Yzimeini["Hidden","Y"]:A_ScreenHeight-TrayWnd_Height-(64*LogoSize//100))
		WinSet, TransColor, F0F0F0 255, ahk_id%Hwnd%
	} Else {
		If (!Hwnd)
			Gui, 2:-Caption +E0x8080088 +ToolWindow +LastFound -DPIScale +HwndHwnd
		If (!pToken_)&&(!pToken_:=Gdip_Startup()){
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			ExitApp
		}
		If (Size!=LogoSize){
			Gui, 2:Show, NA
			If FileExist(DataPath "Yzime.png")
				pBitmap:=Gdip_CreateBitmapFromFile(DataPath "Yzime.png")
			Else {
				pBitmap := "iVBORw0KGgoAAAANSUhEUgAAAEYAAABQCAYAAACkoQMCAAAACXBIWXMAAB7CAAAewgFu0HU+AAAGvGlU"
				. "WHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhp"
				. "SHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0"
				. "az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDUgNzkuMTYzNDk5LCAyMDE4LzA4LzEzLTE2OjQwOjIyICAg"
				. "ICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRm"
				. "LXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6"
				. "Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVu"
				. "dHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAv"
				. "IiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9"
				. "Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1wOkNyZWF0"
				. "b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOSAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIy"
				. "MDIwLTA0LTA4VDIwOjQ2OjQ1KzA4OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMC0wNC0wOFQyMTowMDoz"
				. "NyswODowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMC0wNC0wOFQyMTowMDozNyswODowMCIgZGM6Zm9y"
				. "bWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxl"
				. "PSJzUkdCIElFQzYxOTY2LTIuMSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpjZGZkNzJhNS00MzIy"
				. "LWNkNDEtYjI0Ni01MDA3N2RmYTM0ZTUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NmQ5Mjc0OWUt"
				. "ZTNkZi01ZDQ2LWFkYjEtOTAyYzAzYjBmMGE5IiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5k"
				. "aWQ6NmQ5Mjc0OWUtZTNkZi01ZDQ2LWFkYjEtOTAyYzAzYjBmMGE5Ij4gPHhtcE1NOkhpc3Rvcnk+IDxy"
				. "ZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1w"
				. "LmlpZDo2ZDkyNzQ5ZS1lM2RmLTVkNDYtYWRiMS05MDJjMDNiMGYwYTkiIHN0RXZ0OndoZW49IjIwMjAt"
				. "MDQtMDhUMjA6NDY6NDUrMDg6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCBD"
				. "QyAyMDE5IChXaW5kb3dzKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3Rh"
				. "bmNlSUQ9InhtcC5paWQ6MzYwOThkNWUtMDczZS1lMjRiLWE4NDYtYjk1ZTUwMDgyY2RiIiBzdEV2dDp3"
				. "aGVuPSIyMDIwLTA0LTA4VDIwOjU3OjU2KzA4OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQ"
				. "aG90b3Nob3AgQ0MgMjAxOSAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPHJkZjpsaSBzdEV2"
				. "dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmNkZmQ3MmE1LTQzMjItY2Q0"
				. "MS1iMjQ2LTUwMDc3ZGZhMzRlNSIgc3RFdnQ6d2hlbj0iMjAyMC0wNC0wOFQyMTowMDozNyswODowMCIg"
				. "c3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTkgKFdpbmRvd3MpIiBzdEV2"
				. "dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlv"
				. "bj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PifxVvgAACF4SURBVHic"
				. "1Zx5nKZVdee/5977PO9We1V39QJUNzsIKIEWRQFpI5sGVIgKmBhNQtTRLAOa1cQxo5NthsniZ5AYnZGY"
				. "BY0GFxIFUUETQBBolbVZmqaXqq7q2t7tWe4988fzvrV0Vy9gZkJOf27Xu9xnOb97lt899z6vXHzxxRxI"
				. "VJUoioiiiCeeeJzp6b0cd9zx1Go9qGq325HAp4FbQgh/vvR4EcEYs+K5RYTnntvO9PQsAwMDrB4aIik5"
				. "JLL8zNaM83fnzEeQEzAiCBYIqAZEBTCAIgjaOV8IAUQREdQ7RNu0NWXOJ4xGA2AExCCAavGfGlnx/la+"
				. "6wMCBdu3b8dai4h0Wy9wKvDWJElK7XabdrtNkiQLAPxHlMMBpgRUAUQghMDU1CSqSggB7/1O59w08LJW"
				. "q3VUF5SZmRmSJDmgxbzY5VB3LSLyUeAL3uervfe02y127NixYDXGmBlV/aGq1iqVyqY4jqnVaszNzTE/"
				. "P4+19v+HHv/mYlQLFzlAsyHomjzPL+zvH7xm7dr1rFmzjjVr1gIsuFOWZV8SEXp7+15fq/XQ29tHtVor"
				. "fH0xFv2HkoNajIjkeZ5/K8tyhoeHf2Z0dHT96tWr6e/vJ8syQgiEEBCRr1lrn0rT5M0ickaaJszMTP+H"
				. "tRYAo6ocrIUQvgb6iIg5HnhzCGEhvnRbu90e37Vr10esNeVSKfqE934ky3KMkatFOG7FCxvzog7MJs9T"
				. "Dta8z7anafLFEDwi8t5ms7UWDCEE0jSl1WoxPj7Ojh07/k+a+j8SsWeEEL44Orr6/dVq9fo0zS7Psoyl"
				. "Lc9z5ufn8d6/aMGxY2NjB7UYEWg0Wg/Hcenicrl0cgihZK37J9XQBSfu6+t1zkXeufh27/NSHMdXr1q1"
				. "6mLvtea9L6dp+vk8z1NjDFmWAbBz5068zwlBKZVK1CoVvDOINbx0b2BjPZBaCBS8RDq8pctdoABUun+7"
				. "8Uw6FEENQk6OJ1FPjy0XaVW6R3TkAANjssxzsJYkOcbY3VFU+pCIycvl0vtU9TdDCESRI45LZxhj/2p0"
				. "dHTMOUsI4bcajfq75+bmc2PAGDk7juML4jhmdna2k8nsgiu9WGOzWULUDtgAjOGLk5N73p+mKVHkPmaM"
				. "/Xtj7Muq1coV5XL1ajBvsRZUA2mafqLRaFzunJsDTBRFv+acq87NzaFaAFNkqxenG8HzYr5Cu92+wXt/"
				. "WQjhCefsW4B7VMP7ivjDB42xm5IkIc89zrkvqeqFIE8YY19ljPkza22pcIcXvxhrLdZanHMLflpwGO2Y"
				. "+eKoWmsIQb40P9+8qN1u3WSMtarExejriIh8VFV74jiiUinjvb/be39FkqT3Aj8/MDDwN6q6qsttigwX"
				. "/j30PqSYZrNJs9lkfn6eIm5EGFNM/qwVQAnBY4wsTAq9D0+FEH5WVS9UlW+LgKogYl4Xx6WPRVGEqpIk"
				. "GSGELe12462tVuvbw8PDb+7p6bkjBH+K9zlxHGNtFHvv7YvNq6wxhnp9nqmpSYaHh+jrGyDPU6IoJo4t"
				. "eZ7RarWo1arU601EiiwCShRFT5fL5b/OsvRp7/MNImaNc+4sVT1RRLaEwF6KrDKjqrdGUXR2FEVnZln2"
				. "Ju/zHatWrfphT0+viOHI2LpEnc15kWQlOzg4hDEGVWVwcJByuUKWZQuBN8/zbsyg1WqSpikjI8N4r3if"
				. "MTs7F6w1D1prPxGCTlkrpzlnzwa5EnQUdE+pVNodRVFjfHz8iyHoWeVy5dS+vt43A0OlculbpShOg+jp"
				. "eezmDdI+bfrfH5jDDr7LXUm7oNmJid1jWaYXO1d6F2iP977ufSAEHTFGrrXW3iYiN4UQ3jYxMZHMzc2+"
				. "LYqiu/M8GFX5lTzL/tGHUEPl8bmkdVYm2mdeBH7lnk/nJRPCsRDC5jiOXz82NnaWtXbY+7QiYjr9WPgr"
				. "IsN5nr9dlauOO+74cWO4pd1uPdftI8jrZkrm9pOn8p99w17d9eWx/C11yz1OmQEiwHdaC5gH0h9X6cOR"
				. "wwSm0MJae5yqXh2Cv9IYOU5ExDlHUVnbNw0Xo77kcxPH8VpVfXcIIRch0LHYSDlp+0j5lrdOZFv+8KFs"
				. "03dHXdhdMXNDibqZyGSi0kZ0CmQH8CTwWKc9CtR/HAAOJIcEppO2XQj6juHh4d8OIWzM8wzopna/0He5"
				. "uy4FqvjC+4W+bsFiBAYyZVfJr/vjE+y6P/u+8vIp5dur7arLdnj6c8N8pLhQlDANghpQ1SlU7gfuAb4O"
				. "PMi/IUh2YGBg4aYXg2+KiOlW7NY7F90Ux+UPhMDgIr9ZKW4dPDasFOe0U7MdzODZsnDniPDT2wNNJ9w/"
				. "ZDhzbyADMiNEWgRbo4LBVEXkGBHOQ+QK4FxVLauwTUSaP3ZWOhgwoGfHcfyFcrl8dgj+gGRs5XMfGKR9"
				. "+3dzzepU2dYj7CkLV25T7hoWGtawaVqYc0UmWvzXvYogIiXgaCPyUyJcrIhH5WHB5/8vstLlIF9Q5YQ8"
				. "L2bBhaXofm3l6p924suh+6OQi5IKHNlQ7lwlfHfY8PZtyndWwQ/7hCNbHWC0YzEqmGA6rfNaDRZ7qlPz"
				. "CWP4JhIu0Rc4BTkQMK8X0RuB0aLgvXjyZQotfsqB5kAH77/4oWiRemyASqb8/ZEwnBpeOyH83VEw74TB"
				. "TJa4UsFsDGBUsAhGQULnOwlnlW3P3zlbur7gUz8+MK9U5QZVhhaMXA6u9MEUPnj//Y/xArUctlfh62vg"
				. "0h3gFG5bDT0pRN34piC66FaL74tTmWDw0Fsy5V9dFQ9+Adj0fCawpmC2eTdjjBrD9SIcsVSRA7vGcoWX"
				. "W8dKbnSw/ovHuM51bl2j5GK4eJfwvSFlOhJ608Kdui4lSufvEhfrWBQhYALEJjpbrPkqyCWHDczAwABD"
				. "Q0NUKhVU9TrgrIMdsLLyB+63z6eH1V+Aioct/YF/Gg28dqcjUuH+IejNBauL4CwDCRbeo4uuRlCMmlWI"
				. "/TzKWw8HGPvyl5/J0NAAlUr11SGYjxsjTjV0gvXhUfPFwP580/WB+7sAUyVoRPCmbZbJsvJ4n3LmXoMK"
				. "eCniSrFYW1hIt0piVArf2j+HRSp6hRQkccsBbqq4frPZAqBcLv+Cc6GUpmlnUgkH88mlYCx3hcOR7sHL"
				. "+3fPqYAFBjL4YR88PKCcNWl4aChnTwmGE0MSayeedBi2gFXoEgoTDEE6OUkUs6CPQUU/CToDfOVAd2i8"
				. "93jvz03T5KoQ8iWLZIcXSJcWzp/vMfv2X+qmQaEnU6biwIPDynENQ+yFPWWIF+LL8lgjnRQuXTdaEnOE"
				. "TjpXMEpJ4OPAK5cO0z7AKN77C0VstHS+c7ixZCXFO+8Oecz+11jyHYWiNihP1gKIMJwI064gg66jsFWW"
				. "gFC8FgUJdHZJFIobZTEGAYIcZcX8AbDGo/ulCWOMWSPC5uJ2Vva3lTPN8wXoIG5JoYjo8r5GO7EmhlQM"
				. "PTnkphM7lA4ohSsvVGhEsFh0roHO1pfUchZjT9eiIpFzPeHa3T6hoYF59QvNiMhJURT/hPf5IZU43PS9"
				. "cv+VjimUDwItB1knZu7bNzWdNB4E1cJVbCfziAoWs/BPWhlSclRefiqmYtDZeUQM3RqPqCnicuf4SM17"
				. "Bb3UCwSRhWaSJDlFlbgbRF+odbwQlzOqZBIYjwPPlj07K57MKG7JKTKBwRRKuaHhCoJnAtDJRKKC+FAo"
				. "bCNIUsL4HgY/8k5G//qjYDzUM8Q6xBgkFNUOQchVcWqq61z1ukrQOM4ySnlOKc8x5XJ80uFax6Gs5ED9"
				. "97WSQi1IBCZj5exJy198v8oVz8akojRskUUyq7SdctpMBMEwHgdGEiHujLpRQYyDthLmdkGrRdQ/ACTM"
				. "/v6nqV54FkPXvQPf3kY+sQPaHhOVMKqFZVJYa1ncObU8vLeSpVTyjEqeYUA2dBfqD1d+vMBc9PcCTatc"
				. "NBHxW0+U+cmJEh/b0s+ZU44dpYBXZVecM1YXNu8u8aOBgDfKWMN1nbDIzfU60Qnrqbzm5Wg6De0MVx6m"
				. "ddc3Se59lNK5JyL9UD7mOPz8HrQ+i0QxAh2iCIn3ZCV3VfBmyNcDvqmYEHTV4s0feA370CAdzKr2z3Z5"
				. "pxLzmvGYcuL44EvnuP6EebZVAzUPc7HiDbz/8Qqr2hH3DaasahsGEkMqYINgjENCCs0p+v/w/Qx87Ffx"
				. "7V3k7ceJxzZiR4YwUmHdJ2/giHs/xcgH34m2E3S2uRCQuxnLuniTiLtcvYIvFvWvBRmBA5LAZfJCdyfs"
				. "y46NQsMW7654rsxcpHzwtDobmpbBVHiuEnjvk1WuebIGwG1rE4YTwxl7Y9JOEBIjGInJp3Zg162l8p43"
				. "Eh7dTfm8VzF4w29ix1ZjR4covfRYpFaiuvnlZFuepfGD+zBRDenu35HiPtRiqET/aGqlzACuO6orz2+W"
				. "y6EsqTsCXU7RfS0LhlO8MECPF766NuF3T5nnp7dXeObW1fzN3YO8ZM7xiqmId2+tLQBpg9DdYNnlIiYE"
				. "jHVYaqQ334W0EgY++yFqV16CGIPfvofkzi1op6Ta/No9JA88jKO3A4ouDlUIOGcuFOdeoQUoLBZtlzDQ"
				. "5aoe2Jq64HSn/pkREgeJUQIFtY+DUNGi1mJCEfACSiWHITV8/OgWDw3kfOSHvbx0psJ1j/YTRImCpRnl"
				. "VDPHcFuYLgVyY4gDtClYnBowWMKOKUK9jR0cYu97f41AzuovfY7KpWeTPbiVqQ/8Mc1vfJ9gY9yqEYJ6"
				. "0EB3SlgMlzgyf44Rc4dT1bmDK78vWIuduv275Go2gnkbGMxgTVpkjswqs5Gy0ymxCn0eqr4IepnAaGLo"
				. "zSO+OZLylrOmuebpNm9/tgeLMFHOGU0NIGxsxjzc12LOBkYyoWV1sRZDmdCaJf/h09gT11P76bdAyWGP"
				. "XUV614+YfNeHaW29H+uOxPQPEELGclYIiqLGAunZzrp+OzY29kbYdzvY/sofSAygIoxHynAu/MzumKt2"
				. "Ot4wEXHRVMRrpiJeNe14ybwjUniuEpiMPbF2VhEFzp+M6cuFLf05W3s8t65NuHFDg6lYuXB3BRAGM8N3"
				. "RtrUgnB0PSYYLUgaClGEpi3y7z9GdNZLKF95IfF5p9O66etMvvVXyCdmiXqPhmoZVd+ZbyzXc8EIrOnP"
				. "Sb/igG0HspLCUg7uSgB7XWBd2/Dhp2JePetoCaQFD8UGKIeCqTZ3woM9gb88qsW3RlKGssB0BE9VPL/x"
				. "WC9O4SujCVYNdat8Y7TF93bU2LS3Sl+mnDZb4s6RNudPVIiD0LTFLnEjQHkA/+RzzF76IRip0fPffolQ"
				. "b0NLcZXhwqe9X2YlyzUWVAPOlUYm5548ya5ePXqMc/HFh+Yi+wNkFFqmqI38520RF+21PBsXLpUaoW2V"
				. "tlXqFlpWiINwTN1xwZ4YL/D9gYxYhYcGUk6djfgvjwzwUH/Klv6U9S1HI1Ie6cs4c9oxlMacMB9z22gL"
				. "FTh+voxByWwABTUG46pks1shgp7f+UXsyADtv/su2mhBKSrcpQOMdl1oyXuVIgGJcQ8YY+QHqsEvZpp9"
				. "CdxSK9pnR6cqdRPY2IAz6pa9kdCyKxeSPTBrle01j0H4jSd6uWR3iQAMp5YPnDrNvw4l/O29a7jiuSrP"
				. "VDLKqeHhWsbPnjHBh0+eYGcl531P9nLXSIvnqhmRj6jkFi8CWjxHYBhGkho6V8eefATSX0E1P8SgLw6+"
				. "klONBjbaDRs2NFR5tYgcdbiW0v1UpeAix7aE18w4DEJqulP/xSl/Z+2nIFIqNC3UcsNRbcsdwwk2QCaG"
				. "z6+v87o9Vd65bYggOd8daVHLDbmBO1a3uHVNnQvHK1SC4drT9lIK8LKZErEqiS02GhCVyOe2oXuamDWr"
				. "Sb/0r/iZOlKOD8Niitde83F75JFHNVVlDchrnw95U4q5SmqKhzo2zzj6c0PTFu68HzCdUgEIEgQ1ynBm"
				. "uL8/45GenHVtS8UbHu9NOL7heNPOQY5rWP51qMVMHDimETFdUu4cScgEvjeYctORdUoBzpksY0RJRRFr"
				. "wPWQbnmM5s13oEmAcgQdUA4FTOfBlhm7bt0RqOpeEb1CRGpL3edQOHW/n3Zwct1yYssusFlzEGAMQtRZ"
				. "//lef8ajvTl7Y8/mqTJX7qjx1dE6k3HOZbv6uWBPmUd6Ux7oz1jTtrSssrUnZ6xhUQP3DWZsmonZWHck"
				. "TgkSwDlQwScNJIrAmucHjDBrOnPMH4nIZ7obiFaKJysx4gCUPaSifHlVzpxTBjLhUB6tWpC+hoWdpZyS"
				. "hzVty9dWtXi0lnPNM/081pPwvtN2M++Uz963hg880U/LBOpGKWfgDaxtOtodcOgsxBWV8hziCNszVCw1"
				. "60J+PlyJ7bp16whBEZEnrLUXhxBGDuxS+/MbIwV9fqwSGMiF82cjEgNtERz7W4wLghdlWyXwmXVNvrim"
				. "RRClPzcYFb4z1KbmhWue7WcwN/ygP+GYRsx5kzVOqBvuHWrzdNWTWtgbBZpGuXx3ldNmY9pRIHQtoBtP"
				. "WGodh44xnfd77cDAIFmW024nM+122qpWq5cCXbAOAmrxnVIUp1OB+3pzNrQNZ8xFtJwW4GgXmOKvAlYN"
				. "iVXGS8WW+bpTtlVyEgMW4e7hhGeqGRePV9m8p5dyAMSzsRlxylzM6syQizITBS6YLPPeZ3qoqNJwWiiP"
				. "oiKLVL+rhhRstwveQYDZbVetWt2xAMF7/0BPT+0I58xP5LlfBsBSK9lXFOj1MB0rtw/mvKRpeelsTNtC"
				. "YgtlRTv12c45RjPHqybLvHG8wqbpmCMSR90Gnq16UhG29uTcsrZO3eWMNR19QWi7wFHNmHMnK1wwUeL8"
				. "yTJX7agxkAtTcehOXgpFO+VQ7b6W7hwNMJ3it+hCC91l6ILPPL0ADBQTwt7e3tuNkTNC0GO7M+6DB+HF"
				. "CdNALuyKlduGU05rWk6djQgWmkaxnWcRu7bTMkpqi2L3kc2YV+4tc+lEmU2zZVwQ6kbZGwVu3lDnXwYT"
				. "Lt/ZS29macY5wQRq3rK+5bAoM3FYsIhgOgqbJa6DQOd1kEIhFV2wJu0szqlAKEB7yI6OrlnYoVlsPPR5"
				. "q9X+dlA9I47iDd09MXoQi+l+ryqMZMJkpNw6lDEQ4Ix6RClA07AElsJ6cgMtF2hFxcpnLbMc0XQ8Wcu4"
				. "faRFQMELl05UecNEBTFK04aQGZXEBdrO0+7UZrouxBJFl7vIciD2jTFCYVFFP/OtZcB0t6967+eydvuO"
				. "OI5OzJw5LqPDTfYxkv3A6Xw+lFtmXeCOwYxpB6c0LaOZJe2YsiyxHatF3PFGwMAjvSmP1VLG2o5NcyWu"
				. "faaX92zrQwVmo4DAXlX/caPytzXj6koY86JxBxaC6c66tTv6IEokBhXFU1jTsnsW8F23MoIG/3lbXTtK"
				. "Kiy0zBSkra75LJXyrUd5d4IP/sTxSLFabKNciszSLC5LRqfXF33u7824v9czkAsnNxx9wZAJpGZpUC7E"
				. "G+j3ljNnS7xuqsL5e8scX4/ILcy70L1GtSbR9A+Y+4sn/fyNx4aeBxsmP8da2w+e0Hm82GDI1E9bw71B"
				. "wvfm1CMiQ1bEhAKQXUF0ayAEDH0qSiAgxmCQT9nzB9axNjf7NGFVLhylcfuyybD3/Eb89u0VK0+UMlq2"
				. "GGVLd3VP9regTjYoq1BW4Zly4FsDKbtizzEtyxFthxGhbbqbmTuoSrGy6LRjvaI0XZfus+AaJeuOn9L0"
				. "7LZmXznG9D0wFRr3qclePWBqw9Yo04T6HpK/6A/yrkjMn+7W9HM3Jk9/ZqOptje46uZZzaaCCdep5zdC"
				. "O/vfIbI1jNlUBGudMC7+n/bWdAMXzrvlre54fTNm815lbWZaY1r5yXPm7ZrhXJgyMB4HZqySGogE4lBk"
				. "tf04oBTg9eWCGuGevpSvDyaUFc6cj6kEYX5JwUm1WPTKbfEger7AN6RLOVEgIacmdt2Y6X2wZMtbWtp6"
				. "dpqZ7+yUaHQV1WfG8+ZV3tRvOqG8emRck+PmsjAuRtsbTe2umohpSjjBGHMkhDeJym2Zlc8q4dhSXDmt"
				. "kc3ck/rGjfbqwQ00I7Nia0WGdsnV65GcOZDpT5w77zinYdmQWioepi1siwNNA7WgxLoYZ5bFHqDshcHc"
				. "MB4rXxppszf2vGY6pqbCvAvYhVTeYd5dHiJ0MsoipfdS1IytMd9ra/YdbwJztHbf59PPD6v73JP67M5R"
				. "ce+vmt4vzmvyzppxR58a9X/LiSQJ6YOZ8Laaq7zKirk7lfzbEsu0oLkXrmz55HOq5sv2mr7jEHErN+Mw"
				. "GJxXaVnzljmnZjAIpzcsr647XtGwrEmF3ZGyrVSk9uqSbRlLMQodpYZzi1HhmwMJ81bZPBMDhVu5Ljj7"
				. "gdslk0uK10ZoSd5qmeRmH4zmBrap14dkp4+Me8cro/W/N0H7dwT+3Er6rlbwmxLDP2hE2xn7uqeSnV/r"
				. "Nb3vURum85CSWM7ow1x+JOX/PiDxo/Y9lY2YTpF6pSZBiTXaEVtzQSL5+rrAvC1iwrpMeFXDcU7dUfPw"
				. "eNkzESk1hUhlYa/KUsvxovQEKAXh7v6UnmB41XzMvFOCgGG5dexXSFp4HTAiJxhjHkgyfVQsrHdlasYc"
				. "fZIb/ZPVtvb7e0PzU0j+dJD8AY9cK9Z+l0h2GOT1c74+W3Kl29UqaSt1wzb+Xz90rflez2+PmXLingnb"
				. "97f9fSRoqPdKzy1Hxus2ZT4jl8C8KPMGSqqMZoZfGy9zTj3if6xu81DNsy41Cw8CLMtiCgnQ64W5AH+5"
				. "psHZsxGnNmOejX2xTUzo7HxYbjNLt6aqLPCqPxVhQERvWm0iv57Ry8Z1tnVXuvPvh0wvJSLExuVI7LZU"
				. "82a7leGs9WPltb+eo7YVkntsHP3Uhrj37Bta47/0/ubOuY22gn2frKaWm4O23lwgLe2olGpvVOsHVLWz"
				. "LA65wLxV2kY5NrG8ph6xM1IeqHoqWkwkV1p9UqAUDM/FReXtoukSuVFaVhcfwDlAjOlaUTEJ0H7rzBty"
				. "sqoVc/uo67nmGT85+FSy61ODrpeyKZW81wswcqcYucOorlExv5MbHcnxU4h5bVQpv2G+ufvT983u+N1J"
				. "CVSDR/60f9MhLaZulPPmHcfH5Q9vHzK/p74gfEvFd5TZmFqawC8f2eDemmd9JlhZuaJsgN2Rp88bPvP4"
				. "EKc1HE+VPG4xiR9UujNoU8zzHpwlOz1z/MJGrf1ly8hFbdKvJWQYkZggqVrFEG7ORS5X0fMU/Q6YYeui"
				. "q8eTXVuz1sytVRMVJLTvlGMPeQPzJrC5XuXn6j3D50vfXTMunJQFz75RMlBsETs2tdxfyblufYO2Ffp9"
				. "9zdelp9XKOZR47Hnw8/28u5dvTxX9mR098wdRLqWo4AoMTbZmbbe+qn8mVveUdlw67Gl/oun89avpJLf"
				. "HDmbqddjM8Kvq+ibcgm/aJBPLpxKLLO2YdqSYZAA4Falh36Wa5037o6RdN1ALd1x2fbwX4Mzn53A72c1"
				. "xRoT7HSBk9qWcxqOf+rLCCz5MZsFSAqJgkAwPFrxNF0gDpBYPay6UqcgSBDFEErry5XrR5LKszukdUlf"
				. "0v51lfhjNip9CNVmJKxpaohr4v65ouYzbTzWCFlnWqWqQUPeWTwGe8S6I4hcdIjmXOxKf94XXN/50/KZ"
				. "ybw9Vi2XTw8rlPUMBbWvBpixcH81oChu3/y9AE+xPjSYC+fNx5SBhllU/KCtG3cAL4FcdPBU13/loImi"
				. "yWzP3Uai9WW1sjtv3ridtHSUK2/cEVqfvTub/sb20GLcJwzbEk4MiaTk5AtO7Mrl8qGHBtJ1Kkdv75GX"
				. "ve2E9NPveaRx7dvavZu2lu0pifcrPvTkDfQHIQ7FXhjYdzmmA05ntb9pii1l1Zyibns4QWYJQABelYox"
				. "fUblI2urR2Vew3Q9JK9IQng6Ea1tiKqbP9F48r4/mN/KMa6Hec14ZTTM9UMvY2qfKOi6j+sdSryGvbVW"
				. "/oqneuwv/slJlRt/cmv28ye34tu3lHxv3rWIJTfbjR+Z6BKX21/bhfWrzkHBrByoVxTpHN89tUAD35mr"
				. "hQh0CGOOW1+pPj3g/T8+2ph57sSo/6JvjL56+yY38FBdPQ6DE8MuNTQJuK7FpGlyePcgstsay7GNcP0P"
				. "ysycs27+5k+O6xUvyfv/edo5aZBjEXKBXhWqang0DrSAfhWCdiFbGoSlKDMiDOVCHAKpyGI17TBEO7s4"
				. "tUMMF6+iBMFFyF8B1wXVO3dpeuK5PSP/aYBotJn7q4yQeYpl3iFKtEiJO8PoJiZ2H/LiIQRqtdoTq1ev"
				. "xedZ9bSG/5sHe93LXtef/NbntqabL2/3/MO2SIdaolSCsC4z3FHLuK0nwVJsO12qatelBMWLkhDYkFoG"
				. "QzG96BaVDguYzv8Lx8giEQyiBDgiVW6KnalX4srgTJ6FPb59r0K29BwOYYTehevaarV60C1mqor3nlKp"
				. "7CuV8mUBrYKaNUHPCcglD1ay7wfRuSO8PQMwqcA3qxl/NNJkwgWGvCxcfKVnDuqi2CBcNVPhxMwyHoVF"
				. "BQ+nmSXkz3QL4YVLLhR7RKxBKkE1UdWfE+UTxV7fxQYFYew2OeGEEw49KqpY66hUyl+2xr0h14DTIgNN"
				. "RNr2yvjJiRtY7U3/Hud5PPYEYMh30vQ+51sK0PY4cHrTcMNzvUQYdruw8EzS4Ui36zI3kuU9RCyquiMQ"
				. "3mmU2/zC03oHFhfHpcO6geJnl/RGkbBZlKqnIHTDmZRbomOPlfLwqCpGhJIK1SArggKFKxmgbgKockm9"
				. "RJ8atkXFXEkPcNyKsiyusKQ23yWVBu/bt6fkHyiZ6oOHe2a7evUqDoMxdJ+ofTwEPSqKojNZ8m2EUA4i"
				. "ZRUqQYq6DPu6z+JdG4opxE4XOK8R80vTFRpGadpi8W6h9PACmqJYY4jE4UM2B/JnIej7Auk2Z0r7EM0D"
				. "y/P+9T7n3EdFzEPdH/BSXQyUXQz2DbQLrUP1jcL2yDOWW94/XaakwqxRIn0BoCwRASLrCCjzvvkvqeaX"
				. "i/JBYG6/zoeQ5w2Mqm5vNhtXp2n6SBRFS35z5tB7g60WmWJrlDOUCR+eqHJi4piy4fn9lsKChM7qRhHL"
				. "ggbwsiVJsvdMJjOvDRpuf6Hbb583MMVvxeiP8jw/XzXcArC4GWC5LANJi12ce41yeivihvE+zm1G7HZh"
				. "gRAermin9GlNqXMdXzciX01DeFczSTeL5wZrTPv56rZUXthAIRgj40nSfluSZD9XrZZ/2Rh7UneH+L6j"
				. "1H230+aPHZu6j//xnp74pMS+/vHYn5IbWeUUVpp3HejaghA07M7z+hZVc5eI3Gkjcw+QGNm/cvhC5AUC"
				. "01kVUNp5nt+gGr4M9rwQwiZj5LQQdC1QMUZSYDfow4rc30Zv7wvyzGhumRT/Vy3RY32SnZQbGatE0dF5"
				. "rmvFMAj0ATEFzhmic4JMqrIjqH8mstE2cv9wO59/ytneOdNZ7fq3lP8LH25j4eRuIWAAAAAASUVORK5C"
				. "YII="
				pBitmap:=Gdip_BitmapFromBase64(pBitmap)
			}
			PW:=Gdip_GetImageWidth(pBitmap), PH:=Gdip_GetImageHeight(pBitmap), Size:=LogoSize
			hbm:=CreateDIBSection(PW*LogoSize//100, PH*LogoSize//100), hdc:=CreateCompatibleDC()
			obm:=SelectObject(hdc, hbm), G:=Gdip_GraphicsFromHDC(hdc), Gdip_SetInterpolationMode(G, 7)
			Gdip_DrawImage(G, pBitmap, 0, 0, PW*LogoSize//100, PH*LogoSize//100, 0, 0, PW, PH)
			UpdateLayeredWindow(Hwnd, hdc, Min(A_ScreenWidth-(PW*LogoSize//100),Yzimeini["Hidden","X"]?Yzimeini["Hidden","X"]:A_ScreenWidth-A_ScreenWidth//5-(PW*LogoSize//200)), Min(A_ScreenHeight-100,Yzimeini["Hidden","Y"]?Yzimeini["Hidden","Y"]:A_ScreenHeight-TrayWnd_Height-(PH*LogoSize//100)), PW*LogoSize//100, PH*LogoSize//100)
			SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
		}
	}
	If (fg){
		Gui 2:Show, NA
		WinSet, AlwaysOnTop, On, ahk_id%Hwnd%
		Menu, Tray, Icon, %DataPath%Yzime.icl, 1, 1
	} Else {
		Gui 2:Hide
		Menu, Tray, Icon, %DataPath%Yzime.icl, 2, 1
	}
	TSFMem.SetFlags(!A_IsSuspended&&fg?1:0)

	If (Different&&state){
		WinGet, exe, ProcessName, A
		AppIMEtable[exe]:=fg
	}
}
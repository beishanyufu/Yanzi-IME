; ##################################################################################################################################################################
; # 声明：此文件基于开源仓库 <https://gitee.com/orz707/Yzime> (Commit:d1d0d9b15062de7381d1e7649693930c34fca53d) 
; # 中的同名文件修改而来，并使用相同的开源许可 GPL-2.0 进行开源，具体的权利、义务和免责条款可查看根目录下的 LICENSE 文件
; # 修改者：北山愚夫
; # 修改时间：2024年3月15日 
; ##################################################################################################################################################################

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;~ 原作者:  河许人 && 天黑请闭眼
;~ 环境 版本:   Autohotkey v1.1.32.00 Win10Pro
; 部分自定义设置（热键修改等）可以写入主目录\Lib\usercustoms.ahk文件中
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#NoEnv
#MaxMem 2048
#NoTrayIcon
#KeyHistory 0
#SingleInstance Off
#MaxHotkeysPerInterval 400	; receive 400 Hotkeys per 2 seconds
hMutex:=DllCall("CreateMutex", "Ptr", 0, "Int", 0, "Str", "Yzime_Run_OnlyOne")
If (DllCall("GetLastError")=183)
	ExitApp
OnExit, Exit
ListLines, Off
SetBatchLines, -1
SetKeyDelay, 0, 0
DetectHiddenWindows, On
Process, Priority,, High
CoordMode, Caret, Screen
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetWorkingDir %A_ScriptDir%
CloseOtherYZ()
OnClipboardChange("ClipChanged")
OnClipboardChange("CheckClipboard",-1)
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x4a, "Receive_WM_COPYDATA")
OnMessage(0x11, "WM_QUERYENDSESSION")
OnMessage(0x16, "WM_ENDSESSION")
OnMessage(0x444, "WM_TSFMSG")
eng_key:="'"
func_key:="/"
lspy_key:="z"
srf_symbol:={"``":["``","·"], "~":["~","~"], "!":["!","！"], "@":["@","@"], "#":["#","#"], "$":["$","￥"], "%":["%","%"], "^":["^","……"], "&":["&","&"], "*":["*","*"], "(":["(","（）{Left}"], ")":[")","）"]
, "_":["_","——"], "-":["-","-"], "+":["+","+"], "=":["=","="], "[":["[","【】{Left}"], "]":["]","】"], "{":["{","{}{Left}"], "}":["}","}"], "\":["\","、"], "|":["|","|"], ";":[";","；"], ":":[":","："]
, "'":["'","‘’{Left}"], """":["""","“”{Left}"], "<":["<","《》{Left}"],">":[">","》"],",":[",","，"],".":[".","。"], "/":["/","/"], "?":["?","？"]}
Gosub srf_init
Menu Tray, Icon
SetTimer, EmptyMem, 30000
EmptyMem(), DllCall("CloseHandle", "Ptr", hMutex), hMutex:=0
Return

; Include
#Include %A_ScriptDir%
#Include Lib\Yzlibfunc.ahk	; 常用函数库
#Include Lib\keylist.ahk	; 热键设置
#Include Lib\Gdip.ahk		; Gdip类库
#Include Lib\EasyIni.ahk	; ini类库
#Include Lib\Class_SQLiteDB.ahk	; SQLite类库
#Include Lib\ToolTip.ahk	; ToolTip样式
#Include Lib\DrawHXGUI.ahk	; Gdip样式候选框
#Include Lib\srf_Init.ahk	; 初始化
#Include Lib\srf_IME.ahk	; 找词、功能跳转、显示候选
#Include Lib\srf_func.ahk	; 输入法上屏等函数
#Include Lib\srf_Option.ahk	; 选项界面
#Include Lib\Ciku_Manager.ahk   ; 词库管理界面
#Include Lib\functions.ahk	; 内置命令模块
#Include Lib\suanfa_pinyin.ahk	; 拼音类算法
; #Include Lib\suanfa_sanma.ahk	; 二三码混打算法(2码+1辅助码)
#Include Lib\suanfa_xingma.ahk	; 非全拼类算法
#Include Lib\suanfa_lianda.ahk	;
#Include Lib\game_Main.ahk	; 打字小游戏
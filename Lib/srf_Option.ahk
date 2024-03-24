; ##################################################################################################################################################################
; # 声明：此文件基于开源仓库 <https://gitee.com/orz707/Yzime> (Commit:d1d0d9b15062de7381d1e7649693930c34fca53d) 
; # 中的同名文件修改而来，并使用相同的开源许可 GPL-2.0 进行开源，具体的权利、义务和免责条款可查看根目录下的 LICENSE 文件
; # 修改者：北山愚夫
; # 修改时间：2024年3月15日 
; ##################################################################################################################################################################

Option:
Option_Adv:
	If WinExist("ahk_id" HGui3){
		WinActivate, ahk_id%HGui3%
		Return
	}
	OnMessage(0x200, "WM_MOUSEMOVE")
	Gui, 3:Destroy
	DB.GetTable("SELECT name FROM sqlite_master WHERE type='table' AND NOT instr(tbl_name,'@') AND tbl_name NOT IN ('symbol','customs','functions','hotstrings','pinyin','hebing','sqlite_sequence') ORDER BY name",TableInfo)
	xingmaleitable:=""
	Loop % TableInfo.RowCount
		xingmaleitable .= "|" TableInfo.Rows[A_Index,1]
	xingmaleitable:=xingmaleitable?xingmaleitable:"|"
	Gui, 3:+hwndHGui3
	Gui, 3:Default
	Gui, 3:Margin, 12, 12
	Gui, 3:Font, s10 bold, %GUIFont%
	Gui, 3:Add, Tab3, xp yp+15 gswitchtab AltSubmit, 常规|按键|界面|进阶|燕子|关于
	Gui, 3:Tab, 1
	Gui, 3:Font, s10 norm, %GUIFont%
	Gui, 3:Add, CheckBox, xm+15 ym+45 Section gStarting vStartingup Checked%Startingup%, 开机启动
	Gui, 3:Add, CheckBox, x+25 yp gini_Settings vAutoupdatefg Disabled Checked%Autoupdatefg%, 自动更新
	Gui, 3:Add, CheckBox, x+25 yp gEnableUIAccess vUIAccess Disabled Checked%UIAccess%, UIAccess
	Gui, 3:Add, CheckBox, x+25 yp gini_Settings vMemoryDB Checked%MemoryDB%, 内存数据库
	Gui, 3:Add, CheckBox, % "xs y+10 gInstallTSF Disabled Checked" (DllCall(A_ScriptDir "\tsf\Yzime" (A_PtrSize=8?"64":"") ".dll\IsYzimeInstall")=1), 启用TSF
	Gui, 3:Add, Text, x+20 Right, 发送延时：
	Gui, 3:Add, DropDownList, x+0 yp-5 hp-2 w50 r10 gini_Settings vSendDelay, 0|1|2|3|4|5|6|7|8|9|10
	Gui, 3:Add, Text, x+20 yp+5 Right Disabled, Debug：
	Gui, 3:Add, DropDownList, x+0 yp-5 hp-2 w90 r5 gini_Settings Disabled vDebugLevel AltSubmit Choose%DebugLevel%, log|DebugView|MsgBox|测速|禁用
	GuiControlGet, tempP, 3:Pos, DebugLevel
	tvar:=tempPx+tempPw-30
	GuiControlGet, tempP, 3:Pos, MemoryDB
	tvar:=Max(tempPx+tempPw-30,tvar)

	; GuiControlGet, tempP, 3:Pos, Superrun
	; GuiControl, 3:Move, 辅助功能, % "h" tempPh*2+50
	Gui, 3:Add, GroupBox, xm+15 y+5 w%tvar% h100, 输入模式
	Gui, 3:Add, Text, xp+15 yp+25, 默认状态：
	Gui, 3:Add, DropDownList, x+0 yp-5 w80 gini_Settings vIMEmode AltSubmit Choose%IMEmode%, 英文|中文
	Gui, 3:Add, Checkbox, x+15 yp+5 gini_Settings vEnSymbol Checked%EnSymbol%, 使用英文标点
	Gui, 3:Add, CheckBox, x+15 gini_Settings vTraditional Checked%Traditional%, 繁体输入
	Gui, 3:Add, Checkbox, xm+30 y+15 gini_Settings vDifferent Checked%Different%, 允许每个应用使用不同的输入模式
	Gui, 3:Add, Button, x+30 yp-5 gappmanager, 应用管理
	GuiControlGet, tempP, 3:Pos, 应用管理
	GuiControl, 3:Move, 输入模式, % "h" tempPh*2+35
	Gui, 3:Add, GroupBox, xm+15 y+15 w%tvar% h70, 输入方案
	Gui, 3:Add, Radio, xp+15 yp+25 gshurulei AltSubmit, 拼音类
	Gui, 3:Add, Radio, x+20 yp gshurulei AltSubmit, 形码类
	Gui, 3:Add, DropDownList, x+5 yp-5 w110 gsurufangan v_Inputscheme, % Trim(pinyinlist,"|")
	Gui, 3:Add, Button, % "x+30 yp-1 gmhymanager Hidden" (shurulei!="pinyin"), 模糊音设置
	GuiControlGet, tempP, 3:Pos, 拼音类
	GuiControl, 3:Move, 输入方案, % "h" tempPh+40
	Gui, 3:Add, GroupBox, xm+15 y+20 w%tvar% h95 Section, 输入选项
	Gui, 3:Add, Checkbox, xm+30 yp+25 gini_Settings vShowquanpin Checked%Showquanpin% Hidden, 扩展到全拼
	Gui, 3:Add, Checkbox, x+15 yp gini_Settings vfuzhuma Checked%fuzhuma% Hidden, 直接辅助码
	Gui, 3:Add, Checkbox, x+15 yp gini_Settings vdwxg Checked%dwxg% Hidden, 定位修改
	Gui, 3:Add, Checkbox, x+15 yp gini_Settings vbmhg Checked%bmhg% Hidden, 编码回改
	Gui, 3:Add, Checkbox, xm+30 y+10 gini_Settings vSaveCloud Checked%SaveCloud% Hidden, 保存云结果
	Gui, 3:Add, Checkbox, x+15 yp gini_Settings vCloudInput Checked%CloudInput% Hidden, 云输入
	Gui, 3:Add, Checkbox, x+15 yp gini_Settings vchaojijp Checked%chaojijp% Hidden, 超级简拼
	Gui, 3:Add, Checkbox, x+15 yp gini_Settings vfyfz Checked%fyfz% Hidden, 翻页进入辅助
	GuiControlGet, tempP, 3:Pos, SaveCloud
	GuiControl, 3:Move, 输入选项, % "h" tempPh*2+50
	Gui, 3:Add, CheckBox, xm+30 ys+25 gini_Settings vwumaqc Checked%wumaqc% Hidden, 空码清除
	Gui, 3:Add, CheckBox, x+20 yp gini_Settings vsimasp Checked%simasp% Hidden, 无重上屏
	Gui, 3:Add, CheckBox, x+20 yp gini_Settings vwumasp Checked%wumasp% Hidden, 顶字上屏
	Gui, 3:Add, CheckBox, x+20 yp gini_Settings vdgsp Checked%dgsp% Hidden, 顶功
	Gui, 3:Add, CheckBox, xm+30 y+10 gini_Settings vShowCode Checked%ShowCode% Hidden, 编码反查
	Gui, 3:Add, CheckBox, x+20 yp gini_Settings vzigen Checked%zigen% Hidden, 显示字根
	Gui, 3:Add, CheckBox, x+20 yp gini_Settings vlspy Checked%lspy% Hidden, %lspy_key%引导拼音
	Gui, 3:Add, GroupBox, xm+15 y+20 w%tvar% h95, 其他选项
	Gui, 3:Add, CheckBox, xm+30 yp+25 gini_Settings vWordfrequency Checked%Wordfrequency%, 动态调频
	Gui, 3:Add, CheckBox, x+15 gini_Settings vfixedword Checked%fixedword%, 字频固定
	Gui, 3:Add, CheckBox, x+15 gini_Settings vTofirst Checked%Tofirst%, 一次到顶
	Gui, 3:Add, CheckBox, x+15 gini_Settings vdecfre Checked%decfre%, 重码词降频
	Gui, 3:Add, Checkbox, xm+30 y+10 gini_Settings vLearning Checked%Learning%, 自学习　
	Gui, 3:Add, CheckBox, x+15 gini_Settings vFirstNotSave Checked%FirstNotSave%, 首选不存
	Gui, 3:Add, CheckBox, x+15 gini_Settings vImagine Checked%Imagine%, 联想　　
	Gui, 3:Add, CheckBox, x+15 gini_Settings vUseless Checked%Useless%, 隐藏低频
	GuiControlGet, tempP, 3:Pos, Learning
	GuiControl, 3:Move, 其他选项, % "h" tempPh*2+50
	Gui, 3:Tab, 2
	Gui, 3:Add, GroupBox, xm+15 ym+40 w%tvar% h150, 输入法热键
	Gui, 3:Add, Text, xm+40 yp+30 w80 Right, 切换热键：
	Gui, 3:Add, Edit, x+0 yp-5 w100 vsrfhotkey, %Switch%
	Gui, 3:Add, Button, x+15 yp-1 gsethotkey, 设置
	Gui, 3:Add, CheckBox, x+20 yp+5 gini_Hotkey vDouble Checked%Double%, 双击切换
	Gui, 3:Add, Text, xm+40 y+25 w80 Right, Enter键：
	Gui, 3:Add, DropDownList, x+0 yp-5 w80 AltSubmit vEnterfg gini_Hotkey Choose%Enterfg%, 清除编码|上屏编码
	Gui, 3:Add, Text, x+35 yp+5 w60 Right, Esc键：
	Gui, 3:Add, DropDownList, x+0 yp-5 w80 AltSubmit vEscfg gini_Hotkey Choose%Escfg%, 清除编码|先清后关|英文模式
	Gui, 3:Add, Text, xm+40 y+20 w80 Right, Shift键：
	Gui, 3:Add, DropDownList, x+0 yp-5 w80 AltSubmit vShiftfg gini_Hotkey Choose%Shiftfg%, 清除编码|上屏编码|上屏并切换|辅助码筛选
	Gui, 3:Add, Text, x+35 yp+5 w60 Right, 翻页键：
	Gui, 3:Add, DropDownList, x+0 yp-5 w80 vfanyefg gini_Hotkey, Pgup PgDn|[]|-=||[] -=|,.
	Gui, 3:Add, Text, xm+40 y+20 w80 Right, 以词定字：
	Gui, 3:Add, Radio, x+20 gsetycdz Checked, 无
	Gui, 3:Add, Radio, x+20 gsetycdz, 减号/等号
	Gui, 3:Add, Radio, x+20 gsetycdz, 左右方括号
	Gui, 3:Add, Text, xm+40 y+20 w80 Right, 二三候选：
	Gui, 3:Add, CheckBox, % "x+20 gersankey Checked" InStr(Yzimeini["Hotkey","23hx"],";'"), `;'键
	Gui, 3:Add, CheckBox, % "x+20 gersankey Checked" InStr(Yzimeini["Hotkey","23hx"],"Shift"), 左右Shift
	Gui, 3:Add, CheckBox, % "x+20 gersankey Checked" InStr(Yzimeini["Hotkey","23hx"],"Ctrl"), 左右Ctrl
	GuiControlGet, tempP, 3:Pos, 二三候选：
	GuiControl, 3:Move, 输入法热键, % "h" tempPy+tempPh-35
	Gui, 3:Tab, 3
	Gui, 3:Add, GroupBox, xm+15 ym+40 w%tvar% h325, 候选窗口
	Gui, 3:Add, Text, xm+45 yp+30, 文本字体：
	Gui, 3:Font, s8
	Gui, 3:Add, DropDownList, x+0 yp w160 hp r10 gini_GuiStyle vTextFont, % ListFonts()
	Gui, 3:Font, s10
	Gui, 3:Add, Text, x+30 yp, 字号：
	Gui, 3:Add, Edit, x+0 yp-5 w50 Limit2 Number vFontSize
	Gui, 3:Add, UpDown, Range8-40, 20
	Gui, 3:Add, Text, xm+45 y+15, 符号字体：
	Gui, 3:Font, s8
	Gui, 3:Add, DropDownList, x+0 w160 hp r10 gini_GuiStyle vSymbolFont, % ListFonts()
	Gui, 3:Font, s10
	Gui, 3:Add, Checkbox, x+75 gini_GuiStyle vFontBold Checked%FontBold%, 粗体
	Gui, 3:Add, Text, xm+45 y+20, 编码颜色：
	Gui, 3:Add, Button, x+0 yp-5 w76 gsetcolor vCodeColor, % SubStr(CodeColor, -5)
	Gui, 3:Add, Text, x+30 yp+5 w100 Right, 文本颜色：
	Gui, 3:Add, Button, x+0 yp-5 w76 gsetcolor vTextColor, % SubStr(TextColor, -5)
	Gui, 3:Add, Text, xm+45 y+15, 背景颜色：
	Gui, 3:Add, Button, x+0 yp-5 w76 gsetcolor vBackgroundColor, % SubStr(BackgroundColor, -5)
	Gui, 3:Add, Text, x+30 yp+5 w100 Right, 边框颜色：
	Gui, 3:Add, Button, x+0 yp-5 w75 gsetcolor vBorderColor, % SubStr(BorderColor, -5)
	Gui, 3:Add, Text, xm+45 y+15, 焦点文本：
	Gui, 3:Add, Button, x+0 yp-5 w76 gsetcolor vFocusColor, % SubStr(FocusColor, -5)
	Gui, 3:Add, Text, x+30 yp+5 w100 Right, 焦点背景：
	Gui, 3:Add, Button, x+0 yp-5 w75 gsetcolor vFocusBackColor, % SubStr(FocusBackColor, -5)
	For key,value In ["CodeColor","TextColor","BackgroundColor","BorderColor","FocusBackColor","FocusColor"]
		SetButtonColor(value, "0x" %value%)
	Gui, 3:Add, Text, xm+45 y+15, 候选项数：
	Gui, 3:Add, DropDownList, x+1 yp-5 w74 vListNum gini_GuiStyle, 2|3|4|5
	Gui, 3:Add, Text, x+31 yp+5 w100 Right, 中英文指示器：
	Gui, 3:Add, Edit, x+0 yp-5 w40 Limit2 Number vLogoSize
	Gui, 3:Add, UpDown, Range1-99, 10
	Gui, 3:Add, Text, x+7 yp+5, `像素
	Gui, 3:Add, Text, xm+45 y+20, 显示样式：
	Gui, 3:Add, DropDownList, x+1 yp-5 w74 vToolTipStyle gini_GuiStyle AltSubmit Choose%ToolTipStyle%, ToolTip|Gdip
	Gui, 3:Add, CheckBox, x+50 yp+5 w100 vLockedposition gini_GuiStyle Checked%Lockedposition%, 固定位置
	Gui, 3:Add, Text, xm+45 y+20, 排列方式：
	Gui, 3:Add, Radio, % "x+30 yp vHorizontal gTextdirection Checked" (Textdirection="Horizontal"), 横版
	Gui, 3:Add, Radio, % "x+30 yp vVertical gTextdirection Checked" (Textdirection="Vertical"), 竖版
	GuiControlGet, tempP, 3:Pos, 排列方式：
	GuiControl, 3:Move, 候选窗口, % "h" tempPy-15
	Gui, 3:Tab, 4
	Gui, 3:Add, GroupBox, xm+15 ym+40 w%tvar% h60, 进阶功能
	Gui, 3:Add, CheckBox, xp+15 yp+25 gini_Settings vSuperrun Checked%Superrun%, 超级命令
	Gui, 3:Add, CheckBox, x+15 gini_Settings vMagicstring Checked%Magicstring%, 魔法字符串
	Gui, 3:Add, CheckBox, x+15 gini_Settings vClipHistory Checked%ClipHistory%, 剪贴板历史
	Gui, 3:Add, CheckBox, x+15 gini_Settings vMouseCross Checked%MouseCross%, 鼠标划词
	; Gui, 3:Add, CheckBox, xm+30 yp+25 gini_Settings vRobot Checked%Robot%, Robot
	Gui, 3:Add, GroupBox, xm+15 y+20 w%tvar% r10, 命令管理
	Gui, 3:Add, ListView, % "xm+30 yp+25 w" tvar-30 " r11 vFuncLV -ReadOnly AltSubmit gFuncLV hwndHFuncLV"
	GuiControlGet, tempP, 3:Pos, FuncLV
	GuiControl, 3:Move, 命令管理, % "h" tempPh+40
	Gui, 3:Tab, 5
	Gui, 3:Add, GroupBox, xm+15 ym+40 w%tvar% h325, 扩展选项
	Gui, 3:Add, CheckBox, xm+45 yp+30 gini_Settings vtfuzhuma Checked%tfuzhuma%, 直接输入的间接辅助码
	Gui, 3:Add, CheckBox, xm+45 yp+30 gini_Settings vShowFZM Checked%ShowFZM%, 显示候选项辅助码
	Gui, 3:Add, CheckBox, xm+45 yp+30 gini_Settings vFirstZi Checked%FirstZi%, 辅助码仅针对首字
	Gui, 3:Add, CheckBox, xm+45 yp+30 gini_Settings vShowLogo Checked%ShowLogo%, 显示中英文指示器
	Gui, 3:Add, CheckBox, xm+45 yp+30 gini_Settings vConnectIMEandCursor Checked%ConnectIMEandCursor%, 支持 IME-and-Cursor
	GuiControlGet, tempP, 3:Pos, ConnectIMEandCursor
	GuiControl, 3:Move, 扩展选项, % "h" tempPy-15
	Gui, 3:Tab, 6
	Gui, 3:Add, Picture, xm+10 ym+50 w35 h-1 Icon1, %DataPath%Yzime.icl
	Gui, 3:Font, s15 Bold, %GUIFont%
	Gui, 3:Add, Text, x+5 yp+5, 燕子输入法
	Gui, 3:Font, s10 norm , %GUIFont%
	Gui, 3:Add, Text, x+0 yp+7, % " (" A_PtrSize*8 "位 Beta)"
	Gui, 3:Add, Text, x+20, % "版本：" srf_default_value["Version","Version"] " (2024.3.24)"
	Gui, 3:Add, GroupBox, xm+15 y+10 w%tvar% r4, 简介
	Gui, 3:Add, Text, % "xm+35 yp+25 w" tvar-30, 燕子输入法改编自影子输入法。主要是编制了新的辅助码表并重写了辅助码的输入和筛选逻辑，意在通过更自然和强包容性的设计彻底去除辅助码的使用门槛，从而让更多人受益。`n此外，燕子输入法还添加了中英文模式指示器并内置了对 VS Code 插件 IME-and-Cursor（v1.4+）的支持。`n燕子的前身影子输入法是 “由河许人发起，天黑请闭眼深度开发的简单、简洁、高度自定义的输入法。影子输入法起源于 AutoHotkey 高手群 Hello_srf 开发的柚子输入法，融合了承影和 jip 输入法的理念”。 
	GuiControlGet, tempP, 3:Pos, Static29
	GuiControl, 3:Move, 简介, % "h" tempPh+40
	Gui, 3:Add, Text, xm+10 y+25 w80 Right, 源代码:
	Gui, 3:Add, Link, x+10 yp, <a href="https://github.com/beishanyufu/Yanzi-IME">https://github.com/beishanyufu/Yanzi-IME</a>
	Gui, 3:Add, Picture, xm+15 yp w20 h-1 Icon11, %DataPath%Yzime.icl
	Gui, 3:Add, Picture, xm+15 y+15 w20 h-1 Icon12, %DataPath%Yzime.icl
	Gui, 3:Font, s10 Bold, %GUIFont%
	Gui, 3:Add, Text, x+10 yp, 感谢
	Gui, 3:Font, s10 norm, %GUIFont%
	Gui, 3:Add, Text, % "y+5 w" tvar-60, 感谢影子输入法和柚子输入法的创作者们！如果把你们完成的工作比作一间大房子，本输入法就是筑巢于房檐下的一只小燕子~
	
	If (Inputscheme~="sp$|pinyin"){
		GuiControl, 3:, 拼音类, 1
		_Inputscheme:=pinyinec[Inputscheme]
		GuiControl, % "3:Disable" (Inputscheme="pinyin"), Showquanpin
		Loop 8
			GuiControl, 3:Show, % "Button" (A_Index+15)
	} Else {
		GuiControl, 3:, 形码类, 1
		GuiControl, 3:, _Inputscheme, %xingmaleitable%
		_Inputscheme:=Inputscheme
		Loop 7
			GuiControl, 3:Show, % "Button" (A_Index+23)
		GuiControl, 3:Text, Imagine, 逐码提示
		GuiControl, 3:Text, Learning, 引导学习
	}
	GuiControlGet, tempP, 3:Pos, 其他选项
	GuiControl, 3:Move, SysTabControl321, % "h" tempPy+tempPh
	For Value,Key In ["_Inputscheme","SendDelay","TextFont","SymbolFont","ListNum","fanyefg"]
		GuiControl, 3:ChooseString, %Key%, % StrDeref(%Key%)
	; GuiControl, 3:, ShowCode, % Yzimeini["Settings", "ShowCode"]
	GuiControl, 3:Text, FontSize, %FontSize%
	GuiControl, 3:Text, LogoSize, %LogoSize%
	; GuiControl, 3:, %Textdirection%, 1
	; GuiControl, 3:, ShowFZM, %ShowFZM%
	GuiControl, 3:, % (ycdzfg="-="?"减号/等号":ycdzfg="[]"?"左右方括号":"无"), 1
	For Key, Value In ["Superrun","Magicstring","ClipHistory","MouseCross"]
		GuiControl, 3:, %Value%, % Yzimeini["Settings",Value]
	If InStr(fanyefg,"-=")
		GuiControl, 3:, 减号/等号, 0
	If InStr(fanyefg,"[]")
		GuiControl, 3:, 左右方括号, 0
	Yzimeini["Hotkey","ycdzfg"]:=ycdzfg:=(fanyefg="[] -="?"":StrReplace(ycdzfg,fanyefg))
	GuiControl, % "3:Disable" (InStr(fanyefg,"-=")?1:0), 减号/等号
	GuiControl, % "3:Disable" (InStr(fanyefg,"[]")?1:0), 左右方括号
	SendMessage, 0x1501, 1, "Enter Hotkey Name", Edit3, ahk_id%HGui3%
	; GuiControl, 3:Text, srfhotkey, %Switch%
	GuiControl, 3:, Double, % Yzimeini["Hotkey","Double"]
	GuiControl, 3:Enable%Different%, 应用管理
	GuiControl, 3:Enable%lspy%, ShowCode
	GuiControl, 3:Enable%Wordfrequency%, fixedword
	GuiControl, 3:Enable%Wordfrequency%, decfre
	GuiControl, 3:Enable%Wordfrequency%, Tofirst
	GuiControl, % "3:Disable" InStr(Yzimeini["Hotkey","23hx"],"Shift"), Shiftfg
	GuiControl, 3:-ReDraw, FuncLV
	LV_InsertCol(1, "75", "命令名")
	LV_InsertCol(2, "110", "自定义命令名")
	LV_InsertCol(3, "500", "说明(s选择的文本，c剪切板中的文本)")
	For Key, Value in srf_Default_Func
		LV_Add("", Value[1], srf_Custom_Func[Value[1]], Value[2])
	LV_ModifyCol(3, "AutoHdr")
	LV_ModifyCol(1, "Sort")
	GuiControl, 3:+ReDraw, FuncLV
	DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HFuncLV, "Str", "Explorer", "Ptr", 0)
	ICELV2:=New LV_InCellEdit(HFuncLV, True, True)
	ICELV2.SetColumns(1, 3)
	ICELV2.OnMessage()
	If (A_ThisLabel="Option_Adv")
		GuiControl, 3:Choose, SysTabControl321, |4
	; GuiControl, 3:Choose, SysTabControl321, |5
	Gui, 3:Show, AutoSize, 燕子输入法 选项
	GuiControl, 3:+gini_GuiStyle, FontSize
	GuiControl, 3:+gini_GuiStyle, LogoSize
Return

mhymanager(){
	global GUIFont, Yzimeini
	Gui, 3:Hide
	Gui, mhy:Destroy
	Gui, mhy:+AlwaysOnTop -MinimizeBox
	Gui, mhy:Margin, 25, 25
	Gui, mhy:Color, White
	Gui, mhy:Font, s12 norm, %GUIFont%
	Gui, mhy:Add, CheckBox, w100 gsetmohuyingobj, c=ch
	Gui, mhy:Add, CheckBox, x+25 w100 gsetmohuyingobj, s=sh
	Gui, mhy:Add, CheckBox, x+25 w100 gsetmohuyingobj, z=zh
	Gui, mhy:Add, CheckBox, xm y+10 w100 gsetmohuyingobj, an=ang
	Gui, mhy:Add, CheckBox, x+25 w100 gsetmohuyingobj, en=eng
	Gui, mhy:Add, CheckBox, x+25 w100 gsetmohuyingobj, in=ing
	Gui, mhy:Add, CheckBox, xm y+10 w100 gsetmohuyingobj, ian=iang
	Gui, mhy:Add, CheckBox, x+25 w100 gsetmohuyingobj, uan=uang
	Gui, mhy:Add, CheckBox, x+25 w100 gsetmohuyingobj, ai=an
	Gui, mhy:Add, CheckBox, xm y+10 w100 gsetmohuyingobj, un=ong
	Loop 10
		GuiControl, mhy: , Button%A_Index%, % (SubStr(Yzimeini["Settings","mhy"],A_Index,1)?1:0)
	Gui, mhy:Show, , 模糊音设置
	Return
	mhyGuiClose:
	mhyGuiEscape:
		Gui, mhy:Destroy
		Gui, 3:Show
	Return
}
setycdz(){
	global ycdzfg, Yzimeini
	ycdzfg:=Yzimeini["Hotkey","ycdzfg"]:=(A_GuiControl="无"?"":A_GuiControl="减号/等号"?"-=":"[]")
}
setmohuyingobj(hwnd:=0){
	global mhyRegExObj, Yzimeini, shurulei, Inputscheme, custommhy, pinyinec
	static ls:={c:1,s:2,z:3,an:4,en:5,in:6,ian:7,uan:8,ai:9,un:10}
	If (hwnd>0&&A_GuiControl){
		GuiControlGet, t, mhy:, %A_GuiControl%
		i:=ls[StrSplit(A_GuiControl,"=")[1]], Yzimeini["Settings","mhy"]:=SubStr(Yzimeini["Settings","mhy"],1,i-1) t SubStr(Yzimeini["Settings","mhy"],i+1)
	}
	mhyRegExObj:=[], m:=["c","s","z"], t:=""
	Loop 3
		t .= SubStr(Yzimeini["Settings","mhy"],A_Index,1)?m[A_Index]:""
	If (t)
		mhyRegExObj.Push(["'([" t "])h?","'$1h?"])
	m:=["[^iu]a","e","i","ia","ua"], t:=""
	Loop 5
		t .= SubStr(Yzimeini["Settings","mhy"],A_Index+3,1)?m[A_Index] "|":""
	If (t)
		mhyRegExObj.Push(["(" Trim(t,"|") ")ng?'","$1ng?'"])
	If SubStr(Yzimeini["Settings","mhy"],9,1)
		mhyRegExObj.Push(["a[ni]'","a[ni]'"])
	If SubStr(Yzimeini["Settings","mhy"],10,1)
		mhyRegExObj.Push(["(un|ong)","(un|ong)"])
	If pinyinec.HasKey(Inputscheme)
		Loop % custommhy.Length()
			mhyRegExObj.Push(custommhy[A_Index])
	If (hwnd>=0)
		pyfenci(Chr(1),!hwnd&&shurulei="pinyin"?Inputscheme:"")
}
FuncLV:
	If (A_GuiEvent == "F")&&(ICELV2["Changed"]){
		If (srf_func_hk[LTrim(ICELV2.ItemText,"&")]){
			; Hotkey If, srf_mode
			; Try Hotkey, % LTrim(ICELV2.ItemText,"&"), Off
			; Hotkey If
			Try Hotkey, % LTrim(ICELV2.ItemText,"&"), Off
		}
		ICELV2.Remove("Changed"), tarr:=[]
		Loop % LV_GetCount(){
			LV_GetText(tvar, A_Index), LV_GetText(CustomFuncName, A_Index, 2)
			If CustomFuncName
				tarr[tvar]:=CustomFuncName
		}
		Yzimeini["Func","CustomFuncName"]:=JSON.Dump(tarr), srf_Custom_Func:=tarr, tarr:=[]
		Gosub Registrationfuncandlabel
	}
Return

InstallTSF(){
	bat:=""
	GuiControlGet, ck, , %A_GuiControl%
	If (ck){
		If (!FileExist(A_ScriptDir "\tsf\Yzime.dll"))
			If (!ZIPDownloadToFile("https://gitee.com/orz707/Yzime/raw/zip/tsf.7z", A_ScriptDir "\tsf\tsf.7z")){
				GuiControl, , %A_GuiControl%, 0
				Return 0
			}
		bat = regsvr32 "%A_ScriptDir%\tsf\Yzime.dll"
		If (A_Is64bitOS)
			bat .= " && regsvr32 """ A_ScriptDir "\tsf\Yzime64.dll"""
	} Else {
		bat = regsvr32 /u "%A_ScriptDir%\tsf\Yzime.dll"
		If (A_Is64bitOS)
			bat .= " && regsvr32 /u """ A_ScriptDir "\tsf\Yzime64.dll"""
	}
	Try {
		RunWait *RunAs cmd.exe /c "%bat%", , Hide
		If (!ck)
			Gosub srfreload
	} Catch e {
		If (e.what="SendMessage" && e.message="FAIL")
			Gosub srfreload
		GuiControl, , %A_GuiControl%, % !ck
	}
}

appmanager(){
	local
	global ClipWindows, IMECnWindows, IMEEnWindows, GUIFont, YzimePID, Yzimeini
	Gui, 3:Hide
	Gui, app:Destroy
	Gui, app:+AlwaysOnTop -MinimizeBox
	Gui, app:Font, s12, %GUIFont%
	Gui, app:Add, Radio, xm yp+10 Checked1, 进程名
	Gui, app:Add, Radio, x+40, 类名
	Gui, app:Add, Edit, xm y+10 -Multi r1 w160
	Gui, app:Add, Button, x+10 yp-2 gaddapp, 添加
	Gui, app:Add, ListView, r10 x10 w280 Grid Hwndtvar, 进程名或类名|输入状态
	DllCall("UxTheme.dll\SetWindowTheme", "Ptr", tvar, "Str", "Explorer", "Ptr", 0)
	Gui, app:Default
	LV_ModifyCol(1,160), LV_ModifyCol(2,80)
	Hotkey, IfWinExist, Alt+左键识别窗口 ahk_pid%YzimePID%
	Hotkey, !LButton, clicklbutton, On
	Hotkey, If
	Hotkey, IfWinActive, Alt+左键识别窗口 ahk_pid%YzimePID%
	Hotkey, !c, 中文, On
	Hotkey, !d, 剪贴板, On
	Hotkey, !e, 英文, On
	Hotkey, $Del, 删除, On
	Hotkey, Enter, addapp, On
	Hotkey, If
	GuiControl, app:-ReDraw, SysListView321
	For Value,Key In ["ClipWindows","IMECnWindows","IMEEnWindows"]
		Loop, Parse, %key%, `,
			LV_Add("",A_LoopField,Value=1?"剪贴板":Value=2?"中文":"英文")
	GuiControl, app:+ReDraw, SysListView321
	Gui, app:Show, , Alt+左键识别窗口
	Return
	appGuiClose:
	appGuiEscape:
		IMECnWindows:=IMEEnWindows:=ClipWindows:=""
		Loop % LV_GetCount(){
			LV_GetText(key, A_Index, 2), LV_GetText(value, A_Index, 1)
			If (key="中文")
				IMECnWindows .= "," value
			Else If (key="英文")
				IMEEnWindows .= "," value
			Else
				ClipWindows .= "," value
		}
		For Value,Key In ["ClipWindows","IMECnWindows","IMEEnWindows"]
			Yzimeini["Settings",key]:=%key%:=LTrim(%key%,",")
		Gui, app:Destroy
		Gui, 3:Show
	Return
	appGuiContextMenu:
		If LV_GetNext()
			Menu, appContextMenu, Show, % A_GuiX*A_ScreenDPI/96, % A_GuiY*A_ScreenDPI/96
	Return
	剪贴板:
	中文:
	英文:
	删除:
		Gui, app:Default
		ControlGetFocus, tvar
		If (tvar!="SysListView321"&&A_ThisHotkey="$Del"){
			Send {Del}
			Return
		}
		GuiControl, app:-ReDraw, SysListView321
		tvar:=0
		If (A_ThisLabel="删除"){
			delrows:=[]
			While tvar:=LV_GetNext(tvar)
				delrows.Push(tvar)
			Loop % delrowsnum:=delrows.Length()
				LV_Delete(delrows[delrowsnum+1-A_Index])
		} Else
			While tvar:=LV_GetNext(tvar)
				LV_Modify(tvar, "Col2", A_ThisLabel)
		GuiControl, app:+ReDraw, SysListView321
	Return
	clicklbutton:
		Gui, app:Default
		GuiControlGet, jccl,, Button1
		MouseGetPos, , , moupos
		If jccl
			WinGet, pos, ProcessName, ahk_id%moupos%
		Else
			WinGetClass, pos, ahk_id%moupos%
		GuiControl, app:, Edit1, %pos%
	Return
	addapp:
		Gui, app:Default
		GuiControlGet, jccl,, Edit1
		If (jccl="")
			Return
		GuiControl, app:-ReDraw, SysListView321
		Loop % LV_GetCount()
			LV_Modify(A_Index, "-Select -Focus")
		Loop % LV_GetCount(){
			LV_GetText(t, row:=A_Index)
			If (t=jccl)
				Break
		}
		If (t=jccl)
			LV_Modify(row, "Select Focus Vis")
		Else
			LV_Add("Select Focus Vis",jccl,"")
		ControlFocus, SysListView321
		GuiControl, app:+ReDraw, SysListView321
	Return
}

3GuiClose:
	3GuiEscape:
	Gui, 3:Hide
	ICELV2:="", Yzimeini.Save()
	If (ToolTipStyle=1&&pToken_)
		pToken_:=Gdip_Shutdown(pToken_)
	If !WinExist("ahk_id" HGui97)
		OnMessage(0x200, "")
	ToolTip
	Gui, 3:Destroy
Return

switchtab:
	GuiControlGet, tvar, , SysTabControl321
	GuiControlGet, tempP, 3:Pos, % (tvar=3?"候选窗口":tvar=2?"输入法热键":tvar=4?"命令管理":tvar=1?"其他选项":tvar=5?"Button66":"Static34")
	GuiControl, 3:Move, SysTabControl321, % "h" tempPy+tempPh
	Gui, 3:Show, AutoSize
Return

Starting:
	GuiControlGet, %A_GuiControl%, 3:, %A_GuiControl%
	If Startingup {
		If A_IsCompiled
			tvar = schtasks /Create /TN "燕子输入法" /TR "'%A_ScriptFullPath%'" /SC ONLOGON /DELAY 0000:05
		Else
			tvar := "schtasks /Create /TN ""燕子输入法"" /TR ""'" StrReplace(A_ScriptFullPath, ".ahk", ".exe") "' '" A_ScriptFullPath "'"" /SC ONLOGON /DELAY 0000:05"
		If InStr(A_ScriptFullPath, "C:")
			tvar .= " /RL HIGHEST"
		Try {
			Run *RunAs cmd.exe /c %tvar%, , Hide
			Yzimeini["Settings","Startingup"]:=Startingup
		} Catch {
			Startingup:=0
			GuiControl, 3:, Startingup, 0
		}
	} Else {
		tvar = schtasks /Delete /TN "燕子输入法" /F
		Try {
			Run *RunAs cmd.exe /c %tvar%, , Hide
			Yzimeini["Settings","Startingup"]:=Startingup
		} Catch {
			Startingup:=1
			GuiControl, 3:, Startingup, 1
		}
	}
Return

EnableUIAccess(hwnd:=""){
	global Yzimeini, UIAccess
	If (hwnd){
		GuiControlGet, UIAccess, 3:, UIAccess
		Yzimeini["Settings","UIAccess"]:=UIAccess, Yzimeini.Save()
		Try Run % StrReplace(DllCall("GetCommandLine", "Str"), "_UIA.exe", ".exe")
		ExitApp
	} Else If !A_IsAdmin&&DataInCDrive(){
		MsgBox 52, 注意, 数据文件在C:\Program Files目录，需要有管理员权限才能保存配置及词库，是否以管理员权限启动？
		IfMsgBox Yes
			Run % "*RunAs " DllCall("GetCommandLine", "Str")
	}
	If (UIAccess&&!InStr(DllCall("GetCommandLine", "Str"), "_UIA.exe")){
		If (A_IsCompiled){
			If FileExist(StrReplace(A_ProgramFiles, " (x86)") "\Yzime\" SubStr(A_ScriptName, 1, -4) "_UIA.exe"){
				Run % """" StrReplace(A_ProgramFiles, " (x86)") "\Yzime\" SubStr(A_ScriptName, 1, -4) "_UIA.exe"""
			} Else If (A_ScriptFullPath~=StrReplace(A_ProgramFiles, " (x86)")){
				If !FileExist(StrReplace(A_ScriptFullPath, ".exe", "_UIA.exe"))
					Try RunWait *RunAs "%AhkPath%" "%A_ScriptDir%\Lib\tools\EnableUIAccess.ahk" EnableUIAccess "%A_ScriptFullPath%"
					Catch
						Goto Exception
				Run % """" StrReplace(A_ScriptFullPath, ".exe", "_UIA.exe") """"
			} Else {
				Try RunWait *RunAs "%AhkPath%" "%A_ScriptDir%\Lib\tools\EnableUIAccess.ahk" EnableUIAccess "%A_ScriptFullPath%"
				Catch
					Goto Exception
				Run % """" StrReplace(A_ProgramFiles, " (x86)") "\Yzime\" SubStr(A_ScriptName, 1, -4) "_UIA.exe"""
			} 
		} Else If FileExist(StrReplace(A_ProgramFiles, " (x86)") "\Yzime\Yzime_UIA.exe"){
			Try Run % """" StrReplace(A_ProgramFiles, " (x86)") "\Yzime\Yzime_UIA.exe"" """ A_ScriptFullPath """"
			Catch e
				Goto UIAresignature
		} Else If InStr(A_ScriptFullPath, StrReplace(A_ProgramFiles, " (x86)")){
			If !FileExist(StrReplace(AhkPath, ".exe", "_UIA.exe"))
				Try RunWait *RunAs "%AhkPath%" "%A_ScriptDir%\Lib\tools\EnableUIAccess.ahk" EnableUIAccess
				Catch
					Goto Exception
			Try Run % """" StrReplace(AhkPath, ".exe", "_UIA.exe") """ """ A_ScriptFullPath """"
			Catch e
				Goto UIAresignature
		} Else {
			Try RunWait *RunAs "%AhkPath%" "%A_ScriptDir%\Lib\tools\EnableUIAccess.ahk" EnableUIAccess
			Catch
				Goto Exception
			Try Run % """" StrReplace(A_ProgramFiles, " (x86)") "\Yzime\Yzime_UIA.exe"" """ A_ScriptFullPath """"
			Catch e
				Goto UIAresignature
		}
		If (!hwnd)
			Yzimeini:=""
		ExitApp
	} Else If (!hwnd&&!UIAccess&&FileExist(StrReplace(A_ProgramFiles, " (x86)") "\Yzime"))
		Try Run *RunAs "%AhkPath%" "%A_ScriptDir%\Lib\tools\EnableUIAccess.ahk"
	Return
	Exception:
		Yzimeini["Settings","UIAccess"]:=UIAccess:=0
		If (hwnd)
			GuiControl, 3:, UIAccess, 0
	Return
	UIAresignature:
		If InStr(e.Extra, "从服务器返回了一个参照。"){
			FileDelete % A_ScriptDir "\Yzime_UIA.exe"
			MsgBox 52, Error, 签名的证书已失效，是否重新生成签名文件？
			IfMsgBox, Yes
			{
				Try Run % StrReplace(DllCall("GetCommandLine", "Str"), "_UIA.exe", ".exe")
				ExitApp
			}
			Yzimeini["Settings","UIAccess"]:=UIAccess:=0
			MsgBox 64, 提示, UIAccess权限已关闭，可能无法在部分界面（win10菜单）置顶显示，无法在管理员权限启动的应用中输入！
		} Else
			MsgBox 16, Error, % e.Message "`n" e.Extra
}

ini_GuiStyle:
ini_Settings:
ini_Hotkey:
	Gui +OwnDialogs
	GuiControlGet, %A_GuiControl%, 3:, %A_GuiControl%
	Yzimeini[SubStr(A_ThisLabel, 5), tvar:=LTrim(A_GuiControl,"_")]:=%tvar%:=%A_GuiControl%
	If (A_GuiControl="Wordfrequency"){
		GuiControl, 3:Enable%Wordfrequency%, fixedword
		GuiControl, 3:Enable%Wordfrequency%, decfre
		GuiControl, 3:Enable%Wordfrequency%, Tofirst
	} Else If (A_GuiControl~="Font|ListNum|Lockedposition"){
		Gosub houxuankuangguicreate
		If srf_all_Input
			Gosub srf_tooltip
	} Else If (A_GuiControl="Traditional"){
		If FileExist(DataPath "@s2t.txt")
			valueindex:=Traditional?5:2
		Else {
			Yzimeini["Settings","Traditional"]:=Traditional:=0
			GuiControl, 3:, Traditional, 0
			MsgBox, 48, 提示, 简繁转换文件不存在，请在Data目录下放置简繁转换文件@s2t.txt，格式如下：`n㐷=傌`n㐹=㑶 㐹`n㐽=偑`n码表=碼錶 碼表
		}
	} Else If (A_GuiControl="SendDelay")
		SendDelaymode:=(SendDelay?"{Text}{Delay," SendDelay*10 ",0}":"")
	Else If (A_GuiControl="LogoSize"){
		If (!A_IsSuspended)
			Gosub LoadLogo
	} Else If (A_GuiControl="Different"){
		GuiControl, 3:Enable%Different%, 应用管理
		If (!Different)
			AppIMEtable:=[]
	} Else If (A_GuiControl="lspy"){
		GuiControl, 3:Enable%lspy%, ShowCode
	} Else If (A_GuiControl="bmhg"){
		Hotkey If, srf_inputing&&shurulei!="xingma"
		Loop 26
			Hotkey, % "^" Chr(96+A_Index), searchinsertpos, % (bmhg?"On":"Off")
		Hotkey If
	} Else If (A_GuiControl="fanyefg"){
		If InStr(fanyefg,"-=")
			GuiControl, 3:, 减号/等号, 0
		If InStr(fanyefg,"[]")
			GuiControl, 3:, 左右方括号, 0
		Yzimeini["Hotkey","ycdzfg"]:=ycdzfg:=(fanyefg="[] -="?"":StrReplace(ycdzfg,fanyefg))
		GuiControl, % "3:Disable" (InStr(fanyefg,"-=")?1:0), 减号/等号
		GuiControl, % "3:Disable" (InStr(fanyefg,"[]")?1:0), 左右方括号
	} Else If (A_GuiControl="ShowCode"){
		If (ShowCode&&Inputscheme~="wubi|五笔")
			DB.Exec("CREATE INDEX IF NOT EXISTS ""fc_" Inputscheme """ ON """ Inputscheme """ (""value"")")
	} Else If (A_GuiControl="ToolTipStyle")
		Gosub houxuankuangguicreate
	Else If (A_GuiControl="fuzhuma"){
		If (fuzhuma && !tfuzhuma)
			Gosub ReLoadfuzhuma
		Else If (!tfuzhuma)
		 	srf_fzm_fancha_table:=""
	} Else If (A_GuiControl="tfuzhuma"){
		If (tfuzhuma && !fuzhuma)
			Gosub ReLoadfuzhuma
		Else If (!fuzhuma)
		 	srf_fzm_fancha_table:=""
	} Else If (A_GuiControl="MemoryDB"){
		If MemoryDB
			MsgBox, 64, 提示, 数据库所在磁盘性能较好时不推荐启用此选项！
		Gui, 3:+Disabled
		If (DB._Path=":memory:"&&DB.Changes){
			Suspend, On
			Progress, B2 ZH-1 ZW-1 FS12, 保存内存数据库中，请稍后...
			SaveDB(1)
			Suspend, Off
			Progress, Off
		}
		Gosub LoadDB
		Gui, 3:-Disabled
	} Else If (A_GuiControl="zigen"){
		If (zigen){
			If FileExist(DataPath "@" Inputscheme ".txt")
				MsgBox, 64, 提示, 字根提示需要相关的字体，`nGitee、群文件有字体下载。
			Else {
				Yzimeini["Settings","zigen"]:=zigen:=0
				GuiControl, 3:, zigen, 0
				MsgBox, 16, 提示, 字根提示需要字根拆分文件@%Inputscheme%.txt，`nGitee、群文件有wubi98拆分文件下载。
			}
		}
	} Else If (A_GuiControl="ConnectIMEandCursor"){
		If (ConnectIMEandCursor){
			DirectIMEandCursor(srf_mode)
			OnClipboardChange("CheckClipboard",-1)
		}
		Else{
			OnClipboardChange("CheckClipboard",0)
		}
	} Else If (A_GuiControl="ShowLogo"){
		SetYzLogo(srf_mode,0)
	}
Return

surufangan:
	GuiControlGet, _Inputscheme, 3:, _Inputscheme
	If (!_Inputscheme){
		MsgBox 无该类词库，请先导入词库后重新打开选项！！
	} Else If (shurulei="pinyin"||_Inputscheme~="双拼$|全拼"){
		Inputscheme:=pinyince[_Inputscheme], Yzimeini.Settings["Inputscheme"]:=Inputscheme
		GuiControl, % "3:Disable" (_Inputscheme="全拼"), Showquanpin
	} Else
		Yzimeini.Settings["Inputscheme"]:=Inputscheme:=_Inputscheme, shurulei:=MethodTable[Inputscheme]?MethodTable[Inputscheme]:"xingma"
Return

shurulei:
	If (A_GuiControl="形码类"){
		If (Inputscheme~="pinyin|sp$"){
			tvar:=""
			For Value,Key In ["decfre","fixedword","Imagine","Learning","Tofirst","Wordfrequency"] {
				tvar .= Yzimeini["Settings",key]
				GuiControl, 3:, %key%, % (Yzimeini["Settings",key]:=%key%:=(SubStr(Yzimeini["Settings","Settingsbak"], A_Index, 1)?1:0))
			}
			tvar .= Inputscheme
			GuiControl, 3:, _Inputscheme, %xingmaleitable%
			Inputscheme:=SubStr(Yzimeini["Settings","Settingsbak"], 7)?SubStr(Yzimeini["Settings","Settingsbak"], 7):StrSplit(xingmaleitable, "|", "|")[2]
			Yzimeini["Settings","Settingsbak"]:=tvar
			GuiControl, 3:ChooseString, _Inputscheme, %Inputscheme%
			Loop 15
				GuiControl, % "3:Hide" (A_Index<9), % "Button" (A_Index+15)
			GuiControl, 3:Text, Imagine, 逐码提示
			GuiControl, 3:Text, Learning, 引导学习
			GuiControl, 3:Enable%lspy%, ShowCode
			Yzimeini.Settings["Inputscheme"]:=Inputscheme
		}
		shurulei:=MethodTable[Inputscheme]?MethodTable[Inputscheme]:"xingma"
	} Else {
		shurulei:="pinyin"
		GuiControl, 3:, _Inputscheme, %pinyinlist%
		If !(Inputscheme~="pinyin|sp$"){
			tvar:=""
			For Value,Key In ["decfre","fixedword","Imagine","Learning","Tofirst","Wordfrequency"] {
				tvar .= Yzimeini["Settings",key]
				GuiControl, 3:, %key%, % (Yzimeini["Settings",key]:=%key%:=(SubStr(Yzimeini["Settings","Settingsbak"], A_Index, 1)?1:0))
			}
			tvar .= Inputscheme, Inputscheme:=SubStr(Yzimeini["Settings","Settingsbak"], 7)?SubStr(Yzimeini["Settings","Settingsbak"], 7):"pinyin"
			Yzimeini["Settings","Settingsbak"]:=tvar
		}
		_Inputscheme:=pinyinec[Inputscheme]
		GuiControl, 3:ChooseString, _Inputscheme, %_Inputscheme%
		GuiControl, % "3:Disable" (Inputscheme="pinyin"), Showquanpin
		Loop 15
			GuiControl, % "3:Show" (A_Index<9), % "Button" (A_Index+15)
		GuiControl, 3:Text, Imagine, 联想
		GuiControl, 3:Text, Learning, 自学习
		Yzimeini.Settings["Inputscheme"]:=Inputscheme
	}
	GuiControl, % "3:Show" (A_GuiControl="拼音类"), 模糊音设置
	GuiControl, 3:Enable%Wordfrequency%, fixedword
	GuiControl, 3:Enable%Wordfrequency%, decfre
	GuiControl, 3:Enable%Wordfrequency%, Tofirst
	GuiControlGet, tempP, 3:Pos, 其他选项
	GuiControl, 3:Move, SysTabControl321, % "h" tempPy+tempPh
	Gui, 3:Show, AutoSize
Return
ersankey:
	GuiControlGet, tvar, , %A_GuiControl%
	If (A_GuiControl="左右Shift")
		GuiControl, 3:Disable%tvar%, Shiftfg
	If (tvar){
		If (A_GuiControl=";'键")
			registersymbolhotkey(";",2,0,""), registersymbolhotkey("'",3,0,"")
		Else {
			Hotkey If, srf_inputing
			_:=Func("select_for_num").Bind(2)
			Hotkey, % StrReplace(A_GuiControl, "左右", "L"), %_%
			_:=Func("select_for_num").Bind(3)
			Hotkey, % StrReplace(A_GuiControl, "左右", "R"), %_%
			Hotkey If
		}
		Yzimeini["Hotkey","23hx"]:=Trim(Yzimeini["Hotkey","23hx"] " " RegExReplace(A_GuiControl,"[^\x00-\xff]")," ")
	} Else {
		If (A_GuiControl=";'键")
			registersymbolhotkey({";":"","'":""},,,,0)
		Else {
			Hotkey If, srf_inputing
			Try Hotkey, % StrReplace(A_GuiControl, "左右", "L"), Off
			Try Hotkey, % StrReplace(A_GuiControl, "左右", "R"), Off
			Hotkey If
		}
		Yzimeini["Hotkey","23hx"]:=Trim(RegExReplace(Yzimeini["Hotkey","23hx"],"i)" RegExReplace(A_GuiControl,"[^\x00-\xff]"))," ")
	}
Return

Textdirection:
	Textdirection:=Yzimeini["GuiStyle","Textdirection"]:=A_GuiControl
Return

setcolor(){
	Critical, Off
	global srf_all_Input, Yzimeini, HGui3
	Gui, 3:Default
	tempColor:="0x" Yzimeini["GuiStyle",A_GuiControl]
	If Dlg_Color(tempColor, HGui3){
		%A_GuiControl%:=SubStr(tempColor, 3)
		Yzimeini["GuiStyle",A_GuiControl]:=(StrLen(Yzimeini["GuiStyle",A_GuiControl])=8?SubStr(Yzimeini["GuiStyle",A_GuiControl],1,2):"") SubStr(tempColor, 3)
		GuiControl,, %A_GuiControl%, % SubStr(tempColor, 3)
		SetButtonColor(A_GuiControl, tempColor)
		Gosub houxuankuangguicreate
		If srf_all_Input
			Gosub showhouxuankuang
	}
}

sethotkey:
	Gui 3:+OwnDialogs
	GuiControlGet, srfhotkey, 3:, srfhotkey
	If (srfhotkey=Switch)||(srfhotkey~="i)^[a-z\d,\./;'\[\]\-=]$")||!srfhotkey {
		GuiControl, 3:Text, srfhotkey, %Switch%
		Return
	} Else {
		tarr:=StrSplit(srfhotkey, "&", " ")
		Loop % tarr.Length()
		{
			If !(GetKeyVK(tarr[A_Index])||GetKeyVK(LTrim(tarr[1], "<>!^#+"))||(tarr[A_Index]~="i)^(L|R)?(Win|Alt|Shift|Control|Ctrl|CapsLock)( Up)?$")) {
				GuiControl, 3:Text, srfhotkey, %Switch%
				MsgBox, 16, 错误, 热键名错误, 3
				Return
			}
		}
		Hotkey If, !(srf_inputing&&Switch~="Shift")
		Try	{
			If (Switch)
				Hotkey, %Switch%, srfSwitch, Off
			Hotkey, %srfhotkey%, srfSwitch, On
			Switch:=Yzimeini.Hotkey["Switch"]:=srfhotkey
			
			If !InStr(Switch,"&")
				If (Switch~="i)^(L|R)?(Win|Alt|Shift|Control|Ctrl|CapsLock)$")
					Try Hotkey, % Switch " & vkFF", AndLButton, Off
				Else If RegExMatch(Switch,".*([\+\^!#<>]).+")
					Try Hotkey, % RegExReplace(Switch,".*([\+\^!#<>]).+","$1") "vkFF", AndLButton, Off
			If !InStr(srfhotkey,"&")
				If (srfhotkey~="i)^(L|R)?(Win|Alt|Shift|Control|Ctrl|CapsLock)$")
					Try Hotkey, % srfhotkey " & vkFF", AndLButton, On
				Else If RegExMatch(srfhotkey,".*([\+\^!#<>]).+")
					Try Hotkey, % RegExReplace(srfhotkey,".*([\+\^!#<>]).+","$1") "vkFF", AndLButton, On
		} Catch {
			GuiControl, 3:Text, srfhotkey, %Switch%
			Try Hotkey, %Switch%, srfSwitch, On
			MsgBox, 16, 错误, 注册热键失败, 3
		}
		Hotkey If
	}
Return

WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd){
	global TableName, HLV1, lspy_key
	static buf, lasthwnd:=0, lastpos:=0
		, tips:={Startingup:"此功能需要系统的任务计划服务支持",Autoupdatefg:"勾选自动更新后会检测最新版的exe文件并提示更新，并不会更新源码部分，`n源码请在Gitee、百度网盘、QQ群中下载",UIAccess:"启用此选项后，有更高级别的热键、置顶效果",chaojijp:"显示四字及以上的简拼候选",bmhg:"按Ctrl + A-Z快速定位需要修改的编码位置",fyfz:"翻页后进入间接辅助码模式",启用TSF:"安装TSF，切换输入法激活Yzime`n，上屏更快，能在更多界面上屏"
			,EnChar:"勾选后可在开启其他输入法中文输入状态时，`n正常上屏英文字符、标点，但无法响应相关热键",SendDelay:"部分控件无法响应太快的键击导致上屏漏字，`n适当调高延时解决相关问题",Imagine:"拼音4字后超前联想后续字词`n形码类逐码提示",MemoryDB:"将数据库载入内存获取更好的性能，关闭此选项、退出燕子时保存数据库",ClipHistory:"记录剪贴板文本历史，clip/显示历史纪录",fixedword:"单字字频不变"
			,Wordfrequency:"勾选后词频随使用逐步变化，影响词条在候选中的排列顺序`n手动调频Ctrl + 0-9",Superrun:"勾选后在候选中显示超级命令库的首个命令，`n按。键可启动程序、打开文件、运行ahk脚本",Magicstring:"勾选后在候选中显示魔法字符串库的首个词条，词条可以带换行等格式，`n按，键上屏文本、以键击发送完成快速填表、粘贴大段文本",decfre:"对选择的词外其他重码词进行降频处理",FirstNotSave:"拼音长句模式的组词结果在上屏后不保存"
			,Learning:"保存10字以内的词组到词库`n形码``键引导、分隔编码",Different:"勾选后每个应用有独立的中英文输入状态，切换应用时自动切换输入状态",IMEmode:"切换到应用时的默认输入状态。",应用管理:"设置每次切换到该应用时的输入状态",SymbolFont:"设置候选项界面输入特殊符号时的字体",MouseCross:"鼠标划词后1s内按LCtrl弹出选择菜单",dwxg:"长词条中间部分不合意，长按空格键后释放，`n再按A-Z上屏长词条的前部分，进入辅助码筛选模式"
			,拼音类:"包括全拼、双拼方案，共用pinyin词库",形码类:"最大码长等于4的方案，导入相应词库后生成对应选项，导入文件名即方案名",Traditional:"勾选后词条中简体字以繁体字形式显示上屏，`n不勾选时不对词条中的繁体进行处理",ShowCode:"形码类临时拼音输入时反查编码",lspy:"进入临时拼音模式",zigen:"显示形码的拆分，需要拆分文件",Tofirst:"选择后使该候选到当前序列首位",simasp:"最大码长时无重自动上屏",wumasp:"大于最大码长时当前焦点项上屏",dgsp:"当前编码无候选时减一码自动上屏"
			,Showquanpin:"显示双拼对应的全拼编码",CloudInput:"候选中插入云输入的结果，显示速度与网络速度相关`n获取失败或与本地词条重复时不显示",SaveCloud:"勾选自学习后选择云输入的候选并记录到词库`n不需要开启自学习",fuzhuma:"正常输入拼音后，再直接敲入一个小写字母代表的部首辅助码协助筛选候选项",TextFont:"设置候选项界面的字体",FontSize:"设置候选项字体大小",LogoSize:"设置中英文状态指示器的粗细",ToolTipStyle:"设置候选界面的样式，ToolTip兼容性好速度慢，Gdip速度更快适合Win7及以上的系统"
			,Lockedposition:"固定候选界面不随光标移动，可鼠标拖动至适合位置",srfhotkey:"设置输入法中/英文状态切换热键，`nCtrl对应的热键前缀为 ^`nShift对应的热键前缀为 +`nAlt对应的热键前缀为 !`nWin对应的热键前缀为 #`n如设置切换键为Ctrl + Space，填入^Space再点设置`n更多按键名可查阅ahk中文帮助<目录/热键>、<索引/key list>部分",Double:"勾选后双击切换输入模式，LCtrl+LAlt+F12可禁用/恢复所有热键",FuncLV:"内置函数命令，可输入命令名加/使用，可自定义设置命令名",导入词库:"导入的码表文件是以待导入的词库名为前缀的文本文档(如wubi86_1.txt;zhengma.txt)，推荐编码为UTF-8-BOM。`n每行包括编码、词条、权重或备注(非必须)，以=或Tab或空格分隔。`n导入pinyin、wubi86、wubi98词库时，编码非必须，可自动生成。各行格式一致，格式如下：`n五笔86：`naaaa	恭恭敬敬	劳斯莱斯	花花草草 （无weight）`nggtt	五笔	5`n`n拼音、双拼：`npin'yin	拼音	16`n燕子输入法	20`n`nhotstrings、functions为JSON格式,换行\n Tab\t：`n[""key"",""value"",""comment""]"
			,导出词库:"导出当前词库查询后的所有词条，存放在" A_ScriptDir,删除词库:"删除当前选择的词库",整理词库:"对词库进行去重排序，保留最大权重",压缩词库:"词库在删除词条后空间没有释放，使用压缩词库释放空间",TableName:"选择相应的词库进行管理或导出`n双击对应区域进入编辑模式，进行词条修改。`n右键新建、删除词条，魔法创建可添加多个词条或创建带格式的文本`n点击右下角可设置每页显示的词条数",citiao:"精确查找输入的编码、词条、备注，_代表一位任意字符、%代表任意位字符"
			,ShowFZM:"为候选项附上自身的辅助码", ShowLogo:"在屏幕顶端显示一条细的彩带用以指示当前的输入语言（鼠标可穿透，不会影响您在屏幕顶部的操作）", FirstZi:"选中此项则输入的辅助码仅针对每个候选词中的首字进行匹配筛选；`n取消勾选则会尝试用输入的一位或两位辅助码匹配词中的任意单字，`n如果是两位辅助码则还会尝试按先后顺序分别匹配词中的任意两个字", ConnectIMEandCursor:"对VSCode插件IMEandCursor提供支持，非IMEandCursor用户可关闭此项", tfuzhuma:"在候选框中输入数字6-0（表示声调轻声到四声）或大写字母自动进入间接辅助码模式"
			,StatusBar:"点击状态栏右下角设置每页显示词条数，PgUp、PgDn为翻页键",Useless:"隐藏词频低于0的词条，仅在无其他候选项的时候出现",Tofirst:"选择后的词条到当前编码的第一位",ResultsLV:{}}
	If !VarSetCapacity(buf)
		VarSetCapacity(buf, 20 * (A_IsUnicode ? 2 : 1))
	If (lastpos!=lParam)&&(Hwnd!=HLV1){
		ToolTip
		lastpos:=lParam
	}
	If (lasthwnd=Hwnd)
		Return
	Else
		lasthwnd:=Hwnd
	GuiControlGet, buf, Name, %Hwnd%
	If (buf="")
		DllCall("GetWindowText", "ptr", Hwnd, "str", buf, "int", 20)
	If (tips[buf])
		SetTimer, Showhelptips, -500
	Return
	Showhelptips:
	MouseGetPos, , , , poshwnd, 2
	If (tips[buf])&&(lasthwnd=poshwnd+0){
		If (buf="ResultsLV")
			ToolTip % tips[buf,TableName]
		Else
			ToolTip % tips[buf]
	}
	Return
}

ListFonts(){
	static fontlist:=""
	If (fontlist)
		Return fontlist
	VarSetCapacity(logfont, 128, 0), NumPut(1, logfont, 23, "UChar")
	obj := []
	DllCall("EnumFontFamiliesEx", "ptr", DllCall("GetDC", "ptr", 0), "ptr", &logfont, "ptr", RegisterCallback("EnumFontProc"), "ptr", &obj, "uint", 0)
	For font in obj
		fontlist .= "|" font
	fontlist:=LTrim(fontlist,"|")
	Return fontlist
}
EnumFontProc(lpFont, tm, TextFont, lParam){
	obj := Object(lParam)
	If (TextFont>1&&!InStr(font:=StrGet(lpFont+28), "@"))
		obj[font] := 1
	Return 1
}
/* Title:	Dlg
			*Common Operating System Dialogs*
 */

/*
 Function:		Color
				(See Dlg_color.png)

 Parameters: 
				Color	- Initial color and output in RGB format.
				hGui	- Optional handle to parents Gui. Affects dialog position.
  
 Returns:	
				False if user canceled the dialog or if error occurred	
 */ 
Dlg_Color(ByRef r_Color, hOwner:=0){
    Static CHOOSECOLOR, s_CustomColors
    if !VarSetCapacity(s_CustomColors){
        VarSetCapacity(s_CustomColors,64,0)
		; CustomColors:=[0x99731C,0xECEEEE,0x8B4E01,0x444444,0xE89F00,0x70B33E,0x2DB6F8,0x81A300
		; 			,0xD77800,0x0A1B0D,0x97D4B9,0xEFAD00,0xBF7817,0xE3F6FD,0x362B00,0xDEDEDE]
		CustomColors:=[0xE9E5D9,0x0B0A13,0xFBF2E0,0xECF0E8,0xA5F0D1,0xADC9D9,0xE2ECF9,0x0C0C0C
					,0x99731C,0xECEEEE,0x8B4E01,0x559311,0x0A1B0D,0x444444,0x362B00,0xDEDEDE]
		Loop % CustomColors.Length()
			NumPut(CustomColors[A_Index], s_CustomColors, 4*(A_Index-1), "UInt")
	}
    l_Color:=r_Color, l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)

    ;-- Create and populate CHOOSECOLOR structure
    lStructSize:=VarSetCapacity(CHOOSECOLOR,(A_PtrSize=8) ? 72:36,0)
    NumPut(lStructSize,CHOOSECOLOR,0,"UInt")            ;-- lStructSize
    NumPut(hOwner,CHOOSECOLOR,(A_PtrSize=8) ? 8:4,"Ptr")
        ;-- hwndOwner
    NumPut(l_Color,CHOOSECOLOR,(A_PtrSize=8) ? 24:12,"UInt")
        ;-- rgbResult
    NumPut(&s_CustomColors,CHOOSECOLOR,(A_PtrSize=8) ? 32:16,"Ptr")
        ;-- lpCustColors
    NumPut(0x00000103,CHOOSECOLOR,(A_PtrSize=8) ? 40:20,"UInt")
        ;-- Flags
    RC:=DllCall("comdlg32\ChooseColor" . (A_IsUnicode ? "W":"A"),"Ptr",&CHOOSECOLOR)

    ;-- Cancelled? (user pressed the "Cancel" button or closed the dialog)
    if (RC=0)
        Return False
    ;-- Collect the selected color
    l_Color:=NumGet(CHOOSECOLOR,(A_PtrSize=8) ? 24:12,"UInt")
        ;-- rgbResult
    ;-- Convert to RGB
    l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)

    ;-- Update r_Color with the selected color
    r_Color:=Format("0x{:06X}",l_Color)
    Return True
}
SetButtonColor(ControlID, Color, Margins:=5){
	GuiControlGet, hwnd, 3:Hwnd, %ControlID%
	VarSetCapacity(RECT, 16, 0), DllCall("User32.dll\GetClientRect", "Ptr", hwnd, "Ptr", &RECT)
	W := NumGet(RECT, 8, "Int") - (Margins * 2), H := NumGet(RECT, 12, "Int") - (Margins * 2)

	Color:=((Color&0xFF)<<16)+(Color&0xFF00)+((Color>>16)&0xFF)
	hbm:=CreateDIBSection(W, H), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	hBrush:=DllCall("CreateSolidBrush", "UInt", Color, "UPtr"), obh:=SelectObject(hdc, hBrush)
	DllCall("Rectangle", "UPtr", hdc, "Int", 0, "Int", 0, "Int", W, "Int", H), SelectObject(hdc, obm)
	BUTTON_IMAGELIST_ALIGN_CENTER := 4, BS_BITMAP := 0x0080, BCM_SETIMAGELIST := 0x1602, BITSPIXEL := 0xC
	BPP := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hdc, "Int", BITSPIXEL)
	HIL := DllCall("Comctl32.dll\ImageList_Create", "UInt", W, "UInt", H, "UInt", BPP, "Int", 6, "Int", 0, "Ptr")
	DllCall("Comctl32.dll\ImageList_Add", "Ptr", HIL, "Ptr", hbm, "Ptr", 0)
	; ; Create a BUTTON_IMAGELIST structure
	VarSetCapacity(BIL, 20 + A_PtrSize, 0), NumPut(HIL, BIL, 0, "Ptr")
	Numput(BUTTON_IMAGELIST_ALIGN_CENTER, BIL, A_PtrSize + 16, "UInt")
	SendMessage, BCM_SETIMAGELIST, 0, 0, , ahk_id %HWND%
	SendMessage, BCM_SETIMAGELIST, 0, &BIL, , ahk_id %HWND%
	SelectObject(hdc, obh), DeleteObject(hbm), DeleteObject(hBrush), DeleteDC(hdc)
}
; WM_CTLCOLORSTATIC(wParam, lParam, msg, hwnd){
; 	Critical
; 	static brushes := []
; 	Gui +OwnDialogs
; 	If (!hwnd){
; 		For _,brush In brushes
; 			If (brush)
; 				DllCall("DeleteObject", "ptr", brush)
; 		brushes := []
; 		Return
; 	}
; 	GuiControlGet varName, Name, %lParam%
; 	If !InStr(varName, "Color")
; 		Return
; 	If (brush := brushes[lParam]) && brush >= 0
; 		DllCall("DeleteObject", "ptr", brush)
; 	GuiControlGet tt,, %varName%
; 	clr:="0x" tt, clr:=(clr & 0xFF00) | (clr >> 16) | ((clr&0xFF)<<16)
; 	brushes[lParam] := brush := DllCall("CreateSolidBrush", "uint", clr, "ptr")
; 	DllCall("SetBkMode", "uint", wParam, "int", 1)
; 	DllCall("SetTextColor", "uint", wParam, "int", ~clr&0xffffff)
; 	DllCall("SetBkColor", "uint", wParam, "int", clr)
; 	Return brush
; }
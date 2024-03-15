; ci_ku_Manager###############################################################################
cikuManager:
currentciku:
	If (!MemoryDB){
		If (srf_Plugins["cikuManager", 1]){
			Process, Exist, % srf_Plugins["cikuManager", 1]
			If (ErrorLevel){
				WinShow % "词库管理 ahk_class Yzime ahk_pid" srf_Plugins["cikuManager", 1]
				WinActivate % "词库管理 ahk_class Yzime ahk_pid" srf_Plugins["cikuManager", 1]
				Send_WM_COPYDATA((A_ThisLabel="cikuManager"?"customs":shurulei="pinyin"?"pinyin":Inputscheme)
					, "词库管理 ahk_class Yzime ahk_pid" srf_Plugins["cikuManager", 1], 1)
				Return
			}
		}
		If FileExist("词库管理.exe"){
			Run % "词库管理.exe ""-o" main (main!=extend ? "|" extend : "") """ ""-s" (A_ThisLabel="cikuManager"?"customs":shurulei="pinyin"?"pinyin":Inputscheme) """" (Autoupdatefg?" -update":""), %A_ScriptDir%, , tvar
			srf_Plugins["cikuManager", 1]:=tvar
			Return
		}
	}
	If WinExist("ahk_id" HGui97){
		WinActivate, ahk_id%HGui97%
		WinSet Redraw, , ahk_id%HLV1%
		Return
	}
	; If (!MemoryDB){
	; 	MsgBox, 68, 提示, 词库管理已更新，是否请前往下载？
	; 	IfMsgBox Yes
	; 	{
	; 		Run https://wwi.lanzoui.com/b01bga84b
	; 		Return
	; 	}
	; }
	OnMessage(0x200, "WM_MOUSEMOVE")
	alltablenames:="超级命令|魔法字符串|自定义短语|特殊符号|English", ENTabNames:={特殊符号:"symbol",自定义短语:"customs",拼音:"pinyin",五笔86:"wubi86",五笔98:"wubi98",超级命令:"functions",魔法字符串:"hotstrings"}
	CNColNames:={rowid:"序号",key:"编码(key)",value:"词条(value)",weight:"权重(weight)",comment:"备注(comment)",pos:"位置"}
	If DB.GetTable("SELECT name FROM sqlite_master WHERE type='table' AND tbl_name NOT IN ('English','functions','hotstrings','customs','symbol','hebing','sqlite_sequence')",TableInfo){
		Loop % TableInfo.RowCount
			alltablenames .= "|" TableInfo.Rows[A_Index,1]
		If (ClipHistory)
			alltablenames .= "|ClipHistory"
	}
	Gui, 97:Destroy
	Gui, 97:Default
	Gui, 97:+OwnDialogs +hwndHGui97 ;+Disabled
	Gui, 97:Margin, 10, 10
	Gui, 97:Font, s11 Bold, %GUIFont%
	Gui, 97:Add, GroupBox, w780 h60, 词库管理
	Gui, 97:Font
	Gui, 97:Font, s11, %GUIFont%
	Gui, 97:Add, Button, xp+10 yp+20 w80 gWriteCiKu, 导入词库
	Gui, 97:Add, Button, xp+90 yp w80 gderiveCiKu, 导出词库
	Gui, 97:Add, Button, xp+90 yp w80 gDelCiku, 删除词库
	Gui, 97:Add, Button, xp+90 yp w80 gclearupCiku, 整理词库
	Gui, 97:Add, Button, xp+90 yp w80 gVacuum, 压缩词库
	Gui, 97:Add, Button, xp+90 yp w80 gdownloadCiku, 下载词库
	Gui, 97:Add, Button, xp+90 yp w80 ghelpciku, 使用帮助
	Gui, 97:Font
	Gui, 97:Font, s11 bold, %GUIFont%
	Gui, 97:Add, GroupBox, xm yp+40 w780 h460, 词条管理
	Gui, 97:Font
	Gui, 97:Font, s11, %GUIFont%
	Gui, 97:Add, Text, xm+10 yp+25 h20 w60 0x200, 选择词库:
	Gui, 97:Add, DropDownList, x+5 yp-5 w295 hp vTableName r10 gSwitchTable, %alltablenames%
	Gui, 97:Add, Text, x+40 yp+5 h20 w60 0x200, 显示字体:
	Gui, 97:Add, DropDownList, x+5 yp-5 w295 hp r10 gSetShowFont, % ListFonts()
	Gui, 97:Add, Text, xm+10 yp+35 w60 h20 0x200, 查找词条:
	Gui, 97:Add, Edit, x+5 yp-5 w695 vcitiao gSearch
	Gui, 97:Add, Text, xm+10 yp+35 w60 h20 0x200, 高级查找:
	Gui, 97:Add, Edit, x+5 yp-5 w600
	Gui, 97:Add, Button, x+5 yp hp w90 gSQLSearch, 运行
	Gui, 97:Add, ListView, xm+10 yp+30 w760 h300 AltSubmit gSubLV1 hwndHLV1 +0x9300 +LV0x010000
	GuiControlGet, tempP, 97:Pos, 词条管理
	GuiControl, 97:Move, %HLV1%, % "h" tempPh-120
	DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HLV1, "Str", "Explorer", "Ptr", 0)
	SendMessage, 0x1501, 1, "输入编码、词条、备注，通配符_、%", Edit1, ahk_id%HGui97%
	SendMessage, 0x1501, 1, "输入SQL语句或WHERE子句，支持正则函数regexp、繁转简函数t2s", Edit2, ahk_id%HGui97%
	GuiControl, 97:ChooseString, TableName, % A_ThisLabel="cikuManager"?"自定义短语":shurulei="pinyin"?"pinyin":Inputscheme
	GuiControl, 97:ChooseString, ComboBox2, % GUIFont
	Gui, 97:Add, StatusBar
	SB_SetParts(80,520)
	Gui, 97:Font
	Gui, 97:Show, , 词库管理
	ICELV1:=New LV_InCellEdit(HLV1, 1, 1)
	Hotkey, IfWinActive, 词库管理 ahk_pid%YzimePID%
	Hotkey, $Del, DelRow, On
	Hotkey, ^n, NewRow, On
	Hotkey, F5, Refresh2, On
	Hotkey If
	Gosub SwitchTable
	OnMessage(0x06, "WM_ACTIVATE")
	historyrecord:=[]
	Return
	; #########################################   Gui事件   #####################################################
	vared:								; 热字串、词条生成编辑框
	Gui, 97:+Disabled
	Gui, vared:Destroy
	Gui, vared:+Resize +MinSize350x250 +Owner97 -MinimizeBox +AlwaysOnTop
	Gui, vared:Default
	Gui, vared:Add, Edit, vvaredtext r5 WantTab
	Gui, vared:Add, Button, gSave, 确定
	MenuItem:=A_ThisMenuItem
	If (A_ThisMenuItem = "编辑(&E)"){
		Gui, vared:Show, w350 h250, 编辑
		GuiControl, , Edit1, %eddata%
	} Else If (A_ThisMenuItem = "魔法创建(&W)")
		Gui, vared:Show, w350 h250, 魔法创建
	Else
		Gui, vared:Show, w350 h250, 创建脚本
	ControlFocus, Edit1
Return
varedGuiEscape:
varedGuiClose:
	Gui, 97:-Disabled
	Gui, vared:Destroy
Return

cikuhotkeyfg(){
	; If WinActive("WinTitle" [, "WinText", "ExcludeTitle", "ExcludeText]")
}
Save:								; 热字串、词条生成编辑框 g标签
	Gui, 97:Default
	Gui, 97:-Disabled
	Gui, vared:Submit
	Gui, vared:Destroy
	Start:=A_TickCount
	If (MenuItem = "编辑(&E)"){
		If !(eddata " " == varedtext " "){
			If DB.Exec(_SQL:="UPDATE 'extend'.'" TableName "' SET value='" StrReplace(varedtext,"'","''") "'" " WHERE rowid=" tv_index ";"){
				SB_SetText("更新词条"),SB_SetText("[" tv_index "," CNColNames["value"] "] " eddata "-->" varedtext,2), historyrecord.Push(["UPDATE 'extend'.'" TableName "' SET value='" StrReplace(eddata,"'","''") "'" " WHERE rowid=" tv_index ";","修改"])
				, ICELV1.List[(Focusedrow + ICELV1.PageSize - 1) // ICELV1.PageSize, Mod(Focusedrow - 1, ICELV1.PageSize) + 1, 3] := varedtext
				, ICELV1.LVM_REDRAWITEMS(Focusedrow-1, Focusedrow-1)
			} Else {
				OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
				Return
			}
		}
	} Else If ((MenuItem = "魔法创建(&W)")&&(TableName = "hotstrings"))||((MenuItem = "创建脚本(&W)")&&(TableName = "functions")){
		If !DB.Exec(_SQL:="INSERT INTO 'extend'.'" TableName "' VALUES ('','" StrReplace(varedtext,"'","''") "','" (TableName="functions"?"{Script}":"") "');"){
			OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
			Return
		}
		DB.GetTable("SELECT max(rowid) FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'") TableName "'", Result)
		historyrecord.Push(["DELETE FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' WHERE rowid=" Result.Rows[1, 1] ";","新建"])
		ICELV1.List:=[], ICELV1.RowCount+=1, ICELV1.Maxrowid+=(ICELV1.Maxrowid>0)
		ICELV1.LVM_SetItemCount()
		Sleep 0
		WinSet Redraw, , ahk_id%HLV1%
		SB_SetText("插入词条"),SB_SetText("[" Result.Rows[1, 1] "," CNColNames["value"] "] " varedtext,2)
		SB_SetText("共" RegExReplace(ICELV1.RowCount, "(\d\d\d\d)", ",$1", , , Mod(StrLen(ICELV1.RowCount),4)?Mod(StrLen(ICELV1.RowCount),4)+1:5) "条",3)
	} Else
		citiao_create(TableName, varedtext)
Return

varedGuiSize:						; 热字串、词条生成编辑框自适应布局
	GuiControlGet, tempP, Pos, Button1
	GuiControl, Move, Button1, % "x" A_GuiWidth-10-tempPW "y" A_GuiHeight-6-tempPH
	GuiControl, Move, Edit1, % "w" A_GuiWidth-21 "h" A_GuiHeight-19-tempPH
Return

97GuiDropFiles(Hwnd, FileArray){
	local
	global TableName, historyrecord, DB, DebugLevel
	Gui +OwnDialogs
	tt:=""
	If (TableName!="functions"){
		GuiControl, 97:ChooseString, TableName, 超级命令
		Gosub SwitchTable
	}
	DB.GetTable("SELECT max(rowid) FROM 'extend'.'functions'", Result)
	begin:=end:=Result.Rows[1, 1]
	Loop % FileArray.Length(){
		t:=FileArray[A_Index]
		SplitPath, t, OutFileName, , OutExt
		If (OutExt="ahk"){
			If (tt){
				FileRead, t, %t%
			} Else If (tt=""){
				MsgBox, 68, 提示, ahk脚本以文本形式存入数据库?
				IfMsgBox, Yes
				{
					tt:=1
					FileRead, t, %t%
				} Else
					tt:=0
			}
		}
		If DB.Exec("INSERT INTO 'extend'.'functions' VALUES ('','" StrReplace(t,"'","''") "','" StrReplace(OutFileName,"'","''") "');")
			end++
	}
	If (DB.ErrorCode)
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	If (end>begin)
		historyrecord.Push(["DELETE FROM 'extend'.'functions' WHERE rowid>" begin " AND rowid<" (end+1) ";","新建"])
	Gosub Refresh
}

WM_ACTIVATE(wParam, lParam, msg, hwnd){
	global HGui97
	If (hwnd = HGui97)
		ToolTip
}

97GuiClose:
	OnMessage(0x06, ""), ICELV1:=""
	If !WinExist("ahk_id" HGui3)
		OnMessage(0x200, "")
	ToolTip
	Gui, 97:Hide
	Gui, 97:Destroy
Return

SubLV1:								; CikuManager 列表编辑 g标签 修改、插入、删除。。。
	; Check for changes
	If (A_GuiEvent == "F"){
		If (ICELV1["Changed"]&&TableName){
			For Key, Value In ICELV1.Changed
				Break
			ICELV1.Remove("Changed"), Start:=A_TickCount, _SQL:=""
			If (Newflag){
				If !DB.Exec("INSERT INTO '" (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"extend":"main") "'.'" TableName "' DEFAULT VALUES;"){
					OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
					SendInput {Esc}
					Return
				}
				; DB.LastInsertRowID(tv_index)
				_SQL:="UPDATE " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' SET " ICELV1.ColumnNames[Value.Col] "='" StrReplace(Value.Txt,"'","''") "'" " WHERE rowid=" tv_index ";"
				If InStr(_SQL, "'main'."){
					Key:=""
					; Try Key:=StrSplit(IMEConverter(TableName,Value.Txt),"`t")[1], Key:=StrReplace(Key,"'","''")
					If (TableName = "pinyin"){
						DB.GetTable("SELECT ifnull(max(weight)+1,5000) FROM 'main'.'pinyin' WHERE jp='" RegExReplace(Key,"([a-z])[a-z]*","$1") "' AND key='" Key "'", Result)
						_SQL .= "`nUPDATE 'main'.'" TableName "' SET jp='" RegExReplace(Key,"([a-z])[a-z]*","$1") "',key='" Key "',weight=" Result.Rows[1,1] " WHERE rowid=" tv_index ";"
					} Else {
						DB.GetTable("SELECT ifnull(max(weight)+1,5000) FROM 'main'.'" TableName "' WHERE key='" Key "'", Result)
						_SQL .= "`nUPDATE 'main'.'" TableName "' SET key='" Key "',weight=" Result.Rows[1,1] " WHERE rowid=" tv_index ";"
					}
				} Else If (TableName="customs")
					_SQL .= "`nUPDATE 'extend'.'customs' SET comment='001' WHERE rowid=" tv_index ";"
				If DB.Exec(_SQL){
					historyrecord.Push(["DELETE FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' WHERE rowid=" tv_index ";","新建"])
					ICELV1.List:=[]
					Gosub Refresh
					SB_SetText("新建词条"),SB_SetText("[" tv_index "," CNColNames[ICELV1.ColumnNames[Value.Col]] "] " Value.Txt,2)
				} Else
					OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
				Newflag:=0
				Return
			} Else {
				LV_GetText(tv_index, Value.Row, 1)
				If (TableName = "pinyin" && ICELV1.ColumnNames[Value.Col] = "key")
					_SQL:="UPDATE 'main'.'pinyin' SET key='" StrReplace(Value.Txt,"'","''") "',jp='" RegExReplace(StrReplace(Value.Txt,"'","''"),"([a-z])[a-z]*","$1") "' WHERE rowid=" tv_index ";"
				Else
					_SQL:="UPDATE " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' SET " ICELV1.ColumnNames[Value.Col] "='" StrReplace(Value.Txt,"'","''") "'" " WHERE rowid=" tv_index ";"
				If (_SQL)
					If DB.Exec(_SQL){
						historyrecord.Push([RegExReplace(_SQL,"=(.*)WHERE rowid=" tv_index ";$","='" StrReplace(ICELV1.ItemText,"'","''") "' WHERE rowid=" tv_index ";"),"修改"])
						ICELV1.List[(Value.Row + ICELV1.PageSize - 1) // ICELV1.PageSize, Mod(Value.Row - 1, ICELV1.PageSize) + 1,Value.Col] := Value.Txt
						ICELV1.LVM_REDRAWITEMS(Value.Row-1, Value.Row-1)
						SB_SetText("更新词条"),SB_SetText("[" tv_index "," CNColNames[ICELV1.ColumnNames[Value.Col]] "] " ICELV1.ItemText "-->" Value.Txt,2)
					} Else
						OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
			}
		} Else If (Newflag){
			DB.LastInsertRowID(tv_index), Newflag:=0, ICELV1.List[1].RemoveAt(1), ICELV1.Maxrowid-=(ICELV1.Maxrowid>0)
			; , DB.Exec("DELETE FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' WHERE rowid=" tv_index ";")
			ICELV1.LVM_SetItemCount()
			Sleep 0
			WinSet Redraw, , ahk_id%HLV1%
		}
	} Else If (!Newflag && A_GuiEvent == "f"){
		SB_SetText("编辑"), SB_SetText("",2)
	} Else If (A_GuiEvent == "RightClick" && TableName && !Newflag){
		Sleep 0
		If Focusedrow:=LV_GetNext(){
			If (TableName="Cliphistory")
				Menu, MyContextMenu, Disable, 2&
			Else
				Menu, MyContextMenu, Enable, 2&
			Menu, MyContextMenu, Enable, 3&
		} Else {
			Menu, MyContextMenu, Disable, 2&
			Menu, MyContextMenu, Disable, 3&
		}
		If (TableName~="hotstrings|functions"){
			If Focusedrow {
				LV_GetText(tv_index, Focusedrow, 1)
				LV_GetText(eddata, Focusedrow, 3)
				Menu, MyContextMenu, Enable, 编辑(&E)
			} Else
				Menu, MyContextMenu, Disable, 编辑(&E)
		}
		Menu, MyContextMenu, Rename, 5&, % Trim("撤销 " historyrecord[historyrecord.Length(),2]) "(&U)"
		If historyrecord.Length()
			Menu, MyContextMenu, Enable, 5&
		Else
			Menu, MyContextMenu, Disable, 5&
		Gosub srf_value_off
		GuiControl, -ReDraw, %HLV1%
		Menu, MyContextMenu, Show
		GuiControl, +ReDraw, %HLV1%
	}
Return

NewRow:							; 新建行
	Gui, 97:Default
	GuiControl Focus, %HLV1%
	DB.GetTable("SELECT max(rowid)+1 FROM '" (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"extend":"main") "'.'" TableName "'", Result)
	tv_index:=Result.Rows[1, 1]?Result.Rows[1, 1]:1
	SendInput {Home}
	Sleep 0
	If (!ICELV1.List.HasKey(1))
		ICELV1.List[1]:=[]
	ICELV1.List[1].InsertAt(1,[tv_index ""]), ICELV1.Maxrowid+=(ICELV1.Maxrowid>0), ICELV1.RowCount++
	ICELV1.LVM_SetItemCount()
	Sleep 0
	WinSet Redraw, , ahk_id%HLV1%
	Newflag:=1, ICELV1.EditCell(1,3-(TableName="English"))
	SB_SetText("新建"), SB_SetText("", 2)
Return
CopyRow:
	Gui, 97:Default
	Focusedrow:=0, Start:=A_TickCount
	DB.GetTable("SELECT max(rowid) FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "'", Result)
	firstrowid:=Result.Rows[1, 1]
	DB.Exec("BEGIN TRANSACTION;")
	While Focusedrow:=LV_GetNext(Focusedrow){
		LV_GetText(tv_index, Focusedrow, 1)
		DB.Exec("INSERT INTO " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' SELECT * FROM "
			. (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' WHERE rowid=" tv_index)
	}
	DB.Exec("COMMIT TRANSACTION;")
	DB.LastInsertRowID(Result)
	historyrecord.Push(["DELETE FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' WHERE rowid>" firstrowid " AND rowid<" Result+1,"复制"])
	Gosub Refresh
	SB_SetText("复制词条"), SB_SetText("完成用时：" A_TickCount-Start " ms",2)
Return
DelRow(){							; 删除行
	local
	global DB, historyrecord, TableName, DebugLevel, ICELV1
	Gui, 97:Default
	Gui 97:+OwnDialogs
	ControlGetFocus, tvar
	If (tvar)&&(tvar!="SysListView321"){
		Send, {Del}
		Return
	}
	Start:=A_TickCount
	Firstrow:=LV_GetNext(), delrows:=[], Focusedrow:=0, ColCount:=LV_GetCount("Col"), _SQL:=""
	DB.Exec("BEGIN TRANSACTION;")
	While Focusedrow:=LV_GetNext(Focusedrow){
		tv_index := ICELV1.List[(Focusedrow + ICELV1.PageSize - 1) // ICELV1.PageSize, Mod(Focusedrow - 1, ICELV1.PageSize) + 1, 1]
		If (DB.Exec("DELETE FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' WHERE rowid='" tv_index "';")){
			delrows.Push(tv_index)
			ICELV1.RowCount-=(ICELV1.RowCount>0), tvar:=""
			Loop % ColCount-1
				tvar .= ",'" StrReplace(ICELV1.List[(Focusedrow + ICELV1.PageSize - 1) // ICELV1.PageSize, Mod(Focusedrow - 1, ICELV1.PageSize) + 1, A_Index+1],"'","''") "'"
			If (TableName="pinyin")
				tvar:="'" RegExReplace(StrReplace(ICELV1.List[(Focusedrow + ICELV1.PageSize - 1) // ICELV1.PageSize, Mod(Focusedrow - 1, ICELV1.PageSize) + 1, 2],"'","''"),"([a-z])[a-z]*","$1") "'" tvar
			Else
				tvar:=Trim(tvar, ",")
			If (TableName!="Cliphistory")
				_SQL .= "`nINSERT INTO " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'") TableName "' VALUES(" tvar ");"
		}
	}
	DB.Exec("COMMIT TRANSACTION;")
	If (delrows.Length()) {
		tarr:=[]
		If (TableName!="Cliphistory")
			historyrecord.Push([LTrim(_SQL,"`n"),"删除"]), _SQL:=""
		SB_SetText("删除词条"),SB_SetText("完成用时：" A_TickCount-Start " ms",2)
		ICELV1.Maxrowid:=0
		ICELV1.Fresh()
		Gosub Refresh
	} Else If (DB.ErrorCode)
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
}

Revoke:
	Start:=A_TickCount
	DB.Exec("BEGIN TRANSACTION;")
	DB.Exec((tarr:=historyrecord.Pop())[1])
	DB.Exec("COMMIT TRANSACTION;")
	Gosub Refresh
	If (DB.ErrorCode)
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	SB_SetText("撤销" tarr[2]), SB_SetText("完成用时：" (A_TickCount - Start) " ms",2), tarr:=""
Return

Refresh:							; 刷新
Refresh2:
	Gui, 97:Default
	If (A_ThisLabel="Refresh2")
		SB_SetText("刷新"), Start:=A_TickCount
	ICELV1.Fresh(1)
	SB_SetText("共" RegExReplace(ICELV1.RowCount, "(\d\d\d\d)", ",$1", , , Mod(StrLen(ICELV1.RowCount),4)?Mod(StrLen(ICELV1.RowCount),4)+1:5) "条",3)
	If (A_ThisLabel="Refresh2"){
		SB_SetText("加载用时：" (A_TickCount - Start) " ms",2)
		Sleep, 100
	}
Return

DelCiku:
	Gui, 97:Submit, NoHide
	Gui 97:+OwnDialogs
	; OnMessage(0x18, "SetWindowsAlwaysOnTop")
	MsgBox, 305, 注意, 确定要删除“%TableName%”词库吗？`n删除词库将丢失该词库的数据无法恢复！
	; InputBox, tvar, 删除请输入“确定”, 确定要永久性地删除整个“%TableName%”词库吗？`n删除请输入“确定”, , Max(320,3*A_ScreenDPI), Max(150,2*A_ScreenDPI)
	; OnMessage(0x18, "")
	IfMsgBox, Cancel
		Return
	TableName:=ENTabNames[TableName]?ENTabNames[TableName]:TableName
	_SQL:="DROP TABLE " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "'"
	Start:=A_TickCount
	If (DB.Exec(_SQL)){
		GuiControl, -ReDraw, %HLV1%
		LV_Delete()
		Loop, % LV_GetCount("Column")
			LV_DeleteCol(1)
		ICELV1.RowCount:=ICELV1.Maxrowid:=0, ICELV1.List:=[], ICELV1.SQL:=_SQL:=""
		ICELV1.LVM_SETITEMCOUNT(0)
		GuiControl, +ReDraw, %HLV1%
		SB_SetText("删除词库"),SB_SetText("完成用时：" (A_TickCount - Start) " ms",2)
		SB_SetText("",3)
		If !(TableName~="^(hotstrings|functions|customs|symbol)$"){
			alltablenames:=StrReplace(StrReplace(alltablenames,TableName),"||","|"), TableName:=""
			GuiControl, 97:, TableName, % "|" Trim(alltablenames,"|")
		}
		; DB.Exec("VACUUM")
	} Else
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
Return

clearupCiku(){
	local
	global TableName, DB
	If !TableName
		Return
	SB_SetText("数据合并整理"),SB_SetText("准备数据去重...",2),Start:=A_TickCount
	remaketable(DB,TableName)
	Gosub GetTable
	SB_SetText("整理完毕，完成用时 " A_TickCount - Start " ms",2)
	; DB.Exec("VACUUM")
}

helpciku:
	Run https://gitee.com/orz707/Yzime/wikis/词库类别
Return

SetShowFont:
	Gui, 97:Font, norm, %A_GuiControl%
	GuiControl, 97:Font, %HLV1%
Return

Search:
	SetTimer, GetTable, -500
Return

SwitchTable:
SwitchTable2:
	Gui, 97:Default
	Gui, 97:Submit, NoHide
	TableName:=ENTabNames[TableName]?ENTabNames[TableName]:TableName, historyrecord:=[]
	Loop 2
		Try 
			Menu, MyContextMenu, Delete, 6&
	If (TableName="Cliphistory"){
		Menu, MyContextMenu, Disable, 1&
	} Else
		Menu, MyContextMenu, Enable, 1&
	If (TableName="hotstrings"){
		Menu, MyContextMenu, Add, 编辑(&E), vared
		Menu, MyContextMenu, Add, 魔法创建(&W), vared
	} Else If (TableName="functions"){
		Menu, MyContextMenu, Add, 编辑(&E), vared
		Menu, MyContextMenu, Add, 创建脚本(&W), vared
	} Else If (TableName~="wubi86|wubi98|pinyin"){
		Menu, MyContextMenu, Add, 魔法创建(&W), vared
	}
	If (A_ThisLabel="SwitchTable2")
		Return
	Gosub GetTable
	GuiControl Focus, Edit1
Return

SQLSearch:
	Gui, 97:+OwnDialogs
	Gui, 97:Default
	GuiControlGet, citiao, , Edit2
	If (TableName=""||citiao="")
		Return
	Start:=A_TickCount
	GuiControl, -g, Edit1
	GuiControl, , citiao,
	GuiControl, +gSearch, Edit1
	If (citiao~="i)^\s*(CREATE|INSERT|UPDATE|DELETE|DROP|ATTACH|DETACH)\s"){
		If DB.Exec(citiao){
			Gosub Refresh
			SB_SetText("运行"), SB_SetText("完成用时：" (A_TickCount - Start) " ms",2)
		} Else
			MsgBox, 16, 数据库错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
	} Else {
		If RegExMatch(citiao, "i)^\s*(SELECT|PRAGMA)\s")
			fy_SQL:=citiao
		Else If RegExMatch(citiao, "i)^\s*(WHERE|ORDER|LIMIT)\s")
			fy_SQL:=RegExReplace(fy_SQL,"i)^SELECT .+?\K(\s(WHERE|ORDER BY).+)$") " " citiao
		Else
			fy_SQL:=RegExReplace(fy_SQL,"i)^SELECT .+?\K(\s(WHERE|ORDER BY).+)$") " " (citiao?" WHERE " citiao:"")
		RegExMatch(fy_SQL, "iO)FROM\s+('?[a-z]+'?\.)?('[^']+?'|[^'(),\s]+)\s*", TableName), TableName := Trim(TableName.Value[2], "'")
		Gosub GetTableBySQL
	}
Return
CreateTable(TableName){
	global
	tv_index:=0, ICELV1.RowCount:=ICELV1.Maxrowid:=0
	If (TableName ~= "functions|hotstrings|symbol|customs")
		_SQL = CREATE TABLE 'extend'.'%TableName%' ("key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"comment" TEXT NOT NULL DEFAULT '');
	Else If (TableName="pinyin")
		_SQL = CREATE TABLE 'main'.'pinyin' ("jp" TEXT NOT NULL DEFAULT '',"key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"weight" INTEGER DEFAULT 5000);
	Else If (TableName="English")
		_SQL = CREATE TABLE 'extend'.'English' ("key" TEXT NOT NULL DEFAULT '' COLLATE NOCASE,"weight" INTEGER DEFAULT 5000);
	Else If (TableName="Cliphistory")
		_SQL = CREATE TABLE 'extend'.'Cliphistory' ("value" TEXT NOT NULL DEFAULT '');
	Else
		_SQL = CREATE TABLE 'main'.'%TableName%' ("key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"weight" INTEGER DEFAULT 5000);
	If !DB.Exec(_SQL)
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	Else
		Return 1
}
GetTable:
	Gui, 97:+OwnDialogs
	Gui, 97:Default
	Gui, 97:Submit, NoHide
	If (TableName="")
		Return
	Start:=A_TickCount
	TableName:=ENTabNames[TableName]?ENTabNames[TableName]:TableName
	GuiControl, , Edit2,
	citiao:=StrReplace(citiao, "'", "''"), fy_SQL:="", operate:=(RegExMatch(citiao,"_|%")?"LIKE":"=")
	If (TableName="pinyin")
		fy_SQL:="SELECT rowid,key,value,weight FROM 'pinyin'" (citiao?" WHERE " (RegExMatch(citiao, "^([a-z'_%]+)$")?(RegExMatch(citiao, "^([_%]+)$")?"value " operate "'" citiao "' OR":"jp " operate " '" RegExReplace(citiao,"([a-z])[a-z_]*","$1") "' AND") " key " operate " '" citiao "'":"value " operate " '" citiao "'"):"") " ORDER BY " (citiao?"key,weight":"rowid") " DESC "
	Else If (TableName~="hotstrings|functions|symbol")
		fy_SQL:="SELECT rowid,key,value,comment FROM 'extend'.'" TableName "'" (citiao?" WHERE " (RegExMatch(citiao, "^([a-z;_%]+)$")?"key " operate " '" citiao "' OR value " operate "'" citiao "' OR comment " operate "'" citiao "'":"value " operate " '" citiao "' OR comment " operate "'" citiao "'"):"") " ORDER BY " (citiao?"key ":"rowid DESC ")
	Else If (TableName="customs")
		fy_SQL:="SELECT rowid,key,value,comment FROM 'extend'.'customs'" (citiao?" WHERE " (RegExMatch(citiao, "^([a-z;'_%]+)$")?"key " operate " '" citiao "' OR value " operate "'" citiao "'":"value " operate " '" citiao "'"):"") " ORDER BY " (citiao?"key ":"rowid DESC ")
	Else If (TableName="English")
		fy_SQL:="SELECT rowid,key,weight FROM 'extend'.'English'" (citiao?" WHERE key " operate " '" citiao "'":"") " ORDER BY " (citiao?"key ":"rowid DESC ")
	Else If (TableName="Cliphistory")
		fy_SQL:="SELECT rowid,* FROM 'Cliphistory' ORDER BY rowid DESC "
	Else
		fy_SQL:="SELECT rowid,key,value,weight FROM '" TableName "'" (citiao?" WHERE " (RegExMatch(citiao, "^([a-z;'_% ]+)$")?"key " operate " '" citiao "'" (!(citiao~="[a-z]")?" OR value " operate "'" citiao "'":""):"value " operate " '" citiao "'"):"") " ORDER BY " (citiao?"key,weight DESC ":"rowid DESC ")
GetTableBySQL:
	SB_SetText("获取数据库"),SB_SetText("",2),SB_SetText("",3)
	If DB.GetTable(fy_SQL~="i)^\s*SELECT\s+[a-z,\s]+?FROM"
		? RegExReplace(fy_SQL,"i)^\s*SELECT\s+.+?\s+FROM(.+)(ORDER BY.+)?$","SELECT COUNT(*) FROM$1")
		: "SELECT count(*) FROM (" fy_SQL ")", Result){
		ICELV1.RowCount:=Result.Rows[1, 1], ICELV1.Maxrowid:=0
		If (!InStr(TableName, "@"))&&!InStr(alltablenames "|", "|" TableName "|")&&!(TableName~="^(symbol|hotstrings|functions|customs|English|Cliphistory)$"){
			alltablenames .= "|" TableName
			GuiControl, 97:, TableName, %TableName%
		}
		GuiControl, 97:ChooseString, TableName, % (TableName="hotstrings"?"魔法字符串":TableName="functions"?"超级命令":TableName="customs"?"自定义短语":TableName="symbol"?"特殊符号":TableName)
	} Else If (DB.Err~="no such table"){
		CreateTable(TableName)
		If (TableName="pinyin")
			DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_pinyin' ON ""pinyin"" (""jp"");")
		Else
			DB.Exec("CREATE INDEX IF NOT EXISTS " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.":"'main'.") "'sy_" TableName "' ON """ TableName """ (""key"");")
	} Else {
		SB_SetText("获取失败"), ICELV1.Maxrowid:=0
		MsgBox, 16, SQLite错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
		Return
	}
	SB_SetText("浏览数据"), ICELV1.List:=[]
	ICELV1.ViewSQL(fy_SQL)
	ICELV1.Fresh()
	SB_SetText("浏览数据"),SB_SetText("加载用时：" (A_TickCount - Start) " ms",2)
	SB_SetText("共" RegExReplace(ICELV1.RowCount, "(\d\d\d\d)", ",$1", , , Mod(StrLen(ICELV1.RowCount),4)?Mod(StrLen(ICELV1.RowCount),4)+1:5) "条",3)
Return

citiao_create(TableName, str){
	local
	global DB, historyrecord, MethodTable, HLV1, DebugLevel
	Gui, 97:Default
	GuiControl, Focus, %HLV1%
	Gui, 97:+Disabled
	Suspend, On
	index:=0, tvar:="", start:=A_TickCount
	SB_SetText("魔法创建"),SB_SetText("创建词条中 ...",2),SB_SetText("",3)
	DB.Exec("BEGIN TRANSACTION;")
	DB.GetTable("SELECT max(rowid) FROM '" TableName "'", Result), firstrowid:=Result.Rows[1][1]
	Loop, Parse, str, `n, `r
	{
		If (A_LoopField="")
			Continue
		hang:=A_LoopField
		RegExMatch(hang, "^([a-zA-Z]['a-zA-Z]*)", key)						; 查找key
		hang:=StrReplace(hang, key)
		RegExMatch(hang, "(\d+)", tcipin)							; 查找词频
		hang:=StrReplace(hang, tcipin)
		RegExMatch(hang, "O)([^\x00-\xff]+)", tcizu, 1)				; 查找双字节字符
		If !tcizu.Value[1]
			Continue
		If !key
			tvar .= tcizu.Value[1] (tcipin?"=" tcipin:"") "`n"
		Else {
			StringLower, key, % Trim(key,"'")
			If (TableName = "pinyin"){
				If !InStr(key, "'")									; 未分词的分词处理
					key:=Trim(pyfenci(key,"pinyin"),"'")
			} Else
				key:=StrReplace(key,"'","")
			If (TableName="pinyin")
				DB.Exec("INSERT INTO 'main'.'pinyin' VALUES (""" RegExReplace(key, "([a-z])[a-z]*", "$1") """,""" key """,'" tcizu.Value[1] "'," (tcipin?tcipin:"ifnull((SELECT max(weight) FROM 'pinyin' WHERE jp=""" RegExReplace(key,"([a-z])[a-z]*","$1") """ AND key=""" key """),4999)+1") ")")
			Else
				DB.Exec("INSERT INTO 'main'.'" TableName "' VALUES ('" key "','" tcizu.Value[1] "'," (tcipin?tcipin:"ifnull((SELECT max(weight) FROM '" TableName "' WHERE key='" key "'),4999)+1") ")")
		}
		While RegExMatch(A_LoopField, "O)([^\x00-\xff]+)", tcizu, tcizu.pos[1]+tcizu.len[1]){			; 查找双字节字符加入待转序列
			If !key
				tvar .= tcizu.Value[1] (tcipin?"=" tcipin:"") "`n"
			Else {
				key:=StrReplace(key,"'","''")
				If (TableName="pinyin")
					DB.Exec("INSERT INTO 'main'.'pinyin' VALUES ('" RegExReplace(key, "([a-z])[a-z]*", "$1") "','" key "','" tcizu.value[1] "'," (tcipin?tcipin:"ifnull((SELECT max(weight) FROM 'pinyin' WHERE jp=""" RegExReplace(key,"([a-z])[a-z]*","$1") """ AND key=""" key """),4999)+1") ")")
				Else
					DB.Exec("INSERT INTO 'main'.'" TableName "' VALUES ('" key "','" tcizu.value[1] "'," (tcipin?tcipin:"ifnull((SELECT max(weight) FROM '" TableName "' WHERE key='" key "'),4999)+1") ")")
			}
		}
	}
	; If (tvar) {							; 转换成拼音、wubi86
	; 	Try tvar:=IMEConverter(TableName,tvar,"`t",MethodTable[TableName])
	; 	Catch
	; 		tvar:=""
	; 	Loop, Parse, tvar, `n, `r
	; 	{
	; 		If (A_LoopField=="")
	; 			Continue
	; 		tarr:=StrSplit(A_LoopField,"`t","'")
	; 		If (TableName="pinyin")
	; 			DB.Exec("INSERT INTO 'main'.'pinyin' VALUES(""" RegExReplace(tarr[1],"([a-z])[a-z]*","$1") """,""" tarr[1] """,'" tarr[2] "'," (tarr[3]?tarr[3]:"ifnull((SELECT max(weight) FROM 'pinyin' WHERE jp=""" RegExReplace(tarr[1],"([a-z])[a-z]*","$1") """ AND key=""" tarr[1] """),4999)+1") ")")
	; 		Else
	; 			DB.Exec("INSERT INTO 'main'.'" TableName "' VALUES('" tarr[1] "','" tarr[2] "'," (tarr[3]?tarr[3]:"ifnull((SELECT max(weight) FROM '" TableName "' WHERE key='" tarr[1] "'),4999)+1") ")")
	; 	}
	; }
	If (DB.ErrorCode)
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	tvar:="",tarr:=""
	If (TableName="pinyin")
		DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_pinyin' ON 'pinyin' ('jp');")
	Else
		DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_" TableName "' ON '" TableName "' ('key');")
	Gui, 97:-Disabled
	Suspend, Off
	If DB.Exec("COMMIT TRANSACTION;"){
		DB.GetTable("SELECT max(rowid) FROM 'main'.'" TableName "'", Result), lastrowid:=Result.Rows[1][1]
		If (lastrowid>firstrowid)
			historyrecord.Push(["DELETE FROM 'main'.'" TableName "' WHERE rowid>" firstrowid " AND rowid<" lastrowid+1 ";","魔法创建"])
	} Else {
		SB_SetText("导入失败",1), SB_SetText("",2)
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
		Return
	}
	Gosub Refresh
	SB_SetText("创建完毕，完成用时 " A_TickCount - Start " ms",2)
}

WriteCiKu(){
	; ======================================================================================================================
	; 导入词库
	; ======================================================================================================================
	local
	Critical
	global DB, alltablenames, HLV1, ENTabNames, MethodTable
	Gui 97:+OwnDialogs
	FileSelectFile, MaBiaoFile, 3, , 导入词库 - 导入文件名=导入词库名, Text Documents (*.txt)
	SplitPath, MaBiaoFile, , , , filename
	If (MaBiaoFile = ""){
		SB_SetText("取消导入",2)
		Return
	} Else {
		SB_SetText("选择了词库：" MaBiaoFile,2), SB_SetText("",3)
	}
	RegExMatch(filename, "^[^_]+",filename)
	If !(filename)
		Return
	Else If (filename~="sp$"){
		MsgBox, 52, 提示, 导入的文件名前缀不能以sp结尾！
		Return
	}
	TableName:=ENTabNames[filename]?ENTabNames[filename]:filename
	If DB.GetTable("SELECT rowid FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'") TableName "' LIMIT 1;", Result){
		If Result.Rows[1][1] {
			_:=Func("OnMsgBox").Bind("合并","替换")
			OnMessage(0x44, _)
			MsgBox, 51, 注意, 合并还是替换%filename%词库？`n替换将丢失原词库！
			OnMessage(0x44, _, 0)
			IfMsgBox, Cancel
			{
				SB_SetText("取消导入")
				Return
			}
			DB.Exec("BEGIN TRANSACTION;")
			DB.Exec("DROP INDEX IF EXISTS " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.":"'main'.") "'sy_" TableName "';")
			IfMsgBox No
				DB.Exec("DELETE FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'") TableName "'")
			DB.Exec("COMMIT TRANSACTION;")
		}
	} Else If !(DB.ErrorMsg~="no such table")
		If !CreateTable(TableName){
			SB_SetText("导入失败"), SB_SetText("",2)
			Return
		}
	If (!InStr(TableName, "@"))&&!InStr(alltablenames "|", "|" TableName "|")&&!(TableName~="^(symbol|hotstrings|functions|customs|English|Cliphistory)$"){
		alltablenames .= "|" TableName
		GuiControl, 97:, TableName, %TableName%
	}
	GuiControl, 97:ChooseString, TableName, % (TableName="hotstrings"?"魔法字符串":TableName="functions"?"超级命令":TableName="customs"?"自定义短语":TableName="symbol"?"特殊符号":TableName)
	Gosub SwitchTable2
	LV_Delete()
	SB_SetText("词库导入"),SB_SetText("读取文件...",2),SB_SetText("",3)
	Start:=A_TickCount
	; ======================================================================================================================
	; #######################################词组拼音生成导入###########################
	; ======================================================================================================================
	GuiControl, Focus, %HLV1%
	Gui, 97:+Disabled
	Suspend, On
	SB_SetText("导入中，请稍后...", 2)
	Mabiao:=FileRead(MaBiaoFile, -10)
	duoyi:=0, def:=1
	If !(TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"){
		RegExMatch(MaBiao:=Trim(MaBiao," `n`r"), "[\t =]", delimiter)
		delimiter:=(delimiter~="^(\t|=| )$"?delimiter:"`t")
		If RegExMatch(MaBiao, "m)(*ANYCRLF)^[^\x00-\x7e]+" delimiter "[a-z']+")
			def:=0, Mabiao:=""
		Else If (RegExMatch(MaBiao, "m)(*ANYCRLF)^[^\x00-\x7e]+([= \t]\d+)?$")){
			Return
			; SB_SetText("转换词库中，请稍后...",2),SB_SetText("",3)
			; MaBiao:=IMEConverter(TableName, "`f" MaBiaoFile,delimiter,MethodTable[TableName])
			; If (SubStr(MaBiao, 1, 1)="`f")
			; 	MaBiaoFile:=SubStr(Mabiao, 2), Mabiao:=""
				; FileRead, Mabiao, % "*P1200 " SubStr(MaBiao, 2)
		} Else If RegExMatch(MaBiao, "[a-z']+[= \t][^\x00-\x7e]+[= \t][^\x00-\x7e]+")
			Mabiao:="", duoyi:=1
			; Mabiao:=FileRead(MaBiaoFile)
		Else
			Mabiao:=""
	} Else If (TableName~="i)^(hotstrings|functions)$")
		duoyi:=2, Mabiao:=""
		; Mabiao:=FileRead(MaBiaoFile)
	Else
		Mabiao:=""
	SB_SetText("词库导入中，请稍后...",2)
	If (Mabiao=""&&FileExist(DllFolder "\cikutools.dll")){
		ret:=ImportToDB(DB,TableName,MaBiaoFile,duoyi,def)
	} Else {
		If (Mabiao="")
			Mabiao:=FileRead(MaBiaoFile)
		ret:=writeDB(DB,TableName,MaBiao,delimiter,1)
	}
	If (ret)
		SB_SetText("导入失败",1), SB_SetText("",2), OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	Else {
		Gosub GetTable
		SB_SetText("导入完毕，完成用时 " A_TickCount - Start " ms",2)
	}
	Gui, 97:-Disabled
	Suspend, Off
}
ImportToDB(DB,TableName,file,duoyi:=0,def:=1){
	local
	global historyrecord
	insstr:=TableName="English"?"?,?":(TableName="pinyin"?"?4,":"") (def?"?1,?2,?3":"?2,?1,?3")
	SQL:="INSERT INTO '" (TableName~="^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"extend":"main") "'.'" TableName "' VALUES(" insstr ");" 
	DB.GetTable("SELECT max(rowid) FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'") TableName "'", Result), firstrowid:=Result.Rows[1][1]?Result.Rows[1][1]:0
	ret:=DllCall(DllFolder "\cikutools.dll\ImportToDB", "Ptr", DB._Handle, "WStr", SQL, "WStr", file, "Int", duoyi)
	DB.GetTable("SELECT max(rowid) FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'") TableName "'", Result), lastrowid:=Result.Rows[1][1]?Result.Rows[1][1]:0
	DB.Exec("BEGIN TRANSACTION;")
	If (TableName="pinyin"){
		; DB.Exec("UPDATE 'main'.'pinyin' SET jp=szm(key) WHERE rowid>" firstrowid " AND rowid<" lastrowid+1 ";")
		DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_pinyin' ON 'pinyin' ('jp');")
	} Else If (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$")
		DB.Exec("CREATE INDEX IF NOT EXISTS 'extend'.'sy_" TableName "' ON '" TableName "' ('key');")
	Else
		DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_" TableName "' ON '" TableName "' ('key');")
	DB.Exec("COMMIT TRANSACTION;")
	If (lastrowid>firstrowid)
		historyrecord.Push(["DELETE FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' WHERE rowid>" firstrowid " AND rowid<" lastrowid+1 ";","导入"])
	Return (ret!=0)
}
deriveCiKu(){													; 导出词库
	local
	global TableName, HLV1, DB, fy_SQL
	Gui 97:+OwnDialogs
	Gui, 97:Default
	If !(TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$")&&FileExist(A_ScriptDir "\ciku_demo.db")
		&&DB.Exec("ATTACH DATABASE '" A_ScriptDir "/ciku_demo.db' As 'demo';")
		&&DB.GetTable("SELECT ROWID FROM 'demo'.'" TableName "' LIMIT 1;", Result){
		_:=Func("OnMsgBox").Bind("用户词库","总词库")
		OnMessage(0x44, _)
		MsgBox, 35, 选择词库分类, 导出用户词库或总词库？
		OnMessage(0x44, _, 0)
		start:=A_TickCount
		IfMsgBox Yes, {
			SB_SetText("词库导出"), SB_SetText("导出中...",2)
			tvar:=DeriveCustoms(DB, TableName)
		} Else IfMsgBox No, {
			SB_SetText("词库导出"), SB_SetText("导出中...",2)
			tvar:=DeriveTable(DB, fy_SQL)
		} Else {
			DB.Exec("DETACH DATABASE 'demo';")
			Return
		}
	} Else
		start:=A_TickCount, SB_SetText("词库导出"),SB_SetText("导出中...",2), tvar:=DeriveTable(DB, fy_SQL)
	WinSet Redraw, , ahk_class%HLV1%
	DB.Exec("DETACH DATABASE 'demo';")
	SB_SetText("导出完毕"),SB_SetText("完成用时：" A_TickCount - start " ms，备份文件在：" A_ScriptDir "目录",2)
	MsgBox, 64, 导出完毕, % "导出：" TableName "`n共" tvar "条"
}
OnMsgBox(Bt1,Bt2){
	global YzimePID
	DetectHiddenWindows, On
	If (WinExist("ahk_class #32770 ahk_pid " . YzimePID)){
		ControlSetText Button1, %Bt1%
		ControlSetText Button2, %Bt2%
	}
}
DeriveTable(DB, SQL, timestamp:="") {
	global TableName
	DB.ErrorMsg := ""
	DB.ErrorCode := 0
	If !(DB._Handle) {
		DB.ErrorMsg := "Invalid database handle!"
		Return False
	}
	GuiControlGet, def, 97:, Edit2
	If (def="")
		SQL := RegExReplace(SQL, "i)rowid\s+desc","rowid asc")
	timestamp:=timestamp?timestamp:A_Now, RegExMatch(SQL, "iO)FROM\s+('?[a-z]+'?\.)?('[^']+?'|[^'(),\s]+)\s*", TableName), TableName := Trim(TableName.Value[2], "'")
	SQL := RegExReplace(SQL, "i)SELECT\s+rowid\s*,", "SELECT "), new := ""
	DB.GetTable("SELECT * FROM (" SQL ") LIMIT 1", cols)
	If (TableName~="i)^(hotstrings|functions)$"){
		new = '["'||key||'","'||replace(replace(replace(replace(replace(value,'\','\\'),'"','\"'),x'09','\t'),x'0a','\n'),x'0d','\r')||'","'||comment||'"]'
	} Else
		Loop % cols.ColumnCount
			new .= (A_Index>1?"||x'09'||":"") cols.ColumnNames[A_Index]
	If FileExist(DllFolder "\cikutools.dll"){
		SQL := "SELECT " new " FROM (" SQL ")"
		RowCount := DllCall(DllFolder "\cikutools.dll\ExportToFile", "Ptr", DB._Handle, "WStr", SQL, "WStr", TableName "_" timestamp ".txt")
		Return RowCount ? RowCount : 0
	}
	SQL := "SELECT " new "||x'0a' FROM (" SQL ")"
	; obj.utf8len:=MCode("1,x86:8B4424048D50018A084084C975F92BC2C3,x64:48C7C0FFFFFFFF48FFC0803C010075F7C3")
	CBPtr := 0, Err := 0, obj := [], obj.RowCount := 0
	obj.file := FileOpen(TableName "_" timestamp ".txt", "w", "UTF-8")
	CBPtr := RegisterCallback("callback_DeriveTable", "F C", 4)
	DB._StrToUTF8(SQL, UTF8)
	RC := DllCall("SQLite3.dll\sqlite3_exec", "Ptr", DB._Handle, "Ptr", &UTF8, "Int", CBPtr
		, "Ptr", Object(obj), "PtrP", Err, "Cdecl Int")
	obj.file.Close()
	CallError := ErrorLevel
	DllCall("Kernel32.dll\GlobalFree", "Ptr", CBPtr)
	If (CallError) {
		DB.ErrorMsg := "DLLCall sqlite3_exec failed!"
		DB.ErrorCode := CallError
		Return False
	}
	If (RC) {
		DB.ErrorMsg := DB._ReturnMsg(RC)
		If (DB.ErrorMsg = "")
			DB.ErrorMsg := StrGet(Err, "UTF-8")
		DB.ErrorCode := RC
		DllCall("SQLite3.dll\sqlite3_free", "Ptr", Err, "Cdecl")
		Return False
	}
	Return obj.RowCount
}

DeriveCustoms(DB, TableName){
	; DB.Exec("ATTACH DATABASE '" A_ScriptDir "/ciku_demo.db' As 'demo';")
	DB.Exec("CREATE TEMPORARY TABLE '" TableName "' (key TEXT,value TEXT,weight INTEGER,len INTEGER);")
	DB.Exec("INSERT INTO 'temp'.'" TableName "' SELECT key,value,weight,length(value) FROM 'main'.'" TableName "' ORDER BY 4,key,weight DESC;")
	DB.Exec("DELETE FROM 'temp'.'" TableName "' WHERE key||'|'||value in (SELECT key||'|'||value FROM 'demo'.'" TableName "');")
	RowsCt:=DeriveTable(DB, "SELECT key,value,weight FROM 'temp'.'" TableName "'", "用户词库_" A_Now)
	DB.Exec("DROP TABLE 'temp'.'" TableName "';")
	; DB.Exec("DETACH DATABASE 'demo';")
	Return RowsCt
}

downloadCiku:
	Run, https://www.autoahk.com/archives/16339
	; Run, https://pan.baidu.com/s/1ZTJym45A1wgcaBQ4d_fCvQ
Return

writeDB(DB, TableName, ByRef MaBiao, delimiter:="=", TRANSACTION:=0){
	local
	global historyrecord
	If (TRANSACTION){
		If (DB._Path=":memory:"&&!(TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$")){
			Progress, Off
			MsgBox, 48, 提示, 批量导入前请先关闭内存数据库选项！
			Return 1
		}
		DB.Exec("BEGIN TRANSACTION;")
		DB.Exec("DROP INDEX IF EXISTS " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.":"'main'.") "'sy_" TableName "';")
	}
	If (TableName ~= "i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$")
		_SQL = CREATE TABLE IF NOT EXISTS 'extend'.'%TableName%' ("key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"comment" TEXT NOT NULL DEFAULT '');
	Else If (TableName="pinyin")
		_SQL = CREATE TABLE IF NOT EXISTS 'main'.'pinyin' ("jp" TEXT NOT NULL DEFAULT '',"key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"weight" INTEGER DEFAULT 5000);
	Else If (TableName="English")
		_SQL = CREATE TABLE IF NOT EXISTS 'extend'.'English' ("key" TEXT NOT NULL DEFAULT '' COLLATE NOCASE,"weight" INTEGER DEFAULT 5000);
	Else
		_SQL = CREATE TABLE IF NOT EXISTS 'main'.'%TableName%' ("key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"weight" INTEGER DEFAULT 5000);
	DB.Exec(_SQL)
	DB.GetTable("SELECT max(rowid) FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'") TableName "'", Result), firstrowid:=Result.Rows[1][1]
	index:=0, _SQL:=""
	If (TableName="pinyin"){
		Loop, Parse, MaBiao, `n, `r
		{
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,delimiter)
			tarr[1]:=Format("{:L}", tarr[1])
			If (tarr[3]="")
				index++, _SQL .= "`nINSERT INTO 'pinyin' VALUES(""" RegExReplace(tarr[1],"([a-z])[a-z]*","$1") """,""" tarr[1] """,'" tarr[2] "',5000);"
			Else If (tarr[3]~="^\d+(\.\d+)?")
				index++, _SQL .= "`nINSERT INTO 'pinyin' VALUES(""" RegExReplace(tarr[1],"([a-z])[a-z]*","$1") """,""" tarr[1] """,'" tarr[2] "'," tarr[3] ");"
			Else {
				tvar:=tarr.Length()
				Loop % tvar-2
					_SQL .= "`nINSERT INTO 'pinyin' VALUES(""" RegExReplace(tarr[1],"([a-z])[a-z]*","$1") """,""" tarr[1] """,'" tarr[A_Index+1] "'," (tvar-A_Index+4999) ");"
				index++, _SQL .= "`nINSERT INTO 'pinyin' VALUES(""" RegExReplace(tarr[1],"([a-z])[a-z]*","$1") """,""" tarr[1] """,'" tarr.Pop() "',5000);"
			}
			If (index>199)
				DB.Exec(LTrim(_SQL,"`n")), index:=0, _SQL:=""
		}
		; DB.Exec("UPDATE 'pinyin' SET weight=weight-(SELECT min(weight) from 'pinyin') WHERE weight<0")
	} Else If (TableName~="hotstrings|functions"){
		Loop, Parse, MaBiao, `n, `r
		{
			If (A_LoopField = "")
				Continue
			Try {
				tarr:=JSON.Load(A_LoopField)
				index++, _SQL .= "`nINSERT INTO 'extend'.'" TableName  "' VALUES('" tarr[1] "','" StrReplace(tarr[2],"'","''") "','" tarr[3] "');"
			}
			If (index>199)
				DB.Exec(LTrim(_SQL,"`n")), index:=0, _SQL:=""
		}
	} Else If (TableName="customs"){
		Loop, Parse, MaBiao, `n, `r
		{
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,delimiter)
			If (tarr[3]="")
				index++, _SQL .= "`nINSERT INTO 'extend'.'customs' VALUES('" tarr[1] "','" StrReplace(tarr[2],"'","''") "','001');"
			Else If (tarr[3]~="^\d+(\{.*\})?")
				index++, _SQL .= "`nINSERT INTO 'extend'.'customs' VALUES('" tarr[1] "','" StrReplace(tarr[2],"'","''") "','" tarr[3] "');"
			Else {
				tvar:=tarr.Length()
				Loop % tvar-1
					index++, _SQL .= "`nINSERT INTO 'extend'.'customs' VALUES('" tarr[1] "','" StrReplace(tarr[A_Index+1],"'","''") "','" Format("{:03}", A_Index) "');"
			}
			If (index>199)
				DB.Exec(LTrim(_SQL,"`n")), index:=0, _SQL:=""
		}
	} Else If (TableName="symbol"){
		Loop, Parse, MaBiao, `n, `r
		{
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,delimiter)
			index++, _SQL .= "`nINSERT INTO 'extend'.'symbol' VALUES('" tarr[1] "','" StrReplace(tarr[2],"'","''") "','" tarr[3] "');"
			If (index>199)
				DB.Exec(LTrim(_SQL,"`n")), index:=0, _SQL:=""
		}
	} Else If (TableName="English"){
		Loop, Parse, MaBiao, `n, `r
		{
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,delimiter)
			index++, _SQL .= "`nINSERT INTO 'extend'.'English' VALUES(""" tarr[1] """,'" tarr[2] "');"
			If (index>199)
				DB.Exec(LTrim(_SQL,"`n")), index:=0, _SQL:=""
		}
	} Else {
		Loop, Parse, MaBiao, `n, `r
		{
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,delimiter)
			If (tarr[3]="")
				index++, _SQL .= "`nINSERT INTO '" TableName "' VALUES('" tarr[1] "','" tarr[2] "',5000);"
			Else If (tarr[3]~="^\d+(\.\d+)?")
				index++, _SQL .= "`nINSERT INTO '" TableName "' VALUES('" tarr[1] "','" tarr[2] "'," tarr[3] ");"
			Else {
				tvar:=tarr.Length()
				Loop % tvar-2
					index++, _SQL .= "`nINSERT INTO '" TableName "' VALUES('" tarr[1] "','" tarr[A_Index+1] "'," (tvar-A_Index+4999) ");"
				index++, _SQL .= "`nINSERT INTO '" TableName "' VALUES('" tarr[1] "','" tarr.Pop() "',5000);"
			}
			If (index>199)
				DB.Exec(LTrim(_SQL,"`n")), index:=0, _SQL:=""
		}
	}
	If (index)
		DB.Exec(LTrim(_SQL,"`n")), index:=0, _SQL:=""
	MaBiao:=""
	If (TRANSACTION){
		If (TableName="pinyin")
			DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_pinyin' ON 'pinyin' ('jp');")
		Else If (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$")
			DB.Exec("CREATE INDEX IF NOT EXISTS 'extend'.'sy_" TableName "' ON '" TableName "' ('key');")
		Else
			DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_" TableName "' ON '" TableName "' ('key');")
		If !DB.Exec("COMMIT TRANSACTION;"){
			MsgBox, 16, 数据库错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
			DB.Exec("ROLLBACK;")
			Return 1
		}
	}
	DB.GetTable("SELECT max(rowid) FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'") TableName "'", Result), lastrowid:=Result.Rows[1][1]
	If (lastrowid>firstrowid)
		historyrecord.Push(["DELETE FROM " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") TableName "' WHERE rowid>" firstrowid " AND rowid<" lastrowid+1 ";","导入"])
}

Vacuum:
	SB_SetText("压缩词库"),SB_SetText("压缩中...",2),SB_SetText("",3),Start:=A_TickCount
	DB.Exec("Vacuum " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'":"'main'"))
	SB_SetText("压缩完成"),SB_SetText("完成用时：" A_TickCount-Start "ms",2)
Return
; ci_ku_Manager###############################################################################
; sqlite首字母函数
shouzimu(Context, ArgC, Values){
	; sqlite自定义函数 key生成首字母简拼函数 wo''men --> w''m
	__result:=""
	If (ArgC = 1){
		AddrN := DllCall("SQLite3.dll\sqlite3_value_text", "Ptr", NumGet(Values + 0, "UPtr"), "Cdecl UPtr")
		__result:=RegExReplace(StrGet(AddrN, "UTF-8"), "([a-z])[a-z]*", "$1")
	}
	DllCall("SQLite3.dll\sqlite3_result_text16", "Ptr", Context, "Str", __result, "Int", -1, "Ptr", 0, "Cdecl")
}
trad2simp(Context, ArgC, Values){
	local
	static dict, UTF8
	global DataPath
	If (ArgC!=1)
		Return
	If (dict=""){
		If FileExist(DataPath "@s2t.txt"){
			dict:=[]
			Mabiao:=FileRead(DataPath "@s2t.txt")
			Loop, Parse, Mabiao, `n, `r
			{
				tarr:=StrSplit(A_LoopField, ["=","`t"])
				If (tarr[1]~="^[^\x00-\xff]$")
					Loop, Parse, % tarr[2], %A_Space%
						dict[A_LoopField]:=tarr[1]
			}
		} Else {
			MsgBox, 48, 提示, 简繁转换文件不存在，请在Data目录下放置简繁转换文件@s2t.txt，格式如下：`n㐷=傌`n㐹=㑶 㐹`n㐽=偑`n码表=碼錶 碼表`n文本编码为UTF-8-Bom或ANSI
			Return
		}
	}
	str := StrGet(DllCall("SQLite3.dll\sqlite3_value_text", "Ptr", NumGet(Values + 0, "UPtr"), "Cdecl UPtr"), "UTF-8"), index:=1, simp:=""
	While index:=RegExMatch(str, "O).", match, index)
		simp .= dict[match.Value]?dict[match.Value]:match.Value, index+=match.Len
	VarSetCapacity(UTF8, StrPut(simp, "UTF-8"))
	Len:=StrPut(simp, &UTF8, "UTF-8")-1
	DllCall("SQLite3.dll\sqlite3_result_text", "Ptr", Context, "Ptr", &UTF8, "Int", Len, "Ptr", 0, "Cdecl")
	SetTimer, freedict, -10000
	Return
	freedict:
		dict:=""
	Return
}
remaketable(DB,Name){
	local
	If !Name
		Return
	DB.Exec("DROP TABLE IF EXISTS " (TableName~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.":"'main'.") "'hebing';")
	DB.Exec("BEGIN TRANSACTION;")
	If (Name~="^(hotstrings|functions|symbol|customs)$")
		_SQL = CREATE TABLE IF NOT EXISTS 'extend'.'hebing' ("key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"comment" TEXT NOT NULL DEFAULT '');
	Else If (Name="pinyin")
		_SQL = CREATE TABLE IF NOT EXISTS 'main'.'hebing' ("jp" TEXT NOT NULL DEFAULT '',"key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"weight" INTEGER DEFAULT 5000);
	Else If (Name="English")
		_SQL = CREATE TABLE IF NOT EXISTS 'extend'.'hebing' ("key" TEXT COLLATE NOCASE,"weight" INTEGER DEFAULT 5000);
	Else If (Name="Cliphistory")
		_SQL = CREATE TABLE IF NOT EXISTS 'extend'.'hebing' ("value" TEXT NOT NULL DEFAULT '');
	Else
		_SQL = CREATE TABLE IF NOT EXISTS 'main'.'hebing' ("key" TEXT NOT NULL DEFAULT '',"value" TEXT NOT NULL DEFAULT '',"weight" INTEGER DEFAULT 5000);
	If !DB.Exec(_SQL)
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	If (Name~="^(hotstrings|functions|symbol|customs)$")
		_SQL:="INSERT INTO 'extend'.'hebing' SELECT key,value,comment FROM 'extend'.'" Name "' GROUP by key,value ORDER BY key;"
	Else If (Name="pinyin")
		_SQL:="INSERT INTO 'hebing' SELECT jp,key,value,max(weight) FROM 'main'.'pinyin' GROUP by key,value ORDER BY jp,key,4 DESC;"
	Else If (Name="English")
		_SQL:="INSERT INTO 'extend'.'hebing' SELECT key,max(weight) FROM 'extend'.'" Name "' GROUP by key ORDER BY key;"
	Else If (Name="Cliphistory")
		_SQL:="INSERT INTO 'extend'.'hebing' SELECT * FROM 'extend'.'" Name "' GROUP by value ORDER BY rowid;"
	Else
		_SQL:="INSERT INTO 'hebing' SELECT key,value,max(weight) FROM 'main'.'" Name "' GROUP by key,value ORDER BY key,3 DESC;"
	If DB.Exec(_SQL){
		If !DB.Exec("DROP TABLE " (Name~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") Name "';ALTER TABLE " (Name~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$"?"'extend'.'":"'main'.'") "hebing' RENAME TO '" Name "';")
			OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	} Else
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	If (Name="pinyin")
		_SQL = CREATE INDEX IF NOT EXISTS "sy_%Name%" ON "%Name%" ("jp");
	Else If (Name~="i)^(symbol|hotstrings|functions|customs|English|Cliphistory)$")
		_SQL = CREATE INDEX IF NOT EXISTS 'extend'.'sy_%Name%' ON "%Name%" ("key");
	Else If (Name!="Cliphistory")
		_SQL = CREATE INDEX IF NOT EXISTS "sy_%Name%" ON "%Name%" ("key");
	DB.Exec(_SQL)
	If !DB.Exec("COMMIT TRANSACTION;")
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
}

; 编码生成函数
; IMEConverter(name,Str,delimiter:="`t",Method:=""){
; 	global srf_Plugins, UIAccess, YzimePID
; 	DetectHiddenWindows, on
; 	If (srf_Plugins["IMEConverter",1]=""){
; 		Run, % """" AhkPath """ """ A_ScriptDir "\Lib\tools\IMEConverter.ahk"" " YzimePID " " (tGUID:=CreateGUID()), , , tPID
; 		WinWait, % "ahk_pid" tPID, , 5
; 		srf_Plugins["IMEConverter",1]:=tPID, srf_Plugins["IMEConverter",2]:=tGUID
; 		Sleep 1000
; 	} Else {
; 		Process, Exist, % srf_Plugins["IMEConverter",1]
; 		If (!ErrorLevel){
; 			Run, % """" AhkPath """ """ A_ScriptDir "\Lib\tools\IMEConverter.ahk"" " YzimePID " " (srf_Plugins["IMEConverter",2]?srf_Plugins["IMEConverter",2]:(srf_Plugins["IMEConverter",2]:=CreateGUID())), , , tPID
; 			WinWait, % "ahk_pid" tPID, , 5
; 			srf_Plugins["IMEConverter",1]:=tPID
; 			Sleep 1000
; 		}
; 	}
; 	If (ErrorLevel=srf_Plugins["IMEConverter",1])||(ErrorLevel=0){
; 		Return ComObjActive(srf_Plugins["IMEConverter",2]).Converter(name, Str, delimiter, Method)
; 	} Else
; 		Return
; }
; ======================================================================================================================
; Namespace:      LV_InCellEdit (ListView列表单元格编辑类)
; Function:       Support for in-cell ListView editing.
; Tested with:    AHK 1.1.22.09 (1.1.20+ required)
; Tested on:      Win 10 Pro (x64)
; Change History: 1.2.02.00/2015-12-14/just me - Bug fix and support for centered columns.
;                 1.2.01.00/2015-09-08/just me - Added EditUserFunc option.
;                 1.2.00.00/2015-03-29/just me - New version based on AHK 1.1.20+ features.
;                 1.1.04.00/2014-03-22/just me - Added method EditCell
;                 1.1.03.00/2012-05-05/just me - Added back option BlankSubItem for method Attach
;                 1.1.02.00/2012-05-01/just me - Added method SetColumns
;                 1.1.01.00/2012-03-18/just me
; ======================================================================================================================
; CLASS LV_InCellEdit
;
; Unlike other in-cell editing scripts, this class is using the ListViews built-in edit control.
; Advantage:
;     You don't have to care about the font and the GUI, and most of the job can be done by handling common ListView
;     notifications.
; Disadvantage:
;     I've still found no way to prevent the ListView from blanking out the first subitem of the row while editing
;     another subitem. The only known workaround is to add a hidden first column.
;
; The class provides methods to restrict editing to certain columns, to directly start editing of a specified cell,
; and to deactivate/activate the built-in message handler for WM_NOTIFY messages (see below).
;
; The message handler for WM_NOTIFY messages will be activated for the specified ListView whenever a new instance is
; created. As long as the message handler is activated a double-click on any cell will show an Edit control within this
; cell allowing to edit the current content. The default behavior for editing the first column by two subsequent single
; clicks is disabled. You have to press "Esc" to cancel editing, otherwise the content of the Edit will be stored in
; the current cell. ListViews must have the -ReadOnly option to be editable.
;
; While editing, "Esc", "Tab", "Shift+Tab", "Down", and "Up" keys are registered as hotkeys. "Esc" will cancel editing
; without changing the value of the current cell. All other hotkeys will store the content of the edit in the current
; cell and continue editing for the next (Tab), previous (Shift+Tab), upper (Up), or lower (Down) cell. You cannot use
; the keys for other purposes while editing.
;
; All changes are stored in MyInstance.Changed. You may track the changes by triggering (A_GuiEvent == "F") in the
; ListView's gLabel and checking MyInstance["Changed"] as shown in the sample scipt. If "True", MyInstance.Changed
; contains an array of objects with keys "Row" (row number), "Col" (column number), and "Txt" (new content).
; Changed is one of the two keys intended to be accessed directly from outside the class.
;
; If you want to temporarily disable in-cell editing call MyInstance.OnMessage(False). This must be done also before
; you try to destroy the instance. To enable it again, call MyInstance.OnMessage().
;
; To avoid the loss of Gui events and messages the message handler might need to be 'critical'. This can be
; achieved by setting the instance property 'Critical' to the required value (e.g. MyInstance.Critical:=100).
; New instances default to 'Critical, Off'. Though sometimes needed, ListViews or the whole Gui may become
; unresponsive under certain circumstances if Critical is set and the ListView has a g-label.
; ======================================================================================================================
Class LV_InCellEdit {
	; Instance properties -----------------------------------------------------------------------------------------------
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; META FUNCTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; ===================================================================================================================
	; __New()         Creates a new LV_InCellEdit instance for the specified ListView.
	; Parameters:     HWND           -  ListView's HWND
	;                 Optional ------------------------------------------------------------------------------------------
	;                 HiddenCol1     -  ListView with hidden first column
	;                                   Values:  True / False
	;                                   Default: False
	;                 BlankSubItem   -  Blank out subitem's text while editing
	;                                   Values:  True / False
	;                                   Default: False
	;                 EditUserFunc   -  The name of a user-defined funtion to be called from
	;                                   LVN_BEGINEDITLABEL and LVN_ENDEDITLABEL.
	;                                   The function must accept at least 6 Parameters:
	;                                      State -  The state of the edit operation: BEGIN / END
	;                                      HLV   -  The handle to the ListView.
	;                                      HED   -  The handle to the edit control.
	;                                      Row   -  The row number of the edited item.
	;                                      Col   -  The column number of the edited item.
	;                                      Text  -  The edited item's text before / after editing.
	;                                   To avoid the loss of messages the function should Return as soon as possible.
	; ===================================================================================================================
	__New(HWND, HiddenCol1:=False, BlankSubItem:=False, EditUserFunc:="") {
		If (This.Base.Base.__Class) ; do not instantiate instances
			Return False
		If This.Attached[HWND] ; HWND is already attached
			Return False
		If !DllCall("IsWindow", "Ptr", HWND) ; invalid HWND
			Return False
		VarSetCapacity(Class, 512, 0)
		DllCall("GetClassName", "Ptr", HWND, "Str", Class, "Int", 256)
		If (Class <> "SysListView32") ; HWND doesn't belong to a ListView
			Return False
		If (EditUserFunc <> "") && (Func(EditUserFunc).MaxParams < 6)
			Return False
		; ----------------------------------------------------------------------------------------------------------------
		; Set LVS_EX_DOUBLEBUFFER (0x010000) style to avoid drawing issues.
		SendMessage, 0x1036, 0x010000, 0x010000, , % "ahk_id " . HWND ; LVM_SETEXTENDEDLISTVIEWSTYLE
		This.HWND:=HWND
		This.HEDIT:=0
		This.Item:=-1
		This.SubItem:=-1
		This.ItemText:=""
		This.RowCount:=0
		This.ColCount:=0
		This.List:=""
		This.Cancelled:=False
		This.Next:=False
		This.Skip0:=!!HiddenCol1
		This.Blank:=!!BlankSubItem
		This.Critical:="Off"
		This.PageSize:=500
		This.DW:=0
		This.EX:=0
		This.EY:=0
		This.EW:=0
		This.EH:=0
		This.LX:=0
		This.LY:=0
		This.LR:=0
		This.LW:=0
		This.SW:=0
		ControlGet, Styles, Style,,, ahk_id%HWND%
		If (Styles & 0x1000)
			This.OWNERDATA:=1
		If (EditUserFunc <> "")
			This.EditUserFunc:=Func(EditUserFunc)
		This.OnMessage()
		This.Attached[HWND]:=True
	}
	; ===================================================================================================================
	__Delete() {
		This.Attached.Remove(This.HWND, "")
		WinSet, Redraw, , % "ahk_id " . This.HWND
	}
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; PUBLIC INTERFACE ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; ===================================================================================================================
	; EditCell        Edit the specified cell, if possible.
	; Parameters:     Row   -  1-based row number
	;                 Col   -  1-based column number
	;                          Default: 0 - edit the first editable column
	; Return values:  True on success; otherwise False
	; ===================================================================================================================
	EditCell(Row, Col:=0) {
		If !This.HWND
			Return False
		ControlGet, Rows, List, Count, , % "ahk_id " . This.HWND
		; This.RowCount:=Rows - 1
		ControlGet, ColCount, List, Count Col, , % "ahk_id " . This.HWND
		; This.ColCount:=ColCount - 1
		If (Col = 0) {
			If (This["Columns"])
				Col:=This.Columns.MinIndex() + 1
			ELse If This.Skip0
				Col:=2
			Else
				Col:=1
		}
		If (Row < 1) || (Row > Rows) || (Col < 1) || (Col > ColCount)
			Return False
		If (Column = 1) && This.Skip0
			Col:=2
		If (This["Columns"])
			If !This.Columns[Col - 1]
				Return False
		VarSetCapacity(LPARAM, 1024, 0)
		NumPut(Row - 1, LPARAM, (A_PtrSize * 3) + 0, "Int")
		NumPut(Col - 1, LPARAM, (A_PtrSize * 3) + 4, "Int")
		This.NM_DBLCLICK(&LPARAM)
		Return True
	}
	; ===================================================================================================================
	; SetColumns      Sets the columns you want to edit
	; Parameters:     ColNumbers* -  zero or more numbers of column which shall be editable. If entirely omitted,
	;                                the ListView will be reset to enable editing of all columns.
	; Return values:  True on success; otherwise False
	; ===================================================================================================================
	SetColumns(ColNumbers*) {
		If !This.HWND
			Return False
		This.Remove("Columns")
		If (ColNumbers.MinIndex() = "")
			Return True
		ControlGet, ColCount, List, Count Col, , % "ahk_id " . This.HWND
		Indices:=[]
		For Each, Col In ColNumbers {
			If Col Is Not Integer
				Return False
			If (Col < 1) || (Col > ColCount)
				Return False
			Indices[Col - 1]:=True
		}
		This["Columns"]:=Indices
		Return True
	}
	; ===================================================================================================================
	; OnMessage       Activate / deactivate the message handler for WM_NOTIFY messages for this ListView
	; Parameters:     Apply    -  True / False
	;                             Default: True
	; Return Value:   Always True
	; ===================================================================================================================
	OnMessage(Apply:=True) {
		If !This.HWND
			Return False
		If (Apply) && !This.HasKey("NotifyFunc") {
			This.NotifyFunc:=ObjBindMethod(This, "On_WM_NOTIFY")
			OnMessage(0x004E, This.NotifyFunc) ; add the WM_NOTIFY message handler
		}
		Else If !(Apply) && This.HasKey("NotifyFunc") {
			OnMessage(0x004E, This.NotifyFunc, 0) ; remove the WM_NOTIFY message handler
			This.NotifyFunc:=""
			This.Remove("NotifyFunc")
		}
		WinSet, Redraw, , % "ahk_id " . This.HWND
		Return True
	}
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; PRIVATE PROPERTIES ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; Class properties --------------------------------------------------------------------------------------------------
	Static Attached:={}
	Static OSVersion:=DllCall("GetVersion", "UChar")
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; PRIVATE METHODS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	; -------------------------------------------------------------------------------------------------------------------
	; WM_COMMAND message handler for edit notifications
	; -------------------------------------------------------------------------------------------------------------------
	On_WM_COMMAND(W, L, M, H) {
		; LVM_GETSTRINGWIDTHW = 0x1057, LVM_GETSTRINGWIDTHA = 0x1011
		Critical, % This.Critical
		If (L = This.HEDIT) {
			N:=(W >> 16)
			If (N = 0x0400) || (N = 0x0300) || (N = 0x0100) { ; EN_UPDATE | EN_CHANGE | EN_SETFOCUS
				If (N = 0x0100) ; EN_SETFOCUS
					SendMessage, 0x00D3, 0x01, 0, , % "ahk_id " . L ; EM_SETMARGINS, EC_LEFTMARGIN
				ControlGetText, EditText, , % "ahk_id " . L
				SendMessage, % (A_IsUnicode ? 0x1057 : 0x1011), 0, % &EditText, , % "ahk_id " . This.HWND
				EW:=ErrorLevel + This.DW
				, EX:=This.EX
				, EY:=This.EY
				, EH:=This.EH + (This.OSVersion < 6 ? 3 : 0) ; add 3 for WinXP
				If (EW < This.MinW)
					EW:=This.MinW
				If (EX + EW) > This.LR
					EW:=This.LR - EX
				DllCall("SetWindowPos", "Ptr", L, "Ptr", 0, "Int", EX, "Int", EY, "Int", EW, "Int", EH, "UInt", 0x04)
				If (N = 0x0400) ; EN_UPDATE
					Return 0
			}
		}
	}
	; -------------------------------------------------------------------------------------------------------------------
	; WM_HOTKEY message handler
	; -------------------------------------------------------------------------------------------------------------------
	On_WM_HOTKEY(W, L, M, H) {
		; LVM_CANCELEDITLABEL = 0x10B3, Hotkeys: 0x801B  (Esc -> cancel)
		If (H = This.HWND) {
			If (W = 0x801B) { ; Esc
				This.Cancelled:=True
				PostMessage, 0x10B3, 0, 0, , % "ahk_id " . H
			} Else {
				; SendMessage, 0x10B3, 0, 0, , % "ahk_id " . H
				This.Next:=True
				This.NextSubItem(W)
			}
			Return False
		}
	}
	; -------------------------------------------------------------------------------------------------------------------
	; WM_NOTIFY message handler
	; -------------------------------------------------------------------------------------------------------------------
	On_WM_NOTIFY(W, L) {
		Critical, % This.Critical
		If (H:=NumGet(L + 0, 0, "UPtr") = This.HWND) {
			M:=NumGet(L + (A_PtrSize * 2), 0, "Int")
			; BeginLabelEdit -------------------------------------------------------------------------------------------------
			If (M = -175) || (M = -105) ; LVN_BEGINLABELEDITW || LVN_BEGINLABELEDITA
				Return This.LVN_BEGINLABELEDIT(L)
			; EndLabelEdit ---------------------------------------------------------------------------------------------------
			If (M = -176) || (M = -106) ; LVN_ENDLABELEDITW || LVN_ENDLABELEDITA
				Return This.LVN_ENDLABELEDIT(L)
			; GETDISPINFO ----------------------------------------------------------------------------------------------------
			If (This.OWNERDATA)
			If (M = -177) || (M = -150) ; LVN_GETDISPINFOW || LVN_GETDISPINFOA
				Return This.OnGetDispInfo(L)
			; Double click ---------------------------------------------------------------------------------------------------
			If (M = -3) ; NM_DBLCLICK
				This.NM_DBLCLICK(L)
		}
	}

	; -------------------------------------------------------------------------------------------------------------------
	; LVN_BEGINLABELEDIT notification
	; -------------------------------------------------------------------------------------------------------------------
	LVN_BEGINLABELEDIT(L) {
		Static Indent:=4   ; indent of the Edit control, 4 seems to be reasonable for XP, Vista, and 7
		If (This.Item = -1) || (This.SubItem = -1)
			Return True
		H:=This.HWND
		SendMessage, 0x1018, 0, 0, , % "ahk_id " . H ; LVM_GETEDITCONTROL
		This.HEDIT:=ErrorLevel
		If (This.OWNERDATA){
			nPage := (This.Item + This.PageSize) // This.PageSize, nIndex := Mod(This.Item, This.PageSize) + 1
			This.ItemText:=ItemText:=This.List[nPage, nIndex, This.SubItem + 1]
		} Else {
			VarSetCapacity(ItemText, 2048, 0) ; text buffer
			, VarSetCapacity(LVITEM, 40 + (A_PtrSize * 5), 0) ; LVITEM structure
			, NumPut(This.Item, LVITEM, 4, "Int")
			, NumPut(This.SubItem, LVITEM, 8, "Int")
			, NumPut(&ItemText, LVITEM, 16 + A_PtrSize, "Ptr") ; pszText in LVITEM
			, NumPut(1024 + 1, LVITEM, 16 + (A_PtrSize * 2), "Int") ; cchTextMax in LVITEM
			SendMessage, % (A_IsUnicode ? 0x1073 : 0x102D), % This.Item, % &LVITEM, , % "ahk_id " . H ; LVM_GETITEMTEXT
			This.ItemText:=StrGet(&ItemText, ErrorLevel)
		}
		; Call the user function, if any
		If (This.EditUserFunc)
			This.EditUserFunc.Call("BEGIN", This.HWND, This.HEDIT, This.Item + 1, This.Subitem + 1, This.ItemText)
		SendMessage, 0x000C, 0, % &ItemText, , % "ahk_id " . This.HEDIT
		If (This.SubItem > 0) && (This.Blank) {
			Empty:=""
			, NumPut(&Empty, LVITEM, 16 + A_PtrSize, "Ptr") ; pszText in LVITEM
			, NumPut(0,LVITEM, 16 + (A_PtrSize * 2), "Int") ; cchTextMax in LVITEM
			SendMessage, % (A_IsUnicode ? 0x1074 : 0x102E), % This.Item, % &LVITEM, , % "ahk_id " . H ; LVM_SETITEMTEXT
		}
		VarSetCapacity(RECT, 16, 0)
		, NumPut(This.SubItem, RECT, 4, "Int")
		SendMessage, 0x1038, This.Item, &RECT, , % "ahk_id " . H ; LVM_GETSUBITEMRECT
		This.EX:=NumGet(RECT, 0, "Int") + Indent
		, This.EY:=NumGet(RECT, 4, "Int")
		If (This.OSVersion < 6)
			This.EY -= 1 ; subtract 1 for WinXP
		If (This.SubItem = 0) {
			SendMessage, 0x101D, 0, 0, , % "ahk_id " . H ; LVM_GETCOLUMNWIDTH
			This.EW:=ErrorLevel
		}
		Else
			This.EW:=NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
		This.EH:=NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")
		; Check the column alignement
		VarSetCapacity(LVCOL, 56, 0)
		, NumPut(1, LVCOL, "UInt") ; LVCF_FMT
		SendMessage, % (A_IsUnicode ? 0x105F : 0x1019), % This.SubItem, % &LVCOL, , % "ahk_id " . H ; LVM_GETCOLUMN
		If (NumGet(LVCOL, 4, "UInt") & 0x0002) { ; LVCFMT_CENTER
			SendMessage, % (A_IsUnicode ? 0x1057 : 0x1011), 0, % &ItemText, , % "ahk_id " . This.HWND ; LVM_GETSTRINGWIDTH
			EW:=ErrorLevel + This.DW
			If (EW < This.MinW)
				EW:=This.MinW
			If (EW < This.EW)
				This.EX += ((This.EW - EW) // 2) - Indent
		}
		; Register WM_COMMAND handler
		This.CommandFunc:=ObjBindMethod(This, "On_WM_COMMAND")
		, OnMessage(0x0111, This.CommandFunc)
		; Register hotkeys
		If !(This.Next)
			This.RegisterHotkeys()
		This.Cancelled:=False
		This.Next:=False
		Return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; LVN_ENDLABELEDIT notification
	; -------------------------------------------------------------------------------------------------------------------
	LVN_ENDLABELEDIT(L) {
		H:=This.HWND
		; Unregister WM_COMMAND handler
		OnMessage(0x0111, This.CommandFunc, 0)
		This.CommandFunc:=""
		SB_SetText("")
		; Unregister hotkeys
		If !(This.Next)
			This.RegisterHotkeys(False)
		ItemText:=This.ItemText
		If !(This.Cancelled)
			ControlGetText, ItemText, , % "ahk_id " . This.HEDIT
		If !(ItemText " " == This.ItemText " ") {
			If !(This["Changed"])
				This.Changed:=[]
			This.Changed.Insert({Row: This.Item + 1, Col: This.SubItem + 1, Txt: ItemText})
		}
		; Restore subitem's text if changed or blanked out
		If !(ItemText " " == This.ItemText " ") || ((This.SubItem > 0) && (This.Blank)) {
			VarSetCapacity(LVITEM, 40 + (A_PtrSize * 5), 0) ; LVITEM structure
			, NumPut(This.Item, LVITEM, 4, "Int")
			, NumPut(This.SubItem, LVITEM, 8, "Int")
			, NumPut(&ItemText, LVITEM, 16 + A_PtrSize, "Ptr") ; pszText in LVITEM
			SendMessage, % (A_IsUnicode ? 0x1074 : 0x102E), % This.Item, % &LVITEM, , % "ahk_id " . H ; LVM_SETITEMTEXT
		}
		If !(This.Next)
			This.Item:=This.SubItem:=-1
		This.Cancelled:=False
		This.Next:=False
		; Call the user function, if any
		If (This.EditUserFunc)
			This.EditUserFunc.Call("END", This.HWND, This.HEDIT, This.Item + 1, This.Subitem + 1, ItemText)
		Return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Virtual List
	; -------------------------------------------------------------------------------------------------------------------
	ViewSQL(SQL){
		local
		global DB
		Gui, ListView, % This.Hwnd
		GuiControl, -Redraw, % This.Hwnd
		If RegExMatch(SQL, "iO)LIMIT[ \t]+(\d+)[ \t]*((,|OFFSET)[ \t]*\d+)?;?$", Match){
			SQL:=StrReplace(SQL, Match.Value[0]), This.Begin:=RegExMatch(Match.Value[0],"i),|OFFSET")?Match.Value[1]:0
			same:=(SQL=This.SQL), This.SQL:=SQL
		} Else
			same:=(SQL=This.SQL), This.SQL:=SQL, This.Begin:=0
		This.List:="", This.Maxrowid:=0
		If !DB.GetTable(This.SQL " LIMIT " This.Begin "," This.PageSize, Result)
			OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
		If !Result.HasKey("ColumnNames")
			Result.ColumnNames:=[]
		This.List:=[Result.Rows]
		If (!same){
			LV_Delete()
			Loop, % LV_GetCount("Column")
				LV_DeleteCol(1)
			If (Result.ColumnNames.Length()=0)
				RegExMatch(This.SQL, "iO)SELECT (.+?) FROM", Match), Result.ColumnNames:=StrSplit(Match.Value[1], ",", " ")
			Loop % Result.ColumnNames.Length()
				LV_InsertCol(A_Index, "", Result.ColumnNames[A_Index])
			This.ColumnNames:=Result.ColumnNames
		}
		If (This.SQL~="i)^\s*SELECT\s+rowid")&&!(InStr(This.SQL, "WHERE")||This.SQL~="i)order\s+by\s+(?!rowid)")
			If (This.SQL~="i)order\s+by\s+rowid\s+desc"&&Result.ColumnNames[1]="rowid")
				This.Maxrowid:=Result.Rows[1, 1]?Result.Rows[1, 1]:0
			Else
				DB.GetTable(RegExReplace(This.SQL,"i)^\s*SELECT\s+.+?\s+FROM(.+)(ORDER BY.+)?$","SELECT max(rowid) FROM$1"), Result), This.Maxrowid:=Result.Rows[1, 1]?Result.Rows[1, 1]:0
		This.LVM_SETITEMCOUNT(This.Maxrowid)
		This.LVM_RedrawItems(0, -1)
		; Loop % Result.ColumnNames.Length(){
		; 	SendMessage, 0x101E, A_Index-1, -1, , % "ahk_id " . This.Hwnd
		; 	SendMessage, 0x101D, A_Index-1, 0, , % "ahk_id " . This.Hwnd
		; 	SendMessage, 0x101E, A_Index-1, Min(Max(ErrorLevel,60),450), , % "ahk_id " . This.Hwnd
		; }
		GuiControl, +Redraw, % This.Hwnd
		WinSet Redraw, , % "ahk_id" This.Hwnd
	}
	Fresh(R:=0){
		local
		global DB
		If (R){
			If DB.GetTable(This.SQL~="i)^\s*SELECT\s+[a-z,\s]+?FROM"
				? RegExReplace(This.SQL,"i)^\s*SELECT\s+.+?\s+FROM(.+)(ORDER BY.+)?$","SELECT COUNT(*) FROM$1")
				: "SELECT count(*) FROM (" This.SQL ")", Result){
				This.RowCount:=Result.Rows[1, 1], This.Maxrowid:=0
				If !(InStr(This.SQL, "WHERE")||This.SQL~="i)order\s+by\s+(?!rowid)")
					If (This.SQL~="i)order\s+by\s+rowid\s+desc"&&Result.ColumnNames[1]="rowid")
						This.Maxrowid:=Result.Rows[1, 1]
					Else
						DB.GetTable(RegExReplace(This.SQL,"i)^\s*SELECT\s+.+?\s+FROM(.+)(ORDER BY.+)?$","SELECT max(rowid) FROM$1"), Result), This.Maxrowid:=Result.Rows[1, 1]?Result.Rows[1, 1]:0	
			} Else
				This.RowCount:=This.Maxrowid:=0
			This.List:=[]
		}
		Gui ListView, % This.Hwnd
		GuiControl, -Redraw, % This.Hwnd
		This.LVM_SETITEMCOUNT()
		This.LVM_RedrawItems(0, -1)
		Loop % This.ColumnNames.Length(){
			SendMessage, 0x101E, A_Index-1, -1, , % "ahk_id " . This.Hwnd
			SendMessage, 0x101D, A_Index-1, 0, , % "ahk_id " . This.Hwnd
			SendMessage, 0x101E, A_Index-1, Min(Max(ErrorLevel,60),This.ColumnNames.Length()>4?450:800), , % "ahk_id " . This.Hwnd
		}
		GuiControl, +Redraw, % This.Hwnd
	}
	LVM_REDRAWITEMS(iFirst, iLast){
		LVM_REDRAWITEMS := (0x1000 + 21) ; LVM_FIRST + 21
		SendMessage, LVM_REDRAWITEMS, iFirst, iLast, , % "ahk_id" This.HWND
		return ErrorLevel
	}

	LVM_SETITEMCOUNT(cItems:=0){
		LVSICF_NOINVALIDATEALL := 0x00000001, LVM_SETITEMCOUNT := (0x1000 + 47) ; LVM_FIRST + 47
		cItems:=cItems?cItems:Max(This.Maxrowid, This.RowCount)
		SendMessage, LVM_SETITEMCOUNT, cItems, LVSICF_NOINVALIDATEALL, , % "ahk_id" This.HWND
		return ErrorLevel
	}
	OnGetDispInfo(pnmv){
		; Indices = -1 or VarSetCapacity(Indices, Count * 4, 0), NumPut(nIndex, Indices, nCount * 4, "UInt")
		local
		Critical 999
		static sizeofNMHDR := A_PtrSize * 3, LVIF_TEXT := 0x0001, LVIF_IMAGE := 0x0002, LVIF_STATE := 0x0008
			, hwnd, Null:="", lastpage:=0
		global DB
		iItemOffset		:= sizeofNMHDR + 4
		iItem			:= NumGet(pnmv + 0, iItemOffset, "UInt")
		hwnd			:= This.Hwnd
		if (iItem < 0 || iItem > Max(This.Maxrowid, This.RowCount)-1)
			return	; requesting invalid item
		
		maskOffset		:= sizeofNMHDR + 0
		mask			:= NumGet(pnmv + maskOffset, "UInt")
		
		if (mask & LVIF_TEXT){
			iSubItemOffset	:= sizeofNMHDR + 8
			iSubItem		:= NumGet(pnmv + iSubItemOffset, "UInt")
			
			pszTextOffset	:= sizeofNMHDR + 20 + A_PtrSize - 4
			pszText			:= NumGet(pnmv + pszTextOffset, "UInt")
			
			nPage:=(iItem+This.PageSize)//This.PageSize, nIndex := Mod(iItem, This.PageSize) + 1
			If !This.List.HasKey(nPage){
				SQL := !(This.Maxrowid&&This.ColumnNames[1]="rowid") ? This.SQL " LIMIT " (This.PageSize*(nPage-1)+This.Begin) "," This.PageSize
					: This.SQL~="i)order\s+by\s+rowid\s+desc"
						? "SELECT * FROM (" This.SQL ") WHERE rowid<=" (This.Maxrowid-(nPage-1)*This.PageSize) " LIMIT " This.PageSize
						: "SELECT * FROM (" This.SQL ") WHERE rowid>" ((nPage-1)*This.PageSize) " LIMIT " This.PageSize
				If (!(This.Maxrowid&&This.ColumnNames[1]="rowid")&&GetKeyState("LButton", "P")){
					SetTimer Redraw, -10
				} Else {
					Start:=A_TickCount, tarr:=[]
					DB.GetTable(SQL, Result)
					If (nPage>2&&This.List.HasKey(nPage-1))
						tarr[nPage-1]:=This.List[nPage-1]
					If (This.List.HasKey(nPage+1))
						tarr[nPage+1]:=This.List[nPage+1]
					tarr[1]:=This.List[1], tarr[nPage]:=Result.Rows, This.List:=""
					This.List:=tarr
					If (lastpage!=nPage)
						SB_SetText("浏览数据"), SB_SetText("加载用时：" A_TickCount-Start "ms",2), lastpage:=nPage
				}
			}
			pstrText := This.List[nPage,nIndex].GetAddress(iSubItem+1)
			If (!pstrText){
				If (iSubItem=0&&This.ColumnNames[1]="rowid")
					This.LVM_SETITEMCOUNT(iItem)
				pstrText := &Null
			}
			NumPut(pstrText, pnmv + pszTextOffset, "Ptr")
		}
		if (mask & LVIF_STATE){
			stateOffset := sizeofNMHDR + 12
			NumPut(0, pnmv + stateOffset, "UInt")
		}
		if (mask & LVIF_IMAGE){
			iImageOffset := sizeofNMHDR + 24 + A_PtrSize + A_PtrSize - 4
			NumPut(-1, pnmv + iImageOffset, "Int")
		}
		Return
		Redraw:
			If GetKeyState("LButton", "P")
				SetTimer Redraw, -10
			Else
				WinSet Redraw, , ahk_id%hwnd%
		Return
	}
	; -------------------------------------------------------------------------------------------------------------------
	; NM_DBLCLICK notification
	; -------------------------------------------------------------------------------------------------------------------
	NM_DBLCLICK(L) {
		H:=This.HWND
		This.Item:=This.SubItem:=-1
		Item:=NumGet(L + (A_PtrSize * 3), 0, "Int")
		SubItem:=NumGet(L + (A_PtrSize * 3), 4, "Int")
		nPage := (Item + This.PageSize) // This.PageSize, nIndex := Mod(Item, This.PageSize) + 1
		If (This["Columns"]) {
			If This["Columns", SubItem]
				Return False
		} Else If This.OWNERDATA&&(This.ColumnNames[SubItem+1]="rowid"||This.ColumnNames[1]!="rowid"||This.List[nPage, nIndex, 1]="")
			Return False
		If (Item >= 0) && (SubItem >= 0) {
			This.Item:=Item, This.SubItem:=SubItem
			If !(This.Next) {
				ControlGet, V, List, Count, , % "ahk_id " . H
				This.RowCount:=V - 1
				ControlGet, V, List, Count Col, , % "ahk_id " . H
				This.ColCount:=V - 1
				, NumPut(VarSetCapacity(WINDOWINFO, 60, 0), WINDOWINFO)
				, DllCall("GetWindowInfo", "Ptr", H, "Ptr", &WINDOWINFO)
				, This.DX:=NumGet(WINDOWINFO, 20, "Int") - NumGet(WINDOWINFO, 4, "Int")
				, This.DY:=NumGet(WINDOWINFO, 24, "Int") - NumGet(WINDOWINFO, 8, "Int")
				, Styles:=NumGet(WINDOWINFO, 36, "UInt")
				SendMessage, % (A_IsUnicode ? 0x1057 : 0x1011), 0, % "WWW", , % "ahk_id " . H ; LVM_GETSTRINGWIDTH
				This.MinW:=ErrorLevel
				SendMessage, % (A_IsUnicode ? 0x1057 : 0x1011), 0, % "III", , % "ahk_id " . H ; LVM_GETSTRINGWIDTH
				This.DW:=ErrorLevel
				, SBW:=0
				If (Styles & 0x200000) ; WS_VSCROLL
					SysGet, SBW, 2
				ControlGetPos, LX, LY, LW, , , % "ahk_id " . H
				This.LX:=LX
				, This.LY:=LY
				, This.LR:=LX + LW - (This.DX * 2) - SBW
				, This.LW:=LW
				, This.SW:=SBW
				, VarSetCapacity(RECT, 16, 0)
				, NumPut(SubItem, RECT, 4, "Int")
				SendMessage, 0x1038, %Item%, % &RECT, , % "ahk_id " . H ; LVM_GETSUBITEMRECT
				X:=NumGet(RECT, 0, "Int")
				If (SubItem = 0) {
					SendMessage, 0x101D, 0, 0, , % "ahk_id " . H ; LVM_GETCOLUMNWIDTH
					W:=ErrorLevel
				}
				Else
					W:=NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
				R:=LW - (This.DX * 2) - SBW
				If (X < 0)
					SendMessage, 0x1014, % X, 0, , % "ahk_id " . H ; LVM_SCROLL
				Else If ((X + W) > R)
					SendMessage, 0x1014, % (X + W - R + This.DX), 0, , % "ahk_id " . H ; LVM_SCROLL
			}
			PostMessage, % (A_IsUnicode ? 0x1076 : 0x1017), %Item%, 0, , % "ahk_id " . H ; LVM_EDITLABEL
		}
		Return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Next subItem
	; -------------------------------------------------------------------------------------------------------------------
	NextSubItem(K) {
		; Hotkeys: 0x8009 (Tab -> right), 0x8409 (Shift+Tab -> left), 0x8028  (Down -> down), 0x8026 (Up -> up)
		; Find the next subitem
		H:=This.HWND
		Item:=This.Item
		SubItem:=This.SubItem
		If (K = 0x8009) ; right
			SubItem++
		Else If (K = 0x8409) { ; left
			SubItem--
			If (SubItem = 0) && This.Skip0
				SubItem--
		}
		Else If (K = 0x8028) ; down
			Item++
		Else If (K = 0x8026) ; up
			Item--
		IF (K = 0x8409) || (K = 0x8009) { ; left || right
			If (This["Columns"]) {
				If (SubItem < This.Columns.MinIndex())
					SubItem:=This.Columns.MaxIndex(), Item--
				Else If (SubItem > This.Columns.MaxIndex())
					SubItem:=This.Columns.MinIndex(), Item++
				Else {
					While (This.Columns[SubItem] = "") {
						If (K = 0x8009) ; right
							SubItem++
						Else
							SubItem--
					}
				}
			}
		}
		If (SubItem > This.ColCount)
			Item++, SubItem:=This.Skip0 ? 1 : 0
		Else If (SubItem < 0)
			SubItem:=This.ColCount, Item--
		If (Item > This.RowCount)
			Item:=0
		Else If (Item < 0)
			Item:=This.RowCount
		If (Item <> This.Item)
			SendMessage, 0x1013, % Item, False, , % "ahk_id " . H ; LVM_ENSUREVISIBLE
		VarSetCapacity(RECT, 16, 0), NumPut(SubItem, RECT, 4, "Int")
		SendMessage, 0x1038, % Item, % &RECT, , % "ahk_id " . H ; LVM_GETSUBITEMRECT
		X:=NumGet(RECT, 0, "Int"), Y:=NumGet(RECT, 4, "Int")
		If (SubItem = 0) {
			SendMessage, 0x101D, 0, 0, , % "ahk_id " . H ; LVM_GETCOLUMNWIDTH
			W:=ErrorLevel
		}
		Else
			W:=NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
		R:=This.LW - (This.DX * 2) - This.SW, S:=0
		If (X < 0)
			S:=X
		Else If ((X + W) > R)
			S:=X + W - R + This.DX
		If (S)
			SendMessage, 0x1014, % S, 0, , % "ahk_id " . H ; LVM_SCROLL
		Point:=(X - S + (This.DX * 2)) + ((Y + (This.DY * 2)) << 16)
		SendMessage, 0x0201, 0, % Point, , % "ahk_id " . H ; WM_LBUTTONDOWN
		SendMessage, 0x0202, 0, % Point, , % "ahk_id " . H ; WM_LBUTTONUP
		SendMessage, 0x0203, 0, % Point, , % "ahk_id " . H ; WM_LBUTTONDBLCLK
		SendMessage, 0x0202, 0, % Point, , % "ahk_id " . H ; WM_LBUTTONUP
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Register/UnRegister hotkeys
	; -------------------------------------------------------------------------------------------------------------------
	RegisterHotkeys(Register = True) {
		; WM_HOTKEY:=0x0312, MOD_SHIFT:=0x0004
		; Hotkeys: 0x801B  (Esc -> cancel, 0x8009 (Tab -> right), 0x8409 (Shift+Tab -> left)
		;          0x8028  (Down -> down), 0x8026 (Up -> up)
		H:=This.HWND
		If (Register) { ; Register
			DllCall("RegisterHotKey", "Ptr", H, "Int", 0x801B, "UInt", 0, "UInt", 0x1B)
			, DllCall("RegisterHotKey", "Ptr", H, "Int", 0x8009, "UInt", 0, "UInt", 0x09)
			, DllCall("RegisterHotKey", "Ptr", H, "Int", 0x8409, "UInt", 4, "UInt", 0x09)
			, DllCall("RegisterHotKey", "Ptr", H, "Int", 0x8028, "UInt", 0, "UInt", 0x28)
			, DllCall("RegisterHotKey", "Ptr", H, "Int", 0x8026, "UInt", 0, "UInt", 0x26)
			, This.HotkeyFunc:=ObjBindMethod(This, "On_WM_HOTKEY")
			, OnMessage(0x0312, This.HotkeyFunc) ; WM_HOTKEY
		}
		Else { ; Unregister
			DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x801B)
			, DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x8009)
			, DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x8409)
			, DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x8028)
			, DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x8026)
			, OnMessage(0x0312, This.HotkeyFunc, 0) ; WM_HOTKEY
			, This.HotkeyFunc:=""
		}
	}
}
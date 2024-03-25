; ##################################################################################################################################################################
; # 声明：此文件基于开源仓库 <https://gitee.com/orz707/Yzime> (Commit:d1d0d9b15062de7381d1e7649693930c34fca53d) 
; # 中的同名文件修改而来，并使用相同的开源许可 GPL-2.0 进行开源，具体的权利、义务和免责条款可查看根目录下的 LICENSE 文件
; # 修改者：北山愚夫
; # 修改时间：2024年3月15日 
; ##################################################################################################################################################################

; 纠错插入修改
insertchar(str,char,ByRef pos){
	global IsPinyin
	If (!pos)
		Return str . char
	Else
		Return SubStr(str,1,pos-1+IsPinyin) char SubStr(str,pos+IsPinyin), pos+=1
}
delchar(str,ByRef pos, del:=0){
	global IsPinyin
	If (del){
		If (pos>0)
			Return SubStr(str,1,pos-1+IsPinyin) SubStr(str,pos+1+IsPinyin)
		Else
			Return str
	} Else If (pos)
		Return SubStr(str,1,Max(0,pos-2+IsPinyin)) SubStr(str,pos+IsPinyin), pos:=Max(pos-1,1)
	Else
		Return SubStr(str,1,-1)
}
insertcaret(str,pos){
	local
	global func_key, srf_all_Input
	res:=pos=1?"|":"",index:=0
	Loop, Parse, str
	{
		t:=SubStr(srf_all_Input,index+1,1), t:=t="\"?" ":t
		If !(A_LoopField~="i)[a-z]")&&(t!=A_LoopField){
			res .= A_LoopField
			Continue
		}
		index++, res .= A_LoopField (index=pos-1?"|":"")
	}
	Return res
}
; 上屏合一
select_for_num(num){
	global
	local Match, tarr, ThisHotkey
	If InStr(srf_all_Input,func_key){
		If (srf_func_table[modeMatch.Value[1], "Name"]="get_hotstring")||(srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-zA-Z]+$"){
			srf_HotStringSelect(Function_for_select, num)
		} Else If !(A_ThisHotkey~="\d")||(srf_func_table[modeMatch.Value[1], "Name"]="get_function")||!(modeMatch.Value[1]=""||srf_Default_Func[srf_func_table[modeMatch.Value[1], "Name"],2]~="\d"){
			srf_RunSelect(Function_for_select, num)
		} Else {
			If (num=".")&&(InStr(srf_all_Input, ".")||srf_all_Input=func_key)
				Return
			If GetKeyState("Shift", "P")
				tarr:=["!","@","#","$","%","^","&","*","("], tarr[0]:=")", srf_all_Input:=insertchar(srf_all_Input,tarr[num],insertpos)
			Else
				srf_all_Input:=insertchar(srf_all_Input,num,insertpos)
			Gosub srf_tooltip
		}
	} Else If (srf_all_Input=eng_key&&GetKeyState("Shift", "P")){
		SendInput % "{Text}" StrSplit(")!@#$%^&*(")[num+1]
		Gosub srf_value_off
	} Else If (srf_symbol[srf_all_Input]){
		If (jichu_for_select_Array[num,2]="")
			Return
		RegExMatch(jichu_for_select_Array[num,2],"i)\{[a-z]+\}",Match)
		SendInput(StrReplace(jichu_for_select_Array[num,2],Match), SendDelaymode)
		If (Match)
			SendInput, %Match%
		Gosub srf_value_off
	} Else If GetKeyState("Shift", "P"){
		ThisHotkey:=LTrim(A_ThisHotkey,"~")
		If (ThisHotkey~="^[14690]$"){
			srf_select(1,IsPinyin), tarr:={0:")",1:"!",4:"$",6:"^",9:"("}
			RegExMatch(srf_symbol[tarr[ThisHotkey],(srf_mode&&!(EnSymbol||Englishmode)&&!GetKeyState("CapsLock", "T"))+1],"i)\{[a-z]+\}",Match)
			SendInput(StrReplace(srf_symbol[tarr[ThisHotkey],(srf_mode&&!(EnSymbol||Englishmode)&&!GetKeyState("CapsLock", "T"))+1],Match), SendDelaymode)
			If (Match)
				SendInput, %Match%
		} Else If (ThisHotkey~="^\d$"){
			tarr:={0:")",1:"!",4:"$",6:"^",9:"("}
		} Else
			srf_select(num,IsPinyin)
	} Else
		srf_select(num,IsPinyin)
}
; 输入上屏
srf_select(list_num:=1,mode:=0,key:="",ret:=0){
	global
	local selectvalue, _SQL, Result, index, yhnum, tt, Match, srf_all_Input2, bianma, TableName, weight
	list_num:=list_num?list_num:10, Showdwxgtip:=0
	If (key){
		selectvalue:=[]
		RegExMatch(jichu_for_select_Array[1,1] "'","iO)([a-z]+'){" list_num "}", Match)
		selectvalue[1]:=Trim(Match.Value[0],"'"), selectvalue[0]:="pinyin"
		RegExMatch(srf_all_Input_["tip"] "'","iO)([a-z]+'){" list_num "}", Match)
		selectvalue[-1]:=Trim(Match.Value[0],"'")
		If (selectvalue[1]){
			selectvalue[2]:=SubStr(jichu_for_select_Array[1,2],1,list_num)
			SendInput(SubStr(jichu_for_select_Array[1,valueindex],1,list_num), SendDelaymode), hasCaretPos:=Caret.t="TSF"
			Function_for_select:=[], hotstring_for_select:=[], jichu_for_select_Array:=[], save_field_array:=[]
			Goto dwcz
		} Else
			list_num:=1
	}
	If (list_num>Max(ListNum,srf_for_select_obj.Length())||list_num=0)
		Return
	selectvalue:=jichu_for_select_Array[list_num+ListNum*waitnum], tt:=StrSplit(selectvalue[0],"|")
	If (Trim(selectvalue[2])!="")
		SendInput(selectvalue[valueindex], tt[3]?tt[3]:SendDelaymode), hasCaretPos:=Caret.t="TSF"
	Else {
		hasCaretPos:=Caret.t="TSF"
		Gosub srf_value_off
		Return
	}
	If ((Wordfrequency&&!mode)&&selectvalue[3]>0){
		TableName:=(shurulei="pinyin"?"pinyin":Inputscheme)
		If !(fixedword&&(selectvalue[2]~="^.$")){
			_SQL:="", bianma:=StrReplace(selectvalue[1], "'", "''"), value := StrReplace(selectvalue[2], "'", "''")
			If (srf_last_input[2, 2]=selectvalue[2]){
				_SQL .= "UPDATE 'main'.'pinyin' SET weight = "
				If (TableName="pinyin")
					_SQL := "UPDATE 'main'.'pinyin' SET weight = 1 + (SELECT max(weight) FROM 'main'.'pinyin' WHERE jp = '" (jp := RegExReplace(bianma,"([a-z])[a-z]*","$1")) "') WHERE jp = '" jp "' AND key = '" bianma "' AND value = '" value "';"
				Else
					_SQL := "UPDATE 'main'.'" TableName "' SET weight = 1 + (SELECT max(weight) FROM 'main'.'" TableName "' WHERE key = '" bianma "') WHERE key = '" bianma "' AND value = '" value "';"
			} Else If (tt[2]>1){
				If (weight:=Tofirst?Round(selectvalue[4]+1):Round(selectvalue[3]+1+(selectvalue[4]-selectvalue[3])/(tt[2]<5?Max(tt[2]-1,1):(2*tt[2]-6)/(tt[2]-4))))
					_SQL .= "UPDATE 'main'.'" TableName "' SET weight = " weight " WHERE " (TableName="pinyin"?"jp='" RegExReplace(bianma,"([a-z])[a-z]*","$1") "' AND":"") " key = '" bianma "' AND value = '" value "';"
			} Else If (tt[2]=1)&&(weight:=selectvalue[4]+1)
				_SQL .= "UPDATE 'main'.'" TableName "' SET weight = weight+1 WHERE " (TableName="pinyin"?"jp='" RegExReplace(bianma,"([a-z])[a-z]*","$1") "' AND":"") " key = '" bianma "' AND value = '" value "';"
			If (decfre&&TableName="pinyin"&&weight&&selectvalue[2]~="..+?")
				_SQL := RegExReplace(SQL_buffer[selectvalue[-1]], "SELECT .+(WHERE .+?)(ORDER .+)?$", "UPDATE 'main'.'pinyin' SET weight = weight-5 $1 AND value != '" value "';`n") _SQL
			If (Learning*(Learnfg+1)>1)
				SQL_BUF_FRE += _SQL "`n"
			Else If (_SQL!=""){
				tt:=ObjBindMethod(DB, "Exec", _SQL)
				SetTimer % tt, -100
			}
		}
	}
	dwcz:
	srf_last_input[1, 2] .= selectvalue[2], srf_last_input[1, 1] .= (srf_last_input[1, 1]?"'":"") selectvalue[1]
	, srf_last_input[1, 0] .= (srf_last_input[1, 0]?"'":"") selectvalue[-1], Learnfg+=Learning
	If (selectvalue[1]="")||(tt[1]="customs"){
		If (selectvalue[1]="")
			Learnfg:=0, srf_last_input[1, 1]:=RTrim(srf_last_input[1, 1],"'")
		Gosub srf_value_off
		Return
	} Else If (Inputscheme~="sp$|pinyin"){
		If (SaveCloud)&&(selectvalue[0]="<Cloud>|-1")&&(StrLen(selectvalue[2])<11)
			DB.Exec("INSERT INTO 'main'.'pinyin' VALUES (""" RegExReplace(selectvalue[1],"([a-z])[a-z]*","$1") """,""" selectvalue[1] """,'" selectvalue[2] "'," ("ifnull((SELECT max(weight)+1 FROM 'pinyin' WHERE jp=""" RegExReplace(selectvalue[1],"([a-z])[a-z]*","$1") """ AND key=""" selectvalue[1] """),5000));"))
			; DB.Exec("INSERT INTO 'main'.'pinyin' VALUES (""" RegExReplace(selectvalue[1],"([a-z])[a-z]*","$1") """,""" selectvalue[1] """,'" selectvalue[2] "'," (SQL_buffer[selectvalue[-1]]?"ifnull((SELECT max(weight)+1 FROM 'pinyin' " RegExReplace(SQL_buffer[selectvalue[-1]], "^.+?(WHERE jp=.+)(ORDER BY|UNION ALL).+", "$1") "),5000));":"5000);"))
		If (selectvalue[-1]){
			RegExMatch(srf_all_Input, "iO)" StrReplace(selectvalue[-1] "'", "'", "'?"), Match)
			srf_all_Input:=Trim(SubStr(srf_all_Input, Match.Pos[0]+Match.Len[0]), "'\")
			If (tfzm=""&&selectvalue[-2]!="")
				srf_all_Input:=RegExReplace(srf_all_Input, "i)" selectvalue[-2] " ?$")
			If Trim(srf_all_Input,"'\"){
				jichu_for_select:=srf_all_Input_["tip"]:=ToolTipText:=tfzm:="", save_field_array.RemoveAt(1)
				Function_for_select:=[], hotstring_for_select:=[], jichu_for_select_Array:=[]
				waitnum:=0, hasCaretPos:=Caret.t="TSF", localpos:=1
				Gosub srf_tooltip
				Return
			}
		}
	} Else If (mode){
		If (selectvalue[-1]){
			RegExMatch(srf_all_Input, "iO)" StrReplace(selectvalue[-1] "'", "'", "'?"), Match)
			If (srf_all_Input:=Trim(SubStr(srf_all_Input, Match.Pos[0]+Match.Len[0]), "'\")){
				jichu_for_select:=srf_all_Input_["tip"]:=ToolTipText:=tfzm:="", srf_all_Input:=(mode=1?lspy_key:"") srf_all_Input
				save_field_array.RemoveAt(1)
				hasCaretPos:=waitnum:=0, Function_for_select:=[], hotstring_for_select:=[], jichu_for_select_Array:=[]
				Gosub srf_tooltip
				Return
			}
		}
	} Else {
		If InStr(srf_all_Input,"``"){
			If (srf_all_Input:=RegExReplace(srf_all_Input,"^``?[a-z]+``?")){
				srf_all_Input:="``" srf_all_Input
				Gosub srf_tooltip
				Return
			}
			Gosub srf_value_off
		}
		If (selectvalue[-2]!="")
			srf_all_Input:=RegExReplace(srf_all_Input, "i)" selectvalue[-2] " ?$")
		If (srf_all_Input~="^" selectvalue[1])&&(srf_all_Input:=RegExReplace(srf_all_Input, "^" selectvalue[1])){
			hasCaretPos:=waitnum:=0, Function_for_select:=[], hotstring_for_select:=[], jichu_for_select_Array:=[]
			Gosub srf_tooltip
			Return
		}
	}
	If ret
		Return
	Gosub srf_value_off
}

; 输入法快捷键调位置
srf_SetFirst(list_num, m:=0){
	global
	local selectvalue, _SQL, index, tt, presstime:=A_TickCount, pos:=1, tarr, tpos, yhnum, tstr, maxweight, Match, Result
	list_num:=list_num?list_num:10
	selectvalue:=jichu_for_select_Array[index:=list_num+ListNum*waitnum]
	If (list_num>ListNum)||((tt:=StrSplit(selectvalue[0],"|"))[2]<1)||(selectvalue[2]="")||(tt[1]~="^(hotstrings|functions|English|symbol|<Cloud>|)$")
		Return
	If (m=0){
		KeyWait, % Mod(list_num, 10), T0.3
		If (A_TickCount-presstime>290)||(tt[1]="customs"){
			Suspend, On
			Gui +OwnDialogs
			OnMessage(0x18, "SetWindowsAlwaysOnTop")
			If (tt[1]="customs")
				InputBox, pos, 输入调整后的位置, % "词条固定在第" selectvalue[3] "位`n输入整数调整至指定位置", , 2*A_ScreenDPI, 1.4*A_ScreenDPI
			Else If (tt[1]="pinyin"&&selectvalue[-2])
				InputBox, pos, 在自定义短语中新建词条, % "词条在" tt[1] " 第" tt[2] "位`n输入整数固定在指定位置", , 2*A_ScreenDPI, 1.4*A_ScreenDPI
			Else
				InputBox, pos, 输入调整后的位置, % "词条在" tt[1] " 第" tt[2] "位`n输入整数调整至指定位置", , 2*A_ScreenDPI, 1.4*A_ScreenDPI
			Suspend, Off
			If (ErrorLevel)
				Return
			If (pos~="^\d{1,3}$")&&(selectvalue[-1]){
				If (tt[1]="customs"){
					DB.GetTable("SELECT key FROM 'extend'.'customs' WHERE key='" selectvalue[-1] "' AND comment+0=" pos " LIMIT 1",Result)
					If (Result.Rows[1,1]){
						If (pos>selectvalue[3])
							DB.Exec("UPDATE 'extend'.'customs' SET comment=(comment-1)||regexpr(comment,'^\d+','') WHERE key='" selectvalue[-1] "' AND comment+0>=" selectvalue[3] " AND comment+0<" (pos+1))
						Else If (pos<selectvalue[3])
							DB.Exec("UPDATE 'extend'.'customs' SET comment=(comment+1)||regexpr(comment,'^\d+','') WHERE key='" selectvalue[-1] "' AND comment+0<" (selectvalue[3]+1) " AND comment+0>=" pos)
					}
					; DB.Exec("UPDATE 'extend'.'customs' SET comment='" (Format("{:03}", pos) StrSplit(selectvalue[0], "|")[3]) "' WHERE key='" selectvalue[-1] "' AND value='" StrReplace(selectvalue[1],"'","''") "'")
					DB.Exec("UPDATE 'extend'.'customs' SET comment='" (pos RegExReplace(selectvalue[4],"^\d+")) "' WHERE key='" selectvalue[-1] "' AND value='" StrReplace(selectvalue[1],"'","''") "'")
					srf_all_Input_["history"]:=""
					Gosub srf_tooltip
					Return
				} Else If selectvalue[-2]&&(tt[1]="pinyin"){
					tpos:=RegExMatch(srf_all_Input_["tip"], selectvalue[-1])
					StrReplace(SubStr(srf_all_Input_["tip"],1,tpos-1),"'", , yhnum)
					tpos:=InStr(srf_all_Input_["tip"], "'", , 1, yhnum+1)
					tstr:=StrReplace(SubStr(srf_all_Input_["tip"],tpos+1,InStr(srf_all_Input_["tip"], "'", , 1, yhnum+1+StrSplit(selectvalue[-1], "'").Length())-tpos-1),"'") selectvalue[-2]
					If DB.GetTable("SELECT comment FROM 'extend'.'customs' WHERE key='" tstr "' AND value='" StrReplace(selectvalue[2],"'","''") "' LIMIT 1",Result){
						If (Result.Rows[1,1]){
							RegExMatch(Result.Rows[1,1], "O)(\d+)(\{.*\})?",Match)
							DB.GetTable("SELECT key FROM 'extend'.'customs' WHERE key='" tstr "' AND comment LIKE '" Format("{:03}", pos) "%' LIMIT 1",Result)
							If (Result.Rows[1,1]){
								If (pos>Match.Value[1])
									DB.Exec("UPDATE 'extend'.'customs' SET comment=substr('00'||(substr(comment,1,3)-1),-3)||substr(comment,4) WHERE key='" tstr "' AND comment>='" Format("{:03}", Match.Value[1]) "' AND comment<'" Format("{:03}", pos+1) "'")
								Else If (pos<Match.Value[1])
									DB.Exec("UPDATE 'extend'.'customs' SET comment=substr('00'||(substr(comment,1,3)+1),-3)||substr(comment,4) WHERE key='" tstr "' AND comment<'" Format("{:03}", Match.Value[1]+1) "' AND comment>='" Format("{:03}", pos) "'")
							}
							DB.Exec("UPDATE 'extend'.'customs' SET comment='" (Format("{:03}", pos) Match.Value[2]) "' WHERE key='" tstr "' AND value='" StrReplace(selectvalue[2],"'","''") "'")
						} Else {
							DB.GetTable("SELECT key FROM 'extend'.'customs' WHERE key='" tstr "' AND comment LIKE '" Format("{:03}", pos) "%' LIMIT 1",Result)
							If (Result.Rows[1,1])
								DB.Exec("UPDATE 'extend'.'customs' SET comment=substr('00'||(substr(comment,1,3)+1),-3)||substr(comment,4) WHERE key='" tstr "' AND comment>=""" Format("{:03}", pos) """")
							DB.Exec("INSERT INTO 'extend'.'customs' VALUES('" tstr "','" selectvalue[2] "','" Format("{:03}", pos) "')")
						}
						srf_all_Input_["history"]:=""
						Gosub srf_tooltip
					}
					If (DB.ErrorCode)
						OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
					Return
				}
				pos:=pos?pos:1
			} Else
				Return
		}
	} Else {
		pos:=tt[2]+m
		If (pos=0||(m=1&&pos>StrSplit(jichu_for_select_Array[list_num+ListNum*waitnum+1, 0], "|")[2]))
			Return
	}
	If (pos=tt[2])
		Return
	Else {
		If (pos=1){
			DB.Exec("UPDATE 'main'.'" tt[1] "' SET weight=" selectvalue[4]+1 " WHERE " (tt[1]="pinyin"?"jp=""" RegExReplace(selectvalue[1],"([a-z])[a-z]*","$1") """ AND ":"") "key='" StrReplace(selectvalue[1],"'","''") "' AND value=""" selectvalue[2] """")
		} Else If (pos>=2){
			_SQL:=RegExReplace(SQL_buffer[selectvalue[-1]], "i)ORDER BY.+", "ORDER BY weight DESC"), pos+=(pos>tt[2]?1:0)
			DB.GetTable(RegExReplace(_SQL,"i)^SELECT (.+) FROM","SELECT weight FROM") " LIMIT " (pos-2) ",2",Result)
			If (Result.RowCount=2){
				If (Result.Rows[1,1]-Result.Rows[2,1]<2)
					DB.Exec("UPDATE 'main'.'" tt[1] "' SET weight=weight+" (2+Result.Rows[2,1]-Result.Rows[1,1]) " WHERE ROWID IN (" RegExReplace(_SQL,"i)^SELECT (.+) FROM","SELECT ROWID FROM") " LIMIT " (pos-1) ")")
				DB.Exec("UPDATE 'main'.'" tt[1] "' SET weight=" Result.Rows[2,1]+1 " WHERE " (tt[1]="pinyin"?"jp=""" RegExReplace(selectvalue[1],"([a-z])[a-z]*","$1") """ AND ":"") "key='" StrReplace(selectvalue[1],"'","''") "' AND value=""" selectvalue[2] """")
			} Else If (Result.RowCount=1){
				DB.Exec("UPDATE 'main'.'" tt[1] "' SET weight=weight+1 WHERE ROWID IN (" RegExReplace(_SQL,"i)^SELECT (.+) FROM","SELECT ROWID FROM") " LIMIT " (pos-1) ")")
				DB.Exec("UPDATE 'main'.'" tt[1] "' SET weight=" Result.Rows[1,1] " WHERE " (tt[1]="pinyin"?"jp=""" RegExReplace(selectvalue[1],"([a-z])[a-z]*","$1") """ AND ":"") "key='" StrReplace(selectvalue[1],"'","''") "' AND value=""" selectvalue[2] """")
			} Else {
				DB.GetTable(RegExReplace(_SQL,"i)^SELECT (.+) FROM","SELECT min(weight) FROM"),Result)
				If (Result.Rows[1,1]!="")&&(Result.Rows[1,1]<2)
					DB.Exec("UPDATE 'main'.'" tt[1] "' SET weight=weight+" (2-Result.Rows[1,1]) " WHERE ROWID IN (" RegExReplace(_SQL,"i)^SELECT (.+) FROM","SELECT ROWID FROM") " LIMIT " (pos-1) ")")
				DB.Exec("UPDATE 'main'.'" tt[1] "' SET weight=1 WHERE " (tt[1]="pinyin"?"jp=""" RegExReplace(selectvalue[1],"([a-z])[a-z]*","$1") """ AND ":"") "key='" StrReplace(selectvalue[1],"'","''") "' AND value=""" selectvalue[2] """")
			}
		}
		If (DB.ErrorCode)
			OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
		Else {
			localpos+=m
			If (localpos=0)
				localpos:=ListNum, waitnum--
			Else If (localpos>ListNum)
				localpos:=1, waitnum++
			srf_all_Input_["history"]:="", history_field_array.Delete(selectvalue[-1]), save_field_array.RemoveAt(1), jichu_for_select_Array:=[]
			Gosub srf_tooltip
		}
	}
}

; 输入法快捷键删词
srf_delete(list_num){
	global
	local selectvalue, tt, _SQL
	list_num:=list_num?list_num:10
	selectvalue:=jichu_for_select_Array[list_num+ListNum*waitnum]
	If (list_num>ListNum)||((tt:=StrSplit(selectvalue[0],"|"))[2]<0&&tt[1]!="customs")||(selectvalue[2]="")
		Return
	If (tt[1]="pinyin")
		_SQL:="DELETE FROM 'main'.'pinyin' WHERE jp=""" RegExReplace(selectvalue[1],"([a-z])[a-z]*","$1") """ AND key='" StrReplace(selectvalue[1],"'","''") "' AND value='" StrReplace(selectvalue[2],"'","''") "';"
	Else If (tt[1]="customs")
		_SQL:="DELETE FROM 'extend'.'customs' WHERE key='" selectvalue[-1] "' AND value='" StrReplace(selectvalue[1],"'","''") "';"
	Else
		_SQL:="DELETE FROM 'main'.'" tt[1] "' WHERE key='" selectvalue[1] "' AND value='" StrReplace(selectvalue[2],"'","''") "';"
	If DB.Exec(_SQL){
		jichu_for_select_Array.RemoveAt(list_num+ListNum*waitnum)
		If (ListNum*waitnum+1>jichu_for_select_Array.Length())&&(waitnum>0)
			waitnum-=1
		Gosub srf_tooltip_fanye
	} Else
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
}
customs_alterpos(DB,key,value,pos,alterpos,bz:=""){
	local Result
	DB.GetTable("SELECT key FROM 'extend'.'customs' WHERE key='" key "' AND comment LIKE """ Format("{:03}", alterpos) "%"" LIMIT 1",Result)
	If (Result.Rows[1,1]){
		If (alterpos>pos)
			DB.Exec("UPDATE 'extend'.'customs' SET comment=substr('00'||(substr(comment,1,3)-1),-3)||substr(comment,4) WHERE key='" key "' AND comment>='" Format("{:03}", pos) "' AND comment<'" Format("{:03}", alterpos+1) "'")
		Else If (alterpos<pos)
			DB.Exec("UPDATE 'extend'.'customs' SET comment=substr('00'||(substr(comment,1,3)+1),-3)||substr(comment,4) WHERE key='" key "' AND comment<'" Format("{:03}", pos+1) "' AND comment>='" Format("{:03}", alterpos) "'")
	}
	If !DB.Exec("UPDATE 'extend'.'customs' SET comment='" (Format("{:03}", alterpos) bz "' WHERE key='" key "' AND value='" StrReplace(value,"'","''") "'"))
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
}
; 输入法快捷键造词
srf_create(key:=""){
	local
	global YzimePID, Inputscheme, GUIFont, srf_Plugins, main, extend
	static dy:=0, tkey:="", buffer, lxzc:=0, hedit, last
	If WinExist("快捷造词 Enter确定 Esc退出 ahk_pid" YzimePID){
		WinActivate, 快捷造词 Enter确定 Esc退出 ahk_pid%YzimePID%
		Return
	}
	dy:=key?1:dy, tkey:=key
	Gosub srf_value_off
	Gui, create:-MinimizeBox
	Gui, create:Margin, 15, 15
	Gui, create:Font, s12, %GUIFont%
	Gui, create:Add, Text, , 词条：
	Try
		Gui, create:Add, Edit, x+0 yp w400 -Multi r1 ggetkey, % Trim(Clipboard)?Clipboard:Last_input()?Last_input():""
	Catch
		Gui, create:Add, Edit, x+0 yp w400 -Multi r1 ggetkey, % Last_input()?Last_input():""
	Gui, create:Add, Text, xm, 编码：
	Gui, create:Add, Edit, x+0 yp w400 -Multi r1 gsetkey Hwndhedit, %key%
	Gui, create:Add, Text, xm, 位置：
	Gui, create:Add, Edit, x+0 yp w60 Limit2 Number
	Gui, create:Add, UpDown, Range0-99, 1
	Gui, create:Add, Checkbox, x+30 yp gzdydy Center Checked%dy%, 自定义短语`n(固定位置)
	Gui, create:Add, DropDownList, % "x+20 yp w80 AltSubmit Hidden" !dy, 文本||按键|函数
	Gui, create:Add, Checkbox, x+20 yp Checked%lxzc%, 继续造词
	Gui, create:Show, , 快捷造词 Enter确定 Esc退出
	DllCall("ChangeWindowMessageFilterEx", "Ptr", hedit, "UInt", 0x0C, "UInt", 1, "Ptr", 0)
	Gosub getkey
	Hotkey, IfWinActive, 快捷造词 Enter确定 Esc退出 ahk_pid%YzimePID%
	Hotkey, Enter, createButton确定
	Hotkey, NumpadEnter, createButton确定
	Hotkey, If
	Return
	zdydy:
		GuiControlGet, dy, , Button1
		If (dy)
			GuiControl, Show, ComboBox1
		Else {
			GuiControl, Hide, ComboBox1
			Gosub getkey
		}
	Return
	getkey:
		Gui, create:Default
		GuiControlGet, buffer, , Edit1
		If (A_GuiControl=buffer)
			SetTimer, getkey_, -20
		Else
			Gosub getkey_
	Return
	getkey_:
		Critical, Off
		global srf_Plugins
		Gui, create:Default
		GuiControlGet, dy, , Button1
		If (tkey=""&&!dy){
			If (Inputscheme~="(五笔|wubi)")&&RegExMatch(Inputscheme,"(86|98)",Match)
				cikuname:="wubi" Match
			Else
				cikuname:=(Inputscheme~="pinyin|sp$"?"pinyin":Inputscheme)
			If (cikuname){
				GuiControl, -g, Edit2
				If (!srf_Plugins["cikuManager",1]){
					If (srf_Plugins["cikuManager",1]!=0){
						If FileExist("词库管理.exe"){
							Run % "词库管理.exe -h -o" main (main!=extend ? ";" extend : ""), %A_ScriptDir%, Min, tvar
							srf_Plugins["cikuManager", 1]:=tvar
							WinWait, ahk_pid%tvar%, , 1
							Goto _Send_Msg
						}
					}
					srf_Plugins["cikuManager",1]:=0
				} Else {
					Process, Exist, % srf_Plugins["cikuManager", 1]
					If (!ErrorLevel){
						last:=""
						Run % "词库管理.exe -h -o" main (main!=extend ? ";" extend : ""), %A_ScriptDir%, Min, tvar
						srf_Plugins["cikuManager", 1]:=tvar
						WinWait, ahk_pid%tvar%, , 1
					}
					Goto _Send_Msg
				}
				; bm:=""
				; Try bm:=StrReplace(RegExReplace(StrSplit(IMEConverter(cikuname,buffer),"`t","'")[1],"[^a-z']"),"''","'")
				; If (bm)
				; 	GuiControl, , Edit2, % bm
			}
		}
	Return
	_Send_Msg:
		If (last!=cikuname){
			last:=cikuname
			While (Send_WM_COPYDATA(cikuname, "词库管理 ahk_class Yzime ahk_pid" srf_Plugins["cikuManager", 1], 3)!=1){
				Sleep 100
				If (A_Index>5){
					last:=""
					Return
				}
			}
		}
		WinActivate 快捷造词 Enter确定 Esc退出 ahk_pid%YzimePID%
		Send_WM_COPYDATA(buffer, "词库管理 ahk_class Yzime ahk_pid" srf_Plugins["cikuManager", 1], 0, hedit)
		GuiControl, +gsetkey, Edit2
	Return
	setkey:
		tkey:=A_GuiControl
		Gosub getkey_
	Return
	createButton确定:
	Gui, create:Default
	Gui create:+OwnDialogs
	GuiControlGet, value, , Edit1
	GuiControlGet, key, , Edit2
	GuiControlGet, pos, , Edit3
	GuiControlGet, dy, , Button1
	GuiControlGet, ty, , ComboBox1
	GuiControlGet, lxzc, , Button2
	cikuname:=(dy?"customs":(Inputscheme~="pinyin|sp$"?"pinyin":Inputscheme))
	value:=Trim(RegExReplace(value, "(`r|`n)")," "), key:=Trim(dy||cikuname!="pinyin"?StrReplace(key,"'"):key)
	If (value=""){
		GuiControl, Focus, Edit1
		ToolTip 未输入词条！
		SetTimer, ToolTipOff, -1000
		Return
	} Else If (key=""){
		GuiControl, Focus, Edit2
		ToolTip 未输入编码！
		SetTimer, ToolTipOff, -1000
		Return
	} Else If (pos=""){
		GuiControl, Focus, Edit3
		ToolTip 未指定位置！
		SetTimer, ToolTipOff, -1000
		Return
	}
	pos:=(dy?pos (ty=2?"{}":ty=3?"{Func}":""):pos)
	srf_create_(cikuname,key,value,pos)
	If (lxzc){
		GuiControl, , Edit1
		GuiControl, , Edit2
		GuiControl, Focus, Edit1
	} Else
		Gosub createGuiClose
	Return
	createGuiEscape:
	createGuiClose:
	DllCall("ChangeWindowMessageFilterEx", "Ptr", hedit, "UInt", 0x0C, "UInt", 0, "Ptr", 0)
	Gui, create:Destroy
	Return
}
srf_create_(cikuname,key,value,pos){
	local
	global Inputscheme, DB
	If (key=""||value=""||cikuname=""||pos="")
		Return
	Else {
		If (cikuname="customs"){
			DB.Exec("DELETE FROM " (cikuname="customs"?"'extend'.":"'main'.") "'" cikuname "' WHERE " (cikuname="pinyin"?"jp=""" RegExReplace(key, "([a-z])[a-z]*", "$1") """ AND ":"") "key='" StrReplace(key,"'","''") "' AND value='" StrReplace(value,"'","''") "'")
			If (DB.ErrorCode = 1){
				DB.Exec("CREATE TABLE 'extend'.'customs' (""key"" TEXT NOT NULL DEFAULT '',""value"" TEXT NOT NULL DEFAULT '',""comment"" TEXT NOT NULL DEFAULT '');")
				DB.Exec("CREATE INDEX 'extend'.'sy_customs' ON ""customs"" (""key"");")
			}
			RegExMatch(pos,"\{.*\}", Match), pos:=StrReplace(pos, Match)
			DB.GetTable("SELECT key FROM 'extend'.'customs' WHERE key='" key "' AND comment LIKE '" Format("{:03}", pos) "%' LIMIT 1",Result)
			If (Result.Rows[1,1])
				DB.Exec("UPDATE 'extend'.'customs' SET comment=substr('00'||(substr(comment,1,3)+1),-3)||substr(comment,4) WHERE key='" key "' AND comment>='" Format("{:03}", pos) "'")
			If DB.Exec("INSERT INTO 'extend'.'customs' VALUES ('" key "','" StrReplace(value,"'","''") "','" Format("{:03}", pos) Match "');"){
				ToolTip % "新建词条成功`n编码：" key "`n词条：" value "`n词库：自定义短语"
				SetTimer, ToolTipOff, -5000
			} Else
				OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
		} Else {
			pos:=Max(pos,1)
			DB.GetTable("SELECT (SELECT COUNT(*) FROM pinyin WHERE " (cikuname="pinyin"?"jp = TEMP.jp AND ":"") "key = TEMP.key AND weight > TEMP.weight) + (SELECT COUNT(*) FROM pinyin WHERE " (cikuname="pinyin"?"jp = TEMP.jp AND ":"") "key = TEMP.key AND weight = TEMP.weight AND ROWID <= TEMP.ROWID) FROM pinyin TEMP WHERE " (cikuname="pinyin"?"jp = '" RegExReplace(StrReplace(key,"'","''"),"([a-z])[a-z]*","$1") "' AND ":"") "key = '" StrReplace(key,"'","''") "' AND value = '" value "'",Result), oldpos:=Result.Rows[1,1]
			If (oldpos!="")
				pos+=(pos>oldpos?1:0)
			Else If (pos=oldpos)
				Return
			If (pos=1){
				DB.GetTable("SELECT max(weight)+1 FROM '" cikuname "' WHERE " (cikuname="pinyin"?"jp=""" RegExReplace(key, "([a-z])[a-z]*", "$1") """ AND ":"") "key='" StrReplace(key,"'","''") "'",Result)
				weight:=(Result.Rows[1,1]?Result.Rows[1,1]:5000)
			} Else If (pos>=2){
				DB.GetTable("SELECT weight FROM '" cikuname "' WHERE " (cikuname="pinyin"?"jp=""" RegExReplace(key, "([a-z])[a-z]*", "$1") """ AND ":"") "key='" StrReplace(key,"'","''") "' ORDER BY weight DESC LIMIT " (pos-2) ",2",Result)
				If (Result.RowCount=2){
					If (Result.Rows[1,1]-Result.Rows[2,1]<2)
						DB.Exec("UPDATE 'main'.'" cikuname "' SET weight=weight+" (2+Result.Rows[2,1]-Result.Rows[1,1]) " WHERE ROWID IN (SELECT ROWID FROM '" cikuname "' WHERE " (cikuname="pinyin"?"jp=""" RegExReplace(key, "([a-z])[a-z]*", "$1") """ AND ":"") "key='" StrReplace(key,"'","''") "' ORDER BY weight DESC LIMIT " (pos-1) ")")
					weight:=Result.Rows[2,1]+1
				} Else If (Result.RowCount=1){
					DB.Exec("UPDATE 'main'.'" cikuname "' SET weight=weight+1 WHERE ROWID IN (SELECT ROWID FROM '" cikuname "' WHERE " (cikuname="pinyin"?"jp=""" RegExReplace(key, "([a-z])[a-z]*", "$1") """ AND ":"") "key='" StrReplace(key,"'","''") "' ORDER BY weight DESC LIMIT " (pos-1) ")")
					weight:=Result.Rows[1,1]
				} Else {
					DB.GetTable("SELECT min(weight) FROM '" cikuname "' WHERE " (cikuname="pinyin"?"jp=""" RegExReplace(key, "([a-z])[a-z]*", "$1") """ AND ":"") "key='" StrReplace(key,"'","''") "'",Result)
					If (Result.Rows[1,1]="")
						weight:=5000
					Else
						weight:=Max(Result.Rows[1,1]-1,1)
				}
			}
			If (oldpos="")
				_SQL:="INSERT INTO 'main'.'" cikuname "' VALUES (" (cikuname="pinyin"?"""" RegExReplace(key, "([a-z])[a-z]*", "$1") """,":"") """" key """,'" StrReplace(value,"'","''") "','" weight "');"
			Else
				_SQL:="UPDATE 'main'.'" cikuname "' SET weight = '" weight "' WHERE " (cikuname="pinyin"?"jp = '" RegExReplace(StrReplace(key,"'","''"), "([a-z])[a-z]*", "$1") "' AND ":"") "key = '" StrReplace(key,"'","''") "' AND value = '" StrReplace(value,"'","''") "';"
			If DB.Exec(_SQL){
				ToolTip % "新建词条成功`n编码：" key "`n词条：" value "`n词库：" cikuname
				SetTimer, ToolTipOff, -5000
			} Else
				OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
		}
	}
}

SetWindowsAlwaysOnTop(l,w,msg,Hwnd){
	WinSet, AlwaysOnTop, On, ahk_id%Hwnd%
	ControlGetText, txt, Button2
	If (txt="Cancel"){
		ControlSetText Button1, 确定
		ControlSetText Button2, 取消
	}
	OnMessage(msg, "")
}

restoreinput(str, fzm:=""){
	global srf_all_Input_
	tpos:=RegExMatch(srf_all_Input_["tip"], str)
	StrReplace(SubStr(srf_all_Input_["tip"],1,tpos-1),"'", , yhnum)
	tpos:=InStr(srf_all_Input_["tip"], "'", , 1, yhnum+1)
	tstr:=StrReplace(SubStr(srf_all_Input_["tip"],tpos+1,InStr(srf_all_Input_["tip"], "'", , 1, yhnum+1+StrSplit(str, "'").Length())-tpos-1),"'")
	Return (tstr?tstr fzm:"")
}
; 魔法字符串上屏
srf_HotStringSelect(hotarr, index:=1){
	global ListNum, waitnum
	If (hotarr[index:=index?index+ListNum*waitnum:10+ListNum*waitnum, 1]="")
		Return
	Gosub srf_value_off
	SendInput(StrDeref(hotarr[index, 1]), hotarr[index, 0]), Endinput()
}
; 超级命令执行
srf_RunSelect(function, index:=1){
	; global SendDelaymode, srf_func_table, srf_label_table, DllFolder, ListNum, waitnum
	global
	local tarr, result, exePath, A_variate, errinfo, funcobj, OutDir, Value, tvar, key, Params, Match
	index:=index?index:10
	localpos:=index
	If (index>ListNum||function[index:=index+ListNum*waitnum, 1] . function[index, 3]="")
		Return
	If !(srf_func_table[modeMatch.Value[1], "Name"]="Cliphistory"&&A_ThisHotkey~="Numpad"){
		Gosub srf_value_off
	} Else
		DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction, srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-z]+$"?SymbolFont:TextFont)

	Switch function[index, 0]
	{
		Case "{Script}":
			ExecScript(function[index, 1], function[index, 2])
		Case "{Value}":
			If function[index, 1]
				SendInput(function[index, 1], SendDelaymode)
		Case "{Fast}":
			SendInput(function[index, 1], "{Fast}")
		Case "{Label}":
			If IsLabel(function[index, 1])
				Gosub % function[index, 1]
			Else If IsFunc(tvar:=function[index, 1])&&(Func(tvar).MinParams=0)
				%tvar%()
		Case "{Func}":
			Try {
				If IsObject(result:=ExeFuncStr(function[index, 1]))
					SendInput(result[1], SendDelaymode)
				Else
					SendInput(result, SendDelaymode)
			} Catch errinfo {
				ToolTip % errinfo, A_CaretX + 10 , A_CaretY + 20
				SetTimer, ToolTipOff, -1000
			}
		Case "{Mode}":
			Loop % function[index, 1].Length(){
				If (function[index, 1, A_Index, 1])
					Yzimeini[function[index, 1, A_Index, 1], function[index, 1, A_Index, 2]]:=function[index, 1, A_Index, 3]
				A_variate:=function[index, 1, A_Index, 2]
				If  (A_variate="shurulei"&&function[index, 1, A_Index, 3]!=shurulei&&InStr(function[index, 1, A_Index, 3] "|" shurulei, "pinyin")){
					tvar:=""
					For Value,Key In ["decfre","fixedword","Imagine","Learning","Tofirst","Wordfrequency"] {
						tvar .= %key%
						Yzimeini["Settings",key]:=%key%:=(SubStr(Yzimeini["Settings","Settingsbak"], A_Index, 1)?1:0)
					}
					Yzimeini["Settings","Settingsbak"]:=tvar Inputscheme
				}
				%A_variate%:=function[index, 1, A_Index, 3]
			}
		Case "{Plugin}":
			PluginCall(function[index, 1])
		Default:
			Params:=""
			Loop % srf_Func_Params.Length()-1
				Params .= A_Space srf_Func_Params[A_Index+1]
			SplitPath, exePath, , OutDir
			If !(function[index, 0]~="i)\{Ev(erything)?\}"){
				exePath:=StrDeref(function[index, 1])
				tarr:=tvar:=0
				If (A_PtrSize=4)
					tarr:=DllCall("Kernel32.dll\Wow64DisableWow64FsRedirection", "Ptr*", tvar)
				Try	Run, % exePath Params, %OutDir%
				Catch errinfo {
					ToolTip % exePath "`n" errinfo.Extra, A_CaretX + 10 , A_CaretY + 20
					SetTimer, ToolTipOff, -1000
				}
				If (tarr)
					DllCall("Kernel32.dll\Wow64RevertWow64FsRedirection", "Ptr", tvar)
			} Else {
				If (srf_Plugins["everything",1]=""){
					Run % StrReplace(AhkPath, "_UIA.exe", ".exe") " """ A_ScriptDir "\Lib\tools\everything.ahk" """ " YzimePID, , , tvar
					WinWait, ahk_class AutoHotkey ahk_pid%tvar%, , 2
					srf_Plugins["everything",1]:=tvar
				} Else {
					Process, Exist, % srf_Plugins["everything",1]
					If (!ErrorLevel){
						Run % StrReplace(AhkPath, "_UIA.exe", ".exe") " """ A_ScriptDir "\Lib\tools\everything.ahk" """ " YzimePID, , , tvar
						WinWait, ahk_class AutoHotkey ahk_pid%tvar%, , 2
						srf_Plugins["everything",1]:=tvar
					}
				}
				Send_WM_COPYDATA(function[index, 1] (Params?"`t" Params:""), "ahk_class AutoHotkey ahk_pid" srf_Plugins["everything",1])
			}
	}
	Endinput()
}
; 内置函数
srf_FuncSelect(srf_Input){
	global
	local Match, funcobj, result, key, value, sel
	ToolTipText:=insertcaret(srf_Input,insertpos), srf_Func_Params:=[]
	If (srf_Input=func_key "?"){
		Function_for_select:=[], srf_direction:=1
		Function_for_select[1, 0]:="{Func}", Function_for_select[1, 1]:="ShowSymbol", Function_for_select[1, 3]:="特殊符号输入(" func_key "dw：℃)，详细信息选择跳转"
		Function_for_select[2, 0]:="{Label}", Function_for_select[2, 1]:="Option_Adv", Function_for_select[2, 3]:="命令模式(命令名m" func_key "：模式切换)详见“选项-进阶-命令管理”，选择跳转"
		Function_for_select[3, 0]:="{Value}", Function_for_select[3, 3]:="支持多种格式数字(" func_key "123：一百二十三)、日期(" func_key "2020.06.18：2020年06月18日)、`n时间(" func_key "12:30：十二时三十四分)、公式(" func_key "1+2：1+2=3)"
		Function_for_select[4, 0]:="{Value}", Function_for_select[4, 3]:="英语模糊输入，遗忘部分用" func_key "代替"
		Return 1
	} Else If (srf_Input~="i)^" (func_key="\"?"\\":func_key) "[^a-z]+"){
		If (srf_Input~="i)[^a-z][a-z]$"){
			sel:=Ord(Format("{:L}", SubStr(srf_Input,0)))-96
			If (sel>0&&Function_for_select.Length()>1&&sel<=Function_for_select.Length()){
				select_for_num(sel)
				Endinput()
				Return -2
			}
		} Else If (srf_Input~="\?\d$"){
			srf_RunSelect(Function_for_select, SubStr(srf_Input, 0))
			Return -2
		}
		funcobj:=Func("mathmode"), Function_for_select:=[], srf_Func_Params:=[SubStr(srf_Input,2)]
	} Else If (srf_Input~="^" (func_key="\"?"\\":func_key) "[a-zA-Z]+$"), Function_for_select:=[], srf_Func_Params:=StrSplit(Trim(srf_Input,func_key),func_key)
	{
		If (srf_Func_Params[1])
			Function_for_select:=get_symbol(DB,srf_Func_Params[1])
			If (Function_for_select[1,1]="")
				Function_for_select[1,3]:=Function_for_select[1,1]:=Trim(srf_input, func_key)
		Return 1
	} Else {
		If (funcobj:=srf_func_table[srf_Func_Params[1]]).Name
			srf_Func_Params.RemoveAt(1)
		Else {
			sel:=StrLen(srf_Func_Params[1])
			If (srf_Func_Params[2])
				DB.GetTable("SELECT '" srf_Func_Params[1] "'||substr(key," sel+1 "),weight,2 FROM 'extend'.'English' WHERE key>'" srf_Func_Params[1] "' AND key<'" SubStr(srf_Func_Params[1], 1, -1) Chr(Ord(SubStr(srf_Func_Params[1], 0))+1) "' AND key REGEXP '" StrReplace(LTrim(srf_Input, func_key), func_key, ".+") "' ORDER by 3,weight DESC ", result)
			Else
				DB.GetTable("SELECT '" srf_Func_Params[1] "'||substr(key," sel+1 "),weight,1 FROM 'extend'.'English' WHERE key='" srf_Func_Params[1] "' UNION ALL SELECT '" srf_Func_Params[1] "'||substr(key," sel+1 "),weight,2 FROM 'extend'.'English' WHERE key>'" srf_Func_Params[1] "' AND key<'" SubStr(srf_Func_Params[1], 1, -1) Chr(Ord(SubStr(srf_Func_Params[1], 0))+1) "' ORDER by 3,weight DESC ", result)
			If (result.RowCount){
				Loop % result.RowCount
					result.Rows[A_Index, 3]:=result.Rows[A_Index, 1], result.Rows[A_Index, 0]:="{Value}"
				Function_for_select:=result.Rows
				Loop % Function_for_select.Length()
					Function_for_select[A_Index, 0]:="{Value}"
			} Else {
				Function_for_select[1,0]:="{Value}", Function_for_select[1,3]:=Function_for_select[1,1]:=StrReplace(Trim(srf_input, func_key), func_key)
			}
			Return 1
		}
	}
	If (srf_Func_Params.Length()>=funcobj.MinParams)
		result:=funcobj.Call(srf_Func_Params*)
	If (result="")&&(srf_Func_Params.Length()=0){
		Function_for_select[1, 0]:="{Value}", Function_for_select[1,3]:=Function_for_select[1,1]:=Trim(srf_input, func_key)
		, srf_for_select:="1." Function_for_select[1,3], srf_for_select_obj:=[], srf_for_select_obj[1]:=Function_for_select[1,3]
		Return 1
	} Else If IsObject(result){
		If (result[1,0]="{Off}")
			Return -1
		Function_for_select:=result
		Return 1
	} Else {
		If (result="")
			result:=LTrim(srf_Input,func_key)
		Function_for_select[1, 0]:="{Value}", srf_for_select:="1." (Function_for_select[1, 3]:=Function_for_select[1, 1]:=result)
		, srf_for_select_obj:=[], srf_for_select_obj[1]:=Function_for_select[1,3]
	}
	Return 0
}
Begininput(){
	global
	If (srf_inputing)
		Return 1
	If (TSFmode && (!(InStr(mode, "{"))||(mode~="\{\d+\}"))){
		TSFMem.SetFlags(1)
		SendInput {vkD8}
		srf_inputing:=2
	} else
		srf_inputing:=1
	Return hasCaretPos:=0
}
Endinput(){
	global
	If (!srf_inputing)
		return 0
	If (TSFmode && srf_inputing = 2){
		SendInput {vkD9}
	}
	Return srf_inputing:=0
}
ShowSymbol(){
	global
	local Index
	Function_for_select:=[], srf_direction:=Begininput(), ToolTipText:="默认特殊符号"
	Function_for_select[1, 0]:="{Value}", Function_for_select[1, 3]:="标点(折) bd(z)、单位 dw、数学 sx、几何 jh、货币 hb、上下标 sb xb`n一~十 yi~shi、分数 fs、罗马数字 lm(d)、数字(圈,弧,点) sz(q,h,d)、`n日期 yf rq yr、时间 sj、节气 jq、天干地支 tg dz gz"
	Function_for_select[2, 0]:="{Value}", Function_for_select[2, 3]:="八卦,太玄经 bg(m) lssg lssgm txj、表情 bq、电脑 dn、符号 fh、`n方块 fk、箭头 jt、两性 lx、麻将 mj、扑克 pk、色子 sz、天气 tq、`n天体 tt、星号 xh、象棋 xq、星座 xz(m) seg、音乐 yy"
	Function_for_select[3, 0]:="{Value}", Function_for_select[3, 3]:="笔画 bh、拼音 py(d)、注音 zy、声调 sd、结构 jg、偏旁 pp`n康熙部首 kx、汉字(圈,弧度) hz(q,h)、蘇州碼 szm、拉丁 a~z`n俄语 ey eyd、字母(圈,弧) zm(q,h)、韩文(圈,弧) hw(q,h)`n日文 iro、假名 jm(a~z,bj)、片假名 pjm、希腊 xl(d)"
	Loop % Function_for_select.Length()
		Index:=srf_for_select_obj.Push(A_Index "." Function_for_select[ListNum*waitnum+A_Index, 3])
			, srf_for_select .= "`n" srf_for_select_obj[Index]
	Gosub showhouxuankuang
}
ExeFuncStr(ByRef str, fg:=1){
	local
	global srf_func_table, func_key
	If RegExMatch(str, "O)^([^" (func_key="\"?"\\":func_key) "\(\)]+?)(\((.*)\))?$", Match){
		funcname:=Match.Value[1], params:=[]
		Loop, Parse, % Match.Value[3], CSV, %A_Space%%A_Tab%
			params.Push(StrDeref(A_LoopField))
		funcobj:=srf_func_table[funcname]?srf_func_table[funcname]:fg&&IsFunc(funcname)?Func(funcname):""
	} Else
		params:=StrSplit(Trim(str, func_key), func_key), funcobj:=srf_func_table[params[1]]?srf_func_table[params[1]]:fg&&IsFunc(params[1])?Func(params[1]):"", params.RemoveAt(1)
	If IsObject(funcobj)
		Return funcobj.Call(params*)
}
mathmode(str){
	local
	result:=[]
	If (str~="^\d+(\.(\d+)?)?$"){
		arr:=StrSplit(str,"/")
		t:=n2c(arr*)
		Loop % t.Length()
			result.Push(t[A_Index])
		arr[2]:="r"
		result.Push({0:"{Value}",1:(t:=n2c(arr*)),3:t})
		; arr[2]:="dr"
		; result.Push({0:"{Value}",1:(t:=n2c(arr*)),3:t})
	}
	If RegExMatch(str,"O)^(\d{4}|\d\d|\d)\.(1[012]|0?[1-9])\.(3[01]|[12]\d|0?[0-9])$",mm){
		If (StrLen(mm.Value[1])<3){
			t:="yy年" (StrLen(mm.Value[2])=2?"M":"") "M月" (StrLen(mm.Value[3])=2?"d":"") "d日"
			arr:=date(Format("20{:02}{:02}{:02}",mm.Value[1],mm.Value[2],mm.Value[3]),0,t)
			If arr&&!IsObject(arr){
				result.Push({0:"{Value}",1:arr,3:arr})
				arr:=date(Format("20{:02}{:02}{:02}",mm.Value[1],mm.Value[2],mm.Value[3]),1,t), result.Push({0:"{Value}",1:arr,3:arr})
			}
		} Else {
			t:="yyyy年" (StrLen(mm.Value[2])=2?"M":"") "M月" (StrLen(mm.Value[3])=2?"d":"") "d日"
			arr:=date(mm.Value[1] Format("{:02}{:02}",mm.Value[2],mm.Value[3]),0,t)
			If arr&&!IsObject(arr){
				result.Push({0:"{Value}",1:arr,3:arr})
				arr:=date(mm.Value[1] Format("{:02}{:02}",mm.Value[2],mm.Value[3]),1,t), result.Push({0:"{Value}",1:arr,3:arr})
				arr:=lunar(mm.Value[1] Format("{:02}{:02}",mm.Value[2],mm.Value[3]),"农历YYYY年Md"), result.Push({0:"{Value}",1:arr,3:arr})
				arr:=lunar(mm.Value[1] Format("{:02}{:02}",mm.Value[2],mm.Value[3]),"YY年Md"), result.Push({0:"{Value}",1:arr,3:arr})
			}
		}
	} Else If RegExMatch(str,"O)^(1[0-2]|0?[1-9])\.(3[01]|[12]\d|0?[0-9])$",mm){
		t:=(StrLen(mm.Value[1])=2?"M":"") "M月" (StrLen(mm.Value[2])=2?"d":"") "d日"
		arr:=date(A_YYYY Format("{:02}{:02}",mm.Value[1],mm.Value[2]),0,t)
		If arr&&!IsObject(arr){
			result.Push({0:"{Value}",1:arr,3:arr})
			arr:=date(A_YYYY Format("{:02}{:02}",mm.Value[1],mm.Value[2]),1,t), result.Push({0:"{Value}",1:arr,3:arr})
		}
		If (mm.Value[2]<13){
			t:="yy年" (StrLen(mm.Value[2])=2?"M":"") "M月"
			arr:=date(Format("20{:02}{:02}",mm.Value[1],mm.Value[2]),0,t), result.Push({0:"{Value}",1:arr,3:arr})
			arr:=date(Format("20{:02}{:02}",mm.Value[1],mm.Value[2]),1,t), result.Push({0:"{Value}",1:arr,3:arr})
		}
	} Else If RegExMatch(str,"O)^(\d{4}|\d\d|\d)\.(1[012]|0?[1-9])$",mm){
		If (StrLen(mm.Value[1])<3){
			t:="yy年" (StrLen(mm.Value[2])=2?"M":"") "M月"
			arr:=date(Format("20{:02}{:02}",mm.Value[1],mm.Value[2]),0,t)
			If arr&&!IsObject(arr){
				result.Push({0:"{Value}",1:arr,3:arr})
				arr:=date(Format("20{:02}{:02}",mm.Value[1],mm.Value[2]),1,t), result.Push({0:"{Value}",1:arr,3:arr})
			}
		} Else {
			t:="yyyy年" (StrLen(mm.Value[2])=2?"M":"") "M月"
			arr:=date(mm.Value[1] Format("{:02}",mm.Value[2]),0,t)
			If arr&&!IsObject(arr){
				result.Push({0:"{Value}",1:arr,3:arr})
				arr:=date(mm.Value[1] Format("{:02}",mm.Value[2]),1,t), result.Push({0:"{Value}",1:arr,3:arr})
				arr:=lunar(mm.Value[1] Format("{:02}",mm.Value[2]),"农历YYYY年M"), result.Push({0:"{Value}",1:arr,3:arr})
				arr:=lunar(mm.Value[1] Format("{:02}",mm.Value[2]),"YY年M"), result.Push({0:"{Value}",1:arr,3:arr})
			}
		}
	} Else {
		If RegExMatch(str,"O)^(\d{4})/(\d\d?)(/\d\d?)?$",mm)
			t:=mm.Value[1] Format("{:02}",mm.Value[2]) (mm.Value[3]?Format("{:02}",SubStr(mm.Value[3],2)):"")
		If t&&!Mod(StrLen(t),2){
			If t is time
			{
				arr:=FormatTime(t,"yyyy年" (StrLen(t)>4?"M月":"") (StrLen(t)>6?"d日":""),0), result.Push({0:"{Value}",1:arr,3:arr}), arr:=FormatTime(t,"yyyy年" (StrLen(t)>4?"M月":"") (StrLen(t)>6?"d日":""),1), result.Push({0:"{Value}",1:arr,3:arr})
				If StrLen(t)>6
					arr:=lunar(t,"农历YYYY年Md"), result.Push({0:"{Value}",1:arr,3:arr}),arr:=lunar(t,"YY年Md"), result.Push({0:"{Value}",1:arr,3:arr})
			} Else If !InStr(str,"/"){
				t:=SubStr(A_Now,1,8) t
				If t is time
					arr:=FormatTime(t,"H时" (StrLen(t)>11?"m分":"") (StrLen(t)>13?"s秒":""),0), result.Push({0:"{Value}",1:arr,3:arr}), arr:=FormatTime(t,"H时" (StrLen(t)>11?"m分":"") (StrLen(t)>13?"s秒":""),1), result.Push({0:"{Value}",1:arr,3:arr})
			}
		}
	}
	If RegExMatch(str,"O)^(2[0-3]|1\d|0?[1-9]):([1-5]\d|0?[1-9])(:([1-5]\d|0?[1-9]))?$",mm){
		t:="H时m分" (mm.Value[4]?"s秒":"")
		arr:=time(SubStr(A_Now,1,8) Format("{:02}{:02}{:02}",mm.Value[1],mm.Value[2],mm.Value[4]),0,t), result.Push({0:"{Value}",1:arr,3:arr})
		arr:=time(SubStr(A_Now,1,8) Format("{:02}{:02}{:02}",mm.Value[1],mm.Value[2],mm.Value[4]),1,t), result.Push({0:"{Value}",1:arr,3:arr})
		If (mm.Value[4]=""){
			arr:=time(SubStr(A_Now,1,10) Format("{:02}{:02}",mm.Value[1],mm.Value[2]),0,"m分s秒"), result.Push({0:"{Value}",1:arr,3:arr})
			arr:=time(SubStr(A_Now,1,10) Format("{:02}{:02}",mm.Value[1],mm.Value[2]),1,"m分s秒"), result.Push({0:"{Value}",1:arr,3:arr})
		}
	} Else If RegExMatch(str,"O)^([1-5]\d|0?[1-9]):([1-5]\d|0?[1-9])$",mm){
		arr:=time(SubStr(A_Now,1,10) Format("{:02}{:02}",mm.Value[1],mm.Value[2]),0,"m分s秒"), result.Push({0:"{Value}",1:arr,3:arr})
		arr:=time(SubStr(A_Now,1,10) Format("{:02}{:02}",mm.Value[1],mm.Value[2]),1,"m分s秒"), result.Push({0:"{Value}",1:arr,3:arr})
	}
	If (str~="[\+\-\*/!\^\(\)%&\|<>~]"){
		If (SubStr(str,0)="=")
			str:=SubStr(str,1,-1)
		arr:=RegExReplace(str,"(\d+)!","jiecheng($1)")
		RegExMatch(arr,"O)(\([^\(\)]+\)|\d+(\.\d+)?)\^(\([^\(\)]+\)|\d+(\.\d+)?)",mm)
		arr:=RegExReplace(arr,"(\([^\(\)]+\)|\d+(\.\d+)?)\^(\([^\(\)]+\)|\d+(\.\d+)?)","Math.pow($1,$3)")
		arr:=RegExReplace(arr,"(?<!\.)\b0+(?=\d)")
		Try arr:=JScript().("eval2(" arr ").toString()")
		Catch
			arr:=""
		If (arr!="")&&!InStr(arr,"#"){
			If RegExMatch(arr:=Round(arr, 15),"(?<=\.).*?9{4,}\d*$")
				arr:=RegExReplace(arr,"(?<=\.)(.*?)9{4,}\d*$","$1"), arr+=1/(10**StrLen(Strsplit(arr,".")[2]))*(SubStr(arr,1,1)="-"?-1:1)
			arr:=RTrim(RegExReplace(arr,"(?<=\.)(.*?)(0{4,}\d*|0*)$","$1"),".")
			, result.Push({0:"{Value}",1:arr,3:arr}), arr:=str "=" arr, result.Push({0:"{Value}",1:arr,3:arr})
		}
	}
	If result.Length()=0
		result:=""
	Return result
}
get_hotstring(str){
	global DB
	Return get_word_lianxiang(DB,str,"hotstrings",0)
}
get_function(str){
	global DB
	Return get_word_lianxiang(DB,str,"functions",0)
}
; 模糊取词
get_word_lianxiang(DB, input, cikuname, num:=200, xz:=0){
	local
	Critical
	global Imagine, Singleword, SQL_buffer, srf_all_Input
	If (input="")
		Return []
	If (cikuname="English"){
		len:=StrLen(input), _SQL:="SELECT '','" input "'||substr(key," len+1 "),weight,1 FROM 'extend'.'English' WHERE key='" Input "' UNION ALL SELECT '','" input "'||substr(key," len+1 "),weight,2 FROM 'extend'.'English' WHERE key>'" Input "' AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "' " (xz?"AND length(key)<" xz+StrLen(Input):"") " ORDER by 4,weight DESC " (num?" limit " num:"")
		; If (Ord(input)<91)
		; 	_SQL:="SELECT '',upper(substr(key,1,1))||substr(key,2),weight,1 FROM 'extend'.'English' WHERE key='" Input "' UNION ALL SELECT '',upper(substr(key,1,1))||substr(key,2),weight,2 FROM 'extend'.'English' WHERE key>'" Input "' AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "' " (xz?"AND length(key)<5+" StrLen(Input):"") " ORDER by 4,weight DESC " (num?" limit " num:"")
		; Else
		; 	_SQL:="SELECT '',key,weight,1 FROM 'extend'.'English' WHERE key='" Input "' UNION ALL SELECT '',key,weight,2 FROM 'extend'.'English' WHERE key>'" Input "' AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "' AND length(key)<5+" StrLen(Input) " ORDER by 4,weight DESC " (num?" limit " num:"")
	} Else If (cikuname="hotstrings"), Input:=Format("{:L}", Input)
		_SQL:="SELECT value,comment,replace(replace(value,x'0a','``n'),x'09','``t') FROM 'extend'.'hotstrings' WHERE key>='" Input "' AND key<""" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) """ AND value <> '' ORDER by key " (num?" limit 2":"")
	Else If (cikuname="functions")
		_SQL:="SELECT value,comment,comment FROM 'extend'.'functions' WHERE key>='" Input "' AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "' AND value <> '' ORDER by key " (num?" limit 2":"")
	Else 
		word:=Singleword||InStr(srf_all_Input,"``"), _SQL:="SELECT key,value,weight,1 FROM '" cikuname "' WHERE key='" Input "' AND value <> '' " (word?"AND length(value)=1":"") " UNION ALL SELECT key,value,weight,length(key) FROM '" cikuname "' WHERE key>'" Input "' " ("AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "'") " AND length(key)<" StrLen(Input)+3 " AND value <> '' " (word?"AND length(value)=1":"") " ORDER by 4,weight DESC " (num?"limit " num:"")
	If DB.GetTable(_SQL, Result){
		If (Result.RowCount){
			If (cikuname="hotstrings"){
				Loop % Result.RowCount {
					If RegExMatch(Result.Rows[A_Index, 2], "\{.*\}", Match){
						Result.Rows[A_Index, 2]:=StrReplace(Result.Rows[A_Index, 2],Match)
						If InStr(Match,"{bz}")
							Result.Rows[A_Index, 3]:=Result.Rows[A_Index, 2], Result.Rows[A_Index, 0]:=StrReplace(Match,"{bz}")
						Else
							Result.Rows[A_Index, 0]:=Match
					}
					If (!InStr(Match,"{bz}")&&StrLen(Result.Rows[A_Index, 3])>30)
						Result.Rows[A_Index, 3]:=SubStr(Result.Rows[A_Index, 3],1,30) "……"
				}
			} Else If (cikuname="functions"){
				Loop % Result.RowCount
					If RegExMatch(Result.Rows[A_Index, 2], "\{.*\}", Match){
						If ((Result.Rows[A_Index, 3]:=StrReplace(Result.Rows[A_Index, 2],Match))="")
							Result.Rows[A_Index, 3]:=SubStr(StrReplace(Result.Rows[A_Index, 1],"`n","``n"),1,30) (StrLen(Result.Rows[A_Index, 1])>30?"……":"")
						Result.Rows[A_Index, 0]:=Match
					}
			} Else If (cikuname="English"){
				Loop % Result.RowCount
					Result.Rows[A_Index, 3]:=Result.Rows[A_Index, 2]
			} Else {
				index:=0, fg:=0, SQL_buffer[input]:=_SQL
				Loop % Result.RowCount
					If (Result.Rows[A_Index, 4]=2){
						If fg=0
							fg:=A_Index, index:=0
						index++, Result.Rows[A_Index, 0]:=cikuname "|" index, Result.Rows[A_Index, 4]:=Result.Rows[fg, 3], Result.Rows[A_Index, -1]:=input
					} Else
						index++, Result.Rows[A_Index, 0]:=cikuname "|" index, Result.Rows[A_Index, 4]:=Result.Rows[1, 3], Result.Rows[A_Index, -1]:=input
			}
		}
		Result.Rows[0]:=input
		Return Result.Rows
	}
	Return []
}
; 精确取词
get_word(DB, input, cikuname, num:=0){
	local
	Critical
	global Singleword, SQL_buffer, valueindex, srf_all_Input
	If (input="")
		Return []
	If (cikuname="pinyin")
		_SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp=""" RegExReplace(Input,"([a-z])[a-z]*","$1") """ AND key='" StrReplace(Input,"'","''") "' ORDER BY weight DESC"
	Else If (cikuname~="^(hotstrings|functions)$")
		_SQL:="SELECT value,comment FROM 'extend'.'" cikuname "' where key='" Input "' AND value <> '' ORDER by key ASC limit 1"
	Else If (cikuname="customs")
		_SQL:="SELECT value,value,comment,comment FROM 'extend'.'customs' where key='" Input "' AND comment>'/' AND comment<':' ORDER BY key,comment+0"
	Else If (cikuname="English")
		len:=StrLen(input), _SQL:="SELECT '','" Input "'||substr(key," len+1 "),weight FROM 'extend'.'English' WHERE key='" Input "' ORDER by weight DESC Limit 3"
	Else
		word:=Singleword||InStr(srf_all_Input,"``"), _SQL:="SELECT key,value,weight FROM '" cikuname "' where key='" Input "' AND value <> '' " (word?"AND length(value)=1":"") " ORDER BY key,weight DESC" (num?" LIMIT" num:"")
	; If (cikuname="customs")
	; 	MsgBox %input%
	If DB.GetTable(_SQL, Result){
		If (Result.RowCount){
			If (cikuname="customs"){
				Loop % Result.RowCount
				{
					Result.Rows[A_Index, -1]:=Input ;, Result.Rows[A_Index, 1]:=""
					RegExMatch(Result.Rows[A_Index, 3], "^(\d+)(\{.*\})?",match)
					Result.Rows[A_Index, 0]:=cikuname "|" A_Index "|" match2, Result.Rows[A_Index, 3]:=match1
				}
				If (valueindex>2)
					Loop % Result.RowCount
						Result.Rows[A_Index, valueindex]:=Result.Rows[A_Index, 2]
			} Else {
				Loop % Result.RowCount
					Result.Rows[A_Index, -1]:=input, Result.Rows[A_Index, 0]:=cikuname "|" A_Index, Result.Rows[A_Index, 4]:=Result.Rows[1, 3]
				SQL_buffer[input]:=_SQL
			}
		}
		Result.Rows[0]:=input
		Return Result.Rows
	}
	; Else
		; MsgBox % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
	Return []
}

; 字符上屏
SendInput(str, mode:=""){
	Critical
	global ClipSaved, TSFMem, TSFmode, srf_inputing
	If !(InStr(mode, "{"))||(mode~="\{\d+\}"){
		If (TSFmode){
			TSFMem.SetString(str)
			SendInput {vk0e}
			if (Caret.t!="TSF")
				SetTimer CheckTSFInputSuccess, -50
		} Else
			SendInput % "{Text}" str
	} Else {
		If (srf_inputing = 2){
			SendInput {vkD9}
			srf_inputing:=1
		}
		If (TSFmode)
			TSFMem.SetFlags(0)
		If RegExMatch(mode, "i)\{Fast(,(\d+))?\}", KeyDelay){
			OnClipboardChange("ClipChanged", 0)
			If (ClipSaved="")&&Clipboard
				ClipSaved:=ClipboardAll
			If ((t:=TickCount(1, 1))>15){
				Clipboard:=str
				SendInput, {RShift Down}{Insert}{RShift Up}
				TickCount(0, 1)
			} Else
				Clipboard.=str
			OnClipboardChange("ClipChanged", 1)
		} Else If RegExMatch(mode, "i)\{Delay,(\d+)?(,\d+)?\}", KeyDelay){
			SetKeyDelay, %KeyDelay1%, % Trim(KeyDelay2, ",")
			SendEvent % (InStr(mode, "{Text}")?"{Text}":"") str
			SetKeyDelay, 0, 0
		} Else
			SendInput % str
	}
	Return
}
CheckTSFInputSuccess(){
	global TSFMem
	If (TSFMem.Get(20, "UShort")){
		s := StrGet(TSFMem._buf+TSFMem._headsize, "UTF-16")
		TSFMem.Clear()
		SendInput % "{Text}" s
		; OutputDebug tsf fail
	}
}
TickCount(s:=0,n:=1){
	static freq:=0, CounterBefore:=""
	t:=0
	If !freq
		CounterBefore:=[], DllCall("QueryPerformanceFrequency", "Int64*", freq), DllCall("QueryPerformanceCounter", "Int64*", t), CounterBefore[n]:=t
	If (s){
		DllCall("QueryPerformanceCounter", "Int64*", t)
		Return Format("{:.2f}", (t - CounterBefore[n])/freq*1000)
	} Else
		DllCall("QueryPerformanceCounter", "Int64*", t), CounterBefore[n]:=t
}
soso_select(source,search:=""){
	static sosourl:={baidu:"http://www.baidu.com/s?ie=utf-8&wd=",bing:"https://cn.bing.com/search?q=",weibo:"https://s.weibo.com/weibo/",google:"http://www.google.com/search?q="}
	If (search=""){
		OnClipboardChange("ClipChanged", 0)
		ClipSaved:=ClipboardAll
		Clipboard:=""
		SendInput, {RCtrl Down}c{RCtrl Up}
		ClipWait, 0.5
		If (Clipboard&&DllCall("IsClipboardFormatAvailable","UInt",1))
			search:=Clipboard
		Clipboard:=ClipSaved
		OnClipboardChange("ClipChanged", 1)
		If (search=""){
			OnMessage(0x18, "SetWindowsAlwaysOnTop")
			InputBox, search, 输入搜索关键字, , , , 100, , , , , % Last_input()
			OnMessage(0x18,"")
			If (ErrorLevel)
				Return
		}
	}
	search:=StrReplace(StrReplace(StrReplace(StrReplace(search,"\","\\"),"'","\'"), "`n", "\n"), "`r", "\r")
	Run, % sosourl[source] JScript().("encodeURIComponent('" search "')")
}
soso_list(str:=""){
	; str:="(.*)" RegExReplace(str, "(.)", "$1(.*)")
	; m_list:=[{0:"{Func}",1:"soso_select(baidu)",3:"百度搜索",4:"baidusousuo"},{0:"{Func}",1:"soso_select(bing)",3:"bing搜索",4:"bingsousuo"}
	; 	,{0:"{Func}",1:"fanyi_select(google)",3:"谷歌翻译",4:"gugefanyi"},{0:"{Func}",1:"fanyi_select(youdao)",3:"有道翻译",4:"youdaofanyi"}
	; 	,{0:"{Func}",1:"soso_select(weibo)",3:"微博搜索",4:"weibosousuo"},{0:"{Func}",1:"soso_select(google)",3:"谷歌搜索",4:"gugesousuo"}]
	; Loop % len:=m_list.Length()
	; 	If !(m_list[len+1-A_Index,4]~=str)
	; 		m_list.RemoveAt(len+1-A_Index)
	; Return m_list
}
fanyi_select(apitype:="youdao",KeyWord:=""){
	static apitype_
	If (KeyWord=""){
		OnClipboardChange("ClipChanged", 0)
		KeyWord:=Clipboard
		ClipSaved:=ClipboardAll
		Clipboard:=""
		SendInput, {RCtrl Down}c{RCtrl Up}
		ClipWait, 0.5
		If (Clipboard&&DllCall("IsClipboardFormatAvailable","UInt",1))
			KeyWord:=Clipboard
		Clipboard:=ClipSaved
		ClipSaved:=""
		OnClipboardChange("ClipChanged", 1)
	}
	Gui, fanyi:-DPIScale
	Gui, fanyi:Color, White, White
	Gui, fanyi:Margin, 0, 0
	Gui, fanyi:Font, s15
	w:=A_ScreenWidth//2, h:=A_ScreenHeight*0.375
	Gui, fanyi:Add, Edit, w%w% h%h% ggettrans_
	Gui, fanyi:Add, Tab, % "gfanyitab AltSubmit Choose" (apitype="google"?1:2), 谷歌翻译|有道翻译
	Gui, fanyi:Tab, 1
	Gui, fanyi:Add, Edit, w%w% h%h% ReadOnly
	Gui, fanyi:Tab, 2
	Gui, fanyi:Add, Edit, w%w% h%h% ReadOnly
	Gui, fanyi:Font
	Gui, fanyi:Show, , 中英互译 Esc关闭窗口 Tab切换
	WinSet, Redraw,, 中英互译 Esc关闭窗口 Tab切换
	Hotkey, IfWinActive, 中英互译 Esc关闭窗口 Tab切换
	Hotkey, Tab, switchfanyitab
	Hotkey, If
	apitype_:=apitype
	GuiControl, fanyi:, Edit1, %KeyWord%
	SetTimer gettrans, -10
	Return
	switchfanyitab:
		Gui, fanyi:Default
		GuiControlGet, apitype,, SysTabControl321
		GuiControl, Choose, SysTabControl321, % "|" 3-apitype
	Return
	fanyitab:
		GuiControlGet, apitype,, SysTabControl321
		apitype_:=apitype=1?"google":"youdao"
		Gosub gettrans
	Return
	gettrans:
		Critical, Off
		Gui, fanyi:Default
		GuiControlGet, KeyWord,, Edit1
		GuiControl, , % (apitype_="google"?"Edit2":"Edit3"), % TranslateApi(apitype_,KeyWord,"auto","auto")
	Return
	gettrans_:
		SetTimer, gettrans, -400
	Return
	fanyiGuiEscape:
	fanyiGuiClose:
		Gui, fanyi:Destroy
	Return
}
label_list(str:=""){
	str:="(.*)" RegExReplace(str, "(.)", "$1(.*)")
	m_list:=[{0:"{Label}",1:"option",3:"选项",4:"xuanxiang"},{0:"{Label}",1:"currentciku",3:"词库",4:"ciku"},{0:"{Label}",1:"cikuManager",3:"短语词库",4:"duanyuciku"}
		,{0:"{Label}",1:"srfreload",3:"重启",4:"chongqi"},{0:"{Label}",1:"srfupdate",3:"更新",4:"gengxin"},{0:"{Label}",1:"srfsuspend",3:"禁用",4:"jinyong"},{0:"{Label}",1:"EXIT",3:"退出",4:"tuichu"}]
	Loop % len:=m_list.Length()
		If !(m_list[len+1-A_Index,4]~=str)
			m_list.RemoveAt(len+1-A_Index)
	Return m_list
}
mode_list(str:=""){
	global
	local m_list, len
	str:="(.*)" RegExReplace(str, "(.)", "$1(.*)")
	m_list:=[{0:"{Mode}",1:[["Settings","Traditional",(Traditional?0:1)],["","valueindex",(Traditional?2:5)]],3:(Traditional?"关闭繁体输入":"繁体输入"),4:"fanti"}
			,{0:"{Mode}",1:[["Settings","Imagine",(Imagine?0:1)]],3:(Imagine?"关闭联想":"开启联想"),4:"liangxing"}
			,{0:"{Mode}",1:[["","Englishmode",(Englishmode?0:1)]],3:(Englishmode?"关闭英语输入":"英语输入"),4:"yingwen"}
			,{0:"{Mode}",1:[["Settings","EnSymbol",(EnSymbol?0:1)]],3:(EnSymbol?"中文标点":"英文标点"),4:"biaodian"}
			, (DllCall(A_ScriptDir "\tsf\Yzime" (A_PtrSize=8?"64":"") ".dll\IsYzimeInstall")=1)
				?{0:"{Mode}",1:[["","TSFmode",(TSFmode?0:1)],["","SendDelaymode",""]],3:(TSFmode?"切换至默认上屏":"切换至TSF模式"),4:"tsf"}
				:{0:"{Mode}",1:[["","SendFromClip",(SendFromClip?0:1)],["","SendDelaymode",(SendFromClip?(SendDelay?"{Delay," SendDelay*10 ",0}":""):"{Fast}")]],3:(SendFromClip?"切换至默认上屏":"切换至剪贴板上屏"),4:"jiantieban"}
			,{0:"{Mode}",1:[["GuiStyle","Textdirection",(Textdirection="Vertical"?"Horizontal":"Vertical")]],3:(Textdirection="Vertical"?"候选框横版":"候选框竖版"),4:"houxuankuang"}]

	If (shurulei="pinyin"){
		m_list.Push({0:"{Mode}",1:[["Settings","fuzhuma",(fuzhuma?0:1)]],3:(fuzhuma?"关闭辅助码":"开启辅助码"),4:"fuzhuma"})
		m_list.Push({0:"{Mode}",1:[["Settings","Learning",(Learning?0:1)]],3:(Learning?"关闭自学习":"开启自学习"),4:"zixuexi"})
		m_list.Push({0:"{Mode}",1:[["Settings","Singleword",(Singleword?0:1)]],3:(Singleword?"长句模式":"字词模式"),4:"zicichangju"})
		m_list.Push({0:"{Mode}",1:[["Settings","CloudInput",(CloudInput?0:1)]],3:(CloudInput?"关闭云输入":"开启云输入"),4:"yunshuru"})
		m_list.Push({0:"{Mode}",1:[["Settings","chaojijp",(chaojijp?0:1)]],3:(chaojijp?"关闭超级简拼":"开启超级简拼"),4:"chaojijianpin"})
		m_list.Push({0:"{Mode}",1:[["Settings","Wordfrequency",(Wordfrequency?0:1)]],3:(Wordfrequency?"关闭动态调频":"开启动态调频"),4:"dongtaitiaopin"})
		If (Wordfrequency)
			m_list.Push({0:"{Mode}",1:[["Settings","fixedword",(fixedword?0:1)]],3:(fixedword?"关闭字频固定":"字频固定"),4:"zipingudin"})
	} Else {
		m_list.Push({0:"{Mode}",1:[["Settings","Singleword",(Singleword?0:1)]],3:(Singleword?"字词模式":"字模式"),4:"zici"})
		m_list.Push({0:"{Mode}",1:[["Settings","lspy",(lspy?0:1)]],3:(lspy?"关闭Z拼音模式":"开启Z拼音模式"),4:"zpinyin"})
		If (lspy)
			m_list.Push({0:"{Mode}",1:[["Settings","ShowCode",(ShowCode?0:1)]],3:(ShowCode?"关闭编码反查":"开启编码反查"),4:"bianmafancha"})
		m_list.Push({0:"{Mode}",1:[["Settings","zigen",(zigen?0:1)]],3:(zigen?"关闭字根反查":"开启字根反查"),4:"zigenfancha"})
		m_list.Push({0:"{Mode}",1:[["Settings","wumaqc",(wumaqc?0:1)]],3:(wumaqc?"关闭误码清除":"开启误码清除"),4:"wumaqingchu"})
		m_list.Push({0:"{Mode}",1:[["Settings","simasp",(simasp?0:1)]],3:(simasp?"关闭无重上屏":"开启无重上屏"),4:"simashangping"})
		m_list.Push({0:"{Mode}",1:[["Settings","wumasp",(wumasp?0:1)]],3:(wumasp?"关闭顶字上屏":"开启顶字上屏"),4:"wumashangping"})
	}
	Loop % len:=m_list.Length()
		If !(m_list[len+1-A_Index,4]~=str)
			m_list.RemoveAt(len+1-A_Index)
	Return m_list
}
Inputscheme_list(str:=""){
	local
	global DB, pinyince, Inputscheme, MethodTable
	result:=[], str:="(.*)" RegExReplace(str, "(.)", "$1(.*)")
	DB.GetTable("SELECT name FROM sqlite_master WHERE type='table' AND NOT instr(tbl_name,'@') AND tbl_name NOT IN ('English','symbol','customs','functions','hotstrings','pinyin','hebing','sqlite_sequence') ORDER BY name DESC",TableInfo)
	Loop % TableInfo.RowCount
		If (TableInfo.Rows[A_Index,1]~=str)
			If (Inputscheme=TableInfo.Rows[A_Index,1])
				result.InsertAt(1,{0:"{Mode}",1:[["","shurulei",MethodTable[TableInfo.Rows[A_Index,1]]?MethodTable[TableInfo.Rows[A_Index,1]]:"xingma"],["Settings","Inputscheme",TableInfo.Rows[A_Index,1]]],3:"<" TableInfo.Rows[A_Index,1] ">"})
			Else
				result.Push({0:"{Mode}",1:[["","shurulei",MethodTable[TableInfo.Rows[A_Index,1]]?MethodTable[TableInfo.Rows[A_Index,1]]:"xingma"],["Settings","Inputscheme",TableInfo.Rows[A_Index,1]]],3:TableInfo.Rows[A_Index,1]})
	For Key, Value in pinyince
		If (Value~=str)
			If (Inputscheme=Value)
				result.InsertAt(1,{0:"{Mode}",1:[["","shurulei","pinyin"],["Settings","Inputscheme",Value]],3:"<" Key ">"})
			Else
				result.Push({0:"{Mode}",1:[["","shurulei","pinyin"],["Settings","Inputscheme",Value]],3:Key})
	Return result
}
editgetsel(){
	local
	ControlGetFocus, ctl, A
	ControlGet focusedHWND, Hwnd, , %ctl%, A
	If DllCall("SendMessage", "Ptr", focusedHWND, "Uint", 0xB0, "UintP", start, "UintP", end){
		VarSetCapacity(buf, (A_IsUnicode?2:1)*end, 0)
		ControlGetText, buf, , ahk_id%focusedHWND%
		Return Trim(SubStr(buf, start+1, end-start)," `r`n`t"), buf:=""
	}
	Return Chr(1)
}
selectmenu(){
	local
	Critical, Off
	static init:=0
		, Paramslist:={百度搜索:"baidu",谷歌搜索:"google",bing搜索:"bing",微博搜索:"weibo",谷歌翻译:"google",有道翻译:"youdao",二维码生成:"qrcode",Base64编码:"StrToBase64",Base64解码:"Base64toStr"}
	global srf_mode, YzimePID, Gbuffer:=""
	If (!init){
		Menu, soso_select, Add, 百度搜索(&B), selectmenu_
		Menu, soso_select, Add, bing搜索(&N), selectmenu_
		Menu, soso_select, Add, 微博搜索(&W), selectmenu_
		Menu, soso_select, Add, 谷歌搜索(&G), selectmenu_
		Menu, fanyi_select, Add, 谷歌翻译(&G), selectmenu_
		Menu, fanyi_select, Add, 有道翻译(&Y), selectmenu_
		Menu, Encoding, Add, 二维码生成(&Q), Func_
		Menu, Encoding, Add, Base64编码(&E), Func_
		Menu, Encoding, Add, Base64解码(&D), Func_
		Menu, selectmenu, Add, 搜索(&S), :soso_select
		Menu, selectmenu, Add, 翻译(&F), :fanyi_select
	}
	If ((Gbuffer:=editgetsel())=Chr(1)){
		OnClipboardChange("ClipChanged", 0)
		ClipSaved:=ClipboardAll
		Gbuffer:=Clipboard:=""
		Sleep 100
		SendInput, {RCtrl Down}c{RCtrl Up}
		ClipWait, 0.5
		If (Clipboard&&DllCall("IsClipboardFormatAvailable","UInt",1))
			Gbuffer:=Clipboard
		Clipboard:=ClipSaved
		OnClipboardChange("ClipChanged", 1)
	}
	If Trim(Gbuffer," `t`r`n"){
		t:=srf_mode, SetYzLogo(srf_mode:=0, 0)
		Gosub srf_value_off
		Menu, selectmenu, Delete
		arr:=[]
		If (Gbuffer~="\d+")
			arr:=mathmode(Gbuffer)
		If (arr=""||arr.Length()=0){
			_:=RegExReplace(Gbuffer, "[\x00-\xff]")
			If (_){
				_:=Func("ShowNotes").Bind(_)
				Menu, selectmenu, Add, 注解(&A), %_%
			}
			Menu, selectmenu, Add, 搜索(&S), :soso_select
			Menu, selectmenu, Add, 翻译(&F), :fanyi_select
			Menu, selectmenu, Add, 编码(&C), :Encoding
			Menu, selectmenu, Show
		} Else {
			Try Menu, mathmode, Delete
			Loop % arr.Length()
				Menu, mathmode, Add, % arr[A_Index,1] " (&" Chr(A_Index+64) ")", mathmode_
			Menu, selectmenu, Add, 数值(&M), :mathmode
			Menu, selectmenu, Add, 编码(&C), :Encoding
			Menu, selectmenu, Show
		}
		SetYzLogo(srf_mode:=t, 0)
	}
	Return
	mathmode_:
		SendInput(RegExReplace(A_ThisMenuItem,"i) ?\(&[a-z]\)$"), "{Fast}")
	Return
	selectmenu_:
		%A_ThisMenu%(Paramslist[RegExReplace(A_ThisMenuItem,"i) ?\(&[a-z]\)$")],Gbuffer), Gbuffer:=""
	Return
	Plugin_:
		PluginCall(Paramslist[RegExReplace(A_ThisMenuItem,"i) ?\(&[a-z]\)$")] "(" Gbuffer ")"), Gbuffer:=""
	Return
	Func_:
		tFunc:=Paramslist[RegExReplace(A_ThisMenuItem,"i) ?\(&[a-z]\)$")], SendInput(t:=%tFunc%(Gbuffer), "{Fast}")
		OnClipboardChange("ClipChanged", 0), Clipboard:=t, OnClipboardChange("ClipChanged", 1), Gbuffer:=""
	Return
}
Last_input(n:=""){
	global srf_last_input
	If (n="")
		Return srf_last_input[2, 2]
	res:=""
	Loop %n%
		res.=srf_last_input[2, 2]
	SendInput(res)
	Return [{0:"{off}"}]
}

GetClipSize(){
	hObj:=DllCall( "OpenClipboard", "Ptr", 0 )
	hMem:=DllCall( "GetClipboardData", "Uint", 13 )
	hObj:=DllCall( "GlobalLock", "Ptr", hMem )
	size:=DllCall( "GlobalSize", "Ptr", hMem )
	DllCall( "GlobalUnlock", "Ptr", hMem )
	DllCall( "CloseClipboard" )
	Return size
}
Cliphistory(s:=0){
	local
	global DB
	If (s="+"){
		size:=GetClipSize()
		If (size=0||size>4194304)	; 0-4MB
			Return
		If (!DB.Exec("INSERT INTO 'extend'.'Cliphistory' VALUES('" t:=StrReplace(Clipboard, "'", "''") "');"))
			DB.Exec("CREATE TABLE IF NOT EXISTS 'extend'.'Cliphistory' ('value' TEXT);"), DB.Exec("INSERT INTO 'extend'.'Cliphistory' VALUES('" t "');")
	} Else If (s=0){
		DB.GetTable("SELECT DISTINCT value FROM 'extend'.'Cliphistory' ORDER BY ROWID DESC", result)
		Loop % result.RowCount {
			result.Rows[A_Index,0]:="{Fast}"
			If StrLen(LTrim(result.Rows[A_Index,1]," `r`n`t"))>60
				result.Rows[A_Index,3]:=SubStr(LTrim(result.Rows[A_Index,1]," `r`n`t"),1,60) "……"
			Else
				result.Rows[A_Index,3]:=LTrim(result.Rows[A_Index,1]," `r`n`t")
			result.Rows[A_Index,3]:=StrReplace(StrReplace(StrReplace(result.Rows[A_Index,3],"`t","``t"),"`n","``n"),"`r","``r")
		}
		result.Rows[0]:="Cliphistory"
		Return result.RowCount?result.Rows:[{0:"{Value}",3:"无剪贴板记录"}]
	} Else If (s="c"){
		DB.Exec("DELETE FROM 'extend'.'Cliphistory'")
		Return [{0:"{Off}"}]
	} Else If (s~="^\d+$"){
		DB.GetTable("SELECT DISTINCT value FROM 'extend'.'Cliphistory' ORDER BY ROWID DESC LIMIT " (s-1) ",1", result)
		If (result.Rows[1,1])
			SendInput(result.Rows[1,1], "{Fast}")
	} Else If (s~="^-\d+"){
		DB.Exec("DELETE FROM 'extend'.'Cliphistory' WHERE value=(SELECT DISTINCT value FROM 'extend'.'Cliphistory' ORDER BY ROWID DESC LIMIT " (s-1) ",1)")
		Return [{0:"{Off}"}]
	} Else
		Return [{0:"{Func}",1:"Cliphistory(c)",3:"清空剪贴板纪录"}]
}
qrcode(string:=""){		; 二维码生成
	static str
	If (string=""){
		ClipSaved:=ClipboardAll
		Clipboard:=""
		SendInput, {RShift Down}{Insert}{RShift Up}
		ClipWait, 0.5
		str:=Clipboard, Clipboard:=ClipSaved
	} Else
		str:=string
	SetTimer, makeqrcode, -10
	Return
	makeqrcode:
	If (str=""){
		InputBox, str, 输入文本, , , , 100
		If (ErrorLevel)
			Return
	}
	picHeight:=Max(300,Min(A_ScreenHeight-200,StrLen(str)+100))
	Gui, qrcode:Destroy
	Gui, qrcode:-DPIScale
	Gui, qrcode:Margin , 0, 0
	If (A_PtrSize=4)
		DllCall("Lib\Dll_x86\quricol32.dll\GeneratePNG","str", sFile:=A_Temp "\" A_NowUTC ".png", "str", str, "int", 5, "int", 5, "int", 0)
	Else
		DllCall("Lib\Dll_x64\quricol64.dll\GeneratePNG","str", sFile:=A_Temp "\" A_NowUTC ".png", "str", str, "int", 5, "int", 5, "int", 0)
	Gui, qrcode:Add,Picture, h%picHeight% w-1 gSaveAs, % sFile
	Gui, qrcode:Show, ,点击保存图片 Esc关闭
	str:=""
	Return
	SaveAs:
		Fileselectfile,nf,s16,,另存为,PNG图片(*.png)
		If !StrLen(nf)
			Return
		nf := RegExMatch(nf,"i)\.png") ? nf : nf ".png"
		FileMove,%sFile%,%nf%,1
		Gui, qrcode:Destroy
	Return
	qrcodeGuiEscape:
	qrcodeGuiClose:
		Gui, qrcode:Destroy
		FileDelete, %sFile%
	Return
}
; 简体转繁体
simp2trad(str){
	local
	static STPhrases, phrases_index
	global Traditional, Yzimeini, valueindex, DataPath
	If !IsObject(phrases_index){
		STPhrases:={}, STPhrases:={}, phrases_index:={}
		If FileExist(DataPath "@s2t.txt"){
			Mabiao:=FileRead(DataPath "@s2t.txt")
			Loop, Parse, Mabiao, `n, `r
				If (A_LoopField!="")
					STPhrases[(tarr:=StrSplit(A_LoopField, ["=","`t"]))[1]]:=tarr[2]
		} Else {
			Traditional:=Yzimeini["Settings","Traditional"]:=0, valueindex:=2, phrases_index:=""
			MsgBox, 16, 错误, Data目录下缺少简繁体转换字符集@s2t.txt，转换失败！
			Return
		}
		For key,value in STPhrases
			phrases_index[SubStr(key, 1, 1)] .= "," key
	}
	result:="",word:="",wordnum:=0
	If (StrLen(str)=1)
		Return StrReplace(STPhrases[str]?STPhrases[str]:str, " ", Chr(2))

	Loop, Parse, str
	{
		If (A_LoopField<=Chr(0xff)){
			If wordnum {
				If STPhrases[word]
					result .= STPhrases[word]
				Else
					Loop, Parse, word
						result .= STPhrases[A_LoopField]?SubStr(STPhrases[A_LoopField],1,1):A_LoopField
				word:="", wordnum:=0, result .= A_LoopField
			} Else
				result .= A_LoopField
			Continue
		}
		If !wordnum {
			wordnum+=1
			word .= A_LoopField
		} Else If InStr(phrases_index[SubStr(word, 1, 1)], word A_LoopField) {
			word .= A_LoopField, wordnum+=1
		} Else If (wordnum=1) {
			result .= STPhrases[word]?SubStr(STPhrases[word],1,1):word, word:=A_LoopField, wordnum:=1
		} Else {
			If STPhrases[word]
					result .= STPhrases[word]
			Else
				Loop, Parse, word
					result .= STPhrases[A_LoopField]?SubStr(STPhrases[A_LoopField],1,1):A_LoopField
			word:=A_LoopField, wordnum:=1
		}
	}
	If wordnum
		If STPhrases[word]
			result .= STPhrases[word]
		Else
			Loop, Parse, word
				result .= STPhrases[A_LoopField]?SubStr(STPhrases[A_LoopField],1,1):A_LoopField
	Return StrReplace(result, " ", Chr(2))
}
; 云输入
BDCloudInput(input){
	global srf_Plugins, CloudInput, YzimePID
	static init:=0
	Critical Off
	If (!init)
		Gui, globalvar:Add, Text, Hwndinit
	GuiControl,globalvar:, %init%, % input
	DetectHiddenWindows, on
	If (srf_Plugins["CloudInput",1]=""){
		Try {
			Run, "%AhkPath%" "%A_ScriptDir%\Lib\tools\CloudInput.ahk" %YzimePID%, , , tPID
			WinWait, % "ahk_pid" tPID, , 2
			srf_Plugins["CloudInput",1]:=tPID
		} Catch
			CloudInput:=0
	} Else {
		Process, Exist, % srf_Plugins["CloudInput",1]
		If (!ErrorLevel){
			Run, "%AhkPath%" "%A_ScriptDir%\Lib\tools\CloudInput.ahk" %YzimePID%, , , tPID
			WinWait, % "ahk_pid" tPID, , 2
			srf_Plugins["CloudInput",1]:=tPID
		}
	}
	If (ErrorLevel=srf_Plugins["CloudInput",1])||(ErrorLevel=0)
		PostMessage, 10000, %YzimePID%, %init%, , % "ahk_class AutoHotkey ahk_pid" srf_Plugins["CloudInput",1]
}
; 加载配置
LoadIni(){
	global
	local Key, Value, Section, element, delini:=[]
	For Section, element In srf_default_value
		For Key, Value In element
			If ((%Key%:=Yzimeini[Section, Key])="")
				%Key%:=Yzimeini[Section, Key]:=Value

	; 删除无效配置
	For Section,element In Yzimeini
		If !srf_default_value.HasKey(Section){
			If (Section!="Hidden")
				delini[Section]:=""
		} Else
			For Key, Value In element
				If !srf_default_value[Section].HasKey(Key)
					delini[Section,Key]:=""
	For Section,element In delini
		If (element="")
			Yzimeini.DeleteSection(Section)
		Else If (Section!="Version")
			For Key In element
				Yzimeini.RemoveKey(Section, Key)
	delini:=""
}
RunAhkFile(path){
	Run, % """" StrReplace(AhkPath,"_UIA.exe",".exe") """ """ path """", %A_ScriptDir%
}
; 执行脚本
ExecScript(Script, Name:="", Params:="", workingdir:="") {
	Pipe:=[], Name:=Name?Name:"YZ_AHK_" . A_TickCount
	, workingdir:=workingdir?workingdir:A_ScriptDir
	If (A_IsCompiled&&!FileExist(StrReplace(AhkPath, "_UIA.exe", ".exe"))) {
		If FileExist(A_AhkPath)&&(A_AhkVersion>"1.1.30"){
			FileCopy, % StrReplace(A_AhkPath,"AutoHotkey.exe","AutoHotkeyU32.exe"), % StrReplace(AhkPath, "_UIA.exe", ".exe")
		} Else {
			MsgBox, 20, 错误, 主目录下缺少AutoHotkey.exe或版本太低 ;，是否下载？
			; IfMsgBox, Yes
			; {
			; 	If !UrlDownloadToFile("https://autohotkey.oss-cn-qingdao.aliyuncs.com/AutoAHKScript/Scripts/yz/Lib/AutoHotkey.exe", "Yzime.exe"){
			; 		MsgBox, 16, 错误, 下载AutoHotkey.exe失败！`n请手动下载后放在主目录下。
			; 		Return
			; 	}
			; } Else
				Return
		}
	}
	filepath:=A_Temp "\Yzime\Script\" Name
	If FileExist(filepath)
		FileDelete, % filepath
	If !InStr(FileExist(A_Temp "\Yzime\Script"), "D")
		FileCreateDir, % A_Temp "\Yzime\Script"
	FileAppend, % Script, % filepath, UTF-8
	Run, % """" StrReplace(AhkPath,"_UIA.exe",".exe") """ """ filepath """ " Params, %workingdir%, , pid
	Return pid
}
CreateGUID(){
	VarSetCapacity(pguid, 16, 0)
	If !(DllCall("ole32.dll\CoCreateGuid", "Ptr", &pguid)) {
		size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
		If (DllCall("ole32.dll\StringFromGUID2", "Ptr", &pguid, "Ptr", &sguid, "Int", size))
			Return StrGet(&sguid)
	}
	Return ""
}
; BASE64转Bitmap
Gdip_BitmapFromBase64(ByRef Base64){
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	; calculate the length of the buffer needed
	If !(DllCall("crypt32\CryptStringToBinary", Ptr, &Base64, "UInt", 0, "UInt", 0x01, Ptr, 0, "UIntP", DecLen:=0, Ptr, 0, Ptr, 0))
		return -1
	VarSetCapacity(Dec, DecLen, 0)
	; decode the Base64 encoded string
	If !(DllCall("crypt32\CryptStringToBinary", Ptr, &Base64, "UInt", 0, "UInt", 0x01, Ptr, &Dec, "UIntP", DecLen, Ptr, 0, Ptr, 0))
		return -2
	; create a memory stream
	If !(pStream := DllCall("shlwapi\SHCreateMemStream", Ptr, &Dec, "UInt", DecLen, "UPtr"))
		return -3
	DllCall("gdiplus\GdipCreateBitmapFromStreamICM", Ptr, pStream, "PtrP", pBitmap:=0)
	DllCall("DeleteObject", "Ptr", pStream)
	return pBitmap
}
; 复制对象
CopyObj(obj){
	If !IsObject(obj){
		retObj:=obj
	} Else {
		retObj := {}
		For k, v In obj
			retObj[k] := CopyObj(v)
	}
	Return retObj
}
; symbol函数
Get_symbol(DB,str){
	local
	_SQL:="SELECT value FROM 'extend'.'symbol' WHERE key='" str "' ORDER BY key,comment+0 desc"
	If DB.GetTable(_SQL, Result){
		If (Result.RowCount){
			Loop % Result.RowCount
				Result.Rows[A_Index, 0]:="symbol|-1"
			Return Result.Rows
		} Else {
			DB.GetTable(_SQL:="SELECT value FROM 'extend'.'symbol' WHERE key>='" str "' AND key<'" SubStr(str, 1, -1) Chr(Ord(SubStr(str, 0))+1) "' ORDER BY key,comment+0 desc", Result)
			If (Result.RowCount){
				Loop % Result.RowCount
					Result.Rows[A_Index, 0]:="symbol|-1"
				Return Result.Rows
			}
		}
	}
	Return []
}
FindNotesDict(ByRef char, ByRef dict){
	t:=dict[char]
	Return (t ? " 「" t "」": "")
}
ShowNotes(str:=0){
	local
	global jichu_for_select_Array, ListNum, waitnum, srf_for_select, srf_for_select_obj, srf_direction, DataPath
		, valueindex, srf_inputing, srf_for_select, ToolTipStyle, Lockedposition, Caret, ToolTipText, TextFont, Inputscheme
	static dict:="", last:=""
	If (last!=Inputscheme){
		dict:=[], last:=Inputscheme
		If !FileExist(path:=DataPath "@notes_" Inputscheme ".txt")
			path:=DataPath "@notes.txt"
		If FileExist(path){
			buf:=FileRead(path)
			dict:=[]
			Loop, Parse, buf, `n, `r
				If (A_LoopField!="")
					dict[(tarr:=StrSplit(A_LoopField, "`t"))[1]]:=tarr[2]
		} Else {
			MsgBox, 16, 错误, Data目录下缺少注解文件@notes.txt！
		}
	}
	If (dict.Count()=0)
		Return
	_:=(Textdirection="Horizontal"?"  ":"`n"), hasnote:=False
	If (!str && srf_inputing){
		Loop % Min(jichu_for_select_Array.Length()-ListNum*waitnum, ListNum)
			If (t:=FindNotesDict(jichu_for_select_Array[ListNum*waitnum+A_Index, valueindex], dict))
				srf_for_select_obj[A_Index]:=Mod(A_Index,10) "." jichu_for_select_Array[ListNum*waitnum+A_Index, valueindex] t
				, hasnote:=True
		Loop % srf_for_select_obj.Length()
			srf_for_select .= _ srf_for_select_obj[A_Index]
		Loop % srf_for_select_obj[0].Length()
			srf_for_select .= "`n" srf_for_select_obj[0, A_Index]
		srf_for_select := LTrim(srf_for_select, "`n")
	} Else {
		If (str){
			index:=1, tarr:=[], srf_for_select:="", srf_for_select_obj:=[], ToolTipText:="注解"
			While index:=RegExMatch(str, "O)[^\x00-\xff]", match, index)
				tarr.Push(match.Value), index+=match.Len
			Loop % tarr.Length(){
				t:=FindNotesDict(tarr[A_Index], dict)
				If (t="")
					Continue
				Index:=srf_for_select_obj.Push(tarr[A_Index] " " t)
				srf_for_select .= "`n" srf_for_select_obj[Index]
				hasnote:=True
			}
			srf_for_select:=LTrim(srf_for_select, "`n")
			Caret:=GetCaretPos()
		} Else
			Return
	}
	If (ToolTipStyle=1){
		If (Lockedposition){
			ToolTip(1, ToolTipText "`n" srf_for_select, "x" Caret.x " y" Caret.Y+Caret.H)
		} Else {
			ToolTip(1, ToolTipText "`n" srf_for_select, "x" Caret.x " y" Caret.Y+Caret.H)
		}
	} Else If (hasnote)
		DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction:=1, TextFont)
		; DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction := srf_inputing ? srf_direction : 1, TextFont)
	; Begininput()
	srf_inputing:=1, hasCaretPos:=0
}
; 获取光标坐标
GetCaretPos(Byacc:=1){
	Static init:=0
	Hwnd:=0
	If (A_CaretX=""){
		Caretx:=Carety:=CaretH:=CaretW:=0
		If (Byacc){
			If (!init && !(init:=DllCall("GetModuleHandle", "Str", "oleacc", "Ptr")))
				init:=DllCall("LoadLibrary","Str","oleacc","Ptr")
			VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8, pacc:=0
			, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
			, NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
			If (DllCall("oleacc\AccessibleObjectFromWindow", "Ptr",Hwnd:=WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0){
				Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
				Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
				, CaretX:=NumGet(x,0,"int"), CaretY:=NumGet(y,0,"int"), CaretH:=NumGet(h,0,"int")
			}
		}
		If (Caretx=0&&Carety=0){
			MouseGetPos, x, y, Hwnd
			Return {x:x,y:y,h:30,t:"Mouse",Hwnd:Hwnd}
		} Else
			Return {x:Caretx,y:Carety,h:Max(Careth,30),t:"Acc",Hwnd:Hwnd}
	} Else
		Return {x:A_CaretX,y:A_CaretY,h:30,t:"Caret",Hwnd:Hwnd}
}

OutputDebug(info,type){
	static buffer:=""
	Switch type
	{
		Case 1:
			FormatTime, Now, , [yyyy-MM-dd HH:mm:ss]
			FileAppend, % Now "`n" info "`n", debug.log, UTF-8
		Case 2:
			OutputDebug % info
		Case 3:
			MsgBox, 16, 错误, % StrReplace(info, "|", "`n")
		Case 4:
			buffer .= info "    "
			SetTimer, writeintolog, -1000
		Default:
			Return
	}
	Return
	writeintolog:
		FormatTime, Now, , [yyyy-MM-dd HH:mm:ss]
		FileAppend, % Now "`n" buffer "`n", debug.log, UTF-8
		; OutputDebug % buffer
		buffer:=""
	Return
}

StrDeref(str){
	Try {
		Transform, _var, Deref, %str%
		Return _var
	} Catch
		Return str
}

PluginCall(str){
	local
	global srf_Plugins
	If !RegExMatch(str, "O)^(.+\|)?([^\(\)]+?)(\((.*)\))?$", Match)
		Return
	ComObjError(1)
	Plugin:=(Plugin:=Trim(Match.Value[1], "|"))?Plugin:"YzPlugins", FuncName:=Match.Value[2], Params:=[]
	Loop, Parse, % Match.Value[4], CSV, %A_Space%%A_Tab%
		Params.Push(StrDeref(A_LoopField))
	Try Return ComObjActive(srf_Plugins[Plugin, 2])[FuncName](Params*)
	Catch {
		If !FileExist(PluginPath:="Plugins\" Plugin ".ahk")&&!FileExist(PluginPath:="Plugins\" Plugin "\" Plugin ".ahk"){
			MsgBox, 16, 错误, 插件不存在或已禁用！
			Return
		}
		WinWait, % "ahk_pid" RunPlugins(A_ScriptDir "\" PluginPath), , 2
		Try Return ComObjActive(srf_Plugins[Plugin, 2])[FuncName](Params*)
		Catch
			MsgBox, 16, 错误, 插件启动失败！
	}
}

RunPlugins(PluginPath){
	global srf_Plugins, YzimePID, AhkPath
	SplitPath, PluginPath, , PluginDir, , Plugin
	Run % """" AhkPath """ """ PluginPath """ " YzimePID " " (srf_Plugins[Plugin,2]:=CreateGUID()), %A_ScriptDir%, , PID
	srf_Plugins[Plugin,1]:=PID
	Return PID
}
MCode(mcode) {
	static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
	if (!RegExMatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m))
		return
	if (!DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", 0, "uint*", s, "ptr", 0, "ptr", 0))
		return
	p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
	if (c="x64")
		DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", op)
	if (DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
		return p
	DllCall("GlobalFree", "ptr", p)
}
class CloudinputApi
{
	static req:="", py:="", flag:=0, req2:=""
	static api:="http://olime.baidu.com/py?input={1}&inputtype=py&bg=0&ed=20&result=hanzi&resultcoding=utf-8&ch_en=0&clientinfo=web&version=1"
	
	get(str){
		static cb:=0, oldOS:=!(A_OSVersion~="WIN_8|10\.")
		If (this.flag) 
			this.flag:=0, this.req.abort()
		If (oldOS){
			If (this.req="")
				this.req:=ComObjCreate("WinHttp.WinHttpRequest.5.1"), cb:=ObjBindMethod(this, "BDcallback", 1)
			SetTimer % cb, Off
			try If (str){
				ComObjError(False), this.req.open("GET", Format(this.api, this.py:=str), true)
				this.flag:=1, this.req.send()
				SetTimer % cb, 50
			}
			Return
		} Else {
			If (this.req="")
				this.req:=ComObjCreate("Msxml2.XMLHTTP"), this.req.onreadystatechange:=ObjBindMethod(this, "BDcallback")
			try If (str){
				ComObjError(False)
				this.req.open("GET", Format(this.api, this.py:=str), true)
				this.flag:=1, this.req.send()
			}
		}
	}

/*
	ggget(close:=False){
		static req:="", flag:=0, cb:=0
		if (this.req2="")
			this.req2:=ComObjCreate("WinHttp.WinHttpRequest.5.1"), cb:=ObjBindMethod(this, "ggcallback")
		js:=JScript()
		If (flag)
			flag:=0, req.abort()
		If (close){
			SetTimer % cb, Off
			Return
		}
		url:=js.("ggurl()"), data:=js.("ggdata(""" this.py """,'zh-CN','zh-CN')")
		this.req2.open("POST", url, true)
		this.req2.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
		this.req2.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
		flag:=1, this.req2.send(data)
		SetTimer % cb, 50
	}
	ggcallback(){
		global
		local obj, tarr, ci, py, k, v, m
		static yb:={a:"[āáǎà]",o:"[ōóǒò]",e:"[êēéěè]",i:"[īíǐì]",u:"[ūúǔù]",v:"[ǖǘǚǜü]"}
		try If (this.req2.status = 200){
			SetTimer, , Off
			If (srf_all_Input_["py"] == this.py){
				data := SubStr(this.req2.ResponseText, 7), RegExMatch(data, "\d+", len)
				data:=SubStr(data, StrLen(len)+2, len-2), js := JScript()
				data := js.("(" data ")")[0][2]
				obj := JSON.Load(data)
				ci := "", py := Format("{:L}", obj[2][5][1])
				if (tarr := obj[2][1][1][6]) {
					for k, v in tarr
						If IsObject(v)
							ci .= v[1]
				} else
					ci := jsondata[2][1][1][1]
				k := RegExReplace(this.py, "(\w+)", "($1)")
				k := RegExReplace(k, "([zsc])h?", "$1h?")
				k := RegExReplace(k, "([aoie]n)g?", "$1g?")
				k := RegExReplace(k, "\)('|$)", "[a-z]*) ?")
				If RegExMatch(py, "O)^" k "$", m){
					py := ""
					loop % m.Count
						py .= m[A_Index] "'"
					py := RTrim(py, "'")
				} Else py := this.py
				If (obj&&!qucongtable[ci]){
					tarr:=[py, ci]
					If (Traditional)
						tarr[5]:=StrSplit(simp2trad(ci), Chr(2))[1]
					Loop % ListNum-1
						If (jichu_for_select_Array[A_Index+1, 0]="<Cloud>|-1"){
							If (jichu_for_select_Array[A_Index+1, 2])
								Return
							jichu_for_select_Array[A_Index+1, 1]:=tarr[1], jichu_for_select_Array[A_Index+1, 2]:=tarr[2], jichu_for_select_Array[A_Index+1, 5]:=tarr[5], tarr:=""
							Settimer srf_tooltip_fanye, -1
							Return
						}
					tarr[0]:="<Cloud>|-1", jichu_for_select_Array.InsertAt(2, tarr)
					Settimer srf_tooltip_fanye, -1
				}
			}
		} Else If (srf_all_input = "" || this.req2.status)
			SetTimer, , Off
	}
*/

	BDcallback(isTimer := 0){
		global
		local obj, tarr
		static last:=""
		try If (this.req.status = 200){
			If (isTimer)
				SetTimer, , Off
			If (srf_all_Input_["py"] == this.py){
				obj:=JScript().("(" this.req.ResponseText ")"), obj:=obj["result"][0][0]
				If (obj[0]&&!qucongtable[obj[0]]){
					tarr:=[obj[2]["pinyin"], obj[0]]
					If (Traditional)
						tarr[5]:=StrSplit(simp2trad(obj[0]), Chr(2))[1]
					Loop % ListNum-1
						If (jichu_for_select_Array[A_Index+1, 0]="<Cloud>|-1"){
							jichu_for_select_Array[A_Index+1, 1]:=tarr[1], jichu_for_select_Array[A_Index+1, 2]:=tarr[2], jichu_for_select_Array[A_Index+1, 5]:=tarr[5], tarr:=""
							Settimer srf_tooltip_fanye, -1
							Return
						}
					tarr[0]:="<Cloud>|-1", jichu_for_select_Array.InsertAt(2, tarr)
					Settimer srf_tooltip_fanye, -1
				}
			}
		} Else {
			If (srf_all_input = "" || this.req2.status)
				CloudinputApi.get("")
			; If (last!=this.py)
			; 	last:=this.py, CloudinputApi.ggget()
		}
	}
}
getJSscript() {
	html := SendRequest("https://translate.google.cn")
	RegExMatch(html, "O)""FdrFJe"":""(.*?)""", m), sid := m[1]
	RegExMatch(html, "O)""cfb2h"":""(.*?)""", m), bl := m[1]
	
	Script=
	(LTrim
		function ggurl() {
			return "https://translate.google.cn/_/TranslateWebserverUi/data/batchexecute?rpcids=MkEWBc&f.sid=%sid%&bl=%bl%&hl=en-US&soc-app=1&soc-platform=1&soc-device=1&_reqid=" + Math.floor(1000 + (Math.random() * 9000)) + "&rt=c";
		}
		function ggdata(text, from, to) {
			return 'f.req=' + encodeURIComponent(JSON.stringify([[['MkEWBc', JSON.stringify([[text, from, to, true], [null]]), null, 'generic']]])) + '&';
		}
	)
	Script .= "function eval2(str){var num=eval(str);return num.toString()};function jiecheng(num){var result=1;if (num%1!=0){return};for(var i=1;i<=num;i++){result*=i;}return result;}"
	Return Script
}
TranslateApi(ApiType,KeyWord,to:="auto",from:="auto",proxy:=""){
	Critical, Off
	js:=JScript()
	
	If (KeyWord="")
		Return
	ComObjError(0)
	KeyWord:=StrReplace(StrReplace(StrReplace(StrReplace(KeyWord,"\","\\"),"'","\'"), "`n", "\n"), "`r", "\r")
	Switch ApiType
	{
		Case "youdao":
			url:="http://fanyi.youdao.com/fanyiapi.do?keyfrom=qqqqqqqq123&key=86514254&type=data&doctype=json&version=1.1"
			jsondata:=SendRequest(url, "POST", "q=" js.("encodeURIComponent('" KeyWord "')")), obj:=js.("(" jsondata ")")
			trans:=obj["translation"][0]
			if IsObject(obj["basic"]["explains"])
				Loop % obj["basic"]["explains"].length
					trans .= "`n" obj["basic"]["explains"][A_Index-1]
			if (trans=""&&StrLen(KeyWord)>200)
				Return "要翻译的文本过长！"
		Case "google":
			; to:=from:="zh-CN"
			to:=(to="auto"?(KeyWord~="[\x{4e00}-\x{9fff}]"?"en":"zh-CN"):to), from:=(from="auto"?(to="en"?"zh-CN":"en"):from)
			url:=js.("ggurl()"), data:=js.("ggdata('" KeyWord "','" from "','" to "')")
			jsondata:=SendRequest(url, "POST", data), jsondata := SubStr(jsondata, 7), RegExMatch(jsondata, "\d+", len)
			jsondata:=SubStr(jsondata, StrLen(len)+2, len-2)
			jsondata := js.("(" js.("(" jsondata ")")[0][2] ")"), trans := ""
			if (obj := jsondata[1][0][0][5]) {
				Loop % obj.length
					if IsObject(a := obj[A_Index-1])
						trans .= a[0]
			} else
				trans := jsondata[1][0][0][0]
	}
	Return trans
}
; WM_COPYDATA进程间通信
Receive_WM_COPYDATA(wParam, lParam){
	global
	local StringAddress, MatchStr, MatchStr1, MatchStr2, tarr, CopyOfData
	StringAddress := NumGet(lParam + 2*A_PtrSize)  ; 获取 CopyDataStruct 的 lpData 成员.
	CopyOfData := StrGet(StringAddress)  ; 从结构中复制字符串.
	If RegExMatch(CopyOfData, "^<<([^ ]+)>>(.*)$", MatchStr){
		%MatchStr1%:=MatchStr2, CopyOfData:=""
		If (MatchStr1="CloudResult"&&!InStr(srf_all_input,func_key)){
			tarr:=StrSplit(MatchStr2,"`n")
			If (tarr[2]&&!qucongtable[tarr[2]]&&StrReplace(srf_all_Input_["py"],"\")=tarr[3]){
				tarr[0]:="<Cloud>|-1", tarr[3]:=""
				Loop % ListNum-1
					If (jichu_for_select_Array[A_Index+1, 0]="<Cloud>|-1"){
						jichu_for_select_Array[A_Index+1, 1]:=tarr[1], jichu_for_select_Array[A_Index+1, 2]:=tarr[2], tarr:=""
						Break
					}
				If IsObject(tarr)
					jichu_for_select_Array.InsertAt(2,tarr)
				Gosub houchuli
				Gosub srf_tooltip_fanye
			} Else If (tarr[3]="timeout"){
				Loop % ListNum-1
					If (jichu_for_select_Array[A_Index+1, 0]="<Cloud>|-1"){
						jichu_for_select_Array[A_Index+1, 2]:="获取失败！", tarr:=A_Index+1
						Break
					}
				Gosub srf_tooltip_fanye
				jichu_for_select_Array[tarr, 2]:=""
			}
		}
	}
	Return true  ; 返回 1 (true) 是回复此消息的传统方式.
}

Send_WM_COPYDATA(ByRef StringToSend, TargetScriptTitle, dwData:=0, wParam:=0){  ; 在这种情况中使用 ByRef 能节约一些内存.
	global YzimePID
	VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; 分配结构的内存区域.
	; 首先设置结构的 cbData 成员为字符串的大小, 包括它的零终止符:
	SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
	NumPut(dwData, CopyDataStruct, 0)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
	NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; 设置 lpData 为到字符串自身的指针.
	; Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	; DetectHiddenWindows On
	SetTitleMatchMode 2
	wParam:=wParam?wParam:YzimePID
	; 必须使用发送 SendMessage 而不是投递 PostMessage.
	SendMessage, 0x4a, %wParam%, &CopyDataStruct,, %TargetScriptTitle%  ; 0x4a 为 WM_COPYDAT
	; DetectHiddenWindows %Prev_DetectHiddenWindows%  ; 恢复调用者原来的设置.
	SetTitleMatchMode %Prev_TitleMatchMode%         ; 同样.
	Return ErrorLevel  ; 返回 SendMessage 的回复给我们的调用者.
}
MemInfo(){
	TSFMem.GetInfo()
}
Switchcomposing(){
	NumPut(t:=!TSFMem.Get(10, "UShort"), TSFMem._buf+0, 10, "UShort")
	ToolTip % "写作状态：" (t?"开":"关")
	SetTimer, ToolTipOff, -1000
}
class MemMap
{
	__New(name, dwsize:=4194304){
		this._name:=name, this._dwsize:=dwsize, this._headsize:=20
		this._hMap:=DllCall("CreateFileMapping", "Ptr", -1, "Ptr", 0, "UInt", 0x04, "UInt", 0, "UInt", dwsize+this._headsize, "Str", name)
		If (!this._hMap)
			Return
		this._buf:=DllCall("MapViewOfFile", "Ptr", this._hMap, "UInt", 0x06, "UInt", 0, "UInt", 0, "UInt", 0)
		If (!this._buf){
			DllCall("CloseHandle", "Ptr", this._hMap)
			Return
		}
		this.SetOwner(A_ScriptHwnd), NumPut(0, this._buf+0, 8, "UShort"), NumPut(1, this._buf+0, 10, "UShort")
		VarSetCapacity(MEMORY_BASIC_INFORMATION, 5*A_PtrSize+8, 0)
		If DllCall("Kernel32.dll\VirtualQuery", "Ptr", this._buf+0, "Ptr", &MEMORY_BASIC_INFORMATION, "UInt", 5*A_PtrSize+8)
			this._dwsize:=NumGet(MEMORY_BASIC_INFORMATION, 3*A_PtrSize, "UInt")-this._headsize-8
	}
	__Delete(){
		If (this._buf)
			this.SetOwner(0), this.SetFlags(0), DllCall("UnmapViewOfFile", "Ptr", this._buf)
		If (this._hMap)
			DllCall("CloseHandle", "Ptr", this._hMap)
	}
	Get(offset, type){
		Return NumGet(this._buf+0, offset, type)
	}
	SetOwner(Hwnd){
		NumPut(Hwnd, this._buf+0, 0, "Int64")
	}
	SetFlags(flags:=0){
		NumPut(flags, this._buf+0, 8, "UShort")
	}
	; SetSize(dwsize){
	; 	NumPut(dwsize, this._buf+0, 12, "UInt")
	; }
	SetString(ByRef str){
		m:=NumGet(this._buf+8, "UShort")
		this.SetFlags(m | 0x8000)
		this._size:=StrLen(str)*2
		If (this._size>this._dwsize){
			this._size:=this._dwsize
			str:=SubStr(str,1,this._size//2)
			StrPut(str, this._buf+this._headsize, "UTF-16")
			TrayTip, 警告, 文本超过长度限制，已截断超出部分！, 1
		} Else
			StrPut(str, this._buf+this._headsize, "UTF-16")
		this.SetFlags(m & 0x7FFF)
	}
	Clear(){
		If (this._size && this._buf)
			StrPut("", this._buf+this._headsize, "UTF-16")
	}
	GetInfo(){
		buf:=this._buf
		hwnd:=Format("{:#x}", NumGet(buf+0, "Int64"))
		ser:=NumGet(buf+8, "UShort")
		cli:=NumGet(buf+10, "UShort")
		x:=NumGet(buf+12, "Int")
		y:=NumGet(buf+16, "Int")
		str:=StrGet(buf+20, "UTF-16")
		ToolTip % "句柄:" hwnd "`n输入状态:" (ser?"开":"关") "`t写作状态:" (cli?"开":"关") "`n插入符 x:" x "`ty:" y "`n缓冲区:" str
		SetTimer ToolTipOff, -2000
	}
}

/****************************************************************************************************************************
 * Lib: JSON.ahk
 *     JSON Lib for AutoHotkey.
 * Version:
 *     v2.1.3 [updated 04/18/2016 (MM/DD/YYYY)]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey (v1.1+ or v2.0-a+)
 * Installation:
 *     Use #Include JSON.ahk or copy into a function Library folder and then
 *     use #Include <JSON>
 * Links:
 *     GitHub:     - https://github.com/cocobelgica/AutoHotkey-JSON
 *     Forum Topic - http://goo.gl/r0zI8t
 *     Email:      - cocobelgica <at> gmail <dot> com
 */


/**
 * Class: JSON
 *     The JSON object contains methods for parsing JSON and converting values
 *     to JSON. Callable - NO; Instantiable - YES; Subclassable - YES;
 *     Nestable(via #Include) - NO.
 * Methods:
 *     Load() - see relevant documentation before method definition header
 *     Dump() - see relevant documentation before method definition header
 */
class JSON
{
	/**
	 * Method: Load
	 *     Parses a JSON string into an AHK value
	 * Syntax:
	 *     value := JSON.Load( text [, reviver ] )
	 * Parameter(s):
	 *     value      [retval] - parsed value
	 *     text    [in, ByRef] - JSON formatted string
	 *     reviver   [in, opt] - function object, similar to JavaScript's
	 *                           JSON.parse() 'reviver' parameter
	 */
	class Load extends JSON.Functor
	{
		Call(self, ByRef text, reviver:="")
		{
			this.rev := IsObject(reviver) ? reviver : false
		; Object keys(and array indices) are temporarily stored in arrays so that
		; we can enumerate them in the order they appear in the document/text instead
		; of alphabetically. Skip If no reviver function is specIfied.
			this.keys := this.rev ? {} : false

			static quot := Chr(34), bashq := "\" . quot
				 , json_value := quot . "{[01234567890-tfn"
				 , json_value_or_array_closing := quot . "{[]01234567890-tfn"
				 , object_key_or_object_closing := quot . "}"

			_key := ""
			is_key := false
			root := {}
			stack := [root]
			next := json_value
			pos := 0

			while ((ch := SubStr(text, ++pos, 1)) != "") {
				If InStr(" `t`r`n", ch)
					continue
				If !InStr(next, ch, 1)
					this.ParseError(next, text, pos)

				holder := stack[1]
				is_array := holder.IsArray

				If InStr(",:", ch) {
					next := (is_key := !is_array && ch == ",") ? quot : json_value

				} Else If InStr("}]", ch) {
					ObjRemoveAt(stack, 1)
					next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"

				} Else {
					If InStr("{[", ch) {
					; Check If Array() is overridden and If its return _value has
					; the 'IsArray' property. If so, Array() will be called normally,
					; otherwise, use a custom base object for arrays
						static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
					
					; sacrIfice readability for minor(actually negligible) performance gain
						(ch == "{")
							? ( is_key := true
							  , _value := {}
							  , next := object_key_or_object_closing )
						; ch == "["
							: ( _value := json_array ? new json_array : []
							  , next := json_value_or_array_closing )
						
						ObjInsertAt(stack, 1, _value)

						If (this.keys)
							this.keys[_value] := []
					
					} Else {
						If (ch == quot) {
							i := pos
							while (i := InStr(text, quot,, i+1)) {
								_value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")

								static tail := A_AhkVersion<"2" ? 0 : -1
								If (SubStr(_value, tail) != "\")
									break
							}

							If (!i)
								this.ParseError("'", text, pos)

							  _value := StrReplace(_value,  "\/",  "/")
							, _value := StrReplace(_value, bashq, quot)
							, _value := StrReplace(_value,  "\b", "`b")
							, _value := StrReplace(_value,  "\f", "`f")
							, _value := StrReplace(_value,  "\n", "`n")
							, _value := StrReplace(_value,  "\r", "`r")
							, _value := StrReplace(_value,  "\t", "`t")

							pos := i ; update pos
							
							i := 0
							while (i := InStr(_value, "\",, i+1)) {
								If !(SubStr(_value, i+1, 1) == "u")
									this.ParseError("\", text, pos - StrLen(SubStr(_value, i+1)))

								uffff := Abs("0x" . SubStr(_value, i+2, 4))
								If (A_IsUnicode || uffff < 0x100)
									_value := SubStr(_value, 1, i-1) . Chr(uffff) . SubStr(_value, i+6)
							}

							If (is_key) {
								_key := _value, next := ":"
								continue
							}
						
						} Else {
							_value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)

							static number := "number", integer :="integer"
							If _value is %number%
							{
								If _value is %integer%
									_value += 0
							}
							Else If (_value == "true" || _value == "false")
								_value := %_value% + 0
							Else If (_value == "null")
								_value := ""
							Else
							; we can do more here to pinpoint the actual culprit
							; but that's just too much extra work.
								this.ParseError(next, text, pos, i)

							pos += i-1
						}

						next := holder==root ? "" : is_array ? ",]" : ",}"
					} ; If InStr("{[", ch) { ... } Else

					is_array? _key := ObjPush(holder, _value) : holder[_key] := _value

					If (this.keys && this.keys.HasKey(holder))
						this.keys[holder].Push(_key)
				}
			
			} ; while ( ... )

			return this.rev ? this.Walk(root, "") : root[""]
		}

		ParseError(expect, ByRef text, pos, len:=1)
		{
			static quot := Chr(34), qurly := quot . "}"
			
			line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
			col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
			msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
			,     (expect == "")     ? "Extra data"
				: (expect == "'")    ? "Unterminated string starting at"
				: (expect == "\")    ? "Invalid \escape"
				: (expect == ":")    ? "Expecting ':' delimiter"
				: (expect == quot)   ? "Expecting object _key enclosed in double quotes"
				: (expect == qurly)  ? "Expecting object _key enclosed in double quotes or object closing '}'"
				: (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
				: (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
				: InStr(expect, "]") ? "Expecting JSON _value or array closing ']'"
				:                      "Expecting JSON _value(string, number, true, false, null, object or array)"
			, line, col, pos)

			static offset := A_AhkVersion<"2" ? -3 : -4
			throw Exception(msg, offset, SubStr(text, pos, len))
		}

		Walk(holder, _key)
		{
			_value := holder[_key]
			If IsObject(_value) {
				for i, k in this.keys[_value] {
					; check If ObjHasKey(_value, k) ??
					v := this.Walk(_value, k)
					If (v != JSON.Undefined)
						_value[k] := v
					Else
						ObjDelete(_value, k)
				}
			}
			
			return this.rev.Call(holder, _key, _value)
		}
	}

	/**
	 * Method: Dump
	 *     Converts an AHK _value into a JSON string
	 * Syntax:
	 *     str := JSON.Dump( _value [, replacer, space ] )
	 * Parameter(s):
	 *     str        [retval] - JSON representation of an AHK _value
	 *     _value          [in] - any _value(object, string, number)
	 *     replacer  [in, opt] - function object, similar to JavaScript's
	 *                           JSON.stringIfy() 'replacer' parameter
	 *     space     [in, opt] - similar to JavaScript's JSON.stringIfy()
	 *                           'space' parameter
	 */
	class Dump extends JSON.Functor
	{
		Call(self, _value, replacer:="", space:="")
		{
			this.rep := IsObject(replacer) ? replacer : ""

			this.gap := ""
			If (space) {
				static integer := "integer"
				If space is %integer%
					Loop, % ((n := Abs(space))>10 ? 10 : n)
						this.gap .= " "
				Else
					this.gap := SubStr(space, 1, 10)

				this.indent := "`n"
			}

			return this.Str({"": _value}, "")
		}

		Str(holder, _key)
		{
			_value := holder[_key]

			If (this.rep)
				_value := this.rep.Call(holder, _key, ObjHasKey(holder, _key) ? _value : JSON.Undefined)

			If IsObject(_value) {
			; Check object type, skip serialization for other object types such as
			; ComObject, Func, BoundFunc, FileObject, RegExMatchObject, Property, etc.
				static type := A_AhkVersion<"2" ? "" : Func("Type")
				If (type ? type.Call(_value) == "Object" : ObjGetCapacity(_value) != "") {
					If (this.gap) {
						stepback := this.indent
						this.indent .= this.gap
					}

					is_array := _value.IsArray
				; Array() is not overridden, rollback to old method of
				; identIfying array-like objects. Due to the use of a for-loop
				; sparse arrays such as '[1,,3]' are detected as objects({}). 
					If (!is_array) {
						for i in _value
							is_array := i == A_Index
						until !is_array
					}

					str := ""
					If (is_array) {
						Loop, % _value.Length() {
							If (this.gap)
								str .= this.indent
							
							v := this.Str(_value, A_Index)
							str .= (v != "") ? v . "," : "null,"
						}
					} Else {
						colon := this.gap ? ": " : ":"
						for k in _value {
							v := this.Str(_value, k)
							If (v != "") {
								If (this.gap)
									str .= this.indent

								str .= this.Quote(k) . colon . v . ","
							}
						}
					}

					If (str != "") {
						str := RTrim(str, ",")
						If (this.gap)
							str .= stepback
					}

					If (this.gap)
						this.indent := stepback

					return is_array ? "[" . str . "]" : "{" . str . "}"
				}
			
			} Else ; is_number ? _value : "_value"
				return ObjGetCapacity([_value], 1)=="" ? _value : this.Quote(_value)
		}

		Quote(string)
		{
			static quot := Chr(34), bashq := "\" . quot

			If (string != "") {
				  string := StrReplace(string,  "\",  "\\")
				; , string := StrReplace(string,  "/",  "\/") ; optional in ECMAScript
				, string := StrReplace(string, quot, bashq)
				, string := StrReplace(string, "`b",  "\b")
				, string := StrReplace(string, "`f",  "\f")
				, string := StrReplace(string, "`n",  "\n")
				, string := StrReplace(string, "`r",  "\r")
				, string := StrReplace(string, "`t",  "\t")

				static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
				; while RegExMatch(string, rx_escapable, m)
				; 	string := StrReplace(string, m._value, Format("\u{1:04x}", Ord(m._value)))
			}

			return quot . string . quot
		}
	}

	/**
	 * Property: Undefined
	 *     Proxy for 'undefined' type
	 * Syntax:
	 *     undefined := JSON.Undefined
	 * Remarks:
	 *     For use with reviver and replacer functions since AutoHotkey does not
	 *     have an 'undefined' type. Returning blank("") or 0 won't work since these
	 *     can't be distnguished from actual JSON values. This leaves us with objects.
	 *     Replacer() - the caller may return a non-serializable AHK objects such as
	 *     ComObject, Func, BoundFunc, FileObject, RegExMatchObject, and Property to
	 *     mimic the behavior of returning 'undefined' in JavaScript but for the sake
	 *     of code readability and convenience, it's better to do 'return JSON.Undefined'.
	 *     Internally, the property returns a ComObject with the variant type of VT_EMPTY.
	 */
	Undefined[]
	{
		get {
			static empty := {}, vt_empty := ComObject(0, &empty, 1)
			return vt_empty
		}
	}

	class Functor
	{
		__Call(method, ByRef arg, args*)
		{
		; When casting to Call(), use a new instance of the "function object"
		; so as to avoid directly storing the properties(used across sub-methods)
		; into the "function object" itself.
			If IsObject(method)
				return (new this).Call(method, arg, args*)
			Else If (method == "")
				return (new this).Call(arg, args*)
		}
	}
}
; ##################################################################################################################################################################
; # 声明：此文件基于开源仓库 <https://gitee.com/orz707/Yzime> (Commit:d1d0d9b15062de7381d1e7649693930c34fca53d) 
; # 中的同名文件修改而来，并使用相同的开源许可 GPL-2.0 进行开源，具体的权利、义务和免责条款可查看根目录下的 LICENSE 文件
; # 修改者：北山愚夫
; # 修改时间：2024年3月15日 
; ##################################################################################################################################################################

; 候选项翻页
MoreWait:
	If (waitnum*ListNum+ListNum<Max(jichu_for_select_Array.Length(),Function_for_select.Length())){
		If (fyfz&&shurulei="pinyin"&&!InStr(srf_all_Input,func_key)&&InStr(fanyefg "PgUp PgDn Tab",A_ThisHotkey))
			dwselect:=(srf_inputing&&tfuzhuma&&jichu_for_select_Array[1,0]~="^pinyin")		
		waitnum+=1, localpos:=1
		Gosub srf_tooltip_fanye
	}
Return
LessWait:
	If (waitnum>0){
		waitnum-=1, localpos:=A_ThisHotkey="Up"?ListNum:1
		Gosub srf_tooltip_fanye
	}
Return

; 查字典功能跳转
srf_tooltip:
	srf_direction:=Textdirection="Horizontal" ? 0 : 1
	If InStr(srf_all_Input, func_key){
		RegExMatch(srf_all_Input, "O)^" (func_key="\"?"\\":func_key) "?([a-zA-Z]+)" (func_key="\"?"\\":func_key), modeMatch)
		If (srf_all_Input_["history"]!=srf_all_Input)
			srf_all_Input_["history"]:=srf_all_Input
		srf_for_select:=srf_all_Input_["tip"]:="", jichu_for_select_Array:=[], hotstring_for_select:=[], srf_for_select_obj:=[]
		Switch srf_FuncSelect(srf_all_Input)
		{
			Case 1:
				Gosub srf_tooltip_fanye
			Case 0:
				Gosub showhouxuankuang
			Case -1:
				Gosub srf_value_off
		}
		Return
	} If Englishmode||(eng_key&&SubStr(srf_all_Input,1,1)==eng_key){
		jichu_for_select_Array:=get_word_lianxiang(DB, LTrim(srf_all_Input_["tip"]:=srf_all_Input,eng_key), "English", , 5), srf_all_Input_["history"]:=srf_all_Input
	} Else {
		If (srf_all_Input_["history"]==srf_all_Input)
			Goto srf_tooltip_fanye
		Else {
			srf_all_Input_["history"]:=srf_all_Input
		}
		Function_for_select:=[]
		If (!dwselect)
			customs_for_select:=get_word(DB, srf_all_Input, "customs")
		; If StrLen(srf_all_Input)>2
		; 	English_for_select:=get_word_lianxiang(DB, srf_all_Input, "English", 2, 0)
		; Else
		; 	English_for_select:=""
		If (customs_for_select[1,3]=0){
			If InStr(customs_for_select[1,0],"Rewrite"){
				srf_all_Input:=customs_for_select[1,2], customs_for_select:=get_word(DB, srf_all_Input, "customs")
			} Else {
				If InStr(customs_for_select[1,0],"Func"){
					customs_for_select[1,2]:=ExeFuncStr(customs_for_select[1,2], 0)
					customs_for_select[1,0]:=StrReplace(customs_for_select[1,0],"{Func}")
				}
				SendInput(customs_for_select[1,2],customs_for_select[1,0]?customs_for_select[1,0]:SendDelaymode)
				Goto srf_value_off
			}
		}
		Result:=%shurulei%method(srf_all_Input, Inputscheme)
		If (Result=0)
			Return
		Else If IsObject(Result){
			jichu_for_select_Array:=Result
			Gosub houchuli
		} Else
			jichu_for_select_Array:=[]

		If (magicstring)
			hotstring_for_select:=get_word_lianxiang(DB, srf_all_Input, "hotstrings")
		If (superrun)
			Function_for_select:=get_word_lianxiang(DB, srf_all_Input, "functions")
	}
	If (Result=-1)&&(!jichu_for_select_Array.Length())
		Goto srf_value_off
	Gosub srf_tooltip_fanye
Return

; 去重 简转繁
houchuli:
	If (Traditional){
		Index:=0
		Loop {
			Index++
			If ((Index>jichu_for_select_Array.Length())||(jichu_for_select_Array[Index,2]=""))
				Break
			If tradstr:=Trim(simp2trad(jichu_for_select_Array[Index,2]), Chr(2)){
				If InStr(tradstr, Chr(2)){
					tradstr:=StrSplit(tradstr, Chr(2))
					tarr:={}
					For key,value In jichu_for_select_Array[Index]
						tarr[key]:=value
					jichu_for_select_Array[Index,5]:=tradstr[1]
					Loop % tradstr.Length()-1
						Index++, jichu_for_select_Array.InsertAt(Index, tarr), jichu_for_select_Array[Index,5]:=tradstr[A_Index+1]
				} Else
					jichu_for_select_Array[Index,5]:=tradstr
			} Else 
				jichu_for_select_Array[Index,5]:=jichu_for_select_Array[Index,2]
		}
	}
	;去重
	Loopindex:=1, qucongtable:={}
	While (Loopindex < jichu_for_select_Array.Length()+1){
		If (qucongtable[jichu_for_select_Array[Loopindex, valueindex]]){
			jichu_for_select_Array.RemoveAt(Loopindex)
			Continue
		} Else If (jichu_for_select_Array[Loopindex, valueindex])
			qucongtable[jichu_for_select_Array[Loopindex, valueindex]]:=Loopindex
		Loopindex++
	}
	Loop % (Loopindex:=customs_for_select.Length()){
		If InStr(customs_for_select[Loopindex-A_Index+1,0],"Func"){
			customs_for_select[Loopindex-A_Index+1,valueindex]:=ExeFuncStr(customs_for_select[Loopindex-A_Index+1,2], 0)
			customs_for_select[Loopindex-A_Index+1,0]:=StrReplace(customs_for_select[Loopindex-A_Index+1,0],"{Func}")
		} Else {
			If qucongtable[customs_for_select[Loopindex-A_Index+1,2]]
				customs_for_select[Loopindex-A_Index+1,1]:=(jichu_for_select_Array.Delete(qucongtable[customs_for_select[Loopindex-A_Index+1,2]]))[1]
		}
	}
	Loop % (Loopindex:=jichu_for_select_Array.Length())
		If (jichu_for_select_Array[Loopindex+1-A_Index]="")
			jichu_for_select_Array.RemoveAt(Loopindex+1-A_Index)
	Loop % (Loopindex:=customs_for_select.Length())
		Try jichu_for_select_Array.InsertAt(Min(Max(customs_for_select[Loopindex-A_Index+1,3]-(Loopindex-A_Index),1),jichu_for_select_Array.Length()+1),customs_for_select[Loopindex-A_Index+1])
	; qucongtable:=""
Return

; 显示前处理
srf_tooltip_fanye:
	srf_for_select:="", srf_for_select_obj:=[]
	If !InStr(srf_all_Input,func_key){
		If srf_all_Input&&(jichu_for_select_Array[1,valueindex]=""){
			jichu_for_select_Array[1,1]:="", jichu_for_select_Array[1,valueindex]:=srf_symbol[srf_all_Input,2-(EnSymbol||Englishmode)]?srf_symbol[srf_all_Input,2-(EnSymbol||Englishmode)]:LTrim(srf_all_Input,"'")
			; If (jichu_for_select_Array[1,valueindex]="/")
			; 	jichu_for_select_Array.InsertAt(1,{2:"、"})
		}
		If (waitnum=0)
			Loop % ListNum-1
				If (jichu_for_select_Array[A_Index+1,0]="<Cloud>|-1")
					jichu_for_select_Array[A_Index+1,valueindex] .= "☁"
		_:=(srf_direction ?"`n":"  ")
		Switch shurulei
		{
			Case "pinyin":
				Loop % Min(jichu_for_select_Array.Length()-ListNum*waitnum, ListNum)
					; Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." jichu_for_select_Array[tvar:=ListNum*waitnum+A_Index, valueindex] (StrLen(jichu_for_select_Array[tvar, -2])<2?" " RegExReplace(jichu_for_select_Array[tvar, 6],"i)" RegExReplace(jichu_for_select_Array[tvar,-2],"(.)","(.*?)?$1"),,,1):""))
					Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." jichu_for_select_Array[tvar:=ListNum*waitnum+A_Index, valueindex] (showFZM?" " jichu_for_select_Array[tvar, 6]:""))
					, srf_for_select .= _ srf_for_select_obj[Index]
			Case "sanma":
				If (ShowCode){
					Loop % Min(jichu_for_select_Array.Length()-ListNum*waitnum, ListNum)
						Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." jichu_for_select_Array[ListNum*waitnum+A_Index, valueindex] (srf_all_Input~=StrReplace(jichu_for_select_Array[ListNum*waitnum+A_Index, 1]," "," ?")?"":jichu_for_select_Array[ListNum*waitnum+A_Index, 1]))
						, srf_for_select .= _ srf_for_select_obj[Index]
				} Else {
					Loop % Min(jichu_for_select_Array.Length()-ListNum*waitnum, ListNum)
						Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." jichu_for_select_Array[ListNum*waitnum+A_Index, valueindex])
						, srf_for_select .= _ srf_for_select_obj[Index]
				}
			Case "lianda":
				Loop % Min(jichu_for_select_Array.Length()-ListNum*waitnum, ListNum)
					Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." jichu_for_select_Array[tvar:=ListNum*waitnum+A_Index, valueindex] (StrLen(jichu_for_select_Array[tvar, -2])<2?" " RegExReplace(jichu_for_select_Array[tvar, 6],"i)" RegExReplace(jichu_for_select_Array[tvar,-2],"(.)","(.*?)?$1"),,,1):""))
					, srf_for_select .= _ srf_for_select_obj[Index]
			Default:
				If (ShowCode||zigen){
					Loop % Min(jichu_for_select_Array.Length()-ListNum*waitnum, ListNum)
						Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." jichu_for_select_Array[ListNum*waitnum+A_Index, valueindex] ((jichu_for_select_Array[ListNum*waitnum+A_Index, 0]~="pinyin|<Cloud>")?pinyinfancha[jichu_for_select_Array[ListNum*waitnum+A_Index, 2]]:InStr(jichu_for_select_Array[ListNum*waitnum+A_Index, 0],Inputscheme "|")&&jichu_for_select_Array[ListNum*waitnum+A_Index, 1]~="^" jichu_for_select_Array[0]?(Trim(var:=RegExReplace(jichu_for_select_Array[ListNum*waitnum+A_Index, 1], "^" jichu_for_select_Array[0], " "))?var:(zigen?xingmazigen(jichu_for_select_Array[ListNum*waitnum+A_Index, 2], Inputscheme):"")):(zigen?xingmazigen(jichu_for_select_Array[ListNum*waitnum+A_Index, 2], Inputscheme):"")))
						, srf_for_select .= _ srf_for_select_obj[Index]
				} Else {
					Loop % Min(jichu_for_select_Array.Length()-ListNum*waitnum, ListNum)
						Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." jichu_for_select_Array[ListNum*waitnum+A_Index, valueindex] (InStr(jichu_for_select_Array[ListNum*waitnum+A_Index, 0],Inputscheme "|")&&jichu_for_select_Array[ListNum*waitnum+A_Index, 1]~="^" jichu_for_select_Array[0]?RegExReplace(jichu_for_select_Array[ListNum*waitnum+A_Index, 1], "^" jichu_for_select_Array[0], " "):""))
						, srf_for_select .= _ srf_for_select_obj[Index]
				}
		}
		If (waitnum=0)
			Loop % ListNum-1
				If (jichu_for_select_Array[A_Index+1,0]="<Cloud>|-1")
					jichu_for_select_Array[A_Index+1,valueindex]:=SubStr(jichu_for_select_Array[A_Index+1,valueindex],1,-1)
		srf_for_select_obj[0]:=[]
		If (hotstring_for_select[1, 1])
			srf_for_select .= "`n(,)" hotstring_for_select[1, 3], srf_for_select_obj[0].Push("(,)" hotstring_for_select[1, 3])
		If (Function_for_select[1, 1])
			srf_for_select .= "`n(.)" Function_for_select[1, 3], srf_for_select_obj[0].Push("(.)" Function_for_select[1, 3])
		If (Inputscheme~="pinyin|sp$")&&(jichu_for_select_Array[1,0]~="^(pinyin|customs)"){
			ToolTipText:=StrReplace(Trim(srf_all_Input_["tip"],"'"), "'\'", " ")
			If (fzm)
				ToolTipText:=RegExReplace(ToolTipText, RegExReplace(fzm,"(.)","'?$1") "$", " " fzm)
			ToolTipText:=insertcaret(ToolTipText,insertpos)
			If (Showquanpin&&Inputscheme!="pinyin"&&!InStr(srf_all_Input,func_key))
				ToolTipText .= "`n[ " StrReplace(srf_all_Input_["py"],"''"," ") " ]"
		} Else If (jichu_for_select_Array[1,0]~="^English"){
			ToolTipText:=insertcaret(srf_all_Input,insertpos)
		} Else {
			ToolTipText:=""
			If (shurulei~="sanma|lianda"){
				Loop % save_field_array.Length()
					ToolTipText .= save_field_array[A_Index,0] " "
				ToolTipText .= RegExReplace(srf_all_Input,"^" StrReplace(ToolTipText, " ", " ?"))
				If (fzm)
					ToolTipText:=RegExReplace(ToolTipText, " ?" fzm " ?$", " " fzm)
				If (ToolTipText="")
					ToolTipText:=srf_all_Input_["tip"] (SubStr(srf_all_Input,0)="'"?"'":SubStr(srf_all_Input,0)="\"?" ":""), ToolTipText:=RegExReplace(ToolTipText, "''", " ")
			} Else
				ToolTipText:=srf_all_Input_["tip"], ToolTipText:=RegExReplace(ToolTipText, "''", " ")
			ToolTipText:=insertcaret(ToolTipText,insertpos)
		}
		If (SubStr(srf_all_Input,0)="'"&&SubStr(ToolTipText,0)!="'")
			ToolTipText .= "'"
		srf_for_select:=Trim(srf_for_select, "`n ")
	} Else If (srf_func_table[modeMatch.Value[1], "Name"]="get_hotstring"){
		Loop % Min(Function_for_select.Length()-ListNum*waitnum, ListNum)
			Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." Function_for_select[ListNum*waitnum+A_Index, 3])
			, srf_for_select .= _ srf_for_select_obj[Index]
		srf_for_select:=Trim(srf_for_select, "`n "), ToolTipText:=insertcaret(srf_all_Input,insertpos)
	} Else If (srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-zA-Z]+$"){
		Loop % Min(Function_for_select.Length()-ListNum*waitnum, ListNum)
			Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." Function_for_select[ListNum*waitnum+A_Index, 1])
			, srf_for_select .= _ srf_for_select_obj[Index]
		srf_for_select:=Trim(srf_for_select, "`n "), ToolTipText:=insertcaret(srf_all_Input,insertpos)
	} Else {
		If (srf_all_Input~="\d"&&Function_for_select[1,1])
			Loop % Min(Function_for_select.Length()-ListNum*waitnum, ListNum)
				Index:=srf_for_select_obj.Push(Chr(A_Index+96) "." Function_for_select[ListNum*waitnum+A_Index, 3])
				, srf_for_select .= _ srf_for_select_obj[Index]
		Else
			Loop % Min(Function_for_select.Length()-ListNum*waitnum, ListNum)
				Index:=srf_for_select_obj.Push(Mod(A_Index,10) "." Function_for_select[ListNum*waitnum+A_Index, 3])
				, srf_for_select .= _ srf_for_select_obj[Index]
		; If srf_for_select_obj.Length()=0
		; 	srf_for_select_obj[1]:="1." (srf_symbol[srf_all_Input,2-EnSymbol]?srf_symbol[srf_all_Input,2-EnSymbol]:LTrim(srf_all_Input,"'"))
		; 	, srf_for_select:=srf_for_select_obj[1]
		srf_for_select:=Trim(srf_for_select, "`n "), ToolTipText:=insertcaret(srf_all_Input,insertpos)
	}

; 显示候选项
showhouxuankuang:
	If (ToolTipText=""&&srf_for_select=""){
		If (ToolTipStyle=1)
			ToolTip(1,"") ;, ToolTip(2,"")
		Endinput()
		Return
	}
	If !(Lockedposition||hasCaretPos)
		Caret:=GetCaretPos(), hasCaretPos:=1
	If (ToolTipStyle=1){
		ToolTip(1, ToolTipText "`n" srf_for_select, "x" Caret.x " y" Caret.Y+Caret.H)
	} Else {
		if (dwselect){
			ToolTipText .= "︙" tfzm
		}
		DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction, srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-z]+$"?SymbolFont:TextFont)
	}
Return
; 自学习
zixuexi(){
	local
	global shurulei, DB, srf_last_input, Inputscheme, DelLastLearnSQL
	If (shurulei="pinyin"){
		DB.GetTable("SELECT ROWID FROM 'pinyin' WHERE jp=""" RegExReplace(srf_last_input[2, 1],"([a-z])[a-z]*","$1") """ AND key='" StrReplace(srf_last_input[2, 1],"'","''") "' AND value='" srf_last_input[2, 2] "' LIMIT 1", Result)
		If (!Result.RowCount)
			; DB.Exec("INSERT INTO 'main'.'pinyin' VALUES (""" RegExReplace(srf_last_input[2, 1],"([a-z])[a-z]*","$1") """,""" srf_last_input[2, 1]
			; 	. """,'" srf_last_input[2, 2] "',ifnull((SELECT max(weight)+1 FROM 'pinyin' " (srf_last_input[2, 3]
			; 	?RegExReplace(srf_last_input[2, 3], "i)^.+?(WHERE jp=.+)(ORDER BY|UNION ALL).+", "$1")
			; 	:"WHERE jp=""" RegExReplace(srf_last_input[2, 1],"([a-z])[a-z]*","$1") """ AND key='" StrReplace(srf_last_input[2, 1],"'","''") "'") "),5000));")
			_SQL:="INSERT INTO 'main'.'pinyin' VALUES (""" RegExReplace(srf_last_input[2, 1],"([a-z])[a-z]*","$1") """,""" srf_last_input[2, 1]
				. """,'" srf_last_input[2, 2] "',ifnull(max(5000,(SELECT max(weight)+1 FROM 'pinyin' WHERE jp=""" RegExReplace(srf_last_input[2, 1],"([a-z])[a-z]*","$1") """)),5000));"
	} Else If (shurulei="lianda"){
		srf_last_input[2, 0]:=StrReplace(srf_last_input[2, 1],"'")
		DB.GetTable("SELECT ROWID FROM '" Inputscheme "' WHERE key='" srf_last_input[2, 0] "' AND value='" srf_last_input[2, 2] "' LIMIT 1", Result)
		If (!Result.RowCount)
			_SQL:="INSERT INTO 'main'.'" Inputscheme "' VALUES ('" srf_last_input[2, 0] "','" srf_last_input[2, 2] "',ifnull((SELECT max(weight)+1 FROM '" Inputscheme "' WHERE key='" srf_last_input[2, 0] "'),5000));"
	} Else If (shurulei="xingma"){
		Switch StrLen(srf_last_input[2, 2]){
			Case 0,1:
				Return
			Case 2:
				srf_last_input[2, 0]:=RegExReplace(srf_last_input[2, 1],"^([a-z][a-z])[a-z]*'([a-z][a-z])[a-z]*$","$1$2")
			Case 3:
				srf_last_input[2, 0]:=RegExReplace(srf_last_input[2, 1],"^([a-z])[a-z]*'([a-z])[a-z]*'([a-z][a-z])[a-z]*$","$1$2$3")
			Default:
				srf_last_input[2, 0]:=RegExReplace(srf_last_input[2, 1],"^([a-z])[a-z]*'([a-z])[a-z]*'([a-z])[a-z]*'.+'([a-z])[a-z]*$","$1$2$3$4")
		}
		If (srf_last_input[2, 0]=""||InStr(srf_last_input[2, 0],"'"))
			Return
		DB.GetTable("SELECT ROWID FROM '" Inputscheme "' WHERE key='" srf_last_input[2, 0] "' AND value='" srf_last_input[2, 2] "' LIMIT 1", Result)
		If (!Result.RowCount)
			_SQL:="INSERT INTO 'main'.'" Inputscheme "' VALUES ('" srf_last_input[2, 0] "','" srf_last_input[2, 2] "',ifnull((SELECT max(weight)+1 FROM '" Inputscheme "' WHERE key='" srf_last_input[2, 0] "'),5000));"
	}
	If DB.Exec(_SQL){
		lastid:=0, DB.LastInsertRowID(lastid)
		DelLastLearnSQL:="DELETE FROM 'main'.'" (shurulei="pinyin"?"pinyin":Inputscheme) "' WHERE rowid=" lastid " AND value='" srf_last_input[2,2] "';"
		SetTimer, DelLastLearn, -5000
	} Else
		OutputDebug((A_ThisLabel?"标签:" A_ThisLabel "|":A_ThisFunc?"函数:" A_ThisFunc "|":"") "消息: " DB.ErrorMsg "|SQL: " DB.SQL, DebugLevel)
	Return
	DelLastLearn:
		DelLastLearnSQL:=""
	Return
}
; 关闭候选框
srf_value_off:
	(ToolTipStyle=1)?ToolTip(1):DrawHXGUI("", "")
	If (srf_last_input[1,2]){
		srf_last_input[2]:=srf_last_input[1], srf_last_input[1]:=[]
		If (Learning&&(Learnfg+InStr(srf_all_Input,"\")>1||(!FirstNotSave&&save_field_array.Length()>1))&&!(A_ThisHotkey~="Esc|Enter|BackSpace")){
			If (StrLen(srf_last_input[2, 2])<9){
				srf_last_input[2, 3]:=SQL_buffer[srf_last_input[2, 0]], srf_last_input[2, 1]:=IsPinyin?"":srf_last_input[2, 1]
				SetTimer, zixuexi, -10
			} Else {
				tvar:=ObjBindMethod(DB, "Exec", Trim(SQL_BUF_FRE, "`n"))
				SetTimer % tvar, -100
			}
		}
	}
	insertpos:=Showdwxgtip:=Learnfg:=hasCaretPos:=waitnum:=IsPinyin:=dwselect:=Endinput(), localpos:=1
	, ToolTipText:=srf_all_Input:=srf_for_select:=tfzm:=SQL_BUF_FRE:=Caret.t:=""
	, Function_for_select:=[], hotstring_for_select:=[], history_field_array:=[], jichu_for_select_Array:=[]
	, modeMatch:=[], SQL_buffer:=[], save_field_array:=[], srf_all_Input_:=[], srf_for_select_obj:=[]
Return
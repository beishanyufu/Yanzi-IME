;qu ci bing qie fen
xingmamethod(srf_input, scheme){
	local
	global IsPinyin, wumasp, DB, hasCaretPos, srf_all_Input, Imagine, lspy, ShowCode, pinyinfancha, srf_last_input, dgsp
		, srf_all_Input_, simasp, wumaqc, jichu_for_select_Array, srf_inputing, history_field_array, lspy_key, Useless
		, customs_for_select, Caret
	static zaoci
	max_code_len:=4, all_input:=srf_input
	; If (srf_input~="[A-Z]"){
	; 	srf_all_Input:="", SendInput(srf_input)
	; 	Gosub srf_value_off
	; 	Return 0
	; }
	srf_input_len:=StrLen(srf_input), IsPinyin:=0
	; pinyin
	If (lspy&&(SubStr(srf_input,1,1)==lspy_key)&&(srf_input:=SubStr(srf_input,2))){
		IsPinyin:=1
		SearchResult:=pinyinmethod(srf_input,"pinyin")
		tstr:=""
		If (ShowCode){
			mabiao:="", pinyinfancha:={}
			Loop % SearchResult.Length()
				If InStr(SearchResult[A_Index,0], "pinyin")
					mabiao .= "'" SearchResult[A_Index,2] "',"
			If (mabiao:=Trim(mabiao, ",")){
				DB.GetTable("SELECT value,key FROM " scheme " WHERE value IN (" mabiao ") ORDER BY key", Result)
				Loop % Result.RowCount
					pinyinfancha[Result.Rows[A_Index,1]]:=Result.Rows[A_Index,2]
			}
		}
		Return SearchResult
	}
	srf_all_Input_["tip"]:=all_input, IsPinyin:=0
	If (srf_input~="``")
		srf_input:=StrSplit(Trim(srf_input, "``"),"``")[1], zaoci:=1, history_field_array:=[]
	Else If (zaoci)
		zaoci:=0, history_field_array:=[]
	If !history_field_array.HasKey(srf_input)
		history_field_array[srf_input]:=Imagine?get_word_lianxiang(DB, srf_input, scheme):get_word(DB, srf_input, scheme)
	If (history_field_array[srf_input].Length()=0){
		; 顶功
		If (dgsp){
			If (jichu_for_select_Array.Length()>0&&jichu_for_select_Array[1,0]){
				srf_select(1), hasCaretPos:=(Caret.t="TSF"), srf_all_Input:=SubStr(srf_input,0), Begininput()
				Gosub srf_tooltip
				Return 0
			}
		} Else If (!Imagine)
			history_field_array[srf_input]:=get_word_lianxiang(DB, srf_input, scheme)
	}
	SearchResult:=CopyObj(history_field_array[srf_input])
	If (zaoci)
		Return SearchResult
	
	If (Useless&&SearchResult[1, 3]>0){
		Loop % len:=SearchResult.Length()
			If (SearchResult[len+1-A_Index, 3]<=0)
				SearchResult.RemoveAt(len+1-A_Index)
	}
	If simasp&&(srf_input_len=max_code_len)&&(SearchResult.Length()=1){
		jichu_for_select_Array:=SearchResult
		Gosub houchuli
		If (jichu_for_select_Array.Length()=1){
			srf_select(1)
		} Else
			Gosub srf_tooltip_fanye
		Return 0
	}
	If wumasp&&(srf_input_len>max_code_len){
		If (jichu_for_select_Array.Length()>0&&jichu_for_select_Array[1,0]){
			srf_select(1), hasCaretPos:=Caret.t="TSF", srf_all_Input:=SubStr(srf_input,max_code_len+1), Begininput()
			Gosub srf_tooltip
			Return 0
		}
	}
	If wumaqc&&(srf_input_len>max_code_len-1)&&(SearchResult.Length()+customs_for_select.Length()=0) {
		Return -1
	}
	Return SearchResult
}

xingmazigen(chars, scheme){
	local
	static xingma_dict:="", lastscheme:=""
	global Yzimeini, zigen, DataPath
	If (lastscheme!=scheme){
		xingma_dict:=""
		If !IsObject(xingma_dict){
			If FileExist(DataPath "@" scheme ".txt"){
				zigen_:=FileRead(DataPath "@" scheme ".txt")
				xingma_dict:=[]
				Loop, Parse, zigen_, `n, `r
					If (A_LoopField!="")
						xingma_dict[(tarr:=StrSplit(A_LoopField, "`t"))[1]]:=tarr[2]
			} Else {
				Yzimeini["Settings","zigen"]:=zigen:=0
				MsgBox, 16, 错误, Data目录下缺少字根文件@%scheme%.txt！
				Return
			}
		}
		lastscheme:=scheme
	}
	index:=1, tarr:=[]
	While index:=RegExMatch(chars, "O)[^\x00-\xff]", match, index)
		tarr.Push(match.Value), index+=match.Len
	; msgbox
	Switch tarr.Length()
	{
		Case 0:
			Return ""
		Case 1:
			Return xingma_dict[chars]?"「" xingma_dict[chars] "」":""
		Case 2:
			tt:=""
			Loop 2
				If xingma_dict[tarr[A_Index]]
					tt .= ReSubStr(xingma_dict[tarr[A_Index]],1,2)
				Else
					Return ""
			Return "「" tt "」"
		Case 3:
			tt:=""
			Loop 3
				If xingma_dict[tarr[A_Index]]
					tt .= ReSubStr(xingma_dict[tarr[A_Index]],1,1)
				Else
					Return ""
			tt .= ReSubStr(xingma_dict[tarr[3]],2,1)
			Return "「" tt "」"
		Default:
			tt:=""
			Loop 3
				If xingma_dict[tarr[A_Index]]
					tt .= ReSubStr(xingma_dict[tarr[A_Index]],1,1)
				Else
					Return ""
			If xingma_dict[tarr[tarr.Length()]]
				tt .= ReSubStr(xingma_dict[tarr[tarr.Length()]],1,1)
			Else
				Return ""
			Return "「" tt "」"
	}
	Return ""
}

ReSubStr(str,Begin,Length:=0){
	local
	Result:="", charnum:=0, index:=1
	While RegExMatch(str,".",Match,index){
		index+=StrLen(Match)
		If (A_Index<Begin)
			Continue
		Result .= Match, charnum++
		If (charnum=Length)
			Break
	}
	Return Result
}
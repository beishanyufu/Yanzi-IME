liandamethod(srf_input, scheme){
	local
	global IsPinyin, wumasp, DB, hasCaretPos, srf_all_Input, Imagine, lspy, ShowCode, pinyinfancha, srf_last_input, fzm
		,srf_all_Input_, simasp, wumaqc, jichu_for_select_Array, srf_inputing, history_field_array, fuzhuma, save_field_array
	static history_field_array2:=[]
	max_code_len:=16, IsPinyin:=0
	srf_input_len:=StrLen(srf_input)

	If (fuzhuma&1)&&(A_ThisHotkey~="^[a-z]$"){
		If (srf_input_len>2)&&((Mod(srf_input_len,2)=1&&fzm:=SubStr(srf_input,0))||(fzm:=SubStr(srf_input,-1))){
			saixuan:=[], saixuan2:=[], fzmlen:=StrLen(fzm)
			Loop % jichu_for_select_Array.Length(){
				If (StrLen(jichu_for_select_Array[A_Index,1])>srf_input_len-fzmlen)
					Continue
				If (StrLen(jichu_for_select_Array[A_Index,2])>1&&jichu_for_select_Array[A_Index,6]~="i)" RegExReplace(fzm,"(.)","$1(.*)?"))
					jichu_for_select_Array[A_Index, -2]:=fzm, saixuan.Push(jichu_for_select_Array[A_Index])
				Else If (jichu_for_select_Array[A_Index,6]~="i)^" fzm)
					jichu_for_select_Array[A_Index, -2]:=fzm, saixuan2.Push(jichu_for_select_Array[A_Index])
				Else
					jichu_for_select_Array[A_Index].Delete(-2)
			}
			Loop % saixuan2.Length()
				saixuan.Push(saixuan2[A_Index])
			If saixuan.Length()=0
				fzm:=""		
		} Else If (Mod(StrLen(save_field_array[1,0]),2)=1)
			save_field_array:=[]
	}
	srf_all_Input_["tip"]:=srf_input, IsPinyin:=0

	min_code_len:=1
	index:=1, save_field_array:={}
	While (index<srf_input_len+1){
		tlen:=Min(max_code_len,((srf_input_len+1-index)//min_code_len)*min_code_len)
		While (tlen>min_code_len-1){
			If !history_field_array.HasKey(srf_Input_trim_left:=SubStr(srf_input,index,tlen))
				history_field_array[srf_Input_trim_left]:=get_word(DB, srf_Input_trim_left, scheme)
			If (history_field_array[srf_Input_trim_left, 1, 2]){
				; If SubStr(srf_input,index+tlen)&&(Mod(StrLen(srf_Input_trim_left)/2,2)=1) ; 偶数词权重高优先
				; 	If (t:=SubStr(srf_Input_trim_left, 1, -2))&&(history_field_array[t, 1, 3]>=history_field_array[srf_Input_trim_left, 1, 3]){
				; 		tlen-=min_code_len
				; 		Continue
				; 	}
				save_field_array.Push(CopyObj(history_field_array[srf_Input_trim_left])), index+=tlen
				Break
			}
			tlen-=min_code_len
		}
		If (tlen<min_code_len)
			Break
	}
	If (srf_Input_trim_left:=SubStr(srf_input, index))&&(StrLen(srf_Input_trim_left)<=min_code_len){
		If !history_field_array.HasKey(srf_Input_trim_left)
			history_field_array[srf_Input_trim_left]:=get_word(DB, srf_Input_trim_left, scheme)
		If (history_field_array[srf_Input_trim_left, 1, 2])
			save_field_array.Push(CopyObj(history_field_array[srf_Input_trim_left]))
		Else If (StrLen(srf_Input_trim_left)=1){
			If !history_field_array2.HasKey(srf_Input_trim_left)
				history_field_array2[srf_Input_trim_left]:=get_word_lianxiang(DB, srf_Input_trim_left, scheme, 100)
			save_field_array.Push(CopyObj(history_field_array2[srf_Input_trim_left]))
		}
	}
	comstr:=["",""], SearchResult:=[]
	SearchResult:=CopyObj(save_field_array[1])
	Loop % save_field_array.Length()
		comstr[2] .= save_field_array[A_Index, 1, 2], comstr[1] .= save_field_array[A_Index, 1, 1]
	If SearchResult[1, 2]!=comstr[2]
		SearchResult.InsertAt(1, comstr)
	If ((zisu:=StrLen(save_field_array[1, 1, 2]))>2){
		ci:=save_field_array[1, 1, 1]
		t:=StrLen(ci)
		Loop % t-1 {
			ci:=SubStr(ci,1,t-A_Index)
			If !history_field_array.HasKey(ci)
				history_field_array[ci]:=get_word(DB, ci, scheme)
			If (history_field_array[ci, 1, 2]&&StrLen(history_field_array[ci, 1, 2])<zisu)
				Break
		}
		If (history_field_array[ci, 1, 2]&&StrLen(history_field_array[ci, 1, 2])>1)
			Loop % history_field_array[ci].Length()
				SearchResult.Push(CopyObj(history_field_array[ci, A_Index]))
	}
	zi:=""
	If (StrLen(SearchResult[SearchResult.Length(),2])>1||StrLen(SearchResult[SearchResult.Length(),1])>2){
		zi:=SubStr(srf_input, 1, 2)
		If !history_field_array.HasKey(zi)
			history_field_array[zi]:=get_word(DB, zi, scheme)
		If (history_field_array[zi,1,2])
			Loop % history_field_array[zi].Length()
				SearchResult.Push(CopyObj(history_field_array[zi, A_Index]))
	}
	If (fuzhuma){
		Loop % SearchResult.Length()
			If InStr(SearchResult[A_Index, 0], scheme "|")&&(SearchResult[A_Index, 6]="")
				SearchResult[A_Index, 6]:=fzmfancha(SearchResult[A_Index, 2])
	}
	If (StrLen(fzm)=2), inspos:=2
		Loop % tt:=saixuan.Length()
			SearchResult.InsertAt(inspos,saixuan[tt+1-A_Index])	; 词组优先
	Else
		Loop % tt:=saixuan.Length()
			SearchResult.InsertAt(1,saixuan[tt+1-A_Index])	; 辅助词条优先
	Return SearchResult
}
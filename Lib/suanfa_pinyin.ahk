; ##################################################################################################################################################################
; # 声明：此文件基于开源仓库 <https://gitee.com/orz707/Yzime> (Commit:d1d0d9b15062de7381d1e7649693930c34fca53d) 
; # 中的同名文件修改而来，并使用相同的开源许可 GPL-2.0 进行开源，具体的权利、义务和免责条款可查看根目录下的 LICENSE 文件
; # 修改者：北山愚夫
; # 修改时间：2024年3月15日 
; ##################################################################################################################################################################

pinyinmethod(input, scheme:="pinyin"){	; 拼音取词
	local
	global srf_all_Input_, DB, fzm, Inputscheme, fuzhuma, tfuzhuma, history_field_array, save_field_array, chaojijp, imagine, DebugLevel
		, Singleword, mhyRegExObj, CloudInput, jichu_for_select_Array, srf_all_Input, tfzm, dwselect, insertpos, Useless, CloudinputApi
	Loop_num:=0, history_cutpos:=[0], index:=0, zisu:=10, estr:=input, begin:=A_TickCount
	If (input~="[A-Z]")
		input:=Trim(StrReplace(RegExReplace(input,"([A-Z])","'$1'"),"''","'"),"'")
	srf_all_Input_["tip"]:=srf_all_Input_for_trim:=Trim(pyfenci(input, scheme, 0, DB), "'"), fzm:=""
	srf_all_Input_["py"]:=Trim(RegExReplace(pyfenci(srf_all_Input_for_trim, scheme, 1),"'?\\'?"," "), "'")
	srf_all_Input_for_trim:=StrReplace(srf_all_Input_for_trim,"\",Chr(2))
	If (Inputscheme~="pinyin|sp$"&&fuzhuma&&A_ThisHotkey~="^[a-z]$"&&!insertpos){
		If (RegExMatch(srf_all_Input_["tip"], "O).*[a-z;][a-z;]'([a-z])$", fzm)&&(srf_all_Input~=(fzm:=StrReplace(fzm.Value[1],"'")) "$"))
			||(Inputscheme~="sp$"&&RegExMatch(srf_all_Input_["tip"], "O).*[a-z;][a-z;]'([a-z;]'?[a-z;])$", fzm)&&(srf_all_Input~=(fzm:=StrReplace(fzm.Value[1],"'")) "$")){
			saixuan:=[], saixuan2:=[], fzm:=Trim(fzm," ")
			t:=(StrLen(fzm)>1&&Inputscheme~="sp$")?StrSplit(RegExReplace(srf_all_Input_["tip"], "'" fzm "$"), "'").Length():0
			fzm:=StrReplace(fzm,"'")
			Loop % jichu_for_select_Array.Length(){
				If (t&&InStr(jichu_for_select_Array[A_Index,1], "'", , , t)){
					jichu_for_select_Array[A_Index].Delete(-2)
					Continue
				}
				; If (StrLen(jichu_for_select_Array[A_Index,2])>1&&jichu_for_select_Array[A_Index,6]~="i)" RegExReplace(fzm,"(.)","$1(.*)?"))
				If fzmselect(jichu_for_select_Array[A_Index,6],fzm)
					jichu_for_select_Array[A_Index, -2]:=fzm, saixuan.Push(jichu_for_select_Array[A_Index])
				; Else If (jichu_for_select_Array[A_Index,6]~="i)^" fzm)
				; 	jichu_for_select_Array[A_Index, -2]:=fzm, saixuan2.Push(jichu_for_select_Array[A_Index])
				Else
					jichu_for_select_Array[A_Index].Delete(-2)
			}
			; Loop % saixuan2.Length()
			; 	saixuan.Push(saixuan2[A_Index])
			If saixuan.Length()=0
				fzm:=""
		} Else If save_field_array[1,0]~="'[a-z;]$"
			save_field_array:=[]
	}
	If (Singleword=1){
		If !history_field_array.HasKey(srf_all_Input_for_trim)
			history_field_array[srf_all_Input_for_trim]:= Get_jianpin(DB, scheme, "'" srf_all_Input_for_trim "'", mhyRegExObj, 0, 0)
			; history_field_array[srf_all_Input_for_trim]:= Get_jianpin(DB, scheme, "'" srf_all_Input_for_trim "'", , mhyRegExObj, (imagine?1:0), 0)
		If (history_field_array[srf_all_Input_for_trim,1,2]="")
			While (!history_field_array[srf_all_Input_for_trim:=RegExReplace(srf_all_Input_for_trim,"'[a-z;]+$","",repfg),1,2])&&(repfg){
				If !history_field_array.HasKey(srf_all_Input_for_trim)
					history_field_array[srf_all_Input_for_trim]:= Get_jianpin(DB, scheme, "'" srf_all_Input_for_trim "'", mhyRegExObj, 0, 0)
					; history_field_array[srf_all_Input_for_trim]:= Get_jianpin(DB, scheme, "'" srf_all_Input_for_trim "'", , mhyRegExObj, (imagine?1:0), 0)
				If (history_field_array[srf_all_Input_for_trim,1,2])
					Break
				If (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
					OutputDebug("Get Single Word timeout", DebugLevel)
					Break
				}
			}
		save_field_array:=[CopyObj(history_field_array[srf_all_Input_for_trim])]
	} Else {
		; 正向最大划分
		Loop % save_field_array.Length()
		{
			If save_field_array[A_Index,0]=Chr(1)
				Continue
			If (save_field_array[A_Index,0]=""){
				index:=A_Index
				Break
			}
			checkstr .= save_field_array[A_Index,0] "'"
			If InStr("^" srf_all_Input_for_trim "'", "^" checkstr){
				t:=StrSplit(save_field_array[A_Index,0],"'").Length()
				; 奇偶词条高权重优先
				; If ((t>2)&&(Mod(t, 2)=1)&&(StrLen(checkstr)<StrLen(srf_all_Input_for_trim))&&(history_field_array[save_field_array[A_Index,0], 1, 3]<history_field_array[RegExReplace(save_field_array[A_Index,0],"'[a-z;]+$"), 1, 3])){
				; 	index:=A_Index
				; 	Break
				; }
				history_cutpos.Push(StrLen(checkstr))
			} Else {
				index:=A_Index
				Break
			}
		}
		If (index)
			save_field_array.RemoveAt(index, save_field_array.Length()-index+1)

		srf_all_Input_for_trim_len:=StrLen(srf_all_Input_for_trim)
		If (save_field_array.Length()>0){
			If history_cutpos.Length()>1&&SubStr(srf_all_Input_for_trim,history_cutpos[history_cutpos.Length()],1)!="'"
				history_cutpos.Pop(), save_field_array.Pop()
			begin:=A_TickCount
			Loop % history_cutpos.Length()
			{
				If (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
					OutputDebug("Backtrack timeout", DebugLevel)
					Break
				}
				If ((srf_all_Input_trim_off:=SubStr(srf_all_Input_for_trim,history_cutpos[A_Index]+1))="")
					Break
				If InStr(srf_all_Input_trim_off, "'", , 1, zisu)
					Continue
				If !history_field_array.HasKey(srf_all_Input_trim_off){
					history_field_array[srf_all_Input_trim_off]:= Get_jianpin(DB, scheme, "'" srf_all_Input_trim_off "'", mhyRegExObj, 0, A_Index=1?0:1)
					If (history_field_array[srf_all_Input_trim_off, 1, 2]=""){
						If !InStr(srf_all_Input_trim_off, "'")
							history_field_array[srf_all_Input_trim_off]:={0:srf_all_Input_trim_off,1:[srf_all_Input_trim_off,srf_all_Input_trim_off=Chr(2)?"":srf_all_Input_trim_off]}
						Continue
					} Else If (A_Index>1)
						history_field_array[srf_all_Input_trim_off].Push("")
				}
				If (history_field_array[srf_all_Input_trim_off, 1, 2]){
					tarr:={}, Ln:=A_Index-1
					Loop % Ln
						If save_field_array[A_Index, 0]
							tarr.Push(save_field_array[A_Index])
					tarr.Push(CopyObj(history_field_array[srf_all_Input_trim_off]))
					save_field_array:=tarr, tarr:="", history_cutpos:=[0]
					Loop % save_field_array.Length()
						history_cutpos[A_Index+1]:=history_cutpos[A_Index]+StrLen(save_field_array[A_Index,0])+1
				}
			}
		}
		If (tpos:=history_cutpos[history_cutpos.Length()])<srf_all_Input_for_trim_len
		{
			Loop_num:=0, begin:=A_TickCount
			Loop
			{
				If (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
					OutputDebug("Forward timeout", DebugLevel)
					Break
				}
				If ((cutpos:=InStr(srf_all_Input_for_trim "'", "'", 0, 0, Loop_num+=1))<tpos+1)
					||((srf_Input_trim_left:=SubStr(srf_all_Input_for_trim,tpos+1,cutpos-1-tpos))="")
					Break
				If InStr(srf_Input_trim_left, "'", , 1, zisu)
					Continue
				srf_Input_trim_right:=SubStr(srf_all_Input_for_trim,cutpos+1)
				If srf_Input_trim_left&&!history_field_array.HasKey(srf_Input_trim_left){
					history_field_array[srf_Input_trim_left]:= Get_jianpin(DB, scheme, "'" srf_Input_trim_left "'", mhyRegExObj, 0, (tpos?1:0), ((scheme="pinyin")&&(!InStr(srf_all_Input,srf_Input_trim_left))))
					; jichu_for_select:= Get_jianpin(DB, scheme, "'" srf_Input_trim_left "'", , mhyRegExObj, (srf_Input_trim_right?0:1)&&(imagine?1:0), 0, ((scheme="pinyin")&&(!InStr(srf_all_Input,srf_Input_trim_left))))
					If (history_field_array[srf_Input_trim_left, 1, 2]=""){
						If InStr(srf_Input_trim_left,"'")
							history_field_array[srf_Input_trim_left]:={0:srf_Input_trim_left}
						Else
							history_field_array[srf_Input_trim_left]:={0:srf_Input_trim_left,1:[srf_Input_trim_left,srf_Input_trim_left=Chr(2)?"":srf_Input_trim_left]}
					} Else If (tpos)
						history_field_array[srf_Input_trim_left].Push([])
				}
				If history_field_array[srf_Input_trim_left, 1, 2]=""&&InStr(srf_Input_trim_left,"'")
					Continue
				Else {
					t:=StrSplit(srf_Input_trim_left,"'").Length()
					; 奇偶词条高权重优先
					; If ((t>2)&&(Mod(t, 2)=1)&&srf_Input_trim_right&&(history_field_array[srf_Input_trim_left, 1, 3]<history_field_array[RegExReplace(srf_Input_trim_left,"'[a-z;]+$"), 1, 3]))
					; 	Continue
					Loop_num:=0
					If (srf_Input_trim_left!="")
						save_field_array.Push(CopyObj(history_field_array[srf_Input_trim_left])), history_cutpos[history_cutpos.Length()+1]:=history_cutpos[history_cutpos.Length()]+1+StrLen(srf_Input_trim_left)
					; history_cutpos:=[0]
					; Loop % save_field_array.Length()
					; 	history_cutpos[A_Index+1]:=history_cutpos[A_Index]+StrLen(save_field_array[A_Index,0])+1
					tpos:=history_cutpos[history_cutpos.Length()]
				}
			}
		}
	}
	jichu_for_select:="", SearchResult:=[]
	If (save_field_array[1].Length()=2&&save_field_array[1,2,2]="")
		save_field_array[1]:=CopyObj(history_field_array[save_field_array[1,0]]:= Get_jianpin(DB, scheme, "'" save_field_array[1,0] "'", mhyRegExObj, 0, 0))
	If (save_field_array.Length()=1)||(tfzm){
		; SearchResult:=save_field_array[1]
		SearchResult:=CopyObj(save_field_array[1])
	} Else {
		If (save_field_array[2,1,1]!=Chr(2)){
			ci:=save_field_array[1,1,-1] "'" save_field_array[2,1,-1]
			While (InStr(ci,"'")&&(history_field_array[ci, 1, 2]=""))
				ci:=RegExReplace(ci, "i)'([^']+)?$")
			If (ci~="^" save_field_array[1, 0] "'[a-z;]+"){
				If (history_field_array[ci].Length()=2&&history_field_array[ci,2,2]="")
					history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", mhyRegExObj, 0, 0)
				SearchResult:=CopyObj(history_field_array[ci])
			}
		}
		If InStr(save_field_array[1, 0], "'")
			Loop % save_field_array[1].Length()
				; SearchResult.Push(save_field_array[1, A_Index])
				SearchResult.Push(CopyObj(save_field_array[1, A_Index]))
		SearchResult.InsertAt(1, firstzhuju(save_field_array)), SearchResult[1, 0]:="pinyin"
	}
	; 英文混输
	If (Inputscheme~="pinyin|sp$"&&!history_field_array["", len:=StrLen(estr)]){
		If (len>4)
			tarr:=get_word_lianxiang(DB, estr, "English", 1, 5)
		; Else
		;  	tarr:=get_word(DB, estr, "English")
		If (tarr.Length())
			Loop % tarr.Length()
				SearchResult.InsertAt(A_Index+1, tarr[A_Index])
		Else If (len>4)
			Loop 5
				history_field_array["", len+A_Index-1]:=1
		Else
			history_field_array["", len]:=1
	}

	; 插入候选词部分
	If (ci:=RegExReplace(save_field_array[1,1,-1], "i)'[^']+$")){
		While InStr(ci,"'")&&(history_field_array[ci, 1, 2]=""){
			If (!history_field_array.HasKey(ci)){
				history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", mhyRegExObj, 0, 0)
				If (history_field_array[ci, 1, 2])
					Break
			}
			ci:=RegExReplace(ci, "i)'([^']+)?$")
		}
		If InStr(ci,"'"){
			If (history_field_array[ci].Length()=2&&history_field_array[ci,2,2]="")
				history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", mhyRegExObj, 0, 0)
			Loop % history_field_array[ci].Length()
				SearchResult.Push(CopyObj(history_field_array[ci, A_Index]))
			; 二字词
			If (t:=InStr(ci, "'", , , 2)){
				ci:=SubStr(ci,1,t-1)
				If (!history_field_array.HasKey(ci)||history_field_array[ci].Length()=2&&history_field_array[ci,2,2]="")
					history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", mhyRegExObj, 0, 0)
				If (history_field_array[ci, 1, 2]!="")
					Loop % history_field_array[ci].Length()
						SearchResult.Push(CopyObj(history_field_array[ci, A_Index]))
			}
		}
	}
	If !(tfzm||StrLen(fzm)=1)
		&& (imagine&&InStr(srf_all_Input_["py"], "'", , 1, 3)){
		If (history_field_array[srf_all_Input_["tip"], -1]=""){
			history_field_array[srf_all_Input_["tip"], -1]:=Get_jianpin(DB, "", "'" srf_all_Input_["py"] "'", mhyRegExObj, 1, 0)
		}
		Loop % tt:=history_field_array[srf_all_Input_["tip"], -1].Length()
			SearchResult.InsertAt(2, CopyObj(history_field_array[srf_all_Input_["tip"], -1, tt+1-A_Index]))
	}
	If (StrLen(fzm)=2&&SubStr(srf_all_Input_["tip"],-2,1)="'"){
		inspos:=2	;, inspos:=SearchResult.Length()+1
		; Loop % tt:=saixuan.Length()
			; SearchResult.InsertAt(inspos,saixuan[tt+1-A_Index])	; 词组优先
	} Else {
		Loop % tt:=saixuan.Length()
			SearchResult.InsertAt(1,saixuan[tt+1-A_Index])	; 辅助词条优先
		inspos:=tt?1:2
	}
	; 插入候选字部分
	; If InStr(save_field_array[1, 0], "'"){
		zi:=SubStr(srf_all_Input_["tip"] ,1, InStr(srf_all_Input_["tip"] "'", "'")-1)
		If !(history_field_array.HasKey(zi))||(history_field_array[zi].Length()=2&&history_field_array[zi,2,2]="")
			history_field_array[zi]:= Get_jianpin(DB, scheme, "'" zi "'", mhyRegExObj, 0, 0)
		Loop % history_field_array[zi].Length()
			SearchResult.Push(CopyObj(history_field_array[zi, A_Index]))
	; }
	; If fuzhuma&&(((Inputscheme~="sp$")&&(srf_all_Input_["tip"]~="'[a-z][a-z]'$"))||((Inputscheme="pinyin")&&(srf_all_Input_["tip"]~="[a-z][aoeiuvng]'$"))){
	If (fuzhuma||tfuzhuma){
		Loop % SearchResult.Length()
			If InStr(SearchResult[A_Index, 0], "pinyin|")&&(SearchResult[A_Index, 6]="")
				SearchResult[A_Index, 6]:=fzmfancha(SearchResult[A_Index, 2])
	}
	If (tfzm!=""){
		saixuan:=[]
		Loop % SearchResult.Length(){
			; If (StrLen(SearchResult[A_Index,2])>1&&SearchResult[A_Index,6]~="i)" RegExReplace(tfzm,"(.)","$1(.*)?"))||(SearchResult[A_Index,6]~="i)^" tfzm)
			If fzmselect(SearchResult[A_Index,6], tfzm)
				SearchResult[A_Index, -2]:=dwselect?tfzm:SearchResult[A_Index,6], saixuan.Push(SearchResult[A_Index])
			Else
				SearchResult[A_Index].Delete(-2)
		}
		; If saixuan.Length()
			SearchResult:=saixuan
		; Else
		; 	tfzm:=""
	} Else {
		If chaojijp&&(srf_all_Input~="^[^']{4,8}$")&&!history_field_array.HasKey(cjjp:=Trim(RegExReplace(srf_all_Input,"(.)","$1'"), "'"))
			history_field_array[cjjp]:= Get_jianpin(DB, scheme, "'" cjjp "'", mhyRegExObj, 0, 8, true)
		If (cjjp)
			Loop % l:=history_field_array[cjjp].Length()
				SearchResult.InsertAt(2,CopyObj(history_field_array[cjjp,l+1-A_Index]))
		If (fzm=""){
			Loop % jichu_for_select_Array.Length()
				jichu_for_select_Array[A_Index].Delete(-2)
		}
		; 云输入, 2字词以上触发
		If CloudInput&&inspos=2&&InStr(srf_all_Input_["py"], "'", , 1, 2){
			; SearchResult.InsertAt(2,{0:"<Cloud>|-1",1:"",2:""})
			SetTimer, BDCloudInput, -10
		}
	}
	If (Useless&&SearchResult[1, 3]>0){
		Loop % len:=SearchResult.Length()
			If (SearchResult[len+1-A_Index, 3]&&SearchResult[len+1-A_Index, 3]<=0)
				SearchResult.RemoveAt(len+1-A_Index)
	}
	If (SearchResult.HasKey(0))
		SearchResult.Delete(0)
	Return SearchResult
	; 云输入
	BDCloudInput:
		If (srf_all_Input_["py"]=""||InStr(srf_all_Input_["tip"],"\"))
			Return 0
		; BDCloudInput(srf_all_Input_["py"])
		CloudinputApi.get(srf_all_Input_["py"])
	Return 0
}
fzmselect(wordf,inputf){ ; 用键入的辅助码匹配字词本身的辅助码
    ; local
	global FirstZi
	If (FirstZi) {
		If (fencifuPos:=InStr(wordf, "'"))
			wordf := SubStr(wordf, 1, fencifuPos-1)
		If (StrLen(inputf)=1) {
			return InStr(wordf, inputf)
		} Else {
			If !(inputf ~= "^(\d\D|\D\d)")
				return 0
			return InStr(wordf,SubStr(inputf,1,1)) && InStr(wordf,SubStr(inputf,2,1))
		}
	} Else If (StrLen(inputf)=1) { ; 一位辅助码
        return InStr(wordf, inputf)
    } Else If !InStr(wordf, "'") { ; 单字和多位码
		If !(inputf ~= "^(\d\D|\D\d)")
			return 0
        ; return wordf "|" wordf ~= "i)" SubStr(inputf,1,1) ".*\|.*" SubStr(inputf,2,1)
		return InStr(wordf,SubStr(inputf,1,1)) && InStr(wordf,SubStr(inputf,2,1))
    } Else { ; 多字词和多位码
        ; 如果两位码能与词中的某个字的辅助码匹配则返回真
		If (inputf ~= "^(\d\D|\D\d)") {
			; m := "i)" SubStr(inputf,1,1) ".*\|.*" SubStr(inputf,2,1)
			; Loop, Parse, wordf, ' 
			; 	{
			; 		if(A_LoopField "|" A_LoopField ~= m) 
			; 			return 1 
			; 	} 
			fzm1:=SubStr(inputf,1,1), fzm2:=SubStr(inputf,2,1)
			Loop, Parse, wordf, ' 
			{
				If (InStr(A_LoopField, fzm1) && InStr(A_LoopField, fzm2))
					return 1
			}
		}
        ; 如果多位码的每个码都能有序但可不连续地分别匹配上词中字的辅助码则返回真
        ; return wordf ~= "i)" RTrim(RegExReplace(inputf,"(.)","$1.*\|.*"), ".*\|.*")
		warr := StrSplit(wordf, "'")
		pos := 0
		Loop, Parse, % SubStr(inputf,1,2)
		{
			m := 0
			Loop % warr.Length()-pos
			{
				pos += 1
				if (m:=InStr(warr[pos], A_LoopField))
					break
			}
			if !m 
				break
		}
		return m
    }
}
fzmfancha(str){		; 辅助码构成规则
	local
	global srf_fzm_fancha_table
	result:=""
	Loop, Parse, str
		result .= ((r:=srf_fzm_fancha_table[A_LoopField])?r:"67890ao") . "'"
	; 词末字辅助
	; result := srf_fzm_fancha_table[SubStr(str,0,1)]
	; 首字辅助
	; result := srf_fzm_fancha_table[SubStr(str,1,1)]
	Return  RTrim(result, "'")
}
firstzhuju(arr){	; 首选组词
	rarr:=["",""]
	Loop % arr.Length()
		If (arr[A_Index, 0]!=Chr(2))
			rarr[1] .= (rarr[1]?"'":"") arr[A_Index, 1, 1], rarr[2] .= arr[A_Index, 1, 2]
	Return rarr
}
pyfenci(str,pinyintype:="pinyin",switch:=0,DB:=""){	; 拼音音节切分
	local
	Critical
	static lastpy:="",pyb:="",lsmmd:="",ymmaxlen:=0	; 记录上次分词类型，减少加载
	static lsm:=["a","ai","an","ang","ao","e","ei","en","eng","er","o","ou"]	; 零声母
	; 小鹤双拼键盘布局
	static xhspjm:= {"0":"1","ai":"d","an":"j","ang":"h","ao":"c","ch":"i","ei":"w","en":"f","eng":"g","er":"e","ia":"x","ian":"m","iang":"l","iao":"n","ie":"p","in":"b","ing":"k","iong":"s","iu":"q","ong":"s","ou":"z","sh":"u","ua":"x","uai":"k","uan":"r","uang":"l","ue":"t","ui":"v","un":"y","uo":"o","v":"v","ve":"t","zh":"v"}
	; 自然码键盘布局
	static zrmspjm:={"0":"1","ai":"l","an":"j","ang":"h","ao":"k","ch":"i","ei":"z","en":"f","eng":"g","er":"e","ia":"w","ian":"m","iang":"d","iao":"c","ie":"x","in":"n","ing":"y","iong":"s","iu":"q","ong":"s","ou":"b","sh":"u","ua":"w","uai":"y","uan":"r","uang":"d","ue":"t","ui":"v","un":"p","uo":"o","v":"v","ve":"t","zh":"v"}
	; 智能abc键盘布局
	static abcspjm:={"0":"o","ai":"l","an":"j","ang":"h","ao":"k","ch":"e","ei":"q","en":"f","eng":"g","er":"r","ia":"d","ian":"w","iang":"t","iao":"z","ie":"x","in":"c","ing":"y","iong":"s","iu":"r","ong":"s","ou":"b","sh":"v","ua":"d","uai":"c","uan":"p","uang":"t","ue":"m","ui":"m","un":"n","uo":"o","v":"v","ve":"m","zh":"a"}
	; 微软双拼键盘布局
	; static wrspjm:= {"0":"o","ai":"l","an":"j","ang":"h","ao":"k","ch":"i","ei":"z","en":"f","eng":"g","er":"r","ia":"w","ian":"m","iang":"d","iao":"c","ie":"x","in":"n","ing":"y","iong":"s","iu":"q","ong":"s","ou":"b","sh":"u","ua":"w","uai":"y","uan":"r","uang":"d","ue":"t","ui":"v","un":"p","uo":"o","v":"v","ve":"t","zh":"v"}
	static wrspjm:= {"0":"o","ai":"l","an":"j","ang":"h","ao":"k","ch":"i","ei":"z","en":"f","eng":"g","er":"r","ia":"w","ian":"m","iang":"d","iao":"c","ie":"x","in":"n","ing":";","iong":"s","iu":"q","ong":"s","ou":"b","sh":"u","ua":"w","uai":"y","uan":"r","uang":"d","ue":"t","ui":"v","un":"p","uo":"o","v":"y","ve":"v","zh":"v"}
	static sgspjm:= {"0":"o","ai":"l","an":"j","ang":"h","ao":"k","ch":"i","ei":"z","en":"f","eng":"g","er":"r","ia":"w","ian":"m","iang":"d","iao":"c","ie":"x","in":"n","ing":";","iong":"s","iu":"q","ong":"s","ou":"b","sh":"u","ua":"w","uai":"y","uan":"r","uang":"d","ue":"t","ui":"v","un":"p","uo":"o","v":"y","ve":"t","zh":"v"}
	; 加加双拼
	static jjspjm:= {"0":"2","ai":"s","an":"f","ang":"g","ao":"d","ch":"u","ei":"w","en":"r","eng":"t","er":"q","ia":"b","ian":"j","iang":"h","iao":"k","ie":"m","in":"l","ing":"q","iong":"y","iu":"n","ong":"y","ou":"p","sh":"i","ua":"b","uai":"x","uan":"c","uang":"h","ue":"x","ui":"v","un":"z","uo":"o","v":"v","ve":"x","zh":"v"}
	; 大牛双拼
	static dnspjm:= {"0":"e","ai":"h","an":"d","ang":"f","ao":"s","ch":"i","ei":"w","en":"k","eng":"j","er":"u","ia":"k","ian":"c,q","iang":"n","iao":"m","ie":"p","in":"b","ing":"g","iong":"l","iu":"t","ong":"l","ou":"r","sh":"u,v","ua":"q","uai":"g","uan":"z","uang":"x","ue":"h","ui":"n,v","un":"y","uo":"o","van":"j","ve":"x","vn":"w","zh":"a,o"
					,"2":{"lai":"lh","nai":"nh"}}
	global Yzimeini, customspjm, mhyRegExObj, customspell, JSON
	If (lastpy != pinyintype){											; 加载键盘布局
		If (pinyintype=""){
			If (lastpy)
				pinyintype:=lastpy
			Else
				Return
		} Else If (%pinyintype%jm="")
			%pinyintype%jm:=customspjm[pinyintype]
		lastpy:=pinyintype
		If (str!=Chr(1))
			setmohuyingobj(-1)

		; 全拼声母韵母表	add "din"、"tin"、""、""
		quanpinbiao = 
		(LTrim
			{"i" :{"1":"i"},"u" :{"1":"u"},"v" :{"1":"v"},"a" :{"1":"a","ai":"i","an":"n","ang":"ng","ao":"o"}
			,"b" :{"1":"b","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","o":"o","u":"u","un":"un"}
			,"c" :{"1":"c", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
			,"ch":{"1":"ch","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
			,"d" :{"1":"d","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","ei":"ei","eng":"eng","i":"i","ia":"ia","ian":"ian","iao":"iao","ie":"ie","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
			,"e" :{"1":"e","ei":"i","en":"n","eng":"ng","er":"r"}
			,"f" :{"1":"f","a":"a","an":"an","ang":"ang","ei":"ei","en":"en","eng":"eng","iao":"iao","o":"o","ou":"ou","u":"u"}
			,"g" :{"1":"g","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
			,"h" :{"1":"h","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
			,"j" :{"1":"j","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","ue":"ue","un":"un","v":"u","van":"uan","ve":"ue","vn":"un"}
			,"k" :{"1":"k","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","ei":"ei","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
			,"l" :{"1":"l","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","eng":"eng","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","v":"v","uan":"uan","ue":"ue","un":"un","uo":"uo","ve":"ue"}
			,"m" :{"1":"m","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","o":"o","ou":"ou","u":"u"}
			,"n" :{"1":"n","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","v":"v","uan":"uan","ue":"ue","uo":"uo","un":"un","ve":"ue"}
			,"o" :{"1":"o","ou":"u"}
			,"p" :{"1":"p","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","o":"o","ou":"ou","u":"u"}
			,"q" :{"1":"q","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","ue":"ue","un":"un","van":"uan","ve":"ue","vn":"un","v":"u"}
			,"r" :{"1":"r","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
			,"s" :{"1":"s", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
			,"sh":{"1":"sh","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
			,"t" :{"1":"t","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","eng":"eng","ei":"ei","i":"i","ian":"ian","iao":"iao","ie":"ie","ing":"ing","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
			,"w" :{"1":"w","a":"a","ai":"ai","an":"an","ang":"ang","ei":"ei","en":"en","eng":"eng","o":"o","u":"u"}
			,"x" :{"1":"x","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","un":"un","ue":"ue","van":"uan","ve":"ue","vn":"un","v":"u"}
			,"y" :{"1":"y","a":"a","an":"an","ang":"ang","ao":"ao","e":"e","i":"i","in":"in","ing":"ing","o":"o","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ue":"ue","un":"un","v":"u","van":"uan","ve":"ue","vn":"un"}
			,"z" :{"1":"z", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
			,"zh":{"1":"zh","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo","ua":"ua","uai":"uai","uang":"uang"}}
		)
		qpb:=JSON.Load(quanpinbiao)
		If SubStr(Yzimeini["Settings","mhy"],1,1)		; mhy c ch
			qpb["c","ua"]:="ua", qpb["c","uai"]:="uai", qpb["c","uang"]:="uang"
		If SubStr(Yzimeini["Settings","mhy"],2,1)		; mhy s sh
			For i,ym In ["ei","ong","on","ua","uai","uang"]
				qpb["s",ym]:=qpb["sh",ym]:=ym
		If SubStr(Yzimeini["Settings","mhy"],3,1)		; mhy z zh
			qpb["z","ua"]:="ua", qpb["z","uai"]:="uai", qpb["z","uang"]:="uang"
		If SubStr(Yzimeini["Settings","mhy"],5,1)		; mhy eng
			qpb["t","en"]:="en", qpb["l","en"]:="en"
		If SubStr(Yzimeini["Settings","mhy"],6,1)		; mhy ing
			qpb["d","in"]:=qpb["t","in"]:="in"
		If SubStr(Yzimeini["Settings","mhy"],9,1)		; mhy ai an
			qpb["f","ai"]:=qpb["r","ai"]:=qpb["y","ai"]:="ai"
		If SubStr(Yzimeini["Settings","mhy"],10,1)		; mhy un ong
			qpb["b","ong"]:=qpb["j","ong"]:=qpb["q","ong"]:=qpb["sh","ong"]:="ong"
			, qpb["b","on"]:=qpb["j","on"]:=qpb["q","on" ]:=qpb["sh","on" ]:="ong"
		If (pinyintype="pinyin"){
			; 全拼拼写纠错
			If customspell.Length()
				For sm,_ In qpb
					For ym In _
						Loop % customspell.Length()
							If (sm . ym != (err:=RegExReplace(sm . ym, customspell[A_Index, 1], customspell[A_Index, 2])))
								If (errym:=RegExReplace(err, "^" sm, "", t))&&t
									qpb[sm, errym]:=ym
			ymmaxlen:=4
			pyb:=qpb, pyb["l","ue"]:="ue", pyb["n","ue"]:="ue"
			For key,value In lsm
				If (StrLen(value)>1){
					pyb[t1:=SubStr(value, 1, 1)].Delete(value)
					pyb[t1][t2:=SubStr(value, 2)]:=t2
				}
		} Else {													; 生成双拼声母韵母表
			ymmaxlen:=1, ymb:=CopyObj(%pinyintype%jm)
			lsmmd:=ymb.Delete(0), ymb.Delete(1), exception:=ymb.Delete(2), pyb:=[], mhy_:=ymb.Delete(3)
			For i,ym In ["a","o","e","i","u","v"]
				ymb[ym]:=ymb[ym]?ymb[ym]:ym
			For i,ym In ["ve","van","vn"]
				ymb[ym]:=ymb[ym]?ymb[ym]:ymb[StrReplace(ym,"v","u")]
			For i,sms In {"b":"b","c":"c","ch":ymb.Delete("ch"),"d":"d","f":"f","g":"g","h":"h","j":"j","k":"k","l":"l","m":"m","n":"n","p":"p","q":"q","r":"r","s":"s","sh":ymb.Delete("sh"),"t":"t","w":"w","x":"x","y":"y","z":"z","zh":ymb.Delete("zh")}
			{
				sms:=StrSplit(sms,",")
				Loop % sms.Length(){
					pyb[sm:=sms[A_Index],""]:=i
					For j,yms In ymb
					{
						yms:=StrSplit(yms,",")
						Loop % yms.Length()
							If qpb[i,j]
								pyb[sm,yms[A_Index]]:=i qpb[i,j]
					}
				}
			}
			If (lsmmd=1){
				For i,sm In lsm
					pyb[SubStr(sm,1,1),StrLen(sm)=2?SubStr(sm,0):ymb[sm]?ymb[sm]:sm]:=sm
				pyb["a",""]:="a", pyb["e",""]:="e", pyb["o",""]:="o"
			} Else If (lsmmd=2){
				For i,sm In lsm
					pyb[SubStr(sm,1,1),ymb[sm]?ymb[sm]:sm]:=sm
				pyb["a",""]:="a", pyb["e",""]:="e", pyb["o",""]:="o"
			} Else If (lsmmd~="[a-z]"){
				For i,sm In lsm
					pyb[lsmmd,ymb[sm]?ymb[sm]:sm]:=sm
				pyb[lsmmd, ""]:=lsmmd
			}
			For py,sp In exception
				pyb[SubStr(sp,1,1),SubStr(sp,2)]:=py
			Loop % mhy_.Length()
				mhyRegExObj.Push(mhy_[A_Index])
		}
	}
	index:=1,fc:="'",strlen:=StrLen(str),lastchar:=" "
	Loop
	{
		If (pyb[tsm:=SubStr(str, index, 1),""] tsm~="\d"){
			fc := RTrim(fc,"'") (switch&&pyb[tsm,""]?pyb[tsm,""]:tsm) "'", index++
			Continue
		} Else If pyb.HasKey(tsm){					; 声母
			index+=1
			If (pinyintype="pinyin"){
				If (InStr("csz", tsm)&&(SubStr(str, index, 1)="h"))
					index+=1,tsm .= "h"
				Else If (InStr("aeo", tsm)){
					SubStr(str, index-1, 2)
				}
			}
			tym:="",tymlen:=0
			Loop													; 韵母
			{
				If (index+ymmaxlen-A_Index>strlen)
					Continue
				tym:=SubStr(str, index, tymlen:=ymmaxlen+1-A_Index)
				If (pyb[tsm][tym])
					Break
			} Until A_Index=ymmaxlen+1
			If (pinyintype="pinyin")&&((InStr("n|g", lastchar)||(lastchar="e"&&tsm="r"))&&(!tym||InStr("aeo", tsm))){	; 词库辅助分词
				If (pyb[ttsm][SubStr(ttym,1,-1)])
				{
					tfc:=LTrim(pyfenci(SubStr(str,index-2)),"'")
					If (InStr(tfc, "'")>2){
						If DB&&!(checkfenci(DB,SubStr(fc,1,-2) "'" tfc)<checkfenci(DB,fc tsm tym "'"))
							Return (SubStr(fc,0)="'"?SubStr(fc,1,-2):SubStr(fc,1,-1)) "'" tfc
						; Return (SubStr(fc,0)="'"?SubStr(fc,1,-2):SubStr(fc,1,-1)) "'" tfc
					}
				}
			}
			If (switch)						; 转全拼显示
				ttym:=tym,ttsm:=tsm,fc .= (pinyintype="pinyin"?pyb[tsm][1]:"") pyb[tsm][tym] "'"
			Else
				ttym:=tym,ttsm:=tsm,fc .= tsm tym "'"
			index+=tymlen, lastchar:=pyb[tsm][tym]?SubStr(pyb[tsm][tym],0):pyb[tsm][1]?SubStr(pyb[tsm][1],0):lastchar
		} Else {
			index+=1, lastchar:=tsm
			If (tsm!="'")
				fc .= tsm "'"
		}
	} Until index>strlen
	Return fc
}
mohuyinsql(str,RegExstr:=""){		; RegExstr = ("csz"任选) . ("aei"任选) . ("lrn" "ln" "lr" "" 选其一)
	Return "SELECT key,value,weight FROM pinyin WHERE key IN " mohuyin(str,RegExstr)
}

mohuyin(str,RegExstr:=""){			; RegExstr = ("csz"任选) . ("aei"任选) . ("lrn" "ln" "lr" "" 选其一)
	; 枚举规定使用模糊音的所有拼音  zen''sen --> ('zen''sen','zhen''shen',...,'zheng''sheng')
	If !RegExstr
		Return "('" StrReplace(Trim(str,"'"),"'","''") "')"
	RegExMatch(RegExstr, "[csz]{1,3}", cszRegEx),cszRegEx:=cszRegEx?"([" cszRegEx "])h?":""		; cszRegEx = "([csz])h?"
	RegExMatch(RegExstr, "[aei]{1,3}", aeiRegEx),aeiRegEx:=aeiRegEx?"([" aeiRegEx "o]n)g?":"(on)g?"	; aeiRegEx = "([aei]n)g?"
	RegExMatch(RegExstr, "[lrn]{2,3}", lrnRegEx),lrnRegEx:=lrnRegEx?"[" lrnRegEx "]":""			; lrnRegEx = "[lrn]"
	cszfg:=(cszRegEx?1:0),aeifg:=(aeiRegEx?1:0),lrnfg:=(lrnRegEx?1:0)
	If !(cszfg||aeifg||lrnfg)
		Return "('" StrReplace(Trim(str,"'"),"'","''") "')"
	allpinyin:=[],strarr:=StrSplit(Trim(str,"'"), "'")
	Loop % strarr.Length()
	{
		tstr:=strarr[A_Index],thispinyin:=[]
		If cszfg&&RegExMatch(tstr, cszRegEx, sm){
			thispinyin.Push(sm)
			If (sm=sm1)
				thispinyin.Push(sm "h")
			Else
				thispinyin.Push(sm1)
		} Else If lrnfg&&RegExMatch(SubStr(tstr,1,1), lrnRegEx, sm){
			thispinyin.Push(sm)
			If (sm="l"){
				If InStr(lrnRegEx, "n")
					thispinyin.Push("n")
				If InStr(lrnRegEx, "r")
					thispinyin.Push("r")
			} Else If sm&&(InStr(lrnRegEx,"l"))
				thispinyin.Push("l")
		} 
		If aeifg&&RegExMatch(tstr, aeiRegEx, ym){
			If thispinyin.Length(){
				Loop % thispinyin.Length()
				{
					thispinyin.Push(thispinyin[A_Index] ym1 "g")
					thispinyin[A_Index] .= ym1
				}
			} Else {
				thispinyin.Push(tstr)
				If (ym=ym1)
					thispinyin.Push(tstr "g")
				Else
					thispinyin.Push(SubStr(tstr,1,-1))
			}
		} Else If thispinyin.Length(){
			RegExMatch(tstr, "^[^aoeiuv]h?([a-z]+)", ym)
			Loop % thispinyin.Length()
				thispinyin[A_Index] .= ym1
		}
		If thispinyin.Length() {
			If allpinyin.Length()=0
				allpinyin:=thispinyin
			Else
				Loop % allpinyin.Length()
				{
					thepinyin:=allpinyin[A_Index]
					allpinyin[A_Index] .= "''" thispinyin[1]
					Loop % thispinyin.Length()-1
						allpinyin.Push(thepinyin "''" thispinyin[A_Index+1])
				}
		} Else {
			If allpinyin.Length()=0
				allpinyin.Push(tstr)
			Else
				Loop % allpinyin.Length()
					allpinyin[A_Index] .= "''" tstr
		}
	}
	res:=""
	loop % allpinyin.Length()
		res .= "'" allpinyin[A_Index] "',"
	Return "(" SubStr(res,1,-1) ")"
}

Get_jianpin(DB,scheme,str,RegExObj:="",lianxiang:=1,LimitNum:=100,cjjp:=false){
	local
	Critical
	global SQL_buffer, customspjm
	cpfg:=0, ystr:=Trim(str, "'")
	If (scheme)
		str:=pyfenci(str,scheme,1)
	str:=StrReplace(str, "'", "''"), str:=StrReplace(str, "on'", "ong'"), tstr:=Trim(RegExReplace(str, "([a-z]h?)[a-gi-z]+", "$1", nCount), "'")
	tstr:=RegExReplace(tstr, "([csz])h", "$1")
	If (nCount){
		rstr:=RegExReplace(str, "'([^aoe]h?)'", "'$1[a-z]*'")
		Loop % RegExObj.Length()
			rstr:=RegExReplace(rstr, RegExObj[A_Index,1], RegExObj[A_Index,2])
	} Else If (scheme="pinyin"){
		tRegEx:=""
		For _,key In ["c","s","z"]
			If InStr(str,key "h")&&!InStr(RegExObj[1,1],key)
				tRegEx .= key
		If (tRegEx){
			rstr:=RegExReplace(str, "'([^aoe]h?)'", "'$1[a-z]*'")
			If (StrLen(tstr)=1)
				LimitNum:=100
		}
	} Else {
		tRegEx:=""
		For _,key In ["c","s","z"]
			If InStr(str,key)&&!InStr(RegExObj[1,1],key)
				tRegEx .= key
		If (tRegEx){
			rstr:=RegExReplace(str, "'([" tRegEx "]h?)'", "'$1[^h]*'")
			If (ystr~="[aoe]{2}")
				rstr:=RegExReplace(rstr, "'([^aoe]h?)'", "'$1[a-z]*'")
			Else
				rstr:=RegExReplace(rstr, "'([a-z]h?)'", "'$1[a-z]*'")
			If (StrLen(tstr)=1)
				LimitNum:=100
		}
	}
	If (rstr="")
		If (str~="^''[aoe](''[aoe])*''$")
			rstr:=str
		Else
			LimitNum:=100
	rstr:=Trim(rstr,"'"), lsm:="o"
	If (cpfg:=lianxiang){
		If (rstr~="[\.\*\?\|\[\]]")
			_SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp>='" tstr "''a' AND jp<'" tstr "''{' AND key REGEXP '^" rstr "' ORDER BY weight DESC LIMIT 3"
		Else
			_SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp>='" tstr "''a' AND jp<'" tstr "''{'" (rstr?" AND key>='" rstr "''a' AND key<'" rstr "''{'":"") " ORDER BY weight DESC LIMIT 3"
	} Else If (cjjp&&(scheme~="i)^(abc|wr|sg)sp"||(lsm:=customspjm[scheme, "0"])~="^[a-zA-Z]$")&&InStr(str, lsm)){
		tstr:=StrReplace(tstr, lsm, "_", nCount:=0), rstr:=StrReplace(tstr, "_", "[aoe]")
		If (nCount>4 )
			_SQL:="SELECT key,value,weight FROM 'pinyin' WHERE " Format("((jp>='{:s}a' AND jp<'{:s}b') OR (jp>='{:s}e' AND jp<'{:s}f') OR (jp>='{:s}o' AND jp<'{:s}p')) AND", SubStr(tstr, 1, InStr(tstr, "_")-1)) " jp like '" tstr "' AND jp REGEXP '^" rstr "$' ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
		Else
			_SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp IN " enumlsm(tstr) " ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
	} Else {
		If (rstr~="[\.\*\?\|\[\]]")
			_SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp='" tstr "' AND key REGEXP '^" rstr "$' ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
		Else
			_SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp='" tstr "'" (rstr?" AND key='" rstr "'":"") " ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
	}
	If DB.GetTable(_SQL,Result){
		If (Result.RowCount){
			If (cpfg){
				
			} Else {				
				Loop % Result.RowCount
					Result.Rows[A_Index, -1]:=ystr, Result.Rows[A_Index, 0]:="pinyin|" A_Index, Result.Rows[A_Index, 4]:=Result.Rows[1, 3]
				; Result.Rows[1, 0]:="pinyin|0"
			}
			SQL_buffer[ystr]:=_SQL
		}
		Result.Rows[0]:=ystr
		Return Result.Rows		; {1:[key1,value1],2:[key2,value2]...}
	} Else
		Return []
}

checkfenci(DB,str){
	local
	static history:={0:0}
	If !DB
		Return -1
	If (history[0]>500)
		history:={0:0}
	If (history[str]!="")
		Return history[str]
	str:=StrReplace(str, "'", "''")
	tstr:=RegExReplace(Trim(str, "'"), "([a-z])[a-z]+", "$1")
	rstr:=RegExReplace(str, "'([csz]h?)'", "'$1.*'")
	_SQL:="SELECT weight FROM pinyin WHERE jp='" tstr "' AND key REGEXP '^" Trim(rstr,"'") "$' ORDER BY weight DESC LIMIT 1"
	If DB.GetTable(_SQL,Result){
		If (Result.Rows[1][1])
			Return Result.Rows[1][1], history[str]:=Result.Rows[1][1], history[0]++
		Else
			Return 0, history[str]:=0, history[0]++
	} Else
		Return -1
}

enumlsm(str){
	local res, t
	res:=[""], t:=""
	Loop, Parse, str
	{
		If (A_LoopField="_"){
			len:=res.Length()
			If (t!=""){
				Loop % len
					res[A_Index] .= t
				t:=""
			}
			Loop % len {
				res.Push(res[A_Index] "e")
				res.Push(res[A_Index] "o")
				res[A_Index] .= "a"
			}
		} Else {
			t .= A_LoopField
			continue
		}
	}
	str:=""
	Loop % res.Length()
		res[A_Index]:=res[A_Index] t, str .= ",'" res[A_Index] "'"
	return "(" LTrim(str, ",") ")"
}
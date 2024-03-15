; Get_sanma(DB,str,rt:=""){
; 	len:=StrLen(str)
; 	Switch len
; 	{
; 		Case 1:
; 			DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE jp>='" str "' AND jp<'" Chr(Ord(str)+1) "' AND length(jp)=2 ORDER BY weight DESC",Result)
; 		Case 2:
; 			DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE jp='" str "' ORDER BY weight DESC",Result)
; 		Case 3:
; 			DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE jp='" SubStr(str,1,2) "' AND key='" str "' ORDER BY weight DESC",Result)
; 			If (Result.RowCount=0)&&!rt
; 				DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE jp>='" SubStr(str,1,2) " " SubStr(str,0) "' AND jp<'" SubStr(str,1,2) " " Chr(Ord(SubStr(str,0))+1) "' AND length(jp)=5 AND jp like '" SubStr(str,1,2) " " SubStr(str,0) "_' AND key like '" SubStr(str,1,2) "_ " SubStr(str,0) "__' ORDER BY weight DESC",Result)
; 		Case 4:
; 			DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE jp='" SubStr(str,1,2) " " SubStr(str,3) "' ORDER BY weight DESC",Result)
; 			If (Result.RowCount=0)&&!rt
; 				DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE jp>='" SubStr(str,1,2) " " SubStr(str,0) "' AND jp<'" SubStr(str,1,2) " " Chr(Ord(SubStr(str,0))+1) "' AND length(jp)=5 AND jp like '" SubStr(str,1,2) " " SubStr(str,0) "_' AND key like '" SubStr(str,1,3) " " SubStr(str,0) "__' ORDER BY weight DESC",Result)
; 		Default:
; 			DB.GetTable(Clipboard:="SELECT key,value,weight FROM 'sanma' WHERE jp>='" SubStr(str,1,2) "' AND jp<'" SubStr(str,1,1) Chr(Ord(SubStr(str,2,1))+1) "' AND length(jp)>" ((StrLen(str)+2)//3)*3-2 " AND length(jp)<" ((StrLen(str)+1)//2)*3 " AND ((jp like '" SubStr(str,1,2) " " SubStr(str,3,2) "%' OR jp like '" SubStr(str,1,2) " " SubStr(str,4,2) "%') AND (jp like '%" SubStr(str,-1) "' OR jp like '%" SubStr(str,-2,2) "') AND erjiayi(key,'" str "'))",Result)
; 			If (Result.RowCount=0)&&!rt
; 				DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE jp>='" SubStr(str,1,2) "' AND jp<'" SubStr(str,1,1) Chr(Ord(SubStr(str,2,1))+1) "' AND length(jp)>" ((StrLen(str)+2)//3)*3-2 " AND length(jp)<" ((StrLen(str)+1)//2)*3 " AND ((jp like '" SubStr(str,1,2) " " SubStr(str,3,2) "%' OR jp like '" SubStr(str,1,2) " " SubStr(str,4,2) "%') AND jp like '%" SubStr(str,0) "_' AND erjiayi(key,'" str "'))",Result)
; 	}
; 	If (Result.RowCount){
; 		Loop % Result.RowCount
; 			Result.Rows[A_Index, -1]:=ystr, Result.Rows[A_Index, 0]:="sanma|" A_Index, Result.Rows[A_Index, 4]:=Result.Rows[1, 3]
; 		Return Result.Rows		; {1:[key1,value1],2:[key2,value2]...}
; 	} Else
; 		Return []
; }
Get_sanma(DB,str,rt:=""){
	len:=StrLen(str), Result:=[]
	Switch len
	{
		Case 1:
			If (!rt)
				DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE key>='" str "' AND key<'" Chr(Ord(str)+1) "' AND length(key)=3 ORDER BY weight DESC",Result)
		Case 2:
			DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE key>='" str "' AND key<'" SubStr(str,1,1) Chr(Ord(SubStr(str,2))+1) "' AND length(key)=3 ORDER BY weight DESC",Result)
		Case 3:
			DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE key='" str "' ORDER BY weight DESC",Result)
			If (Result.RowCount=0)&&!rt
				DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE key>='" SubStr(str,1,2) "' AND key<'" SubStr(str,1,1) Chr(Ord(SubStr(str,2,1))+1) "' AND length(key)=7 AND key like '" SubStr(str,1,2) "_ " SubStr(str,0) "__' ORDER BY weight DESC",Result)
		Case 4:
			DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE key>'" SubStr(str,1,2) "' AND key<'" SubStr(str,1,1) Chr(Ord(SubStr(str,2,1))+1) "' AND length(key)=7 AND key like '" SubStr(str,1,2) "_ " SubStr(str,3,2) "_' ORDER BY weight DESC",Result)
			If (Result.RowCount=0)&&!rt
				DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE key>='" SubStr(str,1,3) " " SubStr(str,0) "' AND key<'" SubStr(str,1,3) " " Chr(Ord(SubStr(str,0))+1) "' AND length(key)=7 ORDER BY weight DESC",Result)
		Default:
			DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE (key>='" SubStr(str,1,2) "' AND key<'" SubStr(str,1,1) Chr(Ord(SubStr(str,2,1))+1) "' AND length(key)>" ((len+2)//3)*4-2 " AND length(key)<" ((len+1)//2)*4 " AND (key like '" SubStr(str,1,3) " " SubStr(str,4,2) "_%' OR key like '" SubStr(str,1,2) "_ " SubStr(str,3,2) "_%') AND (key like '%" SubStr(str,-1) "_' OR key like '%" SubStr(str,-2) "')) AND erjiayi(key,'" str "')",Result)
			If (Result.RowCount=0)&&!rt
				DB.GetTable("SELECT key,value,weight FROM 'sanma' WHERE (key>='" SubStr(str,1,2) "' AND key<'" SubStr(str,1,1) Chr(Ord(SubStr(str,2,1))+1) "' AND length(key)>" ((len+2)//3)*4-2 " AND length(key)<" ((len+1)//2)*4 " AND (key like '" SubStr(str,1,3) " " SubStr(str,4,2) "_%' OR key like '" SubStr(str,1,2) "_ " SubStr(str,3,2) "_%') AND key like '%" SubStr(str,0) "__') AND erjiayi(key,'" str "')",Result)
	}
	If (Result.RowCount){
		Loop % Result.RowCount
			Result.Rows[A_Index, -1]:=str, Result.Rows[A_Index, 0]:="sanma|" A_Index, Result.Rows[A_Index, 4]:=Result.Rows[1, 3]
		Return Result.Rows		; {1:[key1,value1],2:[key2,value2]...}
	} Else
		Return []
}

sanmamethod(input){
	global srf_all_Input_, save_field_array, history_field_array, DB
	Loop_num:=0, history_cutpos:=[0], index:=0, checkstr:=""
	;qu ci bing qie fen
	srf_all_Input_["tip"]:=srf_all_Input_trim:=input
	; 正向
	Loop % save_field_array.Length()
	{
		If (save_field_array[A_Index,0]=""){
			index:=A_Index
			Break
		}
		checkstr .= save_field_array[A_Index,0]
		If InStr("^" input, "^" checkstr)&&(checkstr=input||save_field_array[A_Index,0]~=RegExReplace(save_field_array[A_Index,1,1] " "," ","?")){
			history_cutpos.Push(StrLen(checkstr))
		} Else {
			index:=A_Index
			Break
		}
	}
	If (index)
		save_field_array.RemoveAt(index, save_field_array.Length()-index+1)
	srf_all_Input_len:=StrLen(input)
	If (save_field_array.Length()>0){
		; If history_cutpos.Length()>1&&SubStr(input,history_cutpos[history_cutpos.Length()],1)!="'"
		; 	history_cutpos.Pop(), save_field_array.Pop()
		Loop % history_cutpos.Length()
		{
			If ((srf_all_Input_trim_off:=SubStr(input,history_cutpos[A_Index]+1))="")
				Break
			If StrLen(srf_all_Input_trim_off)>24
				Continue
			
			If !history_field_array.HasKey(srf_all_Input_trim_off){
				jichu_for_select:=Get_sanma(DB, srf_all_Input_trim_off)
				If (jichu_for_select[1, 2]=""){
					If (StrLen(srf_all_Input_trim_off)>2){
						history_field_array[srf_all_Input_trim_off]:={0:srf_all_Input_trim_off}
						Continue
					} Else {
						Break
					}
				}
			} Else
				jichu_for_select:=history_field_array[srf_all_Input_trim_off]
			If (jichu_for_select[1, 2]=""){
				If (StrLen(srf_all_Input_trim_off)>2)
					Continue
				Else
					Break
			} Else {
				jichu_for_select[0]:=srf_all_Input_trim_off
				history_field_array[srf_all_Input_trim_off]:=jichu_for_select
				tarr:={}, Ln:=A_Index-1
				Loop % Ln
					If save_field_array[A_Index, 0]
						tarr.Push(save_field_array[A_Index])
				tarr.Push(jichu_for_select)
				save_field_array:=tarr, tarr:="", history_cutpos:=[0]
				Loop % save_field_array.Length()
					history_cutpos[A_Index+1]:=history_cutpos[A_Index]+StrLen(save_field_array[A_Index,0])+1
			}
		}
	}
	If (tpos:=history_cutpos[history_cutpos.Length()])<srf_all_Input_len
	{
		cutpos:=srf_all_Input_len+1
		Loop
		{
			If (cutpos-=1)<tpos+1
				Break
			srf_Input_trim_left:=SubStr(input,tpos+1,cutpos-tpos)
			; ToolTip % tpos "|" cutpos "|" srf_Input_trim_left
			If StrLen(srf_Input_trim_left)>24
				Continue
			srf_Input_trim_right:=SubStr(input,cutpos+1)
			If srf_Input_trim_left&&!history_field_array.HasKey(srf_Input_trim_left){
				jichu_for_select:=Get_sanma(DB, srf_Input_trim_left,srf_Input_trim_right)
				If (jichu_for_select[1, 2]=""){
					history_field_array[srf_Input_trim_left]:={0:srf_Input_trim_left}
					If (StrLen(srf_Input_trim_left)>2)
						Continue
					Else
						Break
				} Else
					history_field_array[srf_Input_trim_left]:=jichu_for_select, history_field_array[srf_Input_trim_left, 0]:=srf_Input_trim_left
			}
			If (history_field_array[srf_Input_trim_left, 1, 2]="")||(srf_Input_trim_right&&(SubStr(srf_Input_trim_left,0)=SubStr(history_field_array[srf_Input_trim_left,1,1],-2,1)))
				Continue
			If (srf_Input_trim_left!="")
				save_field_array.Push(history_field_array[srf_Input_trim_left]), history_cutpos[history_cutpos.Length()+1]:=history_cutpos[history_cutpos.Length()]+StrLen(srf_Input_trim_left)
			; history_cutpos:=[0]
			; Loop % save_field_array.Length()
			; 	history_cutpos[A_Index+1]:=history_cutpos[A_Index]+StrLen(save_field_array[A_Index,0])+1
			tpos:=history_cutpos[history_cutpos.Length()], cutpos:=srf_all_Input_len+1
		}
	}
	;zu he
	jichu_for_select:="", SearchResult:=[]
	If (save_field_array.Length()>1){
		SearchResult:=[firstzhuju(save_field_array)]
		SearchResult[1,1]:=StrReplace(SearchResult[1,1],"'"," ")
		Loop % save_field_array[1].Length()
			SearchResult.Push(CopyObj(save_field_array[1, A_Index]))
	} Else
		SearchResult:=CopyObj(save_field_array[1])
	; MsgBox
	If InStr(SearchResult[1, 1], " "){
		zi:=SubStr(input ,1, 3)
		; If (history_field_array[zi,1,2]!=""||StrLen(history_field_array[zi,1,2])=1)
		; 	Loop % history_field_array[zi].Length()
		; 		SearchResult.Push(CopyObj(history_field_array[zi, A_Index]))
		If (history_field_array[zi:=SubStr(zi,1,2),1,2]!="")
			Loop % history_field_array[zi].Length()
				SearchResult.Push(CopyObj(history_field_array[zi, A_Index]))
	}
	If (SearchResult[1, 0]="")
		SearchResult[1, 0]:="sanma"
	; If CloudInput&&(StrLen(SearchResult[1, 2])>3)
	; 	SetTimer, BDCloudInput, -10
	Return SearchResult
}
erjiayi(Context, ArgC, Values) {
	Result := 0
	If (ArgC = 2) {
		AddrN := DllCall("SQLite3.dll\sqlite3_value_text", "Ptr", NumGet(Values + 0, "UPtr"), "Cdecl UPtr")
		AddrH := DllCall("SQLite3.dll\sqlite3_value_text", "Ptr", NumGet(Values + A_PtrSize, "UPtr"), "Cdecl UPtr")
		Result := RegExMatch(StrGet(AddrH, "UTF-8"), "^" RegExReplace(StrReplace(StrGet(AddrN, "UTF-8")," ","?") "?","([a-z][a-z]\?)$","($1)?") "$")
	}
	DllCall("SQLite3.dll\sqlite3_result_int", "Ptr", Context, "Int", !!Result, "Cdecl") ; 0 = false, 1 = trus
}
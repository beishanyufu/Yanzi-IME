; ##################################################################################################################################################################
; # 声明：此文件基于开源仓库 <https://gitee.com/orz707/Yzime> (Commit:d1d0d9b15062de7381d1e7649693930c34fca53d) 
; # 中的同名文件修改而来，并使用相同的开源许可 GPL-2.0 进行开源，具体的权利、义务和免责条款可查看根目录下的 LICENSE 文件
; # 修改者：北山愚夫
; # 修改时间：2024年3月15日 
; ##################################################################################################################################################################

Registrationhotkey:		; 注册快捷键
	Try {								; 注册切换热键
		Hotkey If, !(srf_inputing&&Switch~="Shift")
		Hotkey, %Switch%, srfSwitch, On
		If !InStr(Switch,"&")
			If (Switch~="i)^(L|R)?(Win|Alt|Shift|Control|Ctrl|CapsLock)$")
				Try Hotkey, % Switch " & vkFF", AndLButton, On
			Else If RegExMatch(Switch,".*([\+\^!#<>]).+")
				Try Hotkey, % RegExReplace(Switch,".*([\+\^!#<>]).+","$1") "vkFF", AndLButton, On
		Hotkey If, A_IsSuspended&&TSFmode
		Hotkey %Switch%, Undisabled, On
		Hotkey If
	} Catch
		MsgBox, 16, 错误, 注册切换热键失败，请手动在[选项>控制]中设置其他热键！！！, 3

	Hotkey If, Showdwxgtip
	Loop 26
		Hotkey % Chr(96+A_Index), dwselect
	Hotkey If
	cncharmode_funobj:=Func("cncharmode").Bind()
	Hotkey If, % cncharmode_funobj
	Loop 26 {
		Hotkey, % Chr(96+A_Index), cnInputchar, On
		Hotkey, % "+" Chr(96+A_Index), cnInputchar, On
	}
	Hotkey, If
	registersymbolhotkey(srf_symbol,,,,0)
	If InStr(Yzimeini["Hotkey","23hx"],";'")
		registersymbolhotkey(";",2,0,""), registersymbolhotkey("'",3,0,"")
	Hotkey, If, srf_inputing
	For key In {"Shift":"","Ctrl":""}
		If InStr(Yzimeini["Hotkey","23hx"],key){
			_:=Func("select_for_num").Bind(2)
			Hotkey, L%key%, %_%
			_:=Func("select_for_num").Bind(3)
			Hotkey, R%key%, %_%
		}
	Loop 5 {
		Hotkey, % A_Index, srf_select_ci, On
		Hotkey, % "Numpad" A_Index, srf_select_ci, On
	}
	Loop 5 {
		Hotkey, % Mod(A_Index+5,10), cnInputchar, On
		Hotkey, % "Numpad" Mod(A_Index+5,10), cnInputchar, On
	}
	Hotkey, PgUp, lessWait, On
	Hotkey, PgDn, MoreWait, On
	Hotkey, Space, , T2
	Hotkey, If
	Hotkey If, srf_inputing&&shurulei!="xingma"
	If (bmhg)
		Loop 26
			Hotkey, % "^" Chr(96+A_Index), searchinsertpos
	Hotkey, If
Return
#If Showdwxgtip
#If srf_inputing&&shurulei!="xingma"
#If
registerschemhotkey(key,scheme,ty:=""){
	global
	local _
	If (key=""){
		shurulei:=scheme~="pinyin|(sp|双拼)$"?"pinyin":ty?ty:"xingma"
		Inputscheme:=Yzimeini.Settings.Inputscheme:=pinyince[scheme]?pinyince[scheme]:scheme
		TrayTip, 切换输入方案, 当前方案：%scheme%, 1
	} Else {
		_:=Func("registerschemhotkey").Bind("",scheme,ty)
		Hotkey %key%, %_%
	}
}
registersymbolhotkey(keys,sel:="",dp:="",pr:="",tp:=1){
	local
	global cncharmode_funobj, func_key, lspy_key
	Hotkey If, % cncharmode_funobj
	If (tp){
		key:=keys
		_:=Func("Sendsymbol").Bind(sel,dp,pr?pr:(InStr(func_key "'" lspy_key,key)?"leading":key=","?"hotstrings":key="."?"functions":""))
		Hotkey, %key%, %_%
	} Else
		For key In keys {
			_:=Func("Sendsymbol").Bind(sel,dp,pr?pr:(InStr(func_key "'" lspy_key,key)?"leading":key=","?"hotstrings":key="."?"functions":""))
			Hotkey, %key%, %_%
		}
	Hotkey If
}
Showdwxgtip(time:=0.35){
	global
	static presst
	local t
	t:=A_TickCount
	KeyWait Space, T%time%
	If (ErrorLevel){
		Showdwxgtip:=1
		DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction, srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-z]+$"?SymbolFont:TextFont)
		KeyWait Space
		presst:=A_TickCount-t
		SetTimer resetpresst, -30
		Return 1
	} Else If (presst>time*1000)
		Return 1
	Return 0
	resetpresst:
		presst:=0
	Return
}
Sendsymbol(sel:="",dp:="",pr:=""){
	global
	local Match, t, t2
	static presst:=0, shiftsymbol:={"/":"?",";":":","'":"""",",":"<",".":">","\":"|","[":"{","]":"}","-":"_","=":"+","``":"~"}
	static pair:=[]
	ThisHotkey:=GetKeyState("Shift", "P")&&shiftsymbol[A_ThisHotkey]?shiftsymbol[A_ThisHotkey]:A_ThisHotkey
	dp:=dp=""?(InStr("``!$^();:"",.<>?[]{}\",ThisHotkey)?1:0):dp
	sel:=sel=""?(dp?1:0) (InStr(";',.",ThisHotkey)+1):sel
	If (srf_inputing){
		If (srf_all_Input=eng_key){
			If (!EnSymbol), t2:=-1
				t2:=EnSymbol, EnSymbol:=true
			Gosub Sendsymbol
			Gosub srf_value_off
			If (t2!=-1)
				EnSymbol:=t2
		} Else If (ThisHotkey=srf_all_input&&ThisHotkey!=";"){
			Gosub srf_value_off
			Gosub Sendsymbol
		} Else If (ThisHotkey=func_key){
			If !InStr((insertpos>1?SubStr(srf_all_Input, insertpos-1, 1):"") SubStr(srf_all_Input, Max(0,insertpos), 1),func_key)
				&&!(srf_func_table[modeMatch.Value[1], "Name"]="get_hotstring"){
				srf_all_Input:=insertchar(srf_all_Input,func_key,insertpos)
				Settimer srf_tooltip, -1
			}
		} Else If InStr(srf_all_input,func_key){
			If !InStr("[]",ThisHotkey)&&(srf_all_input=func_key||(srf_all_Input~="^" (func_key="\"?"\\":func_key)&&!(srf_all_input~="i)^" (func_key="\"?"\\":func_key) "[a-z" (func_key="\"?"\\":func_key) "]+$"))){
				srf_all_Input:=insertchar(srf_all_Input,ThisHotkey,insertpos)
				Settimer srf_tooltip, -1
			} Else If InStr(fanyefg,ThisHotkey){
				Gosub % (SubStr(fanyefg,1,1)=ThisHotkey||InStr(fanyefg," " ThisHotkey)?"LessWait":"MoreWait")
			} Else If (ThisHotkey="."&&srf_Default_Func[srf_func_table[modeMatch.Value[1], "Name"],2]~="\d"){
				srf_all_Input:=insertchar(srf_all_Input,ThisHotkey,insertpos)
				Settimer srf_tooltip, -1
			} Else If SubStr(sel,0)&&(presst<300)
				select_for_num(SubStr(sel,0))
		} Else If (pr="hotstrings"&&hotstring_for_select[1, 1]){
			KeyWait, %A_ThisHotkey%, T0.25
			If (ErrorLevel&&hotstring_for_select.Length()>1){
				t:=A_TickCount
				srf_all_Input:=(srf_Custom_Func["magic"]?srf_Custom_Func["magic"]:"magic") func_key srf_all_Input
				Gosub srf_tooltip
				KeyWait, %A_ThisHotkey%
				presst:=A_TickCount-t
				SetTimer Resetsymbolpresst, -10
			} Else
				srf_HotStringSelect(hotstring_for_select)
		} Else If (pr="functions"&&Function_for_select[1, 1]){
			KeyWait, %A_ThisHotkey%, T0.25
			If (ErrorLevel&&Function_for_select.Length()>1){
				t:=A_TickCount
				srf_all_Input:=(srf_Custom_Func["run"]?srf_Custom_Func["run"]:"run") func_key srf_all_Input
				Gosub srf_tooltip
				KeyWait, %A_ThisHotkey%
				presst:=A_TickCount-t
				SetTimer Resetsymbolpresst, -10
			} Else
				srf_RunSelect(Function_for_select)
		} Else If InStr(fanyefg,ThisHotkey){
			Gosub % (SubStr(fanyefg,1,1)=ThisHotkey||InStr(fanyefg," " ThisHotkey)?"LessWait":"MoreWait")
		} Else If (srf_all_Input){
			If (InStr(ycdzfg,ThisHotkey)&&!InStr(srf_all_Input,func_key)){
				SendInput(SubStr(jichu_for_select_Array[localpos+ListNum*waitnum,2],(InStr("[-",ThisHotkey)?1:0),1))
				Gosub srf_value_off
			} Else If (ThisHotkey=";"&&Inputscheme~="(sg|wr)sp"&&!InStr(pyfenci(insertchar(srf_all_Input,ThisHotkey,insertpos),Inputscheme,1),ThisHotkey)){
				srf_all_Input:=insertchar(srf_all_Input,ThisHotkey,insertpos), waitnum:=numberfg:=0
				Settimer srf_tooltip, -1
			} Else If (((IsPinyin||Inputscheme="pinyin")&&ThisHotkey="'")||(shurulei="xingma"&&Learning&&ThisHotkey="``"))&&!fencifu(){
			} Else If (ThisHotkey="\"&&Inputscheme~="sp$"&&jichu_for_select_Array[1,0]~="pinyin"){
				fencifu()
			} Else If SubStr(sel,1,1){
				select_for_num(dp?1:SubStr(sel,1,1))
				If (dp){
					If (TSFmode){
						t:=A_TickCount
						SetTimer CheckTSFInputSuccess, Off
						While (A_TickCount-t<25&&TSFMem.Get(20, "UShort"))
							Sleep 1
						If (A_TickCount-t>25){
							SendInput % "{Text}" (StrGet(TSFMem._buf+TSFMem._headsize, "UTF-16"))
							TSFMem.Clear()
						}
					}
					Gosub Sendsymbol
				}
			} Else If (ThisHotkey="'")
				fencifu()
		} Else {
			Gosub srf_value_off
			Gosub Sendsymbol
		}
	} Else If (presst<300){
		srf_direction:=Textdirection="Horizontal" ? 0 : 1
		If (ThisHotkey="."&&numberfg)
			SendInput(".", SendDelaymode)
		Else If (Learning&&shurulei="xingma"&&ThisHotkey="``"){
			ToolTipText:=srf_all_input:=ThisHotkey, jichu_for_select_Array:=[], Begininput()
			jichu_for_select_Array[1,2]:=srf_symbol[ThisHotkey,(srf_mode&&!(EnSymbol||Englishmode)&&!GetKeyState("CapsLock", "T"))+1]
			srf_for_select_obj:=[srf_for_select:="1." jichu_for_select_Array[1,2]]
			srf_for_select_obj.Push("2.形码引导造词"), srf_for_select .= (Textdirection="Horizontal"?"  ":"`n") srf_for_select_obj[2]
			Gosub showhouxuankuang
		} Else If (pr="leading"&&!(Englishmode&&ThisHotkey=eng_key)){
			ToolTipText:=srf_all_input:=ThisHotkey, jichu_for_select_Array:=[], Begininput()
			jichu_for_select_Array[1,2]:=srf_symbol[ThisHotkey,(srf_mode&&!(EnSymbol||Englishmode)&&!GetKeyState("CapsLock", "T"))+1]
			srf_for_select_obj:=[srf_for_select:="1." jichu_for_select_Array[1,2]]
			If (shiftsymbol[ThisHotkey]){
				srf_for_select_obj.Push("2." jichu_for_select_Array[2,2]:=srf_symbol[shiftsymbol[ThisHotkey],(srf_mode&&!(EnSymbol||Englishmode)&&!GetKeyState("CapsLock", "T"))+1]), srf_for_select .= (Textdirection="Horizontal"?"  ":"`n") srf_for_select_obj[2]
				If (ThisHotkey=eng_key)
					srf_for_select_obj.Push("3.临时英语输入"), srf_for_select .= (Textdirection="Horizontal"?"  ":"`n") srf_for_select_obj[3]
				Else If (ThisHotkey=func_key)
					srf_for_select_obj.Push("3.多功能键输入/?查看帮助"), srf_for_select .= (Textdirection="Horizontal"?"  ":"`n") srf_for_select_obj[3]
			}
			Gosub showhouxuankuang
		} Else
			Gosub Sendsymbol
	}
	numberfg:=0
	Return
	Sendsymbol:
		RegExMatch(t:=srf_symbol[ThisHotkey,(srf_mode&&!(EnSymbol||Englishmode)&&!GetKeyState("CapsLock", "T"))+1],"i)\{[a-z]+\}",Match)
		If (StrLen(t)=2&&SubStr(t,1,1)!=SubStr(t,0)){
			pair[t]:=!(pair[t]=""?1:pair[t])
			SendInput(SubStr(t,pair[t]+1,1), SendDelaymode)
		} Else {
			SendInput(StrReplace(t,Match), SendDelaymode)
			If (Match){
				If (TSFmode){
					t:=A_TickCount
					SetTimer CheckTSFInputSuccess, Off
					While (A_TickCount-t<25&&TSFMem.Get(20, "UShort"))
						Sleep 1
					If (A_TickCount-t>25){
						SendInput % "{Text}" (StrGet(TSFMem._buf+TSFMem._headsize, "UTF-16"))
						TSFMem.Clear()
					}
				}
				SendInput %Match%
			}
		}
		EndInput()
	Return
	Resetsymbolpresst:
		presst:=0
	Return
}

cncharmode(){
	global srf_mode, srf_inputing
	Return srf_inputing||(srf_mode&&!GetKeyState("CapsLock", "T"))
}

+^F12::
	Suspend
	Gosub srfreload
Return
!^F12::
srfsuspend:
	Suspend
	Gosub srf_value_off
	If (A_IsSuspended){
		SetYzLogo(srf_mode:=0, 0)
		DirectIMEandCursor(srf_mode)
		; Menu, Tray, Icon, %DataPath%Yzime.icl, 1, 1
		Menu Tray, NoIcon
		Menu, Tray, Rename, 8&, 恢复
		SetIMEStatus(1,1)
		OnClipboardChange("ClipChanged", 0)
	} Else {
		Menu Tray, Icon
		Menu, Tray, Rename, 8&, 禁用
		OnClipboardChange("ClipChanged", 1)
		_EventProc(0, 3, WinExist("A"))
	}
Return
Inputchar:
	SendInput(GetKeyState("CapsLock", "T")^GetKeyState("Shift", "P")?Format("{:U}", LTrim(A_ThisHotkey,"+")):LTrim(A_ThisHotkey,"+"))
Return
#If !(srf_inputing&&Switch~="Shift")
srfSwitch:
Switchstate:
	If GetKeyVK(tvar:=RegExReplace(A_ThisHotkey,"i)^([<>\$\^!\+#]+)?([a-z ]+&[ ]+)?([a-z\d]+|.)$","$3"))
		KeyWait, % tvar
	If !Double||(A_ThisHotkey&&(A_PriorHotkey=A_ThisHotkey)&&(A_TimeSincePriorHotkey<400)){
		SetYzLogo(srf_mode:=!srf_mode, A_ThisLabel="srfSwitch")
		DirectIMEandCursor(srf_mode)
		If (!srf_mode){
			If (Shiftfg=2)&&(A_ThisHotkey~="Shift$")&&srf_inputing
				SendInput(Trim(srf_all_Input,eng_key func_key), SendDelaymode)
			Gosub srf_value_off
		}
		SetTimer, ToolTipInputStatus, -100
	}
Return
#If
AndLButton:
	Suspend, Permit
Return
#If A_IsSuspended&&TSFmode
Undisabled:
	Suspend Permit
	If TSFMem.Get(10, "UShort")
		Gosub srfsuspend
	Else
		SendInput {vke0}
Return
#If srf_inputing&&!InStr(srf_all_Input,func_key)
	^1::
	^2::
	^3::
	^4::
	^5::srf_SetFirst(SubStr(A_ThisHotkey,0))

	^Up::
	^Down::srf_SetFirst(localpos, A_ThisHotkey="^Down"?1:-1)

	^!1::
	^!2::
	^!3::
	^!4::
	^!5::srf_delete(SubStr(A_ThisHotkey,0))

	LAlt::ShowNotes()
#If

; 空格、0-9 定义
#If srf_inputing
	Space::
		If srf_symbol[srf_all_Input] {
			RegExMatch(jichu_for_select_Array[localpos,2],"i)\{[a-z]+\}",Match)
			SendInput(StrReplace(jichu_for_select_Array[localpos,2],Match), SendDelaymode)
			If (Match)
				SendInput, %Match%
			Gosub srf_value_off
		} Else {
			If (dwxg&&ToolTipStyle=2&&localpos=1&&(jichu_for_select_Array[1,-2]=""&&jichu_for_select_Array[1,0]~="pinyin"&&StrLen(jichu_for_select_Array[1,2])>1)){
				If Showdwxgtip()
					Return
			}
			select_for_num(localpos)
		}
	Return
	srf_select_ci:
		select_for_num(SubStr(A_ThisHotkey,0))
	Return

	fencifu(){
		global
		local tvar
		static qiecistr
		If ((insertpos>1?SubStr(srf_all_Input, insertpos-1, 1):"") SubStr(srf_all_Input, Max(0,insertpos), 1)~="['\\``]")
			Return 1
		If (A_ThisHotkey="\")&&!insertpos&&!InStr(srf_all_Input, func_key){
			If !InStr(srf_all_Input_["tip"],"'")
				Return 1
			qiecistr:=save_field_array[1,0]
			qiecistr:=RegExReplace(Trim(qiecistr,"'"),"(^|')[a-z]+$")
			If (qiecistr){
				RegExMatch(srf_all_Input_["tip"] "'", "([a-z]+'){" StrSplit(qiecistr,"'").Length() "}", tvar)
				srf_all_Input:=RegExReplace(StrReplace(srf_all_Input,"\"), "(" StrReplace(tvar,"'","'?") ")","$1\", , 1)
			} Else
				srf_all_Input:=StrReplace(srf_all_Input,"\"), save_field_array.RemoveAt(1)
			jichu_for_select_Array:=pinyinmethod(srf_all_Input,Inputscheme)
			Gosub houchuli
			Gosub srf_tooltip_fanye
		} Else {
			srf_all_Input:=insertchar(srf_all_Input,A_ThisHotkey,insertpos), waitnum:=0
			Settimer srf_tooltip, -1
		}
	}

	;srf_all_input模式 backspace键、esc键、enter键、Lshift键 定义
	Delete::
		srf_all_Input:=delchar(srf_all_Input,insertpos,1), Showdwxgtip:=waitnum:=0, modeMatch:=tfzm:=""
		If (srf_all_Input = "")
			Gosub srf_value_off
		Else If (srf_all_Input = func_key){
			ToolTipText:=func_key, srf_for_select:="(" func_key ") " srf_symbol[func_key,2-(EnSymbol||Englishmode)], srf_for_select_obj:=[srf_symbol[func_key,2-(EnSymbol||Englishmode)]]
			Gosub showhouxuankuang
		} Else
			Settimer srf_tooltip, -1
	Return
	BackSpace::
		Showdwxgtip:=0, srf_direction:=Textdirection="Horizontal" ? 0 : 1
		If (!srf_mode&&SubStr(srf_all_Input,0)=func_key)
			Goto srf_value_off
		If (dwselect){
			If (tfzm=""){
				dwselect:=0
				; 刷新候选框以视觉删除间接辅助码引导符
				; Gosub showhouxuankuang 
				Gosub srf_tooltip_fanye
			}
			Else {
				tfzm:=SubStr(tfzm, 1, -1)
				jichu_for_select_Array:=pinyinmethod(srf_all_Input, Inputscheme), waitnum:=0
				Gosub houchuli
				Gosub srf_tooltip_fanye
			}
			Return
		}
		srf_all_Input:=delchar(srf_all_Input,insertpos), waitnum:=0, modeMatch:=tfzm:=""
		If (srf_all_Input = "")
			Gosub srf_value_off
		Else If (srf_symbol[srf_all_Input]){
			ToolTipText:=func_key, srf_for_select:="(" func_key ") " srf_symbol[func_key,2-(EnSymbol||Englishmode)], srf_for_select_obj:=[srf_symbol[func_key,2-(EnSymbol||Englishmode)]]
			Gosub showhouxuankuang
			ToolTipText:=srf_all_input, jichu_for_select_Array:=[]
			jichu_for_select_Array[1,2]:=srf_symbol[srf_all_Input,(srf_mode&&!(EnSymbol||Englishmode)&&!GetKeyState("CapsLock", "T"))+1]
			srf_for_select_obj:=[srf_for_select:="1." jichu_for_select_Array[1,2]]
			If InStr(";'/",srf_all_Input)
				srf_for_select_obj.Push("2." jichu_for_select_Array[2,2]:=srf_symbol[SubStr(":""?",InStr(";'/",srf_all_Input),1),(srf_mode&&!(EnSymbol||Englishmode)&&!GetKeyState("CapsLock", "T"))+1]), srf_for_select .= (Textdirection="Horizontal"?"  ":"`n") srf_for_select_obj[2]
			Gosub showhouxuankuang
		} Else
			Settimer srf_tooltip, -1
	Return

	Tab::
		If (!fyfz&&!dwselect&&shurulei="pinyin"&&!InStr(srf_all_Input,func_key)){
			dwselect:=(srf_inputing&&jichu_for_select_Array[1,0]~="^pinyin")
			; 刷新候选框以显示间接辅助码引导符
			; Gosub showhouxuankuang 
			Gosub srf_tooltip_fanye
		} Else
			Gosub MoreWait
	Return

	+Tab::Gosub LessWait
	Return
	
	Shift::
		Critical, Off
		KeyWait, Shift
		If (A_ThisHotkey="Shift")&&(Shiftfg<4||shurulei!="pinyin"){
			Learnfg:=0
			If (Shiftfg&2=2){
				SendInput(Trim(srf_all_Input . tfzm,eng_key func_key), SendDelaymode)
				Gosub srf_value_off
				If (Shiftfg=3){
					SetYzLogo(srf_mode:=0, 1)
					DirectIMEandCursor(srf_mode)
					SetTimer, ToolTipInputStatus, -10
				}
			} Else
				Gosub srf_value_off
		} Else If !tfzm&&(shurulei="pinyin"&&fuzhuma){
			If (A_PriorHotkey!="Shift")&&RegExMatch(srf_all_Input_["tip"],"O).*[a-z][a-z]'([a-z]('?[a-z])?)$",fzm){
				tfzm:=StrReplace(fzm.Value[1],"'"), srf_all_Input:=RegExReplace(srf_all_Input, tfzm "$")
				jichu_for_select_Array:=pinyinmethod(srf_all_Input, Inputscheme), waitnum:=0
				Gosub houchuli
				Gosub srf_tooltip_fanye
			} Else If (A_PriorHotkey="Shift")&&(A_ThisHotkey="Shift"){
				srf_mode:=Learnfg:=0
				Gosub srf_value_off
				SetYzLogo(srf_mode:=0, 1)
				DirectIMEandCursor(srf_mode)
				SetTimer, ToolTipInputStatus, -10
			}
		} Else If (A_ThisHotkey="Shift"){
			Learnfg:=0
			Gosub srf_value_off
			SetYzLogo(srf_mode:=0, 1)
			DirectIMEandCursor(srf_mode)
			SetTimer, ToolTipInputStatus, -10
		}	
	Return

	Enter::
	NumpadEnter::
		If (Enterfg=2)
			If InStr(srf_all_Input,func_key)
				select_for_num(localpos)
			Else
				SendInput(Trim(srf_all_Input . tfzm,eng_key func_key), SendDelaymode)
		Gosub srf_value_off
	Return
#If
#If !srf_inputing&&DelLastLearnSQL
~BackSpace::
	DB.Exec(DelLastLearnSQL), DelLastLearnSQL:=""
	SetTimer, DelLastLearn, Off
Return
#If
; srf_mode模式 a-z键、esc键、中文符号 定义
#If (srf_inputing||(Escfg>1&&srf_mode))
Esc::
	If (!srf_inputing){
		SetYzLogo(srf_mode:=0, 1)
		DirectIMEandCursor(srf_mode)
		SetTimer, ToolTipInputStatus, -10
	}
	Gosub srf_value_off
	If (srf_mode&&Escfg=3){
		SetYzLogo(srf_mode:=0, 1)
		DirectIMEandCursor(srf_mode)
		SetTimer, ToolTipInputStatus, -10
	}
Return
#If
#If srf_mode&&(InStr(srf_all_Input,func_key))
NumpadDot::
	If (srf_func_table[modeMatch.Value[1], "Name"]="get_hotstring")||(srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-z]+$"){
		srf_HotStringSelect(Function_for_select, 4)
	} Else If (srf_func_table[modeMatch.Value[1], "Name"]="get_function")||!(modeMatch.Value[1]=""||srf_Default_Func[srf_func_table[modeMatch.Value[1], "Name"],2]~="\d"){
		srf_RunSelect(Function_for_select, 4)
	} Else {
		If (SubStr(srf_all_Input, 0)=func_key||srf_all_Input=func_key)
			Return
		srf_all_Input:=insertchar(srf_all_Input,".",insertpos)
		Settimer srf_tooltip, -1
	}
Return
NumpadDiv::
NumpadMult::
NumpadAdd::
NumpadSub::
	srf_all_Input:=insertchar(srf_all_Input,(A_ThisHotkey="NumpadDiv"?"/":A_ThisHotkey="NumpadMult"?"*":A_ThisHotkey="NumpadAdd"?"+":"-"),insertpos)
	Settimer srf_tooltip, -1
Return
#If
#If srf_mode
#If
!CapsLock::srf_create(RegExReplace(srf_all_Input,"i)[^a-z]"))
^+!F1::
	; Run, % "https://gitee.com/orz707/Yzime/wikis/%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B?sort_id=1844118"
	Gosub help
Return
#If srf_mode&&!srf_inputing
	~1::
	~2::
	~3::
	~4::
	~5::
	; ~6::
	; ~7::
	; ~8::
	; ~9::
	; ~0::
	numberfg:=1
	Return
#If

#If srf_mode&&!(!srf_inputing&&GetKeyState("CapsLock"))
; 设置热键
; a-z定义
; 设置热键
cninputchar:
	TickCount(0, 2), localpos:=1
	If StrLen(srf_all_Input)>100
		Return
	If (shurulei="pinyin"){
		if (!dwselect && (InStr("67890", A_ThisHotkey)||(GetKeyState("CapsLock", "T")^GetKeyState("Shift", "P")))){
		; if (!dwselect && (InStr("67890", A_ThisHotkey))){
			dwselect:=(srf_inputing&&tfuzhuma&&jichu_for_select_Array[1,0]~="^pinyin")
		}
		If (dwselect){
			; tfzm:=StrLen(tfzm)=2?LTrim(A_ThisHotkey,"+"):tfzm LTrim(A_ThisHotkey,"+")
			; if (StrLen(tfzm)=2) {
			; 	; tfzm:=""
			; 	return
			; }
			tfzm:=tfzm . (GetKeyState("CapsLock", "T")^GetKeyState("Shift", "P")?Format("{:U}", SubStr(A_ThisHotkey,0)):SubStr(A_ThisHotkey,0))
			; OutputDebug, % tfzm "`n"
			jichu_for_select_Array:=pinyinmethod(srf_all_Input, Inputscheme), waitnum:=0
			Gosub houchuli
			Gosub srf_tooltip_fanye
		} Else {
			If (tfzm)
				srf_select(1,,,1), tfzm:=""
			Begininput()
			srf_all_Input:=insertchar(srf_all_Input,GetKeyState("CapsLock", "T")^GetKeyState("Shift", "P")?Format("{:U}", SubStr(A_ThisHotkey,0)):SubStr(A_ThisHotkey,0),insertpos)
			waitnum:=numberfg:=0, srf_for_select:="", srf_for_select_obj:=[]
			Settimer srf_tooltip, -1
		}
	} Else If (!srf_inputing&&GetKeyState("Shift","P")&&!(Format("{:U}",LTrim(A_ThisHotkey,"+"))==lspy_key)){
		Gosub Inputchar
	} Else {
		If (tfzm)
			srf_select(1,,,1), tfzm:=""
		Begininput()
		srf_all_Input:=insertchar(srf_all_Input,GetKeyState("CapsLock", "T")^GetKeyState("Shift", "P")?Format("{:U}", SubStr(A_ThisHotkey,0)):SubStr(A_ThisHotkey,0),insertpos)
		waitnum:=numberfg:=0, srf_for_select:="", srf_for_select_obj:=[]
		Settimer srf_tooltip, -1
	}
	If (DebugLevel=4)
		OutputDebug(TickCount(1, 2), 4)
Return
#If

dwselect:
	dwselect:=srf_inputing&&tfuzhuma, srf_select(Ord(SubStr(A_ThisHotkey,0))-96, IsPinyin, SubStr(A_ThisHotkey,0))
Return
#If srf_inputing
searchinsertpos:
	insertpos:=InStr(srf_all_Input, SubStr(A_ThisHotkey,0), , Max(1,insertpos)), insertpos+=(insertpos>0)
	Gosub srf_tooltip_fanye
Return
Up::
Down::
	If (A_ThisHotkey="Up"){
		If (localpos>1)
			localpos-=1
		Else
			Gosub LessWait
	} Else If (localpos<srf_for_select_obj.Length())
		localpos+=1
	Else
		Gosub MoreWait
	If (ToolTipStyle=2)
		DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction, srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-z]+$"?SymbolFont:TextFont)
Return
Left::
Right::
	tfzm:="", dwselect:=0
	If (!insertpos){
		If (A_ThisHotkey="Left"){
			insertpos:=leftcaret(StrLen(srf_all_Input)+1)
		} Else
			insertpos:=1
	} Else {
		If (A_ThisHotkey="Left"){
			insertpos:=leftcaret(insertpos)
		} Else
			insertpos:=Min(insertpos+1,StrLen(srf_all_Input)+1)
	}
	Gosub srf_tooltip_fanye
Return
leftcaret(pos){
	global srf_all_Input_
	If (pos<2||!InStr(Trim(srf_all_Input_["tip"],"'"),"'"))
		Return Max(1,pos-1)
	Loop {
		pos--
		t:=insertcaret(StrReplace(Trim(srf_all_Input_["tip"],"'"), "'\'", " "),pos)
	} Until (t~="\|('| )")||pos<=1
	Return pos
}
F5 Up::
	Caret:=GetCaretPos(0), hasCaretPos:=1
	If (ToolTipStyle=1)
		ToolTip(1, ToolTipText "`n" srf_for_select, "x" Caret.x " y" Caret.y+Caret.h)
	Else
		DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction, srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-z]+$"?SymbolFont:TextFont)
Return
#If

~CapsLock::SetTimer, ToolTipInputStatus, -100
ToolTipInputStatus(){
	global srf_inputing, srf_mode, TSFmode
	If (!srf_inputing){
		If (!srf_mode)
			SetIMEStatus()
		If (Caret_:=GetCaretPos()).t="Mouse"
			ToolTip
		Else {
			; fg:=(!(srf_mode&&srf_inputing)&&GetKeyState("CapsLock", "T")?"Ａ":srf_mode||IME_GETOPENSTATUS()?"中":"英")
			fg:=(!(srf_mode&&srf_inputing)&&GetKeyState("CapsLock", "T")?"Ａ":srf_mode?"中":"英")
			ToolTip, % fg, Caret_.X+5, Caret_.Y+30
			; SetYzLogo(fg="中", 0)
			SetTimer, ToolTipOff, -1000
		}
	}
}
MouseIsOverDesktop() {
    MouseGetPos,,, Win
    return WinExist("ahk_exe explorer.exe" . " ahk_id " . Win)
}
#If MouseIsOverDesktop()
~LButton Up::
	If (!srf_inputing)
		_EventProc(0, 3, WinExist("A"))
		; ToolTipInputStatus()
Return
#If
#If MouseCross&&A_PriorHotkey="~LButton Up"&&A_TimeSincePriorHotkey<1200
LCtrl::selectmenu()
<^vkFF::Return
#If
#If ClipSaved
$^v::
recoverclip:
	Clipboard:=ClipSaved, ClipSaved:=""
	SendInput, {RShift Down}{Insert}{RShift Up}
Return
ClipChanged(Type){
	; OutputDebug, % Type " from origin" "`n"
	global ClipSaved, ClipHistory
	ClipSaved:=""
	If (ClipHistory&&Type)
		SetTimer saveclipboardtodb, -50
	Return
	saveclipboardtodb:
	If (DllCall("IsClipboardFormatAvailable","UInt",1))
		Try Cliphistory("+")
	Return
}
#If

ToolTipOff:
	ToolTip
Return

; 窗口拖动
WM_LBUTTONDOWN(l,w,msg,hWnd){
	global ToolTipStyle, @TSF, Caret, Yzimeini
		, srf_for_select_obj, hotstring_for_select, Function_for_select
	ToolTip
	If (A_Gui=2){
		PostMessage, 0xA1, 2
		KeyWait, LButton
		WinGetPos, X, Y, , , ahk_id%hWnd%
		Yzimeini["Hidden","X"]:=X, Yzimeini["Hidden","Y"]:=Y
	} Else If (hWnd=@TSF){
		X:=w & 0xFFFF
		Y:=w >> 16
		t := TSFCheckClickPos(X,Y)
		If (t=""){
			PostMessage, 0xA1, 2
			KeyWait, LButton
			WinGetPos, X, Y, , , % "ahk_id" @TSF
			Caret.X:=X, Caret.Y:=Y-30
		} Else {
			If srf_for_select_obj[t]
				select_for_num(t)
			Else {
				t:=SubStr(srf_for_select_obj[0,-t],1,3)
				If (t="(,)")
					srf_HotStringSelect(hotstring_for_select)
				Else If (t="(.)")
					srf_RunSelect(Function_for_select)
			}
		}
	}
}
WM_TSFMSG(wParam, lParam, msg:=0, hwnd:=0){
	global
	If (!TSFmode)
		Return
	switch wParam
	{
	case -1, 0xffffffff:
		If (lParam=-1||lParam=0xffffffff)
			IsObject(TSFMem)?TSFMem.SetOwner(A_ScriptHwnd):TSFMem:=new MemMap("WXppbWVUU0ZNRU0=")
		If (A_IsSuspended)
			Gosub srfsuspend
	case 0:
		If (lParam=0&&!(Lockedposition||Caret.t="Caret")){
			Caret.x:=TSFMem.Get(12, "Int"), Caret.y:=TSFMem.Get(16, "Int"), Caret.h:=5
			If (ToolTipStyle=2 && srf_for_select_obj.Length())
				DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction, srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-z]+$"?SymbolFont:TextFont)
			Caret.t:="TSF", hasCaretPos:=1
		}
	case 200:
		If (A_IsSuspended) {
			WinGet, pid, Pid, A
			if (pid = lParam)
				Gosub srfsuspend
		}
	case 404:
		If (!A_IsSuspended) {
			If (lParam = 0)
				SetTimer Deactivate, Off
			Else If (WinExist("A") = curwininfo.hwnd && A_TickCount - curwininfo.tick > 30) {
				Settimer Deactivate, -50
				curwininfo.tick := 0
			}
		}
	case 100:
		; OutputDebug % lParam&255 "|" lParam>>8
	}
	Return 0
	Deactivate:
		Gosub srfsuspend
		; Gosub EXIT
	Return
}
WM_QUERYENDSESSION(wParam, lParam, msg)
{
	Gosub Exit
	Return True
}
WM_ENDSESSION(wParam, lParam, msg)
{
	global Yzimeini
	Return (Yzimeini="")
}
SaveDB(wait:=0){
	Critical %wait%
	If (FileGetSize(A_Temp "\Yzime\yzime_sql.tmp")>50){
		; If !FileExist(A_ScriptDir "\Lib\tools\DBService.ahk")
		; 	ZIPDownloadToFile("https://gitee.com/orz707/Yzime/raw/zip/tools.7z", A_ScriptDir "\Lib\tools.7z")
		If (wait)
			RunWait "%AhkPath%" "%A_ScriptDir%\Lib\tools\DBService.ahk" Synchronizedb
		Else
			Run "%AhkPath%" "%A_ScriptDir%\Lib\tools\DBService.ahk" Synchronizedb
	} Else If FileExist(A_Temp "\Yzime\yzime_sql.tmp")
		FileDelete %A_Temp%\Yzime\yzime_sql.tmp
}
srfreload:
	If (MemoryDB)
		SaveDB(1)
	Yzimeini.Save(), hideorshowwindows("a"), DB.CloseDB(), SetIMEStatus(1, 1)
	For Key, Value in srf_Plugins
		Process, Close, % Value[1]
	DrawHXGUI("", "shutdown"), srf_Plugins:=Yzimeini:=""
	Try	{
		If A_IsCompiled
			Run % """" (UIAccess?A_ScriptFullPath:StrReplace(A_ScriptFullPath, "_UIA.exe", ".exe")) """"
		Else
			Run % """" (UIAccess?A_AhkPath:StrReplace(A_AhkPath, "_UIA.exe", ".exe")) """ """ A_ScriptFullPath """"
	}
	ExitApp

EXIT:
	TSFMem:=""
	If (hMutex)
		DllCall("CloseHandle", "Ptr", hMutex), hMutex:=0
	If (Eventhook)
		DllCall("UnhookWinEvent", "Ptr", Eventhook)
	If (Yzimeini="")
		ExitApp
	If (MemoryDB)
		SaveDB(1)
	DB.CloseDB(), Yzimeini.Save(), hideorshowwindows("a"), DrawHXGUI("", "shutdown"), SetIMEStatus(1, 1)
	For Key, Value in srf_Plugins
		Process, Close, % Value[1]
	FileRemoveDir, % A_Temp "\Yzime\Script", 1
	Yzimeini:=""
	ExitApp

EmptyMem:
	If (A_TimeSincePriorHotkey>60000){
		EmptyMem()
		If (MemoryDB)
			SaveDB()
	}
Return

; 来源: http://www.autohotkey.com/forum/topic32876.html
EmptyMem(PID="AHK Rocks"){
	pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
	h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
}
CloseOtherYZ(){
	local
	SetTitleMatchMode RegEx
	pid:=DllCall("GetCurrentProcessId")
	WinGet, id, List, Yzime\.ahk|Yzime(_UIA)?\.exe ahk_class AutoHotkey
	tt:=[]
	Loop %id%
	{
		WinGet, t, PID, % "ahk_id" id%A_Index%
		If (t>0&&t!=pid&&!tt[t]){
			PostMessage, 0x111, 65405, , , ahk_class AutoHotkey ahk_pid %t%
			tt[t]:=1
		}
	}
	SetTitleMatchMode 2
}
; 切换键盘模式
SwitchToEngIME(){
	; 下方代码可只保留一个
	SwitchIME(00000409)
}
SwitchIME(dwLayout){
	HKL:=DllCall("LoadKeyboardLayout", "Str", dwLayout, "UInt", 1)
	SendMessage, 0x50, 0, %HKL%, , A
}
SetIMEStatus(Status:=0,all:=0){
	Critical, Off
	SetTitleMatchMode 3
	If (all){
		WinGet, imehwndlist, List, Default IME ahk_class IME
		Loop %imehwndlist%
			SendMessage 0x283, 0x06, %Status%, , % "ahk_id" imehwndlist%A_Index%
	} Else {
		WinGet, activeexe, ProcessName, % "ahk_id" (activehwnd:=WinExist("A"))
		WinGet, imehwndlist, List, Default IME ahk_class IME ahk_exe %activeexe%
		Loop %imehwndlist%
			If (DllCall("GetParent", "Ptr", imehwndlist%A_Index%)=activehwnd)
				SendMessage 0x283, 0x06, %Status%, , % "ahk_id" imehwndlist%A_Index%
	}
	SetTitleMatchMode 2
	Sleep, 50
}

IME_GETOPENSTATUS(WinTitle="A"){	; 多进程输入状态优化
	hWnd:=WinExist(WinTitle)
	WinGet, activeexe, ProcessName, ahk_id %hWnd%
	WinGet, imehwndlist, List, Default IME ahk_class IME ahk_exe %activeexe%
	res:=0
	Loop %imehwndlist%
		If (DllCall("GetParent", "Ptr", imehwndlist%A_Index%)=hWnd){
			SendMessage 0x283, 0x05, 0, , % "ahk_id" imehwndlist%A_Index%	; Message : WM_IME_CONTROL  wParam:IMC_GETOPENSTATUS
			res |= ErrorLevel
		}
	; DefaultIMEWnd:=DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
	Return res
}

CheckClipboard(DataType) {
	; OutputDebug, % DataType " from check" "`n"
	if(DataType=1 && WinActive("ahk_exe Code.exe") && RegExMatch(Clipboard, "Ime&Cursor:PleaseSwitchTo([01])$", msg)){
		SwitchTo(msg1)
		; OutputDebug("收到：" Clipboard, 1)
		OnClipboardChange("ClipChanged",0)
		OnClipboardChange("CheckClipboard",0) 
		Try {
			Clipboard := SubStr(Clipboard,1,-StrLen(msg))
		} Catch e {
			OutputDebug("Error in " e.What ", which was called at line " e.Line ", Message:" e.Message ", Extra:" e.Extra, 1)
		}
		OnClipboardChange("ClipChanged",1)
		OnClipboardChange("CheckClipboard",-1)
		return 1
	} 
}

SwitchTo(to){
	local
	global srf_mode
	If(to^srf_mode){
		gosub srfSwitch
	} Else {
		DirectIMEandCursor(srf_mode)
	}
}

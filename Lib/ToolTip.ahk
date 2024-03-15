/*
Syntax: ToolTip(Number,Text,Options)

Return Value: ToolTip returns hWnd of the ToolTip

\         Options can include any of following parameters separated by space
\ Option  |      Meaning
\ A       |   Aim ConrolId or ClassNN (Button1, Edit2, ListBox1, SysListView321...)
\         |   - using this, ToolTip will be shown when you point mouse on a control
\         |   - D (delay) can be used to change how long ToolTip is shown
\         |   - W (wait) can wait for specified seconds before ToolTip will be shown
\         |   - Some controls like Static require a subroutine to have a ToolTip!!!
\ B + T   |   Specify here the color for ToolTip in 6-digit hexadecimal RGB code
\         |   - B = Background color, T = Text color
\         |   - this can be 0x00FF00 or 00FF00 or Blue, Lime, Black, White...
\ D       |   Delay. This option will determine how long ToolTip should be shown.30 sec. is maximum
\         |   - this option is also available when assigning the ToolTip to a control.
\ O       |   Oval ToolTip (BalloonTip). Specify O1 to use a BalloonTip instead of ToolTip.
\ P       |   Parent window hWnd or GUI number. This will assign a ToolTip to a window.
\         |   - Reqiered to assign ToolTip to controls and actions.
\ Q       |   Quench Style/Theme. Use this to disable Theme of ToolTip.
\         |   Using this option you can have for example colored ToolTips in Vista.
\ S       |   Show at coordinates regardless of position. Specify S1 to use that feature
\         |   - normally it is fed automaticaly to show on screen
\ W       |   Wait time in seconds (max 30) before ToolTip pops up when pointing on one of controls.
\ X + Y   |   Coordinates where ToolTip should be displayed, e.g. X100 Y200
\         |   - leave empty to display ToolTip near mouse
\         |   - you can specify Xcaret Ycaret to display at caret coordinates
\
\          To hide a ToolTip use ToolTip(Number), to destroy all ToolTip()
*/

ToolTip(ID="",TEXT="",OPTIONS="",F:="",Style:=""){
	static
	local option,a,b,d,k,o,p,q,s,t,w,x,y,xc,yc,xw,yw,RECT,#_DetectHiddenWindows
	If !Init
		Gosub, TTM_INIT
	DetectHiddenWindows:=A_DetectHiddenWindows
	DetectHiddenWindows, On
	If !ID
	{
		Loop, Parse, hWndArray, % Chr(2) ;Destroy all ToolTip Windows
		{
			If WinExist("ahk_id " . A_LoopField)
				DllCall("DestroyWindow","Uint",A_LoopField)
				hWndArray%A_LoopField%=
			}
		hWndArray=
		Loop, Parse, idArray, % Chr(2) ;Destroy all ToolTip Structures
		{
			TT_ID:=A_LoopField
			If TT_ALL_%TT_ID%
				Gosub, TT_DESTROY
		}
		idArray=
		DetectHiddenWindows, %#_DetectHiddenWindows%
    	Return
	}
	
	TT_ID:=ID
	TT_HWND:=TT_HWND_%TT_ID%
	
	;___________________  Load Options Variables and Structures ___________________
	
	If (options){
		Loop,Parse,options,%A_Space%
			If (option:= SubStr(A_LoopField,1,1))
			%option%:= SubStr(A_LoopField,2)
	}
	;__________________________  Save TOOLINFO Structures _________________________
	
	If P {
		If (p<100 and !WinExist("ahk_id " p)){
			Gui,%p%:+LastFound
			P:=WinExist()
		}
		If !InStr(TT_ALL_%TT_ID%,Chr(2) . Abs(P) . Chr(2))
			TT_ALL_%TT_ID%  .= Chr(2) . Abs(P) . Chr(2)
	}
	If !InStr(TT_ALL_%TT_ID%,Chr(2) . ID . Chr(2))
		TT_ALL_%TT_ID%  .= Chr(2) . ID . Chr(2)
	;__________________________  Create ToolTip Window  __________________________
	
	If (!TT_HWND){
		TT_HWND := DllCall("CreateWindowEx", "Uint", 0x8000008, "str", "tooltips_class32", "str", "", "Uint", 0x02 + (v ? 0x1 : 0) + (l ? 0x100 : 0) + (C ? 0x80 : 0)+(O ? 0x40 : 0), "int", 0x80000000, "int", 0x80000000, "int", 0x80000000, "int", 0x80000000, "Uint", P ? P : 0, "Uint", 0, "Uint", 0, "Uint", 0)
		TT_HWND_%TT_ID%:=TT_HWND
		hWndArray .=(hWndArray ? Chr(2) : "") . TT_HWND
		idArray .=(idArray ? Chr(2) : "") . TT_ID
		Gosub, TTM_SETMAXTIPWIDTH
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1)) ;TTDT_AUTOPOP
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 3, "Uint", (W ? W*1000 : -1)) ;TTDT_INITIAL
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 1, "Uint", (W ? W*1000 : -1)) ;TTDT_RESHOW
	}
	;______________________  Create TOOLINFO Structure  ______________________
	
	Gosub, TT_SETTOOLINFO
	
	If (Q!=""){
		Gosub, TTM_SETWINDOWTHEME
		If (TC!=""||T!="")
			Gosub, TTM_SETTIPTEXTCOLOR
		If (BC!=""||B!="")
			Gosub, TTM_SETTIPBKCOLOR
	}
	If (hfont||F!=""){
		Gosub, WM_SETFONT
	}
	If (!A){
		Gosub, TTM_UPDATETIPTEXT
		Gosub, TTM_UPDATE
		If D {
			A_Timer := A_TickCount, D *= 1000
			Gosub, TTM_TRACKPOSITION
			Gosub, TTM_TRACKACTIVATE
			Loop
			{
				Gosub, TTM_TRACKPOSITION
				If (A_TickCount - A_Timer > D)
					Break
			}
			Gosub, TT_DESTROY
			DllCall("DestroyWindow","Uint",TT_HWND)
			TT_HWND_%TT_ID%=
		} else {
			Gosub, TTM_TRACKPOSITION
			Gosub, TTM_TRACKACTIVATE
		}
	}
	
	;________  Return HWND of ToolTip  ________
	
	DetectHiddenWindows, %#_DetectHiddenWindows%
	Return TT_HWND
	
	;________________________  Internal Labels  ________________________
	
	TTM_POP:    ;Hide ToolTip
	TTM_POPUP:    ;Causes the ToolTip to display at the coordinates of the last mouse message.
	TTM_UPDATE: ;Forces the current tool to be redrawn.
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", 0)
	Return
	TTM_TRACKACTIVATE: ;Activates or deactivates a tracking ToolTip.
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", (N ? 0 : 1), "Uint", &TOOLINFO_%ID%)
	Return
	TTM_UPDATETIPTEXT:
	TTM_GETBUBBLESIZE:
	TTM_ADDTOOL:
	TTM_DELTOOL:
	TTM_SETTOOLINFO:
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", &TOOLINFO_%ID%)
	Return
	TTM_SETWINDOWTHEME:
		If Q
			DllCall("uxtheme\SetWindowTheme", "Uint", TT_HWND, "Uint", 0, "UintP", 0)
		else
			DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", &K)
	Return
	TTM_SETMAXTIPWIDTH:
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", R ? R : A_ScreenWidth)
	Return
	TTM_TRACKPOSITION:
		If (x="caret" or y="caret"){
			WinGetPos,xw,yw,,,A
			If (x="caret")
				xc:=xw+A_CaretX +5
			If (y="caret")
				yc:=yw+A_CaretY+15
			If !(xc||yc){
				VarSetCapacity(cur, 20, 0), cur:= Chr(20)
				DllCall("GetCursorInfo", "Uint", &cur)
				yc := NumGet(cur,16)+10, xc := NumGet(cur,12)+5
			}
		}
		If (!x and !y)
			Gosub, TTM_UPDATE
		else if !WinActive("ahk_id " . TT_HWND)
			DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", (x<9999999 ? x : xc & 0xFFFF)|(y<9999999 ? y : yc & 0xFFFF)<<16)
	Return
	TTM_SETTIPBKCOLOR:
		If (B!="")
		{
			B := (StrLen(B) < 8 ? "0x" : "") . B
			BC := ((B&255)<<16)+(((B>>8)&255)<<8)+(B>>16) ; rgb -> bgr
		}
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", BC & 0xFFFFFF, "Uint", 0)
	Return
	TTM_SETTIPTEXTCOLOR:
		If (T!="")
		{
			T := (StrLen(T) < 8 ? "0x" : "") . T
			TC := ((T&255)<<16)+(((T>>8)&255)<<8)+(T>>16) ; rgb -> bgr
		}
		DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint",TC & 0xFFFFFF, "Uint", 0)
	Return
	WM_SETFONT:
		If (F!=""){
			S:=(S?"s" S:"") (Style?" bold":" norm")
			Gui _TTG: Font, %S%, %F%
			GuiControl _TTG: Font, %htext%
			hfont:=DllCall("SendMessage", "Ptr", htext, "Uint", 0x31, "Ptr", 0, "Ptr", 0)
		}
		DllCall("SendMessage", "Ptr", TT_HWND, "Uint", 0x30, "Ptr", hfont, "Ptr", 0)
	Return
	TTM_SETMARGIN:
		VarSetCapacity(RECT,16)
		Loop,Parse,E,.
			NumPut(A_LoopField,RECT,(A_Index-1)*4)
			DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", &RECT)
	Return
	TT_SETTOOLINFO:
		If A {
			If A is not Xdigit
				ControlGet,A,Hwnd,,%A%,ahk_id %P%
			ID :=Abs(A)
			If !InStr(TT_ALL_%TT_ID%,Chr(2) . ID . Chr(2))
				TT_ALL_%TT_ID%  .= Chr(2) . ID . Chr(2) . ID+Abs(P) . Chr(2)
			If !TOOLINFO_%ID%
				VarSetCapacity(TOOLINFO_%ID%, (A_PtrSize=8?56:40), 0),TOOLINFO_%ID%:=Chr(A_PtrSize=8?56:40)
			else
				Gosub, TTM_DELTOOL
			Numput(16,TOOLINFO_%ID%,4,"UInt"),Numput(P,TOOLINFO_%ID%,8,A_PtrSize=8?"Ptr":"Uint"),Numput(ID,TOOLINFO_%ID%,A_PtrSize=8?16:12,A_PtrSize=8?"Ptr":"Uint")
			If (text!="")
				NumPut(&text,TOOLINFO_%ID%,A_PtrSize=8?48:36)
			Gosub, TTM_ADDTOOL
			ID :=ID+Abs(P)
			If !TOOLINFO_%ID%
			{
				VarSetCapacity(TOOLINFO_%ID%, A_PtrSize=8?56:40, 0),TOOLINFO_%ID%:=Chr(A_PtrSize=8?56:40)
				Numput(16,TOOLINFO_%ID%,4,"UInt"),Numput(P,TOOLINFO_%ID%,8,A_PtrSize=8?"Ptr":"Uint"),Numput(ID,TOOLINFO_%ID%,A_PtrSize=8?16:12,A_PtrSize=8?"Ptr":"Uint")
			}
			Gosub, TTM_ADDTOOL
			ID :=Abs(A)
		} else {
			If !TOOLINFO_%ID%
				VarSetCapacity(TOOLINFO_%ID%, A_PtrSize=8?56:40, 0),TOOLINFO_%ID%:=Chr(A_PtrSize=8?56:40)
			NumPut(&text,TOOLINFO_%ID%,A_PtrSize=8?48:36)
			NumPut((0x20|0x80),TOOLINFO_%ID%,4,"UInt"), Numput(P,TOOLINFO_%ID%,8,A_PtrSize=8?"Ptr":"UInt"), Numput(P,TOOLINFO_%ID%,A_PtrSize=8?16:12,A_PtrSize=8?"Ptr":"Uint")
			Gosub, TTM_ADDTOOL
		}
		TOOLLINK%ID%:=L
	Return
	TT_DESTROY:
		Loop, Parse, TT_ALL_%TT_ID%,% Chr(2)
			If A_LoopField
			{
				ID:=A_LoopField
				Gosub, TTM_DELTOOL
				TOOLINFO_%A_LoopField%:="", TT_HWND_%A_LoopField%:="", TOOLTEXT_%A_LoopField%:="", TT_HIDE_%A_LoopField%:="",TOOLLINK%A_LoopField%:=""
			}
		TT_ALL_%TT_ID%=
	Return
	
	TTM_INIT:
		Init:=1, htext:=0, hgui:=0, hfont:=0
		; Messages
		TTM_ACTIVATE := 0x400 + 1,   TTM_ADDTOOL := A_IsUnicode ? 0x432 : 0x404,   TTM_DELTOOL := A_IsUnicode ? 0x433 : 0x405
		,TTM_POP := 0x41c, TTM_POPUP := 0x422,   TTM_UPDATETIPTEXT := 0x400 + (A_IsUnicode ? 57 : 12)
		,TTM_UPDATE := 0x400 + 29, TTM_SETTOOLINFO := 0x409
		,TTN_FIRST := 0xfffffdf8,   TTM_TRACKACTIVATE := 0x400 + 17,   TTM_TRACKPOSITION := 0x400 + 18
		,TTM_SETMARGIN:=0x41a, TTM_SETWINDOWTHEME:=0x200b, TTM_SETMAXTIPWIDTH:=0x418,TTM_GETBUBBLESIZE:=0x41e
		,TTM_SETTIPBKCOLOR:=0x413,   TTM_SETTIPTEXTCOLOR:=0x414
		Gui _TTG: Add, Text, +hwndhtext
		Gui _TTG: +hwndhgui +0x40000000
	Return
}
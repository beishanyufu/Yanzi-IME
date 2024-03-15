TSFGuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y){
	static init:=0
	global
	local index, _
	index := TSFCheckClickPos(X,Y)
	If (index=""||index<0)
		Return
	If (!init){
		Menu, soso_select, Add, 百度搜索(&B), selectmenu_
		Menu, soso_select, Add, bing搜索(&N), selectmenu_
		Menu, soso_select, Add, 微博搜索(&W), selectmenu_
		Menu, soso_select, Add, 谷歌搜索(&G), selectmenu_
		Menu, fanyi_select, Add, 谷歌翻译(&G), selectmenu_
		Menu, fanyi_select, Add, 有道翻译(&Y), selectmenu_
		Menu, selectmenu, Add, 搜索(&S), :soso_select
		Menu, selectmenu, Add, 翻译(&F), :fanyi_select
	}
	If (srf_for_select_obj[index]&&(Gbuffer:=jichu_for_select_Array[ListNum*waitnum+index, valueindex])){
		localpos:=index
		DrawHXGUI(ToolTipText, srf_for_select_obj, Caret.X, Caret.Y+Caret.H, srf_direction, srf_all_Input~="^" (func_key="\"?"\\":func_key) "[a-z]+$"?SymbolFont:TextFont)
		Menu, selectmenu, Delete
		Menu, selectmenu, Add, 搜索(&S), :soso_select
		Menu, selectmenu, Add, 翻译(&F), :fanyi_select
		If (jichu_for_select_Array[ListNum*waitnum+index,0]~="\|\d"){
			_:=Func("srf_SetFirst").Bind(index)
			Menu, selectmenu, Add, 置顶(&A), % _
			_:=Func("srf_delete").Bind(index)
			Menu, selectmenu, Add, 删除(&D), % _
		}
		srf_mode:=srf_inputing:=0
		Menu, selectmenu, Show
		srf_mode:=srf_inputing:=1
	}
	Return
}
Gdip_MeasureString2(pGraphics, sString, hFont, hFormat, ByRef RectF){
	Ptr := A_PtrSize ? "UPtr" : "UInt", VarSetCapacity(RC, 16)
	DllCall("gdiplus\GdipMeasureString", Ptr, pGraphics, Ptr, &sString, "int", -1, Ptr, hFont, Ptr, &RectF, Ptr, hFormat, Ptr, &RC, "uint*", Chars, "uint*", Lines)
	return &RC ? [NumGet(RC, 0, "float"), NumGet(RC, 4, "float"), NumGet(RC, 8, "float"), NumGet(RC, 12, "float")] : 0
}
DrawHXGUI(codetext, Textobj, x:=0, y:=0, Textdirection:=0, Font:="Microsoft YaHei UI"){
	Critical
	static init:=0, Hidefg:=0, DPI:=A_ScreenDPI/96, MonCount:=1, MonLeft, MonTop, MonRight, MonBottom
		, MinLeft:=DllCall("GetSystemMetrics", "Int", 76), MinTop:=DllCall("GetSystemMetrics", "Int", 77)
		, MaxRight:=DllCall("GetSystemMetrics", "Int", 78), MaxBottom:=DllCall("GetSystemMetrics", "Int", 79)
		, xoffset, yoffset, hoffset  ; 左边、上边、编码词条间距离增量
		, fontoffset
	global BackgroundColor, TextColor, CodeColor, BorderColor, FocusBackColor, FocusColor, FontSize, FontBold, TPosObj
		, Showdwxgtip, jichu_for_select_Array, localpos, Caret, @TSF, srf_for_select_obj, Function_for_select, hotstring_for_select, Caret
	If !IsObject(Textobj){
		If (Textobj="init"){
			If !pToken_&&(!pToken_:=Gdip_Startup()){
				MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
				ExitApp
			}
			Gui, TSF: -Caption +E0x8080088 +AlwaysOnTop +LastFound +hwnd@TSF -DPIScale
			Gui, TSF: Show, NA
			SysGet, MonCount, MonitorCount
			SysGet, Mon, Monitor
		} Else If (Textobj="shutdown"){
			If (pToken_)
				pToken_:=Gdip_Shutdown(pToken_)
			Gui, TSF:Destroy
		} Else If (Textobj=""){
			hbm := CreateDIBSection(1, 1), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
			UpdateLayeredWindow(@TSF, hdc, 0, 0, 1, 1), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
			init:=0
		}
		Return
	} Else If (!init){
		If !pToken_&&(!pToken_:=Gdip_Startup()){
			MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
			ExitApp
		}
		xoffset:=FontSize*0.45, yoffset:=FontSize/2.5, hoffset:=FontSize/3.2, init:=1, fontoffset:=FontSize/16
		
		; 识别扩展屏坐标范围
		x:=(x<MinLeft?MinLeft:x>MaxRight?MaxRight:x), y:=(y<MinTop?MinTop:y>MaxBottom?MaxBottom:y)
		If (MonCount>1){
			If (MonInfo:=MDMF_GetInfo(MDMF_FromPoint(x,y)))
				MonLeft:=MonInfo.Left, MonTop:=MonInfo.Top, MonRight:=MonInfo.Right, MonBottom:=MonInfo.Bottom
			Else
				SysGet, Mon, Monitor
		}
	} Else
		x:=(x<MinLeft?MinLeft:x>MaxRight?MaxRight:x), y:=(y<MinTop?MinTop:y>MaxBottom?MaxBottom:y)
	hFamily := Gdip_FontFamilyCreate(Font), hFont := Gdip_FontCreate(hFamily, FontSize*DPI, FontBold)
	hFormat := Gdip_StringFormatCreate(0x4000), Gdip_SetStringFormatAlign(hFormat, 0x00000800), pBrush := []
	For key,value in ["Background","Code","Text","Focus","FocusBack"]
		If (!pBrush[%value%])
			pBrush[%value%] := Gdip_BrushCreateSolid("0x" (%value% := SubStr("FF" %value%Color, -7)))
	pPen_Border := Gdip_CreatePen("0x" SubStr("FF" BorderColor, -7), 1)
	
	w:=MonRight-MonLeft, h:=MonBottom-MonTop
	; 计算界面长宽像素
	hbm := CreateDIBSection(1, 1), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	CreateRectF(RC, 0, 0, w-30, h-30), TPosObj:=[]
	hFont_code := Gdip_FontCreate(hFamily, FontSize*DPI*0.75, FontBold)
	CodePos := Gdip_MeasureString2(G, codetext "|", hFont_code, hFormat, RC), CodePos[1]:=xoffset
	, CodePos[2]:=yoffset, mh:=CodePos[2]+CodePos[4], mw:=CodePos[3]
	If (Textdirection=1||Function_for_select[0]="Cliphistory"){
		mh+=hoffset
		Loop % Textobj.Length()
			TPosObj[A_Index] := Gdip_MeasureString2(G, Textobj[A_Index], hFont, hFormat, RC), TPosObj[A_Index,2]:=mh
			, mh += TPosObj[A_Index,4], mw:=Max(mw,TPosObj[A_Index,3]), TPosObj[A_Index,1]:=CodePos[1]
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index] := Gdip_MeasureString2(G, Textobj[0,A_Index], hFont, hFormat, RC), TPosObj[0,A_Index,2]:=mh
			, mh += TPosObj[0,A_Index,4], mw:=Max(mw,TPosObj[0,A_Index,3]), TPosObj[0,A_Index,1]:=CodePos[1]
		Loop % Textobj.Length()
			TPosObj[A_Index,3]:=mw
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index,3]:=mw
		mw+=2*xoffset, mh+=yoffset
	} Else {
		t:=xoffset, mh+=hoffset
		TPosObj[1] := Gdip_MeasureString2(G, Textobj[1], hFont, hFormat, RC), TPosObj[1,2]:=mh, TPosObj[1,1]:=t, t+=TPosObj[1,3]+hoffset, maxh:=TPosObj[1, 4]
		Loop % (Textobj.Length()-1){
			TPosObj[A_Index+1]:=Gdip_MeasureString2(G, Textobj[A_Index+1], hFont, hFormat, RC), maxh:=Max(maxh, TPosObj[A_Index+1, 4])
			If (t+TPosObj[A_Index+1,3]<=w-30)
				TPosObj[A_Index+1,1]:=t, TPosObj[A_Index+1,2]:=TPosObj[A_Index,2], t+=TPosObj[A_Index+1,3]+hoffset
			Else
				mw:=Max(mw,t), TPosObj[A_Index+1,1]:=xoffset, mh+=TPosObj[A_Index,4], TPosObj[A_Index+1,2]:=mh, t:=xoffset+TPosObj[A_Index+1,3]+hoffset
		}
		mw:=Max(mw,t)
		mh+=maxh
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index] := Gdip_MeasureString2(G, Textobj[0,A_Index], hFont, hFormat, RC), TPosObj[0,A_Index,1]:=xoffset, TPosObj[0,A_Index,2]:=mh, mh += TPosObj[0,A_Index,4], mw:=Max(mw,TPosObj[0,A_Index,3])	
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index,3]:=mw-xoffset
		mw+=xoffset, mh+=yoffset
	}
	SelectObject(hdc, obm), DeleteObject(hbm), Gdip_DeleteGraphics(G)
	hbm := CreateDIBSection(mw, mh), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2)
	; 背景色
	y-=(Caret.h+CodePos[2]), Gdip_SetTextRenderingHint(G, 4)
	Gdip_FillRoundedRectangle(G, pBrush[Background], 0, CodePos[4]+CodePos[2], mw-2, mh-2-(CodePos[4]+CodePos[2]), 5)
	; Gdip_FillRoundedRectangle(G, pBrush[Background], 0, 0, mw-2, mh-2, 5)
	; 编码
	CreateRectF(RC, 0, CodePos[2]*0.8, w-30, h-30), Gdip_DrawString(G, codetext, hFont_code, hFormat, pBrush[Code], RC)
	; CreateRectF(RC, CodePos[1], CodePos[2], w-30, h-30), Gdip_DrawString(G, codetext, hFont_code, hFormat, pBrush[Code], RC)
	If (FontSize<21)
		Gdip_SetTextRenderingHint(G, 5)
	Loop % Textobj.Length()
		If (A_Index=localpos)
			Gdip_FillRoundedRectangle(G, pBrush[FocusBack], TPosObj[A_Index,1], TPosObj[A_Index,2]-hoffset/3, TPosObj[A_Index,3], TPosObj[A_Index,4]+hoffset*2/3, 3)
			, CreateRectF(RC, TPosObj[A_Index,1], TPosObj[A_Index,2]+fontoffset, w-30, h-30), Gdip_DrawString(G, Textobj[A_Index], hFont, hFormat, pBrush[Focus], RC)
		Else
			CreateRectF(RC, TPosObj[A_Index,1], TPosObj[A_Index,2]+fontoffset, w-30, h-30), Gdip_DrawString(G, Textobj[A_Index], hFont, hFormat, pBrush[Text], RC)
	Loop % Textobj[0].Length()
		CreateRectF(RC, TPosObj[0,A_Index,1], TPosObj[0,A_Index,2], w-30, h-30), Gdip_DrawString(G, Textobj[0,A_Index], hFont, hFormat, pBrush[Text], RC)

	; 定位提示
	If (Showdwxgtip){
		If !pBrush["FFFF0000"]
			pBrush["FFFF0000"] := Gdip_BrushCreateSolid("0xFFFF0000")	; 红色
		CreateRectF(RC, TPosObj[1,1], TPosObj[1,2]+FontSize*0.70, w-30, h-30)
		Gdip_DrawString(G, "   " SubStr("　ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ",1,StrLen(jichu_for_select_Array[1,2])), hFont, hFormat, pBrush["FFFF0000"], RC)
	}
	; 边框、分隔线
	Gdip_DrawRoundedRectangle(G, pPen_Border, 0, CodePos[4]+CodePos[2], mw-2, mh-2-(CodePos[4]+CodePos[2]), 5)
	; Gdip_DrawRoundedRectangle(G, pPen_Border, 0, 0, mw-2, mh-2, 5)
	; Gdip_DrawLine(G, pPen_Border, xoffset, CodePos[4]+CodePos[2], mw-xoffset, CodePos[4]+CodePos[2])
	UpdateLayeredWindow(@TSF, hdc, tx:=Min(x, Max(MonLeft, MonRight-mw)), ty:=Min(y, Max(MonTop, MonBottom-mh)), mw, mh)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)

	Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
	Gdip_DeleteFont(hFont_code)
	For key,value in pBrush
		Gdip_DeleteBrush(value)
	Gdip_DeletePen(pPen_Border)
	WinSet, AlwaysOnTop, On, ahk_id%@TSF%
	If (tx>MonLeft+2)
		Caret.X:=tx
}
TSFCheckClickPos(X,Y){
	global TPosObj
	Loop % TPosObj.Length()
		If (X>=TPosObj[A_Index,1]&&X<=TPosObj[A_Index,1]+TPosObj[A_Index,3]
			&&Y>=TPosObj[A_Index,2]&&Y<=TPosObj[A_Index,2]+TPosObj[A_Index,4])
		Return A_Index
	Loop % TPosObj[0].Length()
		If (X>=TPosObj[0,A_Index,1]&&X<=TPosObj[0,A_Index,1]+TPosObj[0,A_Index,3]
			&&Y>=TPosObj[0,A_Index,2]&&Y<=TPosObj[0,A_Index,2]+TPosObj[0,A_Index,4])
		Return (-A_Index)
}
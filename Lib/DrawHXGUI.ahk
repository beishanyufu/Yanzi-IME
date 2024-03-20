; ##################################################################################################################################################################
; # 声明：此文件基于开源仓库 <https://gitee.com/orz707/Yzime> (Commit:d1d0d9b15062de7381d1e7649693930c34fca53d) 
; # 中的同名文件修改而来，并使用相同的开源许可 GPL-2.0 进行开源，具体的权利、义务和免责条款可查看根目录下的 LICENSE 文件
; # 修改者：北山愚夫
; # 修改时间：2024年3月15日 
; ##################################################################################################################################################################

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
			_:=Func("srf_SetFirst").Bind(index, 0)
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
	static init:=0, Hidefg:=0, DPI:=A_ScreenDPI/96, MonCount:=1, MonLeft, MonTop, MonRight, MonBottom, minw:=0
		, MinLeft:=DllCall("GetSystemMetrics", "Int", 76), MinTop:=DllCall("GetSystemMetrics", "Int", 77)
		, MaxRight:=DllCall("GetSystemMetrics", "Int", 78), MaxBottom:=DllCall("GetSystemMetrics", "Int", 79)
		, xoffset, yoffset, hoffset  ; 左边、上边、编码词条间距离增量
		, fontoffset
		, pBitmap:=0
	global BackgroundColor, TextColor, CodeColor, BorderColor, FocusBackColor, FocusColor, FontSize, FontBold, TPosObj, pToken_, func_key
		, Showdwxgtip, jichu_for_select_Array, localpos, Caret, @TSF, srf_for_select_obj, Function_for_select, hotstring_for_select
	If !IsObject(Textobj){
		If (Textobj="init"){
			If !pToken_&&(!pToken_:=Gdip_Startup()){
				MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
				ExitApp
			}
			; If FileExist("d:\git-projects\AHK\yanzi_.png")
			; 	pBitmap:=Gdip_CreateBitmapFromFile("d:\git-projects\AHK\yanzi_.png")
			pBitmap:="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dCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+Cjx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDQuNC4wLUV4aXYyIj4KIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIgogICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgIHhtbG5zOkdJTVA9Imh0dHA6Ly93d3cuZ2ltcC5vcmcveG1wLyIKICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICB4bXBNTTpEb2N1bWVudElEPSJnaW1wOmRvY2lkOmdpbXA6YWVjMjQ0ZWUtMWZmNy00MmY2LThjYzAtZjM4YzA4ZDgxMTUyIgogICB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjViYzkyNDk1LTA2MzktNGU2ZC1hMGRlLWYyM2I1YzRmZjAwMyIKICAgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjY0MTk4NTM5LWU3MDktNDAyYS04MjNjLTRjNmVlYjA5Y2YyYiIKICAgZGM6Rm9ybWF0PSJpbWFnZS9wbmciCiAgIEdJTVA6QVBJPSIyLjAiCiAgIEdJTVA6UGxhdGZvcm09IldpbmRvd3MiCiAgIEdJTVA6VGltZVN0YW1wPSIxNzA4MTQ0MDU0ODM4MTExIgogICBHSU1QOlZlcnNpb249IjIuMTAuMzIiCiAgIHRpZmY6T3JpZW50YXRpb249IjEiCiAgIHhtcDpDcmVhdG9yVG9vbD0iR0lNUCAyLjEwIgogICB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0OjAyOjE3VDEyOjI3OjM0KzA4OjAwIgogICB4bXA6TW9kaWZ5RGF0ZT0iMjAyNDowMjoxN1QxMjoyNzozNCswODowMCI+CiAgIDx4bXBNTTpIaXN0b3J5PgogICAgPHJkZjpTZXE+CiAgICAgPHJkZjpsaQogICAgICBzdEV2dDphY3Rpb249InNhdmVkIgogICAgICBzdEV2dDpjaGFuZ2VkPSIvIgogICAgICBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjQzMTRlMTNlLWM5YTUtNGUyZS1iOTc4LWExOGFiNWI5YTNiZSIKICAgICAgc3RFdnQ6c29mdHdhcmVBZ2VudD0iR2ltcCAyLjEwIChXaW5kb3dzKSIKICAgICAgc3RFdnQ6d2hlbj0iMjAyNC0wMi0xN1QxMjoyNzozNCIvPgogICAgPC9yZGY6U2VxPgogICA8L3htcE1NOkhpc3Rvcnk+CiAgPC9yZGY6RGVzY3JpcHRpb24+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgCjw/eHBhY2tldCBlbmQ9InciPz7c5PRUAAAABmJLR0QAzwBkAFHBtMbrAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH6AIRBBsi3/lydwAAECVJREFUeNrtnXuUVVUdxz/DwPDQgUEEwTeoYCJCICIKXlRE8YVKZCtRLBUfuGqpoVbuHv40e5iVGWWatjSXsUhF8EGFFTdMVonhMzORxFTAJyA6ODDTH3uzHBGEkbn3nr3P97PWXTNrMXPnd/b+ffidc+4+vw1C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"
            
			pBitmap:=Gdip_BitmapFromBase64(pBitmap)
			Gui, TSF: -Caption +E0x8080088 +AlwaysOnTop +LastFound +hwnd@TSF -DPIScale
			Gui, TSF: Show, NA
			SysGet, MonCount, MonitorCount
			SysGet, Mon, Monitor
		} Else If (Textobj="shutdown"){
			if(pBitmap)
				Gdip_DisposeImage(pBitmap)
			If (pToken_)
				pToken_:=Gdip_Shutdown(pToken_)
			Gui, TSF:Destroy
		} Else If (Textobj=""){
			hbm := CreateDIBSection(1, 1), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
			UpdateLayeredWindow(@TSF, hdc, 0, 0, 1, 1), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
			init:=0, minw:=0
		}
		Return
	} Else If (!init){
		If !pToken_&&(!pToken_:=Gdip_Startup()){
			MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
			ExitApp
		}
		SysGet, _MonCount, MonitorCount
		if (_MonCount != MonCount) {
			MonCount := _MonCount
			MinLeft:=DllCall("GetSystemMetrics", "Int", 76), MinTop:=DllCall("GetSystemMetrics", "Int", 77)
		    MaxRight:=DllCall("GetSystemMetrics", "Int", 78), MaxBottom:=DllCall("GetSystemMetrics", "Int", 79)
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
	For __,_value in ["Background","Code","Text","Focus","FocusBack"]
		If (!pBrush[%_value%])
			pBrush[%_value%] := Gdip_BrushCreateSolid("0x" (%_value% := SubStr("FF" %_value%Color, -7)))
	pBrush[invalid] := Gdip_BrushCreateSolid("0x" (invalid:="ffc0c0c0"))
	pPen_Border := Gdip_CreatePen("0x" SubStr("FF" BorderColor, -7), 1)
	
	w:=MonRight-MonLeft, h:=MonBottom-MonTop
	; 计算界面长宽像素
	hdc := CreateCompatibleDC(), G := Gdip_GraphicsFromHDC(hdc)
	CreateRectF(RC, 0, 0, w-30, h-30), TPosObj:=[]
	If (!minw)
		minw := Gdip_MeasureString2(G, "1.一一一一 a", hFont, hFormat, RC)[3]
	if (pBitmap && flagPos:=InStr(codetext, "︙")) {
		codetext := StrReplace(codetext, "︙", "")
		yanziPos := Gdip_MeasureString2(G, subStr(codetext,1,flagPos-1), hFont, hFormat, RC)
		yanziPos[1]:=xoffset+yanziPos[3], yanziPos[2]:=yoffset
		if(hasTail:=strLen(codetext)>flagpos+1?1:0){
			tailPos := Gdip_MeasureString2(G, subStr(codetext,1,flagPos+1), hFont, hFormat, RC)
			tailPos[1]:=xoffset+tailPos[3]+tailPos[4], tailPos[2]:=yoffset
		yanziPos[1]:=xoffset+yanziPos[3], yanziPos[2]:=yoffset
		}
		CodePos := Gdip_MeasureString2(G, codetext "|", hFont, hFormat, RC), CodePos[1]:=xoffset
		, CodePos[2]:=yoffset, mh:=CodePos[2]+CodePos[4], mw:=Max(CodePos[1]+CodePos[3]+CodePos[4], minw)
	} else {
		CodePos := Gdip_MeasureString2(G, codetext "|", hFont, hFormat, RC), CodePos[1]:=xoffset
		, CodePos[2]:=yoffset, mh:=CodePos[2]+CodePos[4], mw:=Max(CodePos[3], minw)
	}
	If (Textdirection=1||InStr(codetext, func_key)){
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
	Gdip_DeleteGraphics(G), hbm := CreateDIBSection(mw, mh), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetTextRenderingHint(G, 4+(FontSize<21))
	; 背景色
	Gdip_FillRoundedRectangle(G, pBrush[Background], 0, 0, mw-2, mh-2, 5)
	; 编码
	If (pBitmap && flagPos){
		CreateRectF(RC, CodePos[1], CodePos[2], w-30, h-30), Gdip_DrawString(G, subStr(codetext,1,flagPos-1), hFont, hFormat, pBrush[Code], RC)
		PW:=Gdip_GetImageWidth(pBitmap), PH:=Gdip_GetImageHeight(pBitmap)
		red:= "0x" subStr(CodeColor,1,2),green:= "0x" subStr(CodeColor,3,2),blue:= "0x" subStr(CodeColor,5,2)
		Matrix := "0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|1|0|" Round(red / 0xFF, 1) "|" Round(green / 0xFF, 1) "|" Round(blue / 0xFF, 1) "|0|1"
		Gdip_DrawImage(G, pBitmap, yanziPos[1], yanziPos[2], yanziPos[4], yanziPos[4], 0, 0, PW, PH, Matrix)
		CreateRectF(RC, yanziPos[1]+yanziPos[4], yanziPos[2], w-30, h-30), Gdip_DrawString(G, subStr(codetext,flagPos,2), hFont, hFormat, pBrush[Code], RC)
		if hasTail
			CreateRectF(RC, tailPos[1], tailPos[2], w-30, h-30), Gdip_DrawString(G, subStr(codetext,flagPos+2), hFont, hFormat, pBrush[invalid], RC)
	} else {
		CreateRectF(RC, CodePos[1], CodePos[2], w-30, h-30), Gdip_DrawString(G, codetext, hFont, hFormat, pBrush[Code], RC)
	}
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
	Gdip_DrawRoundedRectangle(G, pPen_Border, 0, 0, mw-2, mh-2, 5)
	Gdip_DrawLine(G, pPen_Border, xoffset, CodePos[4]+CodePos[2], mw-xoffset, CodePos[4]+CodePos[2])
	UpdateLayeredWindow(@TSF, hdc, tx:=Min(x, Max(MonLeft, MonRight-mw)), ty:=Min(y, Max(MonTop, MonBottom-mh)), mw, mh)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)

	Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
	For __,_value in pBrush
		Gdip_DeleteBrush(_value)
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
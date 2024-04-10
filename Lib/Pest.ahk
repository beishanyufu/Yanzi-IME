class Pest 
{
    static num := 1897
    Hwnd := ""
    hdc := ""
    PassWord := ""
    alpha:= 255

    __New(pw){
        global bitmaps  
        If (!this.Hwnd){            
            ; num := Pest.num += 1
            Gui, New, +HwndHwnd
            this.Hwnd := Hwnd
            ; Gui, %Hwnd%:-Caption +E0x8080088 +ToolWindow +LastFound -DPIScale +AlwaysOnTop
            Gui, %Hwnd%:-Caption +E0x0080000 +ToolWindow +LastFound -DPIScale +AlwaysOnTop
            Gui, %Hwnd%:Show, NA
            WinSet, ExStyle, +0x20, ahk_id%Hwnd%
        }
        this.PassWord := pw  

        If (bitmaps.shield) {
            w:=Gdip_GetImageWidth(bitmaps.shield), h:=Gdip_GetImageHeight(bitmaps.shield)
        } Else {
            w:=100,h:=100
        }

        hFamily := Gdip_FontFamilyCreate("Microsoft YaHei UI"), hFont := Gdip_FontCreate(hFamily, 28*A_ScreenDPI/96, 0)
        hFormat := Gdip_StringFormatCreate(0x4000), Gdip_SetStringFormatAlign(hFormat, 0x00000800)  
        pBrush := []
        pBrush[1] := Gdip_BrushCreateSolid("0xFF0060FF")
        pBrush[3] := Gdip_BrushCreateSolid("0xFFFFFFFF")
        pBrush[2] := Gdip_BrushCreateSolid("0xFFFF3838")
        pBrush[4] := Gdip_BrushCreateSolid("0xFFFFFF00")
        hbm:=CreateDIBSection(w, h), hdc:=CreateCompatibleDC()
        obm:=SelectObject(hdc, hbm), DeleteObject(obm), G:=Gdip_GraphicsFromHDC(hdc) ;, Gdip_SetInterpolationMode(G, 7)
        yanPos := Gdip_MeasureString(G, "燕", hFont, hFormat, RC)
        yanPos:= StrSplit(yanPos, "|")
		yanPos[1]:=(w-yanPos[3])/2, yanPos[2]:=(h-yanPos[4])/2
        ; Gdip_FillRoundedRectangle(G, pBrush[4], 0, 0, 200, 50, 20)
        ; Gdip_FillRoundedRectangle(G, pBrush[2], 0, 50, 200, 50, 20)
        Gdip_DrawImage(G, bitmaps.shield, 0, 0, w, h, 0, 0, w, h)
        CreateRectF(RC, yanPos[1], yanPos[2], yanPos[3], yanPos[4]), Gdip_DrawString(G, this.PassWord, hFont, hFormat, pBrush[3], RC)
        UpdateLayeredWindow(Hwnd, hdc, 0, 0, 100, 100)
        ; SelectObject(hdc, obm)
        DeleteObject(hbm)
        this.hdc:=hdc ;DeleteDC(hdc)
        Gdip_DeleteGraphics(G)    ; , Gdip_DisposeImage(pBitmap)
        Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
        For __,_value in pBrush
            Gdip_DeleteBrush(_value)
        Random, startX, 100, A_ScreenWidth-300
        Random, startY, 100, A_ScreenHeight-300
        Gui, %Hwnd%:Show, x%startX% y%startY% NA
        ; UpdateLayeredWindow(Hwnd, hdc, 0, 0, 100, 100, 150)
        ; WinSet, Transparent, 150, ahk_id %Hwnd%
        this.breathe := ObjBindMethod(this, "huxi")
        breathe := this.breathe
        SetTimer % breathe, % 25


        Return this        
    }

    __Delete(){
        If (this.Hwnd){
            Hwnd:=this.Hwnd
            Gui, %Hwnd%:Destroy
            ; this.Hwnd:=""
        }
        If (this.hdc){
            DeleteDC(this.hdc)
        }
    }
    
    huxi(){
        static huxi
        If (this.alpha<=150){
            ; this.alpha:=50
            huxi:=True
        } Else If (this.alpha>=250){
            ; this.alpha:=255
            huxi:=False
        }
        this.alpha:=huxi?this.alpha+3:this.alpha-2 
        UpdateLayeredWindow(this.Hwnd, this.hdc,,,,, this.alpha)
    }     
        
}
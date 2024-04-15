; ##################################################################################################################################################################
; # 作者：北山愚夫
; # 时间：2024年4月3日 
; ##################################################################################################################################################################

class Pest 
{
    Hwnd := ""
    HDCs := {}
    PassWord := ""
    alpha:= 255
    existing:=True
    phase:=0
    startX:=0, startY:=0
    
    __New(pw){
        global gameBitmaps, totalPest  
        If (!this.Hwnd){            
            Gui, New, +HwndHwnd
            this.Hwnd := Hwnd
            ; Gui, %Hwnd%:-Caption +E0x8080088 +ToolWindow +LastFound -DPIScale +AlwaysOnTop
            Gui, %Hwnd%:-Caption +E0x0080000 +ToolWindow +LastFound -DPIScale +AlwaysOnTop
            Gui, %Hwnd%:Show, NA
            WinSet, ExStyle, +0x20, ahk_id%Hwnd%
        }
        this.PassWord := pw  

        ; If (gameBitmaps.shield) {
        ;     w:=Gdip_GetImageWidth(gameBitmaps.shield), h:=Gdip_GetImageHeight(gameBitmaps.shield)
        ; } Else {
        ;     w:=100,h:=100
        ; }
        w:=100,h:=100

        this.HDCs.shield:=createDCwithDIB(gameBitmaps.shield)
        this.HDCs.shieldAndPassword:=createDCwithDIB(gameBitmaps.shield)
        Random, rand10, 0, 10

        this.HDCs.pest:=createDCwithDIB(rand10<5?gameBitmaps.pest:gameBitmaps.pest2)        

        G:=Gdip_GraphicsFromHDC(this.HDCs.shieldAndPassword.1)
        hFamily := Gdip_FontFamilyCreate("Microsoft YaHei UI"), hFont := Gdip_FontCreate(hFamily, 24*A_ScreenDPI/96, 0)
        hFormat := Gdip_StringFormatCreate(0x4000), Gdip_SetStringFormatAlign(hFormat, 0x00000800)  
        pBrush := Gdip_BrushCreateSolid("0xFFFFFFFF")
        yanPos := Gdip_MeasureString(G, "燕", hFont, hFormat, RC)
        yanPos:= StrSplit(yanPos, "|")
		yanPos[1]:=(w-yanPos[3])/2, yanPos[2]:=(h-yanPos[4])/2-8
        CreateRectF(RC, yanPos[1], yanPos[2], yanPos[3], yanPos[4]), Gdip_DrawString(G, this.PassWord, hFont, hFormat, pBrush, RC)
        Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
        Gdip_DeleteBrush(pBrush)
        Gdip_DeleteGraphics(G)

        this.phase:=1
        UpdateLayeredWindow(Hwnd, this.HDCs.shield.1, 0, 0, 100, 100)

        Random, startX, 100, A_ScreenWidth-300
        Random, startY, 100, A_ScreenHeight-300
        this.startX:=startX, this.startY:=startY
        Gui, %Hwnd%:Show, x%startX% y%startY% NA
        CoordMode, ToolTip
        ToolTip, 发现害虫，正在破解护盾密码……, this.startX-80, this.startY+115
        this.startTime:=A_TickCount
        SetTimer % this, % 30
        Return this        
    }

    __Delete(){
        OutputDebug, % "__delete:" this.PassWord
    }
    
    Call(){
        Critical
        static huxi:=False, hdc
        global totalPest, timeLength, gameSound
        If (this.existing && this.phase=3){
            hdc:=this.HDCs.Pest.1
            UpdateLayeredWindow(this.Hwnd, hdc,,,,, 255)
            CoordMode, ToolTip
            ToolTip, 护盾解除！, this.startX, this.startY+115, 2
            if(gameSound)
                SoundPlay, res/yanzi.wav
            sleep,800
            this.disappear()
            Return
        }
        If (this.existing && A_TickCount-this.startTime>=timeLength*0.8/totalPest){
            if(gameSound)
                SoundPlay, res/low.wav
            this.disappear()
            Return
        }
        If (this.phase=1 && A_TickCount-this.startTime>=timeLength*0.8/totalPest/5){
            this.phase:=2
            hdc:=this.HDCs.shieldAndPassword.1
            ToolTip,,,,1
            CoordMode, ToolTip
            if(gameSound)
                SoundPlay, res/jiu.wav
            ToolTip, 破解密码成功，请速速输入！, this.startX-70, this.startY+115, 2
        }
        If (this.alpha<=150){
            ; this.alpha:=50
            huxi:=True
        } Else If (this.alpha>=250){
            ; this.alpha:=255
            huxi:=False
        }
        If (this.phase=1)
            hdc:=this.HDCs.shield.1
        this.alpha:=huxi?this.alpha+3:this.alpha-2 
        UpdateLayeredWindow(this.Hwnd, hdc,,,,, this.alpha)
    }

    Change2Phase3(){
        this.phase:=3
    }
    
    disappear(){
        global gameSound
        ToolTip,,,,2
        this.existing:=False
        Hwnd:=this.Hwnd
        Gui, %Hwnd%:Show, Hide
        SetTimer, % this, Delete
        If (this.Hwnd){
            Hwnd:=this.Hwnd
            Gui, %Hwnd%:Destroy
            ; this.Hwnd:=""
        }
        For k, v in this.HDCs {
            hbm:=SelectObject(v[1], v[2]), DeleteObject(hbm), DeleteDC(v[1])
        }
        CoordMode, ToolTip
        If (this.phase=3) {
            ; ToolTip, 一只燕子疾速掠过——, this.startX-50, this.startY+30, 3
        }Else{
            ToolTip, 害虫从雷达屏幕上消失了……, this.startX-60, this.startY+30, 3
        }
        SetTimer, RemoveToolTip3, -1000
    }
}

createDCwithDIB(bitmap){
    w:=Gdip_GetImageWidth(bitmap), h:=Gdip_GetImageHeight(bitmap)
    hbm:=CreateDIBSection(w, h), hdc:=CreateCompatibleDC()
    obm:=SelectObject(hdc, hbm)
    G:=Gdip_GraphicsFromHDC(hdc)
    Gdip_DrawImage(G, bitmap, 0, 0, w, h, 0, 0, w, h)
    Gdip_DeleteGraphics(G)
    Return [hdc,obm]
}

RemoveToolTip3:
    ToolTip,,,, 3
return
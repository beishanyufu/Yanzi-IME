#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

cloakings := ["缴","砭","锵"] ;,"崛","嫦","施力","di3簸A"]
score := 0
pests := []
For key, pw in cloakings {
    pests.push(new Pest(pw))
}

; While(pests.Length()){
;     InputBox, userInput
;     For Key, p in pests {
;         If (userInput=p.PassWord){
;             score += 10
;             ; pests.RemoveAt(Key)
;             Hwnd:=pests[Key].Hwnd
;             Gui, %Hwnd%:Show, Hide
;             pests[key]:="dead"
;             Break
;         }
;     }
;     remove(pests,"dead")
; }
Gui, 28:+hwndhwndx
Gui, 28:Default
Gui, 28:Margin, 12, 12
Gui, 28:Font, s10 bold, %GUIFont%
Gui, 28:Add, Text, xm+40 yp+30 w80 Right, 密码：
Gui, 28:Add, Edit, x+0 yp-5 w100 vuserInput gCheck
Gui, 28:Show, AutoSize, 燕子输入法
Return

Check:
    Gui 28:+OwnDialogs
    GuiControlGet, userInput, 28:, userInput
    For k, p in pests {
        If (userInput=p.PassWord){
            score += 10
            ; pests.RemoveAt(Key)
            Hwnd:=pests[k].Hwnd
            Gui, %Hwnd%:Show, Hide
            pests[k]:="dead"
            Sleep,100
            GuiControl,, userInput
            Break
        }
    }
    remove(pests,"dead")
    ; MsgBox, % userInput
    If(pests.Length()=0){
        MsgBox, % "你的分数是：" score
        ExitApp
    }
Return


MsgBox, 你获得了 %score% 分！
ExitApp


remove(obj,value){
    keys:=[]
    For K, V in obj {
        If (V=value){
            keys.push(K)
        }        
    }
    For K, V in keys {
        obj.Delete(v)
    }
}

class Pest 
{
    static num := 1897
    Hwnd := ""
    PassWord := ""
    __New(pw){
        global pToken_       
        If (!pToken_)&&(!pToken_:=Gdip_Startup()){
            MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
            return ""
        }
        If (!this.Hwnd){            
            ; num := Pest.num += 1
            Gui, New, +HwndHwnd
            this.Hwnd := Hwnd
            Gui, %Hwnd%:-Caption +E0x8080088 +ToolWindow +LastFound -DPIScale 
            Gui, %Hwnd%:Show, NA
            WinSet, ExStyle, +0x20, ahk_id%Hwnd%
        }
        this.PassWord := pw  
        hFamily := Gdip_FontFamilyCreate("Microsoft YaHei UI"), hFont := Gdip_FontCreate(hFamily, 20*A_ScreenDPI/96, 0)
        hFormat := Gdip_StringFormatCreate(0x4000), Gdip_SetStringFormatAlign(hFormat, 0x00000800)  
        pBrush := []
        pBrush[1] := Gdip_BrushCreateSolid("0xFF0060FF")
        pBrush[3] := Gdip_BrushCreateSolid("0xFFFFFFFF")
        pBrush[2] := Gdip_BrushCreateSolid("0xFFFF3838")
        pBrush[4] := Gdip_BrushCreateSolid("0xFFFFFF00")
        hbm:=CreateDIBSection(200, 100), hdc:=CreateCompatibleDC()
        obm:=SelectObject(hdc, hbm), G:=Gdip_GraphicsFromHDC(hdc) ;, Gdip_SetInterpolationMode(G, 7)
        Gdip_FillRoundedRectangle(G, pBrush[4], 0, 0, 200, 50, 20)
        Gdip_FillRoundedRectangle(G, pBrush[2], 0, 50, 200, 50, 20)
        CreateRectF(RC, 20, 55, 200-40, 50-10), Gdip_DrawString(G, this.PassWord, hFont, hFormat, pBrush[3], RC)
        UpdateLayeredWindow(Hwnd, hdc, 0, 0, 200, 100)
        SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)    ; , Gdip_DisposeImage(pBitmap)
        Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
        For __,_value in pBrush
            Gdip_DeleteBrush(_value)
        Random, startX, 100, A_ScreenWidth-300
        Random, startY, 100, A_ScreenHeight-300
        Gui, %Hwnd%:Show, x%startX% y%startY% NA
        return this
    }

    __Delete(){
        If (this.Hwnd){
            Hwnd:=this.Hwnd
            Gui, %Hwnd%:Destroy
            ; this.Hwnd:=""
        }
    }
}


#Include Gdip.ahk		; Gdip类库

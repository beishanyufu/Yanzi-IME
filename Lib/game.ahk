#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

If (!pToken_)&&(!pToken_:=Gdip_Startup()){
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    gameExit()
}

bitmaps:={}
If FileExist("res/shield.png")
    bitmaps.shield:=Gdip_CreateBitmapFromFile("res/shield.png")
If FileExist("res/pest01.png")
    bitmaps.pest01:=Gdip_CreateBitmapFromFile("res/pest01.png")
If FileExist("res/pest02.png")
    bitmaps.pest02:=Gdip_CreateBitmapFromFile("res/pest02.png")

cloakings := ["娓","醛","酶"] ;,"崛","嫦","施力","di3簸A"]
score := 0
pests := []
For key, pw in cloakings {
    pests.push(new Pest(pw))
}

Gui, 28:+hwndHwndx ;+AlwaysOnTop
Gui, 28:Default
Gui, 28:Margin, 12, 12
Gui, 28:Font, s10 bold, %GUIFont%
Gui, 28:Add, Text, xm+40 yp+30 w80 Right, 密码：
Gui, 28:Add, Edit, x+0 yp-5 w100 vuserInput gCheck
Gui, 28:Show, AutoSize, 燕子输入法
; WinSet, Transparent, 100, ahk_id %Hwndx%
Return

28GuiClose:
    gameExit()
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
        gameExit()
    }
Return


; MsgBox, 你获得了 %score% 分！
; ExitApp

; Gdip_MeasureString2(pGraphics, sString, hFont, hFormat, ByRef RectF){
; 	Ptr := A_PtrSize ? "UPtr" : "UInt", VarSetCapacity(RC, 16)
; 	DllCall("gdiplus\GdipMeasureString", Ptr, pGraphics, Ptr, &sString, "int", -1, Ptr, hFont, Ptr, &RectF, Ptr, hFormat, Ptr, &RC, "uint*", Chars, "uint*", Lines)
; 	return &RC ? [NumGet(RC, 0, "float"), NumGet(RC, 4, "float"), NumGet(RC, 8, "float"), NumGet(RC, 12, "float")] : 0
; }

gameExit(){
    global bitmaps, Pests
    For Key, Value in bitmaps {
        If (Value)
            Gdip_DisposeImage(Value)
    }
    ; For Key, Value in Pests {
    ;     Pests[key]:=""
    ; }
    pests:=""
    ExitApp
}


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



#Include Pest.ahk
#Include Gdip.ahk ; // 集成到主程序后可以删除

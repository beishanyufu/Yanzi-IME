#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

; Game:
    If (!pToken_)&&(!pToken_:=Gdip_Startup()){
        MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
        exitGame()
    }

    cloakings := ["娓","醛","酶","崛","嫦","施","簸","扮","僵","蹈","枫","蚣","鬟"]

    bitmaps:={}
    If FileExist("res/shield.png")
        bitmaps.shield:=Gdip_CreateBitmapFromFile("res/shield.png")
    If FileExist("res/pest01.png")
        bitmaps.pest01:=Gdip_CreateBitmapFromFile("res/pest01.png")
    If FileExist("res/pest02.png")
        bitmaps.pest02:=Gdip_CreateBitmapFromFile("res/pest02.png")

    Gui, 28:+hwndHwndx ;+AlwaysOnTop
    Gui, 28:Default
    Gui, 28:Margin, 12, 12
    Gui, 28:Font, s10 bold, %GUIFont%
    Gui, 28:Add, Button, x+15 yp-1 gStartGame, 开始
    Gui, 28:Add, Text, xm+40 yp+30 w80 Right, 密码：
    Gui, 28:Add, Edit, x+0 yp-5 w100 vuserInput gCheck
    Gui, 28:Show, AutoSize, 燕子输入法
    ; WinSet, Transparent, 100, ahk_id %Hwndx%
Return

StartGame:
    pests := []
    timeLength := 3000
    remainder := total := 2
    score := 0
    SetTimer, Detect, % timeLength/total
    SetTimer, Referee, 100
Return

28GuiClose:
    Critical
    ; Exit
    exitGame()
Return

Detect:
    Critical
    If(remainder > 0){
        OutputDebug, % remainder
        remainder -= 1
        Random, tn, 1, cloakings.Length()
        pests.push(p:=new Pest(cloakings[tn]))
        OutputDebug, % p.Password
    } Else {
        SetTimer,, Delete
    }
Return

Check:
    Critical
    GuiControlGet, userInput, 28:, userInput
    For k, p in pests {
        If (p.existing&&userInput=p.PassWord){
            score += 10
            Sleep,100
            GuiControl,, userInput
            p.disappear()        
            Break
        }
    }
Return

Referee:
    For K, V in pests {
        If (V.existing){
            Return
        }        
    }
    If(remainder=0){
        SetTimer,, Delete
        For K, V in pests {
            ; V.__Delete()
            pests[K]:=V:=""
            ; V:=6
        }
        ; pests:=[]
        Sleep,-1
        Gui 28:+OwnDialogs
        MsgBox, % "你的分数是：" score
    }
Return

exitGame(){
    global bitmaps, Pests
    For Key, Value in bitmaps {
        If (Value)
            Gdip_DisposeImage(Value)
    }
    For K, V in pests {
        if(IsObject(V)&&V.existing=True)
            V.disappear()
        pests[K]:=V:=""
    }
    pests:=""
    ExitApp
}

#Include game_Pest.ahk
#Include Gdip.ahk ; // 集成到主程序后可以删除

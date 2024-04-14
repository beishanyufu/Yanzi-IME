; ##################################################################################################################################################################
; # 作者：北山愚夫
; # 时间：2024年4月3日 
; ##################################################################################################################################################################

#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

Game:
    If (!pToken_)&&(!pToken_:=Gdip_Startup()){
        MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
        exitGame()
    }

    MsgBox,, --燕子遇英雄--, 燕子：害虫不可怕，就怕害虫有文化`n英雄：不怕不怕，我来助你一臂之力
    MsgBox,, --英雄做出征前的准备--,
    (
形势严峻：
害虫们装备了高科技隐身护盾！
还使用博大精深的汉字做密码！

英雄出征：
英雄，请带上我们紧急研发的害虫探测器！！
（低语：虽然目前还只是个半成品）
【使用说明】
1. 设定除虫作业难度等级（难度等级越高，单次作业（时长1分钟）
    探测到的害虫数量越多，但相应地每只害虫被锁定的时间也越短
2. 按下“开始探测”按钮
3. 在害虫被锁定期间，快速输入破解密码
    )
    DataPath:=A_ScriptDir "\..\Data\"
    gameWords := []
    If FileExist(DataPath "@fzm.txt"){
        game_tvar:=FileRead(DataPath "@fzm.txt")
        Loop, Parse, game_tvar, `n, `r
        {
            If (A_LoopField=""||SubStr(A_LoopField,1,1)="#")
                Continue
            ; srf_fzm_fancha_table[(tarr:=StrSplit(A_LoopField, "="))[1]]:=tarr[2]
            gameWords.push(StrSplit(A_LoopField, "=")[1])
        }
        gameWords.RemoveAt(3501, gameWords.Length()-3500)
        gameWords.RemoveAt(1, 2500)
    } Else {
        gameWords := ["娓","醛","酶","崛","嫦","施","簸","扮","僵","蹈","枫","蚣","鬟","瞅","墅","嗽","踊","蜻","蜡","蝇","蜘","蝉","嘛","嘀","赚","锹"]
    }
    gameBitmaps:={}
    gameSound:=0

    If FileExist("res/shield.png")
        gameBitmaps.shield:=Gdip_CreateBitmapFromFile("res/shield.png")
    If FileExist("res/pest.png") 
        gameBitmaps.pest:=Gdip_CreateBitmapFromFile("res/pest.png")
    If FileExist("res/pest2.png")
        gameBitmaps.pest2:=Gdip_CreateBitmapFromFile("res/pest2.png")
    If FileExist("res/xiaoyanzi.png")
        gameBitmaps.yanzi:=Gdip_CreateBitmapFromFile("res/xiaoyanzi.png")

    Gui, 28:Default
    Gui, 28:Margin, 12, 12
    Gui, 28:Font, s10 bold, %GUIFont%
    Gui, 28:Add, Text, xm ym Right, 作业难度：
	Gui, 28:Add, DropDownList, x+0 yp-3 w50 r10 vtotalPest  choose8, 1|2|3|4|5|6|7|8|9|10|11|12|13
    Gui, 28:Add, CheckBox, x+15 ys vgameSound gSetGameSound Checked%gameSound%, 声效
    Gui, 28:Add, Button, x+10 ys-5 Default gStartGame, 开始探测
    Gui, 28:Add, Text, xm y+10, 破解密码：
    Gui, 28:Add, Edit, x+0 yp-3 w190 vuserInput gCheckMima
    Gui, 28:Show, AutoSize, 害虫探测器-控制台

    gameYanzi:=""
    gameYanziDCDIB=""
    Gui, New, +HwndgameYanzi
    Gui, %gameYanzi%:-Caption +E0x0080000 +ToolWindow +LastFound -DPIScale +AlwaysOnTop
    Gui, %gameYanzi%:Show, NA
    WinSet, ExStyle, +0x20, ahk_id%gameYanzi%
    gameYanziDCDIB:=createDCwithDIB(gameBitmaps.yanzi)
    UpdateLayeredWindow(gameYanzi, gameYanziDCDIB.1, 0, 0, 200, 200)
    Gui, %gameYanzi%:Hide, x0 y0 NA
Return

StartGame:
    pests := []
    preyX:="", preyY:=""
    timeLength := 60000
    GuiControlGet, totalPest, 28:, totalPest
    remainder := totalPest ; := 2
    GuiControlGet, gameSound, 28:, gameSound        
    gameScore := 0
    GuiControl, 28:Enable0, 难度等级：
    GuiControl, 28:Enable0, totalPest
    ; GuiControl, 28:Enable0, gameSound
    GuiControl, 28:Enable0, 开始
    SetTimer, DetectPest, % -1000
    SetTimer, Referee, 100
Return

SetGameSound:
    GuiControlGet, gameSound, 28:, gameSound
Return

28GuiClose:
    Critical
    exitGame()
Return

DetectPest:
    Critical
    OutputDebug, % remainder
    remainder -= 1
    Random, tn, 1, gameWords.Length()
    pests.push(p:=new Pest(gameWords[tn]))
    OutputDebug, % p.Password
    If(remainder > 0)
        SetTimer, DetectPest, % -timeLength/totalPest
Return

CheckMima:
    Critical
    GuiControlGet, userInput, 28:, userInput
    For k, p in pests {
        If (p.existing&&userInput=p.PassWord){
            gameScore += 1
            Sleep,100
            GuiControl,, userInput
            p.Change2Phase3() 
            preyX:=p.startX, preyY:=p.startY
            SetTimer, YanziPrey, -800       
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
        }
        ; pests:=[]
        Sleep,-1
        Gui 28:+OwnDialogs
        If (gameScore){
            title:="--英雄凯旋--"
            result:="好样的英雄！您本次出征和燕子联手消灭了 " gameScore " 只害虫！"
            if(gameSound)
                SoundPlay, res/v.wav
        }Else{
            title:="--英雄归来--"
            result:="别灰心，英雄。我想您只是对我们的探测器还不熟悉。刚开始使用，您可以适当调低作业难度。"
        }
        MsgBox,, % title, % result
        GuiControl, 28:Enable1, 难度等级：
        GuiControl, 28:Enable1, totalPest
        ; GuiControl, 28:Enable1, gameSound
        GuiControl, 28:Enable1, 开始
    }
Return

YanziPrey:
    Critical
    ; global gameYanzi,gameYanziDCDIB
    preyX+=200
    preyY-=100
    Loop, 3
    {
        Gui, %gameYanzi%:Show, x%preyX% y%preyY% NA
        preyX-=200
        Sleep, 10
    }
    Gui, %gameYanzi%:Hide, x0 y0 NA
Return

exitGame(){
    global gameBitmaps, Pests, gameYanzi, gameYanziDCDIB
    For Key, Value in gameBitmaps {
        If (Value)
            Gdip_DisposeImage(Value)
    }
    For K, V in pests {
        if(IsObject(V)&&V.existing=True)
            V.disappear()
        pests[K]:=V:=""
    }
    pests:=""
    Gui, 28:Destroy
    Gui, %gameYanzi%:Destroy
    hbm:=SelectObject(gameYanziDCDIB[1], gameYanziDCDIB[2]), DeleteObject(hbm), DeleteDC(gameYanziDCDIB[1])
    ExitApp
}

#Include game_Pest.ahk
#Include Gdip.ahk ; 集成到主程序后可以删除
#Include Yzlibfunc.ahk ; 集成到主程序后可以删除

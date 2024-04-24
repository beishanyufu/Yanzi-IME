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
英雄，请带上我们最新研发的害虫探测器！！

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
    If FileExist("res/yanwo.png")
        gameBitmaps.yanwo:=Gdip_CreateBitmapFromFile("res/yanwo.png")

    Gui, 28:Default
    Gui, 28:Margin, 12, 12
    Gui, 28:Font, s10 bold, %GUIFont%
    Gui, 28:Add, Text, xm ym Right, 作业难度：
	Gui, 28:Add, DropDownList, x+0 yp-3 w50 r10 vtotalPest  choose6, 1|2|3|4|5|6|7|8|9|10|11|12
    Gui, 28:Add, CheckBox, x+15 ys vgameSound gSetGameSound Checked%gameSound%, 声效
    Gui, 28:Add, Button, x+10 ys-5 Default gStartGame, 开始探测
    Gui, 28:Add, Text, xm y+10, 破解密码：
    Gui, 28:Add, Edit, x+0 yp-3 w190 vuserInput gCheckMima
    GuiControl, 28:Enable0, userInput
    Gui, 28:Show, AutoSize, 害虫探测器-控制台

    gameYanzi:=""
    gameYanziDCDIB:={}
    Gui, New, +HwndgameYanzi
    Gui, %gameYanzi%:-Caption +E0x0080000 +ToolWindow +LastFound -DPIScale +AlwaysOnTop
    Gui, %gameYanzi%:Show, NA
    WinSet, ExStyle, +0x20, ahk_id%gameYanzi%
    gameYanziDCDIB.yanzi:=createDCwithDIB(gameBitmaps.yanzi)
    UpdateLayeredWindow(gameYanzi, gameYanziDCDIB.yanzi.1, 0, 0, 200, 200)
    Gui, %gameYanzi%:Hide, x0 y0 NA

    gameNest:= ""
    TalkOnStart:=["我们是观众，", "我们是观众，", "看妈妈捉害虫，", "看爸爸捉害虫；", "屏幕前的家伙，", "据说也很厉害，", "能让害虫破防，", "能让害虫现原形！"]
    TalkOnPrey:=["妈妈捉到一只！", "爸爸捉到一只！", "妈妈好厉害！", "爸爸好棒！"]
    Gui, New, +HwndgameNest
    Gui, %gameNest%:-Caption +E0x0080000 +ToolWindow +LastFound -DPIScale +AlwaysOnTop
    Gui, %gameNest%:Show, NA
    WinSet, ExStyle, +0x20, ahk_id%gameNest%
    gameYanziDCDIB.nest:=createDCwithDIB(gameBitmaps.yanwo)
    UpdateLayeredWindow(gameNest, gameYanziDCDIB.nest.1, 0, 0, 260, 187)
    Gui, %gameNest%:Show, % "x" A_ScreenWidth-260 " y" 0 " NA"
    NestToolTip(TalkOnStart[1], A_ScreenWidth-200, -2000)
    SetTimer, StartTalk, -100

Return

StartTalk:
    CoordMode, ToolTip
    For Key, Value in TalkOnStart {
        ToolTip, %value%, % A_ScreenWidth-190, 110, 11
        Sleep, 2000
    }
    Gosub, RemoveToolTip11
Return

StartGame:
    pests := []
    preyX:="", preyY:=""
    yanziXYs:=[]
    timeLength := 60000
    GuiControlGet, totalPest, 28:, totalPest
    remainder := totalPest ; := 2
    GuiControlGet, gameSound, 28:, gameSound        
    gameScore := 0
    GuiControl, 28:Enable0, 难度等级：
    GuiControl, 28:Enable0, totalPest
    ; GuiControl, 28:Enable0, gameSound
    GuiControl, 28:Enable0, 开始
    GuiControl, 28:Enable0, totalPest
    GuiControl, 28:Enable1, userInput
    GuiControl, 28:Focus, userInput
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

28GuiSize:
    Critical
    If (A_EventInfo=1){
        If(gameNest)
            Gui, %gameNest%:Hide
    } Else {
        If(gameNest)
            Gui, %gameNest%:Show, NA
    }
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
            SetTimer, YanziPrey, -600       
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
    If (remainder=0){
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
            NestToolTip("爸爸说，他们负责抓，我们负责吃。", A_ScreenWidth-300, -3000)
        }Else{
            title:="--英雄归来--"
            result:="别灰心，英雄。我想您只是对我们的探测器还不熟悉。刚开始使用，您可以适当调低作业难度。"
            NestToolTip("肚子饿得咕咕叫……", A_ScreenWidth-200, -3000)

        }
        MsgBox,, % title, % result
        GuiControl, 28:Enable1, 难度等级：
        GuiControl, 28:Enable1, totalPest
        ; GuiControl, 28:Enable1, gameSound
        GuiControl, 28:Enable1, 开始
        GuiControl, 28:Enable0, userInput
        ; GuiControl, 28:Focus, 开始
    }
Return

YanziPrey:
    Critical
    ; global gameYanzi,gameYanziDCDIB
    yanziXYs:=[]
    preyY-=100
    yanziXYs.push([preyX,preyY])
    Loop {
        preyX-=200    
        preyY-=50
        If (preyX>-150 && preyY>-150)
            yanziXYs.push([preyX,preyY])
        Else
            break    
    }
    preyX:=yanziXYs[1][1], preyY:=yanziXYs[1][2]
    Loop {
        preyX+=200    
        preyY-=60
        If (preyX<A_ScreenWidth-50 && preyY>-150)
            yanziXYs.InsertAt(1,[preyX,preyY])
        Else
            break    
    }
    Gui, %gameYanzi%:Show, x0 y-300 NA
    For Key, Value in yanziXYs {
        preyX:=Value[1], preyY:=Value[2]
        Gui, %gameYanzi%:Show, x%preyX% y%preyY% NA
        Sleep, 5
    }
    Random, OutputVar, 1, % TalkOnPrey.Length()
    NestToolTip(TalkOnPrey[OutputVar], A_ScreenWidth-200, -2000)
    Gui, %gameYanzi%:Hide, x0 y0 NA
Return

exitGame(){
    global gameBitmaps, Pests, gameYanzi, gameYanziDCDIB, gameNest
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
    Gui, %gameNest%:Destroy
    For Key, Value in gameYanziDCDIB {
        hbm:=SelectObject(Value[1], Value[2]), DeleteObject(hbm), DeleteDC(Value[1])
    }
    ExitApp
}

NestToolTip(tip, x:=1600, period:=-3000){
    CoordMode, ToolTip
    ToolTip, %tip%, %x%, 110, 11
    SetTimer, RemoveToolTip11, %period%
}

RemoveToolTip11:
    ToolTip,,,, 11
return

#Include game_Pest.ahk
#Include Gdip.ahk ; 集成到主程序后可以删除
#Include Yzlibfunc.ahk ; 集成到主程序后可以删除

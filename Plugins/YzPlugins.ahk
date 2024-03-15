#Include %A_ScriptDir%\..\Lib\RegisterPlugins.ahk
Class YzPlugins
{
	static GUID:=A_Args[2], Version:="1.0.0"
	GetVar(Var){
		global
		value:=%Var%
		Return value
	}
	qrcode(string:=""){		; 二维码生成
		static str
		If (string=""){
			ClipSaved:=ClipboardAll
			Clipboard:=""
			SendInput, {RCtrl Down}c{RCtrl Up}
			ClipWait, 0.5
			str:=Clipboard, Clipboard:=ClipSaved
		} Else
			str:=string
		SetTimer, makeqrcode, -10
		Return
		makeqrcode:
		If (str=""){
			InputBox, str, 输入文本, , , , 100
			If (ErrorLevel)
				Return
		}
		picHeight:=Max(300,Min(A_ScreenHeight-200,StrLen(str)+100))
		Gui, 1:-DPIScale
		Gui, 1:Margin , 0, 0
		If (A_PtrSize=4)
			DllCall(A_WorkingDir "\Lib\Dll_x86\quricol32.dll\GeneratePNG","str", sFile:=A_Temp "\" A_NowUTC ".png", "str", str, "int", 5, "int", 5, "int", 0)
		Else
			DllCall(A_WorkingDir "\Lib\Dll_x64\quricol64.dll\GeneratePNG","str", sFile:=A_Temp "\" A_NowUTC ".png", "str", str, "int", 5, "int", 5, "int", 0)
		Gui, 1:Add,Picture, h%picHeight% w-1 gSaveAs, % sFile
		Gui, 1:Show, ,点击保存图片 Esc关闭
		str:=""
		Return
		SaveAs:
			Fileselectfile,nf,s16,,另存为,PNG图片(*.png)
			If !StrLen(nf)
				Return
			nf := RegExMatch(nf,"i)\.png") ? nf : nf ".png"
			FileMove,%sFile%,%nf%,1
		Return
		GuiEscape:
		GuiClose:
			Gui, 1:Destroy
			FileDelete, %sFile%
		Return
	}
}

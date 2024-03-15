#NoEnv
#NoTrayIcon
#SingleInstance Ignore
#MaxMem 512
ListLines Off
SetBatchLines -1
global DllFolder:=A_ScriptDir "\..\Dll_x" (A_PtrSize=4?"86":"64")
If IsLabel(A_Args[1])
	Gosub % A_Args[1]
Else If IsFunc(A_Args[1])
	funcname:=A_Args[1], %funcname%()
ExitApp

Synchronizedb(){
	Critical
	IniRead, DBpath, %A_ScriptDir%\..\Data\Yzime.ini, DBFile, main, Data\ciku.db
	FileRead, SQL, %A_Temp%\Yzime\yzime_sql.tmp
	FileDelete %A_Temp%\Yzime\yzime_sql.tmp
	If (Trim(SQL,"`n ")="")
		Return
	SyDB:=new SQLiteDB
	If !SyDB.OpenDB(DBpath,"W",0){
		FileAppendAtBegin(SQL, A_Temp "\Yzime\yzime_sql.tmp")
		MsgBox, 16, DBService错误, % "消息:`t" SyDB.ErrorMsg "`n代码:`t" SyDB.ErrorCode
		Return
	}
	SyDB.CreateScalarFunc("REGEXP", 2, RegisterCallback("SQLiteDB_RegExp", "C"))
	SyDB.CreateScalarFunc("REGEXPR", 3, RegisterCallback("SQLiteDB_RegExpR", "C"))
	SyDB.CreateScalarFunc("szm", 1, RegisterCallback("shouzimu", "C"))
	If !SyDB.Exec("BEGIN TRANSACTION;"){
		FileAppendAtBegin(SQL, A_Temp "\Yzime\yzime_sql.tmp")
		MsgBox, 16, DBService错误, % "消息:`t" SyDB.ErrorMsg "`n代码:`t" SyDB.ErrorCode
		Return
	}
	_SQL:="", index:=0
	Loop, Parse, SQL, `n, `r
	{
		If (A_LoopField="")
			Continue
		_SQL .= A_LoopField "`n", index++
		If (index>199)
			SyDB.Exec(_SQL), index:=0
	}
	If (index)
		SyDB.Exec(_SQL), _SQL:=SQL:=""
	SyDB.Exec("COMMIT TRANSACTION;")
	SyDB.CloseDB(), SyDB:=""
}

FileAppendAtBegin(ByRef str, path){
	file:=FileOpen(path, "rw", "UTF-8")
	t:=file.Read()
	file.Seek(0, 0)
	file.Write(str t)
	file.Close(), t:=""
}

#Include %A_ScriptDir%\..\Class_SQLiteDB.ahk
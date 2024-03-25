; 内置函数定义模块
module_functions:	; 函数声明，{代码函数名:["使用函数别名","函数说明"]}	函数说明在<选项>/<控制> 中显示。
srf_Default_Func:={time:["time","格式化时间，如：time/；time/132555；time/s；time/c"],date:["date","格式化日期，如：date/；date/20191001；date/s；date/c"],lunar:["lunar","农历日期，如：lunar/；lunar/20191001；lunar/s；lunar/c；lunar/YYYY年Md"],n2c:["num","转换成中文小写(大写)数字，如：/12345；/12345/d；num/s；num/12345；num/c"]
	,Time_GetShichen:["Shichen","农历时辰，如：shichen/；shichen/23"],get_hotstring:["magic","魔法字符串，如：magic/lala"],get_function:["run","超级命令，如：run/qq"],wStrLen:["len","计算剪切板或选择范围的字符数，如：len/c；len/s"],Cliphistory:["clip","剪贴板历史记录"]
	,bin:["dtb","十进制转二进制，如：dtb/512；dtb/s；dtb/c"],Dec_Hex:["dth","十进制转十六进制，如：dth/512；dth/s；dth/c"],hex2bin:["htb","十六进制转二进制，如：htb/512；htb/s；htb/c"],Hex_Dec:["htd","十六进制转十进制，如：htd/512；htd/s；htd/c"]
	,Dec:["btd","二进制转十进制，如：btd/512；btd/s；btd/c"],bin2hex:["bth","二进制转十六进制，如：bth/512；bth/s；bth/c"],label_list:["label","标签跳转，label/"],mode_list:["mode","模式切换，mode/"],Inputscheme_list:["scheme","切换输入方案，scheme/"]
	,hideorshowwindows:["hide","隐藏顶层窗口/显示隐藏的窗口，hide/s、hide/a、hide/"],Last_input:["last","上次输入的词条，last/、last/2"]}
Return

hideorshowwindows(p:=""){
	local
	static history:=[]
	If (p=""){
		WinGet, Hwnd, ID, A
		WinGetTitle, title, % "ahk_id" Hwnd
		Return [{0:"{Func}",1:"hideorshowwindows(h)",3:"隐藏‘" title "’"},{0:"{Func}",1:"hideorshowwindows(a)",3:"显示所有隐藏窗口"}]
	} Else If (p="s"){
		result:=[]
		Loop % history.Length()
			result.Push({0:"{Func}",1:"hideorshowwindows(" A_index ")",3:"显示‘" history[A_index,1] "’"})
		Return result
	} Else If (p="a"){
		Loop % history.Length()
			WinShow, % "ahk_id" history[A_index,2]
		WinActivate, % "ahk_id" history[history.Length(),2]
		history:=[]
		Return [{0:"{Off}"}]
	} Else If (p~="^\d+$"){
		WinShow, % "ahk_id" history[p,2]
		WinActivate, % "ahk_id" history[p,2]
		history.RemoveAt(p)
	} Else If (p="h"){
		WinGet, Hwnd, ID, A
		WinGetTitle, title, % "ahk_id" Hwnd
		If (title="")
			Return
		Loop % history.Length()
			If history[A_index,2]=Hwnd
				Return
		WinHide, % "ahk_id" Hwnd
		history.Push([title,Hwnd])
		Loop {
			Hwnd:=DllCall("GetWindow", "Ptr", Hwnd, "UInt", 2)
		} Until DllCall("IsWindowVisible", "Ptr", Hwnd)
		WinActivate, ahk_id%Hwnd%
	}
}
;-------------------------公历转农历-公历日期「大写」-------------------------
/*
<参数>
Gregorian:
公历日期 格式 YYYYMMDD
<返回值>
农历日期 中文 天干地支属相
*/
time(str:="",cn:=0,geshi:=""){
	If (str="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		str:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (str="c")
		str:=Clipboard
	Else If (str="z")
		str:="", cn:=1
	If (geshi=""){
		If str~="^\d+$"
			geshi:="H时" (StrLen(str)<3?"":"mm分" (StrLen(str)<5?"":"ss秒")), str:=SubStr(A_Now,1,8) SubStr(str "000000",1,6)
		Else If str
			geshi:=str, str:=""
		Else
			geshi:="H时mm分"
	}
	TimeVar:=FormatTime(str,geshi,cn)
	If !TimeVar
		Return [{0:"{Value}",1:"",3:"无效时间"}]
	Return TimeVar
}
date(str:="",cn:=0,geshi:=""){
	If (str="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		str:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (str="c")
		str:=Clipboard
	Else If (str="z")
		str:="", cn:=1
	If (geshi=""){
		str:=StrReplace(str,"\\","/")
		If (str="")
			geshi:="yyyy年M月d日"
		Else If (str~="[^\d\.]")
			geshi:=str, str:=""
		Else If RegExMatch(str,"O)^(1[0-2]|0?[1-9])\.?([1-3]\d|0?[1-9])?$",mm){
			geshi:="M月" (mm.Value[2]?"d日":""), str:=Format("2020{:02}{:02}",mm.Value[1],mm.Value[2]?mm.Value[2]:1)
		} Else If RegExMatch(str,"O)^(2\d\d\d|19\d\d|18\d\d|\d\d)\.?(1[0-2]|0?[1-9])?\.?([1-3]\d|0?[1-9])?$",mm){
			If (StrLen(mm.Value[1])=2){
				str:="20" mm.Value[1] Format("{:02}{:02}",mm.Value[2]?mm.Value[2]:1,mm.Value[3]?mm.Value[3]:1)
				geshi:="yy年" (mm.Value[2]?"M月":"") (mm.Value[3]?"d日":"")
			} Else If (StrLen(mm.Value[1])=4)
				geshi:="yyyy年"  (mm.Value[2]?"M月":"") (mm.Value[3]?"d日":""), str:=mm.Value[1] Format("{:02}{:02}",mm.Value[2]?mm.Value[2]:1,mm.Value[3]?mm.Value[3]:1)
		} Else
			Return [{0:"{Value}",1:"",3:"无效日期"}]
	}
	DateVar:=FormatTime(str,geshi,cn)
	If !DateVar
		Return [{0:"{Value}",1:"",3:"无效日期"}]
	Return DateVar
}
FormatTime(str,geshi:="",cn:=0){
	local
	If (cn)
		geshi:=StrReplace(geshi,"y","Y")
	FormatTime, Var, %str%, %geshi%
	If (cn){
		If RegExMatch(Var,"Y+",Match)&&((t:=FormatTime(str,Format("{:L}", Match)))~="^\d+$")
			Var:=StrReplace(Var, Match, n2c(t,"r"))
		Else If RegExMatch(Var, "(\d+)年", Match)&&(Mod(StrLen(Match),2)=1)
			Var:=StrReplace(Var, Match, n2c(Match1,"r") "年")
		While RegExMatch(Var, "\d+", Match)
			Var:=StrReplace(Var, Match, n2c(Match," "), , 1)
	}
	Return Var
}
lunar(Gregorian:="",geshi:=""){
	If (Gregorian="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		Gregorian:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (Gregorian="c")
		Gregorian:=Clipboard
	;1899年~2100年农历数据
	;前三位，Hex，转Bin，表示当年月份，1为大月，0为小月
	;第四位，Dec，表示闰月天数，1为大月30天，0为小月29天
	;第五位，Hex，转Dec，表示是否闰月，0为不闰，否则为闰月月份
	;后两位，Hex，转Dec，表示当年新年公历日期，格式MMDD
	LunarData=
	(LTrim Join
	AB500D2,4BD0883,
	4AE00DB,A5700D0,54D0581,D2600D8,D9500CC,655147D,56A00D5,9AD00CA,55D027A,4AE00D2,
	A5B0682,A4D00DA,D2500CE,D25157E,B5500D6,56A00CC,ADA027B,95B00D3,49717C9,49B00DC,
	A4B00D0,B4B0580,6A500D8,6D400CD,AB5147C,2B600D5,95700CA,52F027B,49700D2,6560682,
	D4A00D9,EA500CE,6A9157E,5AD00D6,2B600CC,86E137C,92E00D3,C8D1783,C9500DB,D4A00D0,
	D8A167F,B5500D7,56A00CD,A5B147D,25D00D5,92D00CA,D2B027A,A9500D2,B550781,6CA00D9,
	B5500CE,535157F,4DA00D6,A5B00CB,457037C,52B00D4,A9A0883,E9500DA,6AA00D0,AEA0680,
	AB500D7,4B600CD,AAE047D,A5700D5,52600CA,F260379,D9500D1,5B50782,56A00D9,96D00CE,
	4DD057F,4AD00D7,A4D00CB,D4D047B,D2500D3,D550883,B5400DA,B6A00CF,95A1680,95B00D8,
	49B00CD,A97047D,A4B00D5,B270ACA,6A500DC,6D400D1,AF40681,AB600D9,93700CE,4AF057F,
	49700D7,64B00CC,74A037B,EA500D2,6B50883,5AC00DB,AB600CF,96D0580,92E00D8,C9600CD,
	D95047C,D4A00D4,DA500C9,755027A,56A00D1,ABB0781,25D00DA,92D00CF,CAB057E,A9500D6,
	B4A00CB,BAA047B,AD500D2,55D0983,4BA00DB,A5B00D0,5171680,52B00D8,A9300CD,795047D,
	6AA00D4,AD500C9,5B5027A,4B600D2,96E0681,A4E00D9,D2600CE,EA6057E,D5300D5,5AA00CB,
	76A037B,96D00D3,4AB0B83,4AD00DB,A4D00D0,D0B1680,D2500D7,D5200CC,DD4057C,B5A00D4,
	56D00C9,55B027A,49B00D2,A570782,A4B00D9,AA500CE,B25157E,6D200D6,ADA00CA,4B6137B,
	93700D3,49F08C9,49700DB,64B00D0,68A1680,EA500D7,6AA00CC,A6C147C,AAE00D4,92E00CA,
	D2E0379,C9600D1,D550781,D4A00D9,DA400CD,5D5057E,56A00D6,A6C00CB,55D047B,52D00D3,
	A9B0883,A9500DB,B4A00CF,B6A067F,AD500D7,55A00CD,ABA047C,A5A00D4,52B00CA,B27037A,
	69300D1,7330781,6AA00D9,AD500CE,4B5157E,4B600D6,A5700CB,54E047C,D1600D2,E960882,
	D5200DA,DAA00CF,6AA167F,56D00D7,4AE00CD,A9D047D,A2D00D4,D1500C9,F250279,D5200D1
	)
	If (geshi=""&&Gregorian~="[^\d]")
		geshi:=Gregorian, Gregorian:=A_Now
	If (Gregorian="")
		Gregorian:=A_Now
	Else If (Gregorian~="^\d+$")
		Gregorian .= SubStr(SubStr(A_Now,1,8),StrLen(Gregorian)+1)
	Else
		Return [{0:"{Value}",1:"",3:"无效日期"}]
	Gregorian:=SubStr(Gregorian,1,8)
	;分解公历年月日
	StringLeft,Year,Gregorian,4
	StringMid,Month,Gregorian,5,2
	StringMid,Day,Gregorian,7,2
	If (Year>2100 Or Year<1900)
		Return [{0:"{Value}",1:"",3:"无效日期"}]

	;获取两年内的农历数据
	Pos:=(Year-1900)*8+1
	StringMid,Data0,LunarData,%Pos%,7
	Pos+=8
	StringMid,Data1,LunarData,%Pos%,7

	;判断农历年份
	Analyze(Data1,MonthInfo,LeapInfo,Leap,Newyear)
	Date1=%Year%%Newyear%
	Date2:=Gregorian
	EnvSub,Date2,%Date1%,Days
	If Date2<0					;和当年农历新年相差的天数
	{
		Analyze(Data0,MonthInfo,LeapInfo,Leap,Newyear)
		Year-=1
		Date1=%Year%%Newyear%
		Date2:=Gregorian
		EnvSub,Date2,%Date1%,Days
	}
	;计算农历日期
	Date2+=1
	LYear:=Year		;农历年份，就是上面计算后的值
	If Leap			;有闰月
	{
		StringLeft,p1,MonthInfo,%Leap%
		StringTrimLeft,p2,MonthInfo,%Leap%
		thisMonthInfo:=p1 . LeapInfo . p2
	} Else
		thisMonthInfo:=MonthInfo
	loop,13
	{
		StringMid,thisMonth,thisMonthInfo,%A_index%,1
		thisDays:=29+thisMonth
		If Date2>%thisDays%
			Date2:=Date2-thisDays
		Else {
			If leap	{
				If leap>%a_index%
					LMonth:=A_index
				Else
					LMonth:=A_index-1
			}
			Else
				LMonth:=A_index
			LDay:=Date2
			Break
		}
	}
	; LDate=%LYear%年%LMonth%月%LDay%		;完成
;~ 	MsgBox,% LDate
	;转换成习惯性叫法
	Order1:=Mod((LYear-4),10)+1
	Order2:=Mod((LYear-4),12)+1
	Year:=StrSplit("甲乙丙丁戊已庚辛壬癸")[Order1] StrSplit("子丑寅卯辰巳午未申酉戌亥")[Order2]
	LYear:=n2c(LYear,"r")
	SX:=StrSplit("鼠牛虎兔龙蛇马羊猴鸡狗猪")[Order2]
	Month:=StrSplit("正,二,三,四,五,六,七,八,九,十,十一,腊",",")[LMonth] "月"
	Day:=StrSplit("初一,初二,初三,初四,初五,初六,初七,初八,初九,初十,十一,十二,十三,十四,十五,十六,十七,十八,十九,二十,廿一,廿二,廿三,廿四,廿五,廿六,廿七,廿八,廿九,三十",",")[LDay]
	Week:=SubStr(A_YWeek,-1)
	geshi:=geshi?geshi:"YY年Md"
	geshi:=StrReplace(geshi,"YYYY","%Lyear%")
	geshi:=StrReplace(geshi,"YY","%Year%")
	geshi:=StrReplace(geshi,"SX","%SX%")
	geshi:=StrReplace(geshi,"M","%Month%")
	geshi:=StrReplace(geshi,"d","%Day%")
	geshi:=StrReplace(geshi,"Week","%Week%")
	Transform, LDate, Deref, %geshi%
	Return LDate
}

;获取农历时辰
Time_GetShichen(time:="")
{
	shichen :=["子时（夜半｜『三更』）","丑时（鸡鸣｜『四更』）","丑时（鸡鸣｜『四更』）","寅时（平旦｜『五更』）","寅时（平旦|『五更』）","卯时（日出）","卯时（日出）","辰时（食时）","辰时（食时）","巳时（隅中）","巳时（隅中）","午时（日中）","午时（日中）","未时（日昳）","未时（日昳）","申时（哺时）","申时（哺时）","酉时（日入）","酉时（日入）","戌时（黄昏｜『一更』）","戌时（黄昏｜『一更』）","亥时（人定｜『二更』）","亥时（人定｜『二更』）","子时（夜半｜『三更』）"]
	If (time="")
		time:=SubStr(A_Now,9,2)
	time_count :=time+1
	Loop % shichen.MaxIndex()
	%A_Index% = %time_count%
	LShichen :=shichen[time_count]
	Return,LShichen
}

;-------------------------农历转公历-------------------------
/*
<参数>
Lunar:
农历日期
IsLeap:
是否闰月
如，某年闰7月，第一个7月不是闰月，第二个7月是闰月，IsLeap=1
当年没有闰月这个参数无效
<返回值>
公历日期(YYYYDDMM)
*/
Date_GetDate(Lunar,IsLeap=0)
{
	;分解农历年月日
	StringLeft,Year,Lunar,4
	StringMid,Month,Lunar,5,2
	StringRight,Day,Lunar,2
	If substr(Month,1,1)=0
		StringTrimLeft,month,month,1
	If (Year>2100 Or Year<1900 or Month>12 or Month<1 or Day>30 or Day<1)
	{
		errorinfo=无效日期
		Return,errorinfo
	}

	;1899年~2100年农历数据
	;前三位，Hex，转Bin，表示当年月份，1为大月，0为小月
	;第四位，Dec，表示闰月天数，1为大月30天，0为小月29天
	;第五位，Hex，转Dec，表示是否闰月，0为不闰，否则为闰月月份
	;后两位，Hex，转Dec，表示当年新年公历日期，格式MMDD
	LunarData=
	(LTrim Join
	AB500D2,4BD0883,
	4AE00DB,A5700D0,54D0581,D2600D8,D9500CC,655147D,56A00D5,9AD00CA,55D027A,4AE00D2,
	A5B0682,A4D00DA,D2500CE,D25157E,B5500D6,56A00CC,ADA027B,95B00D3,49717C9,49B00DC,
	A4B00D0,B4B0580,6A500D8,6D400CD,AB5147C,2B600D5,95700CA,52F027B,49700D2,6560682,
	D4A00D9,EA500CE,6A9157E,5AD00D6,2B600CC,86E137C,92E00D3,C8D1783,C9500DB,D4A00D0,
	D8A167F,B5500D7,56A00CD,A5B147D,25D00D5,92D00CA,D2B027A,A9500D2,B550781,6CA00D9,
	B5500CE,535157F,4DA00D6,A5B00CB,457037C,52B00D4,A9A0883,E9500DA,6AA00D0,AEA0680,
	AB500D7,4B600CD,AAE047D,A5700D5,52600CA,F260379,D9500D1,5B50782,56A00D9,96D00CE,
	4DD057F,4AD00D7,A4D00CB,D4D047B,D2500D3,D550883,B5400DA,B6A00CF,95A1680,95B00D8,
	49B00CD,A97047D,A4B00D5,B270ACA,6A500DC,6D400D1,AF40681,AB600D9,93700CE,4AF057F,
	49700D7,64B00CC,74A037B,EA500D2,6B50883,5AC00DB,AB600CF,96D0580,92E00D8,C9600CD,
	D95047C,D4A00D4,DA500C9,755027A,56A00D1,ABB0781,25D00DA,92D00CF,CAB057E,A9500D6,
	B4A00CB,BAA047B,AD500D2,55D0983,4BA00DB,A5B00D0,5171680,52B00D8,A9300CD,795047D,
	6AA00D4,AD500C9,5B5027A,4B600D2,96E0681,A4E00D9,D2600CE,EA6057E,D5300D5,5AA00CB,
	76A037B,96D00D3,4AB0B83,4AD00DB,A4D00D0,D0B1680,D2500D7,D5200CC,DD4057C,B5A00D4,
	56D00C9,55B027A,49B00D2,A570782,A4B00D9,AA500CE,B25157E,6D200D6,ADA00CA,4B6137B,
	93700D3,49F08C9,49700DB,64B00D0,68A1680,EA500D7,6AA00CC,A6C147C,AAE00D4,92E00CA,
	D2E0379,C9600D1,D550781,D4A00D9,DA400CD,5D5057E,56A00D6,A6C00CB,55D047B,52D00D3,
	A9B0883,A9500DB,B4A00CF,B6A067F,AD500D7,55A00CD,ABA047C,A5A00D4,52B00CA,B27037A,
	69300D1,7330781,6AA00D9,AD500CE,4B5157E,4B600D6,A5700CB,54E047C,D1600D2,E960882,
	D5200DA,DAA00CF,6AA167F,56D00D7,4AE00CD,A9D047D,A2D00D4,D1500C9,F250279,D5200D1
	)

	;获取当年农历数据
	Pos:=(Year-1899)*8+1
	StringMid,Data,LunarData,%Pos%,7

	;判断公历日期
	Analyze(Data,MonthInfo,LeapInfo,Leap,Newyear)
	;计算到当天到当年农历新年的天数
	Sum=0
	If Leap			;有闰月
	{
		StringLeft,p1,MonthInfo,%Leap%
		StringTrimLeft,p2,MonthInfo,%Leap%
		thisMonthInfo:=p1 . LeapInfo . p2
		If (Leap!=Month and IsLeap=1)
		{
			errorinfo=该月不是闰月
			Return,errorinfo
		}
		If (Month<=Leap and IsLeap=0)
		{
			loop,% Month-1
			{
				StringMid,thisMonth,thisMonthInfo,%A_index%,1
				Sum:=Sum+29+thisMonth
			}
		}
		Else
		{
			loop,% Month
			{
				StringMid,thisMonth,thisMonthInfo,%A_index%,1
				Sum:=Sum+29+thisMonth
			}
		}
	}
	Else
	{
		loop,% Month-1
		{
			thisMonthInfo:=MonthInfo
			StringMid,thisMonth,thisMonthInfo,%A_index%,1
			Sum:=Sum+29+thisMonth
		}
	}
	Sum:=Sum+Day-1

	GDate=%Year%%NewYear%
	GDate+=%Sum%,days
	StringTrimRight,Gdate,Gdate,6
	Return,Gdate
}

;分析农历数据的函数 按上面所示规则分析
;4个回参分别对应四项
Analyze(Data,ByRef rtn1,ByRef rtn2,ByRef rtn3,ByRef rtn4){
	;rtn1
	StringLeft,Month,Data,3
	rtn1:=System("0x" . Month,"H","B")
	If StrLen(rtn1)<12
		rtn1:="0" . rtn1

	;rtn2
	StringMid,rtn2,Data,4,1

	;rtn3
	StringMid,leap,Data,5,1
	rtn3:=System("0x" . leap,"H","D")

	;rtn4
	StringRight,Newyear,Data,2
	rtn4:=System("0x" . newyear,"H","D")
	If StrLen(rtn4)=3
		rtn4:="0" . rtn4
}

;-------------------------数字转中文「大小写」--------------------------
n2c(n,op:=""){
	If (n="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		n:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (n="c")
		n:=Clipboard
	n:=StrSplit(n,"."), xs:=RTrim(n[2],"0")?RTrim(n[2],"0"):"0", n:=op="r"?n[1]:(LTrim(n[1],"0")?LTrim(n[1],"0"):"0")
	If !(n ~= "^\d*$")    ;当不是整数
		Return
	Else If StrLen(n)>21
		Return [{0:"{Value}",1:"",3:"数值超过最大值"}]
	Else If (op=""){
		arr:=[{0:"{Value}",1:n2c(n "." xs," ")},{0:"{Value}",1:n2c(n "." xs,"d")},{0:"{Value}",1:n2c(n "." xs,"j")}]
		Loop 3
			arr[A_index,3]:=arr[A_index,1]
		Return arr
	} 
	If (op~="[jd]")
		a:=StrSplit("零壹贰叁肆伍陆柒捌玖"), b:=StrSplit("拾佰仟万拾佰仟亿拾佰仟兆拾佰仟京拾佰仟垓"), jf:=["角","分","厘","毫"]
	Else
		a:=StrSplit("〇一二三四五六七八九"), b:=StrSplit("十百千万十百千亿十百千兆十百千京十百千垓")
	c:=d:=e:="", k:=StrLen(n)
	If (op="r"){
		Loop, Parse, n
			c.=a[A_LoopField+1]
	} Else {
		Loop, Parse, n
			c.=a[A_LoopField+1] . b[k-A_Index]
		if StrLen(c)>(max:=2*b.MaxIndex()+1)
			d:=SubStr(c,1,-max+2), c:=SubStr(c,-max+3)
		c:=RegExReplace(c,"(〇|零)(十|百|千|拾|佰|仟)","$1"), c:=RegExReplace(c,"(〇|零){4}(万|亿|兆|京)","$1")
		c:=RegExReplace(c,"(〇|零)+(万|亿|兆|京)","$2"), c:=RegExReplace(c,"(〇|零)+(?=(〇|零)|$)"), c:=c?c:a[1]
		c:=RegExReplace(c,"^" a[2] b[1],b[1])
	}
	If (op="j"){
		If (xs:=SubStr(xs,1,2)){
			e:="元"
			Loop, Parse, xs
				e.=a[A_LoopField+1] jf[A_index]
			e:=StrReplace(e, a[1] "角", a[1])
		} Else
			e:="元整"
	} Else If (xs!="0"){
		e:="点"
		Loop, Parse, xs
			e.=a[A_LoopField+1]
	}
	Return, d . c . e
}

Bin(x:=""){                ;dec-bin
	If (x="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		x:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (x="c")
		x:=Clipboard
	If !(x~="^\d+$")
		Return
	while x
	r:=1&x r,x>>=1
	Return r
}
Dec(x:=""){                ;bin-dec
	If (x="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		x:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (x="c")
		x:=Clipboard
	If !(x~="^[01]+$")
		Return
	b:=StrLen(x),r:=0
	loop,parse,x
	r|=A_LoopField<<--b
	Return r
}
Dec_Hex(x:=""){                ;dec-hex
	If (x="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		x:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (x="c")
		x:=Clipboard
	If !(x~="^\d+$")
		Return
	SetFormat, IntegerFast, hex
	he := x
	he += 0
	he .= ""
	SetFormat, IntegerFast, d
	Return,he
}
Hex_Dec(x:=""){
	If (x="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		x:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (x="c")
		x:=Clipboard
	If !(x~="i)^(0x)?[\da-f]+$")
		Return
	SetFormat, IntegerFast, d
	de := (x~="^0x"?x:"0x" x)
	de := de + 0
	Return,de
}

system(x,InPutType:="D", OutPutType:="H"){
	If InputType=B
	{
		If OutPutType=D
		r:=Dec(x)
		Else If OutPutType=H
		{
			x:=Dec(x)
			r:=Dec_Hex(x)
		}
	}
	Else If InputType=D
	{
		If OutPutType=B
		r:=Bin(x)
		Else If OutPutType=H
		r:=Dec_Hex(x)
	}
	Else If InputType=H
	{
		If OutPutType=B
		{
			x:=Hex_Dec(x)
			r:=Bin(x)
		}
		Else If OutPutType=D
		r:=Hex_Dec(x)
	}
	Return,r
}

;----------------------进制转换----------------------------------------------

;//二进制字符串转为十六进制字符串
bin2hex(x:=""){
	;//对字符串规范化：前面加1并添0使长度为4的整数倍
	If (x="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		x:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (x="c")
		x:=Clipboard
	If !(x~="^[01]+$")
		Return
	Loop, % Mod(4-Mod(StrLen(x),4),4)
		x:="0" x
	ss:=""
	Biao:={0:"0",1:"1",10:"2",11:"3",100:"4",101:"5"
		,110:"6",111:"7",1000:"8",1001:"9",1010:"A"
		,1011:"B",1100:"C",1101:"D",1110:"E",1111:"F"}
	Loop % StrLen(x)//4
		ss.=Biao[SubStr(x,(A_Index-1)*4+1,4)]
	Return, ss
}

;//十六进制字符串恢复为二进制字符串
hex2bin(x:="") {
	Biao:={0:"0000",1:"0001",2:"0010",3:"0011",4:"0100"
		,5:"0101",6:"0110",7:"0111",8:"1000",9:"1001",A:"1010"
		,B:"1011",C:"1100",D:"1101",E:"1110",F:"1111"}
	If (x="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		x:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (x="c")
		x:=Clipboard
	If !(x~="i)^(0x)?[\da-f]+$")
		Return
	ss:=""
	Loop, Parse, x
		ss.=Biao[A_LoopField]
	ss:=LTrim(ss,"0")
	Return, ss
}

;//10进制字符串转换为2、8、16进制字符串 16转10进制 十六进制字符串要加0x
ToBase(n,b){
	Return (n < b ? "" : ToBase(n//b,b)) . ((d:=Mod(n,b)) < 10 ? d : Chr(d+55))
}

;===================统计字符数=============
wStrLen(source:=""){
	If (source="s"){
		Clipsaved:=ClipboardAll
		Clipboard:=""
		Send, ^c
		ClipWait, 0.5
		source:=Clipboard, Clipboard:=Clipsaved, Clipsaved:=""
	} Else If (source="c"||source="")
		source:=Clipboard
	RegExReplace(source,".",,wLen)
	Return wLen
}
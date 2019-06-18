#include <FTPEx.au3>
#include "vars.au3"
#include <Date.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <WindowsConstants.au3>

;---------------------------------------------Коментарии
;Просто жми  F5
;дальше лучше ничего не трогать)
;---------------------------------------------ТУТ НАЧИНАЕТСЯ СКРИПТ

; Обьявление переменных. Менять ничего не нужно!
$law = 223		; ФЗ
$target = "con"	; цель
$yy = 2019		; год
$mm = 2			; месяц
$week = '-1'      ; неделя
$alll = 0       ; вид закачки

start()                     ; Вызывает окно с параметрами
ConsoleWrite($week & @CR)
Global $mask_44 = ""		; Доп. маска для 44 ФЗ НЕ ЗАПОЛНЯТЬ
Global $mask_223 = ""		; Доп. маска для 223 ФЗ НЕ ЗАПОЛНЯТЬ
Global $mask = ""			; Основная маска		  НЕ ЗАПОЛНЯТЬ
Global $succsess = 0		; Счётччик успешных закачек
Global $fail = 0
maask()						;Расчёт маски на основании исходных данных
if $week <> 0 and $week <> 'daily' then weekdate($yy,$week)    ;Расчёт маски для недели
;MsgBox(0,$mask & " " & $mask_44,"такая вот маска") ;Проверка маски(при необходимости закоментировать)

$log = FileOpen ( "dowload_log.txt",2 )		;Файл логов
$report = FileOpen ("download_report.txt",2)	;Файл отчёта
$ftp = _FTP_Open("goszakupki")		;Старт ФТП сессии (имя можно написать любое)

if $alll = 1 then all()
if $alll = 0 then go($law,$target)

fileWriteLine($log,"")
fileWriteLine($log,"XXXXX")

MsgBox(0,"gotovo",$succsess & " успешных загрузок и " & $fail & " неудачных") ;Окошко информирующее об окончании закачки

; Основная функция закачки архивов. Чтобы скачать один тип данных пользоваться ей
Func go($laww,$targett)
Global $law = $laww
Global $target = $targett

; Подключение к ФТП серверу
Global $dir_cc = ""
Global $dir_main = ""

; Если target не org
if $law == 223 and $target <> "org" then
   Global $fpt = _FTP_Connect($ftp,$ftp_par[0],$ftp_par[1],$ftp_par[1],1) ; Подключение к ФТП серверу 223 Фз
   Global $dir_main = $dir_223
EndIf

if $law == 44 and $target <> "org" then
   Global $fpt = _FTP_Connect($ftp,$ftp_par[0],$ftp_par[2],$ftp_par[2],1)  ; Подключение к ФТП серверу 44 Фз
   Global $dir_main = $dir_44
EndIf

If $target <> "org" then
    Global $is = _FTP_DirSetCurrent($fpt, $dir_main) ; Заходим в папку с регионами
    Global $dirs = _FTP_ListToArray($fpt, 1) ; Получаем список регионов
    clear()
 EndIf

; Если target = org
if $law == 223 and $target == "org" then
   Global $fpt = _FTP_Connect($ftp,$ftp_par[0],$ftp_par[1],$ftp_par[1],1) ; Подключение к ФТП серверу 223 Фз
   Global $dir_main = $dir_org_223
EndIf
if $law == 44 and $target == "org" then
   Global $fpt = _FTP_Connect($ftp,$ftp_par[0],$ftp_par[2],$ftp_par[2],1) ; Подключение к ФТП серверу 44 Фз
   Global $dir_main = $dir_org_44

 EndIf

 ;Выбираем то, что качаем
;---------------------------------------------Если ФЗ 223
IF $law == 223 then

; Если target = org
if $target == "org" and $week == 0 then
$succsess = 0		;Счётччик успешных закачек
$fail = 0			;Счётчик неучдачных закачек
FileWriteLine($log,"загрузка началась: " & _Now())
FileWriteLine($report,"загрузка началась: " & _Now())
$is = _FTP_DirSetCurrent($fpt, $dir_org_223)
Global $nsi = _FTP_ListToArray($fpt, 2)
for $ggg = 1 To $nsi[0]
if StringRegExp($nsi[$ggg], "all_" & $mask) = 1 Then
$home = home_dir($nsi[$ggg])
ConsoleWrite($home & @CR)
$is = _FTP_FileGet($fpt,_FTP_DirGetCurrent($fpt) &"/"& $nsi[$ggg],$home)
FileWriteLine($log,$home &" "& $is)
if $is = 1 then $succsess += 1
if $is = 0 then $fail += 1
EndIf
Next
FileWriteLine($log,"")
FileWriteLine($log, "скачано " & ($succsess+$fail)  & " файлов. Из них " & $succsess &" удачно и "& $fail & " неудачно")
FileWriteLine($log,"")
$repor ="Мы cкачали " & 'Organisation' & " для " & $law & " закона"
FileWriteLine($report,"=================================================================")
FileWriteLine($report,$repor)
FileWriteLine($report, "ИТОГО: "& $succsess &" успешных загрузок и "& $fail &" неудачных") ;Запись в отчёт конечных значений счётчиков успешных и нет закачек
FileWriteLine($report,"=================================================================")
EndIf

; Если target = org (daily)
if $target == "org" and $week == 'daily' then
FileWriteLine($log,"загрузка началась: " & _Now())
FileWriteLine($report,"загрузка началась: " & _Now())
$is = _FTP_DirSetCurrent($fpt, $dir_org_223 & "daily")
Global $nsi = _FTP_ListToArray($fpt, 2)
for $ggg = 1 To $nsi[0]
if StringRegExp($nsi[$ggg], "inc_" & $mask) = 1 Then
$home = home_dir($nsi[$ggg])
$is = _FTP_FileGet($fpt,_FTP_DirGetCurrent($fpt) &"/"& $nsi[$ggg],$home)
FileWriteLine($log," "& $is)
if $is = 1 then $succsess += 1
if $is = 0 then $fail += 1
EndIf
Next
FileWriteLine($log,"")
FileWriteLine($log, "скачано " & ($succsess+$fail)  & " файлов. Из них " & $succsess &" удачно и "& $fail & " неудачно")
FileWriteLine($log,"")
$repor ="Мы cкачали " & 'Organisation daily' & " для " & $law & " закона"
FileWriteLine($report,"=================================================================")
FileWriteLine($report,$repor)
FileWriteLine($report, "ИТОГО: "& $succsess &" успешных загрузок и "& $fail &" неудачных") ;Запись в отчёт конечных значений счётчиков успешных и нет закачек
FileWriteLine($report,"=================================================================")
EndIf

If $target <> "org" then
; Месячные данные
If $week == 0 then
if $law == 223 and $target == "con" then
      download($con_223)
EndIf
if $law == 223 and $target == "d_con" then
   For $vv = 0 to 2
   download($d_con_223[$vv])
   Next
EndIf
if $law == 223 and $target == "not" then
   For $vvvv = 0 to 6
   download($not_223[$vvvv])
   Next
EndIf
EndIf

; Недельные данные
IF $week <> 'daily' and $week <> 0 then
    if $law == 223 and $target == "con" then
   download($con_223 & $day)
EndIf
if $law == 223 and $target == "not" then
   For $vvvv = 0 to 6
   download($not_223[$vvvv] & $day)
   Next
EndIf
if $law == 223 and $target == "d_con" then
   For $vv = 0 to 2
   download($d_con_223[$vv] & $day)
   Next
EndIf
EndIf

; Ежедневные данные за месяц
IF $week == 'daily' then
if $law == 223 and $target="con" then
      download($con_223 & $day)
EndIf
if $law == 223 and $target == "d_con" then
   For $vv = 0 to 2
  ; ConsoleWrite("тест:"& $d_con_223[$vv] & $day & @CR)
   download($d_con_223[$vv] & $day)
   Next
EndIf
if $law == 223 and $target == "not" then
   For $vvvv = 0 to 6
   download($not_223[$vvvv] & $day)
   Next
EndIf
EndIf
EndIf
EndIf

;---------------------------------------------Если ФЗ 44

IF $law == 44 then

; Если target = org
if $target == "org" then
$succsess = 0		;Счётччик успешных закачек
$fail = 0			;Счётчик неучдачных закачек
FileWriteLine($log,"загрузка началась: " & _Now())
FileWriteLine($report,"загрузка началась: " & _Now())
$is = _FTP_DirSetCurrent($fpt, $dir_org_44)
Global $nsi = _FTP_ListToArray($fpt, 2)
for $ggg = 1 To $nsi[0]
if StringRegExp($nsi[$ggg], "all_" & $mask_44) == 1 Then
$home = home_dir($nsi[$ggg])
ConsoleWrite($home & @CR)
$is = _FTP_FileGet($fpt,_FTP_DirGetCurrent($fpt) &"/"& $nsi[$ggg],$home)
FileWriteLine($log,$home & " "& $is)
if $is = 1 then $succsess+=1
if $is = 0 then $fail+=1
EndIf
Next
FileWriteLine($log,"")
FileWriteLine($log, "скачано " & ($succsess+$fail)  & " файлов. Из них " & $succsess &" удачно и "& $fail & " неудачно")
FileWriteLine($log,"")
$repor ="Мы cкачали " & 'Organisation' & " для " & $law & " закона"
FileWriteLine($report,"=================================================================")
FileWriteLine($report,$repor)
FileWriteLine($report, "ИТОГО: "& $succsess &" успешных загрузок и "& $fail &" неудачных") ;Запись в отчёт конечных значений счётчиков успешных и нет закачек
FileWriteLine($report,"=================================================================")
EndIf

if $target <> "org" then
; Месячные данные
If $week == 0 then
ConsoleWrite('dae '&$law & @CR)
if $law == 44 and $target == "con" then
   download($con_44)
EndIf
if $law == 44 and $target == "not" then
   download($not_44)
EndIf
EndIf

;Недельные данные
IF $week <> 0 and $week <> 'daily' then
if $law == 44 and $target="con" then
   download($con_44 & $curr)
   download($con_44 & $prev)
EndIf
if $law == 44 and $target == "not" then
  download($not_44 & $curr)
  download($not_44 & $prev)
EndIf
EndIf

; Ежедневные данные за месяц
IF $week == 'daily' then
if $law = 44 and $target="con" then
   download($con_44 & $prev)
EndIf
if $law == 44 and $target == "not" then
  download($not_44 & $prev)
EndIf
EndIf
EndIf
EndIf
EndFunc


;Функция для скачки всего
Func all()
Global $week = 0
go(44,"con")
go(44,"not")
go(223,"con")
go(223,"d_con")
go(223,"not")
go(44,"org")
go(223,"org")
Global $week = 'daily'
go(44,"con")
go(44,"not")
go(223,"con")
go(223,"d_con")
go(223,"not")
go(223,"org")
;Global $options[13][3]=[[44,"con",-1],[44,"not",-1],[44,"con",0],[44,"not",0],[223,"con",-1],[223,"d_con",-1],[223,"not",-1],[223,"con",0],[223,"d_con",0],[223,"not",0],[44,"org",-1],[223,"org",-1],[223,"org",0]]   ; Все возможные варианты закачек
;for $gl = 0 To 12
;   go($options[$gl][0],$options[$gl][1], $options[$gl][2])
;Next
EndFunc

;Функция захода в нужные папки для скачиваний
Func download($dir_c)
$succsess = 0		;Счётччик успешных закачек
$fail = 0			;Счётчик неучдачных закачек

;MsgBox(0,"я готов","начинаем загрузку?")
FileWriteLine($log,"загрузка началась: " & _Now())
FileWriteLine($report,"загрузка началась: " & _Now())

for $ii=1 to $dirs[0]
ConsoleWrite($dir_main & $dirs[$ii] & $dir_c & @CR)
$is = _FTP_DirSetCurrent($fpt, $dir_main & $dirs[$ii] & $dir_c)
;ConsoleWrite($is & @CR)
Global $files = _FTP_ListToArray($fpt, 2)
ConsoleWrite('$NbFound = ' & $files[0] & '  -> Error code: ' & @error & @CRLF)
if($law = 44) then get($dirs[$ii], 0)
If($law = 223) then get($dirs[$ii], 0)
  	;MsgBox(0,"чекай","один регион есть")
 next
If $target = "con" then $repor=$con
If $target = "not" then $repor=$not & " " & $dir_c
If $target = "org" then $repor="Organisation"
If $target = "d_con" then $repor="dop."& $con & " " & $dir_c

$repor ="Мы cкачали " & $repor & " для " & $law & " закона"

FileWriteLine($report,"=================================================================")
FileWriteLine($report,$repor)
FileWriteLine($report, "ИТОГО: "& $succsess &" успешных загрузок и "& $fail &" неудачных") ;Запись в отчёт конечных значений счётчиков успешных и нет закачек
FileWriteLine($report,"=================================================================")
EndFunc

;Функция скачивания архивов
Func get($reg,$sl = 0)
;Локальные счётчики успешных и нет закачек
$fa = 0
$su = 0

$f=0
$i= $files[0]
if $i > 0 then
while $f=0
ConsoleWrite($files[$i]& @CR)
if(ch($files[$i],$f)) then
   	$is = _FTP_FileGet($fpt,_FTP_DirGetCurrent($fpt) &"/"& $files[$i],home_dir($files[$i]))

	FileWriteLine($log," "& $is)  ;Логирование успеха или неудачи закачки файлов

   if $law = 223 then Sleep($sl)

	if $is = 1 then $su+=1
	if $is = 0 then $fa+=1
else
	if $su>0 then $f=1
endif
$i-=1
if $i=0 then $f=1

wend
EndIf
$succsess += $su
$fail += $fa

;Логирование информации по региону(какой регион сколько удачных и нет закачек)
FileWriteLine($log,"")
FileWriteLine($log, "скачано " & ($su+$fa)  & " файлов. Из них " & $su &" удачно и "& $fa & " неудачно"" регион "& $reg)
FileWriteLine($log,"")
FileWriteLine($report, "скачано " & ($su+$fa)  & " файлов. Из них " & $su &" удачно и "& $fa & " неудачно"" регион "& $reg)

EndFunc

;Функция определения папки в которую качать
Func home_dir($q)

$d = $avraam
if ($target = "org") then
if ($law ==  223 and $week == 'daily') then $d = $org_home & "223" &"_daily"& "\"  & $yy & "\" & $mm & "\" & $q
if ($law ==   44 and $week == 0) then $d = $org_home &  "44" & "\"  & $yy & "\" & $mm & "\" & $q
if ($law ==  223 and $week == 0) then $d = $org_home & "223" & "\"  & $yy & "\" & $mm & "\" & $q
EndIf

if $week == 0 then
if ($target = "org") then return $d
if ($law ==  44 and $target == "con") then $d = $d & $con & "_" & $law & "\" & $yy & "\" & $mm & "\" & $q
if ($law == 44 and $target == "not") then $d = $d & $not & "_" & $law & "\" & $yy & "\" & $mm & "\" & $q
if ($law == 223 and $target == "con") then $d = $d & $con & "_" & $law & "\" & $yy & "\" & $mm & "\" & $q
if ($law == 223 and $target == "not") then $d = $d & $not & "_" & $law & "\" & $yy & "\" & $mm & "\" & $q
if ($law == 223 and $target == "d_con") then $d = $d & $d_con & "\" & $yy & "\" & $mm & "\" & $q
EndIf
if $week <> 0  and $week <> 'daily' Then
   if ($law ==  44 and $target == "con") then $d= $d & "weekdata" & "\" & $con & "_" & $law & "_" & "week" &  "\" & $yy & "\" & $week & "\" & $q
   if ($law == 223 and $target == "con") then $d= $d & "weekdata" & "\" & $con & "_" & $law & "_" & "week" &  "\" & $yy & "\" & $week & "\" & $q
EndIf
if $week == 'daily' then
if ($law == 44 and $target == "con") then $d= $d & "dailydata" & "\" & $con & "_" & $law & "_" & "daily" &  "\" & $yy & "\" & $mm & "\" & $q
if ($law == 223 and $target == "con") then $d= $d & "dailydata" & "\" & $con & "_" & $law & "_" & "daily" &  "\" & $yy & "\" & $mm & "\" & $q
if ($law == 44 and $target == "not") then $d= $d & "dailydata" & "\" & $not & "_" & $law & "_" & "daily" &  "\" & $yy & "\" & $mm & "\" & $q
if ($law == 223 and $target == "not") then $d= $d & "dailydata" & "\" & $not & "_" & $law & "_" & "daily" &  "\" & $yy & "\" & $mm & "\" & $q
if ($law == 223 and $target == "d_con") then $d= $d & "dailydata" & "\" & $d_con & "_" & "daily" &  "\" & $yy & "\" & $mm & "\" & $q
EndIf


ConsoleWrite($d & @CR)
FileWrite($log, $d) ;Логирование названия файла который пытается скачать скрипт. Статус закачки логируется выше
return $d
EndFunc

;Функция определения маски
Func maask()

if $mm > 9 then $mask = $yy & "" & $mm
if $mm < 10 then $mask = $yy & "0" & $mm

;Для месяцев с 31 днями
if $mm == 1 or $mm == 3 or $mm == 5 or $mm == 7 or $mm == 8 or $mm == 10 or $mm == 12 then
if $mm >  9 then $mask_223 = $yy & "" & $mm & "31"
if $mm < 10 then $mask_223 = $yy & "0" & $mm & "31"
EndIf

;Для месяцев с 30 днями
if $mm == 4 or $mm == 6 or $mm == 9 or $mm == 11 then
if $mm >  9 then $mask_223 = $yy & "" & $mm & "30"
if $mm < 10 then $mask_223 = $yy & "0" & $mm & "30"
EndIf

;Для Февраля
if $mm == 2 then
if _DateIsValid( $yy & "/" & 02 & "/" & 29 ) == 1 then
if $mm >  9 then $mask_223 = $yy & "" & $mm & "29"
if $mm < 10 then $mask_223 = $yy & "0" & $mm & "29"
EndIf
if _DateIsValid( $yy & "/" & 02 & "/" & 29 ) == 0 then
if $mm >  9 then $mask_223 = $yy & "" & $mm & "28"
if $mm < 10 then $mask_223 = $yy & "0" & $mm & "28"
EndIf
EndIf

if $mm + 1 = 13 then
	$mask_44 = ($yy+1) & "01"
	return 1;
	endif
if $mm >= 9 then
	$mask_44= $yy & "" & $mm+1
	return 1;
	endif
if $mm < 9 then
	$mask_44 = $yy & "0" & $mm+1
	return 1;
EndIf

EndFunc

;Удаляет из массива папок с регионами папки из словаря исключений
Func clear()
$g=0
for $i=1 to $dirs[0]
	$dirs[$i-$g]=$dirs[$i]
	for $j=0 to 3
		if StringRegExp($dirs_exceptions[$j], $dirs[$i])=1 then $g+=1 ;Убираем папки исключения из массива папок
	next
next
$dirs[0]-=$g
ConsoleWrite("dirs = "&$dirs[0] &@CR)
EndFunc

;условие для закачки архива
Func ch($ff,$d)
	if ($law == 223 and $week == 0 and ($d==0 and StringRegExp($ff, $mask)==1 and StringRegExp($ff, $mask_223)==1)) then return true
	if ($law == 44 and $week == 0 and ($d==0 and ((StringRegExp($ff, $mask)==1) and StringRegExp($ff, $mask_44)==1))) then return true
	if ($law == 44 and $week == 'daily' and ($d==0 and (StringRegExp($ff, $mask)==1))) then return true
	if ($law == 223 and $week == 'daily' and ($d==0 and (StringRegExp($ff, $mask)==1))) then return true
	if ($law == 44 and $week  <> 0 and $week <> 'daily' and $d==0) and (StringRegExp($ff, $weekdate[0] & "00_20")==1 Or StringRegExp($ff, $weekdate[1] & "00_20")==1 Or StringRegExp($ff, $weekdate[2] & "00_20")==1 Or StringRegExp($ff, $weekdate[3] & "00_20")==1 Or StringRegExp($ff, $weekdate[4] & "00_20")==1 Or StringRegExp($ff, $weekdate[5] & "00_20")==1 Or StringRegExp($ff, $weekdate[6] & "00_20")==1) then return true
	if ($law == 223 and $week  <> 0 and $week <> 'daily' and $d==0) and (StringRegExp($ff, $weekdate[0])==1 Or StringRegExp($ff, $weekdate[1])==1 Or StringRegExp($ff, $weekdate[2])==1 Or StringRegExp($ff, $weekdate[3])==1 Or StringRegExp($ff, $weekdate[4])==1 Or StringRegExp($ff, $weekdate[5])==1 Or StringRegExp($ff, $weekdate[6])==1) then return true

	return false

 EndFunc

;Расчёт масок для недели
Func weekdate($yy, $week)
Global $weekdate[7]
$wd = 0
for $i=1 to 31
   for $j=1 to 12
	  if _DateIsValid( $yy & "/" & $j & "/" & $i ) and (_WeekNumberISO($yy,$j,$i) == $week) then
	  $weekdate[$wd] = $yy & addo($j) & addo($i)
	  ConsoleWrite($yy & addo($j) & addo($i) & @CR)
	  $wd += 1
	  EndIf
   Next
Next
EndFunc

;Добовляет нули если число меньше 10
Func addo($q)
	if $q>9 then $q = $q
	if $q<10 then $q = "0" & $q
Return $q
EndFunc

Func start()

	Local $textEdit1, $textEdit2,$textEdit3, $textEdit4, $label ,$Button_1, $Button_2;, $Button_3;, $Button_4, $Button_5, $msg, $hGUI
$hGUI = GUICreate("GUI с кнопкой",250,375) ; Создаёт окно в центре экрана

Opt("GUICoordMode", 2)
$textEdit1 = GUICtrlCreateInput("Target",55,40,150,20)
$textEdit2 = GUICtrlCreateInput("Law",-150,20,150,20)
$textEdit3 = GUICtrlCreateInput("Year",-150,20,150,20)
$textEdit4 = GUICtrlCreateInput("Month",-150,20,150,20)
$textEdit5 = GUICtrlCreateInput("Week",-150,20,150,20)
;~ $label = GUICtrlCreateLabel("text",100,0)
 $Button_1 = GUICtrlCreateButton("Go", -130, 20,50,20)
 $Button_2 = GUICtrlCreateButton("All", 10, -20,50,20)
 ;$Button_3 = GUICtrlCreateButton("Week", 10, -20,50,20)
GuiSetIcon("icon.ico")
GUISetOnEvent($GUI_EVENT_CLOSE, 'GUIExit')
GuiCtrlCreatePic("logo.jpg",-145,10,180,90)
GUISetOnEvent($GUI_EVENT_CLOSE, 'GUIExit')
GUISetState(@SW_SHOW) ; показывает созданное окно
GUICtrlCreateLabel(" Please сhoose options below", -165, -340, 300, 15)
GUICtrlSetColor(-1,0x000000) ; цветинструкцийздесь-красный
; Запускается цикл опроса GUI до тех пор пока окно не будет закрыто
$z=1
While $z=1
    Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE
			$z = 0
            Exit
		 Case $Button_1
			Global $target = GUICtrlRead ( $textEdit1)
			Global $law = Number(GUICtrlRead ( $textEdit2))
			Global $yy = Number( GUICtrlRead ( $textEdit3))
			Global $mm = Number( GUICtrlRead ( $textEdit4))
			Global $week = GUICtrlRead ( $textEdit5)
			If $week == 'Week' or $week == '' then $week = 0
			If $week == 'Daily' or $week == 'DAILY'  then $week = 'daily'
			$z = 0
			GUISetState(@SW_HIDE)
		 Case $Button_2
			Global $yy = Number( GUICtrlRead ( $textEdit3))
			Global $mm = Number( GUICtrlRead ( $textEdit4))
			GUISetState(@SW_HIDE)
			Global $alll=1
			$z = 0
   EndSwitch
 WEnd

	EndFunc
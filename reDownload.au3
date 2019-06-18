#include <FTPEx.au3>
#include <vars.au3>
#include <Array.au3>
;Global $not_223[7] = ["/purchaseNotice/", "/purchaseNoticeAE/", "/purchaseNoticeAE94/", "/purchaseNoticeEP/", "/purchaseNoticeOA/", "/purchaseNoticeOK/", "/purchaseNoticeZK/"]

;---------------------------------------------Коментарии
;Просто жми  F5
;дальше лучше ничего не трогать)
;---------------------------------------------ТУТ НАЧИНАЕТСЯ СКРИПТ

; Подключаемся к ФТП
$ftp1 = _FTP_Open("goszakupki1")
$frr = _FTP_Connect($ftp1,$ftp_par[0],$ftp_par[1],$ftp_par[1],1)


$ftp2 = _FTP_Open("goszakupki2")
$frt = _FTP_Connect($ftp2,$ftp_par[0],$ftp_par[2],$ftp_par[2],1)


$log  = FileOpen ( "dowload_log.txt",0 )
$s = FileReadLine($log)
$law = 0
$target = 0
Global $all = 0
Global $success = 0
Global $fail = 0

While not($s = "XXXXX")

; Определяем $target и $week
If StringRegExp($s,'загрузка началась:') then
$s = FileReadLine($log)
IF  $s <> '' then
$r = StringSplit($s,"\")
$d = StringSplit($r[$r[0]],"_")
If StringRegExp($r[4],"dailydata") then
$week = 'daily'
If StringRegExp($r[5],"44_") Then $law=44
If StringRegExp($r[5],"223_") then $law=223
EndIf
If StringRegExp($r[4],"weekdata") then
$week =  Number($r[4])
If StringRegExp($r[5],"44_") Then $law=44
If StringRegExp($r[5],"223_") then $law=223
EndIf
If  not StringRegExp($r[4],"dailydata") and not StringRegExp($r[4],"weekdata") then
$week = 0
If StringRegExp($r[4],"_44") Then $law=44
If StringRegExp($r[4],"_223") then $law=223
EndIf

; Определяем цель
; Для notification
for $j=0 to 6
  if StringRegExp(StringRegExpReplace($not_223[$j],'/', ''), $d[1]) == 1 then $target = 'not'
  next
; Для contract
If StringRegExp('contract',$d[1]) then $target = 'con'

; Для d_con
for $j=0 to 2
		if StringRegExp(StringRegExpReplace($d_con_223[$j],'/', ''), $d[1]) == 1 then $target = 'd_con'
next

; Для org
If StringRegExp('nsiOrganization',$d[1]) then $target = 'org'
EndIF
EndIf

; Выбираем незакаченные файлы и качаем их
if StringRegExp($s,"zip 0") then
$all += 1
$r = StringSplit($s,"\")
$d = StringSplit($r[$r[0]],"_")
$way = trueway($r[$r[0]])


; Если месячные данные
If $week == 0 then

; 44 ФЗ
If $law == 44 then
if $target == 'con' then $is = _FTP_FileGet($frt,$dir_44 & $way,StringRegExpReplace($s ," 0","" ))
if $target == 'not' then $is = _FTP_FileGet($frt,$dir_44 & $way,StringRegExpReplace($s ," 0","" ))
if $target == 'org' then $is = _FTP_FileGet($frt,$dir_org_44 & $way,StringRegExpReplace($s ," 0","" ))
EndIf

; 223 ФЗ
If $law == 223 then
if $target == 'con' then $is = _FTP_FileGet($frr,$dir_223 & $way,StringRegExpReplace($s ," 0","" ))
if $target == 'not' then $is = _FTP_FileGet($frr,$dir_223 & $way,StringRegExpReplace($s ," 0","" ))
if $target == 'd_con' then $is = _FTP_FileGet($frr,$dir_223 & $way,StringRegExpReplace($s ," 0","" ))
if $target == 'org' then $is = _FTP_FileGet($frr,$dir_org_223 & $way,StringRegExpReplace($s ," 0","" ))
EndIf
EndIF

; Если ежедневные данные
If $week == 'daily' then
; 44 ФЗ
If $law == 44 then
if $target == 'con' then $is = _FTP_FileGet($frt,$dir_44 & $way ,StringRegExpReplace($s ," 0","" ))
if $target == 'not' then $is = _FTP_FileGet($frt,$dir_44 & $way ,StringRegExpReplace($s ," 0","" ))
EndIF
; 223 ФЗ
If $law == 223 then
if $target == 'con' then $is = _FTP_FileGet($frr,$dir_223 & $way,StringRegExpReplace($s ," 0","" ))
if $target == 'not' then $is = _FTP_FileGet($frr,$dir_223 & $way,StringRegExpReplace($s ," 0","" ))
if $target == 'd_con' then $is = _FTP_FileGet($frr,$dir_223  & $way,StringRegExpReplace($s ," 0","" ))
if $target == 'org' then $is = _FTP_FileGet($frr,$dir_org_223 & $way,StringRegExpReplace($s ," 0","" ))
EndIF
EndIF

; Если недельные данные
IF $week <> 0 and $week <> 'daily' then

; 44 ФЗ
If $law == 44 then
if $target == 'con' then
$is = _FTP_FileGet($frt,$dir_44 & $way,StringRegExpReplace($s ," 0","" ))
if is == 0 then is = _FTP_FileGet($frt,$dir_44 & StringRegExpReplace($way ,"prevMonth","currMonth" )$way,StringRegExpReplace($s ," 0","" ))
EndIF
if $target == 'not' then
$is = _FTP_FileGet($frt,$dir_44 & $way,StringRegExpReplace($s ," 0","" ))
if is == 0 then is = _FTP_FileGet($frt,$dir_44 & StringRegExpReplace($way ,"prevMonth","currMonth" )$way,StringRegExpReplace($s ," 0","" ))
EndIf
if $target == 'org' then $is = _FTP_FileGet($frt,$dir_org_44 & $way,StringRegExpReplace($s ," 0","" ))
EndIf

; 223 ФЗ
If $law == 223 then
if $target == 'con' then $is = _FTP_FileGet($frr,$dir_223 & $way, StringRegExpReplace($s ," 0","" ))
if $target == 'not' then $is = _FTP_FileGet($frr,$dir_223 & $way, StringRegExpReplace($s ," 0","" ))
if $target == 'd_con' then $is = _FTP_FileGet($frr,$dir_223 & $way, StringRegExpReplace($s ," 0","" ))
if $target == 'org' then $is = _FTP_FileGet($frr,$dir_org_223 & $way, StringRegExpReplace($s ," 0","" ))
EndIf
EndIf
ConsoleWrite($S & @CR)
;ConsoleWrite($r[$r[0]] & @CR)
;ConsoleWrite($way & @CR)
;ConsoleWrite($law & @CR)
;ConsoleWrite($target & @CR)
;ConsoleWrite($week & @CR)
; ConsoleWrite($r[$r[0]] & @CR)
$result = $is
ConsoleWrite($result & @CR)
if $result == 0 then $fail += 1
if $result == 1 then $success += 1
EndIf
$s = FileReadLine($log)
;ConsoleWrite($s & @CR)
WEnd

MsgBox(0,"Обработка недокачанных архивов",$all & ' - всего недокачанных ' & $success & " - успешных загрузок и " & $fail & " - неудачных") ;Окошко информирующее об окончании закачки



Func trueway($qwe)
Local $tar = StringRegExp($qwe, "([0-9a-zA-Z]*)_", 1)
Local $name = StringRegExp($qwe, "_([a-zA-Z_\-]*)_", 1)

; Месячные данные
If $week == 0 then

; ФЗ 44
If $law == 44 then
   if $target <> 'org' then $way = $name[0] & "/"  & $tar[0] & "s/" & StringRegExpReplace($qwe," 0","")
   if $target == 'org' then $way = StringRegExpReplace($r[$r[0]]," 0","")
EndIf

; ФЗ 223
If $law == 223 then
   if $target <> 'org' then $way = $name[0] & "/"  & $tar[0] & "/" & StringRegExpReplace($qwe," 0","")
   if $target == 'org' then $way = StringRegExpReplace($r[$r[0]]," 0","")
EndIF
EndIF

; Ежедневные данные
If $week == 'daily' then

; ФЗ 44
If $law == 44 then
   if $target <> 'org' then $way = $name[0] & "/"  & $tar[0] & "s/" & $prev & '/' & StringRegExpReplace($r[$r[0]]," 0","")
EndIF

; ФЗ 223
If $law == 223 then
      if $target <> 'org' then $way = $name[0] & "/"  & $tar[0] & "/daily/" & StringRegExpReplace($r[$r[0]]," 0","")
	  if $target == 'org' then $way = 'daily/' & StringRegExpReplace($r[$r[0]]," 0","")
EndIf
EndIf

; Недельные данные
IF $week <> 0 and $week <> 'daily' then

; ФЗ 44
If $law == 44 then
   if $target <> 'org' then $way = $name[0] & "/"  & $tar[0] & "s/" & $prev & '/' & StringRegExpReplace($r[$r[0]]," 0","")
EndIF

; ФЗ 223
If $law == 223 then
   if $target <> 'org' then $way = $name[0] & "/"  & $tar[0] & "/daily/"  & StringRegExpReplace($r[$r[0]]," 0","")
EndIF
EndIf
Return $way
EndFunc
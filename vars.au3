#include <Array.au3>

$dir_44 = "/fcs_regions/"		;папка с регионами на 44
$dir_org_44 = "/fcs_nsi/nsiOrganization/"
$dir_org_223 = "/out/nsi/nsiOrganization/"
$dir_223 = "/out/published/"	;папка с регионами на 223
$day = "daily"					;
$not = "notifications"
$con = "contracts"
$current = "cont"
$d_con = "contracts_223_dop"
$org = "organization"
$avraam ="D:\Share\fcs_regions\" ; основная папка закачки(менять её здесь)

Global $dirs_exceptions[4] = ["_logs/","control99docs/","archive/","PG-PZ/"]
Global $con_44 = "/contracts/"
Global $con_223 = "/contract/"
Global $d_con_223[3] = ["/purchaseContract/","/contractCompleting/","/purchaseContractAccount/"]
Global $not_44 = "/notifications/"
Global $not_223[7] = ["/purchaseNotice/", "/purchaseNoticeAE/", "/purchaseNoticeAE94/", "/purchaseNoticeEP/", "/purchaseNoticeOA/", "/purchaseNoticeOK/", "/purchaseNoticeZK/"]
Global $org_44 = "/fcs_nsi/nsiOrganization/"
Global $org_home = "D:\Share\fcs_regions\organization\"
Global $curr = "currMonth"
Global $prev = "prevMonth"

;"ftp.zakupki.gov.ru","fz223free","free"
Global $ftp_par[3] = ["ftp.zakupki.gov.ru","fz223free","free"]

;перенос строки : &@CR
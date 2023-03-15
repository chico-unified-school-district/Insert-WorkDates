$global:params = @{
 SQLServer   = $empServer
 SQLDatabase = $EmpDB
 SQLCred     = $escapeCreds
 SQLTable    = 'OrgCalendar'
}
$params
Get-ChildItem -Filter *.ps1 -Recurse | Unblock-File
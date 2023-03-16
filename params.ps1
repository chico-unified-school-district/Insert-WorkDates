$global:params = @{
 SQLServer   = $laserFicheServer
 SQLDatabase = 'CUSD-LF-Lookups'
 SQLTable    = 'cusd_CL12M_workdays'
 SQLCred     = $jenkinsLF
 Start       = '01/01/2022'
 End         = '12/31/2030'
}
$params
Get-ChildItem -Filter *.ps1 -Recurse | Unblock-File
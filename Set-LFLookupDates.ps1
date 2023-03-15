[cmdletbinding()]
param (
 # [Parameter(Mandatory = $True)]
 # [Alias('DCs')]
 # [string[]]$DomainControllers,
 # [Parameter(Mandatory = $True)]
 # [System.Management.Automation.PSCredential]$Credential,
 [Parameter(Mandatory = $True)]
 [string]$SqlServer,
 [Parameter(Mandatory = $True)]
 [string]$SqlDatabase,
 [Parameter(Mandatory = $True)]
 [string]$SqlTable,
 [Parameter(Mandatory = $True)]
 [System.Management.Automation.PSCredential]$SQLCredential,
 [Alias('wi')]
 [switch]$WhatIf
)


function Get-OrgCalendarData ($sqlParams, $table) {
 begin {
  function Get-YearStart {
   $targDate = Get-Date 'Jul 1'
   $curDate = Get-Date
   # After July (7) the current year is the start of the current school year
   if ($curDate.Month -gt 7) { Get-Date $targDate -f yyyy-MM-dd }
   else { Get-Date ((Get-Date $targDate).Addyears(-1)) -f yyyy-MM-dd }
  }
 }
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  $contractDate = Get-YearStart
  $sql = "SELECT CalendarDays FROM {0} WHERE CalendarId = 'CL12M' AND DateContractFrom = '{1}'" -f $table, $contractDate
  Invoke-SqlCmd @sqlParams -Query $sql
 }
}



begin {

}
process {
 Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
 $days = $_.CalendarDays.ToCharArray()
 switch ($days) {
  U { 'Unpain' }
  H { 'Holiday' }
  . { 'Paid' }
  default { 'No Idea' }
 }
}
}


# ==================== Main =====================
# Imported Functions
Import-Module 'SQLServer'
$sqlParams = @{
 Server     = $SqlServer
 Database   = $SqlDatabase
 Credential = $SQLCredential
}

Get-OrgCalendarData $sqlParams $SQLTable | Get-Workays
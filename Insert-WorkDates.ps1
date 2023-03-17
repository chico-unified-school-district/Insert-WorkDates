# https://en.wikipedia.org/wiki/Federal_holidays_in_the_United_States#:~:text=New%20Year's%20Day%2C%20Juneteenth%2C%20Independence,the%20day%20of%20the%20week.
[cmdletbinding()]
param (
 [Parameter(Mandatory = $True)]
 [string]$SqlServer,
 [Parameter(Mandatory = $True)]
 [string]$SqlDatabase,
 [Parameter(Mandatory = $True)]
 [string]$SqlTable,
 [Parameter(Mandatory = $True)]
 [System.Management.Automation.PSCredential]$SQLCredential,
 [string]$StartDate,
 [string]$EndDate,
 [Alias('wi')]
 [switch]$WhatIf
)
function Get-ExistingEntry ($sqlParams, $table) {
 begin {
  $baseSql = "SELECT * FROM {0} WHERE date = '{1}' AND dayOfWeek = '{2}'"
 }
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  $sql = $baseSql -f $table, $_.ToShortDateString(), $_.DayOfWeek
  $entry = Invoke-Sqlcmd @sqlParams -Query $sql
  if ($entry) { return }
  $_
 }
}
function Get-DateRange ($startDate, $endDate) {
 begin {
  # $start = Get-Date 'dec 31 2022'
  # $end = get-date 'jan 1 2030'
  $start = Get-Date $startDate
  $end = Get-Date $endDate
  $days = ($end - $start - 1).Days
 }
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  for ($i = 1; $days -ge $i; $i++) {
   (Get-Date $start).AddDays($i)
  }
 }
}
function Format-SQLUpdate ($table) {
 begin {
  $baseSql = "INSERT INTO {0} (date,dayOfWeek) VALUES ('{1}','{2}');"
 }
 process {
  $sql = $baseSql -f $table, $_.ToShortDateString(), $_.DayOfWeek
  $sql
 }
}
function Select-WeekDays {
 process {
  # Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  if ($_.DayOfWeek -match "^Sat|Sun") {
   return
  }
  $_
 }
}

function Select-WorkDays {
 begin {
  $holidays = Get-Content .\json\federal_holidays.json -Raw | ConvertFrom-Json
 }
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  $isHol = foreach ($item in $holidays.holidays) {
   $excludeDays = $item.range.min..$item.range.max
   if (($_.Month -eq $item.monthNum -and $excludeDays -contains $_.day -and $_.DayOfWeek -eq $item.dayOfWeek) -or
   ( $_.Month -eq $item.monthNum -and $excludeDays -contains $_.day -and -not($item.dayOfWeek))) {
    $itemDesc = $item.name + ': ' + $item.Month + ' ' + $item.dayofWeek + ' ' + $item.range.min + '-' + $item.range.max
    [PSCustomObject]@{
     descr = $itemDesc
    }
   }
  }
  if ($isHol) {
   $msg = $MyInvocation.MyCommand.Name, $isHol.descr, $_.DateTime
   Write-Host ('{0},Holiday Detected: [{1}],[{2}]' -f $msg) -Fore Green
   return
  }
  $msg = $MyInvocation.MyCommand.Name, $_.DateTime
  Write-Host ('{0},Work Day Detected: [{1}]' -f $msg) -Fore Yellow
  $_
 }
}
function Update-Table ($sqlParams) {
 begin {
 }
 process {
  Write-Host ('{0},[{1}]' -f $MyInvocation.MyCommand.Name, $_)
  Write-Debug 'Just a moment...'
  if (-not$WhatIf) { Invoke-SqlCmd @sqlParams -Query $_ }
 }
}

# ==================== Main =====================
# Imported Functions
. .\lib\Clear-SessionData.ps1
. .\lib\Load-Module.ps1
. .\lib\Show-TestRun.ps1

Show-TestRun
Clear-SessionData

'SQLServer' | Load-Module

$sqlParams = @{
 Server     = $SqlServer
 Database   = $SqlDatabase
 Credential = $SQLCredential
}

Get-DateRange $StartDate $EndDate | Select-WeekDays | Select-WorkDays |
Get-ExistingEntry $sqlParams $SqlTable |
Format-SQLUpdate $SqlTable | Update-Table $sqlParams

Clear-SessionData
Show-TestRun
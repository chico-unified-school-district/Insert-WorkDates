# https://en.wikipedia.org/wiki/Federal_holidays_in_the_United_States#:~:text=New%20Year's%20Day%2C%20Juneteenth%2C%20Independence,the%20day%20of%20the%20week.
function Get-DateRange {
 begin {
  $start = Get-Date 'dec 31 2021'
  $end = get-date 'jan 31 2023'
  $days = ($end - $start - 1).Days
 }
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  for ($i = 1; $days -ge $i; $i++) {
   (Get-Date $start).AddDays($i)
  }
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

function Select-NonHolidays {
 begin {
  $holidays = Get-Content .\json\federal_holidays.json -Raw | ConvertFrom-Json
 }
 process {
  Write-Host ($_.DateTime.ToString())  -Fore Green
  # Write-Host ($_ | format-list | Out-String)  -Fore Green
  $i = 1
  foreach ($item in $holidays.holidays) {
   $i
   $i++
   $isHoliday = $null
   $itemDesc = $item.name + ': ' + $item.Month + ' ' + $item.dayofWeek + ' ' + $item.range.min + '-' + $item.range.max

   $excludeDays = $item.range.min..$item.range.max

   if (($_.ToString("MMMM") -match $item.month) -and
   ($excludeDays -contains $_.day)) {
    $isHoliday = $true
    if ($item.dayOfWeek) {
     if ($_.DayOfWeek.ToString() -eq $item.dayofWeek) {
      $isHoliday = $true
     }
     else {
      $isHoliday = $false
     }
    }

    if ($isHoliday) {
     $msg = $MyInvocation.MyCommand.Name, $itemDesc, $_.DateTime
     Write-Host ('{0},Holiday Detected: [{1}],[{2}]' -f $msg) -Fore Yellow
    }
   }

   if ($isHoliday) { pause; return }
   $msg = $MyInvocation.MyCommand.Name, $itemDesc, $_.DateTime
   Write-Host ('{0},Non-Holiday Detected: [{1}],[{2}]' -f $msg) -Fore Blue
   $_
   pause
  }
 }
}

# ================ Main ===============
# Get-DateRange | Select-NonHolidays
Get-DateRange | Select-WeekDays | Select-NonHolidays
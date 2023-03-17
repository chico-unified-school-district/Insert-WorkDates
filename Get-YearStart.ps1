function Get-YearStart {
 $targDate = Get-Date 'Jul 1'
 $curDate = Get-Date
 # After July (7) the current year is the start of the current school year
 if ($curDate.Month -gt 7) { Get-Date $targDate -f yyyy-MM-dd }
 else { Get-Date ((Get-Date $targDate).Addyears(-1)) -f yyyy-MM-dd }
}
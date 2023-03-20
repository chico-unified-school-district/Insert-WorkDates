# Insert-WorkDates

Insert valid work dates in SQL database for 12 month employees for all days between a StartDate and EndDate.
 - Excludes weekends using basic SAT|SUN function
 - Federal Holidays using a json file that defines each holidays rules and a function to parse each weekday.
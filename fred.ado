cap program drop fred
program define fred
syntax anything, key(string) [return]
local id = lower("`anything'")
tempfile temp
splitpath `temp'
local tempdirectory `r(directory)'
tempfile temp1

!curl -o "`temp1'.txt.zip" "http://api.stlouisfed.org/fred/series/observations?&file_type=txt&series_id=`id'&api_key=`key'"
!cd `tempdirectory' && unar -D "`temp1'.txt.zip" 
insheet using "`tempdirectory'`id'_1.txt", clear
gen date = date(observation_date,"YMD")
gen datem = mofd(date)
format datem %tm
order datem `id'
sort datem `id'
keep datem `id'

if "`return'"~=""{
	tempvar new 
	gen `new'= `id'[_n+1]/`id'-1
	drop `id'
	rename `new' `id'
}
end

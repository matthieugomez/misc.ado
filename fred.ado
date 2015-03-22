cap program drop fred
program define fred
	syntax anything, key(string) [return Time(string)]
	local id = lower("`anything'")
	tempfile temp
	splitpath `temp'
	local tempdirectory `r(directory)'
	tempfile temp1
	!curl -o "`temp1'.txt.zip" "http://api.stlouisfed.org/fred/series/observations?&file_type=txt&series_id=`id'&api_key=`key'"
	!cd `tempdirectory' && unar -D "`temp1'.txt.zip" 
	insheet using "`tempdirectory'`id'_1.txt", clear
	gen date = date(observation_date,"YMD")
	if "`time'"== "d" | "`time'" == ""{
		local date date
		format `date' %td
	}
	if "`time'"== "m" | "`time'" == ""{
		local date datem
		gen `date' = mofd(date)
		format datem %tm
		
	}
	else if "`time'" == "q"{
		local date dateq
		gen `date' = qofd(date)
		format `date' %tq
	}
	else if "`time'" == "y"{
		local date year
		gen `date' = year(date)
	}
	else{
		display as error "invalid time period"
		exit 4
	}
	order `date' `id'
	sort `date' `id'
	keep `date' `id'
	tsset `date' 
	if "`return'"~=""{
		tempvar new 
		gen `new'= F.`id'/`id'-1
		drop `id'
		rename `new' `id'
	}
end

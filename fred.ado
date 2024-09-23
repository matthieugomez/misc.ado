cap program drop fred
program define fred
	syntax anything, key(string) [return]
	local id = lower("`anything'")
	tempfile temp
	splitpath `temp'
	local tempdirectory `r(directory)'
	local tempfilename `r(filename)'`r(filetype)'
	copy "https://api.stlouisfed.org/fred/series/observations?&file_type=txt&series_id=`id'&api_key=`key'" "`temp'.zip", replace
	di "`temp'"
	di "`tempdirectory'"
	di "`tempfilename'"


	!cd `tempdirectory' && unar -D `tempfilename'.zip
	! sleep 1s
	insheet using "`tempdirectory'`id'_1.txt", clear
	gen date = date(observation_date,"YMD")
	format date %td
	gen datem = mofd(date)
	format datem %tm
	cap tsset datem
	if _rc{
		local date date
	}
	else{
		gen dateq = qofd(date)
		format dateq %tq
		cap tsset dateq
		if _rc{
			local date datem
		}
		else{
			gen year = year(date)
			cap tsset year
			if _rc{
				local date dateq
			}
			else{
				local date year
			}
		}
	}
	order `date' `id'
	keep `date' `id'
	if "`return'"~=""{
		tempvar new 
		gen `new'= F.`id'/`id'-1
		drop `id'
		rename `new' `id'
	}
end

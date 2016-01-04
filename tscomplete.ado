program define tscomplete
	syntax varlist(max=1) [if] [in], gen(string)
	confirm new variable `gen'
	qui tsset 
	local id "`r(panelvar)'"
	local time "`r(timevar)'" 
	tempvar touse
	mark `touse' `if' `in'


	tempvar min
	gen `min' = `varlist'
	bys `id' (`time'): replace `min' = `min'[_n-1] if missing(`min')

	tempvar max mtime
	gen `mtime' = - `time'
	gen `max' = `varlist'
	bys `id' (`mtime'): replace `max' = `max'[_n-1] if missing(`max')

	gen `gen' = `varlist'
	replace `gen' = `min' if `min' == `max'
end


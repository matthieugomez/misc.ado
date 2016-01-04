program define tsfillall
	syntax varlist , [full]
	/* the first n-1 are id, the last is time */
	local n : word count `varlist'
	tokenize `varlist'
	forval i = 1/`=`n'-1'{
		local id `id' `1'
		macro shift
	}
	local time `1'

	/* tsfill */
	tempvar gid sample
	egen `gid' = group(`id'), missing
	tempvar sample
	gen `sample' == 0
	qui tsset `gid' `time', `full'
	qui replace `sample' = 1 if missing(`sample')
	tsfill, `full'
	sort `gid' `sample'
	foreach v of varlist `id'{
		qui by `gid': replace `v' = `v'[1]
	}
	sort `id' `time'
end


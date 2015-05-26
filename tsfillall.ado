program define tsfillall
	syntax [varlist , full]
	local n : word count `varlist'
	tokenize `varlist'
	forval i = 1/`=`n'-1'{
		local id `id' `1'
		macro shift
	}
	local time `1'
	tempvar gid gtime
	egen `gid' = group(`id'), missing
	qui tsset `gid' `time'
	tsfill, `full'
	sort `gid' `id'
	foreach v of varlist `id'{
		qui by `gid': replace `v'= `v'[1] if missing(`v')
	}
	sort `id' `time'
end


program define fillall
syntax [, id(varlist) Time(varlist) full]
	tempvar gid gtime
	egen `gid' = group(`id')
	egen `gtime' = group(`time')
	tsset `gid' `gtime'
	tsfill, `full'
	tsset, clear
	sort `gid' `id'
	foreach v of varlist `id'{
		by `gid': replace `v'= `v'[1] if missing(`v')
	}
	sort `gtime' `time'
	foreach v of varlist `time'{
		by `gtime': replace `v'= `v'[1] if missing(`v')
	}
	sort `gid' `gtime'
end

/* test 
discard
clear all
set obs 10
gen a = _n
gen b = _n
gen time = _n
fillall , id(a b) time(time) full
*/

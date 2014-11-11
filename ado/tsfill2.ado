program define tsfill2
syntax varlist [, full othertime(varlist)]
	local id `varlist'
	local length: list sizeof id
	tokenize `id'
	local time ``length''
	local id: list id - time
	tempvar gid
	egen `gid' = group(`id')
	tsset `gid' `time'
	tsfill, `full'
	tsset, clear
	sort `gid' `id'
	foreach v of varlist `id'{
		by `gid': replace `v'= `v'[1]
	}
	if "`othertime'"!=""{
		sort `time' `othertime'
		foreach v of varlist `othertime'{
			by `time': replace `v'= `v'[1]
		}
	}
	sort `gid' `time'
end

/* test 
discard
clear all
set obs 10
gen a = _n
gen b = _n
gen time = _n
fillgaps a b time, full
*/

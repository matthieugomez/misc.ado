program define collapsesum
	syntax varlist [if] [in] [aweight fweight iweight pweight/] [, BY(varlist) FAST]

	foreach v of varlist `0'{
		tempvar `v'_count
		gen `v'_count = !missing(`v')
		local vlist `vlist' ``v'_count'
	}
	collapse (sum) `0'  `vlist' `exp', `by' `fast'
	foreach v of varlist `0'{
		replace `v' = . if ``v'_count' == 0
	}

end


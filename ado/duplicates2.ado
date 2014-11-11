program define duplicates2
syntax anything [if] [in], [force order(str) gen(str)]
if regexm(`"`anything'"',"^drop (.*)$"){
	local varlist1 `=regexs(1)'
	if "`order'"==""{
		display "drop by what?"
	}
	else{
		tempvar t
		qui duplicates tag `varlist1' `if' `in', gen(`t')
		tempvar temp
		qui egen `temp'=max(`order'), by(`varlist1')
		qui count if `t'>0  & !missing(`t') & missing(`order') & !missing(`temp')
		dis as text "Duplicates deleted because missing = " in ye  %10.0fc r(N) 
		qui drop if `t'>0 & !missing(`t') & missing(`order') & !missing(`temp')

		qui count if `t'>0  & !missing(`t') & `order' < `temp'
		dis as text "Duplicates deleted because smaller = " in ye  %10.0fc r(N) 
		qui drop if `t'>0  & !missing(`t') & `order' < `temp'
		
		tempvar t1
		qui duplicates tag `varlist1' `if' `in', gen(`t1')
		qui count if `t1'>0  & !missing(`t1')
		dis as text "Duplicates deleted randomly = " in ye  %10.0fc r(N) 
		qui duplicates drop `varlist1' `if' `in', force

	}
}
else if regexm("`anything'","^prune (.*)$"){
	local varlist1 `=regexs(1)'
	if "`order'"==""{
		display "prune by what?"
	}
	else{
		tempvar t
		qui duplicates tag `varlist1' `if' `in', gen(`t')
		tempvar temp
		qui egen `temp'=max(`order'), by(`varlist1')
		drop if `t'>0 & missing(`order') & !missing(`temp')
		drop if `t'>0 & `order' < `temp'
	}
}

else if regexm("`anything'","^tag (.*)$"){
	local varlist1 `=regexs(1)'
	duplicates tag `varlist1' `if' `in', gen(`gen')
	order `gen' `varlist1'
	sort `gen' `varlist1'
	tab `gen'
}

else{
	display "ok"
}
end


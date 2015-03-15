program define dropduplicates
syntax varlist [if] [in], [order(varname) gen(str)]


tempvar touse  t maxorder
mark `touse' `if' `in'

bys `touse' `varlist': gen `t' = _N-1 if `touse'==1

qui egen `maxorder'=max(`order'), by(`varlist')
qui count if `t'>0  & !missing(`t') & missing(`order') & !missing(`maxorder')
qui drop if `t'>0 & !missing(`t') & missing(`order') & !missing(`maxorder')
dis as text "Duplicates deleted because missing = " in ye  %10.0fc r(N) 

qui count if `t'>0  & !missing(`t') & `order' < `maxorder'
qui drop if `t'>0  & !missing(`t') & `order' < `maxorder'
dis as text "Duplicates deleted because smaller = " in ye  %10.0fc r(N) 


qui count if `t'>0  & !missing(`t') & float(`order') == float(`maxorder')
dis as text "Duplicates deleted randomly = " in ye  %10.0fc r(N) 
bys `touse' `varlist': drop if _n>1 & `touse'== 1
end

/* test 
discard
clear all
set obs 10
gen a = 1
gen b = floor(_n/5)
gen time = _n
replace time = . if time==4
dropduplicates a b, order(time)
*/
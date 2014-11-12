program define tagduplicates
syntax varlist[if] [in], [GENerate(str)]

tempvar touse 
mark `touse' `if' `in'
bys `touse' `varlist': gen `gen' = _N-1 if `touse'==1
tab `gen'
order `gen' `varlist1'
sort `gen' `varlist1'
end



/* test 
discard
clear all
set obs 10
gen a = 1
gen b = floor(_n/5)
tagduplicates a b, gen(t)
*/
/* separates in 20 bins of equal diameters */
* n is number of bins
* p is min and max percentile
program _gbin, byable(onecall) sortpreserve
version 8.2
gettoken type 0 : 0
gettoken h    0 : 0 
gettoken eqs  0 : 0

syntax varname(numeric) [if] [in] , n(string) p(string) [ ///
   Weights(string)]
marksample touse
if "`weights'" ~=""{
	local wopt [w=`weights']
}
_pctile `varlist' `wopt' if `touse', p(`p')
local min = r(r1)
local max = r(r2)
local at ""
foreach i of numlist 1/`=`n'-1'{
	local at `at' `=`min' + `i'/`n' * (`max' - `min')'
}
qui sum `varlist' if `touse'
local min = r(min)
local max = r(max)
egen  `type' `h' = cut(`varlist') if `touse', at(`min' `at' `max') icodes
end
exit


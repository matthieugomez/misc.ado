/* it's like a  xtile that makes sure tha when you do p(10) you have 10 % of weight in the bottom (i.e. deals with equality stuff) */
program _gsep, byable(onecall) sortpreserve
version 8.2
gettoken type 0 : 0
gettoken h    0 : 0 
gettoken eqs  0 : 0

syntax varname(numeric) [if] [in] [, ///
Percentiles(string) ///
Nquantiles(string) ///
Weights(string) by(varlist) ]

marksample touse 
tempvar byvar
// Error Checks

if "`percentiles'" != "" & "`nquantiles'" != "" {
	di as error "do not specify percentiles and nquantiles"
	exit 198
}

// Default Settings etc.

if "`weights'" ~= "" {
	local weight "[aw = `weights']"
}

if "`percentiles'" != "" {
	local percnum "`percentiles'"
}
else if "`nquantiles'" != "" {
	local perc = 100/`nquantiles'
	local first = `perc'
	local step = `perc'
	local last = 100-`perc'
	local percnum "`first'(`step')`last'"
}

if "`nquantiles'" == "" & "`percentiles'" == "" {
	local percnum 50
}

quietly {

	gen `type' `h' = .
	sort `touse' `by' `varlist'
	if "`weights'" ~= ""{
		by `touse' `by': gen `byvar' = sum(`weights')
	}
	else{
		by `touse' `by': gen `byvar' = _n
	}
	by `touse' `by': replace `byvar' = `byvar'/`byvar'[_N] * 100
	local i = 1
	replace `h' = 1 if `touse'
	foreach p in `percnum'{
		local i = `i' + 1
		replace `h' = `i' if `byvar' > `p' & `touse'
	}
}

end
exit


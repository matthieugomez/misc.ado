qui{
program bindensity 
syntax varlist [if] [, ///
by(varname)  Absorb(varlist) ///
linetype(string) ///
MSize(real 1) ///
Msymbols(string) COLors(string) MColors(string) LColors(string)  *]


qui{


    if ("`linetype'"=="" | "`linetype'" == "connect"){
        local connect connect(1)
    }
    else{
        local connect ""
    }
    if `"`colors'"'=="" local colors ///
    navy maroon forest_green dkorange teal cranberry lavender ///
    khaki sienna emidblue emerald brown erose gold bluishgray 
    if `"`mcolors'"'=="" {
        local mcolors `colors'
    }
    if `"`lcolors'"'=="" {
        local lcolors `colors'
    }
    local num_mcolor=wordcount(`"`mcolors'"')
    local num_lcolor=wordcount(`"`lcolors'"')
    if ("`linetype'"=="connect") local connect "c(l)"
    if "`msymbols'"!="" {
        local symbol_prefix "msymbol("
        local symbol_suffix ")"
    }

    tempvar count count_absorb_by_bin count_absorb_by count_absorb count_all g tag touse 
    gen byte `touse' = 1 `if' 
    replace `touse' = 0 if missing(`varlist') | missing(`varname') | missing(`absorb') | missing(`by')
    bys `touse' `by' `varlist'  : gen byte `tag' = _n==1 if `touse' 
    bys `touse' `absorb' `by' : gen long `count_absorb_by' = _N if `touse'
    by `touse' `absorb' : gen long `count_absorb' = _N if `touse'
    by `touse' : gen long `count_all' = _N if `touse'
    egen double `count' = sum(1/`count_absorb_by'*`count_absorb'/`count_all') if `touse', by(`varlist' `by') 
    *noi tab `temp2'
    sort `varlist'
    egen `g' = group(`by') `if', label
    sum `g'
    local script ""
    foreach i of numlist 1/`r(max)'{
        if "`script'"~=""{
            local script `script' ||
        }
        local scatter_options ///
        `connect' msize(`msize') ///
        mcolor(`: word `i' of `mcolors'') lcolor(`: word `i' of `lcolors'') ///
        `symbol_prefix'`: word `i' of `msymbols''`symbol_suffix' ///
        legend(label(`i'  `:label (`g') `i'')) 
        local script `script' scatter `count' `varlist' if `g' == `i' & `touse' == 1 & `tag' == 1,  `scatter_options' 
    }
    twoway `script' `options' legend(subtitle("`by'"))  graphregion(fcolor(white))
}
end

}
sym

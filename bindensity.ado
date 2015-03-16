
/***************************************************************************************************
example with colors:
colorbrewer ggplot, n(3) 
bindensity wage , by(race) colors(`"`r(colors)'"')
***************************************************************************************************/
program bindensity 
    syntax varlist [if] [, ///
    by(varname)  Absorb(varlist) ///
    discrete n(integer 20) cut(string) min(string) max(string) boundary ///
    linetype(string) cutline(string) ///
    MSize(string) ///
    Msymbols(string) COLors(string) MColors(string) LColors(string)  *]


    qui{
        if "`msize'" == "" {
            local msize 1
            if `n'> 20{
                local msize = ln(20)/ln(`n')
            }
        }
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
            local mcolors `"`colors'"'
        }
        if `"`lcolors'"'=="" {
            local lcolors `"`colors'"'
        }
        local num_mcolor=wordcount(`"`mcolors'"')
        local num_lcolor=wordcount(`"`lcolors'"')
        if ("`linetype'"=="connect") local connect "c(l)"
        if "`msymbols'"!="" {
            local symbol_prefix "msymbol("
                local symbol_suffix ")"
}

tempvar bin count count_absorb_by_bin count_absorb_by count_absorb count_all g tag touse temp2

gen byte `touse' = 1 `if' 
replace `touse' = 0 if missing(`varlist') | missing(`varname') | missing(`absorb') | missing(`by')


if "`discrete'" == ""{
    tab `varlist' if `touse' == 1
    if `=r(N)' > `n'{
        if "`min'"=="" | "`max'" == "" {
            sum `varlist' if `touse' == 1
        }
        if "`min'" == ""{
            local min  `=r(min)'
        }
        if "`max'" == ""{
            local max `=r(max)'
        }
        tempname bottom top increment cutbin
        _pctile `varlist' if `touse' == 1, percentiles(25 50 75)
        scalar `bottom' = max(`min', r(r2) - 5*(r(r3)-r(r1)))
        scalar `top' = min(`max', r(r2) + 5*(r(r3)-r(r1)))
        if "`cut'"~= ""{
            scalar `cutbin' = floor((`cut'-`bottom')/(`top'-`bottom')*`n')
            scalar `bottom' = `cut'-`cutbin'* (`top'-`bottom')/`n'
            scalar `top' = `cut'+(`n'-`cutbin')*(`top'-`bottom')/`n'
        }
        gen `bin' =  floor((`varlist'-`bottom')/(`top'-`bottom')*`n')  if `touse' == 1
        if "`cut'" ~= ""{
            assert `bin' == float(`cutbin') | `varlist'~= float(`cut') | `touse' ~= 1
        }
        if "`boundary'" == ""{
            replace `bin' = `n'-1 if `varlist' >= `top' &  `touse' == 1
            replace `bin' = 0 if `varlist' <= `bottom' &  `touse' == 1
        }
        else{
            replace `touse' = 0 if `varlist' >= `top' | `varlist' <= `bottom'
        }
        replace `bin'= (`bin'+0.5) /`n'* (`top'-`bottom') + `bottom' if `touse' == 1
    }
    else{
        gen `bin' = `varlist'  if `touse' == 1
    }
}
else{
    gen `bin' = `varlist'  if `touse' == 1
}



bys `touse' `by' `bin'  : gen byte `tag' = _n==1 if `touse' == 1
bys `touse' `absorb' `by' : gen long `count_absorb_by' = _N if `touse'== 1
by `touse' `absorb' : gen long `count_absorb' = _N if `touse'== 1
by `touse' : gen long `count_all' = _N if `touse'== 1
bys `touse' `by' `bin': gen `count' = sum(1/`count_absorb_by'*`count_absorb'/`count_all') if `touse'==1
bys `touse' `by' `bin': replace `count' = `count'[_N] if `touse'==1


local script ""
if "`by'"~=""{
    local bylegend legend(subtitle("`by'"))
    capture confirm numeric variable `by'
    if _rc {
        * by-variable is string => generate a numeric version
        tempvar by
        tempname bylabel
        egen `by'=group(`byvarname'), lname(`bylabel')
    }
    local bylabel `:value label `by''
    tempname byvalmatrix
    qui tab `by' if `touse'==1, nofreq matrow(`byvalmatrix')
    local bynum=r(r)

    foreach i of numlist 1/`bynum'{
        if `"`script'"'~=""{
            local script `script' ||
        }
        local scatter_options ///
        `connect' msize(`msize') ///
        mcolor("`: word `i' of `mcolors''") lcolor("`: word `i' of `lcolors''") ///
        `symbol_prefix'`: word `i' of `msymbols''`symbol_suffix' ///
        legend(label(`i'  `:label `bylabel' `i'')) 
        local script `script' scatter `count' `bin' if `by' == `=`byvalmatrix'[`i',1]' & `touse' == 1 & `tag' == 1,  `scatter_options' 
    }
} 
else{
    local scatter_options ///
    `connect' msize(`msize') ///
    mcolor(`mcolors') lcolor(`lcolors') ///
    `symbol_prefix'`msymbols'`symbol_suffix' 
    local script `script' scatter `count' `bin' if  `touse' == 1 & `tag' == 1,  `scatter_options' 
}

if "`cut'" ~= ""{
    if "`cutline'" == ""{
        local cutline solid
    }
    if "`cutline'" == "noline"{
        local pattern 
    }
    else{
        local pattern lpattern(`cutline')
    }
    local xline xline(`cut', lcolor(black) `pattern')
}

twoway `script' `options' `bylegend'  graphregion(fcolor(white)) xtitle(`varlist') ytitle("density") `xline'
}
end


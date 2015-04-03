
/***************************************************************************************************
example with colors:
colorbrewer ggplot, n(3) 
bindensity wage , by(race) colors(`"`r(colors)'"')
***************************************************************************************************/
program bindensity, rclass sortpreserve
syntax varlist [if] [in] [aweight fweight] [, ///
by(varname)  Absorb(varname) ///
discrete Nbin(integer 20) cut(string) min(string) max(string) boundary ///
linetype(string) cutline(string) ///
MSize(string) count lncount ///
Msymbols(string) COLors(string) MColors(string) LColors(string)  *]


qui{
    if ("`weight'"!="") local wt [`weight'`exp']
    local weightv `=regexr("`exp'","=","")'

    if "`msize'" == "" {
        local msize 1
        if `nbin'> 20{
            local msize = ln(20)/ln(`nbin')
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

marksample touse
markout `touse'  `by'  `absorb', strok

qui count if `touse'
local samplesize=r(N)
local touse_first=_N-`samplesize'+1
local touse_last=_N
if `samplesize' == 0 {
    di as error "no obs" 
    exit 10
}

if "`by'"~=""{
    local bylegend legend(subtitle("`by'"))
    capture confirm numeric variable `by'
    if _rc {
        * by-variable is string => generate a numeric version
        tempvar byv
        tempname bylabel
        egen `byv' = group(`by'), lname(`bylabel')
        local by `byv'
    }
}

if "`discrete'" == ""{
    tempvar bin
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
    scalar `increment' = (`top'-`bottom')/`nbin'
    if "`cut'"~= ""{
        scalar `cutbin' = floor((`cut'-`bottom')/ `increment')
        scalar `bottom' = `cut'-`cutbin'* `increment'
        scalar `top' = `cut'+(`nbin'-`cutbin')*`increment'
    }
    gen `bin' =  floor((`varlist'-`bottom')/`increment')  if `touse' == 1
    if "`cut'" ~= ""{
        replace `bin' = `cutbin' if float(`varlist') == float(`cut') & `touse' ~= 1
        di `r(N)'
    }
    if "`boundary'" == ""{
        replace `bin' = `nbin'-1 if `varlist' >= `top' &  `touse' == 1
        replace `bin' = 0 if `varlist' <= `bottom' &  `touse' == 1
    }
    else{
        replace `touse' = 0 if `varlist' >= `top' | `varlist' <= `bottom'
    }
    tempvar bin2
    replace `bin'= (`bin'+0.5) /`nbin'* (`top'-`bottom') + `bottom' if `touse' == 1

    tempname binvalmatrix
    noi tab `bin', nofreq matrow(`binvalmatrix')
    local binnum `r(r)'
    return local binvall`binnum' >= `: di %3.2f `=`binvalmatrix'[`binnum',1]''
    foreach i of numlist `=`binnum'-1'/2 {
        return local binvall`i' [`: di %3.2f `=`binvalmatrix'[`i',1]'' `: di %3.2f `=`binvalmatrix'[`i'+1,1]''[
    }
    return local binvall1 < `: di %3.2f `=`binvalmatrix'[2,1]''
    /*  
    tempname binmatrix
    tab `bin' if `touse' == 1, nofreq matrow(`binmatrix')
    tempvar binmin binmax
    egen `binmax' = max(`varlist') if `touse' == 1, by(`bin')
    egen `binmin' = min(`varlist') if `touse' == 1, by(`bin')
    tempname binminmatrix binmaxmatrix
    tab `binmin' if `touse' == 1, nofreq matrow(`binminmatrix')
    tab `binmax' if `touse' == 1, nofreq matrow(`binmaxmatrix')
    foreach i of numlist 1/`=r(r)' {
        return local binval`i' `=`binminmatrix'[`i',1]' `=`binmaxmatrix'[`i',1]' (`=`binmatrix'[`i',1]')
    }
    */
}

else{
    local bin `varlist'
}





if "`absorb'" ~= ""{
    if "`weight'" == ""{
        tempvar weight2
        bys `touse' `by' `absorb': gen `weight2' = 1 / _N
    }
    else{
        tempvar weight2
        bys `touse' `by' `absorb': gen `weight2' = 1 / sum(`weightv')
    }
}
else{
    if "`weight'" == ""{
        local weight2 1
    }
    else{
        local weight2 `weightv'
    }
}

if !(`touse_first'==1 & word("`:sortedby'",1)=="`by'")  local stouse `touse'
tempvar varcount
bys `stouse' `by' `bin': gen `varcount' = sum(`weight2') 
by `stouse' `by' `bin': replace `varcount' = 0 if _n < _N
if "`lncount'" ~= ""{
    by `stouse' `by' `bin': replace `varcount' = ln(`varcount') if _n == _N
}
else if "`count'" == "" {
    tempvar tvarcount
    by `stouse' `by' : gen `tvarcount' = sum(`varcount') 
    by `stouse' `by': replace `varcount' = `varcount'/`tvarcount'[_N]
}


local script ""

if "`by'"~=""{

    tempname byvalmatrix
    tempname by_boundaries
    mata: characterize_unique_vals_sorted2("`by'",`touse_first',`touse_last',`=_N')
    matrix `byvalmatrix'=r(values)
    noi matrix list r(values)
    matrix `by_boundaries'=r(boundaries)
    local bynum=r(r)

    foreach i of numlist 1/`bynum'{
        local script `script' (scatteri
            local byval `=`byvalmatrix'[`i',1]'
            if ("`bylabel'"=="") {
                local byvalname=`byval'
            }
            else {
                local byvalname `: label `bylabel' `byval''
            }


            cap  mata: characterize_unique_vals_sorted2("`bin'",`=`by_boundaries'[`i',1]',`=`by_boundaries'[`i',2]',`nbin')
            if _rc{

                forvalues row = 1/`binnum'{
                    local xval = `binvalmatrix'[`row', 1]
                    local yval = 0
                    local script `script' `yval' `xval' 
                }
            }
            else{

                tempname bin_boundaries bin_values
                matrix `bin_boundaries'=r(boundaries)
                matrix `bin_values'=r(values)
                local bin_n =r(r)

                local row=1
                local xval=`bin_values'[`row', 1]
                local yval=`varcount'[`=`bin_boundaries'[`row', 2]']
                local row2 = 1
                forvalues row = 1/`binnum'{
                    if  `=`binvalmatrix'[`row', 1]' < `=`bin_values'[`row2', 1]'{
                        local xval = `binvalmatrix'[`row', 1]
                        local yval = 0
                        local script `script' `yval' `xval' 
                    }
                    else{
                        local xval = `bin_values'[`row2', 1]
                        local yval = `varcount'[`=`bin_boundaries'[`row2', 2]']
                        local script `script' `yval' `xval' 
                        local ++row2
                    }
                    local script `script' `yval' `xval' 
                }

            }



            local scatter_options ///
            `connect' msize(`msize')  ///
            mcolor("`: word `i' of `mcolors''") lcolor("`: word `i' of `lcolors''") ///
            `symbol_prefix'`: word `i' of `msymbols''`symbol_suffix' ///
            legend(label(`i'  `byvalname')) 
            local script `script', `scatter_options')
    }
} 
else{

    mata: characterize_unique_vals_sorted2("`bin'",`touse_first',`touse_last',`nbin')
    tempname bin_boundaries bin_values
    matrix `bin_boundaries'=r(boundaries)
    matrix `bin_values'=r(values)
    local bin_n =r(r)



    local row=1
    local xval=`bin_values'[`row', 1]
    local yval=`varcount'[`=`bin_boundaries'[`row', 2]']

    local script `script' (scatteri
        local row2 = 1
        forvalues row = 1/`binnum'{
            if  `binvalmatrix'[`row', 1] ~= `bin_values'[`row2', 1]{
                local xval = `binvalmatrix'[`row', 1]
                local yval = 0
                local script `script' `yval' `xval' 
            }
            else{
                local xval = `bin_values'[`row2', 1]
                local yval = `varcount'[`=`bin_boundaries'[`row2', 2]']
                local script `script' `yval' `xval' 
                local ++row2
            }
            local script `script' `yval' `xval' 
        }

        local scatter_options ///
        `connect' msize(`msize')  ///
        mcolor("`: word `i' of `mcolors''") lcolor("`: word `i' of `lcolors''") ///
        `symbol_prefix'`: word `i' of `msymbols''`symbol_suffix'
        local script `script', `scatter_options')

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
if "`count'" == "" local ytitle density
else local ytitle count

twoway `script', `options' `bylegend'  graphregion(fcolor(white)) xtitle(`varlist') ytitle(`ytitle') `xline'
}
end


/***************************************************************************************************
helper from binscatter
***************************************************************************************************/



version 12.1
set matastrict on

mata:

    void characterize_unique_vals_sorted2(string scalar var, real scalar first, real scalar last, real scalar maxuq) {
        // Inputs: a numeric variable, a starting & ending obs #, and a maximum number of unique values
        // Requires: the data to be sorted on the specified variable within the observation boundaries given
        //              (no check is made that this requirement is satisfied)
        // Returns: the number of unique values found
        //          the unique values found
        //          the observation boundaries of each unique value in the dataset


        // initialize returned results
        real scalar Nunique
        Nunique=0

        real matrix values
        values=J(maxuq,1,.)

        real matrix boundaries
        boundaries=J(maxuq,2,.)

        // initialize computations
        real scalar var_index
        var_index=st_varindex(var)

        real scalar curvalue
        real scalar prevvalue

        // perform computations
        real scalar obs
        for (obs=first; obs<=last; obs++) {
            curvalue=_st_data(obs,var_index)

            if (curvalue!=prevvalue) {
                Nunique++
                if (Nunique<=maxuq) {
                    prevvalue=curvalue
                    values[Nunique,1]=curvalue
                    boundaries[Nunique,1]=obs
                    if (Nunique>1) boundaries[Nunique-1,2]=obs-1
                }
                else {
                    exit(error(134))
                }

            }
        }
        boundaries[Nunique,2]=last

        // return results
        stata("return clear")

        st_numscalar("r(r)",Nunique)
        st_matrix("r(values)",values[1..Nunique,.])
        st_matrix("r(boundaries)",boundaries[1..Nunique,.])

    }

end

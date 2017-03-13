/***************************************************************************************************

***************************************************************************************************/
program bindensity, eclass sortpreserve
syntax varlist [if] [in] [aweight fweight] [, ///
by(varname)  ///
discrete Nbin(integer 20) cut(string) min(string) max(string) boundary ///
linetype(string) cutline(string) ///
MSize(string) count lncount ///
AESthetics(string) ///
palette(string) COLors(string asis) MColors(string asis) LColors(string asis) Msymbols(string) LPatterns(string) ///
clean *]


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
        local connect connect(l)
    }
    else{
        local connect ""
    }





    marksample touse
    markout `touse'  `by'  `absorb', strok



    /* transform weight if absorb is specified */
    if "`weight'" == ""{
        local weight1 1
    }
    else{
        local weight1 `weightv'
    }


    qui count if `touse'
    local samplesize=r(N)
    local touse_first=_N-`samplesize'+1
    local touse_last=_N
    if `samplesize' == 0 {
        di as error "no obs" 
        exit 10
    }

    if "`by'"~=""{
        local byvarname `by'
        local byvarlabel `: var label `by''
        if "`byvarlabel'" == ""{
            local byvarlabel `by'
        }
        capture confirm numeric variable `by'
        if _rc {
            * by-variable is string => generate a numeric version
            tempvar by
            tempname byvaluelabel
            egen `by'=group(`byvarname'), lname(`byvaluelabel')
        }

        local byvaluelabel `:value label `by'' /*catch value labels for numeric by-vars too*/ 

        tempname byvalmatrix
        qui tab `by' if `touse', nofreq matrow(`byvalmatrix')

        local bynum=r(r)
        forvalues i=1/`bynum' {
            local byvals `byvals' `=`byvalmatrix'[`i',1]'
        }

        sort `touse' `by'
        tempname by_boundaries
        mata: characterize_unique_vals_sorted2("`by'",`touse_first',`touse_last',`bynum')
        matrix `by_boundaries'=r(boundaries)
    }
    else{
        local bynum 1
    }

    local ynum 1


    * default aesthetics to color and replace color by mcolor and lcolor
    if "`aesthetics'" == ""{
        local aesthetics mcolor lcolor
    }
    local aesthetics2
    foreach a in `aesthetics'{
        if "`a'" == "color"{
            local aesthetics2 `aesthetics2' mcolor lcolor
        }
        else{
            local aesthetics2 `aesthetics2' `a'
        }
    }
    local aesthetics `aesthetics2'

    if `"`colors'"' == ""{
        if "`palette'" ~= ""{
            colorscheme `bynum', palette(`palette')
            local colors `"`=r(colors)'"'
        }

        else{
            local colors ///
            navy maroon forest_green dkorange teal cranberry lavender ///
            khaki sienna emidblue emerald brown erose gold bluishgray ///
            lime magenta cyan pink blue
        }
    }
    * Fill colors if missing
    if `"`mcolors'"'=="" {
        if regexm("`aesthetics'","mcolor"){
            local mcolors `"`colors'"'
        }
        else{
            local aesthetics `aesthetics' mcolor
            local mcolors `"`color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1'"'
        }
    }
    if `"`lcolors'"'=="" {
        if regexm("`aesthetics'","lcolor"){
            local lcolors `"`colors'"'
        }
        else{
            local aesthetics `aesthetics' lcolor
            local lcolors `"`color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1' `color1'"'
        }
    }

    if `"`lpatterns'"'=="" {
        if regexm("`aesthetics'","lpattern"){
            local lpatterns `"solid dash vshortdash longdash longdash_dot shortdash_dot dash_dot_dot longdash_shortdash dash_dot  dash_3dot longdash_dot_dot shortdash_dot_dot longdash_3dot dot tight_dot"'
        }
        else{
            local aesthetics `aesthetics' lpattern
            local lpatterns solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid 
        }
    }

    if `"`msymbols'"'=="" {
        if regexm("`aesthetics'","lpattern"){
            local msymbols circle diamond square triangle x plus circle_hollow diamond_hollow square_hollow triangle_hollow smcircle smdiamond smsquare smtriangle smx

        }
        else{
            local aesthetics `aesthetics' msymbols
            local msymbols circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle 
        }
    }




    local num_mcolor=wordcount(`"`mcolors'"')
    local num_lcolor=wordcount(`"`lcolors'"')
    if ("`linetype'"=="connect") local connect "c(l)"









    /* create bins */
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
        if "`clean'" ~= ""{
            _pctile `varlist' if `touse' [w=`weight'], percentiles(25 50 75)
            scalar `bottom' = max(`min', r(r2) - 5*(r(r3)-r(r1)))
            scalar `top' = min(`max', r(r2) + 5*(r(r3)-r(r1)))
        }
        else{
            scalar `bottom' = `min'
            scalar `top' = `max'
        }
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
        replace `bin'= (`bin' + 0.5) /`nbin'* (`top'-`bottom') + `bottom' if `touse' == 1

        tempname binvalmatrix
    }
    else{
        local bin `varlist'
    }
    tab `bin', nofreq matrow(`binvalmatrix')
    local binnum `r(r)'



    tempvar varcount
    bys `touse' `by' `bin': gen `varcount' = sum(`weight1') 
    by `touse' `by' `bin': replace `varcount' = 0 if _n < _N
    if "`lncount'" ~= ""{
        by `stouse' `by' `bin': replace `varcount' = ln(`varcount') if _n == _N
    }
    else if "`count'" == "" {
        tempvar tvarcount
        by `touse' `by' : gen `tvarcount' = sum(`varcount') 
        by `touse' `by': replace `varcount' = `varcount'/`tvarcount'[_N]
    }


    local scatters ""
    sort `touse' `by' `bin'
    if "`by'"~=""{

        foreach i of numlist 1/`bynum'{
            local scatter scatteri
            local byval `=`byvalmatrix'[`i',1]'
            if "`bylabel'"=="" {
                local byvalname `byval'
            }
            else {
                local byvalname `: label `bylabel' `byval''
            }


            cap  mata: characterize_unique_vals_sorted2("`bin'",`=`by_boundaries'[`i',1]',`=`by_boundaries'[`i',2]',`nbin')
            if _rc{
                forvalues row = 1/`binnum'{
                    local xval = `binvalmatrix'[`row', 1]
                    local yval = 0
                    local scatter `scatter' `yval' `xval' 
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
                        local scatter `scatter' `yval' `xval' 
                    }
                    else{
                        local xval = `bin_values'[`row2', 1]
                        local yval = `varcount'[`=`bin_boundaries'[`row2', 2]']
                        local scatter `scatter' `yval' `xval' 
                        local ++row2
                    }
                    local scatter `scatter' `yval' `xval' 
                }
            }

            local counter_series=0
            local scatter_options `connect'
            foreach a in `aesthetics' {
                local scatter_option `a'(`"`:word `i' of ``a's''"')
                local scatter_options `scatter_options' `scatter_option'
            }
            local scatters `scatters' (`scatter', `scatter_options')


            if ("`byvaluelabel'"=="") local byvalname `byval'
            else local byvalname `: label `byvaluelabel' `byval''
            local legend_labels `legend_labels' lab(`i' `"`byvalname'"')
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

        local scatter scatteri
        local row2 = 1
        forvalues row = 1/`binnum'{
            if  `binvalmatrix'[`row', 1] ~= `bin_values'[`row2', 1]{
                local xval = `binvalmatrix'[`row', 1]
                local yval = 0
                local scatter `scatter' `yval' `xval' 
            }
            else{
                local xval = `bin_values'[`row2', 1]
                local yval = `varcount'[`=`bin_boundaries'[`row2', 2]']
                local scatter `scatter' `yval' `xval' 
                local ++row2
            }
            local scatter `scatter' `yval' `xval' 
        }


        local scatter_options `connect'
        foreach a in `aesthetics' {
            local scatter_option `a'(`"`:word `counter_series' of ``a's''"')
            local scatter_options `scatter_options' `scatter_option'
        }
        local scatters (`scatter', `scatter_options')
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

    twoway `scatters',   graphregion(fcolor(white)) xtitle(`varlist') ytitle(`ytitle') `xline' legend(`legend_labels' order(`order')) `options'

    ereturn post, esample(`touse')
    ereturn scalar N = `samplesize'
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

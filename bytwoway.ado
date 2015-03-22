program bytwoway
    syntax anything [if] [in], by(varname) [palette(string) colors(string) *]

    marksample touse
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
    if `"`colors'"' == ""{
        if "`palette'" == ""{
            local palette ggplot
        }
        colorbrewer `palette', n(`bynum')
        local colors `"`r(colors)'"'
    }

    foreach i of numlist 1/`bynum'{
        local byval `=`byvalmatrix'[`i',1]'
        if ("`bylabel'"=="") {
            local byvalname=`byval'
        }
        else {
            local byvalname `: label `bylabel' `byval''
        }
        if `"`script'"'~=""{
            local script `script' ||
        }
        local scatter_options ///
        color("`: word `i' of `colors''") ///
        legend(label(`i'  `byvalname')) 
        local script `script' `anything' if `by' == `byval' & `touse' == 1, `scatter_options' 
    }

    twoway `script'  `bylegend' `options'   graphregion(fcolor(white)) 
end

/***************************************************************************************************
sysuse nlsw88.dta, clear
collapse (mean) wage, by(grade race)
bytwoway line wage grade, by(race)
***************************************************************************************************/
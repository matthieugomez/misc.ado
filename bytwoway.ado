program bytwoway
syntax anything [if] [in], [ by(varname) aes(string) palette(string) color(string) * scheme(string)]

marksample touse



count if `touse'
local samplesize=r(N)
local touse_first=_N-`samplesize'+1
local touse_last=_N
tempvar bylength
bys `touse' `by' : gen `bylength' = _N 
local start = `touse_first'







if "`aes'" ~= ""{
    local ia = 0
    foreach v in `aes'{
        local ++ia
        if regexm("`v'", "(.*)\((.*)\)"){
            local option`ia' `=regexs(1)'
            local variable`ia' `=regexs(2)'
        }
        else{
            return as error "aes badly specified"
            exit 100
        }
        if regexm("`option`ia''", "color|lstyle|mcolor|lcolor|symbol"){
            tempname `variable`ia'' matrix
            levelsof `variable`ia'' if `touse'==1, clean
            local levelsvariable`ia' `r(levels)'
        }
    }
}




if "`by'" == ""{
    local ia = 0
    foreach v in `aes'{
        local ++ia
        local groups `groups' `variable`ia''
    }
    if `ia' > 1{
        local bydummy no
        tempvar by
        bysort `groups': gen `by' = _n == 1
        replace `by' = sum(`by')
    }
    else{
        local by `variable`1''
    }
}
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




if "`color'" == ""{
    colorwheel `bynum'
    local color `"`r(colors)'"'
}
if "`lstyle'" == ""{
    local lstyle "solid dash dot shortdash longdash dash_dot sortdash_dot  longdash_dot"
}
if "`mcolor'"==""{
    local mcolor `color'
}
if "`lcolor'" == ""{
    local lcolor `color'
}
if "`symbol'"== ""{
    local symbol "circle diamond triangle sqaure plus X smcircle smdiamond smaquare smtriangle smplus smx"
}




tempvar bylength
bys `touse' `by' : gen `bylength' = _N 
local start = `touse_first'
local i = 0
while `start' <= `touse_last'{
    local ++i
    local end = `start' + `=`bylength'[`start']' - 1
    local byvalname 
    if "`bydummy'" == ""{
        local byval `=`by'[`start']'
        if ("`bylabel'"=="") {
            local byvalname=`byval'
        }
        else {
            local byvalname `: label `bylabel' `byval''
        }
    }
    else{
        local ia = 0
        foreach v in `aes'{
            local ++ia
            local byval `=`variable`ia''[`start']'
            if ("`bylabel'"=="") {
                local byvalname `byvalname', `variable`ia'' =`byval'
            }
            else {
                local byvalname `byvalname', `variable`ia'' =`: label `bylabel' `byval''
            }
        }
        local byvalname `=subinstr(`"`byvalname'"',",","",1)'
    }
    local scatter_options legend(label(`i'  `byvalname')) 
    local ia = 0
    foreach v in `aes'{
        local ++ia
        if regexm("`option`ia''", "color|lstyle|mcolor|lcolor|symbol"){
            local pos `: list posof "`=`variable`ia''[`start']'" in levelsvariable`ia''
            local scatter_option `option`ia''(`"`:word `pos' of ``option`ia''''"')
        }
        else{
            local scatter_option `option`ia''(`=`variable`ia''[`start']')
        }
        local scatter_options `scatter_options' `scatter_option'
    }
    local script `script' (`anything' in `start'/`end', `scatter_options')
    local start = `end' + 1

}


twoway `script'  `options'   
end

/***************************************************************************************************
sysuse nlsw88.dta, clear
collapse (mean) wage, by(grade race)
bytwoway line wage grade, by(race)
***************************************************************************************************/
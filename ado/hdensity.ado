program hdensity 
syntax varlist [if] [, by(varname)  Absorb(varlist) MSize(real 1) NOConnect *]

if "`noconnect'"==""{
    local connect connect(1)
}
else{
    local connect ""
}

qui{
    tempvar count count_absorb_by_bin count_absorb_by count_absorb count_all g tag tag2 touse temp temp2
    gen byte `touse' = 1 `if' 
    replace `touse' = 0 if missing(`varlist') | missing(`varname') | missing(`absorb') | missing(`by')
    bys `touse' `by' `varlist'  : gen byte `tag' = _n==1 if `touse' 
    bys `touse' `absorb' `by' : gen long `count_absorb_by' = _N if `touse'
    by `touse' `absorb' : gen long `count_absorb' = _N if `touse'
    by `touse' : gen long `count_all' = _N if `touse'
    egen double `temp' = sum(1/`count_absorb_by'*`count_absorb'/`count_all') if `touse', by(`varlist' `by') 
    *egen `temp2' = sum(`temp') if `touse' & `tag' ==1 , by (`by')
    *noi tab `temp2'
    sort `varlist'
    egen `g' = group(`by') `if', label
    sum `g'
    local script ""
    foreach i of numlist 1/`r(max)'{
        if "`script'"~=""{
            local script `script' ||
        }
        local script `script' scatter `temp' `varlist' if `g' == `i' & `touse' == 1 & `tag' == 1, msize(`msize') `connect' legend(label(`i'  `:label (`g') `i''))  
    }
    twoway `script' `options'
}
end


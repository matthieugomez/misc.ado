
/***************************************************************************************************
by dfl, 
- reweight so that (count of xq / count of xq == 10) is the same accross dfl
***************************************************************************************************/
cap program drop reweight
program define reweight 
    syntax varlist [if] [in] [aweight], matching(varname) propensity(varlist) gen(string) [nq(int 20)]
    if ("`weight'"!=""){
        local wt [`weight'`exp']
        local weightv `=regexr("`exp'","=","")'
    }
    confirm new var `gen'
    if "`matching'" ~= ""{
        local x matching
        local by `varlist'
        marksample touse 
        markout `touse' `x'
        if "`nq'" ~= ""{
            tempvar xq
            fastxtile `xq' = `x' if `touse', nq(`nq') 
        }
        else{
            local xq x
        }
        tempname dummy
        qui tab `xq' `wt', matcell(freqs) matrow(names) nol gen(`dummy')
        local n = rowsof(names)
        local ref = names[floor(`n'/2), 1]
        di "Reference bin for reweighting is `ref'"
        sort `by'
        ds `dummy'*, d
        forval j = 1/`n' {
            tempvar dummy`j'
            by `by': gen  `dummy`j'' = sum(`dummy'`j')
        }
        forval j = 1/`n' {
            local cond `cond' cond(`xq' == names[`j',1], `dummy`ref''[_N]/ `dummy`j''[_N]*N[`j',1]/N[`ref',1],
                local condend `condend' )
        }
        by `by': gen `gen' = `cond' . `condend'
    }
    else if "`propensity'" ~= ""{
        local by `varlist'
        local x `propensity'
        cap assert inlist(`by', 0, 1)
        if _rc{
            di as error "When the option propensity is specified, variable in by must be a binary variable (0 or 1)"
            exit
        }
        tempvar phat weight2
        qui probit `by' `x' `wt' if `touse'
        qui predict double `phat'
        gen `gen'= `weightv' * (1-`phat')/`phat' if `by' == 0
    }
end




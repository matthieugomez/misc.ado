/***************************************************************************************************
Important not to change since otherwise dummy variable like 0-1 might change. another condition could be intequartile >0?
***************************************************************************************************/


program clean, byable(recall)
syntax varlist [if] [in], [drop *]


tempvar touse
gen byte `touse' = 1 `if' `in'


foreach v of varlist `varlist'{
    qui sum `v'  if `touse' == 1
    scalar max = r(max)
    scalar min = r(min)
    if "`options'" ~= "" { 
        _pctile `v' if `touse' == 1, `options'
        scalar bottom = r(r1)
        scalar top = r(r2)
    }
    else{
        _pctile `v' if `touse' == 1, percentiles(25 50 75)
        scalar bottom = r(r2) - 5*(r(r3)-r(r1)) 
        scalar top = r(r2) + 5*(r(r3)-r(r1)) 
    }

    if "bottom" == "top" {
        display as error "bottom limit equals the top limit"
        exit 4
    }

    scalar bottom2 = round(`=bottom'*100)/100
    scalar top2 = round(`=top'*100)/100


    display as text "Bottom cutoff : " in ye `=bottom2' 
    qui count if `v' < min & `v' ~= . & `touse'== 1
    if r(N) == 0 & min == bottom{
        display as text "Bottom Quantile equals Minimum. No change"
    }
    else{
        display as text "Changes for the bottom : " in ye r(N)
        if "`drop'"==""{
            qui replace `v' = bottom if `v' < bottom & `v' ~= . & `touse' == 1
        }
        else if "`drop'" ~= ""{
            qui replace `v' = . if `v' < bottom & `touse' == 1
        }
    }

    display as text "Top cutoff : " in ye `=top2' 
    qui count if `v' > top & `v' ~= . & `touse' == 1
    if r(N) == 0 & max == top{
        display as text "Top Quantile equals Maximum. No change"
    }
    else{
        display as text "Changes for the top : " in ye r(N)
        if "`drop'"==""{
            qui replace `v' = top if `v' > top & `v' ~= . & `touse' == 1
        }
        else if "`drop'" ~= ""{
            qui replace `v'=. if `v' > top & `touse' == 1
        }
    }
}
end

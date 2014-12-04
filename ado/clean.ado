/***************************************************************************************************
Important not to change since otherwise dummy variable like 0-1 might change. another condition could be intequartile >0?
***************************************************************************************************/


program clean
syntax varlist, [drop *]

foreach v of varlist `varlist'{
    qui sum `v'
    scalar max = r(max)
    scalar min = r(min)

    if "`options'" ~= "" { 
        _pctile `v', `options'
        scalar bottom = r(r1)
        scalar top = r(r2)
    }
    else{
        _pctile `v', percentiles(25 50 75)
        scalar bottom = r(r2) - 5*(r(r3)-r(r1)) 
        scalar top = r(r2) + 5*(r(r3)-r(r1)) 
    }

    if "bottom" == "top" {
        display as error "bottom limit equals the top limit"
        exit 4
    }

   


    display as text "Bottom cutoff: `=bottom' "
    qui count if `v' < min & `v' ~= .
    if r(N) == 0 & min == bottom{
        display as tex "Bottom Quantile equals Minimum. No change"
    }
    else{
        display as text "Changes for the bottom : " in ye r(N)
        if "`drop'"==""{
            qui replace `v' = bottom if `v' < bottom & `v' ~= .
        }
        else if "`drop'" ~= ""{
            qui replace `v' = . if `v' < bottom
        }
    }

    display as text "Top cutoff: `=top' "
    qui count if `v' > top & `v' ~= .
    if r(N) == 0 & max == top{
        display as text "Top Quantile equals Maximum. No change"
    }
    else{
        display as text "Changes for the top : " in ye r(N)
            if "`drop'"==""{
                qui replace `v' = top if `v' > top & `v' ~= .
            }
            else if "`drop'" ~= ""{
                qui replace `v'=. if `v' > top
            }
    }
}
end

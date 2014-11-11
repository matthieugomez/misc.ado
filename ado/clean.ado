/***************************************************************************************************
Important not to change since otherwise dummy variable like 0-1 might change. another condition could be intequartile >0?
***************************************************************************************************/


program clean
syntax varlist [if] [in], [drop]
tokenize `varlist' 
while "`1'"~=""{
    qui sum `1',d
    tempname bottom top max min
    scalar `bottom'=r(p50)-5*(r(p75)-r(p25)) 
    scalar `top'=r(p50)+5*(r(p75)-r(p25)) 
    scalar `max'=r(max)
    scalar `min'=r(min)

    qui count if `1'>`top' & `1'~=.
    if r(N)==0 & `max'==`top'{
        display as error "Top Quantile equals Maximum. No change"
    }
    else{
        display as text "Changes for the top : " in ye r(N)

            if "`drop'"==""{
                qui replace `1'=`top' if `1'>`top' & `1'~=.
            }
            else if "`drop'"~=""{
                qui replace `1'=. if `1'>`top'
            }
    }
    qui count if `1'<`min' & `1'~=.
    if r(N)==0 & `min'==`bottom'{
        display as error "Bottom Quantile equals Minimum. No change"
    }
    else{
        display as text "Changes for the bottom : " in ye r(N)
        if "`drop'"==""{
            qui replace `1'=`bottom' if `1'<`bottom' & `1'~=.
        }
        else if "`drop'"~=""{
            qui replace `1'=. if `1'<`bottom'
        }
    }
    macro shift 
}
end

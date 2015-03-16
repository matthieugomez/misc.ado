/***************************************************************************************************
Important not to change since otherwise dummy variable like 0-1 might change. another condition could be intequartile >0?
***************************************************************************************************/


program clean, byable(recall)
    syntax varlist [if] [in], [drop by(varname) *]


    tempvar touse
    gen byte `touse' = 1 `if' `in'

    tempname max min bottom top top2 bottom2

    if "`by'"~=""{
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
    }
    else local bynum 1

    foreach i of numlist 1/`bynum'{
        if `bynum'>1{
            tempvar touseby
            gen `touseby' = `touse' == 1 & `by' ==  `=`byvalmatrix'[`i',1]'
            display in ye "`by' : `:label `bylabel' `i''"
        }
        else local touseby `touse'

        foreach v of varlist `varlist'{
            qui sum `v'  if `touseby'
            scalar `max' = r(max)
            scalar `min' = r(min)
            if "`options'" ~= "" { 
                _pctile `v' if `touseby', `options'
                scalar `bottom' = r(r1)
                scalar `top' = r(r2)
            }
            else{
                _pctile `v' if `touseby', percentiles(25 50 75)
                scalar `bottom' = r(r2) - 5*(r(r3)-r(r1)) 
                scalar `top' = r(r2) + 5*(r(r3)-r(r1)) 
            }

            if "bottom" == "top" {
                display as error "bottom limit equals the top limit"
                exit 4
            }

            scalar `bottom2' = round(`bottom'*100)/100
            scalar `top2' = round(`top'*100)/100


            qui count if `v' < `bottom' & `v' ~= . & `touseby'
            local nbottom `=r(N)'
            display as text "Bottom cutoff :  `=`bottom2'' (`nbottom' observation changed)"


            if "`drop'"==""{
                qui replace `v' = `bottom' if `v' < `bottom' & `v' ~= . & `touseby'
            }
            else if "`drop'" ~= ""{
                qui replace `v' = . if `v' < `bottom' & `touseby'
            }




            qui count if `v' > `top' & `v' ~= . & `touseby'
            local ntop `=r(N)'
            display as text "Top cutoff :  `=`top2'' (`ntop' observation changed)"

            if "`drop'"==""{
                qui replace `v' = `top' if `v' > `top' & `v' ~= . & `touseby'
            }
            else if "`drop'" ~= ""{
                qui replace `v'=. if `v' > `top' & `touseby'
            }
        }
    }
end

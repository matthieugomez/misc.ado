program define capds , rclass

    syntax anything [, NOT]
    local vlist `anything'
    tokenize `vlist'
    local i = 0
    while "`1'"~=""{
        cap ds `1'
        if _rc==0{
            local existingvlist `existingvlist' `r(varlist)'
        }
        else{
            local existingvlist `existingvlist' 
            local missingvlist `missingvlist' `1'
            local i=`i'+1
        }
        macro shift
    }  
    if "`existingvlist'" == ""{
        if "`not'" == ""{
            local out ""
        } 
        else {
            ds *
            local out `r(varlist)'
        }
    }
    else{
        ds `existingvlist',  `not'
        local out `r(varlist)'
    }
    return local varlist `out'
end

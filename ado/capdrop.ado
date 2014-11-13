program capdrop
syntax anything 

local droplist `anything'
tokenize `droplist'
local newdroplist ""
local i=0
while "`1'"~=""{
    cap ds `1'
    if _rc==0{
        local newdroplist `newdroplist' `r(varlist)'
    }
    else{
        local newdroplist `newdroplist' 
        local missinglist `missinglist' `1'
        local i=`i'+1
    }
    macro shift
}    
qui ds *
local alllist `r(varlist)'
if `i'~=0{
	display as text "Variables not found:" in ye "`missinglist'"
}
if "`newdroplist'"~=""{
    qui drop `newdroplist'
}
end

program capkeep
syntax anything 

local keeplist `anything'
tokenize `keeplist'
local newkeeplist ""
local i=0
while "`1'"~=""{
    cap ds `1'
    if _rc==0{
        local newkeeplist `newkeeplist' `r(varlist)'
    }
    else{
        local newkeeplist `newkeeplist' 
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
qui keep `newkeeplist'
end

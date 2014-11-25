program capdrop
syntax anything 


capds `0'
local vlist `r(varlist)'
if "`vlist'"~=""{
    qui drop `vlist'
}
end

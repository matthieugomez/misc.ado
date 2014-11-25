program capkeep
syntax anything 

capds `0'
local vlist `r(varlist)'
if "`vlist'"~=""{
    qui keep `vlist'
}
else{
    clear all
}
end

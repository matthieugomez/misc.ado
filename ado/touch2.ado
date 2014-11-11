program define touch2
syntax [anything], [replace] [var(string)]
local file = `"`=subinstr(`"`anything'"', `"""', "", .)'"'
preserve
drop _all
gen x=1
drop x
save "`file'", emptyok `replace'
restore
end



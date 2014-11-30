program define touch2
syntax [anything], [replace clear var(string)]
local file = `"`=subinstr(`"`anything'"', `"""', "", .)'"'
if "`file'" == "" {
        error 100
}

if "`clear'" ~= ""{
    preserve
}
drop _all
gen x=1
drop x

/* Set defaults if not specified */
local txttypes `""txt", "csv", "tsv", "tab""'
if "`type'" == "" {
        /* Try to set based on final three characters */
        * remove quotes from filename, if present
    local type = substr("`file'",-3,.)
        // If file extension is a txttype, preceded by a period, set type to "txt"
        if inlist("`type'", `txttypes') & substr("`file'",-4,1) == "." {
                local type "txt"
        }
        // Otherwise, default to dta
        else {
                local type "dta"
        }
}

/* Generate a variable for use in merges if specified */
if "`var'" != "" {
        foreach v of local var {
                gen `v' = .
        }
        sort `var' // to avoid "not sorted" error when user attempts merge
}


/*============================================================================*/
/*                                Save                                        */
/*============================================================================*/
if "`type'" == "dta" {
        save "`file'", emptyok `replace'
}

if inlist("`type'", `txttypes') {
        outsheet using "`file'", `replace'
}

/* Restore original dataset */
if "`clear'" ~= ""{
    restore
} else{
    drop _all
}
end



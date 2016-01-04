/***************************************************************************************************

***************************************************************************************************/
program define cleansas
syntax anything

/* compress types */
compress*

/* automatic format */
foreach v of varlist *{
    local vartype: type `v'
    if inlist("`vartype'", "byte", "int"){
        format `v'  %8.0g
    }
    else if "`vartype'" == "long"{
        format `v'  %12.0g
    }
    else if "`vartype'" == "float"{
        format `v'  %9.0g
    }
    else if "`vartype'" == "double"{
        format `v'  %10.0g
    }
}
end
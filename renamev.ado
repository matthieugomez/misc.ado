program renamev

    ds `0'
    local vlist `r(varlist)'
    foreach v in `vlist'{
        tempvar `v'
        rename `v' ``v''
    }

    local i = 0
    foreach v in `vlist'{
        local i = `i' + 1
        rename ``v'' v`i'
    }

end

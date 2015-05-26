program define fillall
	syntax [, id1(varlist) id2(varlist) GENerate(string)]
	if "`generate'" ~= ""{
		confirm new varname `generate'
	}
	tempvar gid1 gid2
	egen `gid1' = group(`id1'), missing
	egen `gid2' = group(`id2'), missing
	cap ds _fillin
	if _rc == 0{
		tempname temp
		rename _fillin `temp'
		local rename year
	}
	fillin `gid1' `gid2'
	if "`generate'" ~= ""{
		rename _fillin `gen'
	}
	else{
		drop _fillin
	}
	if "`rename'" ~= ""{
		rename `temp' _fillin
	}
	sort `gid1' `id1'
	foreach v of varlist `id1'{
		qui by `gid1': replace `v'= `v'[1] if missing(`v')
	}
	sort `gid2' `id2'
	foreach v of varlist `id2'{
		qui by `gid2': replace `v'= `v'[1] if missing(`v')
	}
	sort `id1' `id2'
end


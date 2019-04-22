* fillall is like fillin execpt the rectangularization is wrt (all existing combinations taken by set of variables in id1) x (all existing combinations taken by set of variables in id2)
* if id1 has 1 variable and id2 has 1 variable, then fillall, id1(v1) id2(v2) gen(_fillin) is equivalent to _fillin v1 v2
program define fillall
	syntax [, id1(varlist) id2(varlist) GENerate(string)]
	if "`generate'" ~= ""{
		confirm new variable `generate'
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
		rename _fillin `generate'
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


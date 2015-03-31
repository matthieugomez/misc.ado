program capappend
syntax using/, *
noi cap append using `"`using'"', `options'
if _rc == 106{
	foreach v of varlist *{
		capture confirm numeric variable `v'
		if _rc==0{
			local master_numeric `master_numeric' `v'
		}
		else{
			local master_string `master_string' `v'
		}
	}
	preserve
	use `"`using'"', clear
	foreach v of varlist *{
		capture confirm numeric variable `v'
		if _rc==0{
			local using_numeric `using_numeric' `v'
		}
		else{
			local using_string `using_string' `v'
		}
	}
	local inter: list master_string & using_numeric
	foreach v in `inter'{
		local type1: type `v'
		tostring `v', replace
		local type2: type `v'
		noi display as text "(note: variable `v' was `type1' in using, now `type2' to accommodate master data value)" 
	}
	tempfile using2
	save `"`using2'"', replace
	restore
	local inter: list master_numeric & using_string
	foreach v in `inter'{
		local type1: type `v'
		tostring `v', replace
		local type2: type `v'
		noi display as text "(note: variable `v' was `type1' in master, now `type2' to accommodate using data value)" 
	}
	noi append using `"`using2'"', `options'	
}
else if _rc == 3{
	use `"`using'"'
}
else{
	exit _rc
}

end

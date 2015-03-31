program define capappend
version 8.2

/***************************************************************************************************

***************************************************************************************************/
syntax using/, *
cap append using `"`using'"', `options'
if _rc~=0{
	cap use `"`using'"'
	if _rc~=0{
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
		use `"`using'"'
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
			display as result "`v' is numeric in using"
			tostring `v', replace
		}
		tempfile using2
		save `"`using2'"', replace
		restore
		local inter: list master_numeric & using_string
		foreach v in `inter'{
			display as result  "`v' is numeric in master"
			tostring `v', replace
		}
		append using `"`using2'"', `options'
		
	}
}
end

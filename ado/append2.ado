program define append2
version 8.2

/***************************************************************************************************
Don't forget
1. if exactmatch_exactifnm is empty, then I replace it as fuzzymatch_exactifnm
2. fuzzymatch_exactifnm must always be more easy to satisfy than exactmatch_exactifnm
2. I always add fuzzymatch_exact+fuzzmatch_exactifnm in exactmatch

Master can have duplicates for varlist
If using has duplicates for varlist, then I output an error message and remove all the links matched to u.
***************************************************************************************************/
syntax using/ 
cap append using `"`using'"'
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
		save `"`using'"', replace
		restore
		local inter: list master_numeric & using_string
		foreach v in `inter'{
			display as result  "`v' is numeric in master"
			tostring `v', replace
		}
		append using `"`using'"'
		
	}
}
end

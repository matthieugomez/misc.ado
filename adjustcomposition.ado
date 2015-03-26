program define adjustcomposition, eclass sortpreserve


	syntax varlist(max=1) [if] [in] [aweight fweight], gen(string) within(varlist) [controls(varlist numeric ts fv) ]

	/* create check */
	cap confirm new variable `gen'
	if _rc{
		display as error "`gen' already exists"
		exit
	}
	if ("`weight'"!=""){
		local wt [`weight'`exp']
		local weightvar  `=regexr("`exp'","=","")'
	}
	noi di "`weightvar'"
	/* expand controls */
	fvrevar `controls'
	local controls `r(varlist)'

	/* mark sample */
	marksample touse
	markout `touse' `controls' `absorb' `within', strok


	/* create new variable */
	tempvar newtemp
	qui gen `newtemp' = .

	tempvar temp

	/* store aggregate mean */
	sum `varlist' `wt' if `touse' == 1, meanonly
	tempname mean
	scalar `mean' = r(mean)

	qui count if `touse' == 1
	local touse_first `=_N-`=r(N)'+1'
	local touse_last `=_N'

	sort `touse' `within'
	local nwithin `: word count `within''
	if `nwithin' ~= 1 {			
		tempvar tag g
		qui by `touse' `within': gen `tag' = 1 if _n == 1 & `touse' == 1
		qui gen `g' = sum(`tag') in `touse_first'/`touse_last'
	}
	else{
		local g `within'
	}
	mata: characterize_unique_vals_sorted ("`g'", `touse_first', `touse_last', `=_N')
	tempname boundaries
	matrix `boundaries' = r(boundaries)
	local ng = r(r)
	foreach v of varlist `controls'{
		tempvar temp`v'
		tempname mean
		sum `v' `wt' in `touse_first'/`touse_last', meanonly
		gen `temp`v'' = `v' - `=r(mean)'
		local controls2 `controls2' `temp`v''
	}
	forvalues i = 1/`ng'{
		reg `varlist' `controls2' `wt' in `=`boundaries'[`i',1]'/`=`boundaries'[`i',2]'
		predict `temp' in `=`boundaries'[`i',1]'/`=`boundaries'[`i',2]', residual
		qui replace `newtemp' = `=_b[_cons]' + `temp'  in `=`boundaries'[`i',1]'/`=`boundaries'[`i',2]'
		drop `temp'
	}
	gen `gen' = `newtemp'	
end


/***************************************************************************************************
helper
***************************************************************************************************/

version 12.1
set matastrict on

mata:

	void characterize_unique_vals_sorted(string scalar var, real scalar first, real scalar last, real scalar maxuq) {
		// Inputs: a numeric variable, a starting & ending obs #, and a maximum number of unique values
		// Requires: the data to be sorted on the specified variable within the observation boundaries given
		//				(no check is made that this requirement is satisfied)
		// Returns: the number of unique values found
		//			the unique values found
		//			the observation boundaries of each unique value in the dataset


		// initialize returned results
		real scalar Nunique
		Nunique=0

		real matrix values
		values=J(maxuq,1,.)

		real matrix boundaries
		boundaries=J(maxuq,2,.)

		// initialize computations
		real scalar var_index
		var_index=st_varindex(var)

		real scalar curvalue
		real scalar prevvalue

		// perform computations
		real scalar obs
		for (obs=first; obs<=last; obs++) {
			curvalue=_st_data(obs,var_index)

			if (curvalue!=prevvalue) {
				Nunique++
				if (Nunique<=maxuq) {
					prevvalue=curvalue
					values[Nunique,1]=curvalue
					boundaries[Nunique,1]=obs
					if (Nunique>1) boundaries[Nunique-1,2]=obs-1
				}
				else {
					exit(error(134))
				}

			}
		}
		boundaries[Nunique,2]=last

		// return results
		stata("return clear")

		st_numscalar("r(r)",Nunique)
		st_matrix("r(values)",values[1..Nunique,.])
		st_matrix("r(boundaries)",boundaries[1..Nunique,.])

	}

end

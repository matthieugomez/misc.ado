/***************************************************************************************************
position
***************************************************************************************************/
program define position, rclass 
	syntax varlist [, first(string) last(string) max(string)]

	if "`first'" == ""{
		local first 1
	}
	if "`last'" == "" {
		local last `=_N'
	}
	if "`max'" == ""{
		local max `=_N'
	}
	scalar varn `: word count `varlist''
		cap confirm numeric variable `varlist'
		if _rc{
			mata: scharacterize_unique_vals_sorted("`varlist'",`first',`last', 2^16)
			tempname temp1 temp2
			mat `temp1' = r(boundaries)
			return matrix boundaries = `temp1'
			forvalues i = `=`r(r)''(-1)1{
			    return local r`i' `=r(r`i')'
			}
			return scalar r = r(r)
		}
		else{
			mata: characterize_unique_vals_sorted("`varlist'", `first', `last', 2^16)
			tempname temp1 temp2
			mat `temp1' = r(boundaries)
			mat `temp2' = r(values)
			return matrix boundaries = `temp1'
			forvalues i = `=`r(r)''(-1)1{
			    return local r`i' `=`temp2'[`i',1]'
			}
			return scalar r = r(r)
		}

end


/***************************************************************************************************
Helper function from binscatter (no change)
***************************************************************************************************/
version 12.1
set matastrict on

mata:

	void characterize_unique_vals_sorted(string scalar var, real scalar first, real scalar last, real scalar maxuq) {
		// Inputs: a numeric variable, a starting & ending obs #, and a maximum number of unique values
		// Requires: the data to be sorted on the specified variable within the observation boundaries given
		//              (no check is made that this requirement is satisfied)
		// Returns: the number of unique values found
		//          the unique values found
		//          the observation boundaries of each unique value in the dataset


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

/***************************************************************************************************

***************************************************************************************************/


version 12.1
set matastrict on

mata:
	void scharacterize_unique_vals_sorted(string scalar var, real scalar first, real scalar last, real scalar maxuq) {
		// Inputs: a string variable, a starting & ending obs #, and a maximum number of unique values
		// Requires: the data to be sorted on the specified variable within the observation boundaries given
		//             (no check is made that this requirement is satisfied)
		// Returns: the number of unique values found
		//         the unique values found
		//         the observation boundaries of each unique value in the dataset


		// initialize returned results
		real scalar Nunique
		Nunique=0

		// changes here
		string matrix values
		values=J(maxuq,1,"")

		real matrix boundaries
		boundaries=J(maxuq,2,.)

		// initialize computations
		real scalar var_index
		var_index=st_varindex(var)

		// change here
		string scalar prevvalue
		string scalar curvalue

		// perform computations
		real scalar obs
		for (obs=first; obs<=last; obs++) {
			// change here
			curvalue=_st_sdata(obs,var_index)
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
		string scalar name
		for (i=1; i <= Nunique; i++){
			name = "r(r" + strofreal(i) + ")"
			st_global(name, values[i, 1])
		}
		st_matrix("r(boundaries)",boundaries[1..Nunique,.])
	}
end




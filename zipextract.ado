program define zipextract, rclass
	syntax anything, in(string) [FILEs(string) replace]


	local from `anything'

	splitpath `from'
	local from `r(directory)'`r(filename)'.zip
	cap confirm file `"`from'"'
	if _rc{
		display as error `"file `from' could not be found"'
		exit
	}

	cap confirm file `"`in'"'
	if _rc{
		cap mkdir `in'
		if _rc{
			display as error `"directory `in' could not be created"'
			exit	
		}
	}


	tempfile tempdirectory
	local tempdirectory `tempdirectory'zip
	!rm -rf "`tempdirectory'"
	!mkdir "`tempdirectory'"
	!chmod u+rw "`tempdirectory'"
	qui ! cd "`tempdirectory'" && unzip -jo  "`from'" 
	if "`files'" == ""{
		local files "*"
	}
	local filelist : dir "`tempdirectory'" files "`files'"
	local nfiles : word count `filelist'
	if `nfiles' == 0{
		display as error `"The archive contains no files corresponding to "`files'""'
	}
	else{
		if "`replace'" == ""{
			foreach file in `filelist'{
				cap confirm new file  `in'/`file'
				if _rc{
					display as error "file `in'/`file' already exists. Use the option replace"
				}
			}
		}
		foreach file in `filelist'{
			copy `"`tempdirectory'/`file'"' `"`in'/`file'"', replace
		}
		return local files `filelist'
		foreach i of numlist `nfiles'/1{
			return local filename`i' `: word `i' of `filelist''
		}
		return local N `nfiles'
	}



end

program define zipget, rclass
	syntax anything [, files(string) output(string) replace]

	splitpath `anything'
	local anything `r(directory)'`r(filename)'.zip
	cap confirm file `"`anything'"'
	if _rc{
		display as error `"file `anything' could not be found"'
		exit
	}

	tempfile tempdirectory
	local tempdirectory `tempdirectory'zip
	!rm -rf "`tempdirectory'"
	!mkdir "`tempdirectory'"
	!chmod u+rw "`tempdirectory'"
	qui ! cd "`tempdirectory'" && unzip -jo  "`anything'" 

	if "`files'" == ""{
		local files "*"
	}
	local filelist : dir "`tempdirectory'" files "`files'"
	
	local nfiles : word count `filelist'
	if `nfiles' == 0{
		display as error `"The archive contains no files corresponding to "`files'""'
	}
	else if `nfiles' == 1 & "`output'" ~= ""{
			local filename `: word 1 of `filelist''
			copy "`tempdirectory'/`filename'" "`output'", `replace'
	}
	else{
		if "`output'" ~= ""{
			display as error `"The option `output' is specified but several files correspond to "`files'""'
			exit
		}
		return local files `filelist'
		return local filepath `tempdirectory'
		foreach i of numlist `nfiles'/1{
			local filename `: word `i' of `filelist''
			return local filename`i' `filename'
		}
		return local N `nfiles'

	}
	

end

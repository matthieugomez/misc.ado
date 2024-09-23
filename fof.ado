program define fof

	syntax anything, [clear]

	tempfile dirdownload
	!rm -rf "`dirdownload'"
	mkdir "`dirdownload'"
	tempfile dirunzip
	!rm -rf "`dirunzip'"
	mkdir "`dirunzip'"
	! wget -q  "http://www.federalreserve.gov/releases/z1/`vintage'/z1_csv_files.zip" -O "`dirdownload'/z1_csv_files.zip" && cd "`dirunzip'" && unzip  -jo "`dirdownload'/z1_csv_files.zip"
	tempfile data
	local files : dir "`dirunzip'" files `"*.csv"'
	di `"`files'"'
	local ifile = 0
	foreach file of local files {
		local ifile = `ifile' + 1
		if regexm("`file'", "(.*).csv"){
			local file = regexs(1) 
		}
		qui insheet using "`dirunzip'/`file'.txt",  clear double case
		replace v1 = subinstr(v1, ".", "", 1)
		forvalues i=1/`=_N' {
			local `=v1[`i']' = v2[`i']
		}
		qui insheet using "`dirunzip'/`file'.csv", comma clear double names case
		capture drop v* 
		capture confirm str# variable date
		if !_rc{
			gen dateq = yq(real(substr(date, 1, 4)), real(substr(date, 7, 1)))
		}
		else{
			gen dateq = yq(date, 4)
		}
		drop date
		format %tq dateq
		sort dateq
		qui destring * , ignore("ND") replace
		qui ds dateq, not
		foreach v in `r(varlist)' {
			qui label variable `v' `"``v''"'
		}
		if `ifile'>2{
			qui merge 1:1 dateq using `data', nogenerate sorted
		}
		sort dateq
		save `data', replace
	}

	use `data', clear


	local files : dir "`dirunzip'" files `"*"'
	foreach file in `files'{
		erase "`dirunzip'/`file'"
	}
	rmdir "`dirunzip'"

	local files : dir "`dirdownload'" files `"*"'
	foreach file in `files'{
		erase "`dirdownload'/`file'"
	}
	rmdir "`dirdownload'"

	order dateq
end

*fof  20170921, clear



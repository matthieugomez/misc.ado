program define zipuse
	syntax anything [using] [if] [in][, clear replace ram *]

	confirm file `anything'
	qui memory
	if  r(data_data_u) ~= 0 & "`clear'"=="" & "`replace'"==""{
		display as error "no; data in memory would be lost"
		exit 4
	}

	if `"`using'"'~=""{
		local vlist `anything'  using
		if regexm(`"`using'"',`"using (.*)"'){
			local file=regexs(1)
		}
	}
	else{
		local file `anything'
	}

	splitpath `file'
	local directory `r(directory)'
	local filename `r(filename)'
	local filetype `r(filetype)'


	if "`ram'"~=""{
		qui memory
		local sizem=`r(data_data_u)'/1000000
		local ramsize = 2048*ceil(`sizem')
		qui !hdiutil eject /Volumes/stataramdisk
		qui !diskutil erasevolume HFS+ "stataramdisk" `hdiutil attach -nomount ram://`ramsize'`
		*''
		local tempdirectory "/Volumes/stataramdisk/"
	}
	else{
		tempfile tempfile
		splitpath `tempfile'
		local tempdirectory `r(directory)'
	}

	!unar -f  "`directory'/`filename'.zip" -o "`tempdirectory'" &&
	cap qui use `vlist' "`tempdirectory'`filename'" `if' `in',`options' `clear' `replace'
	while _rc {      /* file does not exist! */
	!unar -f  "`directory'/`filename'.zip" -o "`tempdirectory'" &&
	di `"`vlist' "`tempdirectory'`filename'" `if' `in',`options' `clear' `replace'"'
	cap qui use `vlist' "`tempdirectory'`filename'" `if' `in',`options' `clear' `replace'
	}


if "`ram'"~=""{
	qui !umount `tempdirectory'
	qui !hdiutil eject "`tempdirectory'"
}

end

program define zipsave
syntax anything [, replace ram *]

splitpath `anything'
local directory `r(directory)'
local filename `r(filename)'
local filetype `r(filetype)'


local files : dir "`directory'" files `"`filename'.zip"'
if "`files'"~="" & "`replace'"==""  {
	display as error "file `anything' already exists"
	exit 602
}

tempfile temp
splitpath `temp'
local tempdirectory `r(directory)'

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
	tempfile temp
	splitpath `temp'
	local tempdirectory `r(directory)'
}

qui !rm "`directory'/`filename'.zip" 
qui save "`tempdirectory'`filename'.dta", replace
qui !cd "`tempdirectory'" && zip -o "`directory'`filename'.zip" "`filename'.dta" && rm "`filename'.dta" 


qui !rm -r `tempdirectory'
if "`ram'"~=""{
	qui !umount `tempdirectory'
	qui !hdiutil eject `tempdirectory'
}

end

program define gzipsave
syntax anything [if] [in] [, replace clear Compression(integer 6) *]


local file `anything'
local file: list clean file
if regexm(`"`file'"',`"^(.+)/([^/\.]+)(.*)$"'){
	local directory=regexs(1)
	local filename=regexs(2)
	local filetype=regexs(3)
}
else{
	if regexm(`"`file'"',`"([^/\.]+)(.*)$"'){
		local directory `c(pwd)'
		local filename=regexs(1) 
		local filetype=regexs(2)
	}
}
local files : dir "`directory'" files `"`filename'.zip"'
if "`files'"~="" & "`replace'"=="" & "`clear'"=="" {
	display as error "file `anything' already exists"
	exit 602
}
*cap local allfiles: dir "/Volumes/RAMDisk" files *
*if _rc~=0{


/*  
qui memory
local sizem=`r(data_data_u)'/1000000
if `sizem'>20{
	local ramsize=2048*`sizem'
	qui !osascript  -e 'tell application "Finder" to eject (every disk whose name starts with "ram")'
	qui !hdiutil eject /Volumes/ramdisk*

	qui !diskutil erasevolume HFS+ "ramdisk" `hdiutil attach -nomount ram://`ramsize'`
	*''
	local tempdirectory "/Volumes/ramdisk 1/"
}
else{
	tempfile temp
	if regexm(`"`temp'"',`"^(.+)/([^/\.]+)(.*)$"'){
		local tempdirectory=regexs(1)
	}
}
*else{
*	!rm -r /Volumes/RAMDisk
*	local tempdirectory /Volumes/RAMDisk/
*}
	*/


tempfile temp
if regexm(`"`temp'"',`"^(.+)/([^/\.]+)(.*)$"'){
	local tempdirectory=regexs(1)+"/"
	local tempname=regexs(2)
}	

if "`replace'"~=""{
	qui !rm -f "`directory'/`filename'.gz" 
}

qui save "`tempdirectory'`filename'.dta", replace
qui !cd "`tempdirectory'"  &&  pigz -c -`compression' -p4  "`filename'.dta" > "`directory'/`filename'.dta.gz" && rm "`file'" 

/*  
if `sizem'>20{
	!cd "`tempdirectory'" && zip -o "`directory'/`filename'.zip" "`filename'.dta" && osascript  -e 'tell application "Finder" to eject (every disk whose name starts with "ram")'
}
else{
	!cd "`tempdirectory'" && zip -o "`directory'/`filename'.zip" "`filename'.dta" && rm "`tempdirectory'`filename'.dta" 
}
*/
end


/***************************************************************************************************
clown 644 remet les bonnes permissions
***************************************************************************************************/
cap program drop unzip
program define unzipto
syntax anything, to(string)

if regexm(`"`anything'"',`""(.*)""'){
	local anything=regexs(1)
}

if regexm(`"`to'"',`""(.*)""'){
	local to=regexs(1)
}

tempfile file
splitpath `file'
local directory `r(directory)'
local filename `r(filename)'
local filetype `r(filetype)'


!unar -f "`anything'"  -o "`directory'`filename'"
local files : dir "`directory'`filename'" files `"*"'
foreach file in `files'{
	! mv "`directory'`filename'/`files'" "`to'"
}
end

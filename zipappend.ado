program define zipappend
syntax  using, *

if regexm(`"`using'"',`"using (.*)"'){
	local file=regexs(1)
}

splitpath `file'
local directory `r(directory)'
local filename `r(filename)'
local filetype `r(filetype)'

tempfile temp
splitpath `temp'
local tempdirectory `r(directory)'


qui !unar -f  "`directory'/`filename'.zip" -o "`tempdirectory'"
append using "`tempdirectory'`filename'",`options'
qui !rm -r "`tempdirectory'`filename'.dta"
end


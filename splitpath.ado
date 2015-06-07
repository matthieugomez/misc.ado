program define splitpath, rclass
syntax anything

local file `0'
local file: list clean file

if regexm(`"`file'"',`"^(.+)/([^/\.]+)(.*)$"'){
	local directory = regexs(1)
	local filename = regexs(2)
	local filetype= regexs(3)
}
else if regexm(`"`file'"',`"^/*([^/\.]+)(.*)$"'){
	* /filename are understod as c(pwd)
		local directory `c(pwd)'
		local filename = regexs(1) 
		local filetype = regexs(2)
}

return local filetype `filetype'
return local filename `filename'
return local directory `directory'/
end

/***************************************************************************************************
basically:
!unar -f  "$DataPath/compustat/bank/bank_fundq.zip"  -o "$SavePath"
use "$SavePath/bank_fundq", clear 
erase "$SavePath/bank_fundq.dta"
***************************************************************************************************/
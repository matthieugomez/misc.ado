program define gzipuse
syntax anything [using] [if] [in][, clear replace * pipe]

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
	local file:list clean file
}
else{
	local file `anything'
}
if regexm(`"`file'"',`""(.*)""'){
	local file=regexs(1)
}

if regexm(`"`file'"',`"^(.+)/([^/\.]+)(.*)$"'){
	local directory=regexs(1)
	local filename=regexs(2)
}
else{
	if regexm(`"`file'"',`"([^/\.]+)(.*)$"'){
		local directory `c(pwd)'
		local filename=regexs(1) 
	}
}

local directory: list clean directory
local filename: list clean filename
local file: list clean file

if "`pipe'"~=""{
	tempfile tempfile myscript
	local tempfile "/Users/Matthieu/tempfile.dta"
	! rm `tempfile'
	cap file close myscript
	qui file open myscript using "`myscript'", write replace
	file write myscript  `"mkfifo `tempfile'"' _n `"unpigz -p4 -c "`directory'/`filename'.dta.gz" > "`tempfile'" &"'
	file close myscript
	! chmod 755 `myscript'
	! `myscript' > /dev/null 2>&1  
	qui use  `vlist' "`tempfile'" `if' `in', `options' `clear' `replace'
	global S_FN = "`filename'.dta"
}
else{
	tempfile tempfile
	qui ! unpigz -p4 -c "`directory'/`filename'.dta.gz" >  "`tempfile'.dta"
	qui use `vlist' "`tempfile'.dta" `if' `in',`options' `clear' `replace'
	qui !rm -r "`temp'"
	global S_FN = "`filename'.dta"
}
end

/***************************************************************************************************
basically:
!unar -f  "$DataPath/compustat/bank/bank_fundq.zip"  -o "$SavePath"
use "$SavePath/bank_fundq", clear 
erase "$SavePath/bank_fundq.dta"
***************************************************************************************************/
program define TexSummary
syntax anything(name=filepath) [, cname(string) cformat(string) stats(string) rlist(string) rname(string) title(string) notes(string)]


tempfile stat
cap postclose tempstat

local i = 0

if `"`rname'"' == ""{
	foreach v of local rlist{
		local rname `"`rname' "`:var label `v''""'
	}
}

foreach v in `cname' {
	local i = `i' + 1
	local clist `clist' v`i' 
}
postfile tempstat str90 v0 `clist' using `stat', replace

tokenize `stats'
foreach v of local rname{
	local post (`"`v'"')
	foreach name in `clist' {
		local post `post' (`1')
		macro shift
	}
	post tempstat `post'
}


foreach v of local cformat{
	local format_si `format_si'S[table.format=`v']
}

postclose tempstat
preserve
use `stat', clear
local firstrow ""
local n : word count `rlist'
foreach v of local cname{
	local firstrow `"`firstrow' & \multicolumn{1}{L}{`v'}"'
}
foreach v of local clist{
	* i would like to use 3 digits unless inger. Issue as no difference beween 0 and 0.001
	replace `v'=int(`v') if abs(`v')>99
	replace `v'=int(`v'*10)/10  if abs(`v')>9 
	replace `v'=int(`v'*100)/100  if abs(`v')>0.01
	replace `v'=int(`v'*1000)/1000  
	format `v' %12.3g
}
replace v0 = subinstr(v0,"%","$\%$",.)
replace v0 = subinstr(v0,"_","-",.)
local filename summary

listtab v0 `clist'  using `filepath', rstyle(tabular) replace  head("\begin{table}[htb]\scriptsize\centering \caption{`title'}" "%<*tag>" " \sisetup{group-digits=true,group-separator={,}}\def\sym X 1{\ifmmode^{ X 1}\else\(^{ X 1}\)\fi}" "\label{tab:`filename'}" "\begin{tabularx}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l`format_si'}" "\cmidrule{1-`=`n'+1'}\morecmidrules\cmidrule{1-`=`n'+1'}" "Variables `firstrow' \\" "\cmidrule{2-`=`n'+1'}")  foot("\cmidrule{1-`=`n'+1'}\morecmidrules\cmidrule{1-`=`n'+1'}" "%</tag>" "\multicolumn{`=`n'+1'}{l}{\begin{minipage}{\hsize} \rule{0pt}{9pt} \scriptsize `notes'  \end{minipage}}\\"  "\end{tabularx}"  "\end{table}")
restore
end

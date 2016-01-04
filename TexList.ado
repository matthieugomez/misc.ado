program define TexList
	syntax anything(name=filepath) , [sifmt(real 3.3) cname(string) title(string) ctitle(string) note(string) ]

	qui ds *
	local varlist = r(varlist)
	tokenize `varlist'
	local firstvar `1'
	macro shift
	local varlist `*'

	local n_C : word count `varlist' 

	local groups2 ""
	local rules2 ""
	local iter=2
	tokenize `"`cname'"'
	while "`1'"~=""{
		local y `1'
		local iter2=0
		while trim("`1'")==trim("`y'"){
			local iter2=`iter2'+1
			macro shift
		}
		local groups2 `"`groups2'  & \multicolumn{`iter2'}{c}{`y'}"'
		local rules2 `"`rules2'  \cmidrule(l{.75em}){`iter'-`=`iter'+`iter2'-1'}"'
		local iter=`iter'+`iter2'
	}
	if "`groups2'"~=""{
		local groups2 `"`groups2' \\ `rules2'"'
	}
	if "`ctitle'" == ""{
		local group `"\cmidrule(l{.75em}){2-`=`n_C'+1'}"'
	}
	else{
		local groups `"& \multicolumn{`n_C'}{c}{`ctitle'} \\ \cmidrule(l{.75em}){2-`=`n_C'+1'} "'
	}




	local i = 0
	foreach v of varlist `varlist'{
		local i = `i' + 1
		local firstrow `"`firstrow' & \multicolumn{1}{L}{(`i')}"'
	}
	local firstrow `"`firstrow' \\"'


	listtab `firstvar' `varlist'  using `filepath', rstyle(tabular) replace  head("\begin{table}[htb]\scriptsize\centering \caption{`title'}" "%<*tag>" " \sisetup{group-digits=true,table-format=`sifmt'}\def\sym X 1{\ifmmode^{ X 1}\else\(^{ X 1}\)\fi}" "\label{tab:`filename'}" "\begin{tabularx}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{`n_C'}{S}}" "\cmidrule{1-`=`n_C'+1'}\morecmidrules\cmidrule{1-`=`n_C'+1'}" "`groups'`groups2' `firstrow'" "\cmidrule{2-`=`n_C'+1'} ")  foot("\cmidrule{1-`=`n_C'+1'}\morecmidrules\cmidrule{1-`=`n_C'+1'}" "%</tag>" "\multicolumn{`=`n_C'+1'}{l}{\begin{minipage}{\hsize} \rule{0pt}{9pt} \scriptsize `note'  \end{minipage}}\\"  "\end{tabularx}"  "\end{table}")

end

program define name_or_label, rclass
	syntax varlist(min = 1 max = 1)
	local name  `: var label `varlist''
	if `"`name'"' == ""{
		local name `varlist'
	}
	return local lab `name'
end

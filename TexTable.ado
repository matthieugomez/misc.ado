	/*****************************************************************************************************

-	To drop a statistics for one result and not the other
	qui estadd local r2="", replace

-	To drop a regressor for one result and not the other
	cap drop return1
	gen retun1=return
	reg y return1


-	To merge different coefficients into the same table row
	esttab, rename(altmpg mpg)

- 	To add yes / no
	qui estadd local FE_xyear "Yes"



	*****************************************************************************************************/
	program define TexTable
	syntax anything(name=filepath)[,  title(string) ctitle(string) clist(string) cname(string) rlist(string) rname(string) stats(string) statsfmt(string)  statslabel(string) nostat(string) note(string) sifmt(real 3.3) position(string) replace *]

	splitpath `filepath'
	local filepath `r(directory)'`r(filename)'.tex
	cap confirm new file `"`filepath'"'
	if _rc ~= 0 & "`replace'" == ""{
			di as error `"file `filepath' already exists"'
			exit 602
	}

	qui estimates dir `clist'
	local n_C: word count `r(names)'
	if "`position'"==""{
		local position hp
	}
	local filepath: list clean filepath
	if regexm(`"`filepath'"',`"^(.+)/([^/\.]+)(.*)$"'){
		local directory=regexs(1)
		local filename=regexs(2)
	}
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
		local groups2 `"`groups2'  & \multicolumn{`iter2'}{mainc}{`y'}"'
		local rules2 `"`rules2'  \cmidrule(l{.75em}){`iter'-`=`iter'+`iter2'-1'}"'
		local iter=`iter'+`iter2'
	}
	if "`groups2'"~=""{
		local groups2 `"`groups2' \\ `rules2'"'
	}
	local groups `"& \multicolumn{`n_C'}{mainc}{`ctitle'} \\ \cmidrule(l{.75em}){2-`=`n_C'+1'} "'
	local sifmt `sifmt'
	if regexm("`sifmt'",".*\.([0-9])"){
		local stata=regexs(1) 
	}
	local format_stata %9.`stata'f

	if "`nostat'"~=""{
		local stats "`stats' N "
		local statsnum: word count `stats'
		local statslayout ""
		forvalues l = 1/`statsnum' {
			local statslayout `" `statslayout' "\multicolumn{1}{c}{@}" "'
		}
		local statsfmt " `statsfmt' %9.0fc "
		local statslabel `" `statslabel' "Observations" "'
	}
	else{
		local stats "r2 `stats' N "
		local statsnum: word count `stats'
		local statslayout ""
		forvalues l = 1/`statsnum' {
			local statslayout `" `statslayout' "\multicolumn{1}{c}{@}" "'
		}
		local statsfmt " %9.3f `statsfmt' %9.0fc "
		local statslabel `" "LatexMath R^2 LatexMath"  `statslabel' "Observations" "'
	}


	esttab `clist' using `"`filepath'"', replace /// 
	cells(b(fmt(`format_stata') star) se(fmt(`format_stata') par)) starlevels(\$^{+}$ 0.1 \$^{*}$ 0.05 \$^{**}$ 0.01) ///
	keep(`rlist') ///
	order(`rlist') /// 
	label varlabels(`rname')  ///
	collabels(,none) numbers nomtitles ///
	stats(`stats', layout(`statslayout') fmt(`statsfmt') labels(`statslabel')) ///
	prehead( "\begin{table}[`position']\scriptsize\centering \caption{`title'}" "%<*tag>" "\sisetup{group-digits=true,table-format=`sifmt'} \def\sym X 1{\ifmmode^{ X 1}\else\(^{ X 1}\)\fi}"   "\label{tab:`filename'}" "\begin{tabularx}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{`n_C'}{S}}" "\cmidrule{1-`=`n_C'+1'}\morecmidrules\cmidrule{1-`=`n_C'+1'}  " "`groups'`groups2'") posthead(`"\cmidrule{1-`=`n_C'+1'}"') ///
	postfoot("\hline\morecmidrules\hline" "%</tag>" "\multicolumn{@span}{l}{\begin{minipage}{\hsize} \rule{0pt}{9pt} \footnotesize `note' \end{minipage}}\\"  "\end{tabularx}"  "\end{table}") /// 
	substitute(" LatexMath" "\$" "LatexMath" "\$"  {c} {L} {mainc} {c} \hline \cmidrule{1-`=`n_C'+1'}) `options'

	eststo clear
	estimates clear



	end

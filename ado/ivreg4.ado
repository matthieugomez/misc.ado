

***************************************************************************************************/
program define ivreg4, eclass
syntax [anything(name=0)] [if] [in] [aweight/], [Absorb(string) CLuster(varlist) NOCONStant adj print rcommand(string) demean fe core(int 1) save(string) using(string)]


/*****************************************************************************************************
Split anything in dependent, exogenous, endogenous, instruments (from ivreg2)
*****************************************************************************************************/

if "`fe'"~=""{
	foreach a in `absorb'{
		cap confirm string variable `a'
		if _rc==0{
			qui count if real(`a')==. & !missing(`a')
			if r(N)==0{
				display "Transform fixed effect to int - otherwise R will read it as an int" as error
				exit
			}
		}
	}
}

/***************************************************************************************************
Read syntax
***************************************************************************************************/
local n 0
gettoken lhs 0 : 0, parse(" ,[") match(paren)
IsStop `lhs'
if `s(stop)' { 
	error 198 
}
while `s(stop)'==0 { 
	if "`paren'"=="(" {
		local n = `n' + 1
		if `n'>1 { 
capture noi error 198
di in red `"syntax is "(all instrumented variables = instrument variables)""'
exit 198
		}
		gettoken p lhs : lhs, parse(" =")
		while "`p'"!="=" {
			if "`p'"=="" {
capture noi error 198 
di in red `"syntax is "(all instrumented variables = instrument variables)""'
di in red `"the equal sign "=" is required"'
exit 198 
			}
			local endo `endo' `p'
			gettoken p lhs : lhs, parse(" =")
		}
* To enable Cragg HOLS estimator, allow for empty endo list
		local temp_ct  : word count `endo'
		if `temp_ct' > 0 {
			tsunab endo : `endo'
		}
* To enable OLS estimator with (=) syntax, allow for empty exexog list
		local temp_ct  : word count `lhs'
		if `temp_ct' > 0 {
			tsunab exexog : `lhs'
		}
	}
	else {
		local inexog `inexog' `lhs'
	}
	gettoken lhs 0 : 0, parse(" ,[") match(paren)
	IsStop `lhs'
}
local 0 `"`lhs' `0'"'

tsunab inexog : `inexog'
tokenize `inexog'
local lhs "`1'"
local 1 " " 
local inexog `*'


/* Develop varlist in absorb */
local absorb_old `absorb'
local absorb ""
foreach name in `absorb_old'{
	if regexm("`name'","^(.*):(.*)$"){
		qui ds `=regexs(1)'
		foreach v in `r(varlist)'{
			local absorb `absorb' `v':`=regexs(2)' 
		}
	}
	else{
		qui ds `name'
		local absorb `absorb' `r(varlist)'
	}
}


/* Read the syntax of interacted fixed effect */
foreach name in `absorb'{
	if regexm("`name'","^(.*):(.*)$"){
		local absorb_interacted `absorb_interacted' `=regexs(1)'
		local absorb_fe  `absorb_fe'  `=regexs(2)' 
	}
	else{
		local absorb_fe `absorb_fe' `name'
	}
}



cap tsunab inexog : `inexog'
cap tsunab endo : `endo'
local endo: list endo-absorb_interacted
cap tsunab exexog : `exexog'
cap tsunab cluster : `cluster'


/* read the time-series data except in absorb */
foreach name in lhs inexog endo exexog{
	tsrevar ``name''
	local vlist "`r(varlist)'"
	local `name': subinstr local `name' "." "____", all
	tokenize ``name''
	foreach v in `vlist'{
		qui rename `v' `1'
		macro shift
	} 
}

/* error if _dm exist and option demean */
if "`demean'"~=""{
	cap confirm `"`endo'`exoxog'"'==""
	if _rc~=0{
		display as error "Only varlist is supported with the option demean"
		errror 198
	}
	foreach v in `lhs' `inexog' {
		confirm new variable `v'_dm
	}
}

/* error if _fe _comp _n exist and option fe */
if "`fe'"~=""{
	foreach v in `absorb'{
		local v=regexr("`v'",":","_")
		confirm new variable `v'_fe
		confirm new variable `v'_n
		confirm new variable `v'_comp
	}
}



marksample touse
markout `touse' `lhs' `inexog' `exexog' `endo' `absorb_interacted' `absorb_fe' `cluster' `exp', strok
tempvar id
qui gen `id'=_n if `touse'==1



/* Weight. just replace every interacted by sqrt. also replace non intereacted fixed effect */
if "`exp'"~=""{
	assert `exp'>=0
	assert `exp'<.
	local absorb_weight ""
	foreach name in `absorb'{
		if regexm("`name'","^(.*):(.*)$"){
			local absorb_weight `absorb_weight' `name'
		}
		else{
			local absorb_weight `absorb_weight' `exp':`name'
		}
	}
}
else{
	local absorb_weight `absorb'
}


/***************************************************************************************************
Store a local with potential cluster adjustment to lfe errors

tokenize `0'
local 1 " " 
local order `*'
local order: subinstr local order "(" " ",all
local order: subinstr local order ")" " ",all
local order: subinstr local order "=" " ",all
tsunab order: `order'

***************************************************************************************************/
local count_adj=0
if "`adj'"~=""{
	foreach a in `absorb'{
		if regexm("`a'",":"){
			continue
		}
		else{
			foreach c in `cluster'{
				local adjust
				tokenize `cluster'
				while "adjust"=="" & "`1'"~="" {
					tempvar ic_ct
					sort `touse' `absorb' `c' 
					qui by `touse' `absorb' `c' : gen long `ic_ct' = 1 if _n==_N 
					sort `touse' `absorb' 
					qui by `touse' `absorb' : replace `ic_ct'=sum(`ic_ct') 
					qui count if `ic_ct' > 1 & `ic_ct' < .
					if r(N)>1 & r(N)<. {
						local adjust dontadjust
					}
				macro shift
				}
			}
			if "adjust"==""{
				qui distinct `a' if `touse'==1
				local count_adj=`count_adj'+r(ndistinct)-1
			}
		}
	}
}

/*****************************************************************************************************
Transform Stata syntax in R syntax
*****************************************************************************************************/

foreach name in inexog exexog cluster {
	local `name'R: subinstr local `name' " " "+",all
	if "``name'R'"==""{
		if "`name'"=="inexog"{
			if "`noconstant'"~=""{
				local `name'R 0
			}
			else if "`exp'"~=""{
				local `name'R 0+`exp'
			}
			else{
				local `name'R 1
			}
		}
		else{
			local `name'R 0
		}
	}
}

local absorbR: subinstr local absorb_weight " " "+",all
if "`absorbR'"==""{
	local absorbR 0
}


if "`exp'"~=""{
	foreach name of varlist `lhs' `inexog' `endo' `exexog' `absorb_interacted'{
		local factorization `"`factorization' `"mydata[, "`name'"] <- sqrt(`exp')*mydata[, "`name'"])"' _n "' 
	}
}

foreach name in `absorb_interacted' `exp'{
		local factorization `"`factorization'	`"mydata[, "`name'"] <- as.numeric(mydata[, "`name'"])"' _n "' 
}

local absorb_fe: list uniq absorb_fe
foreach name in `absorb_fe'{
		local factorization `"`factorization'	`"mydata[, "`name'"] <- as.factor(mydata[, "`name'"])"' _n "' 
}


local endoR: subinstr local endo " " "|", all
*'"

if "`endoR'"~=""{
	local model felm(`lhs'~ `inexogR'|`absorbR'|(`endoR'~`exexogR')|`clusterR',mydata)
}
else{
	local model felm(`lhs'~ `inexogR'|`absorbR'|0|`clusterR',mydata)
}
if "`cluster'"==""{
	local vcv vcv
}
else{
	local vcv clustervcv
}


if "`demean'"~=""{
	local variablelist ""
	local factorlist ""
	local factorization ""
	foreach name in `lhs' `inexog' `absorb_weight_interacted'{
		local factorization `"`factorization'	`"`name' <- as.numeric(mydata[, "`name'"])"' _n "' 
		local variablelist `variablelist',`name'
	}
	foreach name in `absorb_fe'{
		local factorization `"`factorization'	`"`name' <- as.factor(mydata[, "`name'"])"' _n "' 
		local factorlist `factorlist',`name'
	}
	local variablelist=regexr("`variablelist'",",","")
	local factorlist=regexr("`factorlist'",",","")
	local model demeanlist(cbind(`variablelist'),list(`factorlist'))
}
/*****************************************************************************************************
Execute the Regression in R
*****************************************************************************************************/
qui tempfile Rinput Routput Rsource  fecsv
tempname rcode routput
if "`save'"~=""{
	local Rinput=subinstr(`"`save'"',".csv","")
}
else if "`using'"~=""{
	local Rinput=subinstr(`"`save'"',".csv","")
}
if "`using'"==""{
	qui export delimited  `id' `lhs' `inexog' `exexog' `endo' `absorb_interacted' `absorb_fe' `cluster' `exp' using `Rinput'.csv if `touse'==1, replace  nolabel   
}
cap qui erase "`Routput'"
cap qui erase "`fecsv'.csv"
cap file close `rcode'
qui file open `rcode' using `Rsource', write replace
file write `rcode' ///
`"library(data.table)"' _n ///
`"library(lfe)"' _n ///
`"options(lfe.threads=`core')"' _n ///
`"mydata=fread("`Rinput'.csv")"' _n ///
`"setDF(mydata)"'_n ///
`factorization' 
if "`demean'"==""{
	file write `rcode' ///
	`"a=`model'"' _n ///
	`"b=summary(a)"' _n ///
	`"v =a\$vcv"'_n ///
	`"x=suppressWarnings(cbind(b\$r2,b\$N,b\$df, b\$p,a\$coefficients, v))"'_n ///
	`"colnames(x)[colnames(x) =="(Intercept)"] <- "intercept" "'_n ///
	`"colnames(x)[colnames(x) =="Intercept"] <- "intercept" "'_n ///
	`"colnames(x)=gsub(""' "\`" `"","",colnames(x),fixed=TRUE)"'_n ///
	`"colnames(x)=gsub("(fit)","",colnames(x),fixed=TRUE)"'_n ///
	`"rownames(x)[rownames(x) =="(Intercept)"] <- "intercept" "'_n ///
	`"rownames(x)[rownames(x) =="Intercept"] <- "intercept" "'_n ///
	`"rownames(x)=gsub(""' "\`" `"","",rownames(x),fixed=TRUE)"'_n ///
	`"rownames(x)=gsub("(fit)","",rownames(x),fixed=TRUE)"'_n ///
	`"write.csv("`Routput'",x=x,na="0")"' _n 
	*`"file.symlink(from=t,to="`Routput'")"' _n
	if "`fe'"~=""{
		file write `rcode' ///
		`"output_fe=getfe(a)"'_n ///
		`"write.csv("`fecsv'.csv",x=output_fe,na="")"' _n 
	}
}
else if "`demean"~=""{
	file write `rcode' ///
	`"x=`model'"' _n ///
	`"write.csv("`Routput'",x=x,na="0")"' _n 
}
if "`print'"~="" {
	if "`fe'"~=""{
		file write `rcode' ///
		`"head(output_fe)"' _n ///
		`"tail(output_fe)"' _n
	}
}
* add a line otherwise R quites without writing the whole csv
file write `rcode' `"print("the end")"'
file close `rcode'

*shell osascript -e 'tell app "R" to cmd "source(\"Rcode.R\")" ' 
*qui shell osascript -e 'set fileContents to do shell script "cat \"`Rsource'\""' -e 'tell app "Terminal" to do script fileContents in front window'

if "`rcommand'"==""{
	local rcommand = cond(c(os) == "Windows", "Rterm.exe", "R --vanilla")
}
if "`print'"~=""{
  !`rcommand' <`Rsource' 2>&1 && cd ""
}
*shell osascript -e 'tell app "R" to cmd "source(\"`Rsource'\", echo=TRUE,print.eval=TRUE)" ' 
 qui !`rcommand' <`Rsource' 2>&1 && cd ""

/*****************************************************************************************************
Clean CSV and output results
*****************************************************************************************************/

if "`demean'"==""{

	tempname r2 N df_r df_m p
	cap file close `routput'
	file open `routput' using "`Routput'", read
	*"
	local linenum 0
	file read `routput' line
	 while r(eof)==0 {
	  local linenum = `linenum' + 1
	  scalar count = `linenum'
	  local o`linenum'  `"`line'"'
	  local no  `linenum'
	  file read `routput' line
	 }
	 foreach i of numlist 2/`linenum'{
	 	if regexm(`"`o`i''"',`"([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),(.*)"'){
	 		scalar `r2'=regexs(2)
	 		scalar `N'=regexs(3)
	 		scalar `df_r'=regexs(4)
	 		scalar `p'=regexs(5)
	 		local b `b' `=regexs(6)'
	 		local rest=regexs(7)
	 		while `"`rest'"'~=`""'{
	 			if regexm(`"`rest'"',`"([^,]*),(.*)"'){
	 				local V `V'`=regexs(1)',
	 				local rest `=regexs(2)'
	 			}
	 			else{
	 				local V `V' `rest'
	 				if `i'~=`linenum'{
	 					local V `V' \\
	 				}
	 				local rest ""
	 			}
	 		}
	 	}
	 }
	scalar `df_m'=max(`=`p''-1,1)

	local b=subinstr(`"`b'"'," ",",",.)
	mat b=(`b')


	mat V=(`V')

	local o1=subinstr(`"`o1'"',`""","","',"",.)
	local o1=subinstr(`"`o1'"',","," ",.)
	local colnames=subinstr(`"`o1'"',`"""',"",.)

	local colnames1: subinstr local colnames "intercept" "_cons", all
	local colnames1: subinstr local colnames1 "____" ".", all
	local lhs1: subinstr local lhs "____" ".", all


	 matrix rownames V=`colnames1'
	 matrix colnames b=`colnames1'
	 matrix colnames V=`colnames1'
	
	/*********************************************************************************************
	Adjustment of lmfe errors -  http://www.kellogg.northwestern.edu/faculty/matsa/htm/fe.htm.
	**********************************************************************************************/
	if `count_adj'~=0{
			matrix V=(`N'-`df_m')/(`N'-(max(`df_m'-`count_adj',0)))*V
	}
	if "`print'"~=""{
		list *
	}
	/************************************************************************************************	
	Finish
	***********************************************************************************************/
	ereturn post b V, obs(`=`N'') depname("`lhs1'") esample(`touse')
	ereturn scalar N=`=`N''
	ereturn scalar r2=`=`r2''
	ereturn scalar df_m=`=`df_m''
	ereturn scalar df_r=`=`df_r''
	ereturn local cmd "ivreg4"
	ereturn display
	display as text "{lalign 26:R-squared = }" in ye %10.4f `=`r2''
	display as text "{lalign 26:Number of obs = }" in ye %10.0fc `=`N''
	if "`=`df_m''"~=""{
		display as text "{lalign 26:Number of effective obs = }" in ye %10.0fc `=`df_r''
		display as text "{lalign 26:Number of groups = }" in ye %10.0fc `=`df_m''
	}

	if "`fe'"~=""{
		preserve
		foreach a in `absorb_weight'{
			insheet using "`fecsv'.csv", clear case
			noi ds *
			cap drop fe 
			cap drop idx
			gen fe=regexs(1)  if regexm(v1,"^(.*)\.([0-9]*)$")
			gen idx=regexs(2) if regexm(v1,"^(.*)\.([0-9]*)$")
			destring idx, replace
			/* case of interacted */
			if regexm("`a'","(.*):(.*)"){
				local a1=regexs(1) 
				local a2=regexs(2)
				keep if fe=="`a1':`a2'" | fe=="`a2':`a1'"
				if "`exp'"~=""{
					local a=regexr("`a'","`exp':","")
				}
			}
			else{
				keep if fe=="`a'"
				rename obs `a'_n
				rename comp `a'_comp
			}
			
			local match=regexr("`a'",".*:","")
			local a=regexr("`a'",":","_")
			rename idx `match'
			rename effect `a'_fe
			keep `match' `a'_*
			tempfile temp`a'
			save `temp`a'', replace
		}
		restore
		foreach a in `absorb'{
			local match=regexr("`a'",".*:","")
			local a=regexr("`a'",":","_")
			qui merge m:1 `match' using `temp`a'', nogen
			foreach v of varlist `a'_*{
				qui replace `v'=. if e(sample)~=1
			}
		}
	}
}
else if "`demean'"~=""{
	rename v1 `id'
	local i=0
	foreach v in `lhs' `inexog'{
		local i=`i'+1
		rename V`i' `v'_dm
	}
	keep `id' *_dm
	tempfile temp
	save `temp', replace
	restore
	qui merge m:1 `id' using `temp', nogen keep(master match)
}
end

/***************************************************************************************************
Program
***************************************************************************************************/

program define IsStop, sclass
				/* sic, must do tests one-at-a-time, 
				 * 0, may be very large */
	version 8.2
	if `"`0'"' == "[" {		
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
* per official ivreg 5.1.3
	if substr(`"`0'"',1,3) == "if(" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else	sret local stop 0
end


/* test
discard
clear all
set obs 1000
gen a = _n
gen b = runiform
gen fe = floor(_n/10)
areg a b, a(fe)
ivreg4 a b, a(fe)
 */


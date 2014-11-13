program define egensort
syntax [anything(equalok)] [aweight/] [if] [in], [*]

if regexm(" `anything'","^(double|float|byte|long| )*([^\=]+)\=([^\(]*)\((.*)\)$"){
	cap local type `=regexs(1)'
	local gen `=regexs(2)'
	local function `=regexs(3)'
	local varlist `=regexs(4)'
}
else{
	display as error "Syntax issue"
	exit 4
}
if "`weight'"~=""{
	local weight [`weight'=`exp']
}

`function'2 `varlist'  `weight' `if' `in',  gen(`gen') `type'  `options'

end

/***************************************************************************************************
sum
***************************************************************************************************/
cap program drop sum2
program define sum2
syntax anything(equalok) [if] [in],  gen(name)  [by(varlist) Missing type]
quietly {
	tempvar temp v touse 
	confirm new variable `gen' 
	gen `v'=`anything'
	mark `touse' `if' `in'
	if "`missing'"~="" { 
	    markout `touse' `varlist', strok
	}
   	sort `by' `touse' 
   	by `by' `touse' : gen  `type' `temp'=sum(`v')
   	by `by' `touse': gen  `type' `gen'=`temp'[_N] if `touse'
}
end 

/***************************************************************************************************
mean
***************************************************************************************************/
cap program drop mean2
program define mean2
syntax anything(equalok)  [aweight/] [if] [in],  gen(name) [by(varlist) Missing type]
quietly {
	tempvar temp v count touse  weight
	confirm new variable `gen' 
	if "`exp'"==""{
		gen byte `weight'=1
	}
	else{
		gen `weight'=`exp'* !missing(`weight') * !missing(`v')
	}
	gen `v'=`anything'
  	mark `touse' `if' `in'
  	if "`missing'"~="" { 
  	    markout `touse' `varlist', strok
  	    replace `touse'=0 if `weight'==0
  	}
    sort `by' `touse' 
   	by `by' `touse' : gen `type'`temp'=sum(`v'*`weight')
   	by `by' `touse' : gen `type'`count'=sum(`weight')
   	by `by' `touse': gen `type' `gen'=`temp'[_N]/`count'[_N] if `touse'
   	replace `gen'=0 if  missing(`gen') & `touse'
}
end 


/***************************************************************************************************
sd
Example:
gen sroe_sd=.
foreach yyyy of numlist 1980/2010{
	gen period=(year>=`yyyy' & year<`yyyy'+4 & !missing(sroe)) 
	sd2 sroe if period==1, gen(temp) by(gvkey) min(8)
	replace sroe_sd=temp if year==`yyyy'
	drop period temp
}

***************************************************************************************************/
cap program drop sd2
program define sd2
syntax varlist(min=1 max=1) [if] [in], gen(name)  [by(varlist)]
quietly {
	confirm new variable `gen'
	tempvar dummy count count mean var 
	marksample touse
	tokenize `varlist'

	by `by': gen `count'=sum(`touse')
	by `by': replace `count'=`count'[_N]
	by `by': replace `touse'=0 if `count'[_N]<`min'

	sort `by' `touse'
	by `by' `touse' : gen `mean'=sum(`1')/`count' if `touse'
	by `by' `touse': gen `var'=sum((`1'-`mean'[_N])^2)/`count'[_N]  if `touse'
	by `by' `touse': gen `gen'=sqrt(`var'[_N]) if `touse'
}

end


/***************************************************************************************************
Cov
See sd for syntax 
***************************************************************************************************/
cap program drop cov2
program define cov2

syntax varlist(min=2 max=2) [if] [in], gen(name)  [by(varlist) min(integer)]

quietly {
	confirm new variable `gen'

	tempvar dummy count count mean1 mean2  count cov

	marksample touse
	tokenize `varlist'

	by `by': gen `count'=sum(`touse')
	by `by': replace `count'=`count'[_N]
	by `by': replace `touse'=0 if `count'<`min'
	sort `by' `touse'

	by `by' `touse': gen `mean1'=sum(`1')/`count' if `touse'

	by `by' `touse': gen `mean2'=sum(`2')/`count' if `touse'

	by `by' `touse': gen `cov'=sum((`1'-`mean1'[_N])*(`2'-`mean2'[_N]))/(`count')  if `touse'
	by `by' `touse' : gen `gen'=`cov'[_N] if `touse'
}

end 



/***************************************************************************************************
corr
See sd for syntax 
***************************************************************************************************/
cap program drop corr2
program define corr2

syntax varlist(min=2 max=2) [if] [in], gen(name)  [by(varlist) min(integer)]

quietly {
	confirm new variable `gen'

	tempvar dummy count count mean1 var1 mean2 var2 count corr

	marksample touse
	tokenize `varlist'

	by `by': gen `count'=sum(`touse')
	by `by': replace `count'=`count'[_N]
	by `by': replace `touse'=0 if `count'<`min'
	sort `by' `touse'

	by `by' `touse': gen `mean1'=sum(`1')/`count' if `touse'
	by `by' `touse': gen `var1'=sum((`1'-`mean1'[_N])^2)/`count'  if `touse'

	by `by' `touse': gen `mean2'=sum(`2')/`count' if `touse'
	by `by' `touse': gen `var2'=sum((`2'-`mean2'[_N])^2)/`count'  if `touse'

	by `by' `touse': gen `corr'=sum((`1'-`mean1'[_N])*(`2'-`mean2'[_N]))/(`count'*sqrt(`var1'[_N]*`var2'[_N]))  if `touse'
	by `by' `touse' : gen `gen'=`corr'[_N] if `touse'
}

end 

/***************************************************************************************************
max
***************************************************************************************************/
cap program drop max2
program define max2
syntax anything(equalok) [if] [in],  gen(name)  [by(varlist) type]
quietly {
	confirm new variable `gen'
	tempvar touse v varnonmissing
   	mark `touse' `if' `in'
   	cap confirm string variable `anything'
	if _rc==0{
		sort  `by' `touse' `v'
		cap by `by' `touse' : gen `gen'=`v'[_N] if `touse'
	}
   	gen `v'=`anything'
   	gen byte `varnonmissing'=!missing(`var')
   	sort  `by' `touse' `varnonmissing' `v'
   	cap by `by' `touse' : gen `type' `gen'=`v'[_N] if `touse'
   	* gen `gen'=.
   	*sort  `by' `touse' 
   *	by `by' `touse': replace `gen'=/*
   	        */ cond(`var'>`gen' | `gen'[_n-1]==., `var', `gen'[_n-1]) if `touse'==1
   	*by `by' `touse': replace `gen'=`gen'[_N]
}
end 

/***************************************************************************************************
min
***************************************************************************************************/
cap program drop min2
program define min2
syntax anything(equalok) [if] [in], gen(name)  [by(varlist) type]
quietly {
	confirm new variable `gen'
	tempvar touse v varnonmissing
   	mark `touse' `if' `in'
   	cap confirm string variable `anything'
	if _rc==0{
		gen byte `varnonmissing'=missing(`var')
		sort  `by' `touse' `varnonmissing' `v'
		cap by `by' `touse' : gen `gen'=`v'[1] if `touse'
	}
   	gen `v'=`anything'
   	sort `by' `touse' `v'
   	by `by' `touse': gen `type' `gen'=`v'[1] if `touse'
}

end 

/***************************************************************************************************
tag
***************************************************************************************************/
cap program drop tag2
program define tag2
syntax varlist [if] [in], gen(name) [Missing type]
quietly {
	confirm new variable `gen'
	tempvar touse  temp
   	mark `touse' `if' `in'
	  if "`missing'"=="" { 
	      markout `touse' `varlist', strok
	  }
   	sort `touse' `varlist'
   	by `touse' `varlist': gen `type' `temp'=_n==1 if `touse'
   	replace `temp'=0 if `touse'~=1
   	rename `temp' `gen'
}
end 


/***************************************************************************************************
and group
***************************************************************************************************/
cap program drop group2
program define group2
syntax varlist [if] [in],  gen(name) [Missing type]
quietly {
	confirm new variable `gen'
	tempvar touse temp
	mark `touse' `if' `in'
	if "`missing'"=="" { 
	    markout `touse' `varlist', strok
	}
	sort `touse' `varlist'
	by `touse' `varlist': gen long `temp'=1 if _n==1 & `touse'
	replace `temp'=sum(`temp')
	replace `temp'=. if `touse'~=1
	rename `temp' `gen'
	compress `gen'
}
end




/***************************************************************************************************
or group
***************************************************************************************************/
cap program drop orgroup2
program define orgroup2, sortpreserve
syntax varlist(name=with), id(varlist) gen(name) [Missing] [by(varlist)]
quietly {
	confirm new variable `gen'
	gen `gen'=`id'
	count if missing(`id')
	if `r(N)'>0{
		display "First variable should not be missing" as error
	}
	if "`missing'"==""{
		foreach v of varlist `with' {
			tempvar g`v'
			egensort `g`v''=group(`v' `by')
			sum `g`v''
			replace `g`v''=_n+r(max)  if missing(`g`v'')
		}
	}
	else{
		foreach v of varlist `with' {
			tempvar g`v'
			egensort `g`v''=group(`v' `by'), missing
		}
	}
	tempvar temp ttemp
	tokenize `with'
	while "`1'"~=""{
		a2group2, individual(`gen') unit(`g`1'') groupvar(`temp')
		egensort `ttemp'=max(`gen'), by(`temp')	
		drop `gen' `temp'
		gen `gen'=`ttemp'
		drop `ttemp'
		macro shift
	}
}

if "`sort'"~=""{
	sort `gen' `id' `with'
	order `gen' `id' `with'
}
qui distinct `id'
scalar Nm1=r(ndistinct)
qui distinct `gen'
scalar Nm2=r(ndistinct)
dis as text "Initial groups = "in ye %9.0gc Nm1
dis  as text "Final groups = "in ye %9.0gc Nm2 
end



cap program drop a2group2
program define a2group2, sortpreserve
syntax ,  individual(varname) unit(varname) groupvar(name)
quietly {
	preserve

	confirm new variable `groupvar'

	keep `individual' `unit'

	tempvar indid unitid 
	tempfile tempgroupfile

	egen `indid'  = group(`individual')
	egen `unitid' = group(`unit')

	keep `individual' `unit'  `indid' `unitid' 

	***** Keeps only cells : we are working with cells, not observations
	duplicates drop  `indid' `unitid', force

	mata: groups( "`indid'","`unitid'","`groupvar'")

	*** Drop new school and pupil indexes
	keep `individual' `unit' `groupvar'
	sort `individual' `unit'
	save "`tempgroupfile'", replace

	*** Merge group information with main input data file

restore
	
	sort `individual' `unit'
	merge `individual' `unit' using "`tempgroupfile'"
	drop _merge
	}

end 


mata

void groups(string scalar individualid, string scalar unitid, string scalar groupvar) {

		real scalar ncells, npers, nfirm; 	/* Data size : number of distinct observations number of pupils number of schools */
		real matrix byp, byf; 			/* Dataset sorted by pupil/by school */
		real vector pg, fg, pindex, findex, ptraced, ftraced, ponstack, fonstack;
	
		/***** Stack for tracing elements */
		real vector m;				/* Stack of pupils/schools */
		real scalar mpoint;			/* Number of elements on the stack */
	
		real scalar nptraced, nftraced;	// Number of traced elements
		real scalar lasttenp, lasttenf;
		real scalar nextfirm;

		real vector mtype; 	/* Type of the element on top of the stack */
					 	/* Convention : 					 */
					 	/* 1 for a pupil					 */
					 	/* 2 for a school					 */
	
		real scalar g;	/* Current group */
	
		real scalar j;
	
		real matrix data;		/* A data view used to add group information after the algorithm completed */
	
		printf("Grouping algorithm for CG\n");
	
		/****** Core data : cells sorted by person/by firm */

		byp = st_data(., (individualid, unitid));
		printf("Sorting data by pupil id\n");
		byp = sort(byp,1);
	
		byf = st_data(., (individualid, unitid));
		printf("Sorting data by school id\n");
		byf = sort(byf,2);
		
		/****** Data size */
	
		ncells = rows(byf);		/* Number of distinct observations (duplicates drop has to be done beforehand) */
		npers  = byp[ncells,1];		/* Number of pupils										 */
		nfirm  = byf[ncells,2];		/* Number of schools										 */

		printf("Data size : %9.0g cells, %9.0g pupils, %9.0g firms\n", ncells, npers, nfirm);
	
		/****** Initializing the stack and p/ftraced */

		printf("Initializing the stack\n");
	
		ptraced  = J(npers, 1, 0);	// No pupil has been traced yet
		ftraced  = J(nfirm, 1, 0);	// No school has been traced yet

		ponstack = J(npers, 1, 0);	// No pupil has been on the stack yet
		fonstack = J(nfirm, 1, 0);	// No school has been on the stack yet
	
		m 	= J(npers+nfirm, 1, 0); // Empty stack
		mtype = J(npers+nfirm, 1, 0);	// Unknown type of the element on top of the stack
	
		printf("Initializing pg,fg\n");
	
		pg	= J(npers, 1, 0);
		fg	= J(nfirm, 1, 0);
	
		/****** Initializing pindex, findex */
	
		printf("Initializing the index arrays\n");
	
		pindex = J(npers, 1, 0);
		findex = J(nfirm, 1, 0);
	
		for ( j = 1 ; j <= ncells ; j++) {
			pindex[byp[j,1]] = j;
			findex[byf[j,2]] = j;
		}
	
		g = 1;   	// The first group is group 1
		
		check_data(byp, byf, ncells);
	
		/***** Puts the first firm in the stack */
	
		printf("Putting first school on the stack\n");
		nextfirm = 1;
		mpoint = 1;
		m[mpoint] = 1;
		mtype[mpoint] = 2;
		fonstack[1] = 1;
	
		printf("Starting to trace the stack\n");
		
		nptraced = 0;
		nftraced = 0;
		lasttenp = 0;
		lasttenf = 0;

		while (mpoint > 0) {
	
			if (trunc((nptraced/npers)*100.0) > lasttenp || trunc((nftraced/nfirm)*100.0) > lasttenf) {
				lasttenp = trunc((nptraced/npers)*100.0);
				lasttenf = trunc((nftraced/nfirm)*100.0);
	
				printf("Progress : %9.0g pct pupils traced, %9.0g pct firms traced\n",lasttenp,lasttenf);
			}
	
			if (g > 1) {
				printf("%9.0g\t", g);
			}
			trace_stack( byp, byf, pg, fg, m, mpoint, mtype, ponstack, fonstack, ptraced, ftraced, pindex,  findex,g, nptraced, nftraced);
			if (mpoint == 0) {
				g = g + 1;
				while (nextfirm < nfirm && fg[nextfirm] != 0) {
					nextfirm = nextfirm + 1;
				}
				if (fg[nextfirm] == 0) {
					mpoint = 1;
					m[mpoint] = nextfirm;
					mtype[mpoint] = 2;
					fonstack[nextfirm] = 1;
				}
			}
		}
	
		printf("Finished processing, adding group data\n");
	
		st_addvar("long", groupvar);
	
		st_view(data, . ,(individualid, unitid,groupvar));
	
		for (j = 1 ; j<=ncells; j++ ) {
			data[j,3] = pg[data[j,1]];
			if (pg[data[j,1]] != fg[data[j,2]]) {
				printf("Error in the output data.\n");
				printf("Observation %9.0g, Pupil %9.0g, School %9.0g, Group of pupil %9.0g, Group of school %j\n",
						j, data[j,1], data[j,2], pg[data[j,1]], fg[data[j,2]]);
				exit(1);
			}
		}
	
		printf("Finished adding groups.\n");
	
	}

	/*

	Name:			check_data()
	
	Purpose:	This function checks whether data is correctly sequenced.
	
	 */
	
	function check_data(real matrix byp, real matrix byf, real scalar ncells) {
		
		real scalar thispers, thisfirm;
	
		real scalar i;
	
		thispers = 1;
		thisfirm = 1;
	
		for ( i=1 ; i <= ncells ; i++ ) {
			if ( byp[i,1] != thispers ) {
				if ( byp[i,1] != thispers+1 ) {
					printf("Error : by pupil file not correctly sorted or missing sequence number\n");
					printf("Previous person : %9.0g , This person : %9.0g , Index in file %9.0g\n", thispers, byp[i,1], i);
					exit(1);
				}
				thispers = thispers + 1 ;
			}
	

			if ( byf[i,2] != thisfirm ) {
				if ( byf[i,2] != thisfirm + 1 ) {
					printf("Error : by school file not correctly sorted or missing sequence number\n");
					printf("Previous school : %9.0g , This school : %9.0g , Index in file %9.0g\n", thisfirm, byf[i,2], i);
					exit(1);
				}
				thisfirm = thisfirm + 1;
			}
		
		}
	
		printf("Data checked - By pupil and by school files correctly sorted and sequenced\n");
	}

	/*
	
	Name: 	trace_stack()
	
	Purpose:	Builds the connex component of the graph of the elements on the stack

	 */

	void trace_stack( real matrix byp, real matrix byf, real vector pg,  real vector fg, 
				real vector m, real scalar mpoint, real vector mtype,
				real vector ponstack, real vector fonstack,
				real vector ptraced,  real vector ftraced,
				real vector pindex,   real vector findex,
				real scalar g, real scalar nptraced, real scalar nftraced) {
	
		real scalar thispers, thisfirm, person, afirm, lower, upper;
	
		if (mtype[mpoint] == 2) { // the element on top of the stack is a firm
			thisfirm = m[mpoint];
			mpoint = mpoint - 1;
			fg[thisfirm] = g;
			ftraced[thisfirm] = 1;
			fonstack[thisfirm] = 0;
			if (thisfirm == 1) {
				lower = 1;
			} else {
				lower =  findex[thisfirm - 1] + 1;
			}
			upper = findex[thisfirm];
			for (person = lower ; person <= upper ; person ++) {
				thispers = byf[person, 1];
				pg[thispers] = g;
				if (ptraced[thispers] == 0 && ponstack[thispers] == 0) {
					nptraced = nptraced + 1;
					mpoint = mpoint + 1;
					m[mpoint] = thispers;
					mtype[mpoint] = 1;
					ponstack[thispers] = 1;
				}
			}
		} else if (mtype[mpoint] == 1) { // the element on top of the stack is a person
			//printf("A person\t");
			thispers = m[mpoint];
			mpoint = mpoint - 1;
			pg[thispers] = g;
			ptraced[thispers] = 1;
			ponstack[thispers] = 0;
			if (thispers == 1) {
				lower = 1;
			} else {
				lower = pindex[thispers - 1] +1;
			}
			upper = pindex[thispers];
			for (afirm = lower; afirm <= upper; afirm++) {
				thisfirm = byp[afirm, 2];
				fg[thisfirm] = g;
				if (ftraced[thisfirm] == 0 && fonstack[thisfirm] == 0) {
					nftraced = nftraced + 1;
					mpoint = mpoint + 1;
					m[mpoint] = thisfirm;
					mtype[mpoint] = 2;
					fonstack[thisfirm] = 1;
				}
			}
		} else {
			printf("Incorrect type, element number %9.0g of the stack, type %9.0g\n",mpoint,mtype[mpoint]);
		}
	
	}
end


/***************************************************************************************************
nvals
***************************************************************************************************/
program define nvals2
syntax varlist [if] [in] , by(varlist) gen(name) [Missing]
tempvar touse
quietly {
		tempvar temp
		confirm new variable `gen'
        mark `touse' `if' `in'
        if "`missing'" == "" {
                markout `touse' `varlist', strok 
        }
        sort  `by' `touse' `varlist' 
        by `by' `touse'  `varlist': gen `temp' = _n == 1 if `touse' 
        by `by' `touse'  : replace `temp' = sum(`temp') if `touse' 
        by  `by' `touse' : gen `gen' = `temp'[_N] if `touse' 
}
end


/***************************************************************************************************
dup
***************************************************************************************************/
cap program drop duplicates2
program define duplicates2
syntax varlist [if] [in] , gen(name)   [Sort Missing]
tempvar touse
quietly {
		tempvar temp
		confirm new variable `gen'
        mark `touse' `if' `in'
        if "`missing'" == "" {
                markout `touse' `varlist', strok 
        }
        sort  `by' `varlist'  `touse' 
        by `by' `varlist'  `touse' : gen `temp' =  sum(1==1) if `touse' 
        by  `by' `varlist' `touse' : gen `gen' = `temp'-1 if `touse' 
        if "`sort'"~=""{
        	order `gen' `varlist'
        	sort `gen' `varlist'
        	tab `gen'
        }
}
end




/***************************************************************************************************
fill
foreach variable in varlist, fill does the following for each missing observation of the variable:
***************************************************************************************************/

cap program drop fill2
program define fill2
syntax varlist(min=1 max=1) [if] [in], gen(name)  Time(varname) by(varname)  [ifsame(varlist)]
qui{
confirm new variable `gen'
tempvar t time_inf time_sup temp1 temp2 temp
gen `temp'= `varlist'
assert !missing(`by') & !missing(`time')
duplicates tag `by' `time', gen(`t')
cap assert `t'==0
if _rc~=0{
	display as error " `time' not unique for `by'"
	exit 4
}
sort `by' `time'
gen `time_inf'=`time'
gen `time_sup'=-`time'


tempvar touse
gen `touse'=1 `if'

gen `temp1'=0
foreach suffix in _inf _sup{
	tempvar n`suffix'
	sort `by' `time`suffix''
	by `by': gen `n`suffix''=_n
	by `by': replace `n`suffix''=`n`suffix''[_n-1]  if missing(`varlist')
	foreach v in `varlist' `ifsame'{
		tempvar `v'`suffix'
		sort `by' `time`suffix''
		by `by': gen ``v'`suffix''=`v'
		by `by': replace ``v'`suffix''=``v'`suffix''[_n-1]  if _n~=`n`suffix''
		by `by': replace `temp1'=`temp1'+(`v'~=``v'`suffix'')* !missing(``v'`suffix'') * !missing(`v')
	}
	replace `temp'=``varlist'`suffix'' if missing(`temp') & !missing(``varlist'`suffix'')  & `temp1'==0  & `touse'==1
}
rename `temp' `gen'
}

end


/***************************************************************************************************
xtile
***************************************************************************************************/
cap program drop xtile2
program define xtile2
syntax varlist(min=1 max=1) [aw] [if] [in], gen(name) by(varname) Percentiles(string) Nquantiles(string) type]

qui{
tempvar temp
gen `type' `temp'=.
confirm new variable `gen'
if "`percentiles'" != "" {
         local percnum "`percentiles'"
 }
 else if "`nquantiles'" != "" {
         local perc = 100/`nquantiles'
         local first = `perc'
         local step = `perc'
         local last = 100-`perc'
         local percnum "`first'(`step')`last'"
 }
 else{
           local percnum 50
  }


/* without by */
if "`by'"=="" {
        local i 1
        _pctile `varlist' `weight' if `touse', percentiles(`percnum') `altdef'
        foreach p of numlist `percnum' {
                if `i' == 1 {
                        replace `temp' = `i' if `varlist' <= r(r`i') & `touse'
                }
                replace `temp' = `++i' if `varlist' > r(r`--i')  & `touse'
                local i = `i' + 1
        }
       
}
else{
	tempvar byvar
	by `touse' `by', sort: gen `byvar' = 1 if _n==1 & `touse'
	by `touse' (`by'): replace `byvar' = sum(`byvar')

	levels `byvar', local(K)
	foreach k of local K {
	        local i 1
	        _pctile `varlist' `weight' if `byvar' == `k' & `touse' , percentiles(`percnum') `altd
	> ef'
	        foreach p of numlist `percnum' {
	                if `i' == 1 {
	                        replace `temp' = `i' if `varlist' <= r(r`i') & `byvar' == `k' & `touse'
	                }
	                replace `temp' = `++i' if `varlist' > r(r`--i')  & `byvar' == `k' & `touse'
	                local i = `i' + 1
	        }
	}
}
rename `temp' `gen'
}

end




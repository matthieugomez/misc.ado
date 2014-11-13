{smcl}
{* *! version 1.2.14  02feb2013}{...}
{viewerdialog egensort "dialog egensort"}{...}
{vieweralsosee "[D] egensort" "mansection D egensort"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] collapse" "help collapse"}{...}
{vieweralsosee "[D] generate" "help generate"}{...}
{viewerjumpto "Syntax" "egensort##syntax"}{...}
{viewerjumpto "Menu" "egensort##menu"}{...}
{viewerjumpto "Description" "egensort##description"}{...}
{viewerjumpto "Examples" "egensort##examples"}{...}
{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{manlink D egensort} {hline 2}}Faster version of {cmd:egen} and {cmd:egenmore} for a restricted set of functions. It has a different set of options and adds the function {it:orgroup}
 {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:egensort} {dtype} {newvar} {cmd:=} {it:fcn}({it:arguments})   {ifin}
[{it:{help egensort##weight:weight}}]{cmd:,}
[{cmd:,} {it:options}]

{phang}
where depending on the {it:fcn}, {it:arguments} refers to an expression,
{it:varlist}, or {it:numlist}, and the {it:options} are also {it:fcn}
dependent, and where {it:fcn} is

{phang2}
{opth cov(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sample covariance of {it:varlist}. 
The option min sets the new variable to "." when there are less than {it:num} observations such that both variables in {it:varlist} are non missing.

{phang2}
{opth corr(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sample correlation of {it:varlist}. 
The option min sets the new variable to "." when there are less than {it:num} observations such that both variables in {it:varlist} are non missing.

{phang2}
{opth duplicates(varlist)} [{cmd:,} {opt m:issing} {opt s:ort}]{p_end}
{pmore2}
creates a constant  containing the number of duplicates for each observation.  This
    will be 0 for all unique observations.  
    The option {cmd:sort}  sorts and orders the variable according to this new variable and {it:varlist} and tabulates the new variable. The new variable is set to zero for observations with missing value for one variable in {it:varlist}, unless {cmd:missing} is specified.


{phang2}
{opth fill(varname)} {cmd:,} {opt t:ime}{cmd:(}{it:varname}{cmd:)} [{opt by}{cmd:(}{it:byvarlist}{cmd:)}  {opt ifsame}{cmd:(}{it:varlist}{cmd:)}] {p_end}
{pmore2}
creates a variable that corresponds to {it:varname} except that missing values are filled based on non missing observations within groups defined by {it:byvarlist}.
The command first fills in based on previous non missing observation, then based on non missing posterior observations. The option {cmd:ifsame} fills in missing observations only when variables in {it:varlist} are the same between the rows.

{phang2}
{opth group(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt m:issing}]{p_end}
{pmore2}
creates one variable (within {it:byvarlist}) taking on values 1, 2, ... for the groups formed by {it:varlist}.  {it:varlist} may
contain numeric variables, string variables, or a combination of the two.  
The order of the groups is that of the sort order of {it:varlist}.  {opt missing}
indicates that missing values in {it:varlist}
{bind:(either {cmd:.} or {cmd:""}}) are to be treated like any other value
when assigning groups, instead of missing values being assigned to the
group missing.  

{phang2}
{opth max(exp)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the maximum non missing value of {it:exp}. 
Contrary to the traditional {cmd:egen}, it accepts expressions and strings.

{phang2}
{opth mean(exp)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt m:issing}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the mean of
{it:exp}. 
The option {cmd:missing} replaces the new variable by "." when there are no observations with non missing {it:exp} and non null/non missing {it:weight} (within {it:byvarlist}).

{phang2}
{opth min(exp)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the minimum value of {it:exp}. 
Contrary to the traditional {cmd:egen}, it accepts expressions and strings.

{phang2}
{opth nvals(exp)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt m:issing}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the number of distinct values in {it:exp}. 
Missing values are ignored unless {cmd:missing} is specified. 

{phang2}
{opth orgroup(varlist)} [{cmd:,} {opt id}{cmd:(}{it:varname}{cmd:)} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt s:ort} {opt m:issing}]{p_end}
{pmore2}
creates a variable taking on the maximum value of {it:varname} within groups formed by connected components of {it:varname} and {it:varlist} (within {it:byvarlist}). The variable {it:varname} should never be missing. 
{opt missing}
indicates that missing values in {it:varlist} are to be treated like any other value
when assigning groups, instead of each missing value being considered as a unique value. 
The option {cmd:sort} sort and order the data by the new variable and {it:varname}

{phang2}
{opth sd(varname)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the standard
deviation of {it:exp}.   
The option min sets the new variable to "." when there are less than {it:num} observations such that  {it:varname} is non missing.

{phang2}
{opth sum(exp)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt m:issing}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sum of {it:exp}.   
The option {cmd:missing} replaces the new variable by "." when there are no observations with non missing {it:exp}.

{phang2}
{opth tag(varlist)} [{cmd:,} {opt m:issing}]{p_end}
{pmore2}
tags just 1 observation in each distinct group defined by {it:varlist}. The result will be 1 if
the observation is tagged and never missing, and 0 otherwise.  
Values for any observations excluded by either {helpb if} or {helpb in} are set to 0 (not missing).  
Hence, if {opt tag} is the variable produced by {cmd:egen tag =} {opt tag(varlist)}, the idiom {opt if tag}
is always safe.  
{opt missing} specifies that missing values of {it:varlist} may be included.

{phang2}
{opth xtile(varlist)} [{cmd:,}  {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt percentiles}{cmd:(}{it:byvarlist}{cmd:)} {opt nquantiles}{cmd:(}{it:byvarlist}{cmd:)}]{p_end}
{pmore2}
    categorizes varname by specific percentiles. The function works like xtile. 
    By default varname is    dichotomized at the median. 
    percentiles() requests percentiles corresponding to numlist: for
    example, p(25(25)75) is used to create a variable according to quartiles. 
    Alternatively you also    may have specified n(4): to create a variable according to quartiles.  


{marker menu}{...}
{title:Menu}

{phang}
{bf:Data > Create or change data > Create new variable (extended)}


{marker description}{...}
{title:Description}

{pstd}
{cmd:egensort} is coded to be faster than the corresponding {cmd:egen} commands. In particular, {cmd:egensort} does not preserve the initial sorting of the data. Also, precision might be lost unless the type double is used.


{marker weight}{...} {cmd:aweight}s are allowed for {it:mean} and {it:xtile}.



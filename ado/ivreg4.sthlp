{smcl}
{* *! version 1.2.1  07mar2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:ivreg4} {hline 2} estimate models with an arbitrary number of high dimensional fixed effects 


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ivreg4} {it:depvar} [{it:varlist1}]
{cmd:(}{it:varlist2}{cmd:=}{it:varlist_iv}{cmd:)} [{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,} {cmdab:a:bsorb}{cmd:(}{it:string}{cmd:)}}  {cmdab:cl:uster}{cmd:(}{it:varlist}{cmd:)}  {cmd:fe} {cmd:demean} {cmd:adj} {cmdab:nocons:tant} {cmd:rcommand}{cmd:(}{it:string}{cmd:)} {cmd:core}{cmd:(}{it:#}{cmd:)} ]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt a:bsorb(string)}} list of fixed effect{p_end}
{synopt:{opt cl:uster(varlist)}} list of clusters{p_end}
{synopt:{opt fe}} generates fixed effect estimates
{p_end}
{synopt:{opt demean}} Suffix of demeaned variables{p_end}
{synopt:{opt nocons:tant}} No intercept {p_end}
{synopt:{opt adj}} adjust clustered standard errors by number of fixed effect within clusters{p_end}
{synopt:{opt rcommand}} changes the shell command used to invoke R


{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:aweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:ivreg4} uses the package lfe in R to estimate models with high dimensional fixed effects. The packages lfe and data.table must be installed



{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt absorb(string)}  specifies the categorical variable which are to be included in the regression as if it
        were specified by dummy variables. It also specifies the categorial variables which should be included as dummy variables interacted with a continuous variable with the syntax continuous_variable:categorial_variable

{phang}
{opt nocons} specifies that the model should be estimated without intercept


{dlgtab:Errors}
{phang}
{opt cluster(varlist)} computes clustered standard errors. Errors are adjusted for small-sample.

{phang}
{opt adj} specifies that degree of freedoms adjustment of clustered standard errors should not done for fixed effects within clusters (similarly to the default behavior of xtivreg2).


{dlgtab:Output}

{phang}
{opt demean}  creates for each variable in the model a corresponding variable with suffix _dm obtained after partialing out the fixed effects in {cmd:absorb()}. 

{phang}
{opt fe} generates for each categorical variable in {cmd:absorb()} three corresponding variables : a  variable with suffix _fe corresponding to fixed effect estimates, a categorical variable with suffix _comp corresponding to components, and an integer variable with suffix _n corresponding to the size of the components. With weights or with interacted fixed effects, only the fixed effect estimate is given. With interacted fixed effects, the prefix of each variable is continuousvariable_categoricalvariable instead of continuousvariable:categoricalvariable

{dlgtab:R Command}

{phang}
{opt rcommand(string)} changes the shell command used to invoke R

{phang}
{opt core(#)} specifies the number of cores used by the lfe program. Default is 3.

{marker remarks}{...}
{title:Remarks}
Time-series operators are authorized for the dependent variable and regressors.

{marker examples}{...}
{title:Examples}

{phang2}{cmd:. ivreg4 unemployment_growth (L.house_price_growth=elasticity) [w=population], a(quarter county) cl(county)} {p_end}
{phang2}{cmd:. ivreg4 unemployment_growth L.house_price_growth, a(quarter county) cl(county) fe demean} {p_end}
{phang2}{cmd:. ivreg4 unemployment_growth (L.house_price_growth=elasticity), a(quarter county interest_rate:county) cl(county)} {p_end}


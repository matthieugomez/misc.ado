{smcl}
{* *! version 1.2.1  07mar2013}{...}
{title:Title}
{bf:capkeep} {hline 2} keeps variables

{marker syntax}{...}
{title:Syntax}
{cmd:sorder} [{varlist}] 


{marker description}{...}
{title:Description}


{pstd}
{cmd:capkeep} keeps every variable included in {it:varlist}. Contrary to {cmd:keep}, no error is returned if some variable is not in the dataset. 

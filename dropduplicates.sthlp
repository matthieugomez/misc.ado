{smcl}
{* *! version 1.2.1  07mar2013}{...}
{title:Title}
{bf:dropduplicates} {hline 2} drop duplicates using a certain ordering



{marker syntax}{...}
{title:Syntax}
{cmd:dropduplicates} [{varlist}] {ifin} {cmd:,} {opt order(varname)}




{marker description}{...}
{title:Description}


{pstd}
{cmd:dropduplicates} drop duplicates drops duplicates by group specified in {it:varlist}, keeping the observation with maximum {it:order}


{smcl}
{* *! version 1.2.1  07mar2013}{...}
{title:Title}
{bf:tagduplicates} {hline 2} tag duplicates and sort by number of duplicates



{marker syntax}{...}
{title:Syntax}
{cmd:tagduplicates} [{varlist}] {ifin} {cmd:,} {opt gen:erate(varname)}



{marker description}{...}
{title:Description}


{pstd}
{cmd:tagduplicates} returns a new variable with the number of duplicates by groups specified in {it:varlist},  tabulate this variable, and sort the dataset by this variable and the groups.


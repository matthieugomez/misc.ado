{smcl}
{* *! version 1.2.1  07mar2013}{...}
{title:Title}
{bf:capdrop} {hline 2} drops variables

{marker syntax}{...}
{title:Syntax}
{cmd:capdrop} {varlist}


{marker description}{...}
{title:Description}


{pstd}
{cmd:capdrop} drop every variable included in {it:varlist}. Contrary to {cmd:keep}, no error is returned if some variable is not present in the dataset.

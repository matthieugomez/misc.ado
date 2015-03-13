{smcl}
{* *! version 1.2.1  07mar2013}{...}
{title:Title}
{bf:clean} {hline 2} winsorize based on 5 times interquartiles



{marker syntax}{...}
{title:Syntax}
{cmd:clean} {varlist} {ifin} {cmd:,[} {opt drop replace gen(string)}{cmd:]}



{marker description}{...}
{title:Description}
{pstd}
{cmd:clean} winsorizes  each variable in {it:varlist} based on 5 times the interquartile range. With the option {opt drop}, these observations are replaced by missing values. With the option gen, creates a new variable and leaves the original untouched


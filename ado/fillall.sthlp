{smcl}
{* *! version 1.2.1  07mar2013}{...}
{title:Title}
{bf:fillall} {hline 2} tsfill multiple variable

{marker syntax}{...}
{title:Syntax}
{cmd:fillall} {cmd:,} {opt id(varlist)} {opt t:ime(varlist)}  {cmd:,[} {opt full}{cmd:]}


{marker description}{...}
{title:Description}


{pstd}
{cmd:fillall} adds missing rows similarly to {cmd:tsfill} except that multiple variables for id and time can be specified. This is particularly handy when some variables are constant across ids or across time.


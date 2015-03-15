{smcl}
{* *! version 1.2.1  07mar2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] append" "help append"}{...}
{title:Title}
{bf:capappend} {hline 2} append files with conflicting variable types

{marker description}{...}
{title:Description}

{pstd}
{cmd:capappend} is exactly the same as {cmd:append} except for one thing. When the type of one variable differs in both datasets, the variable is converted to strings for both datasets instead of returning an error



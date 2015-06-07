
program TexFigure
version 10
set more off
syntax anything(name=filepath) [, using(string) title(string) note(string) position(string) replace]

splitpath `filepath'
local filepath `r(directory)'`r(filename)'.tex

splitpath `using'
local using `r(directory)'`r(filename)'.pdf


cap confirm new file `"`filepath'"'
if _rc & "`replace'" == ""{
	di `"file `filepath' already exists"'
	exit
}
if "`position'"==""{
	local position hp
}
if regexm(`"`using'"',`"^(.+)/([^/\.]+)(.*)$"'){
	local directory=regexs(1)
	local filename=regexs(2)
}
local filepath: list clean filepath
local using=regexr(`"`using'"',".pdf","")
cap file close texcode
file open texcode using `"`filepath'"', write replace
file write texcode ///
`"\begin{figure}[`position'] "'_n ///
`"\caption{`title'} "'_n ///
`"\centerline{\includegraphics{`using'}}"'_n ///
`"\label{fig:`filename'}"'_n ///
`"\begin{minipage}[t]{\hsize} \rule{0pt}{9pt} "'_n ///
`"\footnotesize "'_n ///
`"\noindent "'_n ///
`"`note'"'_n ///
`"\end{minipage} "'_n ///
`"\end{figure} "'
file close texcode
end



program TexAppend
version 10
set more off
syntax anything(name=filepath) [, using(string) landscape compile slide]

splitpath `filepath'
local filepath `r(directory)'`r(filename)'.tex


splitpath `using'
local using `r(directory)'`r(filename)'.tex

local using=subinstr("`using'","/","\/", .)

if "`landscape'"==""{
	local replacement "\\input{`using'}"
}
else{
	local replacement "\\begin{landscape}`prefix'input{`using'}`prefix'end{landscape}"
}

if "`slide'" != ""{
	local replacement "\\begin{frame} `replacement' \\end{frame}"
}


* if `replacement' is not found in `filepath', replace end document by `replacement' (with sed) and add \end{document} as a new line (with echo)
!grep -q -e "`replacement'" `filepath' || (sed -i"" -e 's/\(\\\end{document}\)/`replacement'/'  "`filepath'"  && echo '\\end{document}' >> `filepath')
if "`compile'"~=""{
	TexCompile `filepath', open
}
end

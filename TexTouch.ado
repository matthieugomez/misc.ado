program TexTouch 
	version 10 
	set more off 
	syntax anything(name=filepath) [, title(string) precompile(string) replace slide] 
	splitpath `filepath'
	local filepath `r(directory)'`r(filename)'.tex
	cap confirm new file `"`filepath'"'
	if _rc ~= 0 & "`replace'" == ""{
			di as error `"file `filepath' already exists"'
			exit 602
		}
	cap file close texcode 
	file open texcode using `filepath', write replace 
	if "`slide'" ~= ""{
		file write texcode ///
		`"%!TEX program = lualatex"' _n ///
		`"\documentclass[10pt, compress]{beamer}"' _n ///
		`"\usetheme[usetitleprogressbar]{m}"' _n ///
		`"\usepackage{booktabs}"' _n ///
		`"\usepackage[scale=2]{ccicons}"' _n ///
		`"\usepgfplotslibrary{dateplot}"' _n ///
		`"\usepackage{tabularx}"' _n ///
		`"\renewcommand{\tabularxcolumn}[1]{>{\centering\arraybackslash}m{#1}}"' _n ///
		`"\newcolumntype{L}{>{\centering}X}"' _n ///
		`"\usepackage{siunitx}"' _n ///
		`"\sisetup{detect-mode, "' _n ///
		`"group-digits            = false ,"' _n ///
		`"input-signs             = - ,"' _n ///
		`"input-symbols           = ()[]-+* ,"' _n ///
		`"input-open-uncertainty  = ,"' _n ///
		`"input-close-uncertainty = ,"' _n ///
		`"table-align-text-post   = false,"' _n ///
		`"table-number-alignment  = center,"' _n ///
		`"%group-digits            = integer,"' _n ///
		`"%group-separator         = {,}"' _n 
	}
	if "`precompile'"==""{
	file write texcode `"\documentclass[11 pt,letterpaper]{article}"' _n ///
	`"\usepackage{amsmath, amsthm, amssymb}"' _n ///
	`"\usepackage[toc,page]{appendix} "' _n ///
	`"\usepackage[utf8]{inputenc}"' _n ///
	`"\usepackage[round]{natbib}"' _n ///
	`"\usepackage{enumerate}"' _n ///
	`"\usepackage{hyperref}"' _n ///
	`"\usepackage{dsfont}"' _n ///
	`"\usepackage{bussproofs}"' _n ///
	`""' _n ///
 	`"\usepackage{rotating}"' _n ///
	`"\usepackage{graphicx}"' _n ///
	`"\usepackage{caption}"' _n ///
	`"\usepackage{subcaption}"' _n ///
	`""' _n ///
	`"\usepackage{afterpage}"' _n ///
	`"\usepackage{adjustbox}"' _n ///
	`""' _n ///
	`"\usepackage{morefloats}"' _n ///
	`""' _n ///
	`"\usepackage{booktabs}"' _n ///
	`"\usepackage{tabularx}"' _n ///
	`"\renewcommand{\tabularxcolumn}[1]{>{\centering\arraybackslash}m{#1}}"' _n ///
	`"\newcolumntype{L}{>{\centering}X}"' _n ///
	`""' _n ///
	`"\usepackage{pdflscape}"' _n ///
	`"\usepackage{longtable}"' _n ///
	`"\usepackage{dcolumn}"' _n ///
	`"\usepackage{siunitx}"' _n ///
	`"\sisetup{ detect-mode, "' _n ///
	`"          input-signs=-,"' _n ///
	`"          input-symbols           = ()[]-+* ,"' _n ///
	`"          input-open-uncertainty  = ,"' _n ///
	`"          input-close-uncertainty = ,"' _n ///
	`"          table-align-text-post   = false,"' _n ///
	`"          table-number-alignment  = center,"' _n ///
	`"        }"' _n 
	}
	else{
		file write texcode `"%&`precompile'"' _n 
	}
	if "`title'"==""{ 
		local title Draft 
	} 
	file write texcode ///
	`"\begin{document}"' _n ///
	`"\title{\vspace{-4.5ex} \large{\textbf{\MakeUppercase{`title'}}}}"' _n ///
	`"\date{\vspace{-4.5ex}\today}	"' _n ///
	`"\maketitle"' _n _n ///
	`"\end{document}"' 
	file close texcode 
end 




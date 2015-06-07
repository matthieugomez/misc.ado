
program TexCompile
	set more off
	syntax anything(name=filepath),[open]

	splitpath `filepath'
	!cd "`r(directory)'" && pdflatex -interaction=batchmode `r(filename)'.tex
	if "`open'"~=""{
		local pdfpath=subinstr(`filepath',".tex",".pdf",.)
		! osascript -e 'tell application "Skim2" to open POSIX file "`pdfpath'" '
	}
end

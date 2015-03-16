program graphtopdf
syntax anything(name=filename)[, replace]
qui{

	splitpath `filename'
	local directory `r(directory)'
	local filename `r(filename)'
	local filetype `r(filetype)'
	cap confirm new file "`directory'`filename'.pdf"
	if _rc  & "`replace'"==""  {
		display as error "file `directory'`filename'.pdf already exists"
		exit 602
	}
	graph export "`directory'`filename'.eps", replace
	shell ps2pdf -dAutoPositionEPSFiles=true -dPreserveEPSInfo=true -dAutoRotatePages=/None -dEPSCrop=true "`directory'`filename'.eps" "`directory'`filename'.pdf" && rm -f "`directory'`filename'.eps"
}
end

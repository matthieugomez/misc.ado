/***************************************************************************************************
To get the table number, look up is in
http://www.bea.gov/api/_pdf/bea_web_service_api_user_guide.pdf
For instance the Section 2.1 in NIPA corresponts to TableID 58. 
The correct command is: bea 58, key() datasetname(NIPA) frequency(A)
***************************************************************************************************/

cap program drop bea
program define bea
	syntax anything, key(string) datasetname(string) frequency(string)
	local tableid = `anything'
	tempname rcode
	tempfile Rsource Routput
	cap file close `rcode'
	qui file open `rcode' using `Rsource', write replace
	file write `rcode' ///
	`"temp = tempfile()"' _n ///
	`"download.file("http://www.bea.gov/api/data/?&UserID=`key'&method=GetData&datasetname=`datasetname'&TableID=`tableid'&Frequency=`frequency'&Year=x&ResultFormat=JSON", temp)"' _n ///
	`"library(jsonlite)"' _n ///
	`"library(dplyr)"' _n ///
	`"library(readr)"' _n ///
	`"df <- fromJSON(temp)"' _n ///
	`"df2 <- tbl_df(df\$BEAAPI\$Results\$Data)"' _n ///
	`"write_csv(df2, "`Routput'.csv")"' _n ///
	`"print("the end")"'
	file close `rcode'
	if "`rcommand'"==""{
		local rcommand = cond(c(os) == "Windows", "Rterm.exe", "R --vanilla  --no-init-file")
	}
	!`rcommand' <`Rsource' 2>&1 && cd ""
	insheet using "`Routput'.csv", clear
	destring datavalue, ignore(",") replace
	tostring noteref, replace
end

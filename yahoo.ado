program define yahoo
	syntax [anything(name=id)], from(string) to(string) period(string)  [return]

	local id vbmfx
	if regexm("`from'","(.*)/(.*)/(.*)"){
		local a `=regexs(1)'
		local b `=regexs(2)'
		local c `=regexs(3)'
	}
	if regexm("`to'","(.*)/(.*)/(.*)"){
		local d `=regexs(1)'
		local e `=regexs(2)'
		local f `=regexs(3)'
	}
	local g `period'
	tempfile temp
	! wget -q  "http://ichart.finance.yahoo.com/table.csv?s=`id'&d=`d'&e=`e'&f=`f'&g=`g'&a=`a'&b=`b'&c=`c'&ignore=.csv" -O "`temp'.csv"
	insheet using "`temp'.csv", clear
	gen temp=date(date,"YMD")
	drop date
	gen datem=mofd(temp)
	* get end of period prices
	replace datem = datem -1
	tsset datem
	rename adjclose `id'
	if "`return'" ~= ""{
		tempvar temp
		gen `temp' = F.`id'/`id'-1
		replace `id' = `temp'
		drop `temp'
	}
	drop if missing(`id')
	format datem %tm
	keep datem `id'
end

program define yahoo
syntax [anything(name=id)], from(string) to(string) period(string) 

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
tsset datem
gen return_`id'=F.adjclose/adjclose-1
drop if missing(return)
format datem %tm
keep datem return*
end

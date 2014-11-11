program define balance
syntax varlist [,id(varlist) time(varlist)]
	egen id=group(`id')
	egen time=group(`time')
	tsset id time
	tsfill 
	* Ordering does not matter. it's a square
	local wid : word 1 of `id'
	foreach v of varlist `varlist'{
	replace `v'=0 if missing(`wid')
}
tsset, clear
sort id
xfill `id', i(id)
sort time
xfill `time', i(time)
drop id time
end

cap program drop checkthat
program define checkthat
	syntax anything(equalok)
	if regexm("`anything'", "(.*)=>(.*)"){
		local p1 = regexs(1) 
		local p2 = regexs(2)
		assert !(`p1') | `p2'
	}
	else{
		assert `anything'
	}
end

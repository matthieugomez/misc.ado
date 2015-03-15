	program define year2d, rclass
	if floor(`0'/2000)>=1 {
		local tempj=mod(`0',2000)
		if `tempj'<10{
			local tempz "0`tempj'"
		}
		else{
			local tempz "`tempj'"
		}
	}	
	else{
		local tempj=mod(`0',1900)
		local tempz "`tempj'"
	}
	return local year `tempz'	
	end


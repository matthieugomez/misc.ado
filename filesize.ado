program define filesize, rclass

	ashell_temp2 du -sk "`0'"
	if regexm(`"`r(o1)'"',"^([0-9]*).*"){
		local size = regexs(1) 
	}	
	return local KB = `size'
	return local MB = `size'/1000
	return local GB = `size'/1000000
end



program def ashell_temp2, rclass
version 8.0
syntax anything (name=cmd)

/*
 This little program immitates perl's backticks.
 Author: Nikos Askitas
 Date: 04 April 2007
 Modified and tested to run on windows. 
 Date: 05 February 2009
*/

* Run program 

  tempfile temp
  shell `cmd' >> "`temp'"
  tempname fh
  local linenum =0
  file open `fh' using "`temp'", read
  file read `fh' line
   while r(eof)==0 {
    local linenum = `linenum' + 1
    scalar count = `linenum'
    return local o`linenum' = `"`line'"'
    return local no = `linenum'
    file read `fh' line
   }
  file close `fh'

  if("$S_OS"=="Windows"){
   shell del `temp'
  }
  else{
   shell rm `temp'
  }


end

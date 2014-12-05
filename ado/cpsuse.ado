
program define cpsuse
  syntax anything

  quietly{
    local dir `c(pwd)'
    local file `0'
    local file: list clean file

    if regexm(`"`file'"',`"^(.+)/([^/\.]+)(.*)$"'){
      local directory = regexs(1)
      local filename = regexs(2)
      local filetype= regexs(3)
    }
    else if regexm(`"`file'"',`"^/*([^/\.]+)(.*)$"'){
        local directory `c(pwd)'
        local filename = regexs(1) 
        local filetype = regexs(2)
    }

    cd `directory'/
    qui !unpigz -p4 -c "`filename'.dat.gz" >  "`filename'.dat"
    do `filename'.do
    erase "`filename'.dat"
    cd `dir'
  }

end


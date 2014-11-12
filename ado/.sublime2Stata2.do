discard
clear all
set obs 10
gen a = _n
gen b = _n
gen time = _n
fillall , id(a b) time(time) full

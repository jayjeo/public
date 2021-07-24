cls
clear
cd "C:\Users\acube\Dropbox\Study\GitHub\public\warehouse"

import delimited "loglin.csv", varnames(1) clear 

set seed 1010101
gen e=rnormal()
rename y y_temp
gen y=y_temp+e
gen lny=ln(y)

reg y x, nocons
reg lny x, nocons

******
import delimited "loglin.csv", varnames(1) clear 
set seed 1010101
gen e=rnormal()
rename y2 y2_temp
gen y2=y2_temp+e
gen lny2=ln(y2)
gen lnx2=ln(x2)

reg y2 x2, nocons
reg lny2 x2, nocons
reg lny2 lnx2, nocons

gen testx=.1066271*x2
gen testy=.1066271*y2
gen yrate=(y-y[_n-1])/y[_n-1]
gen xrate=(x-x[_n-1])/x[_n-1]
gen elast=yrate/xrate
gen compare=testx/elast

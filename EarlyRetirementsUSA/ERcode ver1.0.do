** ERcode ver1.0.do

cls
clear all
set scheme s1color, perm 

/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="E:\Dropbox\Study\UC Davis\Writings\EarlyRetirementsUSA\data"  
/*********************************************
*********************************************/

//!start
cd "${path}"

use cps_00006, clear
gen num=1
format num %12.0g

replace statefip=24 if statefip==11  // include District of Columbia into Maryland. 
rename statefip state
rename wtfinl wgt  // Final Basic Weight
rename cpsidp pid  // Person number in sample unit
gen date=ym(year,month)
drop year month
format date %tm
keep if 35<=age&age<=70
keep if inlist(popstat,1,3)  // civilians

gen emp=0
replace emp=1 if inlist(empstat,10,12)   // employed
replace emp=2 if inlist(empstat,20,21,22)  // unemployed
replace emp=3 if inlist(empstat,30,31,32,33,34,35,36)  // inactive
drop if emp==0
keep if date>=683 // 2016.12

gen retired=0
replace retired=1 if empstat==36
keep date wgt state pid emp age retired
save temp, replace 


use temp, clear
drop if pid==0
gen rand=runiform()
sort rand 

keep if _n<100
keep pid 
format pid %20.3f

save question, replace 



import delimited "https://raw.githubusercontent.com/jayjeo/public/master/EarlyRetirementsUSA/question.csv", varnames(1) clear


/*
gen datedeci=date/1000
*recast double datedeci, force
*replace datedeci=floor(datedeci,.001)
gen piddate=pid+date/1000
format piddate %25.3f
gen dup=0
replace dup=1 if piddate[_n]==piddate[_n-1]
*/
gen pid2=pid
recast float pid2
sort pid
keep pid pid2 
format pid2 %20.3f

drop if pid==0
gen datedeci=date/1000
recast float datedeci, force
format datedeci %20.3f

gen piddate=pid+datedeci
sort piddate
format piddate %20.3f
gen dup=0
replace dup=1 if piddate[_n]==piddate[_n-1]


xtset pid date
tsfill, full
format pid %25.3f
recast float pid, force
reshape wide wgt emp age retired state, i(pid) j(date)

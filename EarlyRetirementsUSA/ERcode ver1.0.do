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
save cps_temp, replace 


use cps_temp, clear
drop if pid==0
format pid %25.3f
egen pidnew=group(pid)
gen double t=date
assert t==date
gen double pidnewdate=pidnew*1000+t
format pidnewdate %25.3f
sort pidnewdate
gen dup=0
replace dup=1 if pidnewdate[_n]==pidnewdate[_n-1]   // duplicate exists

use cps_temp, clear
drop if pid==0
drop if wgt==.     // then duplicate does not exist
format pid %25.3f
egen pidnew=group(pid)
gen double t=date
assert t==date
gen double pidnewdate=pidnew*1000+t
format pidnewdate %25.3f
sort pidnewdate
gen dup=0
replace dup=1 if pidnewdate[_n]==pidnewdate[_n-1]   
sort dup

use cps_temp, clear
drop if pid==0
drop if wgt==. 
egen pidnew=group(pid)
drop pid
rename pidnew pid 
reshape wide wgt emp age retired state, i(pid) j(date)
save cps_reshape, replace 



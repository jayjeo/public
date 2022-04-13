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


/*********************************************
Required programs
*********************************************/
ssc install asgen

*To completely uninstall the files
*ado uninstall filename



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
*keep if 35<=age&age<=70
keep if inlist(popstat,1,3)  // civilians

gen emp=0
replace emp=1 if inlist(empstat,10,12)   // employed
replace emp=2 if inlist(empstat,20,21,22)  // unemployed
replace emp=3 if inlist(empstat,30,31,32,33,34,35,36)  // inactive
drop if emp==0
*keep if date>=683 // 2016.12     (earliest=590 (2009.03))

gen retired=0
replace retired=1 if empstat==36
keep date wgt state pid emp age retired
save cps_temp, replace 

/*
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
*/



/*********************************************
By state (quarter)
*********************************************/
use cps_temp, clear
drop if pid==0
drop if wgt==. 
drop emp
egen pidnew=group(pid)
drop pid
rename pidnew pid 
reshape wide wgt age retired state, i(pid) j(date)
save cps_reshape, replace 

use cps_reshape, clear

forvalues i=600(1)745 {
    local j=`i'+1
    gen startretired`j'=0
    replace startretired`j'=1 if retired`i'==0&retired`j'==1
}
save cps_startretired, replace 

use cps_startretired, clear
gen datenew=.

forvalues i=603(3)746 {
    preserve
        local j=`i'+1
        local k=`j'+1
        keep pid wgt`i' age`i' state`i' startretired`i' startretired`j' startretired`k'
        keep if startretired`i'==1|startretired`j'==1|startretired`k'==1
        collapse (mean) ageretired`i'=age`i' [pweight=wgt`i'], by(state`i')
        rename state`i' state
        save ageretired`i', replace
    restore
}

use ageretired603, clear
forvalues i=606(3)744 {
    merge 1:1 state using ageretired`i', nogenerate
}
save ageretired_merged, replace 

use ageretired_merged, clear
reshape long ageretired, i(state) j(date)
gen td = dofm(date)
gen quarter = qofd(td)
format date %tm
drop date td

xtset state quarter, quarterly
xtline ageretired, overlay legend(off)
scatter ageretired quarter


keep if state==6
xtline ageretired, overlay legend(off)



/*********************************************
Total nation (quarterly)
*********************************************/
use cps_temp, clear
drop if pid==0
drop if wgt==. 
drop emp
egen pidnew=group(pid)
drop pid
rename pidnew pid 
reshape wide wgt age retired, i(pid) j(date)
save cps_reshapen, replace 

use cps_reshapen, clear

forvalues i=600(1)745 {
    local j=`i'+1
    gen startretired`j'=0
    replace startretired`j'=1 if 30<=age`i'&age`i'<=70&retired`i'==0&retired`j'==1
}
save cps_startretiredn, replace 

use cps_startretiredn, clear
gen datenew=.

forvalues i=603(3)746 {
    preserve
        local j=`i'+1
        local k=`j'+1
        keep pid wgt`i' age`i' startretired`i' startretired`j' startretired`k'
        keep if startretired`i'==1|startretired`j'==1|startretired`k'==1
        collapse (mean) ageretired`i'=age`i' [pweight=wgt`i']
        save ageretired`i', replace
    restore
}

use ageretired603, clear
forvalues i=606(3)744 {
    append using ageretired`i'
}
save ageretired_appended, replace 

use ageretired_appended, clear
gen i=_n
reshape long ageretired, i(i) j(date)
drop if ageretired==.
drop i 
gen td = dofm(date)
gen quarter = qofd(td)
format date %tm
drop date td

tsset quarter, quarterly
tsline ageretired, legend(off)
scatter ageretired quarter





/*********************************************
By state (simple calculation)
*********************************************/
use cps_temp, clear
drop if pid==0
drop if wgt==. 
drop emp
egen pidnew=group(pid)
drop pid
rename pidnew pid 

collapse (mean) ageretired=age [pweight=wgt] if retired==1&30<=age&age<=70, by(state date)
*collapse (mean) ageretired=age [pweight=wgt] if retired==1, by(state date)
save cps_reshape_simple, replace 

use cps_reshape_simple, clear
format date %tm
xtset state date, monthly
xtline ageretired, overlay legend(off)
scatter ageretired date

/*********************************************
Total nation (simple calculation)
*********************************************/
use cps_temp, clear
drop if pid==0
drop if wgt==. 
drop emp
egen pidnew=group(pid)
drop pid
rename pidnew pid 

collapse (mean) ageretired=age [pweight=wgt] if retired==1&30<=age&age<=70, by(date)
save cps_reshape_simplen, replace 

use cps_reshape_simplen, clear
format date %tm
tsset date, monthly
tsline ageretired, legend(off)


forvalues i=600(1)745 {
    gen startretired`j'=0
    replace startretired`j'=1 if 30<=age`i'&age`i'<=70&retired`i'==0&retired`j'==1
}
save cps_startretired, replace 

use cps_startretired, clear
gen datenew=.

forvalues i=603(3)746 {
    preserve
        local j=`i'+1
        local k=`j'+1
        keep pid wgt`i' age`i' state`i' startretired`i' startretired`j' startretired`k'
        keep if startretired`i'==1|startretired`j'==1|startretired`k'==1
        collapse (mean) ageretired`i'=age`i' [pweight=wgt`i'], by(state`i')
        rename state`i' state
        save ageretired`i', replace
    restore
}

use ageretired603, clear
forvalues i=606(3)744 {
    merge 1:1 state using ageretired`i', nogenerate
}
save ageretired_merged, replace 

use ageretired_merged, clear
reshape long ageretired, i(state) j(date)
gen td = dofm(date)
gen quarter = qofd(td)
format date %tm
drop date td





/*********************************************
By state (monthly), probability of becoming inactive
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
*keep if 35<=age&age<=70
keep if inlist(popstat,1,3)  // civilians
gen emp=0
replace emp=1 if inlist(empstat,10,12)   // employed
replace emp=2 if inlist(empstat,20,21,22)  // unemployed
replace emp=3 if inlist(empstat,30,31,32,33,34,35,36)  // inactive
drop if emp==0
*keep if date>=683 // 2016.12     (earliest=590 (2009.03))
keep date wgt state pid emp
save cps_temp_inactive, replace 

use cps_temp_inactive, clear
drop if pid==0
drop if wgt==. 
egen pidnew=group(pid)
drop pid
rename pidnew pid 
reshape wide wgt emp state, i(pid) j(date)
save cps_reshape_inactive, replace 

use cps_reshape_inactive, clear
forvalues i=600(1)745 {
    local j=`i'+1
    gen startinactive`j'=0 if emp`i'==2&emp`j'==2
    replace startinactive`j'=1 if emp`i'==2&emp`j'==3
}
save cps_startinactive, replace 

use cps_startinactive, clear
gen startinactive600=.
reshape long wgt startinactive state, i(pid) j(date)
keep pid wgt startinactive state
collapse (mean) startinactive_prob=startinactive [pweight=wgt], by(state date)
format date %tm
drop date td
xtset state date, monthly
xtline startinactive_prob, overlay legend(off)




/*********************************************
By state (monthly) individual
*********************************************/
//!start
cd "${path}"
use cps_temp, clear
drop if pid==0
drop if wgt==. 
drop emp
egen pidnew=group(pid)
drop pid
rename pidnew pid 
sort pid date 
save cps_indi_1, replace


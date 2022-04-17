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

gen edu=0
replace edu=1 if 91<=educ
drop if educ==999

keep date wgt state pid emp age retired sex edu
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
keep wgt age retired state pid date
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

gen edu=0
replace edu=1 if 91<=educ
drop if educ==999

keep date wgt state pid emp age retired sex edu
save cps_temp, replace 

cd "${path}"
use cps_temp, clear
drop if pid==0
drop if wgt==. 
egen pidnew=group(pid)
drop pid
rename pidnew pid 
sort pid date 
save cps_indi_1, replace

clear all
set maxvar  32767, perm 

use cps_indi_1, clear
*keep if 40<=age&age<=64
gen startretired=0
replace startretired=1 if pid[_n-1]==pid[_n]&retired[_n-1]==0&retired[_n]==1&inlist(emp[_n-1],1,2)
keep if startretired==1
*xtset state date
format date %tm
*drop if state==1|state==2
*twoway (scatter age date, msize(tiny))
*graph box age if age>40, over(date)
*keep if edu==0

gen D=0
replace D=1 if date>=720

*keep if date>=696
xtset pid date
gen t=date-720
drop date
gen t1=t
gen t2=t*t
gen t3=t*t*t
gen t4=t*t*t*t
gen t5=t*t*t*t*t
gen Dt1=D*t1
gen Dt2=D*t2
gen Dt3=D*t3
gen Dt4=D*t4
gen Dt5=D*t5
*xi: reg age t t2 t3 D Dt1 Dt2 Dt3 I.sex I.edu  [pweight=wgt], vce(cluster state) noconstant
*predict age_pr

*sort age_pr
*scatter age_pr t
*scatter age t

*npregress kernel demsharenext difdemshare right
generate u = runiform()
replace t=t+u
npregress kernel age t I.D, dkernel(liracine) 
predict mage

capture program drop graph2
program graph2
	args mp bandwidth fit
	local min = 201-`bandwidth'
	local max = 201+`bandwidth'
	graph twoway (line `mp' t, sort lcolor(gs0) clwidth(vvthin)) 
end


graph2 mage 200 "Local Linear Regression"
scatter mage t




/*********************************************
Individual (monthly), tendency to be inactive vs active
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

gen retired=0
replace retired=1 if empstat==36

gen edu=0
replace edu=1 if 91<=educ
drop if educ==999

keep date wgt state pid emp age sex edu wnlook
save cps_temp, replace 

cd "${path}"
use cps_temp, clear
drop if pid==0
drop if wgt==. 
egen pidnew=group(pid)
drop pid
rename pidnew pid 
sort pid date 
save cps_indi_1, replace

use cps_indi_1, clear
*keep if 40<=age&age<=64
gen inflow=.
replace inflow=1 if pid[_n-1]==pid[_n]&emp[_n-1]==3&inlist(emp[_n],1,2)
replace inflow=0 if pid[_n-1]==pid[_n]&inlist(emp[_n-1],1,2)&emp[_n]==3

*xtset state date
format date %tm
*drop if state==1|state==2
*twoway (scatter age date, msize(tiny))
*graph box age if age>40, over(date)
*keep if edu==0

gen D=0
replace D=1 if date>=720

keep if date>=696
xtset pid date
gen t=date-720
drop date
gen t1=t
gen t2=t*t
gen t3=t*t*t
gen t4=t*t*t*t
gen t5=t*t*t*t*t
gen Dt1=D*t1
gen Dt2=D*t2
gen Dt3=D*t3
gen Dt4=D*t4
gen Dt5=D*t5
*xi: reg age t t2 t3 D Dt1 Dt2 Dt3 I.sex I.edu  [pweight=wgt], vce(cluster state) noconstant
*predict age_pr

*sort age_pr
*scatter age_pr t
*scatter age t

*npregress kernel demsharenext difdemshare right
generate u = runiform()
replace t=t+u
npregress kernel inflow t I.D, dkernel(liracine) 
predict minflow

capture program drop graph2
program graph2
	args mp bandwidth fit
	local min = 201-`bandwidth'
	local max = 201+`bandwidth'
	graph twoway (line `mp' t, sort lcolor(gs0) clwidth(vvthin)) 
end

graph2 minflow 200 "Local Linear Regression"
scatter minflow t*t


//!start
cd "E:\Dropbox\Study\GitHub\public\EarlyRetirementsUSA\csse_covid_19_daily_reports_us"
forvalues i=1(1)733{
    import delimited "`i'.csv", clear 
    gen filename=`i'
    save `i', replace 
}
use 1, clear
forvalues i=2(1)733{
    append using `i'
}
drop if fips==.
drop if fips==11 // District of Columbia
drop if inlist(fips,60,66,69,72,888,999)  // American Samoa, Guam, Northern Mariana Islands, Puerto Rico, Diamond Princess, Grand Princess  
drop if fips>56
rename fips state
save covid_temp, replace 

use covid_temp, clear
gen year=substr(last_update,1,4)
gen month=substr(last_update,6,2)
gen day=substr(last_update,9,2)
destring year, replace 
destring month, replace 
destring day, replace 
gen mdy=mdy(month,day,year)
format mdy %td
gen tm=mofd(mdy)
format tm %tm
keep state tm incident_rate //Incidence Rate = cases per 100,000 persons.
collapse (mean) incident_rate, by(tm state)
rename tm date
rename incident_rate covid
xtset state date
tsappend, add(1)
replace date=719 if date==748
tsfill
replace covid=0.1 if date==719
by state: mipolate covid date, gen(covid2) pchip
drop covid
rename covid2 covid
cd "E:\Dropbox\Study\UC Davis\Writings\EarlyRetirementsUSA\data"
save covid, replace 

cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"
use JOLTS, clear
rename statemerge state
keep if 600<=date&date<=743
keep Jobopeningsrate state date
reshape wide Jobopeningsrate, i(state) j(date)
forvalues i=600(1)743 {
    gen vCHG`i'=Jobopeningsrate`i'-Jobopeningsrate719
}
reshape long vCHG Jobopeningsrate, i(state) j(date)
cd "E:\Dropbox\Study\UC Davis\Writings\EarlyRetirementsUSA\data"
save JOLTS_vCHG, replace 

cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"
use JOLTS, clear
rename statemerge state
keep if 600<=date&date<=743
keep Hires numD date state
cd "E:\Dropbox\Study\UC Davis\Writings\EarlyRetirementsUSA\data"
save JOLTS_Hire, replace 

import delimited "E:\Dropbox\Study\GitHub\public\EarlyRetirementsUSA\GDPbyState.csv", clear 
reshape long quarter, i(state) j(dateq)
rename quarter gdp
tostring dateq, replace 
gen year=substr(dateq,1,4)
gen quarter=substr(dateq,5,1)
destring year, replace 
destring quarter, replace 
gen tq=yq(year,quarter)
gen tqt=tq
format tqt %tq
drop dateq year quarter 
gen mdate = mofd(dofq(tq)) + 1
xtset state mdate
format mdate %tm
tsfill
sort state mdate 
*net install mipolate.pkg
by state: mipolate gdp mdate, gen(gdp2) pchip
preserve
    keep if state==6
    set scheme s1color
    twoway connected gdp2 mdate, ms(+) || scatter gdp mdate, ///
    legend(order(1 "guessed" 2 "known"))  xtitle("") yla(, ang(h)) ytitle(GDP, orient(horiz))
restore 
keep state gdp2 mdate
rename gdp2 gdp
rename mdate date
cd "E:\Dropbox\Study\UC Davis\Writings\EarlyRetirementsUSA\data"
save gdp, replace

use cps_indi_1, clear
keep if 20<=age&age<=64
gen active=1 if inlist(emp,1,2)
gen unemp=1 if inlist(emp,2)
preserve 
    collapse (sum) active [pweight=wgt], by(date state)
    save active, replace 
restore
preserve 
    collapse (sum) unemp [pweight=wgt], by(date state)
    save unemp, replace 
restore

use active, clear
merge 1:1 date state using unemp, nogenerate
gen u=unemp/active*100
drop active unemp
save u, replace 

use cps_indi_1, clear
keep if 20<=age&age<=64
gen inflow=.
gen whyinactive=1 if inlist(wnlook,6,7,9)
replace inflow=1 if pid[_n-1]==pid[_n]&emp[_n-1]==3&whyinactive[_n-1]!=1&inlist(emp[_n],1,2)
replace inflow=0 if pid[_n-1]==pid[_n]&inlist(emp[_n-1],1,2)&emp[_n]==3&whyinactive[_n]!=1
format date %tm
rename state state
drop if inflow==.
collapse (mean) inflow [pweight=wgt], by(date state)
replace inflow=inflow*100
merge 1:1 date state using u
keep if _merge==3
drop _merge
merge 1:1 date state using JOLTS_vCHG, nogenerate
merge 1:1 date state using JOLTS_Hire, nogenerate 
merge 1:1 date state using gdp, nogenerate
merge 1:1 date state using covid
keep if _merge==3
drop _merge
sort date state
tsfill 
drop if state==0
drop if state==15  // Hawaii
gen v=Jobopeningsrate
gen l=numD/(1-u/100)
save cps_indi_2, replace 
foreach i of numlist 1 2 4 5 6 8 9 10 12 13 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
    preserve
        keep if state==`i'
        gen lnF=ln(F1.Hire/(u/100)/l)
        gen lntheta=ln(v/u)
        reg lnF lntheta
        gen k=_b[lntheta]
        keep k state
        keep if _n==1
        save k`i', replace 
    restore
}
use k1, clear
foreach i of numlist 2 4 5 6 8 9 10 12 13 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
    append using k`i'
}
save k, replace 

use cps_indi_2, clear 
merge m:1 state using k, nogenerate
xtset state date
sort state date 
gen matcheff=F1.Hire/(u/100*l*(v/u)^k) 
keep if 719<=date  // 2019m12
keep if 696<=date  // 2018m1
drop if date>=743  // 2021m12
gen t=date-718
format t %3.0f
save master1, replace

use master1, clear
xtset state t
gen lnv=ln(v)
gen lninflow=ln(inflow)
gen lnmatcheff=ln(matcheff)
gen lngdp=ln(gdp)
gen lncovid=ln(covid)

tsfilter hp inflow_hp = inflow, trend(smooth_inflow) smooth(1)
tsfilter hp vCHG_hp = vCHG, trend(smooth_vCHG) smooth(1)
tsfilter hp v_hp = v, trend(smooth_v) smooth(1)
tsfilter hp gdp_hp = gdp, trend(smooth_gdp) smooth(1)
tsfilter hp covid_hp = covid, trend(smooth_covid) smooth(1)

**** FE regression
xi: xtreg smooth_vCHG smooth_inflow smooth_gdp, fe vce(cluster state)
xi: xtreg smooth_v smooth_inflow smooth_gdp, fe vce(cluster state)
xi: xtreg v inflow gdp covid, fe vce(cluster state)
xi: xtreg v matcheff gdp covid, fe vce(cluster state)
xi: xtreg lnv lninflow lnmatcheff lngdp lncovid, fe vce(cluster state)

**** Arellano and Bond (1991) First-differenced GMM estimator.
xtdpd smooth_vCHG L.vCHG smooth_inflow smooth_gdp, dgmm(L.smooth_vCHG smooth_inflow smooth_gdp, lag(1))

**** Arellano and Bond (1991) Linear dynamic panel GMM estimator.
xtabond smooth_vCHG smooth_inflow, lags(2) pre(smooth_gdp smooth_covid)
xtabond smooth_v smooth_inflow, lags(2) pre(smooth_gdp smooth_covid)
xtabond v inflow, lags(1) pre(gdp covid)
xtabond v matcheff, lags(1) pre(gdp covid)
xtabond v inflow matcheff, lags(1) pre(gdp covid)
xtabond lnv lninflow lnmatcheff, lags(3) pre(gdp lncovid)

**** Moral-Benito et al. (2019) Dynamic Panel Data Model using ML
xtdpdml smooth_vCHG smooth_inflow, predetermined(smooth_gdp) ylag(1 2) 
xtdpdml vCHG inflow gdp, ylag(2) iterate(50) technique(nr 25 bhhh 25) fiml
xtdpdml v inflow gdp covid, ylag(2) iterate(50) technique(nr 25 bhhh 25) fiml
xtdpdml lnv lninflow lnmatcheff, ylag(1 2 3) pre(gdp lncovid)


keep if state==8
tsset t
twoway(tsline v, yaxis(1))(tsline inflow, yaxis(2))(tsline matcheff, yaxis(3))


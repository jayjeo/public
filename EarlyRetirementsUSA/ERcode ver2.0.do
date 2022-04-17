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



/*********************************************
JOLTS Data (Seasonally unadjusted)
*********************************************/
//!start
cd "${path}"
foreach variable in "Jobopeningsrate" "Jobopenings" "Hires" {
    foreach state in  "TotalUS" "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "DistrictofColumbia" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "NewHampshire" "NewJersey" "NewMexico" "NewYork" "NorthCarolina" "NorthDakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "RhodeIsland" "SouthCarolina" "SouthDakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "WestVirginia" "Wisconsin" "Wyoming" {
        import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortageUSA/data/JOLTS(unadjusted)/`variable'_`state'.csv", varnames(1) clear 
        rename (jan feb mar apr may jun jul aug sep oct nov dec) (m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12)
        reshape long m, i(year) j(month)
        rename m `variable'
        gen state="`state'"
        gen date=ym(year,month)
        drop year month
        tsset date
        format date %tm
        save `variable'_`state', replace 
    }
}

//!start
cd "${path}"
foreach state in  "TotalUS" "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "DistrictofColumbia" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "NewHampshire" "NewJersey" "NewMexico" "NewYork" "NorthCarolina" "NorthDakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "RhodeIsland" "SouthCarolina" "SouthDakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "WestVirginia" "Wisconsin" "Wyoming" {
        use Jobopeningsrate_TotalUS, clear
        drop Jobopeningsrate state
    foreach variable in "Jobopeningsrate" "Jobopenings" "Hires" {
        merge 1:1 date using `variable'_`state', nogenerate
    }
    save `state', replace
    }

//!start
use TotalUS, clear
foreach state in "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "DistrictofColumbia" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "NewHampshire" "NewJersey" "NewMexico" "NewYork" "NorthCarolina" "NorthDakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "RhodeIsland" "SouthCarolina" "SouthDakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "WestVirginia" "Wisconsin" "Wyoming" {
        append using `state'
    }
gen numD=(100/Jobopeningsrate-1)*Jobopenings  // numD = number of employment
drop Jobopeningsrate
save JOLTS_temp1, replace 

//!start (merge DistrictofColumbia and Maryland)
use JOLTS_temp1, clear
keep if inlist(state,"DistrictofColumbia","Maryland")
sort date state
gen statenum=1 if state=="DistrictofColumbia"
replace statenum=2 if state=="Maryland"
drop state 
reshape wide numD Jobopenings Hires Quits Totalseparations Layoffsanddischarges, i(date) j(statenum)
foreach var in numD Jobopenings Hires Quits Totalseparations Layoffsanddischarges {
        gen `var'=`var'1+`var'2
        drop `var'1 `var'2
    }
gen state="Maryland"
save Maryland, replace

//!start
use JOLTS_temp1, clear
drop if inlist(state,"DistrictofColumbia","Maryland")
append using Maryland
sort state date 

gen Jobopeningsrate=Jobopenings/(Jobopenings+numD)*100

gen statemerge=1 if state=="Alabama"
replace statemerge=2 if state=="Alaska"
replace statemerge=4 if state=="Arizona"
replace statemerge=5 if state=="Arkansas"
replace statemerge=6 if state=="California"
replace statemerge=8 if state=="Colorado"
replace statemerge=9 if state=="Connecticut"
replace statemerge=10 if state=="Delaware"
replace statemerge=12 if state=="Florida"
replace statemerge=13 if state=="Georgia"
replace statemerge=15 if state=="Hawaii"
replace statemerge=16 if state=="Idaho"
replace statemerge=17 if state=="Illinois"
replace statemerge=18 if state=="Indiana"
replace statemerge=19 if state=="Iowa"
replace statemerge=20 if state=="Kansas"
replace statemerge=21 if state=="Kentucky"
replace statemerge=22 if state=="Louisiana"
replace statemerge=23 if state=="Maine"
replace statemerge=24 if state=="Maryland"
replace statemerge=25 if state=="Massachusetts"
replace statemerge=26 if state=="Michigan"
replace statemerge=27 if state=="Minnesota"
replace statemerge=28 if state=="Mississippi"
replace statemerge=29 if state=="Missouri"
replace statemerge=30 if state=="Montana"
replace statemerge=31 if state=="Nebraska"
replace statemerge=32 if state=="Nevada"
replace statemerge=33 if state=="NewHampshire"
replace statemerge=34 if state=="NewJersey"
replace statemerge=35 if state=="NewMexico"
replace statemerge=36 if state=="NewYork"
replace statemerge=37 if state=="NorthCarolina"
replace statemerge=38 if state=="NorthDakota"
replace statemerge=39 if state=="Ohio"
replace statemerge=40 if state=="Oklahoma"
replace statemerge=41 if state=="Oregon"
replace statemerge=42 if state=="Pennsylvania"
replace statemerge=44 if state=="RhodeIsland"
replace statemerge=45 if state=="SouthCarolina"
replace statemerge=46 if state=="SouthDakota"
replace statemerge=47 if state=="Tennessee"
replace statemerge=48 if state=="Texas"
replace statemerge=49 if state=="Utah"
replace statemerge=50 if state=="Vermont"
replace statemerge=51 if state=="Virginia"
replace statemerge=53 if state=="Washington"
replace statemerge=54 if state=="WestVirginia"
replace statemerge=55 if state=="Wisconsin"
replace statemerge=56 if state=="Wyoming"
replace statemerge=0 if state=="TotalUS"
drop state
save JOLTSunadjusted, replace 


/*********************************************
CPS IPUMS Data
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
save master0, replace 

******************************************************
******************************************************
* Estimate Match efficiency by state
******************************************************
******************************************************
//!start
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"
use JOLTS, clear
rename statemerge state
cd "E:\Dropbox\Study\UC Davis\Writings\EarlyRetirementsUSA\data"
merge 1:1 date state using u
keep if _merge==3
drop _merge
sort state date
xtset state date
rename Jobopeningsrate v
gen theta=ln(v/u)
gen l=numD/(1-u/100)
gen jfr=ln(F1.Hires/(u/100)/l)
drop if jfr==.
gen year=year(dofm(date))
gen month=month(dofm(date))
gen t=date-599
keep year month date t jfr theta u state
tab month, gen(m_)
drop m_1
save matcheffmaster, replace 

cap program drop estim_grid
program define estim_grid
syntax [, P(real 1) Q(real 1) ADDLAGSTH(integer 1) LAGSJFR(integer 1) PMAX(integer 1) SELECT(string) ETA0(real 1) GRAPH] 
	
	preserve
	
	if "`select'"~=""	keep if `select'
	
	local first = `q' + 1
	
	local last_th = `q' + `p' + 1 + `addlagsth'
	local laglist_th "`first'/`last_th'"
	
	if `lagsjfr'>0	{
		local last_jfr = `q' + `lagsjfr'
		local laglist_jfr "`first'/`last_jfr'"
					}
		
	if `lagsjfr'>0	local inst "l(`laglist_th').theta l(`laglist_jfr').jfr m_*"
	else local inst "l(`laglist_th').theta m_*"
	
	local addobs = 100
		
	// Instruments = 0 if missing
	local new_n = _N + `addobs'
	set obs `new_n'
	recode * (.=0)
	sort t
	replace t = _n  
	sort t
	tsset t
	gen insamp = (t>=`addobs' + max(`q'+2,`p'+1))
	
	// Proper IV imposing common factor restriction , full sample
	local urtest "(-1)"

	local esteq "jfr - {eta}*theta - {mu}"
	forval m = 2/12	{
		local esteq "`esteq' - {tau`m'}*m_`m'"
					}		
	forval l = 1/`p'	{
		
		local urtest "[rho`l']_cons + `urtest'"
		
		local esteq "`esteq' - {rho`l'}*(l`l'.jfr - {eta}*l`l'.theta"
		forval m = 2/12	{
			local esteq "`esteq' - {tau`m'}*l`l'.m_`m'"
						}	
		local esteq "`esteq')"
						}

	local esteq "(`esteq')"
	local urtest "`urtest' == 0"
		
	mat m = J(5 + 2*(`pmax'+2) ,1,.)
	mat m[1,1] = `p'
	mat m[2,1] = `q'
	
	cap	{
		noi gmm `esteq' if insamp, instruments(`inst') twostep vce(unadjusted) wmatrix(unadjusted) from(mu 0 eta `eta0')
		
		mat V = e(V)
		
		// Retrieve the actual constant and its SE
		matrix V = V["mu:_cons","mu:_cons".."rho`p':_cons"] \ V["rho1:_cons".."rho`p':_cons","mu:_cons".."rho`p':_cons"]
		matrix V = V[1...,"mu:_cons"] , V[1...,"rho1:_cons".."rho`p':_cons"]
		local denom = 1
		forval arp = 1/`p'	{
			local denom = `denom'-[rho`arp']_b[_cons]
							}
							
		local mu = [mu]_b[_cons]/`denom'
		
		mat G = 1/`denom' \ J(`p',1,`mu'/`denom')
		mat SE = G'*V*G
				
		matrix m[3,1] = sqrt(SE[1,1]) \ `mu' 
		* matrix m[3,1] = [mu]_se[_cons] \ [mu]_b[_cons]  
		matrix m[5,1] = [eta]_se[_cons] \ [eta]_b[_cons] 
		forv arp = 1/`p'	{
			/*
			local t = [rho`arp']_b[_cons] / [rho`arp']_se[_cons]
			matrix m[6 + 2*`arp'-1 ,1] = `t' \ [rho`arp']_b[_cons]
			*/
			
			matrix m[6 + 2*`arp'-1 ,1] = [rho`arp']_se[_cons] \ [rho`arp']_b[_cons] 
			
							}
			
		test "`urtest'"
		matrix m[6 + 2*`pmax' + 1,1] = r(p)
		
		noi estat overid
		matrix m[6 + 2*`pmax' + 2,1] = r(J) \ r(J_p)
				
		if "`graph'"~=""	{
			predict omega if insamp
			noi ac omega if insamp, lag(18) level(90) text(-.15 14 "(p,q) = (`p',`q')", box place(e) margin(medsmall)) /*
				*/ note("") xlab(0(2)18) scheme(s1mono) name(name`p'`q', replace)
							}
		}
	restore
end

*** p selection protocol
cap program drop estim_state
program define estim_state
    args state 
        use matcheffmaster, clear
        keep if state==`state'

        qui	{
        local pmin = 1
        local pmax = 6

        matrix results = J(5 + 2*(`pmax'+2),1,.)
        local rnames "p q sd(mu) mu sd(eta) eta"
        noi di "--------------------------------------------------"
        forv p = 1/`pmax'	{
            local rnames "`rnames' sd(rho`p') rho`p'"
            
            if `p'>=`pmin'	{
                forv q = 0/6	{
                    noi di _con "(`p' , `q') -- "
                    estim_grid, p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) eta0(0.7)
                    matrix results = (results , m)
                                }	
                            }
                            }

        noi di " "
        noi di "--------------------------------------------------"
        local rnames "`rnames' UR_p Hansen Hans_p"
        mat rownames results = `rnames'
        mat results = results[1...,2...]
        mat results = results'
        }

        matain results
        // p and q
        mata rest=results[.,1],results[.,2]
        // p-value for mu
        mata z=abs(results[.,4]:/results[.,3])
        mata rest1=2*normal(-abs(z))
        // eta
        mata eta=results[.,6]
        // p-value for eta
        mata z=abs(results[.,6]:/results[.,5])
        mata rest2=2*normal(-abs(z))
        // p-value for rho1
        mata z=abs(results[.,8]:/results[.,7])
        mata rest3=2*normal(-abs(z))
        // p-value for rho2
        mata z=abs(results[.,10]:/results[.,9])
        mata rest4=2*normal(-abs(z))
        // p-value for rho3
        mata z=abs(results[.,12]:/results[.,11])
        mata rest5=2*normal(-abs(z))
        // p-value for rho4
        mata z=abs(results[.,14]:/results[.,13])
        mata rest6=2*normal(-abs(z))
        // p-value for rho5
        mata z=abs(results[.,16]:/results[.,15])
        mata rest7=2*normal(-abs(z))
        // p-value for rho6
        mata z=abs(results[.,18]:/results[.,17])
        mata rest8=2*normal(-abs(z))

        mata rest=rest,rest1,eta,rest2,rest3,rest4,rest5,rest6,rest7,rest8
        mata rest 
end

*** q selection protocol
cap prog drop fig
program define fig
args state pvalu
    use matcheffmaster, clear
    keep if state==`state'
    forvalue ii=1(1)6{
        qui{
        estim_grid, p(`pvalu') q(`ii') pmax(`pvalu') addlagsth(0) lagsjfr(1) eta0(0.7) graph
        }
    }
    graph combine name`pvalu'1 name`pvalu'2 name`pvalu'3 name`pvalu'4 name`pvalu'5 name`pvalu'6
end

************************ Manually decide p and q by states using the selection protocols provided by Borowczyk-Martins2013 (put state number)
*** p selection protocol 
estim_state 2

*** q selection protocol
fig 1 1

******************************************************
******************************************************
******************************************************
******************************************************


use master0, clear
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


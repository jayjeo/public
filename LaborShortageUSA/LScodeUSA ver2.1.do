** LScodeUSA ver2.0.do

cls
clear all
set scheme s1color, perm 

/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"  
/*********************************************
*********************************************/



/*********************************************
JOLTS Data
*********************************************/
//!start
cd "${path}"
foreach variable in "Jobopeningsrate" "Jobopenings" "Hires" "Quits" "Totalseparations" "Layoffsanddischarges" {
    foreach state in  "TotalUS" "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "DistrictofColumbia" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "NewHampshire" "NewJersey" "NewMexico" "NewYork" "NorthCarolina" "NorthDakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "RhodeIsland" "SouthCarolina" "SouthDakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "WestVirginia" "Wisconsin" "Wyoming" {
        import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortageUSA/data/JOLTS/`variable'_`state'_SeriesReport.csv", varnames(1) clear 
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
    foreach variable in "Jobopeningsrate" "Jobopenings" "Hires" "Quits" "Totalseparations" "Layoffsanddischarges" {
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
save JOLTS, replace 

use JOLTS, clear 
keep date statemerge Jobopeningsrate
egen statenum=group(statemerge)
drop statemerge 
xtset statenum date
xtline Jobopeningsrate, overlay legend(off)


/*********************************************
*********************************************
*********************************************
*********************************************
*********************************************
*********************************************/
/*********************************************
CPS IPUMS Data
*********************************************/
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\rawdata\CPS"

//!start
/*
Manunally download a file from https://www.dropbox.com/s/xlyk90gm0o93e3j/cps.dta
2GB, it will take long time to download. 

save cps, replace 
*/


//!start
use cps, clear
gen num=1
format num %12.0g

replace statefip=24 if statefip==11  // include District of Columbia into Maryland. 
rename wtfinl wgt  // weight
gen date=ym(year,month)
drop year month
format date %tm

keep if 20<=age&age<=64
keep if inlist(popstat,1,3)  // civilians
*keep if inlist(labforce,1,2)  
gen t=date 

gen emp=0
replace emp=1 if inlist(empstat,10,12)   // employed
replace emp=2 if inlist(empstat,20,21,22)  // unemployed
replace emp=3 if inlist(empstat,30,31,32,33,34,35,36)  // inactive
drop if emp==0

rename ind1990 ind2
gen indb=0
replace indb=1 if 1<=ind2&ind2<40 // agriculture
replace indb=2 if 40<=ind2&ind2<400 // mining, construction, manufacturing
replace indb=3 if 400<=ind2&ind2<500 // transportation, communications, and other public utilities
replace indb=4 if 500<=ind2&ind2<700 // Wholesale trade, Retail trade
replace indb=5 if 700<=ind2&ind2<761 // FINANCE, INSURANCE, AND REAL ESTATE , BUSINESS AND REPAIR SERVICES
replace indb=6 if 761<=ind2&ind2<812 // PERSONAL SERVICES, ENTERTAINMENT AND RECREATION SERVICES
replace indb=7 if 812<=ind2&ind2<1000 // PROFESSIONAL AND RELATED SERVICES, PUBLIC ADMINISTRATION,  ACTIVE DUTY MILITARY, etc

*drop if yrimmig==0000 // never drop. it includes domestic citizens. 
gen yrim=0
replace yrim=1 if 1949<=yrimmig&yrimmig<1981
replace yrim=2 if 1981<=yrimmig&yrimmig<2000
replace yrim=3 if 2000<=yrimmig&yrimmig<2015
replace yrim=4 if 2015<=yrimmig
*drop if yrim==0 // never drop. it includes domestic citizens. 

save CPS2, replace 


/*
collapse (sum) num [pweight=wgt], by(date emp)
emp 1+2+3 = Civilian noninstitutional population
emp 1+2 = Civilian labor force
emp 1 = Employed
emp 2 = Unemployed
emp 3 = Not in labor force (inactive)
*/


//!start (Draw a graph)
use CPS2, clear 
keep if emp==1
keep if citizen==5  // Foreigner
*keep if yrim==4
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Ft_emp
replace Ft_emp=Ft_emp/1000   // million
keep if date>=660
save Ft_emp, replace 

use CPS2, clear 
keep if emp==1
*keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Lt_emp
replace Lt_emp=Lt_emp/1000   // million
keep if date>=660
save Lt_emp, replace 

use CPS2, clear 
*keep if emp==1
keep if citizen==5  // Foreigner
*keep if yrim==4
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Ft_tot
replace Ft_tot=Ft_tot/1000   // million
keep if date>=660
save Ft_tot, replace 

use CPS2, clear 
*keep if emp==1
*keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Lt_tot
replace Lt_tot=Lt_tot/1000   // million
keep if date>=660
save Lt_tot, replace 

use Lt_tot, clear
merge 1:1 date using Ft_tot, nogenerate
merge 1:1 date using Ft_emp, nogenerate
merge 1:1 date using Lt_emp, nogenerate
gen FLt_tot=Ft_tot/Lt_tot*100
gen FLt_emp=Ft_emp/Lt_emp*100
tsset date
tsline FLt_tot FLt_emp

gen Dt_tot=(Lt_tot-Ft_tot)   
gen Dt_emp=(Lt_emp-Ft_emp)   

twoway (tsline Dt_tot, lcolor(gs0) lwidth(thick))(tsline Ft_tot, lcolor(red) lwidth(thick))(tsline Dt_emp, lcolor(gs0) lpattern(dashed))(tsline Ft_emp, lcolor(red) lpattern(dashed)) ///
, xtitle("") ytitle("Million person") xline(720) xline(723) /// 
legend(label(1 "Domestic Population") label(2 "Foreign Population") label(3 "Domestic Employment") label(4 "Foreign Employment") order(1 2 3 4))

twoway (tsline Ft_tot, lcolor(red) lwidth(thick))(tsline Ft_emp, lcolor(red) lpattern(dashed)), xline(720)


//!start
/*look at the change in immigrants Jan-2020 to Jan 2022, 
relative to the same change say Jan 2017-Jan 2019 
and see if the rate has declined a lot, across states.*/

cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\rawdata\CPS"
use CPS2, clear 
*keep if emp==1
keep if citizen==5  // Foreigner
*keep if yrim==4
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date statefip)
rename num Ft_tot
replace Ft_tot=Ft_tot/1000   // million
keep if inlist(date,684,708,720,744)
reshape wide Ft_tot, i(statefip) j(date)
gen immelas=((Ft_tot744-Ft_tot720)/(Ft_tot720))/((Ft_tot708-Ft_tot684)/(Ft_tot684))
save immelas, replace 

use immelas, clear
sort immelas
keep if -25<immelas&immelas<25
gen state=_n
twoway scatter immelas state, yline(0)

//!start
/* a scatter of 
vacancy rate change from 2019.09 to 2021.09 across states
and share of f-born in employment across states in 2019.09 */

cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\rawdata\CPS"
use CPS2, clear 
keep if emp==1
gen domestic=1
replace domestic=0 if citizen==5 // Foreigner
keep if date==716 // 2019.09
collapse (sum) num [pweight=wgt], by(domestic statefip)
rename num employment
reshape wide employment, i(statefip) j(domestic)
gen fshare=employment0/(employment1+employment0)*100
rename statefip statemerge
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"
save fshare, replace 

cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\rawdata\CPS"
use CPS2, clear 
keep if emp==1
keep if citizen==5 // Foreigner
keep if inlist(date,716,740) // 2019.09, 2021.09
collapse (sum) num [pweight=wgt], by(date statefip)
rename num foreignemp
reshape wide foreignemp, i(statefip) j(date)
gen foreignempCHGrate=(foreignemp740-foreignemp716)/foreignemp716*100
rename statefip statemerge
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"
save foreignempCHGrate, replace 

cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"
use FstIV, clear 
reshape wide FstIV, i(statemerge) j(date)
gen FstIVCHGrate=(FstIV740-FstIV716)/FstIV716*100
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"
save FstIVCHGrate, replace 

cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\rawdata\CPS"
use CPS2, clear 
keep if emp==1
drop if citizen==5 // drop foreigner
keep if inlist(date,716,723) // 2019.09, 2020.04
collapse (sum) num [pweight=wgt], by(date statefip)
rename num domesticemp
reshape wide domesticemp, i(statefip) j(date)
gen domesticemp_rate=(domesticemp723-domesticemp716)/domesticemp716*100
rename statefip statemerge
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\latex\version 1.0"
save domesticemp_rate, replace 

use JOLTS, clear 
keep date statemerge Jobopeningsrate
keep if inlist(date,716,740) // 2019.09, 2021.09
reshape wide Jobopeningsrate, i(statemerge) j(date)
gen vCHG=Jobopeningsrate740-Jobopeningsrate716  

keep statemerge vCHG Jobopeningsrate740
drop if statemerge==0
save JOLTSvCHG, replace

use fshare, clear
merge 1:1 statemerge using foreignempCHGrate, nogenerate
merge 1:1 statemerge using domesticemp_rate, nogenerate
merge 1:1 statemerge using FstIVCHGrate, nogenerate
merge 1:1 statemerge using JOLTSvCHG, nogenerate
drop if statemerge==15|statemerge==28
scatter fshare foreignempCHGrate
scatter fshare vCHG
scatter foreignempCHGrate vCHG
scatter fshare Jobopeningsrate740
scatter foreignempCHGrate Jobopeningsrate740
scatter domesticemp_rate vCHG
scatter domesticemp_rate Jobopeningsrate740
scatter foreignempCHGrate FstIVCHGrate
scatter FstIVCHGrate vCHG


reg Jobopeningsrate740 fshare domesticemp_rate
reg vCHG fshare domesticemp_rate
reg vCHG fshare domesticemp_rate
ivregress 2sls vCHG (fshare=FstIVCHGrate) domesticemp_rate
ivregress 2sls Jobopeningsrate740 (foreignempCHGrate=fshare) domesticemp_rate
ivregress 2sls Jobopeningsrate740 (FstIVCHGrate=fshare) domesticemp_rate


/*********************************************
Regression Data Generation
*********************************************/
//!start

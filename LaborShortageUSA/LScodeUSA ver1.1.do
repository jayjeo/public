** LScodeUSA ver1.0.do

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
cd "${path}"
foreach variable in "Jobopeningsrate" "Jobopenings" "Hires" "Quits" "Totalseparations" "Layoffsanddischarges" {
    foreach state in  "TotalUS"	"Alabama"	"Alaska"	"Arizona"	"Arkansas"	"California"	"Colorado"	"Connecticut"	"Delaware"	"DistrictofColumbia"	"Florida"	"Georgia"	"Hawaii"	"Idaho"	"Illinois"	"Indiana"	"Iowa"	"Kansas"	"Kentucky"	"Louisiana"	"Maine"	"Maryland"	"Massachusetts"	"Michigan"	"Minnesota"	"Mississippi"	"Missouri"	"Montana"	"Nebraska"	"Nevada"	"NewHampshire"	"NewJersey"	"NewMexico"	"NewYork"	"NorthCarolina"	"NorthDakota"	"Ohio"	"Oklahoma"	"Oregon"	"Pennsylvania"	"RhodeIsland"	"SouthCarolina"	"SouthDakota"	"Tennessee"	"Texas"	"Utah"	"Vermont"	"Virginia"	"Washington"	"WestVirginia"	"Wisconsin"	"Wyoming" {
        import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortageUSA/data/JOLTS/`variable'_`state'_SeriesReport.csv", varnames(1) clear 
        rename (jan	feb	mar	apr	may	jun	jul	aug	sep	oct	nov	dec) (m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12)
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

*!start
cd "${path}"
foreach state in  "TotalUS"	"Alabama"	"Alaska"	"Arizona"	"Arkansas"	"California"	"Colorado"	"Connecticut"	"Delaware"	"DistrictofColumbia"	"Florida"	"Georgia"	"Hawaii"	"Idaho"	"Illinois"	"Indiana"	"Iowa"	"Kansas"	"Kentucky"	"Louisiana"	"Maine"	"Maryland"	"Massachusetts"	"Michigan"	"Minnesota"	"Mississippi"	"Missouri"	"Montana"	"Nebraska"	"Nevada"	"NewHampshire"	"NewJersey"	"NewMexico"	"NewYork"	"NorthCarolina"	"NorthDakota"	"Ohio"	"Oklahoma"	"Oregon"	"Pennsylvania"	"RhodeIsland"	"SouthCarolina"	"SouthDakota"	"Tennessee"	"Texas"	"Utah"	"Vermont"	"Virginia"	"Washington"	"WestVirginia"	"Wisconsin"	"Wyoming" {
        use Jobopeningsrate_TotalUS, clear
        drop Jobopeningsrate state
    foreach variable in "Jobopeningsrate" "Jobopenings" "Hires" "Quits" "Totalseparations" "Layoffsanddischarges" {
        merge 1:1 date using `variable'_`state', nogenerate
    }
    save `state', replace
    }

use TotalUS, clear
foreach state in "Alabama"	"Alaska"	"Arizona"	"Arkansas"	"California"	"Colorado"	"Connecticut"	"Delaware"	"DistrictofColumbia"	"Florida"	"Georgia"	"Hawaii"	"Idaho"	"Illinois"	"Indiana"	"Iowa"	"Kansas"	"Kentucky"	"Louisiana"	"Maine"	"Maryland"	"Massachusetts"	"Michigan"	"Minnesota"	"Mississippi"	"Missouri"	"Montana"	"Nebraska"	"Nevada"	"NewHampshire"	"NewJersey"	"NewMexico"	"NewYork"	"NorthCarolina"	"NorthDakota"	"Ohio"	"Oklahoma"	"Oregon"	"Pennsylvania"	"RhodeIsland"	"SouthCarolina"	"SouthDakota"	"Tennessee"	"Texas"	"Utah"	"Vermont"	"Virginia"	"Washington"	"WestVirginia"	"Wisconsin"	"Wyoming" {
        append using `state'
    }
save JOLTS, replace 

*!start
cd "${path}"
use JOLTS, clear
gen numD=Jobopenings*100/Jobopeningsrate
save JOLTS_2, replace 


/*********************************************
CPS IPUMS Data
*********************************************/
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\rawdata\CPS"
use cps, clear
*import delimited "https://www.dropbox.com/s/sbqdt6fkgi4gfet/cps.dta?dl=1", varnames(1) clear 

gen num=1
format num %12.0g

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

rename ind1990 ind2
gen indb=0
replace indb=1 if 10<=ind2&ind2<40 // agriculture
replace indb=2 if 40<=ind2&ind2<100 // mining and construction
replace indb=3 if 100<=ind2&ind2<400 // manufacturing
replace indb=4 if 400<=ind2&ind2<500 // transportation, communications, and other public utilities
replace indb=5 if 500<=ind2&ind2<580 // Wholesale trade
replace indb=6 if 580<=ind2&ind2<700 // Retail trade
replace indb=7 if 700<=ind2&ind2<721 // FINANCE, INSURANCE, AND REAL ESTATE
replace indb=8 if 721<=ind2&ind2<761 // BUSINESS AND REPAIR SERVICES
replace indb=9 if 761<=ind2&ind2<800 // PERSONAL SERVICES
replace indb=10 if 800<=ind2&ind2<812 // ENTERTAINMENT AND RECREATION SERVICES
replace indb=11 if 812<=ind2&ind2<900 // PROFESSIONAL AND RELATED SERVICES
replace indb=12 if 900<=ind2&ind2<940 // PUBLIC ADMINISTRATION
replace indb=13 if 940<=ind2&ind2<1000 // ACTIVE DUTY MILITARY, etc



/*
collapse (sum) num [pweight=wgt], by(date emp)
emp 1+2+3 = Civilian noninstitutional population
emp 1+2 = Civilian labor force
emp 1 = Employed
emp 2 = Unemployed
emp 3 = Not in labor force (inactive)
*/
preserve
keep if emp==1
keep if citizen==5  // Foreigner
keep if date==605 // 2010m6
collapse (sum) num [pweight=wgt], by(yrimmig state indb)
save yrimmig-state-indb, replace 
restore




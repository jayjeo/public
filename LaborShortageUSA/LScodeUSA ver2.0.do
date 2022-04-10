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
save JOLTS, replace 

use JOLTS, clear 
gen Jobopeningsrate=Jobopenings/(Jobopenings+numD)*100
keep date state Jobopeningsrate
egen statenum=group(state)
drop state 
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
import delimited "https://www.dropbox.com/s/xlyk90gm0o93e3j/cps.dta?dl=1", varnames(1) clear  // 2GB, it will take long time to download. 
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

rename ind1990 ind2
gen indb=0
replace indb=1 if 1<=ind2&ind2<40 // agriculture
replace indb=2 if 40<=ind2&ind2<400 // mining, construction, manufacturing
replace indb=3 if 400<=ind2&ind2<500 // transportation, communications, and other public utilities
replace indb=4 if 500<=ind2&ind2<700 // Wholesale trade, Retail trade
replace indb=5 if 700<=ind2&ind2<761 // FINANCE, INSURANCE, AND REAL ESTATE , BUSINESS AND REPAIR SERVICES
replace indb=6 if 761<=ind2&ind2<812 // PERSONAL SERVICES, ENTERTAINMENT AND RECREATION SERVICES
replace indb=7 if 812<=ind2&ind2<1000 // PROFESSIONAL AND RELATED SERVICES, PUBLIC ADMINISTRATION,  ACTIVE DUTY MILITARY, etc

drop if yrimmig==0000
gen yrim=0
replace yrim=1 if 1949<=yrimmig&yrimmig<1981
replace yrim=2 if 1981<=yrimmig&yrimmig<2000
replace yrim=3 if 2000<=yrimmig&yrimmig<2015
replace yrim=4 if 2015<=yrimmig
drop if yrim==0

save CPS2, replace 


/*
collapse (sum) num [pweight=wgt], by(date emp)
emp 1+2+3 = Civilian noninstitutional population
emp 1+2 = Civilian labor force
emp 1 = Employed
emp 2 = Unemployed
emp 3 = Not in labor force (inactive)
*/


//!start
use CPS2, clear 
keep if emp==1
keep if citizen==5  // Foreigner
keep if yrim==4
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Ft_emp
keep if date>=660
save Ft_emp, replace 

use CPS2, clear 
keep if emp==1
*keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Lt_emp
keep if date>=660
save Lt_emp, replace 

use CPS2, clear 
*keep if emp==1
keep if citizen==5  // Foreigner
keep if yrim==4
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Ft_tot
keep if date>=660
save Ft_tot, replace 

use CPS2, clear 
*keep if emp==1
*keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Lt_tot
keep if date>=660
save Lt_tot, replace 

use Lt_tot, clear
merge 1:1 date using Ft_tot, nogenerate
merge 1:1 date using Ft_emp, nogenerate
merge 1:1 date using Lt_emp, nogenerate
gen FLt_tot=Ft_tot/Lt_tot
gen FLt_emp=Ft_emp/Lt_emp
tsset date
tsline FLt_tot FLt_emp

gen Dt_tot=(Lt_tot-Ft_tot)/1000
gen Dt_emp=(Lt_emp-Ft_emp)/1000
replace Ft_tot=Ft_tot/1000
replace Ft_emp=Ft_emp/1000
gen t=date
twoway (tsline Dt_tot, lcolor(gs0) lwidth(thick))(tsline Ft_tot, lcolor(red) lwidth(thick))(tsline Dt_emp, lcolor(gs0) lpattern(dashed))(tsline Ft_emp, lcolor(red) lpattern(dashed)) ///
, xtitle("") ytitle("Million person") xline(720) /// 
legend(label(1 "Domestic Population") label(2 "Foreign Population") label(3 "Domestic Employment") label(4 "Foreign Employment") order(1 2 3 4))


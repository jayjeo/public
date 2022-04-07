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

*!start
cd "${path}"
foreach state in  "TotalUS" "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "DistrictofColumbia" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "NewHampshire" "NewJersey" "NewMexico" "NewYork" "NorthCarolina" "NorthDakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "RhodeIsland" "SouthCarolina" "SouthDakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "WestVirginia" "Wisconsin" "Wyoming" {
        use Jobopeningsrate_TotalUS, clear
        drop Jobopeningsrate state
    foreach variable in "Jobopeningsrate" "Jobopenings" "Hires" "Quits" "Totalseparations" "Layoffsanddischarges" {
        merge 1:1 date using `variable'_`state', nogenerate
    }
    save `state', replace
    }

use TotalUS, clear
foreach state in "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "DistrictofColumbia" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "NewHampshire" "NewJersey" "NewMexico" "NewYork" "NorthCarolina" "NorthDakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "RhodeIsland" "SouthCarolina" "SouthDakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "WestVirginia" "Wisconsin" "Wyoming" {
        append using `state'
    }
gen numD=(100/Jobopeningsrate-1)*Jobopenings  // numD = number of employment
drop Jobopeningsrate
save JOLTS_temp1, replace 

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

use JOLTS_temp1, clear
drop if inlist(state,"DistrictofColumbia","Maryland")
append using Maryland
sort state date 
save JOLTS, replace 



/*********************************************
CPS IPUMS Data
*********************************************/
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\rawdata\CPS"


use cps, clear
*import delimited "https://www.dropbox.com/s/sbqdt6fkgi4gfet/cps.dta?dl=1", varnames(1) clear 

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


/**************************
Generate Fyst0
**************************/
use CPS2, clear 

preserve
keep if emp==1
keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(yrim statefip date)
rename num Fyst
save Fyst, replace 
restore

use Fyst, clear
keep if yrim>1
tab statefip, nolab
tab yrim, nolab

foreach i of numlist 1 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
    foreach j of numlist 2 3 4 {
        preserve
            keep if statefip==`i'&yrim==`j'
            tsset date
            tsfill, full
            replace statefip=`i' if statefip==.
            replace yrim=`j' if yrim==.
            ipolate Fyst date, gen(Fystipo)
            save `i'_`j', replace 
        restore
    }
} 

*!start
use 1_2, clear
append using 1_3
append using 1_4

foreach i of numlist 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
    foreach j of numlist 2 3 4 {
        append using `i'_`j'
    }
} 

drop Fyst 
rename Fystipo Fyst
reshape wide Fyst, i(yrim statefip) j(date)
// completely exist from 662 to 745
save Fyst_temp, replace

use Fyst_temp, clear 
keep statefip yrim Fyst684
save Fyst0, replace

/**************************
Generate delta_Fyst
**************************/
use Fyst_temp, clear 
forvalues i=684(1)744 {
    gen delta_Fyst`i'=0
    local j=`i'+1
    replace delta_Fyst`i'=Fyst`j'-Fyst`i'
}
keep statefip yrim delta_Fyst*
reshape long delta_Fyst, i(statefip yrim) j(date)
save delta_Fyst, replace 


/**************************
Generate Fysit0
**************************/
use CPS2, clear 

preserve
keep if emp==1
keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(yrim statefip date indb)
rename num Fysit
save Fysit, replace 
restore

use Fysit, clear
keep if yrim>1
reshape wide Fysit, i(yrim statefip indb) j(date)

gen replaced=0
forvalues k=1(1)24 {
    local i=684+`k'
    local j=684-`k'
    replace replaced=`i' if Fysit684==.
    replace Fysit684=Fysit`i' if Fysit684==.
    replace replaced=`j' if Fysit684==.
    replace Fysit684=Fysit`j' if Fysit684==.
}
replace Fysit684=0 if Fysit684==.

keep statefip yrim indb Fysit684
save Fysit0, replace

foreach i of numlist 1 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
    foreach j of numlist 2 3 4 {
            foreach k of numlist 1 2 3 4 5 6 7 {
            preserve
                keep if statefip==`i'&yrim==`j'&indb==`k'
                tsset date
                tsfill, full
                replace statefip=`i' if statefip==.
                replace yrim=`j' if yrim==.
                replace indb=`k' if indb==.
                ipolate Fysit date, gen(Fysitipo)
                save `i'_`j'_`k', replace 
            restore
        }
    }
} 

*!start
use 1_2_1, clear
gen delete=1

foreach i of numlist 1 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
    foreach j of numlist 2 3 4 {
            foreach k of numlist 1 2 3 4 5 6 7 {
                append using `i'_`j'_`k'
    }
} 
drop if delete==1

drop Fysit 
rename Fysitipo Fysit
reshape wide Fysit, i(yrim statefip indb) j(date)
// completely exist from 662 to 745
keep statefip yrim indb Fysit662
save Fysit0, replace

/**************************
Generate Lsit
**************************/
use CPS2, clear 

keep if emp==1
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(statefip date indb)
rename num Lsit
sort Lsit
save Lsit, replace 

/**************************
Generate Merge
**************************/
clear all
set obs 65100
gen state=.
gen yrim=.
gen indb=.
gen date=.

scalar i=1
mata x=J(65100, 4, 0)
forvalues date=684(1)745 {
mata x[i,1]=`date'
    foreach state of numlist 1 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
    mata x[i,2]=`state'
        foreach yrim of numlist 2 3 4 {
        mata x[i,3]=`yrim'
            foreach indb of numlist 1 2 3 4 5 6 7 {
            mata x[i,4]=`indb'
            scalar i=`i'+1             
}
}
}
}


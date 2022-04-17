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

//!start
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
//!start
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

//!start
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
//!start
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
//!start
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
sort Fysit684
keep statefip yrim indb Fysit684
save Fysit0, replace


/**************************
Generate Lsit
**************************/
//!start
use CPS2, clear 

keep if emp==1
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(statefip date indb)
rename num Lsit
sort Lsit
save Lsit, replace 

/**************************
Generate tilde_Fsit
**************************/
//!start
clear all
local i=0
mata x=J(65100, 4, 0)
forvalues date=684(1)745 {
    foreach state of numlist 1 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {  
        foreach yrim of numlist 2 3 4 {       
            foreach indb of numlist 1 2 3 4 5 6 7 {
            local i=`i'+1    
            mata: x[`i',1]=`date'
            mata: x[`i',2]=`state'
            mata: x[`i',3]=`yrim'
            mata: x[`i',4]=`indb'                            
}
}
}
}

getmata (date state yrim indb)=x, replace 
rename state statefip
save base, replace 

//!start
use base, clear
merge m:1 statefip date indb using Lsit, nogenerate
drop if yrim==.
merge m:1 yrim statefip indb using Fysit0, nogenerate
rename Fysit684 Fysit0
merge m:1 statefip yrim using Fyst0, nogenerate
rename Fyst684 Fyst0
merge m:1 statefip yrim date using delta_Fyst, nogenerate
drop if date==745
replace Lsit=0 if Lsit==.

reshape wide Fysit0 Fyst0 delta_Fyst Lsit, i(statefip date indb) j(yrim)
rename Lsit2 Lsit
drop Lsit3 Lsit4
gen tilde_Fsit=(Fysit02/Fyst02*delta_Fyst2/Lsit)+(Fysit03/Fyst03*delta_Fyst3/Lsit)+(Fysit04/Fyst04*delta_Fyst4/Lsit)
replace tilde_Fsit=0 if tilde_Fsit==.
keep date statefip indb tilde_Fsit
save tilde_Fsit, replace 

/**************************
Generate Fsit0
**************************/
//!start
use CPS2, clear 

preserve
keep if emp==1
keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(statefip date indb)
rename num Fsit
save Fsit, replace 
restore

use Fsit, clear
reshape wide Fsit, i(statefip indb) j(date)

gen replaced=0
forvalues k=1(1)24 {
    local i=684+`k'
    local j=684-`k'
    replace replaced=`i' if Fsit684==.
    replace Fsit684=Fsit`i' if Fsit684==.
    replace replaced=`j' if Fsit684==.
    replace Fsit684=Fsit`j' if Fsit684==.
}
replace Fsit684=0 if Fsit684==.
sort Fsit684
keep statefip indb Fsit684
save Fsit0, replace

/**************************
Generate Fst0
**************************/
//!start
use CPS2, clear 
keep if emp==1
keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(statefip date)
rename num Fst684
keep if date==684
save Fst0, replace 

/**************************
Generate tilde_Fst
**************************/
//!start
use tilde_Fsit, clear 
merge m:1 statefip indb using Fsit0, nogenerate
rename Fsit684 Fsit0
merge m:1 statefip using Fst0, nogenerate
rename Fst684 Fst0
reshape wide tilde_Fsit Fsit0 Fst0, i(statefip date) j(indb)
rename Fst01 temp_Fst0
drop Fst0*
rename temp_Fst0 Fst0

forvalues ind=1(1)7 {
    gen temp`ind'=Fsit0`ind'/Fst0*tilde_Fsit`ind'
}
gen tilde_Fst=temp1+temp2+temp3+temp4+temp5+temp6+temp7
keep statefip date tilde_Fst
save tilde_Fst, replace 

use tilde_Fst, clear
drop if inlist(statefip,54,28)
sort tilde_Fst
xtset statefip date
xtline tilde_Fst, overlay 

/**************************
Generate FstIV
**************************/
//!start 
use tilde_Fst, clear
merge m:1 statefip using Fst0, nogenerate
rename Fst684 Fstzero
gen rate_Fst=1+tilde_Fst
drop tilde_Fst
reshape wide rate_Fst Fstzero, i(date) j(statefip)

tsset date, monthly 

foreach state of numlist 1 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {  
    gen temp_Fstzero`state'=Fstzero`state'
    replace Fstzero`state'=Fstzero`state'*L1.rate_Fst`state'
    replace Fstzero`state'=temp_Fstzero`state' if date==684
    drop temp_Fstzero`state'
}
drop rate_Fst*
reshape long Fstzero, i(date) j(statefip)
rename Fstzero FstIV_temp
save FstIV_temp, replace 

use FstIV_temp, clear
keep if date==684
rename FstIV_temp FstIV_temp684
save FstIV_temp684, replace 

use FstIV_temp, clear
merge m:1 statefip using FstIV_temp684, nogenerate
gen FstIV=FstIV_temp/FstIV_temp684
save FstIV, replace 

use FstIV, clear
xtset statefip date
drop if inlist(statefip,54,28)
xtline FstIV, overlay 



/**************************
Generate delta_Fst
**************************/
//!start
use CPS2, clear 

preserve
keep if emp==1
keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(statefip date)
rename num Fst
save Fst, replace 
restore

use Fst, clear
foreach i of numlist 1 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
        preserve
            keep if statefip==`i'
            tsset date
            tsfill, full
            replace statefip=`i' if statefip==.
            ipolate Fst date, gen(Fstipo)
            save Fst_temp`i', replace 
        restore
} 

//!start
use Fst_temp1, clear
foreach i of numlist 2 4 5 6 8 9 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
        append using Fst_temp`i'
} 

drop Fst 
rename Fstipo Fst
reshape wide Fst, i(statefip) j(date)
// completely exist from 662 to 745
save Fst_temp, replace

forvalues i=684(1)744 {
    gen delta_Fst`i'=0
    local j=`i'+1
    replace delta_Fst`i'=Fst`j'-Fst`i'
}
keep statefip delta_Fst*
reshape long delta_Fst, i(statefip) j(date)
save delta_Fst, replace 


/**************************
Generate Lst
**************************/
//!start
use CPS2, clear 

keep if emp==1
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(statefip date)
rename num Lst
sort Lst
save Lst, replace 

/**************************
Generate Lst
**************************/
//!start
use Lst, clear 
merge 1:1 statefip date using delta_Fst, nogenerate

gen test=delta_Fst/Lst
keep if date>=684
drop if inlist(statefip,54,28)

xtset statefip date
xtline test, overlay  




/**************************
Generate Fsit0
**************************/
//!start
use CPS2, clear 

*keep if emp==1
keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(yrim date)
rename num Fyt
keep if date>=660
save Fyt, replace 

use Fyt, clear
keep if date==660
rename Fyt Fyt0 
drop date 
save Fyt0, replace 

use Fyt, clear
merge m:1 yrim using Fyt0, nogenerate
gen Fyt_normalized=Fyt/Fyt0
keep yrim date Fyt_normalized
xtset yrim date
xtline Fyt_normalized, overlay  

use CPS2, clear 
*keep if emp==1
*keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Lt
keep if date>=660
save Lt, replace 

use Fyt, clear
merge m:1 date using Lt, nogenerate
xtset yrim date
gen FLt=Fyt/Lt
xtline FLt, overlay  


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



global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\US data\rawdata\CPS"
copy "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/X12A.EXE" "${path}/X12A.exe"
net install st0255, from(http://www.stata-journal.com/software/sj12-2)
adopath + "${path}"

sax12 FLt_tot, satype(single) inpref(FLt_tot.spc) outpref(FLt_tot) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12im "FLt_tot.out", ext(d11)

sax12 FLt_emp, satype(single) inpref(FLt_emp.spc) outpref(FLt_emp) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12im "FLt_emp.out", ext(d11)

tsline FLt_tot_d11 FLt_emp_d11
tsline Ft_emp Lt_emp 

//!start
use CPS2, clear 
*keep if emp==1
*keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Lt_tot
keep if date>=660
save Lt_tot, replace 
tsset date
tsline Lt_tot

//!start
use CPS2, clear 
*keep if emp==1
keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Ft_tot
keep if date>=660
save Ft_tot, replace 

merge 1:1 date using Lt_tot, nogenerate
tsset date
tsline Lt_tot Ft_tot





//!start
use CPS2, clear 
*tab bpl, nolab
gen birth=0 if 9900<=bpl&bpl<15000
replace birth=1 if 15000<=bpl&bpl<99999
drop if birth==.
save CPS3, replace 

use CPS3, clear
*keep if emp==1
*keep if citizen==5  // Foreigner
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Lt_tot
keep if date>=660
save Lt_tot, replace 
tsset date
tsline Lt_tot

use CPS3, clear 
*keep if emp==1
keep if birth==1  // Foreign birth
**keep if date==719 // 2019m12 PRE-COVID
collapse (sum) num [pweight=wgt], by(date)
rename num Ft_tot
keep if date>=660
save Ft_tot, replace 

merge 1:1 date using Lt_tot, nogenerate
tsset date
tsline Lt_tot Ft_tot


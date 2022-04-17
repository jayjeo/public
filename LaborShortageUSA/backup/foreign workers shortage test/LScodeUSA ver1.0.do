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
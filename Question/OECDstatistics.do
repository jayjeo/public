// import necessary data from OECD statistics // 

clear all
import delimited "OECD/SNA_TABLE4_03032023065326465.csv", delimiter(",") rowrange(2)
rename (ïlocation)(location)
replace value=value*10^powercodecode
keep if transact=="PPPGDP"
keep year unitcode value location
rename (value)(PPP)
save PPP_1, replace 


clear all
import delimited "OECD/PRICES_CPI_03032023220557911.csv", delimiter(",") rowrange(2)
rename (ïlocation value time)(location CPI year)
keep if subject=="CPALTT01"
keep if v6=="Index"
keep location year CPI
save CPI_temp, replace
use CPI_temp, clear
keep if location=="GRC"
replace location="BGR"
save CPI_BGR, replace // change later
use CPI_temp, clear
keep if location=="GRC"
replace location="ROU"
save CPI_ROU, replace // change later
use CPI_temp, clear
append using CPI_BGR
append using CPI_ROU
save CPI, replace 


clear all
import delimited "OECD/SNA_TABLE7A_03032023210132368.csv", delimiter(",") rowrange(2)
rename (ïlocation)(location)
replace value=value*10^powercodecode
rename value oecd_population
keep location year oecd_population
smoothing oecd_population
save oecd_population, replace


clear all
import delimited "OECD/STANI4_2020_11032023001647166.csv", delimiter(",") rowrange(2)
rename (ïlocation)(location)
replace value=value*10^powercodecode
keep location country var time unitcode value
rename (time var)(year transact)
replace unitcode="JPY" if location=="JPN"
drop if unitcode==""
merge m:m unitcode year using PPP_1
drop if _merge==2
drop _merge
replace value=value/PPP if location!="USA"
drop PPP unitcode 
keep if transact=="GOPS"
drop transact country
rename (value)(oecd_markup)
smoothing oecd_markup
save oecd_markup, replace


clear all
import delimited "OECD/SNA_TABLE6A_03032023052333459.csv", delimiter(",") rowrange(2)
rename (ïlocation)(location) 
keep if measure=="C"
replace value=value*10^powercodecode
keep location country transact transaction activity v6 year unitcode value
replace unitcode="JPY" if location=="JPN"
merge m:m unitcode year using PPP_1
drop if _merge==2
drop _merge
replace value=value/PPP if location!="USA"
drop PPP unitcode 
keep location transact activity value year
preserve 
    keep if transact=="B1GA"
    drop transact 
    rename value oecd_VA
    smoothingmanuf activity oecd_VA
    save oecd_VA, replace
restore 
preserve 
    keep if transact=="D1A"
    drop transact
    rename value oecd_COMP
    smoothingmanuf activity oecd_COMP
    save oecd_COMP, replace
restore 


clear all
import delimited "OECD/AV_AN_WAGE_06032023165809242.csv", delimiter(",") rowrange(2)  // already PPP
rename (ïcountry value time)(location oecd_wage year)
keep location year oecd_wage
smoothing oecd_wage
save oecd_wage, replace


clear all 
import delimited "OECD/MEI_PRICES_PPI_04032023164344951.csv", delimiter(",") rowrange(2)
keep if ïsubject=="PITGVG01" & measure=="IXOB" & frequency=="A"
keep location country time value
rename (time value)(year oecd_vxi)
smoothing oecd_vxi
save oecd_vxi_2, replace

use oecd_vxi_2, clear
keep if location=="GBR"
replace location="IRL"
save oecd_vxi_IRL, replace

use oecd_vxi_2, clear
append using oecd_vxi_IRL
drop country
save oecd_vxi, replace


clear all
import delimited "OECD/SNA_TABLE7A_03032023051834684.csv", delimiter(",") rowrange(2)
rename (ïlocation)(location)
keep if measure=="PER"
replace value=value*10^powercodecode
keep if transact=="ETOA"
keep location activity year value
rename (value)(oecd_EMP)
smoothingmanuf activity oecd_EMP
save oecd_EMP, replace


clear all
import delimited "OECD/STANI4_2020_12032023001729372.csv", delimiter(",") rowrange(2)
rename (ïlocation)(location)
replace value=value*10^powercodecode
rename time year
keep location country var ind year unitcode value
replace unitcode="JPY" if location=="JPN"
merge m:m unitcode year using PPP_1
drop if _merge==2
drop _merge
replace value=value/PPP if location!="USA"
drop unitcode

gen sector="C" if inlist(ind,"D10T33")
replace sector="10_12" if inlist(ind,"D10T12")
replace sector="13_15" if inlist(ind,"D13T15")
replace sector="16_18" if inlist(ind,"D16T18")
replace sector="19" if inlist(ind,"D19")
replace sector="20_21" if inlist(ind,"D20T21")
replace sector="22_23" if inlist(ind,"D22T23")
replace sector="24_25" if inlist(ind,"D24T25")
replace sector="26_27" if inlist(ind,"D26T27")
replace sector="28" if inlist(ind,"D28")
replace sector="29_30" if inlist(ind,"D29T30")
replace sector="31_33" if inlist(ind,"D31T33")
drop ind 
sort location var sector year 
foreach var in VALU LABR WAGE GOPS CFCC CPGK {
    preserve 
        keep if var=="`var'"&sector=="C"
        rename value oecd_`var'_total
        smoothing oecd_`var'_total
        keep location year oecd_`var'_total
        drop if location==""
        duplicates drop
        save oecd_`var'_total, replace
    restore
    preserve 
        keep if var=="`var'"&sector!="C"
        rename value oecd_`var'_detail
        smoothingmanuf sector oecd_`var'_detail
        keep location year sector oecd_`var'_detail
        drop if location==""|sector==""
        duplicates drop
        save oecd_`var'_detail, replace
    restore    
} 




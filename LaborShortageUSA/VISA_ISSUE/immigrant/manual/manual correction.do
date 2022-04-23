****************************
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage USA"  
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortageUSA/VISA_ISSUE/immigrant/manual/202104.csv", clear 
rename (v1 v2 v3)(nation visa issue)
save needcorrection, replace

use needcorrection, clear
keep if visa!=""
save good, replace 

use needcorrection, clear
keep if visa==""
drop if nation=="GRAND TOTAL"
save bad, replace 

use bad, clear
replace nation=substr(nation,1,strlen(nation)-1)
gen lower=regexr(substr(nation,strlen(nation)-4,1), "[a-z]", "1")
gen lower2=4 if lower=="1"
forvalues i=1(1)4 {
    local j=4-`i'
    replace lower=regexr(substr(nation,strlen(nation)-`j',1), "[a-z]", "1")
    replace lower2=`j' if lower=="1"
}
gen nation2=substr(nation,1,strlen(nation)-lower2)
gen visa2=substr(nation,strlen(nation)-lower2+1,lower2)
drop nation visa
rename (nation2 visa2)(nation visa)
keep nation visa issue
append using good
save immigrant202104, replace 


****************************
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage USA"  
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortageUSA/VISA_ISSUE/immigrant/manual/202102.csv", clear 
rename (v1 v2 v3)(nation visa issue)
save needcorrection, replace

use needcorrection, clear
keep if visa!=""
save good, replace 

use needcorrection, clear
keep if visa==""
drop if nation=="GRAND TOTAL"
save bad, replace 

use bad, clear
replace nation=substr(nation,1,strlen(nation)-1)
gen lower=regexr(substr(nation,strlen(nation)-4,1), "[a-z]", "1")
gen lower2=4 if lower=="1"
forvalues i=1(1)4 {
    local j=4-`i'
    replace lower=regexr(substr(nation,strlen(nation)-`j',1), "[a-z]", "1")
    replace lower2=`j' if lower=="1"
}
gen nation2=substr(nation,1,strlen(nation)-lower2)
gen visa2=substr(nation,strlen(nation)-lower2+1,lower2)
drop nation visa
rename (nation2 visa2)(nation visa)
keep nation visa issue
append using good
drop if visa==""
save immigrant202102, replace 


****************************
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage USA"  
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortageUSA/VISA_ISSUE/nonimmigrant/manual/202102.csv", clear 
rename (v1 v2 v3)(nation visa issue)
drop if issue==""
drop if issue=="Issuances"
save needcorrection, replace

use needcorrection, clear
tostring visa, replace 
replace visa="" if visa=="."
keep if visa==""
drop if nation=="GRAND TOTAL"
save bad, replace 

use bad, clear
gen temp=nation
gen dash=regexr(substr(nation,strlen(nation)-4,1), "/", "1")
gen dash2=4 if dash=="1"
forvalues i=1(1)4 {
    local j=4-`i'
    replace dash=regexr(substr(nation,strlen(nation)-`j',1), "/", "1")
    replace dash2=`j' if dash=="1"
}
replace nation=substr(nation,1,strlen(nation)-dash2-1) if inlist(dash2,1,2)
sort dash2
gen single=regexr(substr(nation,strlen(nation),1), "[A-Z]", "1") if substr(nation,strlen(nation),1)!="1"
sort single
gen nation2=substr(nation,1,strlen(nation)-1) if single=="1"
gen visa2=substr(nation,strlen(nation)-1+1,1) if single=="1"

replace nation=substr(nation,1,strlen(nation)-1)
gen lower=regexr(substr(nation,strlen(nation)-4,1), "[a-z]", "1")
gen lower2=4 if lower=="1"
forvalues i=1(1)4 {
    local j=4-`i'
    replace lower=regexr(substr(nation,strlen(nation)-`j',1), "[a-z]", "1")
    replace lower2=`j' if lower=="1"
}
replace nation2=substr(nation,1,strlen(nation)-lower2)
replace visa2=lower if visa2==""
*keep temp nation2 visa2
drop nation visa
rename (nation2 visa2)(nation visa)
keep nation visa issue
append using good
drop if visa==""
save nonimmigrant202102, replace


****************************
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage USA"  
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortageUSA/VISA_ISSUE/nonimmigrant/manual/202104.csv", clear 
rename (v1 v2)(nation issue)
gen visa=""
drop if issue==""
drop if issue=="Issuances"
save needcorrection, replace

use needcorrection, clear
tostring visa, replace 
replace visa="" if visa=="."
keep if visa==""
drop if nation=="GRAND TOTAL"
save bad, replace 

use bad, clear
gen temp=nation
gen dash=regexr(substr(nation,strlen(nation)-4,1), "/", "1")
gen dash2=4 if dash=="1"
forvalues i=1(1)4 {
    local j=4-`i'
    replace dash=regexr(substr(nation,strlen(nation)-`j',1), "/", "1")
    replace dash2=`j' if dash=="1"
}
replace nation=substr(nation,1,strlen(nation)-dash2-1) if inlist(dash2,1,2)
sort dash2
gen single=regexr(substr(nation,strlen(nation),1), "[A-Z]", "1") if substr(nation,strlen(nation),1)!="1"
sort single
gen nation2=substr(nation,1,strlen(nation)-1) if single=="1"
gen visa2=substr(nation,strlen(nation)-1+1,1) if single=="1"

replace nation=substr(nation,1,strlen(nation)-1)
gen lower=regexr(substr(nation,strlen(nation)-4,1), "[a-z]", "1")
gen lower2=4 if lower=="1"
forvalues i=1(1)4 {
    local j=4-`i'
    replace lower=regexr(substr(nation,strlen(nation)-`j',1), "[a-z]", "1")
    replace lower2=`j' if lower=="1"
}
replace nation2=substr(nation,1,strlen(nation)-lower2)
replace visa2=lower if visa2==""
*keep temp nation2 visa2
drop nation visa
rename (nation2 visa2)(nation visa)
keep nation visa issue
append using good
drop if visa==""
save nonimmigrant202104, replace
// Import IFR data // 
* IFR data needs to be purchased and is forbidden to distribute. 
* We used "World Robotics 2022" version of IFR data. 
* Reporting > Report by industry > CSV download > Compose data > Complete data. 
* Once downloaded, save it to this current workspace.

clear all
import delimited "IFRdata", delimiter(";") rowrange(2)
sort country industry year
keep if country=="KR"

clear all
import delimited "IFRdata", delimiter(";") rowrange(2)
sort country industry year
gen location="USA" if country=="US"
replace location="AUT" if country=="AT"
replace location="BEL" if country=="BE"
replace location="CZE" if country=="CZ"
replace location="DEU" if country=="DE"
replace location="DNK" if country=="DK"
replace location="ESP" if country=="ES"
replace location="EST" if country=="EE"
replace location="FIN" if country=="FI"
replace location="FRA" if country=="FR"
replace location="GBR" if country=="UK"
replace location="GRC" if country=="GR"
replace location="HUN" if country=="HU"
replace location="IRL" if country=="IE"
replace location="ITA" if country=="IT"
replace location="JPN" if country=="JP"
replace location="LTU" if country=="LT"
replace location="NLD" if country=="NL"
replace location="NOR" if country=="NO"
replace location="POL" if country=="PL"
replace location="PRT" if country=="PT"
replace location="SVK" if country=="SK"
replace location="SVN" if country=="SL"
replace location="SWE" if country=="SE"
drop if location==""
save IFRdata_temp, replace 

use IFRdata_temp, clear 
keep if industry=="D"
keep year location installations operationalstock
//smoothing "installations operationalstock"
save IFRdata_manuf, replace 

use IFRdata_temp, clear
keep year location industry installations operationalstock 
gen sector="10_12" if industry=="10-12"
replace sector="13_15" if industry=="13-15" 
replace sector="16_18" if industry=="16"|industry=="17-18"  
replace sector="19" if industry=="19"  
replace sector="20_21" if industry=="20-21"  
replace sector="22_23" if industry=="22"|industry=="23"  
replace sector="24_25" if industry=="24"|industry=="25"   
replace sector="26_27" if industry=="26-27" 
replace sector="28" if industry=="28"  
replace sector="29_30" if industry=="29"|industry=="30"
replace sector="31_33" if industry=="91"  
drop industry
drop if sector==""
rename(installations operationalstock)(installationsdetail operationalstockdetail)
collapse (sum) installationsdetail operationalstockdetail, by(location sector year)
//smoothingmanuf sector "installationsdetail operationalstockdetail"
rename(installationsdetail operationalstockdetail)(installations_detail operationalstock_detail)

//replace installations_detail=0.1 if installations_detail==.|installations_detail==0|installations_detail<0
//replace operationalstock_detail=0.1 if operationalstock_detail==.|operationalstock_detail==0|operationalstock_detail<0

save IFRdata_manuf_detail, replace 





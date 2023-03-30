// Replicate Karabarbounis&Neiman using PWT 10.01 version // 



* Get investment deflator and consumer deflator from BEA in the USA. 
clear
import delimited "BEA/BEA_price_deflators.txt", delimiter(tab) encoding(UTF-8)
rename a006rd3a086nbea investment_deflator
//replace investment_deflator=1/investment_deflator
rename dpcerd3a086nbea consum_deflator   
//replace consum_deflator=1/consum_deflator
gen year=substr(date,1,4)
destring year, replace 
drop date
save price_BEA, replace 



* Generate original KN data from Karabarbounis&Neiman
use "KN/kn1data", clear 
global betaset=0.935
global deltaset=0.10
global taukset=0.00
gen price_investment=price_investment71
gen price_consumption=price_consumption71
gen price_investment_us=price_investment71_us
gen price_consumption_us=price_consumption71_us
keep if sourceid=="KN_mergedI"
gen vxi= ( (price_investment / price_consumption) / (price_investment_us / price_consumption_us) )* (p_i_bea_us / p_c_bea_us) // 77페이지 과정을 거치는 것. 
gen vR=vxi*(1/(1-$taukset))*(1/$betaset-1+$deltaset)
gen R_plain=vR
keep country country_label year vR vxi R_plain price_consumption
gen location=country_label 
replace location="DEU" if country_label=="GER"
replace location="ROU" if country_label=="ROM"
rename vxi vxi_KN
rename R_plain R_KN
keep location year R_KN 
save KN_replication_original, replace



use "KN/kn1data", clear 
keep if sourceid=="KN_mergedI"
egen loc=group(country_label)
keep if loc==111
keep year price_investment71_us price_consumption71_us p_i_bea_us p_c_bea_us
save kn1data_BEA, replace 

use price_BEA, clear 
merge 1:1 year using kn1data_BEA
keep year price_investment71_us price_consumption71_us p_i_bea_us p_c_bea_us consum_deflator investment_deflator  
gen KN=price_investment71_us/price_consumption71_us
gen BEA_KN_original=p_i_bea_us/p_c_bea_us
gen BEA_updated=investment_deflator/consum_deflator
tsset year 
twoway (tsline BEA_KN_original)(tsline BEA_updated, yaxis(2)), legend(off) xtitle("")
graph export "BEA_deflators.eps", as(eps) preview(off) replace
keep year BEA_updated
save BEA_updated, replace 




// KN replication from PWT 10.01 version // 
use "PennWorldTable/pwt1001", clear
gen location=countrycode
global betaset=0.935
global deltaset=0.10
global taukset=0.00
gen price_investment=pl_i
gen price_consumption=pl_c
gen price_investment_us_n = price_investment if location=="USA"
gen price_consumption_us_n = price_consumption if location=="USA"
egen price_investment_us = mean(price_investment_us_n), by(year)
egen price_consumption_us = mean(price_consumption_us_n), by(year)
merge m:1 year using BEA_updated
gen vxi= ( (price_investment / price_consumption) / (price_investment_us / price_consumption_us) )* (BEA_updated) // 77페이지 과정을 거치는 것. 
gen vR=vxi*(1/(1-$taukset))*(1/$betaset-1+$deltaset)
gen R_plain=vR
keep country location countrycode year vR vxi R_plain price_consumption
replace location="DEU" if countrycode=="GER"
replace location="ROU" if countrycode=="ROM"
rename vxi vxi_KN
keep country location year vR vxi_KN R_plain price_consumption
merge 1:1 location year using KN_replication_original, nogenerate
save KN_replication_from_scratch, replace



// Compare between original and updated versions // 
use KN_replication_from_scratch, clear 
merge 1:1 location year using KN_replication_original
egen loc=group(location)
xtset loc year
rename R_plain R_updated
keep if inlist(location,"USA","GBR","DEU","FRA","ITA","POL")
twoway(line R_KN year, lcolor(gs0) )(line R_updated year, lcolor(red) clpattern(shortdash)), by(country) xtitle("")
    




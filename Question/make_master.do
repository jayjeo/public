
use oecd_VA, clear 
merge 1:1 year location activity using oecd_COMP, nogenerate
merge 1:1 year location activity using oecd_EMP, nogenerate

gen sector="10_12" if inlist(activity,"V10","V11","V12")
replace sector="13_15" if inlist(activity,"V13","V14","V15")
replace sector="16_18" if inlist(activity,"V16","V17","V18")
replace sector="19" if inlist(activity,"V19")
replace sector="20_21" if inlist(activity,"V20","V21")
replace sector="22_23" if inlist(activity,"V22","V23")
replace sector="24_25" if inlist(activity,"V24","V25")
replace sector="26_27" if inlist(activity,"V26","V27")
replace sector="28" if inlist(activity,"V28")
replace sector="29_30" if inlist(activity,"V29","V30")
replace sector="31_33" if inlist(activity,"V31","V32")
drop activity
drop if sector==""
collapse (sum) oecd_VA oecd_COMP oecd_EMP, by(location sector year)
save oecd, replace 


use "OECD/oecd_NOPS_detail", clear
merge 1:1 year location sector using oecd_GOPS_detail, nogenerate
keep oecd_GOPS_detail oecd_NOPS_detail year location sector
egen loc=group(location)
egen ind=group(sector)
egen ij=group(sector location)

twoway(scatter oecd_GOPS_detail oecd_NOPS_detail )(function y=x, range(-5000000000 200000000000)) ///
    , xlabel(0(2000000000000)200000000000) ylabel(0(2000000000000)200000000000) legend(off) ytitle(GOPS) xtitle(NOPS) ///
      text(100000000000 130000000000 "Y=X", placement(ne) size(vlarge) color(orange))
    graph export "GOPSNOPSraw.eps", as(eps) preview(off) replace

gen oecd_GOPS_detail2=oecd_GOPS_detail*oecd_GOPS_detail
reg oecd_NOPS_detail oecd_GOPS_detail oecd_GOPS_detail2 i.ind i.loc i.ij
predict oecd_NOPS_detail_pr, xb
//twoway(scatter oecd_NOPS_detail_pr oecd_NOPS_detail )(function y=x, range(-5000000000 150000000000))
replace oecd_NOPS_detail=oecd_NOPS_detail_pr if oecd_NOPS_detail==.
twoway(scatter oecd_NOPS_detail_pr oecd_NOPS_detail )(function y=x, range(-5000000000 150000000000)) ///
    , xlabel(0(2000000000000)20000000000) ylabel(0(2000000000000)20000000000) legend(off) ytitle(Predicted NOPS) xtitle(NOPS) ///
      text(60000000000 80000000000 "Y=X", placement(ne) size(vlarge) color(orange))
      graph export "GOPSNOPSpredicted.eps", as(eps) preview(off) replace
keep oecd_NOPS_detail year location sector
save oecd_NOPS_detail_predicted, replace 


use "KLEMS/KLEMS_jay", clear 
merge 1:1 year location sector using oecd, nogenerate
merge m:1 year location using oecd_population, nogenerate
merge m:1 year location using oecd_wage, nogenerate
merge m:1 year location using oecd_markup, nogenerate
merge m:1 year location using oecd_VALU_total, nogenerate
merge m:1 year location using oecd_LABR_total, nogenerate
merge m:1 year location using oecd_WAGE_total, nogenerate
merge m:1 year location using oecd_GOPS_total, nogenerate
merge m:1 year location using oecd_CFCC_total, nogenerate
merge m:1 year location using oecd_CPGK_total, nogenerate
merge 1:1 year location sector using oecd_VALU_detail, nogenerate
merge 1:1 year location sector using oecd_LABR_detail, nogenerate
merge 1:1 year location sector using oecd_WAGE_detail, nogenerate
merge 1:1 year location sector using oecd_GOPS_detail, nogenerate
merge 1:1 year location sector using oecd_NOPS_detail_predicted, nogenerate
merge 1:1 year location sector using oecd_CFCC_detail, nogenerate
merge 1:1 year location sector using oecd_CPGK_detail, nogenerate
merge m:1 year location  using KN_replication_from_scratch, nogenerate
merge 1:1 year location sector using IFRdata_manuf_detail, nogenerate
merge m:1 year location using IFRdata_manuf, nogenerate
merge 1:1 year location sector using markup_detail, nogenerate
merge m:1 year location using markup, nogenerate
merge m:1 year location using CPI, nogenerate
gen price_us=CPI      //!  price_consumption is from PWT data, and does not have industry variation
gen priceR_i=R_plain
//gen oecd_wage=oecd_wage // already PPP
gen population_us=oecd_population
foreach var of varlist installations operationalstock installations_detail operationalstock_detail{
    replace `var'=0.1 if `var'==.|`var'==0 
}
replace oecd_LABR_detail=oecd_WAGE_detail if oecd_LABR_detail==.
replace oecd_LABR_total=oecd_WAGE_total if oecd_LABR_total==.
replace oecd_LABR_detail=0 if oecd_LABR_detail<0
replace oecd_VALU_detail=0 if oecd_VALU_detail<0
replace oecd_CFCC_detail=oecd_VALU_detail-oecd_LABR_detail-oecd_NOPS_detail if oecd_CFCC_detail==.
replace oecd_CFCC_detail=0 if oecd_CFCC_detail<0
replace markup_detail=oecd_VALU_detail/(oecd_LABR_detail+oecd_CFCC_detail)

gen ls_test=oecd_LABR_detail/oecd_VALU_detail
replace oecd_LABR_detail=. if ls_test>=1
replace oecd_VALU_detail=. if ls_test>=1
save master, replace

//! update later
use "KN/KN_replication", clear   
keep location year price_consumption
save price_consumption, replace 

/*
use oecd_markup, clear 
merge 1:1 year location using markup, nogenerate
keep if location=="ITA"
tsset year 
twoway(tsline markup, lcolor(blue))(tsline oecd_markup, lcolor(red) yaxis(2))
*/


/*
use master, clear
keep location year oecd_CFCC_total oecd_VALU_total oecd_LABR_total oecd_GOPS_total
replace oecd_CFCC_total=oecd_VALU_total-oecd_LABR_total-oecd_GOPS_total if oecd_CFCC_total==.
replace oecd_CFCC_total=0 if oecd_CFCC_total<0
gen markup_total=oecd_VALU_total/(oecd_LABR_total+oecd_CFCC_total)
duplicates drop
keep if year>=1998
keep if inlist(location,"AUS","AUT","BEL","CZE","DEU","DNK","ESP")| ///
inlist(location,"EST","FIN","FRA","GBR","GRC","HUN","ISL","ITA")| ///
inlist(location,"JPN","KOR","LTU","LUX","LVA","MEX","NLD","NOR")| ///
inlist(location,"NZL","POL","PRT","SVK","SVN","SWE","USA")
drop if markup_total==.
egen country=group(location)
xtset country year
tsfill, full
drop if year==2019
keep location year markup_total
replace location="GER" if location=="DEU"
drop if location=="GRC"
rename location country_label
save "C:\Users\acube\Dropbox\Study\DR\230225\laborshare_replication\markup", replace 
*/

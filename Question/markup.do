use "jd_prod_industry2d_20e_weighted", clear 

keep if by_var=="CE51_markup_ml_1" & by_var_value==100
keep CE51_markup_ml_1_p50 country industry2d year
rename CE51_markup_ml_1_p50 markup

gen location="AUT" if country=="AT"  //Austria
replace location="CZE" if country=="CZECH REPUBLIC"  //Czech Republic
replace location="DEU" if country=="GERMANY"  //Germany
replace location="DNK" if country=="DENMARK"  //Denmark
replace location="ESP" if country=="SPAIN"  //Spain
replace location="FIN" if country=="FINLAND"  //Finland
replace location="FRA" if country=="FRANCE"  //France
replace location="HUN" if country=="HUNGARY"  //Hungary
replace location="ITA" if country=="ITALY"  //Italy
replace location="LTU" if country=="LITHUANIA"  //Lithuania
replace location="NLD" if country=="NETHERLANDS"  //Netherlands
replace location="POL" if country=="POLAND"  //Poland
replace location="PRT" if country=="PORTUGAL"  //Portugal
replace location="ROU" if country=="ROMANIA"  //Romania
replace location="SWE" if country=="SWEDEN"  //Sweden
replace location="SVN" if country=="SLOVENIA"  //Slovenia
replace location="SVK" if country=="SLOVAKIA"  //Slovak Republic
drop if location==""
drop country
order location industry2d year markup 

gen sector="10_12" if inlist(industry2d,10,11)
replace sector="13_15" if inlist(industry2d,13,14,15)
replace sector="16_18" if inlist(industry2d,16,17,18)
replace sector="19" if inlist(industry2d,999)   // not exist
replace sector="20_21" if inlist(industry2d,20)
replace sector="22_23" if inlist(industry2d,22,23)
replace sector="24_25" if inlist(industry2d,24,25)
replace sector="26_27" if inlist(industry2d,26,27)
replace sector="28" if inlist(industry2d,28)
replace sector="29_30" if inlist(industry2d,29,30)
replace sector="31_33" if inlist(industry2d,31,32,33)
drop industry2d
drop if sector==""
rename markup markup_detail
collapse (mean) markup_detail, by(location sector year) 
smoothingmanuf sector markup_detail
keep location sector year markup_detail
drop if location==""
save markup_detail, replace 




*====================================================
use KLEMS/KLEMS_jay, clear 
keep location sector year valueVA
save KLEMS_jay_temp, replace 
use markup_detail, clear 
merge 1:1 location sector year using KLEMS_jay_temp
keep if _merge==3
drop _merge 
collapse (mean) markup_detail [pweight=valueVA], by(location year)
rename markup_detail markup
save markup, replace 


/*====================================================
use "data/CompNet/jd_prod_country_all_unweighted", clear 

keep if by_var=="CE51_markup_ml_1" & by_var_value==100
keep CE51_markup_ml_1_p50 country year
rename CE51_markup_ml_1_p50 markup

gen location="AUT" if country=="AT"  //Austria
replace location="CZE" if country=="CZECH REPUBLIC"  //Czech Republic
replace location="DEU" if country=="GERMANY"  //Germany
replace location="DNK" if country=="DENMARK"  //Denmark
replace location="ESP" if country=="SPAIN"  //Spain
replace location="FIN" if country=="FINLAND"  //Finland
replace location="FRA" if country=="FRANCE"  //France
replace location="HUN" if country=="HUNGARY"  //Hungary
replace location="ITA" if country=="ITALY"  //Italy
replace location="LTU" if country=="LITHUANIA"  //Lithuania
replace location="NLD" if country=="NETHERLANDS"  //Netherlands
replace location="POL" if country=="POLAND"  //Poland
replace location="PRT" if country=="PORTUGAL"  //Portugal
replace location="ROU" if country=="ROMANIA"  //Romania
replace location="SWE" if country=="SWEDEN"  //Sweden
replace location="SVN" if country=="SLOVENIA"  //Slovenia
replace location="SVK" if country=="SLOVAKIA"  //Slovak Republic
drop if location==""
drop country
order location year markup 
collapse (mean) markup, by(location year) 
save markup, replace 

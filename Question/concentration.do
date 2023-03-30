//use "C:\Users\acube\Dropbox\Study\UC Davis\Writings\LaborShareKorea\CompNet\unconditional_industry2d_20e_unweighted", clear 
use "unconditional_industry2d_all_unweighted", clear 
//use "K:\Dropbox\Study\UC Davis\Writings\LaborShareKorea\CompNet\unconditional_industry2d_all_unweighted", clear 
drop if industry2d==12
rename CR02_top_rev_sam_2D_tot CR02
keep country industry2d year FV08_nrev_N FV08_nrev_mn CR02
gen tR=FV08_nrev_N*FV08_nrev_mn
egen tRmean=mean(tR), by(country industry2d)
replace tR=tRmean if tR==.
gen tenR=CR02*tR

gen sector="10_12" if inlist(industry2d,10,11)	 //Food products, beverages and tobacco
replace sector="13_15" if inlist(industry2d,13,14,15)	 //Textiles, wearing apparel, leather and related prodcuts
replace sector="16_18" if inlist(industry2d,16,17,18)	 //Wood and paper products; printing and reproduction of recorded media
//replace sector="19" if inlist(industry2d,9999)	 //Coke and refined petroleum products
replace sector="20_21" if inlist(industry2d,20,21)	 //Chemicals and chemical products
replace sector="22_23" if inlist(industry2d,22,23)	 //Rubber and plastics products, and other non-metallic mineral products
replace sector="24_25" if inlist(industry2d,24,25)	 //Basic metals and fabricated metal products, except machinery and equipment
replace sector="26_27" if inlist(industry2d,26,27)	 //Electrical and optical equipment
replace sector="28" if inlist(industry2d,28)	 //Machinery and equipment n.e.c.
replace sector="29_30" if inlist(industry2d,29,30)	 //Transport equipment
replace sector="31_33" if inlist(industry2d,31,32,33)	 //Other manufacturing; repair and installation of machinery and equipment
drop if sector==""

save concentration_temp, replace 

**** concentration by country sector year ****
use concentration_temp, clear 
collapse (sum) tenR tR (mean) CR02, by(country sector year)
gen CR02_2=tenR/tR
scatter CR02 CR02_2
drop CR02

egen ij=group(country sector)
xtset ij year
tsfill
ipolate CR02_2 year, gen(concentration) epolate by(ij) 

gen location="BEL" if country=="BELGIUM"
replace location="CZE" if country=="CZECH REPUBLIC"
replace location="DEU" if country=="GERMANY"
replace location="DNK" if country=="DENMARK"
replace location="ESP" if country=="SPAIN"
replace location="FIN" if country=="FINLAND"
replace location="FRA" if country=="FRANCE"
replace location="HUN" if country=="HUNGARY"
replace location="ITA" if country=="ITALY"
replace location="LTU" if country=="LITHUANIA"
replace location="NLD" if country=="NETHERLANDS"
replace location="POL" if country=="POLAND"
replace location="PRT" if country=="PORTUGAL"
replace location="SVN" if country=="SLOVENIA"
replace location="SVK" if country=="SLOVAKIA"
replace location="SWE" if country=="SWEDEN"
drop if location==""
drop ij

save concentration, replace 



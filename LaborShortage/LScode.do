

/*********************************************
****************Dataset links****************
Does not need to download to run this code.
Most of webpages do not provide English version.

The Labor Force Survey at Establishments (LFSE; 사업체노동력조사)
http://laborstat.moel.go.kr (opened to public)

Employment Permit System (EPS; 고용허가제고용동향)
https://www.open.go.kr/ (opened to Korean citizen)

Monthly Survey of Mining And Manufacturing (MSMM; 광업제조업 동향조사)
https://kosis.kr/ (opened to public)

Economically Active Population Survey (EAPS; 경제활동인구조사)
https://mdis.kostat.go.kr/ (opened to Korean citizen)

Employment Information System (EIS; 고용보험통계)
https://eis.work.go.kr/ (opened to public)

Korean Labor and Income Panel Study (KLIPS; 한국노동패널)
https://www.kli.re.kr/klips/ (opened to public; required to sign up)

Worknet Job Search Trend (워크넷 구인구직)
https://eis.work.go.kr/ (opened to public)

Minimum Wage Trend (최저임금위원회 최저임금제도)
https://www.minimumwage.go.kr/minWage/policy/decisionMain.do (opened to public)

Korea Immigration Service Monthly Statistics (출입국외국인정책 통계월보)
https://www.immigration.go.kr/immigration/1569/subview.do (opened to public)

Survey on Immigrant's Living Conditions and Labour Force (이민자체류실태및고용조사)
https://mdis.kostat.go.kr/ (opened to Korean citizen)

Currency Exchange Rate (원달러환율)
https://www.index.go.kr/potal/main/EachDtlPageDetail.do?idx_cd=1068 (opened to public)

*********************************************/

** LScode ver10.2.do
cls
clear all
set scheme s1color, perm 

/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\Github move\Latex\Dissertation Draft ver10.0"   
/*********************************************
*********************************************/
cd "${path}"

/*********************************************
Required programs
*********************************************/
net install Jay_ado.pkg, from(https://raw.githubusercontent.com/jayjeo/public/master/adofiles)
copy "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/X12A.EXE" "${path}/X12A.exe"
net install st0255, from(http://www.stata-journal.com/software/sj12-2)
adopath + "${path}"
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
cap ado uninstall ivreg2
ssc install ivreg2, replace
cap ado uninstall ivreghdfe
net install ivreghdfe, from("https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/")
ssc install ranktest, replace
*To completely uninstall the files
*ado uninstall filename



/*********************************************
Graphs generation
*********************************************/
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/minwage.csv", clear 
tsset ym
format ym %tm
gen minwagereal=minwage*100/cpi
save minwage, replace

cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/worknet_parttime.csv", clear 
tsset ym
format ym %tm
gen partpercent=worknet_parttime/worknet_total*100
gen partpercent_high=worknet_parttime_high/worknet_total_high*100  // below tertiary
gen partpercent_occ8=worknet_parttime_occ8/worknet_total_occ8*100  // among occ=8 (manufacture occupation)
replace partpercent=partpercent*0.883765357084955 if ym>=734
replace partpercent_high=partpercent_high*0.883765357084955 if ym>=734
replace partpercent_occ8=partpercent_occ8*0.883765357084955 if ym>=734

merge 1:1 ym using minwage, nogenerate

twoway (tsline minwagereal, lwidth(thick) lcolor(gs0) yaxis(1)) /// 
        (tsline partpercent, lcolor(gs0) yaxis(2)) ///
        (tsline partpercent_high, lcolor(gs0) clpattern(longdash) yaxis(2)) ///
        (tsline partpercent_occ8, lcolor(gs0) clpattern(shortdash) yaxis(2)) ///
    , xtitle("") ytitle("") xline(720) ysize(1) xsize(3) xlabel(624(12)744) ylabel(4(4)14, axis(2)) ///
    caption("Source: Worknet Job Search Trend (Korea Employment Information Service)" "              Minimum Wage Trend (Minimum Wage Commission)") ///
    legend(label(1 "Minimun Wage") label(2 "Total Seekers") label(3 "Below Tertiary") label(4 "Occupation=8") ) 
graph export partpercent.eps, replace


*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/monthlye9.csv", clear 
gen date=ym(year,month)
tsset date
format date %tm

tsfilter hp e9inflow_hp = e9inflow, trend(smooth_e9inflow) smooth(6)
keep if date>=648

twoway (tsline smooth_e9inflow, lcolor(gs0))(tsline e9stock, lwidth(thick) lcolor(gs0) yaxis(2)) ///
, xlabel(648(6)744) xlabel(, grid angle(270)) xline(720) ytitle("person", axis(1)) ytitle("person", axis(2)) scheme(s1mono) ///
ysize(3.5) xsize(8) ///
legend(label(1 "E9 inflow") label(2 "E9 stock")) ///
caption("Source: Employment Permit System (EPS)")
graph export monthlye9.eps, replace


*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/uib.csv", varnames(1) clear 
gen ym=t+592
format ym %tm
tsset ym
gen uib_adj=uib
*replace uib_adj=uib*0.7 if ym>=720  

gen recession1=0
replace recession1=1 if 717<=ym   //2019m10
gen recession2=0
replace recession2=1 if 719<=ym
gen recession3=0
replace recession3=1 if 721<=ym
gen recession4=0
replace recession4=1 if 724<=ym

reg ut uib recession1-recession4
predict uib_p
replace uib_p=uib if ym<717
twoway (tsline ut, lcolor(gs0))(tsline uib, lcolor(red))(tsline uib_p, lcolor(blue) clpattern(longdash)) ///
    , xtitle("") ytitle("%") xline(720) /// 
    ysize(3.5) xsize(8) ///
    legend(label(1 "Unemployment rate") label(2 "Unemployment Insurance Benefit") label(3 "Unemployment Insurance Benefit (adjusted)") order(1 2 3))
graph export uib.eps, replace



		
*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/ConclusionFigures.csv", varnames(1) clear 

drop if inlist(countries,"Ireland","Luxembourg")
replace countries="Czech" if countries=="Czech Republic"
replace countries="Slovak" if countries=="Slovak Republic"
//replace countries="UK" if countries=="United Kingdom"
//replace countries="US" if countries=="United States"

twoway (scatter forper2020 gdppercapita2020 if countries!="South Korea", mlabel(countries) mlabangle(+10) mcolor(gs0)) ///
       (scatter forper2020 gdppercapita2020 if countries=="South Korea", mlabel(countries) mlabangle(+10) mcolor(red) mlabcolor(red) msize(large)) ///
       (lfit forper2020 gdppercapita2020) ///
		, ytitle("Foreigner proportion in 2020 (%)") xtitle("GDP per Capita in 2020 ($,2005)") ///
		ysize(3.5) xsize(8) xlabel(17000(10000)67000) scheme(s1mono) legend(label(3 "Linear fit") order(3)) ///
        caption("Source: International Migration Database, OECD")
graph export forper2020.eps, replace

*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/ConclusionFigures.csv", varnames(1) clear 

drop if inlist(countries,"Ireland","Luxembourg")
replace countries="Czech" if countries=="Czech Republic"
replace countries="Slovak" if countries=="Slovak Republic"
replace countries="UK" if countries=="United Kingdom"
//replace countries="US" if countries=="United States"

twoway (scatter tertiary2020 gdppercapita2020 if countries!="South Korea", mlabel(countries) mlabangle(+15) mcolor(gs0)) ///
       (scatter tertiary2020 gdppercapita2020 if countries=="South Korea", mlabel(countries) mlabangle(+15) mcolor(red) mlabcolor(red) msize(large)) ///
       (lfit tertiary2020 gdppercapita2020) ///
		, ytitle("Tertiary or above in 2020 (%)") xtitle("GDP per Capita in 2020 ($,2005)") ///
		ysize(3.5) xsize(8) xlabel(17000(10000)67000) scheme(s1mono) legend(label(3 "Linear fit") order(3)) ///
        caption("Source: Education at a Glance, OECD")
graph export tertiary2020.eps, replace

*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/PopulationProjections(normalized).csv", varnames(1) clear 

reshape long y, i(countries) j(year)
rename y projection
egen countries_id = group(countries) 
keep if inlist(countries,"Mexico","Italy","Germany","United States","Japan","South Korea")
gen D=0
replace D=1 if inlist(countries,"Italy","United States")
xtset countries_id year, yearly
summ year
xtline projection, overlay scheme(s2mono) ///
addplot((scatter projection year if year==2027 & D==0, mlabel(countries) legend(off)) ///
    (scatter projection year if year==2025 & D==1, mlabel(countries))) ///
    ytitle("Population""Normalized to 1 in 2005") xtitle("") ///
    caption("Source: Population Projections, OECD")
graph export PopulationProjections.eps, replace


*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/SVARdata.csv", clear 
gen month=_n+623
tsset month 
format month %tm

gen forpercent=fw/(fw+dw)*100
keep if month >= 648 

twoway (tsline forpercent, lcolor(gs0)) ///
, xlabel(648(6)743) xlabel(, grid angle(270)) xline(720) xtitle("") ytitle("%") scheme(s1mono) ///
ysize(3) xsize(8) legend(off) ///
caption("Source: Korea Immigration Service Monthly Statistics & Survey on Immigrant's Living Conditions and Labour Force")
graph export forpercent.eps, replace

gen date=month
keep date forpercent
cd "E:\Dropbox\Study\UC Davis\Writings\Labor Shortage USA" 
save LSUSAfigure, replace 
cd "${path}"

*********************
*!start
***** Need to manually download dataset from https://www.dropbox.com/s/gpy3ekn6w3ve8np/cps.dta
cd "${path}"
use cps, clear
gen date= ym(real(substr(string(infile),1,4)), real(substr(string(infile),5,2)))
save cpsdate, replace 

use cpsdate, clear
keep if 50<=age&age<80
keep if retired==1
collapse (sum) num [pweight=wgt], by(date)
tsset date
lowess num date if date<=720, gen(lowessnum2)
lowess num date, gen(lowessnum3)
ipolate lowessnum2 date, gen(lowessnum) epolate
gen er=lowessnum3/lowessnum
replace er=1 if date<720
*twoway (tsline num)(tsline lowessnum)(tsline lowessnum3 if date>720)
gen state=0
save er0, replace 

use er0, clear
format date %tm
replace num=num/1000/1000  // 1 thousand persons
replace lowessnum=lowessnum/1000/1000  // 1 thousand persons
replace lowessnum3=lowessnum3/1000/1000  // 1 thousand persons
twoway (tsline num, lcolor(gs0))(tsline lowessnum, lcolor(gs0) lwidth(thick))(tsline lowessnum3 if date>720, lwidth(thick) lcolor(gs0)) ///
    , xtitle("") xline(720) ysize(1) xsize(1.5) xlabel(600(24)744) ///
    ytitle("Million persons") ///
    legend(label(1 "Number of retired people") label(2 "Trend") order(1 2))
graph export Excessretire.eps, replace

***** Another more accurate method. 
cd "${path}"
use cpsdate, clear
keep if 20<=age&age<80
*tab date 
gen agecat=0
replace agecat=1 if 20<=age&age<25
replace agecat=2 if 25<=age&age<30
replace agecat=3 if 30<=age&age<35
replace agecat=4 if 35<=age&age<40
replace agecat=5 if 40<=age&age<45
replace agecat=6 if 45<=age&age<50
replace agecat=7 if 50<=age&age<55
replace agecat=8 if 55<=age&age<60
replace agecat=9 if 60<=age&age<65
replace agecat=10 if 65<=age&age<70
replace agecat=11 if 70<=age&age<75
replace agecat=12 if 75<=age&age<80
save cpsagecat, replace 

use cpsagecat, clear 
keep if 708<=date&date<=719 // 2019m1~2019m12
collapse (sum) num [pweight=wgt], by(agecat retired)
reshape wide num, i(agecat) j(retired) 
keep if 7<=agecat
gen prob=num1/(num0+num1)
keep agecat prob 
save prob, replace 

cd "${path}"
use cpsagecat, clear
keep if 7<=agecat
keep if 719<date
collapse (sum) num [pweight=wgt], by(agecat date)
reshape wide num, i(agecat) j(date) 
merge 1:1 agecat using prob, nogenerate
forvalues i=720(1)743 {
    gen retiredestimate`i'=num`i'*prob
}
keep agecat retiredestimate*
reshape long retiredestimate, i(agecat) j(date) 
collapse (sum) retiredestimate, by(date)
save retiredestimate, replace 

use cpsagecat, clear
keep if 7<=agecat
keep if retired==1
collapse (sum) num [pweight=wgt], by(date)
merge 1:1 date using retiredestimate, nogenerate
tsset date 
format date %tm
replace num=num/1000/1000  // 1 thousand persons
replace retiredestimate=retiredestimate/1000/1000  // 1 thousand persons
lowess num date, gen(lowessnum)
twoway (tsline num, lcolor(gs0))(tsline lowessnum, lcolor(gs0) lwidth(thick))(tsline retiredestimate, lcolor(gs0) lwidth(thick)) ///
    , xtitle("") xline(720) ysize(1) xsize(1.5) xlabel(600(24)744) ///
    ytitle("Million persons") ///
    legend(label(1 "Number of retired people") label(2 "Estimated retired people") order(1 2))
graph export Excessretire_est.eps, replace


*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/unauthorizedshare.csv", varnames(1) clear 
twoway (connected share time, lcolor(gs0) lwidth(med) mcolor(gs0)) ///
, xlabel(1"y99" 2"y00" 3"y01" 4"y02" 5"y03" 6"y04" 7"y05" 8"y06" 9"y07" 10"y08" 11"y09" 12"y10" 13"y11" 14"y12" 15"y13" 16"y14" 17"y15" 18"y16" 19"y17" 20"y18" 21"y19" 22"y20" 23"y21" 24"y22m3") ///
xtitle("") ytitle("%") ysize(1) xsize(3) ymtick(#20, grid tstyle(none))
graph export unauthorizedshare.eps, replace


/*********************************************
Data Merge
*********************************************/
//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
keep if ym==648
rename numd numd648
keep indmc ym numd648
save numd648, replace 

//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/u.csv", varnames(1) clear 
        // E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\경제활동인구조사\rawdata\infile3 (2015~2017추가).do   =>  nonuC
rename nonuc ut
replace ut=ut
rename uc uC
gen indmc=0
save ut, replace 

use ut, clear
//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/e9inflow.csv", varnames(1) clear 
destring *, replace dpcomma
reshape long ym, i(indmc) j(j)
rename ym e9inflow
rename j ym
save e9inflow, replace 

//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/cpi.csv", varnames(1) clear 
save cpi, replace

//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/exchangerate.csv", varnames(1) clear 
save exchangerate, replace

//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/totalforeignproportion.csv", varnames(1) clear 
save forper, replace 

//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
merge 1:1 ym indmc using ut, nogenerate
merge m:1 ym using cpi, nogenerate
merge m:1 ym using exchangerate, nogenerate
merge 1:1 ym indmc using e9inflow, nogenerate
merge m:1 indmc using forper, nogenerate
merge m:1 indmc using numd648, nogenerate

xtset indmc ym   // indmc = sub-sector of manufacturing industry. ; ym = monthly time.
format ym %tm
gen ymraw=ym

rename (nume numd exit numefull numdfull numepart numdpart) (numE numD EXIT numEfull numDfull numEpart numDpart)  
// numE = number of vacant spots ; numD = number of workers ; EXIT = number of separated workers
gen v=numE/numD*100   // v = vacancy rate
gen vfull=numEfull/numDfull*100   // v = vacancy rate (full-time workers)
gen vpart=numEpart/numDpart*100   // v = vacancy rate (part-time workers)

gen uibCC=uib/numD*100
gen uibOriginal=uib/numD*100*0.896503381
*gen uibCC=uib/numD*100*0.896503381 if ym<720
*replace uibCC=uib/numD*100*0.63 if ym>=720

gen wage=wage_tot*100/cpi/hour/exchangerate  // cpi adjusted hourly wage (unit=USD)
gen wagefull=wage_totfull*100/cpi/hourfull/exchangerate  // cpi adjusted hourly wage (unit=USD)
gen wagepart=wage_totpart*100/cpi/hourpart/exchangerate  // cpi adjusted hourly wage (unit=USD)

gen uibmoney2=uibmoney/numd648/cpi/exchangerate
drop uibmoney
rename uibmoney2 uibmoney

drop if inlist(indmc,12)  // tobacco industry. Extremely few workers, and production data is not available.
sort indmc ym
keep if 648<=ym&ym<=747   // largest available data span.

gen Break1=0
replace Break1=1 if ym>=717
gen Break2=0
replace Break2=1 if ym>=718
gen Break3=0
replace Break3=1 if ym>=719
gen Break4=0
replace Break4=1 if ym>=720
gen Break5=0
replace Break5=1 if ym>=721
gen recession1=0
replace recession1=1 if 668<=ym
gen recession2=0
replace recession2=1 if ym<=672
gen recession3=0
replace recession3=1 if ym<=677
gen recession4=0
replace recession4=1 if 699<=ym
gen recession5=0
replace recession5=1 if ym<=710

gen months=month(dofm(ym))
tabulate months, generate(tau)
gen quarters=quarter(dofm(ym))
tabulate quarters, generate(rho)
save panelm_uib, replace 

use panelm_uib, clear
xtset ym indmc
reg ut uibCC recession1-recession5 rho1-rho4 tau2-tau12 if indmc==0
predict uibC
keep indmc ym uibC
save uibC_master, replace 

use panelm_uib, clear
merge 1:1 indmc ym using uibC_master, nogenerate
save panelm, replace 

/*
use panelm, clear 
keep if indmc==0
twoway (tsline uibC)(tsline ut, lwidth(thick))

tsset ym 
gen uibCCC=uib/numD*100
sax12 ut, satype(single) inpref(ut.spc) outpref(ut) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12im "ut.out", ext(d11)
twoway (tsline uibCCC uibCC)(tsline uibC, lwidth(thick))(tsline ut_d11, lcolor(red) lwidth(thick)), xline(720)

use panelm, clear 
twoway (tsline uibC if indmc==0)(tsline uibC if indmc==10)(tsline uibC if indmc==11)(tsline uibC if indmc==13)(tsline uibC if indmc==14)(tsline uibC if indmc==15)(tsline uibC if indmc==16)(tsline uibC if indmc==17)(tsline uibC if indmc==18)(tsline uibC if indmc==19)(tsline uibC if indmc==20)(tsline uibC if indmc==30)
*/


*!start
cd "${path}"
use panelm, clear
keep ym indmc numD e9 hourfull
reshape wide numD e9 hourfull, i(indmc) j(ym)

** 719=2019m12; 722=2020m3; 724=2020m5; 739=2021m8

gen e9chg=(e9744-e9715)/numD715*100
gen e9share=e9715/numD715*100
gen e9share684=e9684/numD684*100
gen e9share678=e9678/numD678*100
gen e9share660=e9660/numD660*100

keep indmc e9chg e9share e9share684 e9share678 e9share660 hourfull716
save chg, replace 


use panelm, clear
merge m:1 indmc using chg, nogenerate
save panelf2, replace 

*!start
cd "${path}"
use panelf2, clear
sort indmc ym 
gen numDpartproportion=numDpart/numDfull*100
gen l=numD/(1-uibC/100)
label var v "Vacancy" 
label var vfull "Vacancy(Full)" 
label var vpart "Vacancy(Part)"
label var hour "Work Hours" 
label var wage "Wage" 
label var wagefull "Wage(Full)" 
label var wagepart "Wage(Part)" 
label var numDpartproportion "Part/Full" 
label var uibC "Non-emloyment rate" 
label var prod "Production"
label var proddome "ProdDomestic"
label var prodabroad "ProdAbroad"
label var prodoper "ProdOperation" 
save panelf2_temp2, replace 

use panelf2_temp2, clear
keep if 648<=ym
gen bk1=0
replace bk1=1 if 673<=ym
gen bk2=0
replace bk2=1 if 703<=ym
gen bk3=0
replace bk3=1 if 725<=ym
foreach i of numlist 0 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    preserve 
        keep if indmc==`i'
        tsset ym, monthly
        gen theta=v/uibC
        gen lnF=ln(matched/(uibC/100)/l)
        gen lntheta=ln(theta)
        reg lnF lntheta tau2-tau12 bk1-bk3, noconstant 
        *nl (lnF={eta=0.7}*lntheta+{xb:tau2-tau12}+{bkb:bk1-bk3})
        gen eta_biased=_b[lntheta]
        keep if _n==1
        di `i'
        keep indmc eta_biased
        save eta_biased`i', replace 
    restore 
}

use eta_biased0, clear
foreach i of numlist 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    append using eta_biased`i'
}
save eta_biased_master, replace 

use panelf2_temp2, clear 
merge m:1 indmc using eta_biased_master, nogenerate
sort indmc ym
xtset indmc ym
gen jfr=ln(matched/(uibC/100)/l)
gen theta=ln(v/uibC)
gen jfr_theta_eta=jfr-eta_biased*theta
gen a_alter=matched/(uibC/100*l*(v/uibC)^eta_biased)
keep jfr_theta_eta tau* ym indmc eta_biased a_alter
keep if 648<=ym&ym<=746
foreach i of numlist 0 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    preserve
        keep if indmc==`i'
        tsset ym
        reg jfr_theta_eta tau2-tau12 // if 648<=ym&ym<=719
        predict a_biased, residuals
        replace a_biased=a_biased+_b[_cons]
        replace a_biased=exp(a_biased)
        reg a_alter tau2-tau12
        predict a_biased2, residuals
        replace a_biased2=a_biased2+_b[_cons]
        replace a_biased2=exp(a_biased2)
        keep indmc ym a_biased eta_biased a_biased2
        save matcheff_biased`i', replace 
    restore
}

use matcheff_biased0, clear 
foreach i of numlist 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    append using matcheff_biased`i'
}
save matcheff_biased_master, replace 

use panelf2_temp2, clear 
merge 1:1 indmc ym using matcheff_biased_master, nogenerate
gen lambda=EXIT/l        // calibration result for termination rate  
keep if 648<=ym&ym<=747   // largest available data span.
save panelf3_temp3, replace

use panelf3_temp3, clear
keep ym indmc numD
keep if 713<=ym&ym<=719
collapse (mean) numD, by(indmc)
rename numD numDbefore
save numDbefore, replace 

use panelf3_temp3, clear
keep ym indmc numDfull
keep if 713<=ym&ym<=719
collapse (mean) numDfull, by(indmc)
rename numDfull numDfullbefore
save numDfullbefore, replace 

use panelf3_temp3, clear
merge m:1 indmc using numDbefore, nogenerate
merge m:1 indmc using numDfullbefore, nogenerate
gen v_alter=numE/numDbefore*100
replace v_alter=v if ym<720
gen vfull_alter=numEfull/numDfullbefore*100
replace vfull_alter=vfull if ym<720
label var v_alter "Vacancy(alter)"  
label var vfull_alter "Vacancy(Full,alter)"  
gen theta=v/uibC
gen theta_alter=v_alter/uibC
label var theta "Tightness" 
label var theta_alter "Tightness(alter)" 
save panelf3_temp4, replace 


/*********************************************
Estimate Match efficiency by state (Borowczyk-Martins2013)
*********************************************/
//!start
cd "${path}"
use panelf3_temp, clear
keep if 648<=ym&ym<=746
sort indmc ym
xtset indmc ym
gen theta=ln(v/uibC)
gen jfr=ln(matched/(uibC/100)/l)
drop if jfr==.
gen year=year(dofm(ym))
gen month=month(dofm(ym))
gen t=ym-647
rename uibC u
gen bk1=0
replace bk1=1 if 673<=ym
gen bk2=0
replace bk2=1 if 703<=ym
gen bk3=0
replace bk3=1 if 725<=ym

keep year month ym t jfr theta u indmc bk*
tab month, gen(m_)
drop m_1
drop if jfr==.
save matcheffmaster, replace 

cap program drop estim_grid
program define estim_grid
syntax [, P(real 1) Q(real 1) ADDLAGSTH(integer 1) LAGSJFR(integer 1) BK(integer 1) PMAX(integer 1) SELECT(string) ETA0(real 1) GRAPH] 
	
	preserve
	
	if "`select'"~=""	keep if `select'
	
	local first = `q' + 1
	
	local last_th = `q' + `p' + 1 + `addlagsth'
	local laglist_th "`first'/`last_th'"
	
	if `lagsjfr'>0	{
		local last_jfr = `q' + `lagsjfr'
		local laglist_jfr "`first'/`last_jfr'"
					}
		
	if `lagsjfr'>0	local inst "l(`laglist_th').theta l(`laglist_jfr').jfr m_*"
	else local inst "l(`laglist_th').theta m_*"
	
    if `bk'==1 local inst "`inst' bk*"

	local addobs = 100
		
	// Instruments = 0 if missing
	local new_n = _N + `addobs'
	set obs `new_n'
	recode * (.=0)
	sort t
	replace t = _n  
	sort t
	tsset t
	gen insamp = (t>=`addobs' + max(`q'+2,`p'+1))
	
	// Proper IV imposing common factor restriction , full sample
	local urtest "(-1)"

	local esteq "jfr - {eta}*theta - {mu}"
	forval m = 2/12	{
		local esteq "`esteq' - {tau`m'}*m_`m'"
					}		
	forval l = 1/`p'	{
		
		local urtest "[rho`l']_cons + `urtest'"
		
		local esteq "`esteq' - {rho`l'}*(l`l'.jfr - {eta}*l`l'.theta"
		forval m = 2/12	{
			local esteq "`esteq' - {tau`m'}*l`l'.m_`m'"
						}	
		local esteq "`esteq')"
						}
    if `bk'==1	{
        local esteq "`esteq' - {b1}*bk1 - {b2}*bk2 - {b3}*bk3"
        forval l = 1/`p'	{
            local esteq "`esteq' + {rho`l'}*( {b1}*l`l'.bk1 + {b2}*l`l'.bk2 + {b3}*l`l'.bk3 )"
                            }
                }

	local esteq "(`esteq')"
	local urtest "`urtest' == 0"
		
	mat m = J(5 + 2*(`pmax'+2) ,1,.)
	mat m[1,1] = `p'
	mat m[2,1] = `q'
	
	cap	{
		noi gmm `esteq' if insamp, instruments(`inst') twostep vce(unadjusted) wmatrix(unadjusted) from(mu 0 eta `eta0')
		
		mat V = e(V)
		
		// Retrieve the actual constant and its SE
		matrix V = V["mu:_cons","mu:_cons".."rho`p':_cons"] \ V["rho1:_cons".."rho`p':_cons","mu:_cons".."rho`p':_cons"]
		matrix V = V[1...,"mu:_cons"] , V[1...,"rho1:_cons".."rho`p':_cons"]
		local denom = 1
		forval arp = 1/`p'	{
			local denom = `denom'-[rho`arp']_b[_cons]
							}
							
		local mu = [mu]_b[_cons]/`denom'
		
		mat G = 1/`denom' \ J(`p',1,`mu'/`denom')
		mat SE = G'*V*G
				
		matrix m[3,1] = sqrt(SE[1,1]) \ `mu' 
		* matrix m[3,1] = [mu]_se[_cons] \ [mu]_b[_cons]  
		matrix m[5,1] = [eta]_se[_cons] \ [eta]_b[_cons] 
		forv arp = 1/`p'	{
			/*
			local t = [rho`arp']_b[_cons] / [rho`arp']_se[_cons]
			matrix m[6 + 2*`arp'-1 ,1] = `t' \ [rho`arp']_b[_cons]
			*/
			
			matrix m[6 + 2*`arp'-1 ,1] = [rho`arp']_se[_cons] \ [rho`arp']_b[_cons] 
			
							}
			
		test "`urtest'"
		matrix m[6 + 2*`pmax' + 1,1] = r(p)
		
		noi estat overid
		matrix m[6 + 2*`pmax' + 2,1] = r(J) \ r(J_p)
				
		if "`graph'"~=""	{
			predict omega if insamp
			noi ac omega if insamp, lag(18) level(90) text(-.15 14 "(p,q) = (`p',`q')", box place(e) margin(medsmall)) /*
				*/ note("") xlab(0(2)18) scheme(s1mono) name(name`p'`q', replace)
							}
		}
	restore
end

*** p selection protocol
cap program drop estim_indmc
program define estim_indmc
    args indmc 
        use matcheffmaster, clear
        keep if indmc==`indmc'

        qui	{
        local pmin = 1
        local pmax = 4

        matrix results = J(5 + 2*(`pmax'+2),1,.)
        local rnames "p q sd(mu) mu sd(eta) eta"
        noi di "--------------------------------------------------"
        forv p = 1/`pmax'	{
            local rnames "`rnames' sd(rho`p') rho`p'"
            
            if `p'>=`pmin'	{
                forv q = 0/6	{
                    noi di _con "(`p' , `q') -- "
                    estim_grid, p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) bk(1) eta0(0.3)
                    matrix results = (results , m)
                                }	
                            }
                            }

        noi di " "
        noi di "--------------------------------------------------"
        local rnames "`rnames' UR_p Hansen Hans_p"
        mat rownames results = `rnames'
        mat results = results[1...,2...]
        mat results = results'
        }

        matain results
        // p and q
        mata rest=results[.,1],results[.,2]
        // p-value for mu
        mata z=abs(results[.,4]:/results[.,3])
        mata rest1=2*normal(-abs(z))
        // eta
        mata eta=results[.,6]
        // p-value for eta
        mata z=abs(results[.,6]:/results[.,5])
        mata rest2=2*normal(-abs(z))
        // p-value for rho1
        mata z=abs(results[.,8]:/results[.,7])
        mata rest3=2*normal(-abs(z))
        // p-value for rho2
        mata z=abs(results[.,10]:/results[.,9])
        mata rest4=2*normal(-abs(z))
        // p-value for rho3
        mata z=abs(results[.,12]:/results[.,11])
        mata rest5=2*normal(-abs(z))
        // p-value for rho4
        mata z=abs(results[.,14]:/results[.,13])
        mata rest6=2*normal(-abs(z))
        mata rest=rest,rest1,eta,rest2,rest3,rest4,rest5,rest6
        mata rest 
end

*** q selection protocol
cap prog drop fig
program define fig
args indmc pvalu
    use matcheffmaster, clear
    keep if indmc==`indmc'
    forvalue ii=1(1)10{
        qui{
        estim_grid, p(`pvalu') q(`ii') pmax(`pvalu') addlagsth(0) lagsjfr(1) bk(1) eta0(0.3) graph
        }
    }
    graph combine name`pvalu'1 name`pvalu'2 name`pvalu'3 name`pvalu'4 name`pvalu'5 name`pvalu'6 name`pvalu'7 name`pvalu'8 name`pvalu'9 name`pvalu'10
end

******* Manually decide p and q by indmc using the selection protocols provided by Borowczyk-Martins2013 
*** p selection protocol (estim_indmc `indmc') 
estim_indmc 10

*** q selection protocol (fig `indmc' `p')
fig 33 1

*** manual finding for eta
use matcheffmaster, clear
keep if indmc==32
estim_grid, p(1) q(0) pmax(1) addlagsth(0) lagsjfr(1) bk(1) eta0(0.3) graph

*** p, q selection results: "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/pqselectionresult.xlsx"

*** import p, q selection results
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/pqselectionresult.csv", varnames(1) clear 
save pqselectionresult, replace 

use panelf3_temp, clear
merge m:1 indmc using pqselectionresult, nogenerate
sort indmc ym
xtset indmc ym
gen jfr=ln(matched/(uibC/100)/l)
gen theta=ln(v/uibC)
gen jfr_theta_eta=jfr-eta*theta
keep jfr_theta_eta tau* ym indmc eta
keep if 648<=ym&ym<=746
foreach i of numlist 0 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    preserve
        keep if indmc==`i'
        tsset ym
        reg jfr_theta_eta tau2-tau12 // if 648<=ym&ym<=719
        predict a_unbiased, residuals
        replace a_unbiased=a_unbiased+_b[_cons]
        replace a_unbiased=exp(a_unbiased)
        keep indmc ym a_unbiased eta
        rename eta eta_unbiased
        save matcheff`i', replace 
    restore
}

use matcheff0, clear 
foreach i of numlist 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    append using matcheff`i'
}
save matcheff_unbiased_master, replace 

use panelf3_temp4, clear
merge 1:1 indmc ym using matcheff_unbiased_master, nogenerate
save panelf3_temp5, replace 


/*********************************************
Deseasonalize by using seasonal dummy 
*********************************************/
use panelf3_temp5, clear
foreach i of numlist 0 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    preserve
        keep if indmc==`i'
        tsset ym
        reg lambda tau2-tau12 rho1-rho4
        predict lambda_p, residuals
        replace lambda_p=lambda_p+_b[_cons]
        reg wage tau2-tau12
        predict wage_p, residuals
        replace wage_p=wage_p+_b[_cons]
        reg wagefull tau2-tau12
        predict wagefull_p, residuals
        replace wagefull_p=wagefull_p+_b[_cons]
        reg wagepart tau2-tau12
        predict wagepart_p, residuals
        replace wagepart_p=wagepart_p+_b[_cons]
        reg hour tau2-tau12
        predict hour_p, residuals
        replace hour_p=hour_p+_b[_cons]
        reg hourfull tau2-tau12
        predict hourfull_p, residuals
        replace hourfull_p=hourfull_p+_b[_cons]
        reg hourpart tau2-tau12
        predict hourpart_p, residuals
        replace hourpart_p=hourpart_p+_b[_cons]
        drop lambda wage wagefull wagepart hour hourfull hourpart
        rename (lambda_p wage_p wagefull_p wagepart_p hour_p hourfull_p hourpart_p)(lambda wage wagefull wagepart hour hourfull hourpart)
        save panelf3_temp5_seasonal`i', replace 
    restore
}
use panelf3_temp5_seasonal0, clear
foreach i of numlist 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    append using panelf3_temp5_seasonal`i'
}
save panelf3_temp5_seasonal, replace 

use panelf3_temp5, clear  
drop lambda wage wagefull wagepart hour hourfull hourpart
//drop v vfull vpart v_alter theta theta_alter wage wagefull wagepart hour hourfull hourpart
merge 1:1 indmc ym using panelf3_temp5_seasonal, nogenerate
save panelf3, replace 

*********************
//!start
use panelf3, clear
keep if indmc==0
save panelf3_uibfigure, replace 
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/cpi.csv", varnames(1) clear 
save cpi, replace
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/exchangerate.csv", varnames(1) clear 
save exchangerate, replace
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
keep indmc ym uibmoney numd 
collapse (sum) uibmoney, by(ym)
merge 1:1 ym using cpi, nogenerate
merge 1:1 ym using exchangerate, nogenerate
merge 1:1 ym using panelf3_uibfigure
keep if _merge==3
drop _merge
gen uibmoney2=uibmoney/cpi/exchangerate // (1 dollar, 2005 real)
tsset ym 
format ym %tm
tsfilter hp lambda_hp = lambda, trend(smooth_lambda) smooth(3)
tsfilter hp uibmoney2_hp = uibmoney2, trend(smooth_uibmoney2) smooth(1)
tsfilter hp prod_hp = prod, trend(smooth_prod) smooth(1)
label var smooth_prod "Production (Left)"
keep if 648<=ym&ym<=746
twoway (tsline smooth_prod, lcolor(gs0) lwidth(thick) yaxis(1))(tsline smooth_uibmoney2, lwidth(thick) clpattern(dash) yaxis(2)) ///
, xtitle("") ytitle("Termination rate", axis(1)) ytitle("2005 real, $", axis(2)) xline(720) ysize(1) xsize(3) xlabel(648(12)746) scheme(s1mono) /// 
legend(label(1 "Production (Left)") label(2 "Unemployment Insurance Benefit Payment (Right)")) 
graph export uibmoney.eps, replace

/*********************************************
Matching efficiency comparison
*********************************************/
use panelf3, clear
keep if indmc==0
tsset ym 
format ym %tm

tsfilter hp a_unbiased_hp = a_unbiased, trend(smooth_a_unbiased) smooth(1)
tsfilter hp a_biased_hp = a_biased, trend(smooth_a_biased) smooth(1)
tsfilter hp v_hp = v, trend(smooth_v) smooth(1)

twoway (tsline smooth_v, lpattern(solid) lwidth(thick) lcolor(gs0)) ///
(tsline smooth_a_unbiased, yaxis(2) lcolor(gs0)) ///
(tsline smooth_a_biased, yaxis(2) clpattern(shortdash) lcolor(gs0)) ///
, xtitle("") ytitle("")  xline(720) ysize(1) xsize(3) xlabel(648(12)746) scheme(s1mono) /// 
legend(label(1 "Vacancy rate(%)") label(2 "Unbiased matching efficiency") label(3 "Biased matching efficiency"))
graph export matchcomparison.eps, replace

xcorr v smooth_a_unbiased
xcorr v smooth_a_biased

//!start
use panelf3, clear
keep if ym==719
keep ym eta_unbiased eta_biased
drop if eta_biased<0
twoway (scatter eta_unbiased eta_biased)(function y=x) ///
, scheme(s1mono) ytitle("Unbiased eta") xtitle("Biased eta") legend(off)
graph export etacomparison.eps, replace


/*********************************************
Spurious Correlation check
*********************************************/
use panelf3, clear
drop if indmc==0
keep ym indmc v
keep if 715<=ym&ym<=719
collapse (mean) v, by(indmc)
rename v vmean719
save vmean719, replace // vacancy mean before covid

use panelf3, clear
drop if indmc==0
keep ym indmc v
keep if 738<=ym&ym<=743
collapse (mean) v, by(indmc)
rename v vmean743
save vmean743, replace

use panelf3, clear
drop if indmc==0
keep ym indmc prod
keep if 715<=ym&ym<=719
collapse (mean) prod, by(indmc)
rename prod prodmean719
save prodmean719, replace // prod mean before covid

use panelf3, clear
keep if indmc==0
tsset ym 
tsline prod, xline(724)

use panelf3, clear
drop if indmc==0
keep ym indmc prod
keep if ym==724
keep indmc prod
rename prod prodmean724
save prodmean724, replace 

use panelf3, clear
drop if indmc==0
keep ym indmc e9
keep if 715<=ym&ym<=719
collapse (mean) e9, by(indmc)
keep indmc e9
rename e9 e9mean719
save e9mean719, replace // E9 mean before covid

use panelf3, clear
drop if indmc==0
keep ym indmc e9
keep if ym==743
keep indmc e9
rename e9 e9mean743
save e9mean743, replace 

use vmean719, replace 
merge 1:1 indmc using vmean743, nogenerate
merge 1:1 indmc using prodmean719, nogenerate
merge 1:1 indmc using prodmean724, nogenerate
merge 1:1 indmc using e9mean719, nogenerate
merge 1:1 indmc using e9mean743, nogenerate
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations

gen vdif=vmean743-vmean719
gen proddif=prodmean724-prodmean719
gen e9dif=e9mean743-e9mean719

twoway (scatter proddif vdif)
twoway (scatter proddif e9dif)
twoway (scatter e9dif vdif)


/*********************************************
DID Regressions
*********************************************/
*!start
cd "${path}"
use panelf3, clear
xtset indmc ym
drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations
gen d=0 if  684<=ym&ym<=719  // 684<=ym&ym<=719 // inlist(ym,712,713,714,715,716,717,718,719) 
replace d=1 if 739<=ym&ym<=745 // inlist(ym,738,739,740,741,742,743,744)
drop if d==.

gen forperd=forper*d
gen e9shared=e9share*d
gen e9share684d=e9share684*d
gen e9chgd=e9chg*d
label var d "T" 
label var e9shared "E9SHARE $\times$ D" 
label var e9share684d "E9SHARE $\times$ D" 
label var e9chgd "E9CHG $\times$ D" 
label var forperd "TFWSHARE $\times$ D" 
label var a_unbiased "Match Eff" 
label var lambda "Termination" 
label var uibmoney "UIB" 
label var wagefull "Wage(Full)" 
label var hourfull "Hour(Full)" 

******* Reduced form
eststo clear 
eststo: xtreg theta e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg v e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg vfull e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg vpart e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg numDpartproportion e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg wagefull e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg hourfull e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg a_unbiased e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg lambda e9share684d L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)

esttab * using "tableapril1.tex", ///
    title(\label{tableapril1}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	

******* IV
eststo clear 
eststo: xtivreg theta (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg v (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg vfull (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg vpart (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg numDpartproportion (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg wagefull (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg hourfull (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg a_unbiased (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg lambda (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)

esttab * using "tableapril2.tex", ///
    title(\label{tableapril2}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	


// Find First-stage F statistics. Does not work below Stata version 17
ivreghdfe theta (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe v (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe vfull (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe vpart (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe numDpartproportion (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe wagefull (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe hourfull (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first
ivreghdfe a_unbiased (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first
ivreghdfe lambda (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first

******* Graphs
twoway (scatter e9share forper)(lfit e9share forper) ///
        , xtitle("TFW Share (%)") ytitle("E9 Share (%)") legend(off)
graph export TFWe9share.eps, replace

twoway (scatter forper hourfull716)(lfit forper hourfull716), ///
        xtitle("Fulltime Workers' Monthly Work Hours") ytitle("TFW Share (%)") legend(off) ///
        title("Panel (F): Corr between Work hours and TFW share") xline(174)
graph export TFWsharehourfull716.eps, replace


******* IV (Robustness Check)
eststo clear 
eststo: xtivreg theta_alter (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg v_alter (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
esttab * using "tableapril4.tex", ///
    title(\label{tableapril4}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	

// Find First-stage F statistics. Does not work below Stata version 16
ivreghdfe theta_alter (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe v_alter (e9chgd=e9share684d) L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  


/*********************************************
Continuous DID Regressions (monthly)
*********************************************/
*!start
cd "${path}"
use panelf3, clear
drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations
gen Luibmoney=L.uibmoney
label var Luibmoney "UIB" 

keep if 684<=ym&ym<=745
tab ym, gen(dum)

label var theta "Tightness" 

foreach i of numlist 1/62 {
    gen e9share684dum`i'=e9share684*dum`i'
}
* dum61 = 2020m1

foreach var in theta uibC theta_alter v vfull vpart v_alter vfull_alter numDpartproportion hourfull wagefull proddome prodabroad prodoper a_unbiased lambda Luibmoney {
    gen `var'_temp=`var'
    drop `var'
    tsfilter hp `var'_hp2 = `var'_temp, trend(`var') smooth(1)
}

order *, sequential
capture program drop contdidreg
program contdidreg 
args i j
    preserve
            reg `i' e9share684dum1-e9share684dum35 e9share684dum37-e9share684dum62 i.ym i.indmc Luibmoney proddome prodabroad prodoper
            mat b2=e(b)'
            mat b=b2[1..35,1]\0\b2[36..61,1]   
            mat v2=vecdiag(e(V))'
            mat v=v2[1..35,1]\0\v2[36..61,1]
            scalar invttail=invttail(e(df_r),0.025)
            matain b
            matain v
            mata se=sqrt(v)
            clear
            getmata b  
            getmata se
            gen lb=b-invttail*se
            gen ub=b+invttail*se
            gen t=_n
            replace t=t+683
            tsset t, monthly
            format t %tm
    
            gen theta=.
            gen theta_alter=.
            gen v=.
            gen vfull=.
            gen vpart=.
            gen v_alter=.
            gen vfull_alter=.
            gen numDpartproportion=.
            gen hourfull=.
            gen wagefull=.
            gen dw_approx=.
            gen a_unbiased=.
            gen lambda=.

            label var theta "Tightness"
            label var theta_alter "Tightness(alter)" 
            label var v "Vacancy" 
            label var vfull "Vacancy(Full)" 
            label var vpart "Vacancy(Part)" 
            label var v_alter "Vacancy(alter)" 
            label var vfull_alter "Vacancy(Full,alter)" 
            label var numDpartproportion "Ratio Part/Full" 
            label var hourfull "Work Hours(Full)" 
            label var wagefull "Wage(Full)" 
            label var dw_approx "Domestic Workers" 
            label var a_unbiased "Match Efficiency" 
            label var lambda "Termination" 

            twoway (rspike ub lb t, lcolor(gs0))(rcap ub lb t, msize(medsmall) lcolor(gs0))(scatter b t), xline(719) yline(0) xtitle("") ytitle("") /// 
            legend(off) xlabel(684(12)745) ///
            title(Panel(`j'): `: variable label `i'')
            graph export contdid`i'`j'.eps, replace
    restore
end

contdidreg theta A
contdidreg v B
contdidreg vfull C
contdidreg vpart D
contdidreg numDpartproportion E
contdidreg wagefull G
contdidreg hourfull H
contdidreg theta_alter A
contdidreg v_alter B
contdidreg vfull_alter C
contdidreg a_unbiased I
contdidreg lambda J
//contdidreg uibC D


/*********************************************
Continuous DID Regressions (Robustness Check)
*********************************************/
//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/SVARdata.csv", clear 
gen ym=_n+623
keep ym fw dw
save SVARdata_DID, replace 
//!start
cd "${path}"
use panelf3, clear
drop if indmc==0
collapse (sum) e9, by(ym)
rename e9 e9tot
drop if 745<=ym
save e9tot, replace 
//!start
cd "${path}"
use panelf3, clear
merge m:1 ym using SVARdata_DID
drop if _merge==2
drop _merge
merge m:1 ym using e9tot
keep if _merge==3
drop if 744<=ym
preserve  // check if numD==dw+fw (yes)
    keep if indmc==0
    keep ym numD dw fw
    sort ym
    gen numD_compare=dw+fw
    gen check=numD-numD_compare
    keep if check!=0
    di _N
restore 
drop if indmc==0
gen e9weight=e9/e9tot
gen fw_approx=fw*e9weight
gen dw_approx=numD-fw_approx
gen share_approx=fw_approx/(fw_approx+dw_approx)*100
sort indmc ym 
xtset indmc ym 
xtline share_approx, overlay
save numDrobust, replace 

//!start
use numDrobust, clear 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations
xtset indmc ym 
gen La_unbiased=L.a_unbiased 
gen Llambda=L.lambda 
gen Luibmoney=L.uibmoney
label var La_unbiased "Match Eff" 
label var Llambda "Termination" 
label var Luibmoney "UIB" 

keep if 684<=ym&ym<=743
tab ym, gen(dum)

foreach i of numlist 1/60 {
    gen e9share684dum`i'=e9share684*dum`i'
}

foreach var in numD theta_alter v_alter dw_approx proddome prodabroad prodoper Luibmoney {
    gen `var'_temp=`var'
    drop `var'
    tsfilter hp `var'_hp2 = `var'_temp, trend(`var') smooth(1)
}
order *, sequential
capture program drop contdidreg2
program contdidreg2
args i j
    preserve
            reg `i' e9share684dum1-e9share684dum35 e9share684dum37-e9share684dum60 i.ym i.indmc Luibmoney proddome prodabroad prodoper
            mat b2=e(b)'
            mat b=b2[1..35,1]\0\b2[36..59,1]   
            mat v2=vecdiag(e(V))'
            mat v=v2[1..35,1]\0\v2[36..59,1]
            scalar invttail=invttail(e(df_r),0.025)
            matain b
            matain v
            mata se=sqrt(v)
            clear
            getmata b  
            getmata se
            gen lb=b-invttail*se
            gen ub=b+invttail*se
            gen t=_n
            replace t=t+683
            tsset t, monthly
            format t %tm
    
            gen theta=.
            gen v=.
            gen vfull=.
            gen vpart=.
            gen v_alter=.
            gen numDpartproportion=.
            gen hourfull=.
            gen wagefull=.
            gen dw_approx=.

            label var theta "Tightness" 
            label var v "Vacancy" 
            label var vfull "Vacancy(Full)" 
            label var vpart "Vacancy(Part)" 
            label var v_alter "Vacancy(alter)" 
            label var numDpartproportion "Ratio Part/Full" 
            label var hourfull "Work Hours(Full)" 
            label var wagefull "Wage(Full)" 
            label var dw_approx "Domestic Workers" 

            twoway (rspike ub lb t, lcolor(gs0))(rcap ub lb t, msize(medsmall) lcolor(gs0))(scatter b t), xline(719) yline(0) xtitle("") ytitle("") /// 
            legend(off) xlabel(684(12)743) ///
            title(Panel(`j'): `: variable label `i'')
            graph export contdid`i'`j'.eps, replace
    restore
end

contdidreg2 dw_approx D


/*********************************************
Local Projection method
*********************************************/
*!start
cd "${path}"

capture program drop LP
program LP 
    args j depvar
    use panelf3, clear
    xtset indmc ym

    drop if indmc==0    // information for total manufacturing sectors. 
    drop if indmc==32|indmc==16  // too much fluctuations
    drop if indmc==19  // too few observations
    keep if 708<=ym

    label var theta "Tightness" 
    label var a_unbiased "Match Eff" 
    label var lambda "Termination" 
    label var uibmoney "UIB" 
    label var theta "Tightness" 
    label var v "Vacancy" 
    label var vfull "Vacancy(Full)" 
    label var vpart "Vacancy(Part)" 
    label var hourfull "Work Hours(Full)" 
    label var wagefull "Wage(Full)" 
    label var v_alter "Vacancy(Alternative)" 

    gen e9numD=e9/numD*100
    gen LP=.
    gen ub=.
    gen lb=.

    forvalues h=0(1)28 {
        preserve
            gen Fv=F`h'.`depvar'
            keep if 708<=ym&ym<=719
            xtreg Fv e9numD uibmoney proddome prodabroad prodoper, fe vce(cluster indmc)
        restore
        replace LP = _b[e9numD] if _n==`h'+1
        replace ub = _b[e9numD] + 1.645* _se[e9numD] if _n==`h'+1
        replace lb = _b[e9numD] - 1.645* _se[e9numD] if _n==`h'+1
    }

    replace ym=ym+11
    keep if _n<=29
    gen Zero=0
    twoway ///
    (rarea ub lb  ym,  ///
    fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
    (line LP ym, lcolor(blue) ///
    lpattern(solid) lwidth(thick)) ///
    (line Zero ym, lcolor(black)), legend(off) ///
    ytitle("", size(medsmall)) xtitle("", size(medsmall)) ///
    graphregion(color(white)) plotregion(color(white)) xlabel(719(4)747) ///
    title(Panel(`j'): `: variable label `depvar'') ///
    ysize(1) xsize(1.6)
    graph export LP`depvar'.eps, replace
end

LP A theta
LP B v_alter
LP C v
LP D vfull
LP E vpart
LP F hourfull
LP G wagefull
LP G lambda 
LP G a_unbiased


/*********************************************
Local Projection method (DD)
*********************************************/
*!start
cd "${path}"

capture program drop LPDID
program LPDID 
    args j depvar
    use panelf3, clear
    xtset indmc ym

    drop if indmc==0    // information for total manufacturing sectors. 
    drop if indmc==32|indmc==16  // too much fluctuations
    drop if indmc==19  // too few observations
    keep if 708<=ym

    label var theta "Tightness" 
    label var uibmoney "UIB" 
    label var theta "Tightness" 
    label var v "Vacancy" 
    label var vfull "Vacancy(Full)" 
    label var vpart "Vacancy(Part)" 
    label var hourfull "Work Hours(Full)" 
    label var wagefull "Wage(Full)" 
    label var v_alter "Vacancy(Alternative)" 

    gen e9numD=e9/numD*100
    gen LP=.
    gen ub=.
    gen lb=.

    forvalues h=0(1)18 {
        preserve
            gen Fv=F`h'.`depvar'
            gen d=0 if  710<=ym&ym<=719  
            replace d=1 if 720<=ym&ym<=729
            drop if d==.
            gen e9share684d=e9share684*d
            xtreg Fv e9share684d uibmoney proddome prodabroad prodoper, fe vce(cluster indmc)
        restore
        replace LP = _b[e9share684d] if _n==`h'+1
        replace ub = _b[e9share684d] + 1.645* _se[e9share684d] if _n==`h'+1
        replace lb = _b[e9share684d] - 1.645* _se[e9share684d] if _n==`h'+1
    }

    replace ym=ym+19
    keep if _n<=19
    gen Zero=0
    twoway ///
    (rarea ub lb  ym,  ///
    fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
    (line LP ym, lcolor(blue) ///
    lpattern(solid) lwidth(thick)) ///
    (line Zero ym, lcolor(black)), legend(off) ///
    ytitle("", size(medsmall)) xtitle("", size(medsmall)) ///
    graphregion(color(white)) plotregion(color(white)) xlabel(729(4)747) ///
    title(Panel(`j'): `: variable label `depvar'') ///
    ysize(1) xsize(1.6)
    graph export LP`depvar'.eps, replace
end

LPDID A theta
LPDID B v_alter
LPDID C v
LPDID D vfull
LPDID E vpart
LPDID F hourfull
LPDID G wagefull


/*********************************************
Generate figures
*********************************************/

*!start
cd "${path}"
use panelf3, clear

keep if ym>=696
gen e9shareconcur=e9/numD*100
local var="e9shareconcur"
twoway ///
(tsline `var' if indmc==10, lcolor(gs0)) ///
(tsline `var' if indmc==11, lcolor(gs0)) ///
(tsline `var' if indmc==13, lcolor(gs0)) ///
(tsline `var' if indmc==14, lcolor(gs0)) ///
(tsline `var' if indmc==15, lcolor(gs0)) ///
(tsline `var' if indmc==17, lcolor(gs0)) ///
(tsline `var' if indmc==18, lcolor(gs0)) ///
(tsline `var' if indmc==20, lcolor(gs0)) ///
(tsline `var' if indmc==21, lcolor(gs0)) ///
(tsline `var' if indmc==22, lcolor(gs0)) ///
(tsline `var' if indmc==23, lcolor(gs0)) ///
(tsline `var' if indmc==24, lcolor(gs0)) ///
(tsline `var' if indmc==25, lcolor(gs0)) ///
(tsline `var' if indmc==26, lcolor(gs0)) ///
(tsline `var' if indmc==27, lcolor(gs0)) ///
(tsline `var' if indmc==28, lcolor(gs0)) ///
(tsline `var' if indmc==29, lcolor(gs0)) ///
(tsline `var' if indmc==30, lcolor(gs0)) ///
(tsline `var' if indmc==31, lcolor(gs0)) ///
(tsline `var' if indmc==33, lcolor(gs0)) ///
, xline(720) ylabel(0(4)12) ytitle("E9 Share (%)") xtitle("") legend(off)
graph export e9shareconcur2.eps, replace


//!start
cd "${path}"
use panelf3, clear
keep if indmc==0
merge 1:1 ym using ut
keep ym v prod uC
drop if uC==.
tsset ym, monthly
tsfilter hp v_hp = v, trend(smooth_v) smooth(1)
drop v
rename smooth_v v
tsfilter hp uC_hp = uC, trend(smooth_uC) smooth(1)
drop uC
rename smooth_uC uC
tsfilter hp prod_hp = prod, trend(smooth_prod) smooth(1)
drop prod
rename smooth_prod prod
label var uC "Unemployment rate"
label var v "Vacancy rate"
label var prod "Production"
twoway (tsline v, lwidth(thick) lcolor(gs0) yaxis(1)) /// 
    (tsline uC, lcolor(gs0) yaxis(2)) ///
    (tsline prod, lcolor(gs0) clpattern(longdash) yaxis(3)) ///
    , xtitle("") ytitle("") xline(720) xline(724) ysize(1) xsize(3) xlabel(660(12)744)
graph export vup.eps, replace


/*********************************************
VAR with sign restrictions
*********************************************/
//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
keep if indmc==0
keep if 624<=ym&ym<=746 // 2012m1~2022m3
gen v=nume/numd*100
keep ym uib v numd
merge 1:1 ym using ut, nogenerate
drop uC //  will use nonuC(=ut)

drop indmc
gen uibCC=uib/numd*100
keep if 624<=ym&ym<=746 // 2012m1~2022m3
tsset ym

gen Break1=0
replace Break1=1 if ym>=717
gen Break2=0
replace Break2=1 if ym>=718
gen Break3=0
replace Break3=1 if ym>=719
gen Break4=0
replace Break4=1 if ym>=720
gen Break5=0
replace Break5=1 if ym>=721
gen recession1=0
replace recession1=1 if 668<=ym
gen recession2=0
replace recession2=1 if ym<=672
gen recession3=0
replace recession3=1 if ym<=677
gen recession4=0
replace recession4=1 if 699<=ym
gen recession5=0
replace recession5=1 if ym<=710

gen months=month(dofm(ym))
tabulate months, generate(tau)
gen quarters=quarter(dofm(ym))
tabulate quarters, generate(rho)
reg ut uibCC recession1-recession5 rho1-rho4 tau2-tau12
predict uibC
twoway (tsline uibC)(tsline ut, lwidth(thick)) ///
, ysize(3.5) xsize(8) xline(720) xline(664)

replace uibC=ut if ym>=664
twoway (tsline uibC)(tsline ut, lwidth(thick)) ///
, ysize(3.5) xsize(8) xline(720) xline(664)

rename uibC u

keep ym u v
save SVARuv, replace 

//!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/SVARdataset.csv", varnames(1) clear 
save SVARdataset, replace 

use SVARuv, clear
merge 1:1 ym using SVARdataset, nogenerate
tsset ym, monthly 
format ym %tmdd/NN/CCYY

gen tw=fw+dw

foreach var of varlist tw fw dw u v {
    gen ln`var'=ln(`var')
    drop `var'
    rename ln`var' `var'
}

preserve 
keep dw fw u v
order dw fw u v
export delimited using "${path}\SVARdata_seasondummyadj.csv", replace
*manually saved it to ".../Rubio_Ramirez_Replication/data/SVARdata_seasondummyadj.csv"
restore 

preserve 
keep ym 
order ym
export delimited using "${path}\SVARdata_seasondummyadj_dates.csv", replace
*manually saved it to ".../Rubio_Ramirez_Replication/data/SVARdata_seasondummyadj_dates.csv"
restore 

/*************** Executable using Matlab code by Antolín-Díaz and Rubio-Ramírez 2018
1) Download Replication data: Narrative Sign Restrictions for SVARs from https://www.openicpsr.org/openicpsr/project/113168/version/V1/view
2) Download entire files from https://github.com/jayjeo/public/tree/main/LaborShortage/Rubio_Ramirez_Replication, and merge it to the previous one.
3) Run Application_3_LS.m
********************/


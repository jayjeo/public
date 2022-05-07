

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

** LScode ver6.3.do
cls
clear all
set scheme s1color, perm 

/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\Github move\Latex\Dissertation Draft ver6.0"   
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

tsfilter hp e9inflow_hp = e9inflow, trend(smooth_e9inflow) smooth(1)
sax12 smooth_e9inflow, satype(single) inpref(e9inflow.spc) outpref(e9inflow) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12im "e9inflow.out", ext(d11)
keep if date>=648

twoway (tsline e9inflow_d11, lcolor(gs0))(tsline e9stock, lwidth(thick) lcolor(gs0) yaxis(2)) ///
, xlabel(648(6)744) xlabel(, grid angle(270)) xline(720) ytitle("person", axis(1)) ytitle("person", axis(2)) scheme(s1mono) ///
ysize(3.5) xsize(8) ///
legend(label(1 "E9 inflow") label(2 "E9 stock")) ///
caption("Source: Employment Permit System (EPS)")
graph export monthlye9.eps, replace


*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/uib.csv", varnames(1) clear 
replace t=t+592
format t %tm
tsset t 
gen uib_adj=uib
gen tt=t
replace uib_adj=uib*0.7 if t>=720  
*0.674947869
twoway (tsline ut, lcolor(gs0))(tsline uib_adj, lcolor(red))(tsline uib, lcolor(blue) clpattern(longdash)) ///
    , xtitle("") ytitle("%") xline(720) /// 
    ysize(3.5) xsize(8) ///
    legend(label(1 "Unemployment rate") label(2 "Unemployment Insurance Benefit (adjusted)") label(3 "Unemployment Insurance Benefit") order(1 2 3))
graph export uib.eps, replace


*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/participationandprod.csv", varnames(1) clear 
tsset ym 
format ym %tm
drop if ym>740
label var prod "Production (Left)"
label var activeall_d11 "Labor Participation Rate (Right)"
twoway (tsline prod, lcolor(gs0) lwidth(thick) yaxis(1))(tsline activeall_d11, lcolor(gs0) yaxis(2)) /// 
, xtitle("") xline(720) ysize(3.5) xsize(8) xlabel(660(12)730)
graph export participationandprod.eps, replace

		
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
tsset month 
format month %tm

gen forpercent=fw/(fw+dw)*100
keep if month >= 648 

twoway (tsline forpercent, lcolor(gs0)) ///
, xlabel(648(6)743) xlabel(, grid angle(270)) xline(720) xtitle("") ytitle("%") scheme(s1mono) ///
ysize(3) xsize(8) legend(off) ///
caption("Source: Korea Immigration Service Monthly Statistics & Survey on Immigrant's Living Conditions and Labour Force")
graph export forpercent.eps, replace


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
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/cpi.csv", varnames(1) clear 
save cpi, replace
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/exchangerate.csv", varnames(1) clear 
save exchangerate, replace
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
keep if 648<=ym&ym<=746
keep indmc ym uibmoney numd 

preserve
    keep if ym==648
    rename numd numd648
    keep indmc ym numd648
    save numd648, replace 
restore
merge m:1 indmc using numd648, nogenerate
merge m:1 ym using cpi, nogenerate
merge m:1 ym using exchangerate, nogenerate
keep if 648<=ym&ym<=746

gen uibmoney2=uibmoney/numd648/cpi/exchangerate // (1 dollar, 2005 real)
collapse (sum) uibmoney2, by(ym)
tsset ym 
format ym %tm

tsline uibmoney2 ///
, xtitle("") ytitle("")  xline(720) ysize(1) xsize(3) xlabel(648(12)746) scheme(s1mono) /// 
legend(label(1 "Unemployment Insurance Benefit Payment ($, 2005 real)"))
graph export uibmoney.eps, replace


*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/cpi.csv", varnames(1) clear 
save cpi, replace
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/exchangerate.csv", varnames(1) clear 
save exchangerate, replace
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
keep indmc ym uibmoney numd 
collapse (sum) uibmoney, by(ym)
merge 1:1 ym using cpi, nogenerate
merge 1:1 ym using exchangerate, nogenerate
gen uibmoney2=uibmoney/cpi/exchangerate // (1 dollar, 2005 real)
tsset ym 
format ym %tm
keep if 648<=ym&ym<=746
tsline uibmoney2 ///
, xtitle("") ytitle("$, 2005 real") xline(720) ysize(1) xsize(3) xlabel(648(12)746) scheme(s1mono) /// 
legend(label(1 "Unemployment Insurance Benefit Payment"))
graph export uibmoney.eps, replace


*********************
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/unauthorizedshare.csv", varnames(1) clear 
twoway (connected share time, lcolor(gs0) lwidth(med) mcolor(gs0)) ///
, xlabel(1"y99" 2"y00" 3"y01" 4"y02" 5"y03" 6"y04" 7"y05" 8"y06" 9"y07" 10"y08" 11"y09" 12"y10" 13"y11" 14"y12" 15"y13" 16"y14" 17"y15" 18"y16" 19"y17" 20"y18" 21"y19" 22"y20" 23"y21" 24"y22m3") ///
xtitle("") ytitle("%") ysize(1) xsize(3) ymtick(#20, grid tstyle(none))
graph export unauthorizedshare.eps, replace


/*********************************************
Regression Data Generation
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
rename uc uC
save ut, replace 

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
merge m:1 ym using ut, nogenerate
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

gen uibC=uib/numD*100*0.896503381 if ym<720
replace uibC=uib/numD*100*0.63 if ym>=720

gen wage=wage_tot*100/cpi/hour/exchangerate  // cpi adjusted hourly wage (unit=USD)
gen wagefull=wage_totfull*100/cpi/hourfull/exchangerate  // cpi adjusted hourly wage (unit=USD)
gen wagepart=wage_totpart*100/cpi/hourpart/exchangerate  // cpi adjusted hourly wage (unit=USD)

gen uibmoney2=uibmoney/numd648/cpi/exchangerate
drop uibmoney
rename uibmoney2 uibmoney

drop if inlist(indmc,12)  // tobacco industry. Extremely few workers, and production data is not available.
sort indmc ym
keep if 648<=ym&ym<=747   // largest available data span.
save panelm, replace 

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

preserve
    keep if indmc==0 
    tsset ym, monthly
    
    gen theta=v/uibC
    gen l=numD/(1-uibC/100)
    gen lnF=ln(F1.matched/(uibC/100)/l)
    gen lntheta=ln(theta)
    reg lnF lntheta if 684<=ym
    scalar k2=_b[lntheta]
    di k2    // .3146704
    twoway (scatter lnF lntheta if 684<=ym ) (lfit lnF lntheta if 684<=ym) (scatter lnF lntheta if 684>ym ) (lfit lnF lntheta if 684>ym)
    twoway (tsline F1.matched) (tsline uibC, yaxis(2))
    tsline lnF lntheta
restore

scalar k2=.3146704
gen l=numD/(1-uibC/100)
gen a_alter=F1.matched/(uibC/100*l*(v/uibC)^k2)     // alternative calibration result for matching efficiency 
gen lambda_alter=F1.EXIT/l        // calibration result for termination rate  

label var a_alter "Match Eff" 
label var lambda_alter "Termination" 

keep if 648<=ym&ym<=747   // largest available data span.

save panelf3_temp, replace



/*********************************************
Estimate Match efficiency by state (Borowczyk-Martins2013)
*********************************************/
//!start
cd "${path}"
use panelf3_temp, clear
keep if 648<=ym&ym<=719   

sort indmc ym
xtset indmc ym
gen theta=ln(v/uibC)
gen jfr=ln(F1.matched/(uibC/100)/l)
drop if jfr==.
gen year=year(dofm(ym))
gen month=month(dofm(ym))
gen t=ym-647
rename uibC u
keep year month ym t jfr theta u indmc
tab month, gen(m_)
drop m_1
save matcheffmaster, replace 

cap program drop estim_grid
program define estim_grid
syntax [, P(real 1) Q(real 1) ADDLAGSTH(integer 1) LAGSJFR(integer 1) PMAX(integer 1) SELECT(string) ETA0(real 1) GRAPH] 
	
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
        local pmax = 5

        matrix results = J(5 + 2*(`pmax'+2),1,.)
        local rnames "p q sd(mu) mu sd(eta) eta"
        noi di "--------------------------------------------------"
        forv p = 1/`pmax'	{
            local rnames "`rnames' sd(rho`p') rho`p'"
            
            if `p'>=`pmin'	{
                forv q = 0/6	{
                    noi di _con "(`p' , `q') -- "
                    estim_grid, p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) eta0(0.7)
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
        // p-value for rho5
        mata z=abs(results[.,16]:/results[.,15])
        mata rest7=2*normal(-abs(z))

        mata rest=rest,rest1,eta,rest2,rest3,rest4,rest5,rest6,rest7
        mata rest 
end

*** q selection protocol
cap prog drop fig
program define fig
args indmc pvalu
    use matcheffmaster, clear
    keep if indmc==`indmc'
    forvalue ii=1(1)6{
        qui{
        estim_grid, p(`pvalu') q(`ii') pmax(`pvalu') addlagsth(0) lagsjfr(1) eta0(0.7) graph
        }
    }
    graph combine name`pvalu'1 name`pvalu'2 name`pvalu'3 name`pvalu'4 name`pvalu'5 name`pvalu'6 
end

******* Manually decide p and q by indmc using the selection protocols provided by Borowczyk-Martins2013 
*** p selection protocol (estim_indmc `indmc') 
estim_indmc 0

*** q selection protocol (fig `indmc' `p')
fig 25 1

*** p, q selection results: "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/pq selection result.xlsx"

*** import p, q selection results
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/pqselectionresult.csv", varnames(1) clear 
save pqselectionresult, replace 

use panelf3_temp, clear 
merge m:1 indmc using pqselectionresult, nogenerate
sort indmc ym
xtset indmc ym
gen a_unbiased=F1.matched/(uibC/100*l*(v/uibC)^eta) 
keep if 648<=ym&ym<=747 // maximum possible time span. 2014m1~2022m2
save panelf3_temp2, replace  


/*********************************************
Deseasonalize by using seasonal dummy 
*********************************************/
use panelf3_temp2, clear
gen quarter=quarter(dofm(ym))
tabulate quarter, generate(quarterd)
foreach i of numlist 0 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    preserve
        keep if indmc==`i'
        tsset ym
        reg uibC quarterd2 quarterd3 quarterd4
        predict uibCs, residuals
        replace uibCs=uibCs+_b[_cons]
        drop uibC
        rename uibCs uibC
        reg wage quarterd2 quarterd3 quarterd4
        predict wages, residuals
        replace wages=wages+_b[_cons]
        drop wage
        rename wages wage
        reg wagefull quarterd2 quarterd3 quarterd4
        predict wagefulls, residuals
        replace wagefulls=wagefulls+_b[_cons]
        drop wagefull
        rename wagefulls wagefull
        reg wagepart quarterd2 quarterd3 quarterd4
        predict wageparts, residuals
        replace wageparts=wageparts+_b[_cons]
        drop wagepart
        rename wageparts wagepart
        reg hour quarterd2 quarterd3 quarterd4
        predict hours, residuals
        replace hours=hours+_b[_cons]
        drop hour
        rename hours hour
        reg hourfull quarterd2 quarterd3 quarterd4
        predict hourfulls, residuals
        replace hourfulls=hourfulls+_b[_cons]
        drop hourfull
        rename hourfulls hourfull
        reg hourpart quarterd2 quarterd3 quarterd4
        predict hourparts, residuals
        replace hourparts=hourparts+_b[_cons]
        drop hourpart
        rename hourparts hourpart
        keep indmc ym uibC wage wagefull wagepart hour hourfull hourpart
        save panelf3_temp2_seasonal`i', replace 
    restore
}
use panelf3_temp2_seasonal0, clear
foreach i of numlist 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 {
    append using panelf3_temp2_seasonal`i'
}
save panelf3_temp2_seasonal, replace 

use panelf3_temp2, clear  
drop uibC wage wagefull wagepart hour hourfull hourpart
merge 1:1 indmc ym using panelf3_temp2_seasonal, nogenerate
save panelf3, replace 


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
gen La_unbiased=L.a_unbiased
gen Luibmoney=L.uibmoney
gen d=0 if  684<=ym&ym<=719  // 684<=ym&ym<=719 // inlist(ym,712,713,714,715,716,717,718,719) 
replace d=1 if 739<=ym&ym<=745 // inlist(ym,738,739,740,741,742,743,744)
drop if d==.

gen forperd=forper*d
gen e9shared=e9share*d
gen e9share684d=e9share684*d
gen e9chgd=e9chg*d
gen theta=v/uibC
label var d "T" 
label var theta "Tightness" 
label var e9shared "E9SHARE $\times$ D" 
label var e9share684d "E9SHARE $\times$ D" 
label var e9chgd "E9CHG $\times$ D" 
label var forperd "TFWSHARE $\times$ D" 
label var a_alter "Match Eff" 
label var a_unbiased "Match Eff" 
label var uibmoney "UIB" 
label var wagefull "Wage(Full)" 
label var hourfull "Hour(Full)" 

******* Reduced form
eststo clear 
eststo: xtreg theta e9share684d L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg v e9share684d L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg vfull e9share684d L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg vpart e9share684d L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg numDpartproportion e9share684d L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg wagefull e9share684d L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtreg hourfull e9share684d L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)

esttab * using "tableapril1.tex", ///
    title(\label{tableapril1}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	

******* IV
eststo clear 
eststo: xtivreg theta (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg v (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg vfull (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg vpart (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg numDpartproportion (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg wagefull (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
eststo: xtivreg hourfull (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, fe vce(cluster indmc)

esttab * using "tableapril2.tex", ///
    title(\label{tableapril2}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	


// Find First-stage F statistics. Does not work in Stata version 16
ivreghdfe theta (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe v (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe vfull (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe vpart (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe numDpartproportion (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe wagefull (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first  
ivreghdfe hourfull (e9chgd=e9share684d) L.a_unbiased  L.uibmoney proddome prodabroad prodoper i.ym, absorb(indmc) cluster(indmc) first


******* Graphs
twoway (scatter e9share forper)(lfit e9share forper) ///
        , xtitle("TFW Share (%)") ytitle("E9 Share (%)") legend(off)
graph export TFWe9share.eps, replace

twoway (scatter forper hourfull716)(lfit forper hourfull716), ///
        xtitle("Fulltime Workers' Monthly Work Hours") ytitle("TFW Share (%)") legend(off) ///
        title("Panel (H): Corr between Work hours and TFW share") xline(174)
graph export TFWsharehourfull716.eps, replace



/*********************************************
Continuous DID Regressions (monthly)
*********************************************/
*!start
cd "${path}"
use panelf3, clear
drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations
gen La_unbiased=L.a_unbiased 
gen Luibmoney=L.uibmoney

keep if 684<=ym
tab ym, gen(dum)

gen theta=v/uibC
label var theta "Tightness" 

foreach i of numlist 1/62 {
    gen e9share684dum`i'=e9share684*dum`i'
}
* dum61 = 2020m1

foreach var in theta v vfull vpart numDpartproportion hourfull wagefull proddome prodabroad prodoper La_unbiased  Luibmoney {
    gen `var'_temp=`var'
    drop `var'
    tsfilter hp `var'_hp2 = `var'_temp, trend(`var') smooth(1)
}

foreach j in A B C D E F G { 
order *, sequential
foreach i of varlist theta v vfull vpart numDpartproportion hourfull wagefull {  
preserve
        reg `i' e9share684dum1-e9share684dum35 e9share684dum37-e9share684dum62 i.ym i.indmc proddome prodabroad prodoper La_unbiased  Luibmoney
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
        gen v=.
        gen vfull=.
        gen vpart=.
        gen numDpartproportion=.
        gen hourfull=.
        gen wagefull=.

        label var theta "Tightness" 
        label var v "Vacancy" 
        label var vfull "Vacancy(Full)" 
        label var vpart "Vacancy(Part)" 
        label var numDpartproportion "Ratio Part/Full" 
        label var hourfull "Work Hours(Full)" 
        label var wagefull "Wage(Full)" 

        twoway (rspike ub lb t, lcolor(gs0))(rcap ub lb t, msize(medsmall) lcolor(gs0))(scatter b t), xline(719) yline(0) xtitle("") ytitle("") /// 
        legend(off) xlabel(684(12)745) ///
        title(Panel(`j'): `: variable label `i'')
        graph export contdid`i'`j'.eps, replace
restore
}
}

/*********************************************
Local Projection method1
*********************************************/

*!start
cd "${path}"
use panelf3, clear
xtset indmc ym

drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations
keep if 712<=ym

gen theta=v/uibC
label var theta "Tightness" 
label var a_alter "Match Eff" 
label var uib "UIB" 

preserve
    keep ym indmc numE numD  
    keep if ym==720
    rename (numE numD)(numE720 numD720)
    save ym720, replace 
restore

gen e9numD=e9/numD*100
gen LP=.
gen ub=.
gen lb=.
forvalues h=0(1)18 {
    preserve
        gen Fv=F`h'.v
        keep if 712<=ym&ym<=729
        xtreg Fv e9numD a_alter uib proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
    restore
    replace LP=_b[e9numD] if _n==`h'+1
    replace ub = _b[e9numD] + 1.645* _se[e9numD] if _n==`h'+1
    replace lb = _b[e9numD] - 1.645* _se[e9numD] if _n==`h'+1
}

replace ym=ym+17
keep if _n<=19
gen Zero=0
twoway ///
(rarea ub lb  ym,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line LP ym, lcolor(blue) ///
lpattern(solid) lwidth(thick)) ///
(line Zero ym, lcolor(black)), legend(off) ///
title("Impulse response of Local Projection for 19 months since 2020m10", color(black) size(medsmall)) ///
ytitle("Percent", size(medsmall)) xtitle("", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))


/*********************************************
Local Projection method2
*********************************************/

*!start
cd "${path}"
use panelf3, clear
xtset indmc ym

drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations
keep if 712<=ym

gen theta=v/uibC
label var theta "Tightness" 
label var a_alter "Match Eff" 
label var uib "UIB" 

preserve
    keep ym indmc numE numD  
    keep if ym==720
    rename (numE numD)(numE720 numD720)
    save ym720, replace 
restore

gen e9numD=e9/numD*100
gen LP=.
gen ub=.
gen lb=.
forvalues h=0(1)16 {
    preserve
        gen Fv=F`h'.vfull
        keep if 712<=ym&ym<=731
        xtreg Fv e9numD a_alter uib proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
    restore
    replace LP=_b[e9numD] if _n==`h'+1
    replace ub = _b[e9numD] + 1.645* _se[e9numD] if _n==`h'+1
    replace lb = _b[e9numD] - 1.645* _se[e9numD] if _n==`h'+1
}

replace ym=ym+20
keep if _n<=16
gen Zero=0
twoway ///
(rarea ub lb  ym,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line LP ym, lcolor(blue) ///
lpattern(solid) lwidth(thick)) ///
(line Zero ym, lcolor(black)), legend(off) ///
title("Impulse response of Local Projection for 16 months since 2020m1", color(black) size(medsmall)) ///
ytitle("Percent", size(medsmall)) xtitle("", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))




/*********************************************
Local Projection method3
*********************************************/

*!start
cd "${path}"
use panelf3, clear
xtset indmc ym

drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations
keep if 712<=ym

gen theta=v/uibC
label var theta "Tightness" 
label var a_alter "Match Eff" 
label var uib "UIB" 

xtset indmc ym 

gen e9numD=e9/numD*100
gen LP=.
gen ub=.
gen lb=.
forvalues h=0(1)6 {
    preserve
        gen Fv=F`h'.v
        xtreg Fv e9numD a_alter uib proddome prodabroad prodoper i.ym, fe vce(cluster indmc)
    restore
    replace LP=_b[e9numD] if _n==`h'+1
    replace ub = _b[e9numD] + 1.645* _se[e9numD] if _n==`h'+1
    replace lb = _b[e9numD] - 1.645* _se[e9numD] if _n==`h'+1
}

replace ym=ym+64
keep if _n<=6
gen Zero=0
twoway ///
(rarea ub lb  ym,  ///
fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line LP ym, lcolor(blue) ///
lpattern(solid) lwidth(thick)) ///
(line Zero ym, lcolor(black)), legend(off) ///
title("Impulse response of Local Projection for 2 years", color(black) size(medsmall)) ///
ytitle("Percent", size(medsmall)) xtitle("Months", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))



/*********************************************
Arellano-Bond regressions
*********************************************/
*!start
cd "${path}"
use panelf3, clear
xtset indmc ym
gen Luibmoney=L5.uibmoney
keep if  719<=ym

drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations

preserve
    keep if ym==719
    keep numD indmc
    rename numD numD719
    save numD719, replace 
restore
merge m:1 indmc using numD719, nogenerate 
sort indmc ym 
xtset indmc ym 
gen lnv=ln(v)
gen lna=ln(a_unbiased)
gen lnuib=ln(Luibmoney/numD719)
gen lne9=ln(e9/numD719*100)
gen lnproddome=ln(L.proddome)
gen lnprodabroad=ln(L.prodabroad)
gen lnprodoper=ln(L.prodoper)
label var lnv "Vacancy" 
label var lna "Match Eff" 
label var lnuib "UIB" 
label var lne9 "E9 Workers" 

eststo clear 
eststo: xi: xtabond lnv lna lnuib lne9, lags(2) pre(lnproddome) pre(lnprodabroad) pre(lnprodoper) // maxldep(12) maxlags(12) // included in the paper
eststo: xi: xtabond lnv lna lnuib lne9, lags(3) pre(lnproddome) pre(lnprodabroad) pre(lnprodoper) // maxldep(12) maxlags(12) // included in the paper
eststo: xi: xtabond lnv lna lnuib lne9, lags(4) pre(lnproddome) pre(lnprodabroad) pre(lnprodoper) // maxldep(12) maxlags(12) // included in the paper
esttab * using "tableapril3.tex", ///
    title(\label{tableapril3}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace


/*********************************************
Continuous DID Regressions (KLIPS OLS)
*********************************************/
cd "${path}"
foreach var in 12 13 14 15 16 17 18 19 20 21 22 23 {
use "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/klips`var'p.dta", clear
save klips`var'p, replace 
keep pid    
save klips`var'pid, replace 
}

use klips12pid, clear   
append using klips13pid
append using klips14pid
append using klips15pid
append using klips16pid
append using klips17pid
append using klips18pid
append using klips19pid
append using klips20pid
append using klips21pid
append using klips22pid
append using klips23pid

sort pid
quietly by pid: gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup
foreach var in 12 13 14 15 16 17 18 19 20 21 22 23 {
    merge 1:1 pid using klips`var'p, nogenerate
}
foreach i in 12 13 14 15 16 17 18 19 20 21 22 23 {
    gen p`i'0342mid=99 if 1<=p`i'0342&p`i'0342<100 // else
    replace p`i'0342mid=10 if 100<=p`i'0342&p`i'0342<110 // Food Products
    replace p`i'0342mid=11 if 110<=p`i'0342&p`i'0342<120 // Beverages
    replace p`i'0342mid=12 if 120<=p`i'0342&p`i'0342<130 // Tobacco products
    replace p`i'0342mid=13 if 130<=p`i'0342&p`i'0342<140 // Textiles, Except Apparel
    replace p`i'0342mid=14 if 140<=p`i'0342&p`i'0342<150 // Wearing apparel, Clothing Accessories and Fur Articles
    replace p`i'0342mid=15 if 150<=p`i'0342&p`i'0342<160 // Tanning and Dressing of Leather, Luggage and Footwear
    replace p`i'0342mid=16 if 160<=p`i'0342&p`i'0342<170 // Wood Products of Wood and Cork; Except Furniture
    replace p`i'0342mid=17 if 170<=p`i'0342&p`i'0342<180 // Pulp, Paper and Paper Products
    replace p`i'0342mid=18 if 180<=p`i'0342&p`i'0342<190 // Printing and Reproduction of Recorded Media
    replace p`i'0342mid=19 if 190<=p`i'0342&p`i'0342<200 // Coke, hard-coal and lignite fuel briquettes and Refined Petroleum Products
    replace p`i'0342mid=20 if 200<=p`i'0342&p`i'0342<210 // Chemicals and chemical products except pharmaceuticals, medicinal chemicals
    replace p`i'0342mid=21 if 210<=p`i'0342&p`i'0342<220 // Pharmaceuticals, Medicinal Chemicals and Botanical Products
    replace p`i'0342mid=22 if 220<=p`i'0342&p`i'0342<230 // Rubber and Plastic Products
    replace p`i'0342mid=23 if 230<=p`i'0342&p`i'0342<240 // Other Non-metallic Mineral Products
    replace p`i'0342mid=24 if 240<=p`i'0342&p`i'0342<250 // Basic Metal Products
    replace p`i'0342mid=25 if 250<=p`i'0342&p`i'0342<260 // Fabricated Metal Products, Except Machinery and Furniture
    replace p`i'0342mid=26 if 260<=p`i'0342&p`i'0342<270 // Electronic Components, Computer, Radio, Television and Communication Equipment and Apparatuses
    replace p`i'0342mid=27 if 270<=p`i'0342&p`i'0342<280 // Medical, Precision and Optical Instruments, Watches and Clocks
    replace p`i'0342mid=28 if 280<=p`i'0342&p`i'0342<290 // Electrical equipment
    replace p`i'0342mid=29 if 290<=p`i'0342&p`i'0342<300 // Other Machinery and Equipment
    replace p`i'0342mid=30 if 300<=p`i'0342&p`i'0342<310 // Motor Vehicles, Trailers and Semitrailers
    replace p`i'0342mid=31 if 310<=p`i'0342&p`i'0342<320 // Other Transport Equipment
    replace p`i'0342mid=32 if 320<=p`i'0342&p`i'0342<330 // Furniture
    replace p`i'0342mid=33 if 330<=p`i'0342&p`i'0342<340 // Other Manufacturing
    replace p`i'0342mid=99 if 340<=p`i'0342&p`i'0342<1000  // else
}
save klips_master, replace 

********************
use klips_master, clear
foreach i in 12 13 14 15 16 17 18 19 20 21 22 {
local j=`i'+1
gen sel`j'=1 if p`i'0201==1 & p`j'0201==1 & p`i'0342mid==p`j'0342mid  // 같은 산업에 잔류
replace sel`j'=1 if p`i'0201==1 & p`j'0201==1 & p`i'0342mid!=p`j'0342mid  // 다른 산업으로 취직
replace sel`j'=1 if p`i'0201==1 & p`j'0201==2 & p`i'0342mid!=. & p`j'2801==1  // 실업자로 이동
replace sel`j'=0 if p`i'0201==1 & p`j'0201==2 & p`i'0342mid!=. & p`j'2801==2  // 비경활로 이동
replace sel`j'=2 if p`i'0201==1 & p`j'0201==1 & p`i'0342mid!=p`j'0342mid  // 다른 산업에서 취직
*replace sel`j'=0 if p`i'0201==2 & p`j'0201==1 & p`j'0342mid!=. & p`i'2801==1  // 실업자에서 취직
replace sel`j'=3 if p`i'0201==2 & p`j'0201==1 & p`j'0342mid!=. & p`i'2801==2  // 비경활에서 취직

}
drop if sel13==.&sel14==.&sel15==.&sel16==.&sel17==.&sel18==.&sel19==.&sel20==.&sel21==.&sel22==.&sel23==.
keep pid sel* p**0342mid p**0107 p**0110 p**0101
save klips_master_temp1, replace

use klips_master_temp1, clear
foreach i in 12 13 14 15 16 17 18 19 20 21 22 {
local j=`i'+1
preserve
    keep p`i'0342mid p`j'0342mid sel`j' p`j'0107 p`j'0110 p`j'0101
    replace p`i'0342mid=p`j'0342mid if sel`j'==2
    replace sel`j'=1 if sel`j'==2
    replace p`i'0342mid=p`j'0342mid if sel`j'==3
    replace sel`j'=1 if sel`j'==3
    gen yr=`j'+1997
    rename (p`i'0342mid sel`j' p`j'0107 p`j'0110 p`j'0101)(indmc sel age edu sex)
    keep if edu <=6 // 전문대졸 미만
    keep if 20<=age&age<=64
    save sel`j', replace 
restore 
}

use sel13, clear
append using sel14
append using sel15
append using sel16
append using sel17
append using sel18
append using sel19
append using sel20
append using sel21
append using sel22
append using sel23
drop if indmc==99|indmc==.
drop if sel==.
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==11|indmc==19  // too few observations
drop if indmc==12
keep if 20<=age&age<=64
keep if yr>=2015
rename yr year
keep if inlist(indmc,10,11,	12,	13,	14,	15,	16,	17,	18,	19,	20,	21,	22,	23,	24,	25,	26,	27,	28,	29,	30,	31,	32,	33)
save klipsresult_logit, replace 

cd "${path}"
use panelf3, clear
drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==11|indmc==19  // too few observations
drop if indmc==12
gen year = yofd(dofm(ym))
format year %ty
collapse (mean) e9share684 a_alter uib proddome prodabroad prodoper, by(year indmc)
merge 1:m year indmc using klipsresult_logit
keep if _merge==3
drop _merge

tab year, gen(dum)

foreach i of numlist 1/6 {
    gen e9share684dum`i'=e9share684*dum`i'
}

ereturn list
order *, sequential
xi: reg sel e9share684dum1-e9share684dum4 e9share684dum6 i.year i.indmc age i.sex i.edu, robust
        mat borig=e(b)'
        mat vorig=vecdiag(e(V))'
        clear
        
        mat b1=borig[1..4,1]\0\borig[5,1]   
        mat v1=vorig[1..4,1]\0\vorig[5,1]
        matain b1
        matain v1
        mata se1=sqrt(v1)
        
        getmata b1  
        getmata se1
        gen lb1=b1-se1*1.96
        gen ub1=b1+se1*1.96
        
        gen t=_n
        replace t=t+2014
        tsset t, yearly
        format t %ty
        twoway (rspike ub1 lb1 t, lcolor(gs0))(rcap ub1 lb1 t, msize(medsmall) lcolor(gs0))(scatter b1 t), xline(2019) yline(0) xtitle("") ytitle("") /// 
        legend(off) xlabel(2015(1)2020) 
        graph export ols.eps, replace




********************
use klips_master, clear
foreach i in 12 13 14 15 16 17 18 19 20 21 22 {
local j=`i'+1
gen sel`j'=1 if p`i'0201==1 & p`j'0201==2 & p`i'0342mid!=. & p`j'2801==1  // 실업자로 이동
replace sel`j'=0 if p`i'0201==1 & p`j'0201==2 & p`i'0342mid!=. & p`j'2801==2  // 비경활로 이동
replace sel`j'=3 if p`i'0201==2 & p`j'0201==1 & p`j'0342mid!=. & p`i'2801==2  // 비경활에서 취직

}
drop if sel13==.&sel14==.&sel15==.&sel16==.&sel17==.&sel18==.&sel19==.&sel20==.&sel21==.&sel22==.&sel23==.
keep pid sel* p**0342mid p**0107 p**0110 p**0101
save klips_master_temp1, replace

use klips_master_temp1, clear
foreach i in 12 13 14 15 16 17 18 19 20 21 22 {
local j=`i'+1
preserve
    keep p`i'0342mid p`j'0342mid sel`j' p`j'0107 p`j'0110 p`j'0101
    replace p`i'0342mid=p`j'0342mid if sel`j'==3
    replace sel`j'=1 if sel`j'==3
    gen yr=`j'+1997
    rename (p`i'0342mid sel`j' p`j'0107 p`j'0110 p`j'0101)(indmc sel age edu sex)
    keep if edu <=6 // 전문대졸 미만
    keep if 20<=age&age<=64
    save sel`j', replace 
restore 
}

use sel13, clear
append using sel14
append using sel15
append using sel16
append using sel17
append using sel18
append using sel19
append using sel20
append using sel21
append using sel22
append using sel23
drop if indmc==99|indmc==.
drop if sel==.
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==11|indmc==19  // too few observations
drop if indmc==12
keep if 20<=age&age<=64
keep if yr>=2015
rename yr year
keep if inlist(indmc,10,11,	12,	13,	14,	15,	16,	17,	18,	19,	20,	21,	22,	23,	24,	25,	26,	27,	28,	29,	30,	31,	32,	33)
save klipsresult_logit, replace 

cd "${path}"
use panelf3, clear
drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==11|indmc==19  // too few observations
drop if indmc==12
gen year = yofd(dofm(ym))
format year %ty
collapse (mean) e9share684 a_alter uib proddome prodabroad prodoper, by(year indmc)
merge 1:m year indmc using klipsresult_logit
keep if _merge==3
drop _merge

tab year, gen(dum)

foreach i of numlist 1/6 {
    gen e9share684dum`i'=e9share684*dum`i'
}

ereturn list
order *, sequential
xi: reg sel e9share684dum1-e9share684dum4 e9share684dum6 i.year i.indmc age i.sex i.edu, robust
        mat borig=e(b)'
        mat vorig=vecdiag(e(V))'
        clear
        
        mat b1=borig[1..4,1]\0\borig[5,1]   
        mat v1=vorig[1..4,1]\0\vorig[5,1]
        matain b1
        matain v1
        mata se1=sqrt(v1)
        
        getmata b1  
        getmata se1
        gen lb1=b1-se1*1.96
        gen ub1=b1+se1*1.96
        
        gen t=_n
        replace t=t+2014
        tsset t, yearly
        format t %ty
        twoway (rspike ub1 lb1 t, lcolor(gs0))(rcap ub1 lb1 t, msize(medsmall) lcolor(gs0))(scatter b1 t), xline(2019) yline(0) xtitle("") ytitle("") /// 
        legend(off) xlabel(2015(1)2020) 
        graph export ols.eps, replace



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




/*********************************************
VAR with sign restrictions
*********************************************/
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/SVARdata.csv", varnames(1) clear 
tsset month, monthly 

sax12 u, satype(single) inpref(u.spc) outpref(u) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12im "u.out", ext(d11)
sax12 v, satype(single) inpref(v.spc) outpref(v) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12im "v.out", ext(d11)

drop u v month
rename (u_d11 v_d11)(u v)

export delimited using "${path}\SVARdata_seasonadjusted2.csv", replace
*manually saved it to "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/SVARdata_seasonadjusted2.csv"


/*************** Executable using R from below:
*SVAR.Rmd

###### Install required packages
install.packages("minqa") 
install.packages("HI") 
install.packages("mvnfast")
install.packages("lubridate")  
install.packages("VARsignR")  

###### Import data and set sign restrictions

rm(list = ls())
set.seed(12345)
library(VARsignR)

SVARdata <- read.csv("https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/SVARdata_seasonadjusted2.csv")
SVARdata <- ts (SVARdata, frequency = 12, start = c(2012, 1))

constr <- c(-1,+2,-4)  # FW(-1) should be place in the first order. 


###### Uhlig’s (2005) Penalty Function Method

model <- uhlig.penalty(Y=SVARdata, nlags=3, draws=2000, subdraws=1000, nkeep=1000, KMIN=1, KMAX=3, constrained=constr, constant=FALSE, steps=120, penalty=100, crit=0.001)

irfs <- model$IRFS 

vl <- c("Foreign Workers","Domestic Workers","Production Shock","Unemployment rate","Vacancy rate")

irfplot(irfdraws=irfs, type="median", labels=vl, save=FALSE, bands=c(0.16, 0.84), grid=TRUE, bw=TRUE)


###### Rubio-Ramirez et al’s (2010) Rejection Method

model3 <- rwz.reject(Y=SVARdata, nlags=3, draws=200, subdraws=200, nkeep=1000, KMIN=1, KMAX=3, constrained=constr, constant=FALSE, steps=120)

irfs3 <- model3$IRFS

vl <- c("Foreign Workers","Domestic Workers","Production Shock","Unemployment rate","Vacancy rate")

irfplot(irfdraws=irfs3, type="median", labels=vl, save=FALSE, bands=c(0.16, 0.84), grid=TRUE, bw=TRUE)


###### Fry and Pagan’s (2011) Median-Target (MT) method

model2 <- uhlig.reject(Y=SVARdata, nlags=3, draws=200, subdraws=200, nkeep=1000, KMIN=1, KMAX=3, constrained=constr, constant=FALSE, steps=120)

summary(model2)

irfs2 <- model2$IRFS

fp.target(Y=SVARdata, irfdraws=irfs2, nlags=3, constant=F, labels=vl, target=TRUE, type="median", bands=c(0.16, 0.84), save=FALSE, grid=TRUE, bw=TRUE, legend=TRUE, maxit=1000)




********************/


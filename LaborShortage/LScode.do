** LScode ver5.0.do

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

*********************************************/


cls
clear all
set scheme s1color, perm 

/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\Github move\Latex\Dissertation Draft ver5.0"   
/*********************************************
*********************************************/


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


/*********************************************
Regression Data Generation
*********************************************/
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/u.csv", varnames(1) clear 
        // E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\경제활동인구조사\rawdata\infile3 (2015~2017추가).do   =>  nonuC
rename nonuc ut
rename uc uC
save ut, replace 

*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/e9inflow.csv", varnames(1) clear 
destring *, replace dpcomma
reshape long ym, i(indmc) j(j)
rename ym e9inflow
rename j ym
save e9inflow, replace 

*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/cpi.csv", varnames(1) clear 
save cpi, replace

*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/exchangerate.csv", varnames(1) clear 
save exchangerate, replace

*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/totalforeignproportion.csv", varnames(1) clear 
save forper, replace 

*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
merge m:1 ym using ut, nogenerate
merge m:1 ym using cpi, nogenerate
merge m:1 ym using exchangerate, nogenerate
merge 1:1 ym indmc using e9inflow, nogenerate
merge m:1 indmc using forper, nogenerate

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

save panelmf1, replace

*** wage seasonal adjustment
*!start
use panelmf1, clear
keep if 612<=ym&ym<=744   // largest available data span for wage variable.

local i=0
    preserve
    keep if indmc==`i'
    sax12 wage, satype(single) inpref(wage.spc) outpref(wage) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
    sax12im "wage.out", ext(d11)

    sax12 wagefull, satype(single) inpref(wagefull.spc) outpref(wagefull) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
    sax12im "wagefull.out", ext(d11)

    sax12 wagepart, satype(single) inpref(wagepart.spc) outpref(wagepart) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
    sax12im "wagepart.out", ext(d11)

    drop wage wagefull wagepart
    rename (wage_d11 wagefull_d11 wagepart_d11) (wage wagefull wagepart)
    keep ym indmc wage wagefull wagepart
    save wage`i', replace 
    restore

forvalues i= 10(1)33 {
    preserve
    keep if indmc==`i'
    sax12 wage, satype(single) inpref(wage.spc) outpref(wage) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
    sax12im "wage.out", ext(d11)

    sax12 wagefull, satype(single) inpref(wagefull.spc) outpref(wagefull) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
    sax12im "wagefull.out", ext(d11)

    sax12 wagepart, satype(single) inpref(wagepart.spc) outpref(wagepart) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
    sax12im "wagepart.out", ext(d11)

    drop wage wagefull wagepart
    rename (wage_d11 wagefull_d11 wagepart_d11) (wage wagefull wagepart)
    keep ym indmc wage wagefull wagepart
    save wage`i', replace 
    restore
}

use wage0, clear
forvalues i= 10(1)33 {
    append using wage`i'
}
save wagesax, replace 

use panelmf1, clear
drop wage wagefull wagepart
merge m:1 ym indmc using wagesax, nogenerate

drop if inlist(indmc,12)  // tobacco industry. Extremely few workers, and production data is not available.
sort indmc ym
keep if 660<=ym&ym<=745   // largest available data span.
save panelm, replace 

*!start
cd "${path}"
use panelm, clear
keep ym indmc numD e9 hourfull
reshape wide numD e9 hourfull, i(indmc) j(ym)

** 719=2019m12; 722=2020m3; 724=2020m5; 739=2021m8

gen e9chg=(e9744-e9715)/numD715*100
gen e9share=e9715/numD715*100

keep indmc e9chg e9share hourfull716
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

keep if 660<=ym&ym<=744   // largest available data span.

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
gen d=0 if  684<=ym&ym<=719  // 684<=ym&ym<=719 // inlist(ym,712,713,714,715,716,717,718,719) 
replace d=1 if 739<=ym&ym<=744 // inlist(ym,738,739,740,741,742,743,744)
drop if d==.

gen forperd=forper*d
gen e9shared=e9share*d
gen e9chgd=e9chg*d

label var d "T" 
label var e9shared "E9SHARE $\times$ D" 
label var e9chgd "E9CHG $\times$ D" 
label var forperd "TFWSHARE $\times$ D" 

eststo clear 
eststo: xtivreg v (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg wage (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg hour (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg uibC (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)

esttab * using "tablemar1.tex", ///
    title(\label{tablemar1}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	

// Find First-stage F statistics. Does not work in Stata version 16 (bug)
ivreghdfe v proddome (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe wage (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe hour (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe uibC (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  

twoway (scatter e9share forper)(lfit e9share forper) ///
        , xtitle("TFW Share (%)") ytitle("E9 Share (%)") legend(off)
graph export TFWe9share.eps, replace

twoway (scatter forper hourfull716)(lfit forper hourfull716), ///
        xtitle("Fulltime Workers' Monthly Work Hours") ytitle("TFW Share (%)") legend(off) ///
        title(Correlation between Work hours and TFW share) xline(174)
graph export TFWsharehourfull716.eps, replace

eststo clear 
eststo: xtivreg numDpartproportion (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg vfull (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg vpart (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg a_alter (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg lambda_alter (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)

esttab * using "tablemar2.tex", ///
    title(\label{tablemar2}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	

// Find First-stage F statistics. Does not work in Stata version 16 (bug)
ivreghdfe numDpartproportion proddome (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe vfull (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe vpart (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe a_alter (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe lambda_alter (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  


eststo clear 
eststo: xtivreg wage (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg wagefull (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)
eststo: xtivreg wagepart (e9chgd=e9shared) i.ym proddome prodabroad prodoper, fe vce(cluster indmc)

esttab * using "tablemar3.tex", ///
    title(\label{tablemar3}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	

// Find First-stage F statistics. Does not work in Stata version 16 (bug)
ivreghdfe wage (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe wagefull (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  
ivreghdfe wagepart (e9chgd=e9shared) i.ym proddome prodabroad prodoper, absorb(indmc) cluster(indmc) first  


/*********************************************
Continuous DID Regressions (monthly)
*********************************************/
*!start
cd "${path}"
use panelf3, clear
drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations

keep if 684<=ym
tab ym, gen(dum)

foreach i of numlist 1/61 {
    gen e9sharedum`i'=e9share*dum`i'
    gen e9chgdum`i'=e9chg*dum`i'
    gen forperdum`i'=forper*dum`i'
}
* dum61 = 2020m1

foreach var in proddome prodabroad prodoper a_alter lambda_alter v vfull vpart hour wage wagefull wagepart numDpartproportion {
    gen `var'_temp=`var'
    drop `var'
    tsfilter hp `var'_hp2 = `var'_temp, trend(`var') smooth(3)
}

order *, sequential
foreach i of varlist numDpartproportion v vfull vpart hour wage wagefull wagepart a_alter lambda_alter uibC {  
preserve
        reg `i' e9sharedum1-e9sharedum35 e9sharedum37-e9sharedum61 i.ym i.indmc proddome prodabroad prodoper
        mat b2=e(b)'
        mat b=b2[1..35,1]\0\b2[36..60,1]   
        mat v2=vecdiag(e(V))'
        mat v=v2[1..35,1]\0\v2[36..60,1]
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

        gen v=.
        gen vfull=.
        gen vpart=.
        gen hour=.
        gen wage=.
        gen wagefull=.
        gen wagepart=.
        gen numDpartproportion=.
        gen lambda_alter=.
        gen a_alter=.
        gen uibC=.

        label var v "Vacancy" 
        label var vfull "Vacancy(Full)" 
        label var vpart "Vacancy(Part)" 
        label var hour "Work Hours" 
        label var wage "Wage" 
        label var wagefull "Wage(Full)" 
        label var wagepart "Wage(Part)" 
        label var numDpartproportion "Ratio Part/Full" 
        label var a_alter "Match Efficiency" 
        label var lambda_alter "Termination" 
        label var uibC "Non-employment rate" 

        twoway (rspike ub lb t, lcolor(gs0))(rcap ub lb t, msize(medsmall) lcolor(gs0))(scatter b t), xline(719) yline(0) xtitle("") ytitle("") /// 
        legend(off) xlabel(684(12)744) ///
        title(`: variable label `i'')
        graph export contdid`i'.eps, replace
restore
}



/*********************************************
Continuous DID Regressions (KLIPS Logit)
*********************************************/
*!start
clear all
use "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/klipsresult_logit.dta"
cd "${path}"
save klipsresult_logit, replace 

*!start
cd "${path}"
use panelf3, clear
drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations

gen date = dofm(ym)
format date %d
gen yr=year(date)
gen month=month(date)

foreach var of varlist prod {
    egen `var'yr=mean(`var'), by(yr indmc)
}
keep if month==8
drop if yr==2021
xtset indmc yr

merge 1:m yr indmc using klipsresult_logit, nogenerate

tab yr, gen(dum)

foreach i of numlist 1/6 {
    gen e9sharedum`i'=e9share*dum`i'
    gen e9chgdum`i'=e9chg*dum`i'
}

ereturn list
order *, sequential
logit sel e9sharedum1-e9sharedum4 e9sharedum6 i.yr i.indmc proddome prodabroad prodoper
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
        legend(off) xlabel(2015(1)2020) ///
        title("Panel A")
        graph export logit.eps, replace



/*********************************************
Continuous DID Regressions (KLIPS Mlogit)
*********************************************/
*!start
clear all
use "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/klipsresult_mlogit.dta"
cd "${path}"
save klipsresult_mlogit, replace 

*!start
cd "${path}"
use panelf3, clear
drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==32|indmc==16  // too much fluctuations
drop if indmc==19  // too few observations

gen date = dofm(ym)
format date %d
gen yr=year(date)
gen month=month(date)

foreach var of varlist prod {
    egen `var'yr=mean(`var'), by(yr indmc)
}
keep if month==8
drop if yr==2021
xtset indmc yr

merge 1:m yr indmc using klipsresult_mlogit, nogenerate

tab yr, gen(dum)

foreach i of numlist 1/6 {
    gen e9sharedum`i'=e9share*dum`i'
    gen e9chgdum`i'=e9chg*dum`i'
}

ereturn list
order *, sequential
mlogit sel e9sharedum1-e9sharedum4 e9sharedum6 i.yr i.indmc proddome prodabroad prodoper
        mat borig=e(b)'
        mat vorig=vecdiag(e(V))'
        clear
        
        mat b1=borig[35..38,1]\0\borig[39,1]   
        mat v1=vorig[35..38,1]\0\vorig[39,1]
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
        legend(off) xlabel(2015(1)2020) ///
        title("Panel B [Became Unemployed]")
        graph export mlogit1.eps, replace


        mat b2=borig[69..72,1]\0\borig[73,1]   
        mat v2=vorig[69..72,1]\0\vorig[73,1]
        matain b2
        matain v2
        mata se2=sqrt(v2)
        
        getmata b2
        getmata se2
        gen lb2=b2-se2*1.96
        gen ub2=b2+se2*1.96
        
        twoway (rspike ub2 lb2 t, lcolor(gs0))(rcap ub2 lb2 t, msize(medsmall) lcolor(gs0))(scatter b2 t), xline(2019) yline(0) xtitle("") ytitle("") /// 
        legend(off) xlabel(2015(1)2020) ///
        title("Panel C [Became Inactive]")
        graph export mlogit2.eps, replace


        mat b3=borig[103..106,1]\0\borig[107,1]   
        mat v3=vorig[103..106,1]\0\vorig[107,1]
        matain b3
        matain v3
        mata se3=sqrt(v3)
        
        getmata b3
        getmata se3
        gen lb3=b3-se3*1.96
        gen ub3=b3+se3*1.96
        
        twoway (rspike ub3 lb3 t, lcolor(gs0))(rcap ub3 lb3 t, msize(medsmall) lcolor(gs0))(scatter b3 t), xline(2019) yline(0) xtitle("") ytitle("") /// 
        legend(off) xlabel(2015(1)2020) ///
        title("Panel D [Moved to another sector]")
        graph export mlogit3.eps, replace


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

export delimited using "${path}\SVARdata_seasonadjusted.csv", replace
*manually saved it to "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/SVARdata_seasonadjusted.csv"


/*************** Executable using R from below:

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

SVARdata <- read.csv("https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/SVARdata_seasonadjusted.csv")
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


cls
clear all
set scheme s1color, perm 

/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="D:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\211126"   
/*********************************************
*********************************************/


/*********************************************
Graphs
*********************************************/

*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/monthlye9.csv", clear 
gen date=ym(year,month)
tsset date
format date %tm

copy "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/X12A.EXE" "${path}/X12A.exe"
net install st0255.pkg
adopath + "${path}"

tsfilter hp e9inflow_hp = e9inflow, trend(smooth_e9inflow) smooth(1)
sax12 smooth_e9inflow, satype(single) inpref(e9inflow.spc) outpref(e9inflow) transfunc(log) regpre( const ) ammodel((0,1,1)(0,1,1)) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12im "e9inflow.out", ext(d11)
keep if date>=648

twoway (tsline e9inflow_d11, lcolor(gs0))(tsline e9stock, lwidth(thick) lcolor(gs0) yaxis(2)) ///
, xlabel(648(6)737) xlabel(, grid angle(270)) xline(720) ytitle("person", axis(1)) ytitle("person", axis(2)) scheme(s1mono) ///
ysize(3.5) xsize(8) ///
legend(label(1 "E9 inflow") label(2 "E9 stock")) ///
caption("Source: Employment Permit System (EPS)")
graph export monthlye9.eps, replace

*********************
*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/e9f4h2.csv", clear 
gen date=ym(year,month)
tsset date
format date %tm
gen t=date

twoway (tsline f4, lcolor(gs0) clpattern(longdash))(tsline e9, lcolor(gs0))(tsline h2, lcolor(gs0) clpattern(shortdash_dot)) ///
, xlabel(648(6)737) xlabel(, grid angle(270)) xline(720) ytitle("person") scheme(s1mono) ///
ysize(3.5) xsize(8) ///
caption("Source: Monthly Korea Immigration Service Statistics, Ministry of Justice.")
graph export e9f4h2.eps, replace


*********************
*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/did_graph.csv", varnames(1) clear 
gen ym=t+695
tsset ym
format ym %tm
replace emp=emp/1000
replace u=u*100
replace v=v*100


qui su emp
generate upper = r(max)
qui su emp
local min=r(min)
local barcall upper ym if inrange(ym, 713,719) | inrange(ym, 722,724) | inrange(ym,733,739), bcolor(gs14) base(`min')
twoway (bar `barcall')(tsline emp, lcolor(gs0))(tsline production, lcolor(blue) yaxis(2) ///
    text(3645 716 "P1 (D=0)") text(3645 723 "P2") text(3645 736 "P3 (D=1)")) ///
       , xtitle("") ytitle("A thousand person") xline(720) /// 
    legend(label(2 "Total workers (Left)") label(3 "Production (Right)") order(2 3))
graph export empgraph.eps, replace


qui su u
generate upper2 = r(max)
qui su v
local min=0.5
local barcall upper2 ym if inrange(ym, 713,719) | inrange(ym, 722,724) | inrange(ym,733,739), bcolor(gs14) base(`min')
twoway (bar `barcall')(tsline u, lcolor(gs0))(tsline v, lcolor(gs0) clpattern(dash))(tsline production, lcolor(blue) yaxis(2) ///
    text(0.6 716 "P1 (D=0)") text(0.6 723 "P2") text(0.6 736 "P3 (D=1)")) ///
    , xtitle("") ytitle("%") xline(720) /// 
    legend(label(2 "Unemployment rate") label(3 "Vacancy") label(4 "Production (Right)") order(2 3 4))
graph export uvgraph.eps, replace




/*********************************************
Regression Models
*********************************************/

*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
replace ym=t+695
xtset indmc ym   // indmc = sub-sector of manufacturing industry. ; ym = monthly time.
format ym %tm
rename (nume numd exit) (numE numD EXIT)  // numE = number of vacant spots ; numD = number of workers ; EXIT = number of separated workers
gen v=numE/numD*100   // v = vacancy rate
gen MATCHr=matched/numD*100  // matched = number of matched person. ; MATCHr = matching percentage per total workers.
gen EXITr=EXIT/numD*100  // EXITr = separation percentage per total workers.
drop if indmc==0         // information for total manufacturing sectors. 

foreach var in v MATCHr EXITr prod numD {
tsfilter hp `var'_hp = `var', trend(smooth_`var') smooth(200)  // hp smoothing
}

drop if inlist(indmc,12)  // tobacco industry. Extremely few workers, and production data is not available.
save panelm, replace 


*!start
cd "${path}
use panelm, clear
keep ym indmc numD e9 v prod
reshape wide numD e9 v prod, i(indmc) j(ym)

** 719=2019m12; 722=2020m3; 724=2020m5; 739=2021m8
gen e9chg=(e9739-e9719)/numD719*100
gen e9chg739726=(e9739-e9726)/numD719*100
gen vchg=(v739-v719)/numD719*100
gen e9share=e9719/numD719*100
gen numDchg=(numD724-numD722)/numD719*100
gen prodchg=(prod724-prod722)

keep indmc vchg numD719 e9chg e9share numDchg prodchg e9chg739726
save chg, replace 

twoway (scatter vchg e9chg, lcolor(gs0))(lfit vchg e9chg, lcolor(gs0)) 
twoway (scatter vchg e9share, lcolor(gs0))(lfit vchg e9share, lcolor(gs0)) 
twoway (scatter e9share e9chg, lcolor(gs0))(lfit e9share e9chg, lcolor(gs0)) 


*!start
cd "${path}
use panelm, clear
merge m:1 indmc using chg, nogenerate

gen d=0 if inlist(ym,713,714,715,716,717,718,719)
replace d=1 if inlist(ym,733,734,735,736,737,738,739)
drop if d==.

gen e9shared=e9share*d
gen e9chg739719d=e9chg739719*d
gen prodchg724722d=prodchg724722*d
gen numDchg724722d=numDchg724722*d

label var v "Vacancy" 
label var d "T" 
label var e9shared "E9SHARE $\times$ D" 
label var e9chg739719d "E9CHG $\times$ D" 
label var prod "Production"
label var prodchg724722d "PRODCHG $\times$ D" 
label var numDchg724722d "WORKERCHG $\times$ D" 

eststo clear 
eststo: xtivreg v (e9chg739719d=e9shared) i.ym prod, fe vce(cluster indmc) first
eststo: xtivreg v (e9chg739719d=e9shared) i.ym prodchg724722d prod, fe vce(cluster indmc) first
eststo: xtivreg v (e9chg739719d=e9shared) i.ym numDchg724722d prod, fe vce(cluster indmc) first

esttab * using "..\latex\tablenov1.tex", ///
    title(\label{tablenov1}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	



/*********************************************
Calibration of Matching efficiency and Termination rate (total manufacturing sector)
*********************************************/
*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
replace ym=t+695
xtset indmc ym   // indmc = sub-sector of manufacturing industry. ; ym = monthly time.
format ym %tm


*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/totalmanufacturing.csv", varnames(1) clear 
gen t=_n+659
tsset t
format t %tm

foreach var in ut empt vacancyt matchedt exitt{
    rename `var' `var'temp
    tsfilter hp `var'_hp = `var'temp, trend(`var') smooth(50) 
}
drop if _n<49
keep t ut empt vacancyt matchedt exitt 

gen lt=empt/(1-ut)
gen vt=vacancyt/lt
gen thetat=vt/ut

gen lnF=ln(matchedt/ut/lt)
gen lntheta=ln(thetat)
reg lnF lntheta
twoway (scatter lnF lntheta)(lfit lnF lntheta)
scalar k=_b[lntheta]
di k   // k=.3066547

gen at=matchedt/(ut*lt*(vt/ut)^k)    // calibration result for matching efficiency (total manufacturing sector)
gen lambdat=exitt/empt               // calibration result for termination rate (total manufacturing sector)



/*********************************************
Matching efficiency
*********************************************/
*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/u.csv", varnames(1) clear 
save u, replace 


*!start
cd "${path}
use panelm, clear
merge m:1 indmc using chg, nogenerate
merge m:1 t using u, nogenerate
xtset indmc ym
format ym %tm

replace v=numE/numD
gen theta=v/u               // theta= market tightness
gen lambda=EXIT/numD       // lambda= termination rate; EXIT= separation number; numD= total number of workers.
gen l=numD/(1-u)          // l= active population per each sub-industry

scalar k=.3066547
gen a=matched/(u*l*(v/u)^k)      // a= matching efficiency
gen adiscrete=matched/u/l*(1+theta)/theta  // // adiscrete= matching efficiency (discrete version)

foreach var in a lambda {
    tsfilter hp `var'_hp = `var', trend(`var'_smooth) smooth(10) 
}
save panelm2, replace


*!start
cd "${path}
use panelm2, clear
gen d=0 if inlist(ym,713,714,715,716,717,718,719)
replace d=1 if inlist(ym,733,734,735,736,737,738,739)
drop if d==.

gen e9shared=e9share*d
gen e9chgd=e9chg*d
gen prodchgd=prodchg*d
gen numDchgd=numDchg*d

label var v "Vacancy" 
label var d "T" 
label var e9shared "E9SHARE $\times$ D" 
label var e9chgd "E9CHG $\times$ D" 
label var prod "Production"
label var prodchgd "PRODCHG $\times$ D" 
label var numDchgd "WORKERCHG $\times$ D" 
label var a "Match Eff" 
label var lambda "Termination" 

eststo clear 
eststo: xtivreg a (e9chgd=e9shared) i.ym prod, fe vce(cluster indmc) first
eststo: xtivreg lambda (e9chgd=e9shared) i.ym prod, fe vce(cluster indmc) first
eststo: xtivreg a (e9chgd=e9shared) i.ym prodchgd prod, fe vce(cluster indmc) first
eststo: xtivreg lambda (e9chgd=e9shared) i.ym prodchgd prod, fe vce(cluster indmc) first
eststo: xtivreg a (e9chgd=e9shared) i.ym numDchgd prod, fe vce(cluster indmc) first
eststo: xtivreg lambda (e9chgd=e9shared) i.ym numDchgd prod, fe vce(cluster indmc) first

esttab * using "tablenov2.tex", ///
    title(\label{tablenov2}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	


*!start
cd "${path}
use panelm2, clear
merge m:1 indmc using chg, nogenerate
keep if ym==696
keep indmc e9share
sort e9share
save rank, replace 


*!start
cd "${path}
use panelm2, clear

local var="a_smooth"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
, xline(720) xline(728) ytitle("Matching efficiency") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)
graph export final_adaniel.eps, replace

local var="lambda_smooth"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
, xline(720) xline(728) ytitle("Termination rate") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)
graph export final_lambda.eps, replace

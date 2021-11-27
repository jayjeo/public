
cls
clear all
set scheme s1color, perm 
/*********************************************
*********************************************/
* NEED TO SET YOUR OWN DESIRED PATH
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

esttab * using "..\latex\tablenov2.tex", ///
    title(\label{tablenov2}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	

gen e9chg739726d=e9chg739726*d

eststo clear
eststo: xtivreg a (e9chg739726d=e9shared) i.ym prod, fe first vce(robust)
eststo: xtivreg lambda (e9chg739726d=e9shared) i.ym prod, fe first vce(robust)
eststo: xtivreg a (e9chg739726d=e9shared) prodchg724720d i.ym prod, fe first vce(robust)
eststo: xtivreg lambda (e9chg739726d=e9shared) prodchg724720d i.ym prod, fe first vce(robust)
eststo: xtivreg la (e9chg739726d=e9shared) prodchg724720d i.ym prod, fe first vce(robust)

keep indmc	prod	ym	a	e9shared	e9chg739726d


*!start
cd "${path}
use panelm, clear
merge m:1 indmc using chg, nogenerate
keep if ym==696
keep indmc e9share
sort e9share
save rank, replace 


*!start
use panele, clear
merge m:1 indmc using chg_matched, nogenerate
merge m:1 indmc using rank, nogenerate

gen v=numE/numD
gen theta=v/u
gen lambda=EXIT/numD
gen lc=numD/(1-u)
gen unemp=u*lc
xtset indmc ym
format ym %tm

scalar k=.3066547
gen adaniel=matched/(u*lc*(v/u)^k)
gen adanieldiscrete=matched/u/lc*(1+theta)/theta

gen lc2=F.D.lc
gen bd=lc2/lc-1

local var="adaniel"
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
graph export ..\latex\final_adaniel.eps, replace

local var="lambda"
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
graph export ..\latex\final_lambda.eps, replace


foreach num of numlist 1/9 {
gen d`num'=0
}
replace d1=1 if inlist(ym,696,697,698)
replace d2=1 if inlist(ym,702,703,704)
replace d3=1 if inlist(ym,708,709,710)
replace d4=1 if inlist(ym,714,715,716)
replace d5=1 if inlist(ym,720,721,722)
replace d6=1 if inlist(ym,726,727,728)
replace d7=1 if inlist(ym,732,733,734)
replace d8=1 if inlist(ym,737,738,739)
drop if d1==0&d2==0&d3==0&d4==0&d5==0&d6==0&d7==0&d8==0

replace d9=1 if inlist(ym,696,697,698)
replace d9=2 if inlist(ym,702,703,704)
replace d9=3 if inlist(ym,708,709,710)
replace d9=4 if inlist(ym,714,715,716)
replace d9=5 if inlist(ym,720,721,722)
replace d9=6 if inlist(ym,726,727,728)
replace d9=7 if inlist(ym,732,733,734)
replace d9=8 if inlist(ym,737,738,739)

foreach num of numlist 1/8 {
gen e9shared`num'=e9share*d`num'
}

xi: xtreg lambda e9shared2-e9shared8 i.ym i.d9|prod, fe







*!start
cd "D:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\직종별사업체노동력조사 2021_지역\rawdata"
import delimited "D:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\직종별사업체노동력조사 2021_지역\matlab\Searchintensityraw.csv", varnames(1) clear 
gen t=_n+659
tsset t
format t %tm


foreach var in uc empc vacc matchedc us emps vacs matcheds {
    rename `var' `var'temp
    tsfilter hp `var'_hp = `var'temp, trend(`var') smooth(200) 
}


keep uc empc vacc matchedc us emps vacs matcheds t

gen lc=empc/(1-uc)
gen ls=emps/(1-us)
gen vc=vacc/lc
gen vs=vacs/ls
gen thetac=vc/uc
gen thetas=vs/us
gen invthetac=1/thetac
gen invthetas=1/thetas
scalar a=15
scalar s=5
scalar k=.3066547
scalar g=3

gen sc=(matchedc*a*vc/lc)/(a*uc*vc-matchedc*uc/lc)
gen ss=(matcheds*a*vs/ls)/(a*us*vs-matcheds*us/ls)
gen ac=(s*matchedc*uc/lc)/(s*uc*vc-matchedc*vc/lc)
gen as=(s*matcheds*us/ls)/(s*us*vs-matchedc*vs/ls)
gen tc=matchedc/lc*(uc+vc)/(uc*vc)
gen ts=matcheds/ls*(us+vs)/(us*vs)
gen tc_test=(uc+vc)/(uc*vc)
gen ts_test=(us+vs)/(us*vs)
gen tc_test2=matchedc/lc
gen ts_test2=matcheds/ls
gen tc_alter=matchedc/lc/(uc^k*vc*(1-k))
gen ts_alter=matcheds/ls/(us^k*vs*(1-k))
gen sc_alter=(matchedc/lc/(uc^k*(a*vc)^(1-k)))^(1/k)
gen ss_alter=(matcheds/ls/(us^k*(a*vs)^(1-k)))^(1/k)
gen ac_alter=(matchedc/lc/(vc^(1-k)*(s*uc)^(k)))^(1/(1-k))
gen as_alter=(matcheds/ls/(vs^(1-k)*(s*us)^(k)))^(1/(1-k))
gen avonlyc=(matchedc*uc)/(lc*vc*(g*uc-matchedc/lc))
gen avonlys=(matcheds*us)/(ls*vs*(g*us-matcheds/ls))
gen avonlyc_alter=((matchedc)/(lc*uc^k*vc^(1-k)))^(1/(1-k))
gen avonlys_alter=((matcheds)/(ls*us^k*vs^(1-k)))^(1/(1-k))
gen duc=F.d.uc
gen dus=F.d.us
/*
drop if _n<49
gen lnF=ln(matchedc/uc/lc)
gen lntheta=ln(thetac)
reg lnF lntheta
twoway (scatter lnF lntheta)(lfit lnF lntheta)
scalar k=.3066547
*/
gen adanielc=matchedc/(uc*lc*(vc/uc)^k)


gen lnipjc=ln(matchedc/lc)
gen lnvacc=ln(vc)
gen lnunempc=ln(uc)

nl(lnipjc={h}+{k}*lnvacc+(1-{k})*lnunempc)
predict lnipj_prc
gen aac=lnipjc-lnipj_prc
replace aac=exp(aac)

gen lnipjs=ln(matcheds/ls)
gen lnvacs=ln(vs)
gen lnunemps=ln(us)

nl(lnipjs={h}+{k}*lnvacs+(1-{k})*lnunemps)
predict lnipj_prs
gen aas=lnipjs-lnipj_prs
replace aas=exp(aas)

/*
twoway (tsline sc, lcolor(red))(tsline ss, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline ac, lcolor(red))(tsline as, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline tc, lcolor(red))(tsline ts, lcolor(blue))(tsline invthetac, yaxis(2) lwidth(thick) lcolor(red))(tsline invthetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline tc_alter, lcolor(red))(tsline ts_alter, lcolor(blue))(tsline invthetac, yaxis(2) lwidth(thick) lcolor(red))(tsline invthetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline uc, lcolor(red))(tsline us, lcolor(blue))
twoway (tsline sc_alter, lcolor(red))(tsline ss_alter, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline ac_alter, lcolor(red))(tsline as_alter, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline tc_test, lcolor(red))(tsline ts_test, lcolor(blue))(tsline invthetac, yaxis(2) lwidth(thick) lcolor(red))(tsline invthetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline tc_test2, lcolor(red))(tsline ts_test2, lcolor(blue))(tsline invthetac, yaxis(2) lwidth(thick) lcolor(red))(tsline invthetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline avonlyc, lcolor(red))(tsline avonlys, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline aelsbyc, lcolor(red))(tsline aelsbys, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline avonlyc_alter, lcolor(red))(tsline avonlys_alter, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline aelsbyc_alter, lcolor(red))(tsline aelsbys_alter, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))

twoway (tsline aac, lcolor(red))(tsline aas, lcolor(blue))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))(tsline thetas, yaxis(2) lwidth(thick) lcolor(blue))
twoway (tsline adanielc, lcolor(red))(tsline thetac, yaxis(2) lwidth(thick) lcolor(red))
*/

gen unempc=vc*lc
gen unemps=vs*ls
gen lnjfc=ln(matchedc/unempc)
gen lnjfs=ln(matcheds/unemps)
gen lnthetac=(1-k)*ln(thetac)
gen lnavonlyc_alter=ln(avonlyc_alter)
reg lnjfc lnthetac lnavonlyc_alter
predict lnjfc_pr
gen lnavonlyc_alter_pr=lnavonlyc_alter+lnjfc-lnjfc_pr
twoway (tsline lnavonlyc_alter_pr, lcolor(red))(tsline lnavonlyc_alter, lcolor(blue))
twoway (tsline lnjfc, lcolor(red))(tsline lnthetac, lcolor(blue))(tsline lnavonlyc_alter)

qui su ts
generate upper = 5
local max = 5
qui su tc
local min=1
local barcall upper t if inrange(t, 718,719) | inrange(t, 723,724) | inrange(t,726,727 ) | inrange(t, 738,739), bcolor(gs14) base(`min')
twoway (bar `barcall') ///
       (tsline tc, lcolor(gs0) lwidth(thick))(tsline ts, lcolor(gs0) /// 
    text(1.5 718.5 "P1") text(1.5 723.5 "P2") text(1.5 726.5 "P3") text(1.5 738.5 "P4")) ///
    , xtitle("") ytitle("Matching Efficiency") xline(720) xlabel(660(12)730) ylabel(1(1)5) /// 
    legend(label(2 "Manufacturing") label(3 "Service") order(2 3))
graph export ..\latex\matchingeff1.eps, replace

qui su ts
generate upper2 = 1.6
local max = 1.6
qui su tc
local min=0.8
local barcall upper2 t if inrange(t, 718,719) | inrange(t, 723,724) | inrange(t,726,727 ) | inrange(t, 738,739), bcolor(gs14) base(`min')
twoway (bar `barcall') ///
       (tsline aelsbyc, lcolor(gs0) lwidth(thick))(tsline aelsbys, lcolor(gs0) /// 
    text(0.9 718.5 "P1") text(0.9 723.5 "P2") text(0.9 726.5 "P3") text(0.9 738.5 "P4")) ///
    , xtitle("") ytitle("Matching Efficiency") xline(720) xlabel(660(12)730) ylabel(0.8(0.2)1.6) /// 
    legend(label(2 "Manufacturing") label(3 "Service") order(2 3))
graph export ..\latex\matchingeff2.eps, replace



*!start
cd "D:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\직종별사업체노동력조사 2021_지역\rawdata"
import delimited "D:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\직종별사업체노동력조사 2021_지역\matlab\Searchintensityraw2.csv", varnames(1) clear 
gen t=_n+659
tsset t
format t %tm


foreach var in uc empc vacc matchedc us emps vacs matcheds exitc {
    rename `var' `var'temp
    tsfilter hp `var'_hp = `var'temp, trend(`var') smooth(20) 
}
keep uc empc vacc matchedc t exitc

gen lc=empc/(1-uc)
gen vc=vacc/lc
gen thetac=vc/uc

save temp, replace


use temp, clear // Daniel 방법
gen lnf=ln(ipjikc/uc/lc)
gen lntheta=ln(thetac)
reg lnf lntheta
predict lnf_pr
gen lne=lnf-lnf_pr
gen A_pr=exp(.4418435+lne)
gen lambda=exitc/empc
gen distance=(uc^2+vc^2)^0.5
scalar k=.2546027
gen Athetaqinv=1/(A*thetac^k)
gen Flc=F.lc
drop if _n==_N
gen bd=Flc/lc-1+0.03

gen A=(matchedc/uc/lc)/(thetac^.2546027)  // .2546027

*twoway (tsline A, lwidth(thick))(tsline A_pr)
twoway (tsline distance, lwidth(thick) yaxis(1))(tsline Athetaqinv, lcolor(blue) yaxis(2))(tsline lambda, lcolor(red) yaxis(3))(tsline bd, lcolor(gs0) yaxis(4))

scalar k=.2546027
nl (uc={g=1}*({lambda=1}*lambda+{bd=1}*bd)/({lambda=1}*lambda+{bd=1}*bd+{A=1}*A*thetac^k))
predict uc_pr
gen uc_pr2=(2.000757*lambda+1.832181*bd)/(2.000757*lambda+1.832181*bd+4.063006*A*thetac^k)
gen vc_pr=uc_pr*thetac
gen vc_pr2=uc_pr2*thetac
gen distance_pr=(uc_pr^2+vc_pr^2)^0.5
gen distance_pr2=(uc_pr2^2+vc_pr2^2)^0.5
twoway (tsline distance, lwidth(thick))(tsline distance_pr)(tsline thetac, yaxis(2))



use temp, clear // Daniel 방법을 Discrete m(u,v)로 변형 버전. 
gen lnf=ln(matched/u/l)
gen lntheta=ln(theta)
gen lntheta2=ln(1+theta)
nl(lnf={lna}+lntheta-lntheta2)
predict lnf_pr
gen lne=lnf-lnf_pr
gen adanieldiscrete=exp(1.312319+lne)

gen A=matchedc/uc/lc*(1+thetac)/thetac
twoway (tsline A, lwidth(thick))(tsline adanieldiscrete)





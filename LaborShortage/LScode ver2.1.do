
cls
clear all
set scheme s1color, perm 

/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\211126"   
/*********************************************
*********************************************/


/*********************************************
Graphs
*********************************************/

*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/monthlye9.csv", clear 
gen date=ym(year,month)
tsset date
format date %tm

copy "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/X12A.EXE" "${path}/X12A.exe"
net install st0255, from(http://www.stata-journal.com/software/sj12-2)
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


*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/immigrantsproportion.csv", clear

gen prop2000=new2000f/new2000t*100
gen prop2020=new2020f/new2020t*100

drop if countries=="Switzerland" | countries=="Estonia"
replace countries="South Korea" if countries=="Korea" 
replace countries="Slovak" if countries=="Slovak Republic"

twoway (scatter prop2020 prop2000, mlabel(countries) mlabangle(+15) mcolor(gs0) ///
        text(5 6 "45 degree line")) ///
		(function y=x, range(0 12) legend(label(1 Proportion of Immigrants) label(2 "y=x"))) ///
		, ytitle("Year 2020 (%)") xtitle("Year 2000 (%)") ///
		ysize(3.5) xsize(8) xlabel(0(3)12) ylabel(0(3)15) scheme(s1mono) ///
        legend(off) ///
        caption("Source: OECD Statistics" "Greece used data from 2017 instead of 2020" "Switzerland: 19% in 2000 and 24% in 2020")
graph export immigrantsproportion.eps, replace


*********************
*!start
cd "${path}"
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
cd "${path}"
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
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/uvlong.csv", varnames(1) clear 
gen t=_n
replace t=t+611
format t %tm
tsset t 
replace u=u/100
replace v=v/100
twoway (tsline u, lcolor(gs0))(tsline v, lcolor(red))
sax12 u, satype(single) inpref(u.spc) outpref(u) transfunc(log) regpre( const seasonal ) ammaxlag(1 1) ammaxdiff(1 1) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12 v, satype(single) inpref(v.spc) outpref(v) transfunc(log) regpre( const seasonal ) ammaxlag(1 1) ammaxdiff(1 1) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12 numd, satype(single) inpref(numd.spc) outpref(numd) transfunc(log) regpre( const seasonal ) ammaxlag(1 1) ammaxdiff(1 1) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12 matched, satype(single) inpref(matched.spc) outpref(matched) transfunc(log) regpre( const seasonal ) ammaxlag(1 1) ammaxdiff(1 1) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12 exit, satype(single) inpref(exit.spc) outpref(exit) transfunc(log) regpre( const seasonal ) ammaxlag(1 1) ammaxdiff(1 1) ammaxlead(0) x11mode(mult) x11seas(S3x9)
sax12im "${path}\u.out", ext(d11)
sax12im "${path}\v.out", ext(d11)
sax12im "${path}\numd.out", ext(d11)
sax12im "${path}\matched.out", ext(d11)
sax12im "${path}\exit.out", ext(d11)
twoway (tsline u_d11, lcolor(gs0))(tsline v_d11, lcolor(red))
tsfilter hp u_d11_hp = u_d11, trend(smooth_u) smooth(30)
tsfilter hp v_d11_hp = v_d11, trend(smooth_v) smooth(30)
tsfilter hp numd_d11_hp = numd_d11, trend(smooth_numd) smooth(30)
tsfilter hp matched_d11_hp = matched_d11, trend(smooth_matched) smooth(30)
tsfilter hp exit_d11_hp = exit_d11, trend(smooth_exit) smooth(30)
twoway (tsline smooth_u, lcolor(gs0))(tsline smooth_v, lcolor(red))
// put this result to beveridgegraph.csv and plot it using Matlab (beveridgegraph.m). 


drop u v numd matched exit
rename (smooth_u smooth_v smooth_numd smooth_matched smooth_exit)(u v numd matched exit)
gen theta=v/u
gen l=numd/(1-u)

scalar k=.3413222
gen a=matched/(u*l*(v/u)^k)    // calibration result for matching efficiency 
gen lambda=exit/numd*(1-u)               // calibration result for termination rate 

label var v "Vacancy rate" 
label var u "Unemployment rate" 
label var a "Matching efficiency" 
label var lambda "Termination rate" 

gen tt=t
twoway (tsline u, lcolor(gs0) yaxis(1))(tsline v, lcolor(gs0) clpattern(longdash) yaxis(1))(tsline a, lcolor(red) yaxis(2))(tsline lambda, lcolor(red) clpattern(longdash) yaxis(3)) ///
    , xtitle("") xline(720) ysize(3.5) xsize(8) xlabel(612(12)730)
graph export uvlong.eps, replace





/*********************************************
Regression Models
*********************************************/
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/u.csv", varnames(1) clear 
        // E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\경제활동인구조사\rawdata\infile3 (2015~2017추가).do   =>  nonuC
rename nonuc ut
save ut, replace 

*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
merge m:1 ym using ut, nogenerate

xtset indmc ym   // indmc = sub-sector of manufacturing industry. ; ym = monthly time.
format ym %tm
gen ymraw=ym
rename (nume numd exit) (numE numD EXIT)  // numE = number of vacant spots ; numD = number of workers ; EXIT = number of separated workers
gen v=numE/numD*100   // v = vacancy rate
*drop if indmc==0         // information for total manufacturing sectors. 
drop if inlist(indmc,12)  // tobacco industry. Extremely few workers, and production data is not available.
keep if 660<=ym&ym<=740   // largest available data span.
save panelm, replace 


*!start
cd "${path}"
use panelm, clear
keep ym indmc numD e9 v prod
reshape wide numD e9 v prod, i(indmc) j(ym)

** 719=2019m12; 722=2020m3; 724=2020m5; 739=2021m8
gen e9chg=(e9739-e9719)/numD719*100
gen vchg=(v739-v719)/numD719*100
gen e9share=e9719/numD719*100
gen numDchg=(numD724-numD722)/numD719*100
gen prodchg=(prod724-prod722)

keep indmc vchg numD719 e9chg e9share numDchg prodchg 
save chg, replace 

twoway (scatter vchg e9chg, lcolor(gs0))(lfit vchg e9chg, lcolor(gs0)) 
twoway (scatter vchg e9share, lcolor(gs0))(lfit vchg e9share, lcolor(gs0)) 
twoway (scatter e9share e9chg, lcolor(gs0))(lfit e9share e9chg, lcolor(gs0)) 

use panelm, clear
merge m:1 indmc using chg, nogenerate
save panelf2, replace 

    keep if indmc==0 

*!start
cd "${path}"
use panelf2, clear
preserve
    keep if indmc==0 
    tsset ym, monthly
    tsfilter hp ut_hp = ut, trend(smooth_ut) smooth(50)  // hp smoothing
    drop ut
    rename smooth_ut ut 
    replace theta=v/ut
    replace l=numD/(1-ut)
    replace lnF=ln(matched/ut/l)
    replace lntheta=ln(theta)
    reg lnF lntheta
    scalar k2=_b[lntheta]
    di k2    // .30116953
restore

scalar k2=.30116953
gen a_alter=matched/(ut*l*(v/ut)^k2)     // alternative calibration result for matching efficiency 
gen lambda_alter=exit/numd*(1-ut)        // alternative calibration result for termination rate 

save panelm5, replace



*!start
cd "${path}"
use panelf2, clear
drop if indmc==0    // information for total manufacturing sectors. 
gen d=0 if inlist(ym,713,714,715,716,717,718,719)
replace d=1 if inlist(ym,734,735,736,737,738,739,740)
drop if d==.

*corr e9share e9chg
gen e9shared=e9share*d
gen e9chgd=e9chg*d
gen prodchgd=prodchg*d
gen numDchgd=numDchg*d

*corr e9shared e9chgd

label var v "Vacancy" 
label var d "T" 
label var e9shared "E9SHARE $\times$ D" 
label var e9chgd "E9CHG $\times$ D" 
label var prod "Production"
label var prodchgd "PRODCHG $\times$ D" 
label var numDchgd "WORKERCHG $\times$ D" 

eststo clear 
eststo: xtivreg v (e9chgd=e9shared) i.ym prod, fe vce(cluster indmc) first
eststo: xtivreg v (e9chgd=e9shared) i.ym prodchgd prod, fe vce(cluster indmc) first
eststo: xtivreg v (e9chgd=e9shared) i.ym numDchgd prod, fe vce(cluster indmc) first

esttab * using "tablenov1.tex", ///
    title(\label{tablenov1}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	



/*********************************************
Calibration of Matching efficiency and Termination rate 
*********************************************/
*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/u.csv", varnames(1) clear 
        // E:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\경제활동인구조사\rawdata\infile3 (2015~2017추가).do   =>  nonuC
rename nonuC ut
save ut, replace 

*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
merge m:1 t using ut, nogenerate
replace ym=t+695
format ym %tm
xtset indmc ym
gen v=nume/numd
gen u=unemp/(unemp+numd)*uibadjust
rename u utemp
save tempo1, replace

use tempo1, clear 
foreach num of numlist 0 10(1)33 {
    preserve
        keep if indmc==`num'
        sax12 utemp, satype(single) inpref(utemp.spc) outpref(utemp) transfunc(log) regpre( const seasonal ) ammaxlag(1 1) ammaxdiff(1 1) ammaxlead(0) x11mode(mult) x11seas(S3x9)
        sax12im "${path}\utemp.out", ext(d11)
        rename utemp_d11 u
        keep indmc ym u 
        save ud11_`num', replace 
    restore 
}
use ud11_0, clear
foreach num of numlist 10(1)33 {
append using ud11_`num'
}
save ud11, replace 

use tempo1, clear 
merge 1:1 indmc ym using ud11, nogenerate
*twoway (tsline utemp if indmc==10)(tsline u if indmc==10)

gen theta=v/u
gen l=numd/(1-u)
gen lnF=ln(matched/u/l)
gen lntheta=ln(theta)
drop if _n==_N

preserve 
    keep if indmc==0
    reg lnF lntheta
    scalar k=_b[lntheta]
    di k  // k=.3413222
restore 

scalar k=.3413222
gen a=matched/(u*l*(v/u)^k)    // calibration result for matching efficiency 
gen lambda=exit/numd*(1-u)               // calibration result for termination rate 
save tempo2, replace


use tempo2, clear
preserve
    keep if indmc==0 
    tsset ym, monthly
    tsfilter hp ut_hp = ut, trend(smooth_ut) smooth(50)  // hp smoothing
    drop ut
    rename smooth_ut ut 
    replace theta=v/ut
    replace l=numd/(1-ut)
    replace lnF=ln(matched/ut/l)
    replace lntheta=ln(theta)
    reg lnF lntheta
    scalar k2=_b[lntheta]
    di k2    // .30116953
restore

scalar k2=.30116953
gen a_alter=matched/(ut*l*(v/ut)^k2)     // alternative calibration result for matching efficiency 
gen lambda_alter=exit/numd*(1-ut)        // alternative calibration result for termination rate 

save panelm5, replace


*!start
cd "${path}"
use panelm5, clear
drop if indmc==12
merge m:1 indmc using chg, nogenerate
xtset indmc ym
format ym %tm

foreach var in a a_alter lambda lambda_alter v theta {
    tsfilter hp `var'_hp2 = `var', trend(`var'_smooth) smooth(10) 
}
save panelm7, replace



*!start
cd "${path}"
use panelm7, clear
xtset indmc ym 
keep a lambda ym indmc
keep if indmc==0

*!start
cd "${path}"
use panelm7, clear
xtset indmc ym 
drop if indmc==0    // information for total manufacturing sectors. 
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
label var a_alter "Match Eff" 
label var lambda "Termination" 
label var lambda_alter "Termination" 

eststo clear 
eststo: xtivreg a (e9chgd=e9shared) i.ym prod u hour, fe vce(cluster indmc) first
eststo: xtivreg a (e9chgd=e9shared) i.ym prodchgd prod, fe vce(cluster indmc) first
eststo: xtivreg a (e9chgd=e9shared) i.ym numDchgd prod, fe vce(cluster indmc) first
eststo: xtivreg a_alter (e9chgd=e9shared) i.ym prod, fe vce(cluster indmc) first
eststo: xtivreg a_alter (e9chgd=e9shared) i.ym prodchgd prod, fe vce(cluster indmc) first
eststo: xtivreg a_alter (e9chgd=e9shared) i.ym numDchgd prod, fe vce(cluster indmc) first

esttab * using "tablenov2.tex", ///
    title(\label{tablenov2}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    	mgroups("$u_i$ for each subsector" "$u_i=u$ for all $i$", pattern(1 0 0 1 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	

eststo clear 
eststo: xtivreg lambda (e9chgd=e9shared) i.ym prod u hour, fe vce(cluster indmc) first
eststo: xtivreg lambda (e9chgd=e9shared) i.ym prodchgd prod, fe vce(cluster indmc) first
eststo: xtivreg lambda (e9chgd=e9shared) i.ym numDchgd prod, fe vce(cluster indmc) first
eststo: xtivreg lambda_alter (e9chgd=e9shared) i.ym prod, fe vce(cluster indmc) first
eststo: xtivreg lambda_alter (e9chgd=e9shared) i.ym prodchgd prod, fe vce(cluster indmc) first
eststo: xtivreg lambda_alter (e9chgd=e9shared) i.ym numDchgd prod, fe vce(cluster indmc) first


esttab * using "tablenov3.tex", ///
    title(\label{tablenov3}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    	mgroups("$u_i$ for each subsector" "$u_i=u$ for all $i$", pattern(1 0 0 1 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	


eststo clear 
eststo: xtivreg u (e9chgd=e9shared) i.ym prod, fe vce(cluster indmc) first
eststo: xtivreg u (e9chgd=e9shared) i.ym prodchgd prod, fe vce(cluster indmc) first
eststo: xtivreg u (e9chgd=e9shared) i.ym numDchgd prod, fe vce(cluster indmc) first

esttab * using "tablenov4.tex", ///
    title(\label{tablenov4}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	


*!start
cd "${path}"
use panelm7, clear
merge m:1 indmc using chg, nogenerate
keep if ym==696
keep indmc e9share
sort e9share
save rank, replace 

qui label define indmc_lab ///
10 "Food Products" ///
11 "Beverages" ///
12 "Tobacco Products" ///
13 "Textiles, Except Apparel" ///
14 "Wearing apparel, Clothing Accessories and Fur Articles" ///
15 "Tanning and Dressing of Leather, Luggage and Footwear" ///
16 "Wood Products of Wood and Cork; Except Furniture" ///
17 "Pulp, Paper and Paper Products" ///
18 "Printing and Reproduction of Recorded Media" ///
19 "Coke, hard-coal and lignite fuel briquettes and Refined Petroleum Products" ///
20 "Chemicals and chemical products except pharmaceuticals, medicinal chemicals" ///
21 "Pharmaceuticals, Medicinal Chemicals and Botanical Products" ///
22 "Rubber and Plastic Products" ///
23 "Other Non-metallic Mineral Products" ///
24 "Basic Metal Products" ///
25 "Fabricated Metal Products, Except Machinery and Furniture" ///
26 "Electronic Components, Computer, Radio, Television and Communication Equipment and Apparatuses" ///
27 "Medical, Precision and Optical Instruments, Watches and Clocks" ///
28 "Electrical equipment" ///
29 "Other Machinery and Equipment" ///
30 "Motor Vehicles, Trailers and Semitrailers" ///
31 "Other Transport Equipment" ///
32 "Furniture" ///
33 "Other Manufacturing"

qui label values indmc indmc_lab

// net install dataout.pkg
dataout, save(myfile) tex replace


*!start
cd "${path}"
use panelm7, clear

local var="v"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
(tsline `var' if indmc==0, lcolor(gs0) lwidth(thick) clpattern(longdash)) ///
, xline(720) xline(728) ytitle("Matching efficiency") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)

local var="prod"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
(tsline `var' if indmc==0, lcolor(gs0) lwidth(thick) clpattern(longdash)) ///
, xline(720) xline(728) ytitle("Matching efficiency") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)

local var="a_smooth"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
(tsline `var' if indmc==0, lcolor(gs0) lwidth(thick) clpattern(longdash)) ///
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
(tsline `var' if indmc==0, lcolor(gs0) lwidth(thick) clpattern(longdash)) ///
, xline(720) xline(728) ytitle("Termination rate") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)
graph export final_lambda.eps, replace

local var="u"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
(tsline `var' if indmc==0, lcolor(gs0) lwidth(thick) clpattern(longdash)) ///
, xline(720) xline(728) ytitle("Unemployment rate") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)
graph export final_u.eps, replace

local var="v_smooth"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
(tsline `var' if indmc==0, lcolor(gs0) lwidth(thick) clpattern(longdash)) ///
, xline(720) xline(728) ytitle("Vacancy rate") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)
graph export final_v.eps, replace

gen e9shareconcur=e9/numd*100
local var="e9shareconcur"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
(tsline `var' if indmc==0, lcolor(gs0) lwidth(thick) clpattern(longdash)) ///
, xline(720) xline(728) ytitle("e9shareconcur") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)


local var="numd"
twoway (tsline `var' if indmc==21, lcolor(blue) lwidth(thick)) ///
(tsline `var' if indmc==27, lcolor(blue) lwidth(medthick)) ///
(tsline `var' if indmc==11, lcolor(blue) lwidth(medium)) ///
(tsline `var' if indmc==26, lcolor(blue)) ///
(tsline `var' if indmc==16, lcolor(red) lwidth(thick)) ///
(tsline `var' if indmc==32, lcolor(red) lwidth(medthick)) ///
(tsline `var' if indmc==33, lcolor(red) lwidth(medium)) ///
(tsline `var' if indmc==22, lcolor(red)) ///
, xline(720) xline(728) ytitle("numD") xtitle("") ///
caption("Red: Highest E9share, Blue: Lowest E9share.") legend(off)



/***********************
Alternative identification
***********************/


*!start
cd "${path}"
use panelm7, clear
xtset indmc ym 
keep if indmc==0
keep ym hour 

*!start
cd "${path}"
use panelm7, clear
xtset indmc ym 
drop if indmc==0    // information for total manufacturing sectors. 
gen tt=ym 

gen e9cmp=e9/numD719
gen numDcmp=numd/numD719

label var v "Vacancy" 
label var prod "Production"
label var a "Match Eff" 
label var lambda "Termination" 

eststo clear 
eststo: xtreg v e9cmp prod a lambda numDcmp hour I.ym if ym>=718, fe vce(cluster indmc) 
eststo: xtreg v e9cmp prod a lambda numDcmp hour I.ym if ym<718, fe vce(cluster indmc) 

eststo clear 
eststo: xtreg v e9cmp prod a lambda hour I.ym if ym>=718, fe vce(cluster indmc) 
eststo: xtreg v e9cmp prod a lambda hour I.ym if ym<718, fe vce(cluster indmc) 

forvalues i=696(1)739{
    corr e9cmp a if ym==`i'
} 
forvalues i=696(1)739{
    corr e9cmp lambda if ym==`i'
} 


forvalues i=696(1)739{
    corr e9share a if ym==`i'
} 
forvalues i=696(1)739{
    corr e9share lambda if ym==`i'
} 


forvalues i=696(1)739{
    reg a e9share prod numDcmp hour if ym==`i'
} 
forvalues i=696(1)739{
    reg lambda e9share prod numDcmp hour if ym==`i'
} 
forvalues i=696(1)739{
    reg hour e9share prod numDcmp if ym==`i'
} 
forvalues i=696(1)739{
    reg prod e9share numDcmp hour if ym==`i'
} 
forvalues i=696(1)739{
    reg numDcmp e9share prod hour if ym==`i'
} 



*!start
cd "${path}"
use panelm, clear

merge m:1 indmc using chg, nogenerate
merge 1:1 indmc ym using ud11, nogenerate

drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==12    // tobacco industry. Extremely few workers, and production data is not available.

gen d=0 if inlist(ym,713,714,715,716,717,718,719)
replace d=1 if inlist(ym,733,734,735,736,737,738,739)
drop if d==.

corr e9share e9chg
gen e9shared=e9share*d
gen e9chgd=e9chg*d
gen prodchgd=prodchg*d
gen numDchgd=numDchg*d
corr e9shared e9chgd

label var v "Vacancy" 
label var d "T" 
label var e9shared "E9SHARE $\times$ D" 
label var e9chgd "E9CHG $\times$ D" 
label var prod "Production"
label var prodchgd "PRODCHG $\times$ D" 
label var numDchgd "WORKERCHG $\times$ D" 

eststo clear 
eststo: xtivreg v (e9chgd=e9shared) i.ym prod u hour, fe vce(cluster indmc) first

esttab * using "tablenov1.tex", ///
    title(\label{tablenov1}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace ///
    addnotes("$\text{S}_i$ and $\text{T}_t$ included but not reported.")	






*!start
cd "${path}"
use panelm, clear

merge m:1 indmc using chg, nogenerate
merge 1:1 indmc ym using ud11, nogenerate
merge 1:1 indmc ym using panelm7, nogenerate

drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==12    // tobacco industry. Extremely few workers, and production data is not available.

gen d=0 if ym<=719
replace d=1 if ym>719
drop if d==.

gen e9cmp=e9/numD719
gen numDcmp=numd/numD719
gen e9shared=e9share*d
gen e9chgd=e9chg*d
gen prodchgd=prodchg*d
gen numDchgd=numDchg*d
corr e9shared e9chgd

label var v "Vacancy" 
label var d "T" 
label var e9shared "E9SHARE $\times$ D" 
label var e9chgd "E9CHG $\times$ D" 
label var prod "Production"
label var prodchgd "PRODCHG $\times$ D" 
label var numDchgd "WORKERCHG $\times$ D" 

eststo clear 
eststo: xtivreg v (e9chgd=e9shared) i.ym prod a lambda u hour numDcmp, fe vce(cluster indmc) first
eststo: xtivreg v (e9chgd=e9shared) i.ym prod, fe vce(cluster indmc) first
eststo: xtivreg v (e9chgd=e9shared) i.ym prod a lambda u hour numDcmp, fe vce(cluster indmc) first

eststo: xtivreg v (e9cmp=L3.e9cmp) i.ym if ym>719, fe vce(cluster indmc) first
eststo: xtivreg a (e9cmp=L3.e9cmp) i.ym if ym>719, fe vce(cluster indmc) first
eststo: xtivreg lambda (e9cmp=L3.e9cmp) i.ym if ym>719, fe vce(cluster indmc) first
eststo: xtivreg numDcmp (e9cmp=L3.e9cmp) i.ym if ym>719, fe vce(cluster indmc) first
eststo: xtivreg prod (e9cmp=L3.e9cmp) i.ym if ym>719, fe vce(cluster indmc) first
eststo: xtivreg u (e9cmp=L3.e9cmp) i.ym prod if ym>719, fe vce(cluster indmc) first
eststo: xtivreg hour (e9cmp=L3.e9cmp) i.ym prod if ym>719, fe vce(cluster indmc) first

eststo: xtivreg v (e9cmp=L3.e9cmp) i.ym a lambda numDcmp prod hour if ym>718, fe vce(cluster indmc) first

eststo: xtivreg v (e9cmp=L3.e9cmp) i.ym numDcmp prod u hour if ym>719, fe vce(cluster indmc) first
eststo: xtivreg a (e9cmp=L3.e9cmp) i.ym numDcmp prod u hour if ym>719, fe vce(cluster indmc) first
eststo: xtivreg lambda (e9cmp=L3.e9cmp) i.ym numDcmp prod u hour if ym>719, fe vce(cluster indmc) first

keep if d==1
eststo: xtreg v e9cmp i.ym, fe vce(cluster indmc) 
eststo: xtreg a e9cmp i.ym, fe vce(cluster indmc) 
eststo: xtreg lambda e9cmp i.ym, fe vce(cluster indmc) 
eststo: xtreg numDcmp e9cmp i.ym, fe vce(cluster indmc) 
eststo: xtreg prod e9cmp i.ym, fe vce(cluster indmc) 
eststo: xtreg u e9cmp i.ym prod, fe vce(cluster indmc) 
eststo: xtreg hour e9cmp i.ym prod, fe vce(cluster indmc) 




*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/cpi.csv", varnames(1) clear 
save cpi, replace

*!start
cd "${path}"
use panelm, clear

merge m:1 indmc using chg, nogenerate
merge 1:1 indmc ym using ud11, nogenerate
merge 1:1 indmc ym using panelm7, nogenerate
merge m:1 ym using cpi, nogenerate

drop if indmc==0    // information for total manufacturing sectors. 
drop if indmc==12    // tobacco industry. Extremely few workers, and production data is not available.
gen tt=ym 

gen d=0 if ym<=719
replace d=1 if ym>719
drop if d==.

gen wage=wage_tot*100/cpi/hour  // cpi adjusted hourly wage (unit=KRW)

gen lnv=ln(v)
gen lne9=ln(e9)
gen lnnumD=ln(numd)
gen lna=ln(a)
gen lnlambda=ln(lambda)
gen lnprod=ln(prod)
gen lnhour=ln(hour)
gen lnu=ln(u)
gen lnwage=ln(wage)

xtreg lnv lne9 lnnumD lna lnlambda lnprod lnwage i.ym if ym>719, fe vce(cluster indmc)

label var lnv "lnv" 
label var lne9 "lnE9" 
label var lnnumD "lnTotalworker" 
label var lna "lnMatchEff" 
label var lnlambda "lnTermination" 
label var lnprod "lnProduction" 
label var lnhour "lnWorkhour" 
label var lnwage "lnHourlywage" 
label var lnu "lnunemployment" 

eststo clear
eststo: xtreg lnv lne9 lnnumD lna lnlambda lnprod lnhour lnwage lnu if ym>719, fe vce(cluster indmc)
esttab * using "tableadd1.tex", ///
    title(\label{tableadd1}) ///
    b(%9.3f) se(%9.3f) ///
    lab se r2 pr2 noconstant replace


xi: xtreg lnv i.ym|lne9 i.ym|lna i.ym|lnlambda i.ym|lnprod i.ym|lnhour i.ym|lnnumD i.ym|lnu, fe vce(cluster indmc)


keep if ym>719
xi: xtreg lnv i.ym|lne9 i.ym|lna i.ym|lnlambda i.ym|lnprod, fe vce(cluster indmc)


*!start
cd "${path}"
use panelm, clear

merge m:1 indmc using chg, nogenerate
merge 1:1 indmc ym using ud11, nogenerate
merge 1:1 indmc ym using panelm7, nogenerate
keep if indmc==0   
gen tt=ym
keep indmc wage_tot ym tt






/***********************
Alternative identification2
***********************/

*!start
cd "${path}"
use panelm, clear
merge m:1 indmc using chg, nogenerate

drop if indmc==0    // information for total manufacturing sectors. 
drop if inlist(ym,700,701,702,710,711,712,720,721,722,730,731,732)
gen d=-2 if 696<=ym&ym<=699
replace d=-1 if 703<=ym&ym<=709
replace d=0 if 713<=ym&ym<=719
replace d=1 if 723<=ym&ym<=729
replace d=2 if 733<=ym&ym<=739

tab d, gen(dum)

foreach i of numlist 1/5 {
    gen e9sharedum`i'=e9share*dum`i'
    gen e9chgdum`i'=e9chg*dum`i'
}

label var v "Vacancy" 
label var d "T" 
label var prod "Production"


eststo clear 
eststo: xtreg v e9chgdum1 e9chgdum2 e9chgdum4 e9chgdum5 i.ym prod, fe vce(cluster indmc) 



/***********************
Alternative identification3
***********************/

*!start
cd "${path}"
use panelm, clear
merge m:1 indmc using chg, nogenerate

drop if indmc==0    // information for total manufacturing sectors. 

tab ym, gen(dum)

foreach i of numlist 1/44 {
    gen e9sharedum`i'=e9share*dum`i'
    gen e9chgdum`i'=e9chg*dum`i'
}

label var v "Vacancy" 
label var prod "Production"

order *, sequential
eststo clear 
eststo: xtreg v e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg v e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 



*!start
cd "${path}"
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/cpi.csv", varnames(1) clear 
save cpi, replace

*!start
cd "${path}"
use panelm7, clear
xtset indmc ym 
drop if indmc==0    // information for total manufacturing sectors. 
merge m:1 ym using cpi, nogenerate
gen wage=wage_tot*100/cpi/hour  // cpi adjusted hourly wage (unit=KRW)
replace v=v*100

tab ym, gen(dum)

foreach i of numlist 1/44 {
    gen e9sharedum`i'=e9share*dum`i'
    gen e9chgdum`i'=e9chg*dum`i'
}

gen exitshare=exit/numD719*100

label var v "Vacancy" 
label var a "Match Eff" 
label var a_alter "Match Eff" 
label var lambda "Termination" 
label var lambda_alter "Termination" 

order *, sequential
eststo clear 
eststo: xtreg v e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg a e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg lambda e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg a_alter e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg lambda_alter e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg hour e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg u e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg wage e9chgdum1-e9chgdum24 e9chgdum26-e9chgdum44 i.ym prod, fe vce(cluster indmc) 

eststo: xtreg v e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg a e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg lambda e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg a_alter e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg lambda_alter e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg hour e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg u e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 
eststo: xtreg wage e9sharedum1-e9sharedum24 e9sharedum26-e9sharedum44 i.ym prod, fe vce(cluster indmc) 


twoway (scatter e9chg numD719, lcolor(gs0))(lfit e9chg numD719, lcolor(gs0)) 
twoway (scatter e9share numD719, lcolor(gs0))(lfit e9share numD719, lcolor(gs0)) 


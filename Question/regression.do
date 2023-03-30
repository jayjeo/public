// Ready to hop on regressions //

use master_afterEMPmerge, clear
merge m:1 location year using NI_oecd, nogenerate
//merge m:1 sector year using data/cps_skill, nogenerate
merge m:1 location year using price_consumption, nogenerate
merge 1:1 location sector year using concentration, nogenerate
save master_fin, replace 




*==================== oecd version
use master_fin, clear
gen N=N_oecd
gen I=I_oecd
gen RK=oecd_CFCC_detail
gen K=RK/R_plain
gen WLRK=oecd_LABR_detail/oecd_CFCC_detail
gen L=oecd_EMP
gen priceW_i=oecd_LABR_detail/oecd_EMP   
drop if sector==""|location==""
egen ij=group(location sector)
xtset ij year 
gen ls=oecd_LABR_detail/oecd_VALU_detail
egen ls_mean=mean(ls), by(ij)
drop if ls_mean==.
sort ij year
gen flag_IFR=1


sort ij year
foreach var of varlist installations_detail {
	by ij: gen cum_`var'=sum(`var')
	//replace cum_`var'=0 if year==2000
}


/*
gen M=installations
replace M=M+M[_n-1] if M[_n-1]!=.
*/
gen M=cum_installations_detail
sort ij
replace M=. if M==0
egen min_M=min(M), by(ij)
replace M=min_M if M==.
drop min_M

//drop if 215<=ij&ij<=227|ij==416|ij==423  // labor share is error.
save ls_detail2, replace

use ls_detail2, clear
rename (concentration)(con)

*** Karabarbounis의 R을 사용 \\ R=(investment price)/(consumer price) 를 사용 (엄밀하게 이것은 R/W이 아님)
gen R=R_plain 
//gen R=R_KN 

*** 2015에 끝나는 Karabarbounis의 R에 2020까지의 R을 신규로 합침 \\ R=(investment price)/(consumer price) 를 사용 (엄밀하게 이것은 R/W이 아님)
//replace R=R 

*** Karabarbounis의 R을 사용 \\ R=(investment price)/(wage) 를 사용 (엄밀하게 이것은 Karabarbounis의 R이 아님)
//replace R=R_plain/priceW_i

drop markup_detail
gen markup_detail=oecd_VALU_detail/(oecd_LABR_detail+oecd_CFCC_detail)
gen WL=oecd_LABR_detail

keep ls R M markup_detail location sector year oecd_VALU_detail R_plain N I L K WLRK RK WL con
egen ij=group(location sector)
xtset ij year
/*
rangestat (mean) ls R L K WLRK N I con, interval(year -3 3) by(location sector)
foreach var of varlist ls R L K WLRK N I con{
    drop `var'
    rename `var'_mean `var'
}
*/
foreach var of varlist L {
    egen `var'_mean=mean(`var'), by(location sector)
}
/*
gen L2000=L if year==2000
egen L20000=mean(L2000), by(location sector)
drop L2000
rename L20000 L_mean
*/

foreach var of varlist ls R markup_detail N I L K WLRK {
    rename `var' `var'_temp
    ipolate `var'_temp year, gen(`var') epolate by(ij) 
    drop `var'_temp
}
foreach var of varlist M {
    rename `var' `var'_temp
    ipolate `var'_temp year, gen(`var') by(ij) 
    drop `var'_temp
}
save markupcon, replace 

use markupcon, clear 
egen country=group(location)
egen ind=group(sector)
reg con markup i.country i.ind i.year

use markupcon, clear 
gen lsmarkup=ls*markup_detail
rename (oecd_VALU_detail)(Y)
drop RK WL

reshape wide ls lsmarkup markup_detail R M Y R_plain N I L K WLRK L_mean con, i(location sector) j(year)
foreach var in ls lsmarkup markup_detail R R_plain M N I L K WLRK con{
    gen gr_`var'2000=(`var'2000-`var'1990)/`var'1990
    forval start = 1991/2010 {
        local end=`start'+10
        gen gr_`var'`end'=(`var'`end'-`var'`start')/`var'`start'
        }
    }
foreach var in M {
    gen AAR1995=(`var'2000-`var'1990)/L_mean2000
    forval start = 1991/2010 {
        local end=`start'+10
        gen AAR`end'=(`var'`end'-`var'`start')/L_mean2000
        }
    }
keep location sector gr* AAR* R_plain*
reshape long gr_ls gr_lsmarkup gr_markup_detail gr_R gr_R_plain gr_M AAR gr_N gr_I gr_L gr_K gr_WLRK gr_con, i(location sector) j(t)
rename gr_markup_detail gr_markup
egen ij=group(location sector)
xtset ij t
egen country=group(location)
egen ind=group(sector)
/*
foreach var in gr_ls gr_lsmarkup gr_markup gr_R gr_M gr_N gr_I gr_L gr_K gr_WLRK AAR gr_con{
    rename `var' `var'_temp
    ipolate `var'_temp t, gen(`var') epolate by(ij) 
}
*/

foreach var of varlist gr_ls gr_markup gr_lsmarkup gr_R gr_M gr_N gr_I gr_L gr_K gr_WLRK AAR gr_con{
    egen `var'_mean=mean(`var'), by(location sector)
    egen `var'_sd=sd(`var'), by(location sector)
    replace `var'=(`var'-`var'_mean)/`var'_sd if `var'!=.
}

save beforereg_oecd, replace 


use beforereg_oecd, clear 
keep if t>=2000
//keep if inlist(t,2001,2006,2010,2015)
//drop if gr_ls==.| gr_markup==.| gr_R==.| gr_M==.

//scatter gr_I gr_M

scatter gr_markup gr_con
eststo clear
est clear
*specification 1 
eststo spec1_right: rreg gr_ls gr_markup gr_R AAR gr_N i.country i.ind i.t, tune(8)    //!!!
estadd local markup "RHS"

eststo spec1_left: rreg gr_lsmarkup gr_R AAR gr_N i.country i.ind i.t, tune(8)   //!!!
estadd local markup "LHS"


*specification 2
eststo spec2_right: rreg gr_ls gr_markup gr_L gr_K AAR gr_N i.country i.ind i.t   //!!!
estadd local markup "RHS"
eststo spec2_left: rreg gr_lsmarkup gr_L gr_K AAR gr_N i.country i.ind i.t  //!!!
estadd local markup "LHS"

*specification 3
eststo spec3: rreg gr_WLRK gr_R AAR gr_N i.country i.ind i.t, tune(8)    //!!!

*specification 4
eststo spec4: rreg gr_WLRK gr_L gr_K AAR gr_N i.country i.ind i.t, tune(8)  //!!!

esttab * using "C:\Users\acube\Dropbox\Study\UC Davis\Writings\LaborShareKorea\Latex\maintable_rewinded_replicated.tex", ///
	title(Estimation Results \label{regression}) ///
    b(%9.3f) se(%9.3f) ///
	se nomtitles nocons noobs  replace scalars("markup") ///
	mgroups("Spec1" "Spec2" "Spec3" "Spec4", pattern(1 0 1 0 1 1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span}))








/*********************************************
Borowczyk et al (2013) // Accounting for endogeneity in matching function estimation
*********************************************/
* Implementation to my dataset. 

/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="D:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\211126"   
/*********************************************
*********************************************/

*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/u.csv", varnames(1) clear 
rename u ut
save ut, replace 
*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
merge m:1 t using ut, nogenerate
replace ym=t+695
format ym %tm
gen date = dofm(ym)
format date %d
*drop if t<25
gen month=month(date)
gen v=nume/numd
gen u=unemp/(unemp+numd)*uibadjust
gen theta=v/u
gen l=numd/(1-u)
gen jfr=ln(matched/u/l)
replace theta=ln(theta)
drop if _n==_N
drop if jfr==.
gen kk=0
keep t indmc jfr theta month k
save borow, replace 


/*
capture program drop select 
program define select
    args `indmc'
    use borow, clear 
    keep if indmc=`indmc'
    drop indmc 
    tsset t, monthly
    tab month, gen(m_)
    drop m_1
end
*/

cap program drop estim_grid1
program define estim_grid1
version 14
syntax [, INDMC(real 0) P(real 1) Q(real 1) ADDLAGSTH(integer 1) LAGSJFR(integer 1) BK(integer 1) PMAX(integer 1) SELECT(string) ETA0(real 1) GRAPH] 
	
    use borow, clear 
    keep if indmc==`indmc'
    *drop indmc 
    tsset t, monthly
    tab month, gen(m_)
    drop m_1

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
		local esteq "`esteq' - {b1}*bk1 - {b2}*bk2"
		forval l = 1/`p'	{
			local esteq "`esteq' + {rho`l'}*( {b1}*l`l'.bk1 + {b2}*l`l'.bk2 )"
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
				*/ note("") xlab(0(2)18) scheme(s1mono) 
							}
		}
	restore
end



*!start 
// Table 3
qui	{
local pmin = 1
local pmax = 5

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/5	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(10) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) bk(0) eta0(0.7)
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

matrix list results, format(%9.3g)
estim_grid1, indmc(10) p(2) q(7) pmax(2) addlagsth(0) lagsjfr(1) bk(0) eta0(0.7) graph




matain results
// p and q
mata rest=results[.,1],results[.,2]
// p-value for mu
mata z=abs(results[.,4]:/results[.,3])
mata rest1=2*normal(-abs(z))
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


mata rest=rest,rest1,rest2,rest3,rest4,rest5,rest6,rest7
mata rest 








cap program drop estim_grid
program define estim_grid
version 14
syntax [, INDMC(real 0) P(real 1) Q(real 1) ADDLAGSTH(integer 1) LAGSJFR(integer 1) BK(integer 1) PMAX(integer 1) SELECT(string) ETA0(real 1) GRAPH] 
	
    use borow, clear 
    keep if indmc==`indmc'
    *drop indmc 
    tsset t, monthly
    tab month, gen(m_)
    drop m_1

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
		local esteq "`esteq' - {b1}*bk1 - {b2}*bk2"
		forval l = 1/`p'	{
			local esteq "`esteq' + {rho`l'}*( {b1}*l`l'.bk1 + {b2}*l`l'.bk2 )"
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
				*/ note("") xlab(0(2)18) scheme(s1mono) 
							}
		}
	restore

    *gmm, coeflegend
    local k=_b[eta:_cons]
    use borow, clear 
    replace kk=`k' if indmc==`indmc'
    save borow, replace

end


foreach num of numlist 10(1)33{
*estim_grid, indmc(`num') p(10) q(10) pmax(10) addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
estim_grid, indmc(`num') p(5) q(5) pmax(5) addlagsth(0) lagsjfr(1) bk(0) eta0(0.5)
}

use borow, clear 
keep if t==25
keep indmc kk
save borowresult, replace 







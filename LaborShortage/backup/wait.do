cls
/*********************************************
*********************************************/
* NEED TO SET YOUR PREFERRED PATH
global path="D:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\211126"   
/*********************************************
*********************************************/

*!start
cd "${path}
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/LaborShortage/orig.csv", varnames(1) clear 
replace ym=t+695
format ym %tm
drop if t<17
gen date = dofm(ym)
format date %d
gen month=month(date)
gen v=nume/numd
gen u=unemp/(unemp+numd)
gen theta=v/u
gen l=numd/(1-u)
gen jfr=ln(matched/u/l)
replace theta=ln(theta)
drop if _n==_N
drop if jfr==.
gen kk=0
keep t indmc jfr theta month k
save borow, replace 



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
		matrix m[5,1] = 2*normal(-abs([eta]_b[_cons]/[eta]_se[_cons])) \ [eta]_b[_cons] 
		forv arp = 1/`p'	{
			/*
			local t = [rho`arp']_b[_cons] / [rho`arp']_se[_cons]
			matrix m[6 + 2*`arp'-1 ,1] = `t' \ [rho`arp']_b[_cons]
			*/			
			matrix m[6 + 2*`arp'-1 ,1] = 2*normal(-abs([rho`arp']_b[_cons]/[rho`arp']_se[_cons])) \ [rho`arp']_b[_cons] 
			
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
local pmax = 4

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/5	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(10) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=10
estim_grid1, indmc(10) p(4) q(6) pmax(4) addlagsth(0) lagsjfr(0) bk(0) eta0(0.5) graph



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
			estim_grid1, indmc(11) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=11
estim_grid1, indmc(11) p(5) q(7) pmax(5) addlagsth(0) lagsjfr(1) bk(0) eta0(0.5) graph


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
			estim_grid1, indmc(12) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=12
// drop if indmc==12 (담배제조업)

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
			estim_grid1, indmc(13) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=13
estim_grid1, indmc(13) p(5) q(6) pmax(5) addlagsth(0) lagsjfr(1) bk(0) eta0(0.5) graph


*!start 
// Table 3
qui	{
local pmin = 1
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/5	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(14) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(1) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=14
estim_grid1, indmc(14) p(3) q(4) pmax(3) addlagsth(0) lagsjfr(1) bk(0) eta0(0.5) graph


*!start 
// Table 3
qui	{
local pmin = 3
local pmax = 6

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/5	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(15) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=15


*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(16) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=16


*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(17) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=17


*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(18) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=18


*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(19) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=19



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(20) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=20



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(21) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=21



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(22) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=22



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(23) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=23



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(24) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=24



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(25) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=25



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(26) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=26



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(27) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=27



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(28) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=28



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(29) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=29



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(30) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=30



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(31) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=31




*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(32) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=32



*!start 
// Table 3
qui	{
local pmin = 5
local pmax = 7

matrix results = J(5 + 2*(`pmax'+2),1,.)
local rnames "p q sd(mu) mu sd(eta) eta"
noi di "--------------------------------------------------"
forv p = 1/`pmax'	{
	local rnames "`rnames' sd(rho`p') rho`p'"
	
	if `p'>=`pmin'	{
		forv q = 1/6	{
			noi di _con "(`p' , `q') -- "
			estim_grid1, indmc(33) p(`p') q(`q') pmax(`pmax') addlagsth(0) lagsjfr(0) bk(0) eta0(0.5)
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

matrix list results, format(%9.3g)  // indmc=33

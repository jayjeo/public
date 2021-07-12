
*-----------------------------------------------------------------------------
* This coding uses some ado files below:
net install Jay_ado.pkg, from(https://raw.githubusercontent.com/jayjeo/stata/master)

/*
To see contents of the Jay_ado.pkg:
https://github.com/jayjeo/stata

To completely uninstall Jay_ado.pkg:
ado uninstall Jay_ado
-----------------------------------------------------------------------------*/

/*** useful materials
http://blog.stata.com/2016/01/05/programming-an-estimation-command-in-stata-computing-ols-objects-in-mata/  
TRI = Colin Cameron, Pravin K. Trivedi, Microeconometrics: Methods and Applications. 2005

*/

clear all
use "https://raw.githubusercontent.com/jayjeo/public/master/GH210712_REGexercise/krueger_example.dta", clear
set matastrict on
version 14
tempfile original
save `original', replace


***** Take a look at missinv values.
//ssc install mdesc
keep schgroup pscore wa free sex totexpk cs sm 
mdesc
drop if totexpk==.

***** generate basic matrices
tabulate schgroup, generate(d)

mata: i=1
putmata d1
mata: D=d1
forvalues i=2(1)79 {
	putmata d`i'
	mata: D=D,d`i'
	}

putmata *, replace


*** OLS
mata
	Y=pscore
	n=rows(Y)

	X=wa, free, sex, totexpk, cs, J(n,1,1)
	XX=quadcross(X,X)
	XY=quadcross(X,Y)

	k=cols(X)

	b_ols=invsym(XX)*XY

	b_ols=invsym(XX)*(XY)
	e_ols=Y-X*b_ols
	e_ols_2=e_ols:*e_ols
	sigma2_ols=mean(e_ols_2)
	v_ols=n*invsym(n-k)*sigma2_ols*invsym(XX)
end

mata b_ols
mata sqrt(diagonal(v_ols))

reg pscore wa free sex totexpk cs

preserve  // To see what if missing rows had not been dropped.
	use `original', replace
	reg pscore wa free sex totexpk cs
restore 


*** Robust variance
mata
	//beta same
	D0=diag(e_ols_2)
	XD0X=quadcross(X,D0)*X
	v_ols_ro=n*invsym(n-k)*invsym(XX)*quadcross(X,e_ols_2,X)*invsym(XX) // This also works. 
	v_ols_ro=n*invsym(n-k)*invsym(XX)*quadcross(X,D0)*X*invsym(XX)  
end

mata XD0X
mata sqrt(diagonal(v_ols_ro))

reg pscore wa free sex totexpk cs, ro

preserve  // To see what if missing rows had not been dropped.
	use `original', replace
	reg pscore wa free sex totexpk cs, ro
restore 


*** Cluster variance // assuming small clusters, C goes to infinity. (TRI 834 (24.34))
sort schgroup
	scalar last = schgroup[_N]+1
	di last
	replace schgroup=last if missing(schgroup)
qui list schgroup
//ssc install moremata

mata
	//beta same
	info=panelsetup(schgroup,1)
	info
	nc=rows(info)
	
	SXX=J(k,k,0)
		for(i=1; i<=nc; i++){
			xi=panelsubmatrix(X,i,info)
			SXX=SXX+xi'*xi
		}

	SXuuX=J(k,k,0)
		for(i=1; i<=nc; i++){
			xi=panelsubmatrix(X,i,info)
			ui=panelsubmatrix(e_ols,i,info)
			SXuuX=SXuuX+xi'*(ui*ui')*xi
		}
	dfc=(n-1)/(n-k)*nc/(nc-1)
	v_ols_cl=dfc*invsym(SXX)*SXuuX*invsym(SXX)
end

mata sqrt(diagonal(v_ols_cl))
reg pscore wa free sex totexpk cs, vce(cluster schgroup)  

preserve  // To see what if missing rows had not been dropped.
	use `original', replace
	reg pscore wa free sex totexpk cs, vce(cluster schgroup)  
restore 



*-----------------------------------------------------------------------------
* This coding uses some ado files below:
net install Jay_ado.pkg, from(https://raw.githubusercontent.com/jayjeo/public/master/adofiles)

/*
To see contents of the Jay_ado.pkg:
https://github.com/jayjeo/stata

To completely uninstall Jay_ado.pkg:
ado uninstall Jay_ado
-----------------------------------------------------------------------------*/

/******** useful materials
http://blog.stata.com/2016/01/05/programming-an-estimation-command-in-stata-computing-ols-objects-in-mata/  
TRI = Colin Cameron, Pravin K. Trivedi, Microeconometrics: Methods and Applications. 2005

*/

*!start
clear all
use "https://raw.githubusercontent.com/jayjeo/public/master/GH210712_REGexercise/krueger_example.dta", clear
set matsize 11000, perm
set matastrict on
version 14
save original, replace


******** Take a look at missing values
//ssc install mdesc
keep schgroup pscore wa free sex totexpk cs sm classid
mdesc
drop if totexpk==.

sort schgroup
	scalar last = schgroup[_N]+1
	di last
	replace schgroup=last if missing(schgroup)
qui list schgroup
//ssc install moremata


******** generate basic matrices
tabulate schgroup, generate(d)
putmata *, replace

mata: D=d2
forvalues i=3(1)79 {
	mata: D=D,d`i'
	}  //d1 dropped.

foreach var in pscore wa free sex totexpk cs sm  {
	egen `var'm = mean(`var'), by(schgroup)
	putmata `var'm
	mata `var'd=`var'-`var'm
}


******** OLS
mata
	Y=pscore
	n=rows(Y)

	*X=wa, free, sex, totexpk, J(n,1,1), cs  // This order also works for even with IV
	*Z=wa, free, sex, totexpk, J(n,1,1), sm  // This order also works for even with IV
	X=cs, wa, free, sex, totexpk, J(n,1,1)   
	Z=sm, wa, free, sex, totexpk, J(n,1,1)

	XX=quadcross(X,X)
	ZZ=quadcross(Z,Z)
	XZ=quadcross(X,Z)
	ZX=quadcross(Z,X)
	XY=quadcross(X,Y)
	ZY=quadcross(Z,Y)

	k=cols(X)
		
	Yd=pscored
	Xd=csd, wad, freed, sexd, totexpkd

	b_ols=invsym(XX)*XY
	e_ols=Y-X*b_ols
	e_ols_2=e_ols:*e_ols
	sigma2_ols=mean(e_ols_2)
	v_ols=n*invsym(n-k)*sigma2_ols*invsym(XX)
end

mata b_ols
mata sqrt(diagonal(v_ols))

reg pscore cs wa free sex totexpk

preserve  // To see what if missing rows had not been dropped.
	use original, replace
	reg pscore cs wa free sex totexpk 
restore 

save default, replace
mata: mata matsave default *,replace
// use these files as default. From below, overwrite data if necessary



******** Robust variance
*!start
clear all
use default
mata: mata matuse default

mata
	//beta same as b_ols
	D0=diag(e_ols_2)
	XD0X=quadcross(X,D0)*X
	v_ols_ro=n*invsym(n-k)*invsym(XX)*quadcross(X,e_ols_2,X)*invsym(XX) // This also works. 
	v_ols_ro=n*invsym(n-k)*invsym(XX)*quadcross(X,D0)*X*invsym(XX)  
end

mata XD0X
mata sqrt(diagonal(v_ols_ro))

reg pscore cs wa free sex totexpk, ro

preserve  // To see what if missing rows had not been dropped.
	use original, replace
	reg pscore cs wa free sex totexpk, ro
restore 


******** Cluster variance 
* assuming small clusters, C goes to infinity. (TRI 834 (24.34))
*!start
clear all
use default
mata: mata matuse default

mata
	//beta same as b_ols
	info=panelsetup(schgroup,1)
	nc=rows(info)
	
	SXX=J(k,k,0)
	SXuuX=J(k,k,0)
		for(i=1; i<=nc; i++){
			xi=panelsubmatrix(X,i,info)
			ui=panelsubmatrix(e_ols,i,info)
			SXX=SXX+xi'*xi
			SXuuX=SXuuX+xi'*(ui*ui')*xi
		}

	dfc=(n-1)/(n-k)*nc/(nc-1)
	v_ols_cl=dfc*invsym(SXX)*SXuuX*invsym(SXX)
end

mata sqrt(diagonal(v_ols_cl))
reg pscore cs wa free sex totexpk, vce(cluster schgroup)  


******** TSLS 
* error independent and identical
*!start
clear all
use default
mata: mata matuse default

mata 
	fsb=invsym(ZZ)*(ZX)
	Xh=Z*fsb
	b_tsls=invsym(quadcross(Xh,Xh))*quadcross(Xh,Y)
	// v_tsls the same as v_ils
end

mata b_tsls

ivregress 2sls pscore (cs=sm) wa free sex totexpk 


******** ILS
* error independent and identical
*!start
clear all
use default
mata: mata matuse default

mata 
	b_ils=luinv(ZX)*ZY   // invsym does not work. Should use luinv instead.
	e_ils=Y-X*b_ils
	e_ils_2=e_ils:*e_ils
	sigma2_ils=mean(e_ils_2)
	v_ils=invsym(XZ*invsym(ZZ)*ZX)*sigma2_ils   // do not multiply n*invsym(n-k)
end

*mata invsym(ZX)
*mata luinv(ZX)

mata b_ils
mata sqrt(diagonal(v_ils))

ivregress 2sls pscore (cs=sm) wa free sex totexpk 


******** ILS
* error independent but not identical (robust)

mata 
	//beta same as b_ils.
	D0=diag(e_ils_2)
	ZD0Z=quadcross(Z,D0)*Z
	v_ils_ro=luinv(XZ*luinv(ZZ)*ZX)*(XZ*luinv(ZZ)*ZD0Z*luinv(ZZ)*ZX)*luinv(XZ*luinv(ZZ)*ZX)
      // do not multiply n*luinv(n-k)
end

mata sqrt(diagonal(v_ils_ro))

ivregress 2sls pscore (cs=sm) wa free sex totexpk, robust


******** ILS
* error not independent and not identical (dependent by school group)

mata
	//beta same as b_ils.
	info=panelsetup(schgroup,1)
	nc=rows(info)

	ZuuZ=J(k,k,0)
		for(i=1; i<=nc; i++){
			zi=panelsubmatrix(Z,i,info)
			ui=panelsubmatrix(e_ils,i,info)
			ZuuZ=ZuuZ+zi'*(ui*ui')*zi
		}
	v_ils_ro_cl=luinv(X'*Z*luinv(Z'*Z)*Z'*X)*(X'*Z*luinv(Z'*Z)*ZuuZ*luinv(Z'*Z)*Z'*X)*luinv(X'*Z*luinv(Z'*Z)*Z'*X) 
end

mata sqrt(diagonal(v_ils_ro_cl))

ivregress 2sls pscore (cs=sm) wa free sex totexpk, cluster(schgroup)


******** FE
*!start
clear all
use default
mata: mata matuse default

mata
	k=k-1   // Constant dropped from default.
	info=panelsetup(schgroup,1)
	nc=rows(info)

	XdXd=J(k,k,0)
	XdYd=J(k,1,0)
		for(i=1; i<=nc; i++){
			xdi=panelsubmatrix(Xd,i,info)
			ydi=panelsubmatrix(Yd,i,info)

			XdXd=XdXd+xdi'*xdi
			XdYd=XdYd+xdi'*ydi
		}

	b_fe=luinv(XdXd)*XdYd

	e_fe=Yd-Xd*b_fe
		
	XduuXd=J(k,k,0)
	eded=0
		for(i=1; i<=nc; i++){
			xdi=panelsubmatrix(Xd,i,info)
			ydi=panelsubmatrix(Yd,i,info)
			edi=ydi-xdi*b_fe
			XduuXd=XduuXd+xdi'*(edi*edi')*xdi
			eded=eded+edi'*edi
		}		

	XduuXd2=J(k,k,0)		// XduuXd2 is the same as XduuXd.
		for(i=1; i<=nc; i++){
			xdi=panelsubmatrix(Xd,i,info)
			udi=panelsubmatrix(e_fe,i,info)
			XduuXd2=XduuXd2+xdi'*(udi*udi')*xdi
		} 		

	SXX_fe=J(k,k,0)
	SXuuX_fe=J(k,k,0)
	for(i=1; i<=nc; i++){
		xdi=panelsubmatrix(Xd,i,info)
		udi=panelsubmatrix(e_fe,i,info)

		SXX_fe=SXX_fe+xdi'*xdi
		SXuuX_fe=SXuuX_fe+xdi'*(udi*udi')*xdi
	}

	dfc=1/(n-nc-k)
	dfc1=(n-1)/(n-nc-k)*nc/(nc-1)       
	dfc2=(n-1)/(n-1-k)*nc/(nc-1)
	dfc3=(n-1)/(n-k)*nc/(nc-1)

	v_fe=dfc*eded*luinv(XdXd)						     // homoskedasity estimator (BRUn_616 (17.36))
	v_fe_white=dfc*luinv(XdXd)*XduuXd*luinv(XdXd)        // White type robust estimator (BRU21_642 (17.56.b))
	v_fe_cl1=dfc1*luinv(SXX_fe)*SXuuX_fe*luinv(SXX_fe)   // FE cluster type robust estimator (BRUn_617 (17.40))
	v_fe_cl2=dfc2*luinv(SXX_fe)*SXuuX_fe*luinv(SXX_fe)   // xtreg fe robust result (Don't know what this is)
	v_fe_cl3=dfc3*luinv(SXX_fe)*SXuuX_fe*luinv(SXX_fe)   // Cluster robust estimator (non-FE version)
end

mata b_fe
mata sqrt(diagonal(v_fe))

xtset schgroup
xtreg pscore wa free sex totexpk cs, fe

mata sqrt(diagonal(v_fe_cl2))
xtreg pscore wa free sex totexpk cs, fe robust

areg pscore wa free sex totexpk cs, absorb(schgroup) vce(robust)

// Heteroskedasticity-Robust Estimation for Balanced and Unbalanced Case (BRU21_643 (17.58), (17.60))


******** FE TSLS
* error independent but not identical (robust)
* Fixed effect IV model. BRUn633 (17.69.b)
*!start
clear all
use default
mata: mata matuse default

mata
	I=I(n)
	M=I-D*luinv(D'*D)*D'
	b_iv_fe_ro=luinv(X'*M*Z*luinv(Z'M*Z)*Z'*M*X)*(X'*M*Z*luinv(Z'*M*Z)*Z'M*Y)

	MY=M*Y
	MX=M*X
	MZ=M*Z

	e_iv_fe_ro=MY-MX*b_iv_fe_ro

	info=panelsetup(schgroup,1)
	nc=rows(info)

	MZeeMZ=J(k,k,0)
		for(i=1; i<=nc; i++){
			mzi=panelsubmatrix(MZ,i,info)
			edi=panelsubmatrix(e_iv_fe_ro,i,info)

			MZeeMZ=MZeeMZ+mzi'*(edi*edi')*mzi
		}
	v_iv_fe_ro=luinv(MX'*MZ*luinv(MZ'*MZ)*MZ'*MX)*MX'*MZ*luinv(MZ'*MZ)*MZeeMZ*luinv(MZ'*MZ)*MZ'*MX*luinv(MX'*MZ*luinv(MZ'*MZ)*MZ'*MX)
									//  Cluster robust estimator (BRUn635)
	dfc3=(n-1)/(n-k)*nc/(nc-1)	
	v_iv_fe_ro3=dfc3*v_iv_fe_ro     //  xtivreg fe robust result
end

mata b_iv_fe_ro
mata sqrt(diagonal(v_iv_fe_ro3))

xtset schgroup
xtivreg pscore wa free sex totexpk (cs=sm), fe vce(robust)


******** MoM
*for ols and just-identified IV, MoM resulsts are identical to conventional ols and iv. 
*for ols there is no need to use GMM. 
*for over-identified IV,GMM is necessary. 

******** GMM
* Over-identified case. 
* The result varies by selection on weighting matirx, W. See TRI186 Table 6.2
* Here, focus on OGMM (TRI187)

*corr(cs wa free sex totexpk classid)
*bidensity cs wa, levels(10)
// make wa the second instrument, which should be not good IV. 

*!start
clear all
use default
mata: mata matuse default
	
mata	
	Y=pscore
	n=rows(Y)

	X=cs,     free, sex, totexpk, J(n,1,1)   
	Z=sm, wa, free, sex, totexpk, J(n,1,1)	  // over-identified case. 

	XX=quadcross(X,X)
	ZZ=quadcross(Z,Z)
	XZ=quadcross(X,Z)
	ZX=quadcross(Z,X)
	XY=quadcross(X,Y)
	ZY=quadcross(Z,Y)

	k=cols(X)
	l=cols(Z)

	b_2sls=luinv(X'*Z*luinv(Z'*Z)*Z'*X)*X'*Z*luinv(Z'*Z)*Z'*Y
	
	u_2sls=Y-X*b_2sls
	u_2sls2=u_2sls:*u_2sls
	D0=diag(u_2sls2)
	S=luinv(n)*Z'*D0*Z    // TRI185 (6.40)

	b_ogmm=luinv((X'*Z)*luinv(S)*(Z'*X))*((X'*Z)*luinv(S)*(Z'*Y))
			// TRI187 (6.43)

	u_ogmm=Y-X*b_ogmm
	u_ogmm2=u_ogmm:*u_ogmm
	D0_ogmm=diag(u_ogmm2)
	S_ogmm=luinv(n)*Z'*D0_ogmm*Z    // TRI185 (6.40)

	v_ogmm1=n*luinv(X'*Z*luinv(S)*Z'*X)
	v_ogmm2=n*luinv(X'*Z*luinv(S_ogmm)*Z'*X)     // ivregress gmm robust result. (TRI 187)
end

mata b_ogmm
mata sqrt(diagonal(v_ogmm1))
mata sqrt(diagonal(v_ogmm2))

ivregress gmm pscore free sex totexpk (cs=sm wa), robust first  



******** MLE (logit)
// use sm as dependent variable for practice purpose. 

*!start
clear all
use default
mata: mata matuse default

capture program drop mylogit
prog mylogit
	version 14
	args lnf theta1
	tempvar Logit
	local y "$ML_y1"
	gen double `Logit'=exp(`theta1')/(1+exp(`theta1'))
	qui replace `lnf' =`y'*ln(`Logit')+(1-`y')*ln(1-`Logit')
end

ml model lf mylogit (sm = cs wa free sex totexpk)
ml maximize

logit sm cs wa free sex totexpk
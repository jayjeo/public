******** FE (If data was a balanced panel)
// Heteroskedasticity-Robust Estimation for Balanced Case (BRU21_643 (17.58))
// Make arbitrary data set. Generate individual(ind) variable. 
*!start
clear all
use default

sort schgroup
gen ind=1
replace ind=ind[_n-1]+1 if schgroup==schgroup[_n-1]

putmata schgroup
mata 
	info=panelsetup(schgroup,1)
	infon=info[.,2]-info[.,1]+J(rows(info),1,1)
	T=min(infon)
	st_numscalar("T", T)
end
di T

drop if ind>T
//tsset schgroup ind

putmata pscore wa free sex totexpk cs sm schgroup, replace

foreach var in pscore wa free sex totexpk cs sm  {
	egen `var'mm = mean(`var'), by(schgroup)
	replace `var'd=`var'-`var'mm

	putmata `var'mm
	mata `var'd=`var'-`var'mm
}

mata
	Y=pscore
	n=rows(Y)
		
	Yd=pscored
	Xd=csd, wad, freed, sexd
	k=cols(Xd)
end


mata
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

	XdD0Xd=J(k,k,0)	
	XdS2Xd=J(k,k,0)		    
		for(i=1; i<=nc; i++){
			xdi=panelsubmatrix(Xd,i,info)
			ydi=panelsubmatrix(Yd,i,info)
			edi=ydi-xdi*b_fe
			ededi=edi:*edi
			D0i=diag(ededi)
			XdD0Xd=XdD0Xd+xdi'*D0i*xdi

			sigma2i=1*invsym(rows(ededi)-1)*colsum(ededi)  // BRU21_643 (17.59)
			XdS2Xd=XdS2Xd+xdi'*xdi*sigma2i

			eded`i'_check=ededi
		}		

	dfcw=n/(n-nc-k)
	dfcw2=n/(n-k)
	dfcw3=n/(n-nc-1)
	v_fe_white=dfcw*luinv(XdXd)*XdD0Xd*luinv(XdXd)        // White type robust estimator (BRU21_642 (17.56.b))
	v_fe_white2=dfcw2*luinv(XdXd)*XdD0Xd*luinv(XdXd)       // Without considering nc. This is not the correct dfc. 
	v_fe_white3=dfcw3*luinv(XdXd)*XdD0Xd*luinv(XdXd)       
	B_fe=luinv(XdXd)*XdS2Xd*luinv(XdXd)
	v_fe_stock=(T-1)*invsym(T-2)*v_fe_white-1*invsym(T-1)*B_fe         // Stock and Watson estimator (BRU21_643 (17.58))
	v_fe_stock3=(T-1)*invsym(T-2)*v_fe_white3-1*invsym(T-1)*B_fe
end

mata b_fe
mata diagonal(v_fe_stock)
//mata sqrt(diagonal(v_fe_stock))
// test





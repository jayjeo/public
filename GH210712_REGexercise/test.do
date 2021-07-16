****** Balanced panel data using formula (17.60)
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

gen n=_n

putmata schgroup ind n, replace 
mata 
	info=panelsetup(schgroup,1)
	Ti=info[.,2]-info[.,1]+J(rows(info),1,1)
	ijn=schgroup,ind,n
end

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
	e2=e_fe:*e_fe

	omega=J(k,k,0)
		for(i=1; i<=nc; i++){
			edi=panelsubmatrix(e_fe,i,info)
			ededi=edi:*edi
			sigma2i=1*invsym(rows(ededi)-1)*colsum(ededi)

			xdi=panelsubmatrix(Xd,i,info)

			for(j=1; j<=Ti[i]; j++){
				sel=select(ijn, ijn[.,1]:==i)
				sel=select(sel, sel[.,2]:==j) 
				ij=sel[.,3]
				Xdij=Xd[ij,.]
				e2ij=e2[ij,.]

				omega=omega+Xdij'*Xdij*((Ti[i]*e2ij-sigma2i)*invsym(Ti[i]-2))
			}
		}	
    dfcw=(n)/(n-2)
	v_fe_unbal=luinv(Xd'*Xd)*omega*luinv(Xd'*Xd)
end

mata b_fe
mata diagonal(v_fe_unbal)
//mata sqrt(diagonal(v_fe_unbal))





putmata pscore wa free sex totexpk cs sm schgroup, replace

foreach var in pscore wa free sex totexpk cs sm  {
	egen `var'mm = mean(`var'), by(schgroup)
	putmata `var'mm
	mata `var'd=`var'-`var'mm
}

mata
	Y=pscore
	n=rows(Y)

	*X=wa, free, sex, totexpk, J(n,1,1), cs  // This order also works for even with IV
	*Z=wa, free, sex, totexpk, J(n,1,1), sm  // This order also works for even with IV
	X=cs, wa, free, sex, totexpk, J(n,1,1)   

	XX=quadcross(X,X)
	XY=quadcross(X,Y)

	k=cols(X)
		
	Yd=pscored
	Xd=csd, wad, freed, sexd, totexpkd

end

// The same program as FE
// generate White type robust estimator (BRU21_642 (17.56.b))
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
	
	v_fe_white=dfc*luinv(XdXd)*XduuXd*luinv(XdXd)        // White type robust estimator (BRU21_642 (17.56.b))
end

mata b_fe
mata v_fe_white


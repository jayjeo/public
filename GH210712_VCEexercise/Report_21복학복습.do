
*-----------------------------------------------------------------------------
* This coding uses some ado files below:
net install Jay_ado.pkg, from(https://raw.githubusercontent.com/jayjeo/stata/master)

/*
To see contents of the Jay_ado.pkg:
https://github.com/jayjeo/stata

To completely uninstall Jay_ado.pkg:
ado uninstall Jay_ado
-----------------------------------------------------------------------------*/



/*-----------------------------------------------------------------------------
Krueger procedures
-----------------------------------------------------------------------------*/

/* create Krueger scaled scores */


/* reading score */
clear all
use webstar

keep if cltypek > 1 /* regular classes */
keep if treadssk ~= .
sort treadssk
gen pread0 = 100*_n/_N
egen pread = mean(pread0), by(treadssk)/* percentile score in reg. classes */
keep treadssk pread
sort pread    //tread typo? changed to pread
keep if pread ~= pread[_n-1] //tread typo? changed to pread
sort treadssk
save tempr, replace


/* math score */
clear all
use webstar

keep if cltypek > 1/* regular classes */
keep if tmathssk ~= .
sort tmathssk
gen pmath0 = 100*_n/_N
egen pmath = mean(pmath0), by(tmathssk)
keep tmathssk pmath
sort pmath //tmath typo? changed to pmath
keep if pmath ~= pmath[_n-1] //tmath typo? changed to pmath
sort tmathssk
save tempm, replace


/* merge percentile scores back on */
clear all
use webstar

keep if stark == 1
sort treadssk
merge treadssk using tempr
ipolate pread treadssk, gen(pr) epolate
drop _merge
sort tmathssk
merge tmathssk using tempm
ipolate pmath tmathssk, gen(pm) epolate
replace pm = 0 if pm < 0
drop _merge
egen pscore = rowmean(pr pm)
/* make class ids */
egen classid1 = group(schidkn cltypek)
egen cs1 = count(classid1), by(classid1)
egen classid2 = group(classid1 totexpk hdegk cladk) if cltypek==1 & cs1 >= 20   // cs typo?
egen classid3 = group(classid1 totexpk hdegk cladk) if cltypek>1 & cs1 >= 30    // cs typo?
/* Whether cs1 or cs (typo?) do no change much. 
Data saved to cs11.dta for the reference. (cs00(used cs) vs cs11(used cs1)) 
Changed to cs1.
*/
gen temp = classid1*100
egen classid = rowtotal(temp classid2 classid3)
egen cs = count(classid), by(classid)
gen female = ssex == 2
gen nwhite = srace >= 2 & srace <= 6 if srace ~= .
sort cs
keep if cs <= 27 & pscore ~= .
save master, replace




/*-----------------------------------------------------------------------------
Basic procedures
-----------------------------------------------------------------------------*/

clear all
version 14
path Home

*findit dmexogxt
//include krueger.do
cd "${path}\Study\UC Davis\2019 Fall\ECN230A_Public Economics\Problem Sets\HW3\Stata"
sysuse master, replace
*log using "log/191114.log", replace

include label.do


set more off
set matsize 11000, perm
set matastrict on


gen sex=female ==0 // 1=male 0=female
gen sm=cltypek==1 // 1=small class 0=else
gen aid=cltypek==3 // 1=regular with aide 0=else
gen wa=0  //1=white or asian 0=else
replace wa=1 if inlist(srace,1,3)
gen age=1985-sbirthy      // age in 1985
gen free=sesk==1 // 1=free lunch 0=not free lunch

qui label var wa "White|Asian"
qui label define wa_lab 0 "else" 1 "White|Asian"
qui label values wa wa_lab
 
qui label var cs "Class Size"
qui label var classid "Class ID"
qui label var schidkn "School ID"
qui label var newid "Individual ID"
qui label var pscore "Percentile Score"
qui label var free "FreeLunch"
qui label define free_lab 0 "NotFree" 1 "FreeLunch"
qui label values free free_lab


egen schgroup = group(schidkn)
qui label var schgroup "School ID"
sort schgroup    //data sorted by schgroup
by schgroup: egen totexpk_m= mean(totexpk)
by schgroup: egen totexpk_sd  = sd(totexpk)
by schgroup: gen  totexpk_std = (totexpk-totexpk_m)/totexpk_sd



** Q1 
do basic
     
/*-----------------------------------------------------------------------------

-----------------------------------------------------------------------------*/

/* ANS: */


/*-----------------------------------------------------------------------------
Qi. Did the random assignment work? 

(1)
Do a joint test that the variables nonwhite, female, and free lunch status 
(free=1), and total teacher experience (totexpk) are the same across 
the treatment and control groups. 
(2)
Krueger suggests that random assignment was only good within school. 
Are there any significant differences controlling for school dummies? 
(The id for school is schgroup.)
(3) 
What if you allow for arbitrary correlation within school also?
(4)
Does this make you worry about the experiment (1 paragraph max)
-----------------------------------------------------------------------------*/

/*
ANS: 

IMPORTANT NOTE: This data set is not a balanced panel. It is a cross sectional 
data. Meanwhile, if we think of School ID as i, and Class Size as t, then
thinking it as unbalanced panal is possible. However, it is very unbalanced
since Class Sizes in each school is sparsely distributed. Therefore, using 
the fixed effect model is possible but not appropriate. 
By the way, the standard OLS with School dummy and the standard fixed effect 
regression(FE) should yield the same result of coefficients and variances,
since those beta is same. Moreover, when used robust or clustering option, 
both OLS with School dummy and FE should yield the same coefficients, 
but the variances will be different. 

Small dummy (Small=1 Regular=0) is used as dependent variable,
where Regular includes both with and without aide.

Although the homework uses 'White=1, Non-white=0' as dummy, the paper uses 
'White or Asian (WA)=1, Else=0' as dummy. I use the latter for the entire answers.  

(1~3)
The assignment to small or regular class is not balanced when jointly examined. 
However, controlling the school dummy and error-term's correlation 
within school (Cluster), it is balnced jointly. 

(4)
As long as the analysis is done within the school with clustering
, then the finding using this sample is valid.

For the reference, TableII in the paper uses different method to test the balance.
I could not find exactly what it uses, but I tried to replicate it using ANOVA. 
*/
			
qui reg sm i.free i.wa i.sex totexpk
	mat pf=(Ftail(e(df_m), e(df_r), e(F)))
qui reg sm i.free i.wa i.sex totexpk i.schgroup
	mat pf=pf\(Ftail(e(df_m), e(df_r), e(F)))	
qui reg sm i.free i.wa i.sex totexpk, vce(cluster schgroup)   
	mat pf=pf\(Ftail(e(df_m), e(df_r), e(F)))	
// i.schogroup not used when clustering by schogroup

matrix rownames pf = OLS Dummy Dummy&Cluster 
matrix colnames pf = p-value
matlist pf, format(%9.4f) rowtitle(Varlist) title(Joint F-test)

anova totexpk i.cltypek i.schgroup

set graphics off
graph box totexpk, over(cltypek) saving(totexpk, replace) 
graph box totexpk_std, over(cltypek) saving(totexpk_std, replace) 

set graphics on
graph combine totexpk.gph totexpk_std.gph, ///
	imargin(0 0) ///
	ycommon xcommon altshrink ///
	title("TotalTeacherExp without and with standardizing by school")

qui anova free i.cltypek i.schgroup
	mat pvm1=(Ftail(e(df_1), e(df_r), e(F_1)))
qui anova wa i.cltypek i.schgroup
	mat pvm1=pvm1\(Ftail(e(df_1), e(df_r), e(F_1)))
qui anova age i.cltypek i.schgroup
	mat pvm1=pvm1\(Ftail(e(df_1), e(df_r), e(F_1)))
qui anova cs i.cltypek i.schgroup
	mat pvm1=pvm1\(Ftail(e(df_1), e(df_r), e(F_1)))	
qui anova pscore i.cltypek i.schgroup
	mat pvm1=pvm1\(Ftail(e(df_1), e(df_r), e(F_1)))
matrix rownames pvm1 = FreeLunch White|Asian Age ClassSize PScore 
matrix colnames pvm1 = p-value
matlist pvm1, format(%9.4f) rowtitle(Variables) title(Multi-factor Anova F-test)


/*-----------------------------------------------------------------------------
Qii. Use the regular class room sample. 
What is the effect of class size on the average percentile score here (pscore)? 
Is this large? Meaningful? (This is asking about the OLS regressions in the 
normal size classes.)
-----------------------------------------------------------------------------*/

/* 
ANS: it is reasonable to include covariates such as age, sex, and White|Asian
into the regression. The effects of ClassSize(CS) on PercentileScore(PScore)
are both -0.83 in OLS and Clustered (both used school dummy)
-0.83 means that when ClassSize increases by one PScore decreases by 0.83. 
(PScore is a ranking from 0 to 100, where 100 means the top rank) 
Not only the magnitude of the effect is small, but also the variance is large. 
Therefore the effect of CS to PScore is not meaningful. This is because the
analysis is done among the regular classes (with and without aide). 
*/ 

est clear
eststo clear

qui eststo ols: reg pscore cs aid free totexpk age sex wa i.schgroup if sm==0
qui eststo clu: reg pscore cs aid free totexpk age sex wa i.schgroup, vce(cluster schgroup), if sm==0

estout ols clu,  label replace ///
	prehead(Linear regression) ///
	varwidth(35) modelwidth(15) ///
	keep(cs aid free totexpk age sex wa) ///
	mlabels("OLS" "Clustered")  ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	stats(r2 N, labels(R-squared "N")) ///
	legend collabels(none) varlabels(_cons Constant free FreeLunch) ///
	postfoot("Constant coefficients not reported"  ///
			"Regression estimates reported with standard errors below in parenthesis.") 

/*-----------------------------------------------------------------------------
Qiii. Check that there is a first stage. 

(1)
First do this without any Xs in the model. 
(2)
Is the first stage strong using the rule of thumb number? Other values? 
(3)
What if you control for nonwhite, free and reduced price lunch, 
gender, and school dummies?
-----------------------------------------------------------------------------*/
/*
ANS:
(1)
The Hausman test cannot be not easily implented in Stata. Let me skip this part. 

"Heteroskedasticity-robust and cluster-robust subset endogeneity tests
 are not currently implemented in Stata. Instead, we can use the 
 regression approach if we account for the generated regressor problem.  
 ... A heteroskedasticity or  cluster-robust test cannot be constructed 
 easily by the Durbin-WuHausman approach, since the covariance matrix 
 does not take a simple form. ... The solution is to use the 
 control-function-robust covariance matrix estimator.
 (Bruce Hansen, ECONOMETRICS, 2019)"
 
(2)
The F statistic is 16422, which is bigger than 10. 
(3)
The F statistic is 1432, which is still bigger than 10. 
Therefore, the IV is not weak.
*/

est clear
eststo clear

* impossible to use the Hausman test
reg pscore cs i.schgroup
est sto reg
ivregress 2sls pscore i.schgroup (cs=sm)
est sto ivreg
hausman reg ivreg

* Weak IV test
reg cs sm
test sm

reg cs sm wa free sex i.schgroup, cluster(schgroup)
test sm

/*-----------------------------------------------------------------------------
Qiv. What does the reduced form look like without controls? With controls? 
Are smaller classes good for students?
-----------------------------------------------------------------------------*/
/*
ANS:
Yes, the smaller class has better score after controlling everything discussed 
above. Class size increase by one person reduces the ranking (0 worst, 100 best)
by 0.706. However, the manitude is relatively smaller than other covariates,
such as White|Asian(+9.5), FreeLunch(-13.1), or Sex(-4.5). (male=1, female=0) 
*/


do basic

xtset schgroup
xtivreg pscore wa free sex totexpk (cs=sm), fe
mat feB=e(b)'
mat feV=vecdiag(e(V))'
mat feBcut = feB[1..5,1]
mat feVcut = feV[1..5,1]
matain feBcut

set more off
set matsize 11000, perm
set matastrict on

est clear
eststo clear

qui eststo iv: ivregress 2sls pscore wa free sex totexpk i.schgroup (cs=sm)
mat ivB=e(b)'
mat ivV=vecdiag(e(V))'

qui eststo ivro: ivregress 2sls pscore wa free sex totexpk i.schgroup (cs=sm), vce(robust)
mat ivroB=e(b)'
mat ivroV=vecdiag(e(V))'

qui eststo ivcl: ivregress 2sls pscore wa free sex totexpk i.schgroup (cs=sm), cluster(schgroup)
mat ivclB=e(b)'
mat ivclV=vecdiag(e(V))'


estout *,  label replace ///
	prehead(Linear regression) ///
	varwidth(35) modelwidth(15) ///
	keep(cs wa free sex totexpk) ///
	mlabels("IV" "IV Robust" "IV Cluster")  ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	stats(r2 N, labels(R-squared "N")) ///
	legend collabels(none) varlabels(_cons Constant free FreeLunch) ///
	postfoot("Constant coefficients not reported"  ///
			"Regression estimates reported with standard errors below in parenthesis.") 

/*-----------------------------------------------------------------------------
Qv.  What is the Wald estimator?
-----------------------------------------------------------------------------
ANS:
The Wald estimator is equivalent to the coefficient of endogenous variable
of IV regression with constant and without other covariates. Therefore, it is
-0.63.
*/

ivregress 2sls pscore (cs=sm)



/*-----------------------------------------------------------------------------
Qvi. Do two stage least squares by hand with the controls. 
(1)
Check you get the same thing with canned 2SLS. 
(2)
Do inference assuming no heterogeneous effects. 
(3)
(Extra credit, do your own adjustment to the errors. )
-----------------------------------------------------------------------------
ANS:
(1)
Table# shows that the results are exactly same. (xtivreg, fe vce(cluster schgroup))
beta estimators of the clustered FE and the ordinary FE should be same. 
Whether or not pluggin in constant on X and Z matrix does not affect the result. 
Constant should be zero in the fixed effect model, but I could not figure out 
why Stata xtreg output has constant=65.50
21 out of 5743 observations failed to impute totexpk for unknown reason.
Those 21 obs were dropped when calculationg by hand. 
 
(2)
Assuming, within and between schools,
individual errors are independent and identical(homoskedasity) 
the variance of beta is a simplest estimator under 2SLS FE. 
(xtivreg, fe)

(3)
Assuming, within and between schools,
individual errors are independent but not identical(heteroskedasity)
the variance of beta 

(xtivreg, fe vce(robust))
Note that the Hinkley-White(Sandwich) estimator under 2SLS 
is not accurate at all. In other words, FE Robust result and 
By Hand(Sandwich) result are far from similar.  
This huge biasedness is because the data is 
unbalanced panel. Individual(i) and Time(t) in the standard panel
correstponds to as SchoolID(i) and individual(t) in the dataset.  
*/


est clear
eststo clear

qui eststo g1: reg pscore wa free sex totexpk cs
qui eststo g2: reg pscore wa free sex totexpk cs, vce(cluster schgroup)  
qui eststo g3: reg pscore wa free sex totexpk cs i.schgroup
qui eststo g4: reg pscore wa free sex totexpk cs i.schgroup, vce(cluster schgroup)  

estout g1 g2 g3 g4,  label replace ///
	prehead(Linear regression) ///
	varwidth(35) modelwidth(15) ///
	keep(wa free sex totexpk cs) ///
	mlabels("(No dummy)OLS" "(No dummy)Clust" "OLS" "Cluster")  ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	stats(r2 N, labels(R-squared "N")) ///
	legend collabels(none) varlabels(_cons Constant free FreeLunch) ///
	postfoot("Constant coefficients not reported"  ///
			"Regression estimates reported with standard errors below in parenthesis.") 

			
*=================
* From here, the procedure uses mata, instead of Stata matrix. 
* mata is more convenient. 
*=================			
			
reg pscore cs wa free sex totexpk i.schgroup
mat regB=e(b)'
mat regV=vecdiag(e(V))'

*-------------- program rowchange 
capture program drop rch1
program define rch1
	args in out
	mata: `in' = st_matrix("`in'")
	mata: `out' = (`in'[5,1])\(`in'[1,1])\(`in'[2,1])\(`in'[3,1])\(`in'[4,1])\(`in'[6,1])
	mata: `out'
	mata: st_matrix("`out'",`out')
end
*--------------

rch1 regB regB
rch1 regV regV

matain regB
matain regV
matain ivB
matain ivV
matain ivroB
matain ivroV
matain ivclB
matain ivclV

mata: regBcut=regB[1::5,.]
mata: regVcut=regV[1::5,.]
mata: ivBcut=ivB[1::5,.]
mata: ivVcut=ivV[1::5,.]
mata: ivroBcut=ivroB[1::5,.]
mata: ivroVcut=ivroV[1::5,.]
mata: ivclBcut=ivclB[1::5,.]
mata: ivclVcut=ivclV[1::5,.]

gen exclude=0
replace exclude=1 if totexpk==.
sort exclude schgroup
gen order=_n   
by exclude schgroup (order), sort: gen start=_n==1
by exclude schgroup (order), sort: gen end=_n==_N
egen schgroupsize = count(schgroup), by(exclude schgroup)
* keep if start==1
* egen test = sum(schgroupsize) if exclude==0


//generate school dummies
// d79 dropped. Total schools are 79.
tabulate schgroup, generate(d)

mata: i=1
putmata d1
mata: D=d1
forvalues i=2(1)79 {
	putmata d`i'
	mata: D=D,d`i'
}

* order *, sequential
* ssc install ftools 
* ssc install matsave

set matastrict on
putmata *, replace

save tempsave, replace
mata: mata matsave tempsave *,replace










clear all
use tempsave
set matastrict on
set more off, perm
mata: mata matuse tempsave

mata: miss=sum(rowmissing(totexpk))
mata: miss



* ---------------------------------------------------
* Delete obs if tempvar is missing
* ---------------------------------------------------

*---- program rowdelete if totexpk==.
capture program drop rowdel
program rowdel
	args C
	mata: totexpk2=totexpk
	mata: tempvar=(totexpk2, `C')
	mata: `C'=select(tempvar[.,2], tempvar[.,1]:~=.)
end
*----
rowdel pscore
rowdel cs
rowdel sm
rowdel wa
rowdel free
rowdel sex

*---- program rowdelete if totexpk==. for D
capture program drop rowdelD
program rowdelD
	args C
	mata: totexpk2=totexpk
	mata: tempvar=(totexpk2, `C')
	mata: `C'=select(tempvar[.,2..80], tempvar[.,1]:~=.)
end
*----
rowdelD D
* mata: D=D[.,1..78]  // drop d1 (first colunm)  // Do not use.
mata: cols(D)


forvalues i=1(1)79 {
	rowdel d`i'
	}
	
rowdel totexpk  // should not be done before d`i'
*--------------------------------------------------- 




mata
	// gen total number obs. (n=it)
	n=rows(cs)
	// gen classsize(t) for each school(i). 
	start_schgroup_schgroupsize= (start,schgroup,schgroupsize)
	Ti=select(start_schgroup_schgroupsize[.,3], start_schgroup_schgroupsize[.,1]:==1)
	Ti=Ti[1..79] // drop row 80 since it is totexpk= missing
	rows(Ti)  // Total number of schools is 79
	// gen 1 vector (small L)
	l=J(rows(cs),1,1)

	Y=pscore 
	X=  cs, wa, free, sex, totexpk, D  //D is full. constant should not exist.
	Z=  sm, wa, free, sex, totexpk, D  //D is full. constant should not exist.
	k=cols(X)

	XX=quadcross(X,X)
	ZZ=quadcross(Z,Z)
	XZ=quadcross(X,Z)
	ZX=quadcross(Z,X)
	XY=quadcross(X,Y)
	ZY=quadcross(Z,Y)
end


************
* OLS (school dummy)
************

mata
	regb=luinv(XX)*(XY)
	rege=Y-X*regb
	rege2=rege:*rege
	regsigma2=mean(rege2)
	regv=n*luinv(n-k)*regsigma2*luinv(XX)
	
	
	regbcut=regb[(5,1,2,3,4)]
	regv=diagonal(regv)
	regvcut=regv[(5,1,2,3,4)]
end

mataout regbcut
mat list regbcut	// small letter by hand. (dummy cut) 
mataout regBcut		
mat list regBcut   	// big letter by Stata. 


mataout regvcut
mat list regvcut   
mataout regVcut
mat list regVcut  

************
* TSLS (school dummy)
* error independent and identical
************

mata 
	fsb=luinv(ZZ)*(ZX)
	Xh=Z*fsb
	tsb=luinv(quadcross(Xh,Xh))*quadcross(Xh,Y)
end
mata: tsbcut=tsb[1::5,.]
mataout tsbcut
mat list tsbcut     // small letter by hand. (dummy cut)



************
* ILS (school dummy)
* error independent and identical
************
mata 
	ivb=luinv(ZX)*(ZY)
	ive=Y-X*ivb
	ive2=ive:*ive
	ivsigma2=mean(ive2)
	ivv=luinv(XZ*luinv(ZZ)*ZX)*ivsigma2   // do not multiply n*luinv(n-k)

	ivbcut=ivb[1::5,.]
	ivv=diagonal(ivv)
	ivvcut=ivv[1::5,.]
end
mata: ivb

mata: ivbcut
mataout ivbcut
mat list ivbcut     // small letter by hand. (dummy cut)
mataout ivBcut 
mat list ivBcut     // big letter by Stata.

mataout ivvcut
mat list ivvcut     
mataout ivVcut
mat list ivVcut  


************
* ILS (school dummy)
* error independent but not identical (robust)
************
mata 
	//beta same.
	D0=diag(ive2)
	ZD0Z=quadcross(Z,D0)*Z
	ivrov=luinv(XZ*luinv(ZZ)*ZX)*(XZ*luinv(ZZ)*ZD0Z*luinv(ZZ)*ZX)*luinv(XZ*luinv(ZZ)*ZX)
      // do not multiply n*luinv(n-k)
	ivrobcut=ivb[1::5,.]
	ivrov=diagonal(ivrov)
	ivrovcut=ivrov[1::5,.]
end

mataout ivrobcut
mat list ivrobcut     // small letter by hand. (dummy cut)
mataout ivroBcut 
mat list ivroBcut     // big letter by Stata.

mata ivroVcut
mataout ivrovcut
mat list ivrovcut     
mataout ivroVcut
mat list ivroVcut  

************
* ILS (school dummy)
* error not independent and not identical (dependent by school group)
* ivregress 2sls, cluster(schgroup)
************


**** Partition by School group.

capture program drop rowpart
program rowpart 
	args varname
	mata: p=1
	mata: q=Ti[1]
	mata: T2=Ti \ 0
	mata: test= 0,0
	forvalues i=1(1)79 {
		mata: test=test \ p,q
		mata: tempvar=`varname'[p..q,.]
		mata: mata rename tempvar `varname'`i'
		mata: p=p+T2[`i']
		mata: q=q+T2[`++i']
	}
end

rowpart Z
rowpart X
rowpart Y
rowpart D
mata e=ive
rowpart e

forvalues i=1(1)79 {
	mata: S`i'=Z`i''*e`i'*e`i''*Z`i' 
}

mata: S=J(rows(S1),cols(S1),0)
forvalues i=1(1)79 {
	mata: S=S+S`i'
}


mata: ivclv=luinv(X'*Z*luinv(Z'*Z)*Z'*X)*(X'*Z*luinv(Z'*Z)*S*luinv(Z'*Z)*Z'*X)*luinv(X'*Z*luinv(Z'*Z)*Z'*X) 
mata: ivclv=diagonal(ivclv)
mata: ivclvcut=ivclv[1..5,.]
mata: ivclvcut


****************************
* For models which use D separately.

mata
	Y=pscore 
	X=  cs, wa, free, sex, totexpk   //D is excluded. Will use D separately.
	Z=  sm, wa, free, sex, totexpk   //D is excluded. Will use D separately.
	k=cols(X)

	XX=quadcross(X,X)
	ZZ=quadcross(Z,Z)
	XZ=quadcross(X,Z)
	ZX=quadcross(Z,X)
	XY=quadcross(X,Y)
	ZY=quadcross(Z,Y)
end

************
* FE TSLS (school dummy)
* error independent but not identical (robust)
* Fixed effect model IV. Bruce Hansen(2019) p633
************
mata
	n=rows(X)
	I=I(n)
	M=I-D*luinv(D'*D)*D'
	feb=luinv(X'*M*Z*luinv(Z'M*Z)*Z'*M*X)*(X'*M*Z*luinv(Z'*M*Z)*Z'M*Y)
	febcut=feb[1::5,.]
end


mataout febcut
mat list febcut     // small letter by hand. (dummy cut)




*********************************************
/**** Table generate
*** For general except the Fixed Effect model. 
	Y=pscore 
	X=  cs, wa, free, sex, totexpk, D   //D is full. constant should not exist.
	Z=  sm, wa, free, sex, totexpk, D   //D is full. constant should not exist.
*** For Fixed Effect model.
	Y=pscore 
	X=  cs, wa, free, sex, totexpk   //D is excluded. Will use D separately.
	Z=  sm, wa, free, sex, totexpk   //D is excluded. Will use D separately.
*/

ivreg pscore wa free sex totexpk d1-d79 (cs=sm), nocons
mat ivregB=e(b)'
mat ivregV=vecdiag(e(V))'
mat ivregBcut = ivregB[1..5,1]
mat ivregVcut = ivregV[1..5,1]

// reg pscore cs wa free sex totexpk i.schgroup
// invsym(XX)*(XY)    (School dummy included in X)
mat table=regBcut, regbcut
matrix rownames table = ClassSize White|Asian FreeLunch Sex TeachExperience
matrix colnames table = "OLS Stata" "OLS Hand"
matlist table, format(%9.4f) rowtitle(Variables) title(Coefficients) border(rows) twidth(20)



// ILS Stata:  ivreg pscore wa free sex totexpk d1-d78 (cs=sm), nocons
// TSLS Stata: ivregress 2sls pscore wa free sex totexpk i.schgroup (cs=sm)
// FE Stata:   xtivreg pscore wa free sex totexpk (cs=sm), fe    (xtset schgroup)
// ILS Hand:   invsym(ZX)*(ZY)    (School dummy included in X)
// TSLS Hand:  invsym(quadcross(Xh,Xh))*quadcross(Xh,Y) where Xh is Xhat
// FE Hand:    invsym(X'*M*Z*invsym(Z'M*Z)*Z'*M*X)*(X'*M*Z*invsym(Z'*M*Z)*Z'M*Y)   
//				(School dummy included in X and Z)

mataout ivBcut
mataout feBcut

mat table=ivregBcut, ivBcut, feBcut
matrix rownames table = ClassSize White|Asian FreeLunch Sex TeachExperience
matrix colnames table = "ILS" "TSLS" "FE"
matlist table, format(%9.4f) rowtitle(Variables) title(Stata Result) border(rows) twidth(20)


mat table=ivbcut, tsbcut, febcut
matrix rownames table = ClassSize White|Asian FreeLunch Sex TeachExperience
matrix colnames table = "ILS" "TSLS" "FE"
matlist table, format(%9.4f) rowtitle(Variables) title(Hand Result) border(rows) twidth(20)

mataout ivVcut
mataout ivroVcut
mataout ivclVcut

mataout ivvcut
mataout ivrovcut
mataout ivclvcut
 

mat table=ivVcut, ivroVcut, ivclVcut
matrix rownames table = ClassSize White|Asian FreeLunch Sex TeachExperience
matrix colnames table = "TSLS" "Robust" "Cluster"
matlist table, format(%9.4f) rowtitle(Variables) title(Stata Result of TSLS) border(rows) twidth(20)

mat table=ivvcut, ivrovcut, ivclvcut
matrix rownames table = ClassSize White|Asian FreeLunch Sex TeachExperience
matrix colnames table = "TSLS" "Robust" "Cluster"
matlist table, format(%9.4f) rowtitle(Variables) title(Hand Result of TSLS) border(rows) twidth(20)



/*-----------------------------------------------------------------------------
Qvii. What if you fail to include the Xs in the first stage? 
Why might this not change the estimates here?
-----------------------------------------------------------------------------
ANS:
Common variables in X and Z yields coefficients with 1. 
Specifically, the coefficient matrix in the first stage
has submatrix of Identity matrix. 
*/

mata
	X=  cs
	Z=  sm, wa, free, sex, totexpk, D  //D is full. constant should not exist.
	k=cols(X)
	fsb_omit=luinv(Z'*Z)*(Z'*X)
	Xh_omit=Z*fsb_omit
	Xo= wa, free, sex, totexpk, D
	Xf= Xh_omit, Xo     // second stage should include covariates. 
	tsb_omit=luinv(quadcross(Xf,Xf))*quadcross(Xf,Y)
end

mata tsb_omit
mata: tsbcut_omit=tsb_omit[1::5,.]
mataout tsbcut_omit
mat list tsbcut_omit     // small letter by hand. (dummy cut)

mat table=tsbcut, tsbcut_omit
matrix rownames table = ClassSize White|Asian FreeLunch Sex TeachExperience
matrix colnames table = "TSLS" "TSLS Omit"
matlist table, format(%9.4f) rowtitle(Variables) title(Hand Result) border(rows) twidth(20)


mata
	Y=pscore 
	X=  cs, wa, free, sex, totexpk, D  //D is full. constant should not exist.
	Z=  sm, wa, free, sex, totexpk, D  //D is full. constant should not exist.
	XX=quadcross(X,X)
	ZZ=quadcross(Z,Z)
	XZ=quadcross(X,Z)
	ZX=quadcross(Z,X)
	XY=quadcross(X,Y)
	ZY=quadcross(Z,Y)
	
	fsb=luinv(ZZ)*(ZX)
	fsb_change=edittozero(fsb, 10000)
	fsb_change
end


putmata *, replace
save tempsave2, replace
mata: mata matsave tempsave2 *,replace


clear all
use tempsave2
mata: mata matuse tempsave2


/*-----------------------------------------------------------------------------
Qx. 
Now instead you decide to take classroom means 
and get the IV estimates using them (a la Donald and Lang). 
Does this change your conclusion?
-----------------------------------------------------------------------------
ANS:
*/
drop if totexpk==.

sort schgroup
replace order=_n   
by schgroup (order), sort: replace start=_n==1
by schgroup (order), sort: replace end=_n==_N
egen schgroupsize2 = count(schgroup), by(schgroup)

foreach var in pscore cs sm wa free sex totexpk  {
egen `var'_mean = mean(`var'), by(schgroup)
}

keep if start==1

ivregress 2sls pscore_mean (cs_mean=sm_mean) wa_mean free_mean sex_mean totexpk_mean 
mat dlB=e(b)'
mat dlV=e(V)'
mat dlBcut=dlB[1..5,1]
mat dlV=vecdiag(dlV)'
mat dlVcut=dlV[1..5,1]
matlist dlVcut

mataout ivBcut
mataout ivclVcut

mat table=ivBcut, dlBcut
matrix rownames table = ClassSize White|Asian FreeLunch Sex TeachExperience
matrix colnames table = "TSLS" "Donald Lang"
matlist table, format(%9.4f) rowtitle(Variables) title(Stata Result of TSLS) border(rows) twidth(20)

mat table=ivclVcut, dlVcut
matrix rownames table = ClassSize White|Asian FreeLunch Sex TeachExperience
matrix colnames table = "TSLS" "Donald Lang"
matlist table, format(%9.4f) rowtitle(Variables) title(Stata Result of TSLS) border(rows) twidth(20)





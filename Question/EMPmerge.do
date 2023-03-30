use master, clear
keep year sector location valueEMP oecd_EMP
replace oecd_EMP=. if oecd_EMP==0
egen ij=group(location sector)
egen ind=group(sector)
egen country=group(location)
constraint 1 valueEMP ==1000
cnsreg oecd_EMP valueEMP i.ind i.country, constraint(1)
predict oecd_EMP_from_KLEMS, xb
/*
keep if location=="ESP"  // check manually all countries. All match really well. 
xtset ind year
xtline oecd_EMP oecd_EMP_from_KLEMS
*/
replace oecd_EMP=oecd_EMP_from_KLEMS if oecd_EMP==.
keep year sector location oecd_EMP
save EMPmerge, replace 

use master, clear
merge 1:1 year sector location using EMPmerge, nogenerate
save master_afterEMPmerge, replace 




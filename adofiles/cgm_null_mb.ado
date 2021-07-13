#delimit ;
prog def cgm_null_mb, rclass ;
* code up cgm algorithm to be slightly more general;
* hypothesis here must be a simple one (coefficient of rhstest = \beta_k,0);
*   meanings of options;
* lhs- left hand side variable;
* estmator - regression command (reg, probit, etc.);
* hypoth - value beta_k for hypothesis <rhstest>==beta_k;
* rhstest- name of RHS variable we are doing testing for;
* clust - name of cluter variable;
* bootreps - number of bootstrap reps;
* wgt- type of weight for wild bootstrap, rademacher or mammen;

syntax varlist  [if] [in] [aweight fweight pweight iweight] , lhs(string) estmator(string) hypoth(string) rhstest(string) clust(string) bootreps(string) wgt(string);

* save data;
preserve;



* drop unused observations;
tempvar use;
quietly mark `use' `if' `in';
drop if `use' !=1;


if "`weight'"=="0" {;
	tempvar exp;
	local `exp'=1;
	local `weight'= "pweight";
	};

di "`wgt' is weight";
* temporary files;
tempfile main bootsave;
* temporary name for bootsave;
tempname bskeep;

tempvar yhatres yhatunr epshatres epshatunr lhsres;

* create lhs for restricted regression, imposing the null;
qui gen double `lhsres' = `lhs' - `hypoth' * `rhstest';
* run restricted regression;
qui `estmator' `lhsres' `varlist' `if' [`weight'`exp'], cluster(`clust');
* get restricted residuals, yhat;
qui predict `epshatres', resid;
qui predict `yhatres', xb;
qui replace `yhatres' = `yhatres' + `hypoth' * `rhstest';


* rerun unrestricted regression;

noi `estmator' `lhs' `rhstest' `varlist' `if' [`weight'`exp'], cluster(`clust');
** get unrestricted residuals, yhat;
qui predict `epshatunr', resid;
qui predict `yhatunr', xb;

qui sort `clust' `varlist';
* save data;
qui save `main', replace;

tempvar mainbeta maint;
*** after running unrestricted regression;
local mainbeta  = _b["`rhstest'"];
*** Main t imposes hypothesis;
local maint  = (_b[`rhstest'] - `hypoth')/_se[`rhstest'];

cap erase `bootsave';
cap postclose `bskeep';
postfile `bskeep' t_wildres t_wildunr
	using `bootsave', replace;
** bootstrap loop;
forvalues bsnum = 1/ `bootreps' { ;
	qui use `main', replace ;
	tempvar  tmp1 reswgt wildresidres wildresidunr wildyres wildyunr bst_wildunr bst_wildres prob val;
	* get weights;
	if "`wgt'" == "rademacher" {;
		qui bysort `clust' : gen double `tmp1' = uniform() if _n==1;
		qui replace `tmp1' = 1 * (`tmp1'<= 0.5) + -1* (`tmp1'>0.5);
		qui egen `reswgt' = max(`tmp1'), by(`clust');
		};
	else if "`wgt'" =="liunormal" {;
		local wmean = (1/2)*(sqrt(17/6) + sqrt(1/6))
		local zmean = (1/2)*(sqrt(17/6) - sqrt(1/6))
	        qui bysort `clust': gen double `w'= sqrt(1/2)* invnormal(uniform()) + `wmean' if _n==1
	        qui bysort `clust': gen double `z'= sqrt(1/2)* invnormal(uniform()) + `zmean' if _n==1
		qui bysort `clust' : gen double `dummy' = `w'*`z' - `wmean'*`zmean' if _n==1
		qui egen `reswgt' = max(`tmp1'), by(`clust');
		};
	else if "`wgt'" =="mammen" {;
	        qui gen double `prob'= (1 +5^.5) /(2*5^.5);
		qui gen double `val' = (1-5^.5)/2;
		qui bysort `clust' : gen double `tmp1' = uniform() if _n==1;
		qui replace `tmp1' = `val' * (`tmp1'<`prob') + (1-`val')* (`tmp1'>=`prob') if `tmp1'<.;
		qui egen `reswgt' = max(`tmp1'), by(`clust');
		};


	* for debugging, set wildresid to be epshatunr;
	* gen `wildresid' = `epshatunr';
	*** Unrestricted;
	qui gen `wildresidunr' = `epshatunr' * `reswgt';
	* next line for debugging;
	*list `wildresidunr' `epshatunr' `reswgt' year ;
	** unrestricted wild y, no null imposed;
	qui gen `wildyunr' = `yhatunr' + `wildresidunr' ;
	* di " unrestricted regression with wildbootstrap";
	qui `estmator' `wildyunr' `varlist' `rhstest' `if' `in' [`weight'`exp'], cluster(`clust') ;
*	di "main beta `mainbeta'" ;
	local bst_wildunr = (_b[`rhstest'] - `mainbeta') / _se[`rhstest'] ;

	* for debugging, set wildresid to be epshatres;
	* gen `wildresid' = `epshatres';
	*** Restricted;
	qui gen `wildresidres' = `epshatres' * `reswgt';
	* next line for debugging;
	*list `wildresidres' `epshatres' `reswgt' year ;
	** resestricted wild y, null imposed;
	qui gen `wildyres' = `yhatres' + `wildresidres' ;
	* di " restricted regression with wildbootstrap";
	qui `estmator' `wildyres' `varlist' `rhstest' `if' `in' [`weight'`exp'], cluster(`clust') ;
*	di "main beta `mainbeta'" ;
	local bst_wildres = (_b[`rhstest'] - `hypoth') / _se[`rhstest'] ;


	* next line for debugging;	
*	di "Unrestricted bst_wild is `bst_wildunr'";
*	di "Restricted bst_wild is `bst_wildres'";
	post `bskeep' (`bst_wildunr') (`bst_wildres');
	};
postclose `bskeep';

* add in real data;
qui use `bootsave' , replace ;
keep if _n==1 ;
gen realdata=1;
replace t_wildunr = .;
replace t_wildres = .;
qui append using `bootsave';
replace t_wildunr = `maint' if t_wildunr==.;
replace t_wildres = `maint' if t_wildres==.;
replace realdata=0 if realdata==.;
tempvar n bign mypres mypunr pctile_twildres pctile_twildunr mainp pctile_main;

* n for figuring where real data is;
qui gen `n'=.;
* summarize to get number of bootstraps + 1;
qui sum t_wildres;
qui gen `bign' = r(N);

* sort by t;
sort t_wildres;

qui replace `n'=_n;
* get number for where t_wild is real data one;
qui summ `n' if abs(t_wildres - `maint') < 0.000001;
* my p is that divided by total N;
gen `mypres' = r(mean)/`bign';
* percentile twild p-value is 2 * min(myp, 1-myp);
gen `pctile_twildres' = 2 * min(`mypres',(1-`mypres'));

* sort by t;
sort t_wildunr;

qui replace `n'=_n;
* get number for where t_wild is real data one;
qui summ `n' if abs(t_wildunr - `maint') < 0.000001;

* my p is that divided by total N;
gen `mypunr' = r(mean)/`bign';
* percentile twild p-value is 2 * min(myp, 1-myp);
gen `pctile_twildunr' = 2 * min(`mypunr',(1-`mypunr'));


* normal p;
gen `mainp' = normal(`maint');
* main p-value;
gen `pctile_main' = 2 *min(`mainp', (1-`mainp'));


local myfmt = "%12.3f" ;
local myfmt2 = "%6.3f" ;
di ; 
di "Ran regression `estmator' `lhs' `lhs' `varlist' `rhstest' `if' `in' [`weight'`exp'], cluster(`clust') ";
di "bootstrapping done imposing null, with `wgt' weights";
di "";
di "Number BS reps = `bootreps' Null hypothesis = _b[`rhstest']==`hypoth'" ;
di "";
display "Main beta" _column(15) "Main T" ;
di     %12.3f `mainbeta' _column (15) %8.5f `maint' _column(23);
di "";
di  "Percentile main p-value " _column(15) "Restricted wild Bootstrap %le t p-value ";
di   %8.5f `pctile_main' _column(32) %8.5f `pctile_twildres';
di  "Unrestricted wild Bootstrap %le t p-value ";
di   %8.5f `pctile_twildunr';
*pause;
restore;
end;


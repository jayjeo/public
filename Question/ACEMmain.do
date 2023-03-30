sort indcode year
global appendix=0
global sigma 0.8
global growth_rate_1987_2017 0.0146

global style_prod_effect 	color(eltgreen) mlabcolor(eltgreen) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct)
global style_comp_effect 	lcolor(edkblue) mcolor(edkblue) mlabcolor(edkblue) msymbol(square) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct)
global style_price_subs 	color(lavender) mlabcolor(lavender) msymbol(none) lpattern(dash_dot) lwidth(thin) msize(vsmall) connect(direct)
global style_task_content   color(dkorange) mlabcolor(dkorange) msymbol(diamond_hollow) lpattern(dash_dot) lwidth(thin) msize(small) connect(direct)
global style_observed       lcolor(gs8) mcolor(gs8) mlabcolor(gs8) msymbol(triangle_hollow) lpattern(solid) lwidth(thin) msize(small) connect(direct)
global style_displacement   color(orange_red) mlabcolor(orange_red) msymbol(circle) lpattern(solid) lwidth(thin) msize(small) connect(direct)
global style_reinstatement  color(blue)    mlabcolor(blue)     msymbol(triangle) lpattern(solid) lwidth(thin) msize(small) connect(direct)
global style_displacement2  color(orange_red) mlabcolor(orange_red) msymbol(none) lpattern(dash_dot) lwidth(thin) msize(small) connect(direct)
global style_reinstatement2 color(blue)    mlabcolor(blue)     msymbol(none) lpattern(dash_dot) lwidth(thin) msize(small) connect(direct)
global style_price_effect 	color(maroon) mlabcolor(maroon) msymbol(triangle) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct)
global style_obs_manuf      mcolor(edkblue) msize(medium) msymbol(diamond) mlcolor(black) mlwidth(vthin)
global style_obs_nmanuf 	mcolor(eltgreen) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)

bys year: egen gdp_manuf=total(vadded_i)
bys year: egen wbill_manuf=total(wages_i)
gen labsh_us=wbill_manuf/gdp_manuf
gen log_gdp_manuf=ln(gdp_manuf*price_us/population_us)
gen log_wbill_manuf=ln(wbill_manuf*price_us/population_us)
gen log_qty_manuf=ln(qty_manuf/population_us)
gen log_price_manuf=ln(gdp_manuf*price_us/qty_manuf)

sort indcode year
bys indcode: gen cum_delta_wbill_manuf=100*(log_wbill_manuf-log_wbill_manuf[1])
assert cum_delta_wbill_manuf==0 if year==${assertyear}
bys indcode: gen cum_prod_effect=100*(log_gdp_manuf-log_gdp_manuf[1])
assert cum_prod_effect==0 if year==${assertyear}
bys indcode: gen cum_qty_effect=100*(log_qty_manuf-log_qty_manuf[1])
assert cum_qty_effect==0 if year==${assertyear}
bys indcode: gen cum_price_effect=100*(log_price_manuf-log_price_manuf[1])
assert cum_price_effect==0 if year==${assertyear}

sort indcode year
gen gdpsh_i=vadded_i/gdp_manuf
gen labsh_i=wages_i/vadded_i
bys indcode: gen base_gdpsh=gdpsh_i[1]
assert base_gdpsh==gdpsh_i if year==${assertyear}
bys indcode: gen base_labsh=labsh_i[1]
assert base_labsh==labsh_i if year==${assertyear}

sort indcode year
bys year: egen comp_actual_1=total(gdpsh_i*labsh_i)
bys year: egen comp_counter_1=total(base_gdpsh*labsh_i)
gen cum_composition=100*(ln(comp_actual_1)-ln(comp_counter_1))

sort indcode year
xtset indcode year
gen logW_i=ln(priceW_i)
gen logR_i=ln(priceR_i)
gen ln_labsh_i=ln(labsh_i)
*gen substitution_i=(1-${sigma})*(1-base_labsh)*(d.logW_i - d.logR_i - ${growth_rate2011_2020})
gen substitution_i=(1-${sigma})*(1-base_labsh)*(d.logW_i - d.logR_i - ${growth_rate_1987_2017})
gen task_content_i=d.ln_labsh_i-substitution_i

sort indcode year
rangestat (mean) task_content_*, interval(year -2 2) by(indcode)
gen task_negative_5yr=min(task_content_i_mean,0)
gen task_positive_5yr=max(task_content_i_mean,0)

sort indcode year
rangestat (mean) task_content_i_mean_3yr=task_content_i, interval(year -1 1) by(indcode)
gen task_negative_3yr=min(task_content_i_mean_3yr,0)
gen task_positive_3yr=max(task_content_i_mean_3yr,0)

sort indcode year
gen task_negative=min(task_content_i,0)
gen task_positive=max(task_content_i,0)

sort indcode year
bys indcode: gen base_share=wages_i[1]/wbill_manuf[1]
bys indcode: gen lagged_share=wages_i[_n-1]/wbill_manuf[_n-1]
collapse (mean) cum_* (sum) substitution_i task_content_* task_negative* task_positive* [iw=base_share], by(year) 

tsset year
foreach var of varlist substitution_i task_content_* task_negative* task_positive* {
	gen cum_`var'=100*sum(`var')
	replace cum_`var'=0 if year==${assertyear}
}

gen label_prod="Productivity effect" if year==2018
gen label_comp="Composition effect"  if year==2016
gen label_subs="Substitution effect"  if year==2016
gen label_task="Change in task content"  if year==2016
gen label_wbill="Observed wage bill" if year==2016
gen label_price="Price effect"  if year==2016
gen label_reinstatement="Reinstatement" if year==2016
gen label_displacement="Displacement" if year==2016





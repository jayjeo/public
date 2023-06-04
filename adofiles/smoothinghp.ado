program smoothinghp
args sector varlists length
    egen ij_temp=group(location `sector')
    xtset ij_temp year 
    tsfill
    foreach var of varlist `varlists' {
        rename `var' `var'_temp_temp
        ipolate `var'_temp_temp year, gen(`var'_temp) epolate by(ij_temp) 
        tsfilter hp `var'_hp = `var'_temp, trend(`var') smooth(`length')
        drop `var'_temp
    }
    drop ij_temp
end

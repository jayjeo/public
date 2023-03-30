capture program drop smoothing
program smoothing 
args varlists 
    egen location_temp=group(location)
    xtset location_temp year 
    tsfill
    foreach var of varlist `varlists' {
        rename `var' `var'_temp_temp
        ipolate `var'_temp_temp year, gen(`var'_temp) epolate by(location_temp) 
        tsfilter hp `var'_hp = `var'_temp, trend(`var') smooth(1)
        drop `var'_temp
    }
    drop location_temp
end

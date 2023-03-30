// basic settings and ado-installation // 
set scheme s1color, perm

capture ado uninstall Jay_ado
net install Jay_ado.pkg, from(https://raw.githubusercontent.com/jayjeo/public/master/adofiles)


capture program drop main
program main
	local ssc_packages "_gwtmean" "grstyle" "parmest" 
	
    if !missing("`ssc_packages'") {
        foreach pkg in "`ssc_packages'" {
            dis "Installing `pkg'"
            ssc install `pkg', replace
        }
    }

end

main


capture ado uninstall gr0002_3
net install gr0002_3, from (http://www.stata-journal.com/software/sj4-3)


capture ado uninstall st0085_2
net install st0085_2, from(http://www.stata-journal.com/software/sj14-2)


capture ado uninstall rangestat
net install rangestat, from(http://fmwww.bc.edu/RePEc/bocode/r)







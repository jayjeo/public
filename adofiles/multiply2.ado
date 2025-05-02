capture program drop multiply2
program multiply2
    capture matrix VV = e(V)
    if _rc {
        display as error "❗ e(V) not found in current estimates. Cannot compute standard errors."
        exit 198
    }
    
    matrix b100 = e(b)*100
    matrix VVV = e(V)
    
    mata: VV = st_matrix("VV")
    mata: VV = sqrt(VV) :* 100
    mata: st_matrix("VV", VV)
    
    forval i = 1/`= rowsof(VV)' {
        forval j = 1/`= colsof(VV)' {
            mat VVV[`i', `j'] = VV[`i', `j']
        }
    }
    
    matrix se100 = vecdiag(VVV)
    estadd matrix b100 = b100
    estadd matrix se100 = se100
end

clear all
import delimited "https://raw.githubusercontent.com/jayjeo/public/master/warehouse/SVARpractice.csv", varnames(1) clear 

******** oirf
tsset t
mat A=(1,.\0,1)
mat B=(.,0\0,.)
svar y z, lags(1) aeq(A) beq(B)
irf create order1, set(var2.irf) replace step(10)
irf graph oirf, xlabel(0(2)10) irf(order1) noci yline(0,lcolor(black)) byopts(yrescale)
irf drop order1 

******** sirf
tsset t
mat A=(1,.\0,1)
mat B=(.,0\0,.)
svar y z, lags(1) aeq(A) beq(B)
irf create order1, set(var2.irf) replace step(10)
irf graph sirf, xlabel(0(2)10) irf(order1) noci yline(0,lcolor(black)) byopts(yrescale)
irf drop order1 

******** My Replication
tsset t
sureg (y L.y L.z)(z L.y L.z)
gen ybly=_b[y:L.y]
gen yblz=_b[y:L.z]
gen zbly=_b[z:L.y]
gen zblz=_b[z:L.z]
putmata ybly yblz zbly zblz
mata A1=ybly[1],yblz[1]\zbly[1],zblz[1]
mata
    B=1,-0.3864334590141\0,1
    Gamma=B*A1
    pi_svar=I(2)
    pi11_svar=pi_svar[1,1]
    pi12_svar=pi_svar[1,2]
    pi21_svar=pi_svar[2,1]
    pi22_svar=pi_svar[2,2]
end
forvalues i=2(1)$obs {
    mata: pi_svar=Gamma*pi_svar
    mata: pi11_svar=pi11_svar\pi_svar[1,1]
    mata: pi12_svar=pi12_svar\pi_svar[1,2]
    mata: pi21_svar=pi21_svar\pi_svar[2,1]
    mata: pi22_svar=pi22_svar\pi_svar[2,2]
}
getmata pi11_svar pi12_svar pi21_svar pi22_svar
preserve
    tsset t
    keep if t<=10
    tsline pi11_svar, name(pi11_svar)
    tsline pi12_svar, name(pi12_svar)
    tsline pi21_svar, name(pi21_svar)
    tsline pi22_svar, name(pi22_svar)
    graph combine pi11_svar pi21_svar pi12_svar pi22_svar
restore 
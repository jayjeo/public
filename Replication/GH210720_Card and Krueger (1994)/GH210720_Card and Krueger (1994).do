global pathr "C:\Users\acube\Dropbox\Study\GitHub\public\Replication\GH210720_Card and Krueger (1994)\Rep_files\njmin"
cd "$pathr"

/******* MHE Replication:
MHE = Joshua D. Angrist, Jorn-Steffen Pischke - Mostly Harmless Econometrics_ An Empiricist's Companion (2008)
Data webpage = http://economics.mit.edu/faculty/angrist/data1/mhe
*/


******** Card and Krueger (1994), MHE169

infix   ///
SHEET           1-3        ///
CHAIN           5-5        ///
CO_OWNED        7-7        ///
STATE           9-9        ///
SOUTHJ         11-11        ///
CENTRALJ       13-13        ///
NORTHJ         15-15        ///
PA1            17-17        ///
PA2            19-19        ///
SHORE          21-21        ///
        ///
NCALLS         23-24         ///
EMPFT          26-30        ///
EMPPT          32-36        ///
NMGRS          38-42        ///
WAGE_ST        44-48        ///
INCTIME        50-54        ///
FIRSTINC       56-60        ///
BONUS          62-62        ///
PCTAFF         64-68        ///
MEALS          70-70        ///
OPEN           72-76        ///
HRSOPEN        78-82        ///
PSODA          84-88        ///
PFRY           90-94        ///
PENTREE        96-100        ///
NREGS         102-103        ///
NREGS11       105-106        ///
        ///
TYPE2         108-108        ///
STATUS2       110-110        ///
DATE2         112-117        ///
NCALLS2       119-120        ///
EMPFT2        122-126        ///
EMPPT2        128-132        ///
NMGRS2        134-138        ///
WAGE_ST2      140-144        ///
INCTIME2      146-150        ///
FIRSTIN2      152-156        ///
SPECIAL2      158-158        ///
MEALS2        160-160        ///
OPEN2R        162-166        ///
HRSOPEN2      168-172        ///
PSODA2        174-178        ///
PFRY2         180-184        ///
PENTREE2      186-190        ///
NREGS2        192-193        ///
NREGS112      195-196        ///
using "$pathr\public.dat", clear
save public, replace

use public, clear
rename (EMPFT EMPFT2) (EMPFT1 EMPFT2)
rename (EMPPT EMPPT2) (EMPPT1 EMPPT2)
rename (NMGRS NMGRS2) (NMGRS1 NMGRS2)

keep STATUS2 SHEET EMPFT1 EMPFT2 EMPPT1 EMPPT2 NMGRS1 NMGRS2 ///
        STATE SOUTHJ CENTRALJ NORTHJ PA1 PA2 SHORE

local w=0.4  // Can't figure not how FTE(Full Time Equivalent) employment is calculated. 
gen FTE1=EMPFT1+`w'*EMPPT1+NMGRS1
gen FTE2=EMPFT2+`w'*EMPPT2+NMGRS2

sort SHEET
drop if SHEET==SHEET[_n-1]
reshape long FTE, i(SHEET) j(month)

replace FTE=0 if STATUS2==3
replace FTE=. if inlist(STATUS2,2,4,5)
recode month (1=0) (2=1)

*keep if CENTRALJ==1 |SOUTHJ==1 | PA1==1 | PA2==1
*drop if PA1==1
*keep if CENTRALJ==1|STATE==0
reg FTE STATE#month 


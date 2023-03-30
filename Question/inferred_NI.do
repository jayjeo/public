
****************** OECD version ******************
use master, clear 
sort location sector year
gen vadded_i=oecd_VALU_detail
gen wages_i=oecd_LABR_detail
gen priceW_i=oecd_LABR_detail/oecd_EMP
gen qty_manuf=oecd_VALU_detail  //  // /price_us
egen indcode=group(sector)
save master_oecd, replace 

keep if vadded_i!=.&year==2005
keep location 
duplicates drop

** USA
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf 
keep if location=="USA" 
keep if inrange(year,2000,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 2000
duplicates drop
do ACEMmain
gen location="USA"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative 
save USA, replace

** Austria
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf 
keep if location=="AUT"
keep if inrange(year,1995,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="AUT"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save AUT, replace


** Austrailia
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="AUT"
keep if inrange(year,1995,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="AUT"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save AUT, replace


** Belgium
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="BEL"
keep if inrange(year,1995,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="BEL"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save BEL, replace


** Canada
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="CAN"
keep if inrange(year,1997,2010)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1997
duplicates drop
do ACEMmain
gen location="CAN"
/*
gen I_20_temp=cum_task_negative if year==2010
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save CAN, replace

** Czech Republic
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="CZE"
keep if inrange(year,1995,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="CZE"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save CZE, replace


** Germany
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="DEU"
keep if inrange(year,1995,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="DEU"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save DEU, replace


** Denmark
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="DNK"
keep if inrange(year,1990,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1990
duplicates drop
do ACEMmain
gen location="DNK"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save DNK, replace


** Spain
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="ESP"
keep if inrange(year,1995,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="ESP"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save ESP, replace



** Estonia
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="EST"
keep if inrange(year,1998,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1998
duplicates drop
do ACEMmain
gen location="EST"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save EST, replace



** Finland
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="FIN"
keep if inrange(year,1990,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1990
duplicates drop
do ACEMmain
gen location="FIN"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save FIN, replace


** France
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="FRA"
keep if inrange(year,1990,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1990
duplicates drop
do ACEMmain
gen location="FRA"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save FRA, replace


** United Kingdom
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="GBR"
keep if inrange(year,1995,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="GBR"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save GBR, replace


** Greece
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="GRC"
keep if inrange(year,1995,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="GRC"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save GRC, replace



** Hungary
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="HUN"
keep if inrange(year,1995,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="HUN"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save HUN, replace



** Italy
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="ITA"
keep if inrange(year,1995,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="ITA"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save ITA, replace


** Japan
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="JPN"
keep if inrange(year,1994,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1994
duplicates drop
do ACEMmain
gen location="JPN"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save JPN, replace



** Lithuania
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="LTU"
keep if inrange(year,1995,2017)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="LTU"
/*
gen I_20_temp=cum_task_negative if year==2017
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save LTU, replace


** Mexico
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="MEX"
keep if inrange(year,1993,2010)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1993
duplicates drop
do ACEMmain
gen location="MEX"
/*
gen I_20_temp=cum_task_negative if year==2010
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save MEX, replace


** Netherlands
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="NLD"
keep if inrange(year,1995,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="NLD"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save NLD, replace


** Poland
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="POL"
keep if inrange(year,1995,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="POL"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save POL, replace



** Portugal
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="PRT"
keep if inrange(year,1995,2017)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="PRT"
/*
gen I_20_temp=cum_task_negative if year==2017
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save PRT, replace



** Slovenia
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="SVN"
keep if inrange(year,1995,2018)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1995
duplicates drop
do ACEMmain
gen location="SVN"
/*
gen I_20_temp=cum_task_negative if year==2018
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save SVN, replace


* Sweden
use master_oecd, clear
sort location indcode year 
keep year location country price_us priceW_i priceR_i vadded_i wages_i population_us indcode qty_manuf  
keep if location=="SWE"
keep if inrange(year,1993,2019)==1
drop if qty_manuf==.|price_us==.|priceW_i==.|priceR_i==.|vadded_i==.|wages_i==.|population_us==.|indcode==.
global assertyear 1993
duplicates drop
do ACEMmain
gen location="SWE"
/*
gen I_20_temp=cum_task_negative if year==2019
egen I_20=sum(I_20_temp)
replace cum_task_positive=cum_task_positive/I_20*(-1)
replace cum_task_negative=cum_task_negative/I_20*(-1)
*/
gen t=_n
tsset t
do ACEM_graph2
keep year location cum_task_positive_5yr cum_task_negative_5yr cum_task_positive_3yr cum_task_negative_3yr cum_task_positive cum_task_negative  
save SWE, replace



use USA, clear
foreach location in CZE	DEU	DNK	ESP	EST	FIN	FRA	GBR	///
GRC	HUN	ITA	JPN	LTU	MEX	NLD	POL	PRT	SVN	SWE {
    append using `location'
}
sort location year
rename(cum_task_positive cum_task_negative)(N_oecd I_oecd)
replace I_oecd=-1*I_oecd
save NI_oecd, replace



*** for N comparison(Cedefop)   // C:\Users\acube\Dropbox\Study\UC Davis\Writings\LaborShareKorea\EmergingTasks_ver3(Cedefop)
use AUT, clear
foreach location in  CZE	DEU	DNK	ESP	EST	FIN	FRA	GBR	///
GRC	HUN	ITA	LTU	NLD	POL	PRT	SVN	SWE {
    append using `location'
}
sort location year
rename(cum_task_positive cum_task_negative)(N_oecd I_oecd)
replace I_oecd=-1*I_oecd
keep year I_oecd location 
//save "C:\Users\acube\Dropbox\Study\UC Davis\Writings\LaborShareKorea\EmergingTasks_ver3(Cedefop)\I_oecd", replace 






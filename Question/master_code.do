
cls
clear all
*++++++++++ Set your preferred folder ++++++++++
global path="C:\Users\acube\Dropbox\Study\UC Davis\Writings\LaborShareKorea\GELS_ver2"
//global path="K:\Dropbox\Study\UC Davis\Writings\LaborShareKorea\GELS_ver2"
*+++++++++++++++++++++++++++++++++++++++++++++++
cd "${path}"


// basic settings and ado-installation // 
do configure


// import necessary data from OECD statistics // 
do OECDstatistics
do IFR
do KN_replication
do markup  
do make_master
do EMPmerge  
do inferred_NI
do concentration
do regression











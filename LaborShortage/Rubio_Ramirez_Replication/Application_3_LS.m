%% Code for Structuctural VAR %%

% Supports Sign, Zero and Narrative Sign Restrictions, as well as Conjugate
% Priors on the Reduced Form

% Revision History:
% 06/12/2016  - Juan Antolin-Diaz - Version 1
clear
clc

%% Reduced form Settings 
% Data Location and Adjustments
T = readtable('C:\Users\acubens\Documents\acubens_UCDserver\NarrativeSignRestrictions\data\SVARdata_seasondummyadj_dates.csv','NumHeaderLines',1);
dates = datenum([T.Var3,T.Var2,T.Var1]);
data = table2array(readtable('C:\Users\acubens\Documents\acubens_UCDserver\NarrativeSignRestrictions\data\SVARdata_seasondummyadj.csv','NumHeaderLines',1));
clearvars T

save('LS.mat','dates','data') 
load('C:\Users\acubens\Documents\acubens_UCDserver\NarrativeSignRestrictions\data\LSvarnames.mat')
save('C:\Users\acubens\Documents\acubens_UCDserver\NarrativeSignRestrictions\data\LS.mat')

clear
clc
addpath('data')
addpath('functions')
datafile ='data\LS.mat'

panelselect = [1:4];                % Choose subset and/or re-order variables (optional); Empty = use all;
exog = [];
startYear = 2020;                       % Choose start year
endYear = 2024;                           

% Model Specification
constant = 1;                           % Add constant in VAR
p = 3;                                  % Maximum lag order of factor VAR
h = 120;                                % Desired forecast horizon

%% Reduced Form Priors
prior_settings.prior_family = 'conjugate';
prior_settings.prior = 'flat';                % Select 'flat' or 'Minnesota'

%% Structural Identification Settings
StructuralIdentification = 'Signs/Zeros';           % Chose 'None' or 'Signs/Zeros' or 'Choleski';
agnostic = 'irfs';  % select: 'structural' or 'irfs';
       
    % Set up Sign Restrictions       
      % SR{r} = {Shockname,{Variable Names}, Horizon, Sign (1 or -1),}; 
        SR{1} = {'reallocationshock',{'UNEMPLOYMENT'}    ,10,-1};
        SR{2} = {'reallocationshock',{'VACANCY'}         ,10,-1};

        SR{3} = {'aggregateshock',{'UNEMPLOYMENT'}    ,10,-1};
        SR{4} = {'aggregateshock',{'VACANCY'}         ,10,1};

        SR{5} = {'TFWshock',{'TFW'}             ,10,-1};
        SR{6} = {'TFWshock',{'UNEMPLOYMENT'}    ,10,-1};

        SR{7} = {'NATIVEshock',{'NATIVE'}          ,1,-1};
        SR{8} = {'NATIVEshock',{'UNEMPLOYMENT'}    ,1,-1};


  % Set up Narrative Sign Restrictions        
      % NSR{r} = {'shockname',type of restriction ('sign of shock' or
      % 'contribution'), date, end date (for contributions only), variable 
      % (for contributions only), sign, 'strong' or 'weak' for
      % contributions.
            NSR{1} = {'TFWshock','contribution',datenum(2020,04,01),datenum(2022,11,31),'NATIVE',1,'weak'};
            NSR{1} = {'NATIVEshock','contribution',datenum(2020,04,01),datenum(2022,11,31),'TFW',1,'weak'};

cumulateWhich = []; % Compute Cumulated IRFs for Plots
    
%% Gibss Sampler Settings
numDesiredDraws = 1000;
BetaSigmaTries = 50;
Qs_per_BetaSigma = 5;
nRepsWeights = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of Code that is Edited Frequently %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
rng(1)
Run_SVAR_v1

%% Some Results
% Impulse Responses
Plot_IRFs_LS
saveas(gcf,'Plot_IRFs','epsc')

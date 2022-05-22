%% Code for Structuctural VAR %%

% Supports Sign, Zero and Narrative Sign Restrictions, as well as Conjugate
% Priors on the Reduced Form

% Revision History:
% 06/12/2016  - Juan Antolin-Diaz - Version 1
clear
clc

%% Reduced form Settings 
% Data Location and Adjustments
T = readtable('E:\Dropbox\Study\DR\220521\Replication\data\SVARdata_seasondummyadj_dates.csv','NumHeaderLines',1);
dates = datenum([T.Var3,T.Var2,T.Var1]);
data = table2array(readtable('E:\Dropbox\Study\DR\220521\Replication\data\SVARdata_seasondummyadj.csv','NumHeaderLines',1));
clearvars T

save('LS.mat','dates','data') 
load('data\LSvarnames.mat')
save('data\LS.mat')

clear
clc
addpath('data')
addpath('functions')
datafile ='data\LS.mat'

panelselect = [1:4];                % Choose subset and/or re-order variables (optional); Empty = use all;
exog = [];
startYear = 2015;                       % Choose start year
endYear = 2022;                           

% Model Specification
constant = 1;                           % Add constant in VAR
p = 6;                                  % Maximum lag order of factor VAR
h = 120;                                % Desired forecast horizon

%% Reduced Form Priors
prior_settings.prior_family = 'conjugate';
prior_settings.prior = 'flat';                % Select 'flat' or 'Minnesota'

%% Structural Identification Settings
StructuralIdentification = 'Signs/Zeros';           % Chose 'None' or 'Signs/Zeros' or 'Choleski';
agnostic = 'irfs';  % select: 'structural' or 'irfs';
       
    % Set up Sign Restrictions       
      % SR{r} = {Shockname,{Variable Names}, Horizon, Sign (1 or -1),}; 
        SR{1} = {'reallocationshock',{'u'}    ,6,1};
        SR{2} = {'reallocationshock',{'v'}    ,6,1};

        SR{3} = {'aggregateshock',{'u'}       ,6,1};
        SR{4} = {'aggregateshock',{'v'}       ,6,-1};

        SR{5} = {'TFWshock',{'fw'}            ,6,-1};
        SR{6} = {'TFWshock',{'u'}             ,6,-1};

        SR{7} = {'nativeshock',{'dw'}         ,6,-1};
        SR{8} = {'nativeshock',{'u'}          ,6,-1};

    % Set up Narrative Sign Restrictions        
      % NSR{r} = {'shockname',type of restriction ('sign of shock' or
      % 'contribution'), date, end date (for contributions only), variable 
      % (for contributions only), sign, 'strong' or 'weak' for
      % contributions.
            %sign_of_shocks
            NSR{1} = {'TFWshock','contribution',datenum(2020,04,01),datenum(2022,03,31),'fw',1,'strong'};
            NSR{2} = {'nativeshock','contribution',datenum(2020,04,01),datenum(2022,03,31),'dw',1,'strong'};

cumulateWhich = []; % Compute Cumulated IRFs for Plots
    
%% Gibss Sampler Settings
numDesiredDraws = 500;
BetaSigmaTries = 50;
Qs_per_BetaSigma = 50;
nRepsWeights = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of Code that is Edited Frequently %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
rng(1)
Run_SVAR_v1

%% Some Results
% Impulse Responses
Plot_IRFs


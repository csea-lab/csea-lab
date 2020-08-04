% this is the pipeline for fitting the RW model 
%% this works for behavioral data

%a = load ('bop120.dat');

contingencies = condition_103;
ratings = rating_103;

[BETA,R,J,COVB,MSE] = nlinfit(contingencies,ratings./max(ratings),@PearceHallMod, [0.5 0.5]);

BETA

MSE

figure

temp = PearceHallMod([BETA], contingencies);

% there are no valid Rsquares in nonlinear regression :-0 
% In nonlinear regression, SS Regression + SS Error do not equal SS Total! 

RSS = sum(R.^2);

BIC = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R));

ChiSquare = sum((R./std(ratings)).^2);

plot(temp)

hold on 

plot(ratings./max(ratings), 'r')
%% now for the brain data
% first we need the contingencies for ONLY the good trials
% they are in rig file :-) 

clear

folder_out = '/Users/kierstin_riels/Desktop/Experiments/BOP/RWmodelSPMs/';

load('/Users/kierstin_riels/Desktop/Experiments/BOP/workspace saves/rescwag with kept trials.mat'); 

outname = 'RW_paras.101.at'

contingencies = rig101; 

% load the matching alpha data; 

load ('/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/appg/sing/bop_101.fl40h1.E1.appgalph.sing.mat'); 


for chan = 1:129
    
    [BETA(chan,:),R,J,COVB,MSE(chan)] = nlinfit(contingencies,outmat(chan,:)'./max(outmat(chan,:)),@rescorlaWagnerModelAK4linfit, [0.5 0.6]);
  
end

figure

plot(BETA(:,1)), pause
plot(BETA(:,2)), pause
plot(MSE)

% plot chan 62 against model predictions for 62
temp = rescorlaWagnerModelAK4linfit([BETA(62,:)], contingencies);
figure
plot(temp)
hold on 
plot(outmat(62,:)'./max(outmat(62,:)), 'r')

% make a nice matrix and save in ATG firmat for emegs to read
SPM_atgmat = [BETA MSE']; 
SaveAvgFile([folder_out outname],SPM_atgmat,[],[], 1); 
 
%% now for the brain data, shifted ! previous trial contingency predicting next trial's alpha (weights from model = weights(2:end))
% first we need the contingencies for ONLY the good trials
% they are in rig file :-) 

clear

folder_out = '/Users/kierstin_riels/Desktop/Experiments/BOP/RWmodelSPMs_negat/';

load('/Users/kierstin_riels/Desktop/Experiments/BOP/workspace saves/rescwag with kept trials.mat'); 

outname = 'RW_paras_neg.121.at'

contingencies = r20(ig20(1:length(ig20)-1));

% load the matching alpha data; 

load ('/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/appg/sing/bop_121.fl40h1.E1.appgalph.sing.mat'); 


for chan = 1:129
    
    [BETA(chan,:),R,J,COVB,MSE(chan)] = nlinfit(contingencies,outmat(chan,1:end-1)'./max(outmat(chan,1:end-1)),@rescorlaWagnerModelAK4linfit, [0.5 0.6]);
  
end

figure

plot(BETA(:,1)), pause
plot(BETA(:,2)), pause
plot(MSE)

% plot chan 62 against model predictions for 62
temp = rescorlaWagnerModelAK4linfit([BETA(62,:)], contingencies);
figure
plot(temp)
hold on 
plot(outmat(62,:)'./max(outmat(62,:)), 'r')

% make a nice matrix and save in ATG firmat for emegs to read
SPM_atgmat = [BETA MSE']; 
SaveAvgFile([folder_out outname],SPM_atgmat,[],[], 1); 



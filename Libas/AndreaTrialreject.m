function [ EEG ] = AndreaTrialreject( filepath)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
EEG = pop_loadset(filepath); 

datamat = double(EEG.data); 
[ datamat ] = imputebslandrea( datamat );

for trial = 1:size(datamat,3)
    plot(squeeze(datamat(:, :, trial))'), title(num2str(trial)), pause
end


% perform wavelet analysis 
 %%%  
 
% 




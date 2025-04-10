function [convec] = getcon_C1P1(infile)

conmat = load(infile);

stimulustype = conmat(:,4) + 1; % plus one makes numbers interpretable and addable 

% stimulustype 1 = STD right (was zero in log) 
% stimulustype 2 = STD left (was 1 in log) 
% stimulustype 3 = Target right (was 2 in log) 
% stimulustype 4 = Target right (was 3 in log) 

blocktype = conmat(:,5)+1; % plus one makes numbers interpretable and addable 

% blocktype 1 = attend right
% blocktype 2 = attend left

convec = blocktype.*10 + stimulustype;

% 11 = attended standard, right VF
% 12 = unattended standard, left VF
% 21 = unattended standard, right VF
% 22 = attended standard, left VF
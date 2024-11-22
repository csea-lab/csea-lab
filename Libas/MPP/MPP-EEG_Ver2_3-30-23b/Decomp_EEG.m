function [MPP,D]  = Decomp_EEG(X,Clust,M,th,f)
% Function that analyzes/decomposes single-channel EEG traces for a given
% dictionary
% INPUTS:
% X - single-trial (row vector), multi-trial/same length (matrix), or
% multi-trial/different lengths (cell/structure) input with single-channel EEG data
% Single traces MUST be row vectors
% D - Dictionary, matrix MxK. M: duration of phasic events (in samples), K:
% number of atoms/filters in the dictionary
% th - sparsity constraint 

% if not one, convert to structure
n_tr = size(X,1);
if ~isstruct(X)
    X = squeeze(X);
    n_tr = size(X,1);
    X = cell2struct(X,'Trial',n_tr);
end

% Decomposition per trial
MPP = struct();
for i = 1:n_tr
    [MPP_tr,D] = PhEv_nonovp(X(i).Trial,Clust,M,th,f); % decomposition function
    n_det = size(MPP_tr,2);
    for j = 1:n_det
        MPP_tr(j).PhEv = bsxfun(@rdivide,MPP_tr(j).PhEv,sqrt(sum(MPP_tr(j).PhEv.^2)));  % Unit-norm atoms
    end
    MPP(i).Trials = MPP_tr; 
end

end
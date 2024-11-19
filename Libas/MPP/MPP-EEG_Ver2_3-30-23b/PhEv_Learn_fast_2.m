function [D,MPP,th_opt,ar,bw] = PhEv_Learn_fast_2(X, M, K)
% THIS IS THE MAIN FUNCTION THAT CALLS ALL THE REST. 
% Inputs 
% X - banpassed, multi - trial, single channel EEG signal. Must be in cell format or
% row format. (Dimension: number of trials X Time)
% M - Maximum length of event in samples. For ex., sleep spindles are 0.5s
% in length. In that case, M = 0.5 X sampling frequency
% K - Total number of dictionary atoms/ templates/ clusters of events.
% Outputs
% MPP - structure comprising of trial wise detections (as a marked point process (MPP)): 
%       PhEv - normalized snippet of the exracted event,
%       tau - time point of occurrence (mid - point),
%       alph - maximum absolute amplitude of the event,
%       D_idx - dictionary index that maximally correlates
%       pow - power of the extracted snippet
% D - Dictionary atoms/ centers of the cluster/ templates of the events
% authors: Shailaja Akella, Carlos Loza

X = squeeze(X);
n_tr = size(X,1); 

% Convert to structure
if ~iscell(X) 
    X = mat2cell(X,ones(1,n_tr));
end
X = cell2struct(X,'Trial',n_tr);

% Threshold Calculation
[th, ar, bw] = Denoise(X,M,1);

% Dictionary Learning - Training - Alternating estimations
disp('Initializing Dictionary for 10 possible cases')
D_fin = struct();
n_rep = 10; % number of initializations
D_init_c = D_init_data(X,M,K,n_rep); % dictionary initialization
n_it = 50; % maximum number of iterations for convergence 
eps_stp = 10^-2; % threshold for convergence

for i = 1:n_rep
    display(['Repetition ' num2str(i) ' of ' num2str(n_rep)])
    D = D_init_c(i).Num;
    D = cell2struct(num2cell(D,1),'cent',K);
    fl_stp = 0;
    it = 1;
    D_pre = zeros(M,K);
    while fl_stp == 0
        % Phasic Event Assignment
        MPP = Decomp_EEG(X,D,M,th,0);
        MPP = MPP(~cellfun(@isempty,{MPP.Trials}));
        MPP_all = [MPP.Trials];
        
        % Dictonary Update
        D = Dict_Cluster_Corr([MPP_all.PhEv],[MPP_all.D_idx],K,[D.cent]);
        
        % Convergence criterion
        aux_norm1 = abs(D_pre) - abs([D.cent]);
        aux_norm2 = sqrt(sum(aux_norm1.^2,1));
        if mean(aux_norm2) <= eps_stp % stopping criteria 1
            fl_stp = 1;
            D_fin(i).Rep = [D.cent]; 
            clear D
        elseif it == n_it % stopping criteria 2
            fl_stp = 1;
            D_fin(i).Rep = [D.cent];
            clear D
        else
            D_pre = [D.cent];
            it = it + 1;
        end
    end 
end
clear D

% Choosing the dictionary with lowest mutual coherence
mu_coh = zeros(1,n_rep);
for i = 1:n_rep
    D = D_fin(i).Rep;
    mu_coh(1,i) = Mutual_Coherence(D);
end
[~, idx] = min(mu_coh);
clear D

for i = 1:K
 D(i).cent = D_fin(idx).Rep(:,i);
%  D(i).len = len(D_fin(idx).Rep(:,i));
end

% D = Rem_OutBand(D);

% Final Decomposition
[MPP,D] = Decomp_EEG(X,D,M,th,1);

th_opt = th;
end     

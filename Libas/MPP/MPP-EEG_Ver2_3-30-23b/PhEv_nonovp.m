function [MPP,D] = PhEv_nonovp(x,D,M,th,f)
% INPUTS
% x - single trial, single channel, bandpassed EEG trace 
% D - Dictionary 
% th - threshold learnt from denoising
% f - flag for adjusting length of atoms and detections (Crude post - processing) 
%     f = 0: event lengths are not adjusted
%     f = 1: event lengths are adjusted to include only oscillations


N = length(x);
n_te = size(D,2);
stp_fl = 0;                             % Stopping flag for main loop
MPP = struct();
n = 1;

sz = arrayfun(@(s) numel(s.cent),D);
if all(sz == sz(1))
    D_new = struct();
    for d = 1:n_te
        if (n_te == 1 && length(D(1).cent) < M)
            D_new = D;
            D_new(1).len = length(D(1).cent);
    	    break;
        end

        d_n = setPhEv(D(d).cent,1,f);
        if ~isempty(d_n)
            D_new(n).cent = d_n;
            D_new(n).len = length(d_n);
            n = n+1;
        elseif(isempty(d_n) && n_te == 1)
            D_new = D;
            D_new(1).len = length(D(1).cent);
        end

    end
    clear D
    D = D_new;
    clear D_new
end

n_te = size(D,2);

M = max([D.len]);
if iscolumn(x) == 0
    x = x';
end
i = 2;


% Correlations b/w signal and atoms 
if f
    for n = 1:n_te
        for j = 1:N
            if j + D(n).len <= N corrs(j,n) = D(n).cent'*x(j:j+D(n).len-1);
            else corrs(j,n) = D(n).cent'*[x(j:N,1); x(1:D(n).len - (N - j + 1),1)]; end
        end
    end
else
    for n = 1:n_te
        corrs(:,n) = cconv(x,flipud(D(n).cent),length(x)+D(n).len);
    end
    corrs = corrs(D(1).len:end-1,:);
end
abs_corrs = abs(corrs);
[max_tau, max_D_idx] = max(abs_corrs,[],2);

% First iteration
[~, idx_max] = max(max_tau);
if idx_max + M > N                          % Condition for right edge
    z_padd = min(N - idx_max + M,N);
    max_tau(max(idx_max - M + 1,1):end) = zeros(z_padd,1);
    MPP = struct();
    i = i-1;
else
    if (idx_max - M + 1) <= 0
        l = length(1:idx_max+ M -1);
        max_tau(1:idx_max+ M-1) = zeros(l,1);
    else
        max_tau(idx_max - M + 1:idx_max+ M -1) = zeros(2*M - 1,1);
    end
    
    [x_set,t_new] = setPhEv(x(idx_max:idx_max + M - 1,1),idx_max,f);
    if ~isempty(x_set)
        MPP(i-1).tau = t_new;
        MPP(i-1).PhEv = x_set;
        MPP(i-1).alph = max(abs(x_set));
        MPP(i-1).D_idx = max_D_idx(idx_max);
        MPP(i-1).pow = (1/length(x_set))*(norm(x_set).^2);
    else
        i = i-1;
    end
end

% Remaining iterations
while stp_fl == 0
    [tau_p, fl] = check_potential_PhEv(max_tau, M);
    if fl == 0
        for j = 1:length(tau_p)
            [~, idx_max] = max(max_tau);
            if idx_max + M > N                       % Condition for right edge
                z_padd = min(N - idx_max + M,N);
                max_tau(max(1,idx_max - M + 1):end) = zeros(z_padd,1);
            else
                if (idx_max - M + 1) <= 0            % Condition for left edge
                    l = length(1:idx_max+ M -1);
                    max_tau(1:idx_max+ M-1) = zeros(l,1);
                else
                    max_tau(idx_max - M + 1:idx_max+ M -1) = zeros(2*M - 1,1);
                end
                [x_set,t_new] = setPhEv(x(idx_max:idx_max + M - 1,1),idx_max,f);
                if ~isempty(x_set)
                    MPP(i).tau = t_new;
                    MPP(i).PhEv = x_set;
                    MPP(i).D_idx = max_D_idx(idx_max);
                    MPP(i).alph = max(abs(x_set));
                    MPP(i).pow = (1/length(x_set))*(norm(x_set)).^2;
                    i = i + 1;
                end
            end
            if ~isempty(fieldnames(MPP)) % stopping criteria
                if (norm(MPP(i-1).PhEv)) < th
                    stp_fl = 1;
                    break;
                end
            end
        end
    else
        stp_fl = 1;
    end
    
end

if length(MPP) > 1
    MPP(end) = [];
end
end

function [tau_p, fl] = check_potential_PhEv(max_tau, M)
% Function to check if there are any potential atoms left to be discovered
% in the non-overlapping case of the decomposition
% if fl = 0 -> no potential phasic events to be found
% if fl = 1 -> potential phasic events still available

max_tau_ones = double((max_tau ~= 0));

aux_fl = conv(max_tau_ones,ones(1,M),'valid');
idx = find(aux_fl == M);

if isempty(idx) == 1
    fl = 1;
    tau_p = 0;
else
    fl = 0;
    aux_idx = find(diff(idx) >= M) + 1;
    tau_p = [idx(1); idx(aux_idx)];
end

end


function [x,t] = setPhEv(x_i,t_i,f)
% Post - processing for length adjustments
% x_i - snippet, t_i - time stamp of occurrence, f - flag for adjustments
if f
    M = 1:length(x_i);
    aux_M = round(M(end)/2);
    x_hs = smooth(abs(hilbert(x_i)));
    [~,L_idx] = findpeaks(max(x_hs) - x_hs,'MinPeakDistance',aux_M);
    x_norm = zeros(length(L_idx)+1,1);
    n_idx = length(L_idx);
    switch(n_idx)
        case 0
            idx = M;
        case 1
            x_norm(1) = norm(x_i(1:L_idx(1)));
            x_norm(2) = norm(x_i(L_idx(1):end));
            [~,I] = max(x_norm);
            if (I == 1)
                idx = 1:L_idx(1);
            else
                idx = L_idx(1):M(end);
            end
        otherwise
            x_norm(1) = norm(x_i(1:L_idx(1)));
            for j = 2:length(L_idx)
                x_norm(j) = norm(x_i(L_idx(j-1):L_idx(j)));
            end
            x_norm(j+1) = norm(x_i(L_idx(j):end));
            [~,I] = max(x_norm);
            if I == 1
                idx = 1:L_idx(1);
            elseif I == j+1
                idx = L_idx(j):M(end);
            else
                idx = L_idx(I-1):L_idx(I);
            end
    end
    
    x =[]; t =[];
    if (length(idx) > M(end)/2)
        x = x_i(idx);
        t = t_i + idx(1) + round(length(x)/2)-1;
    end
else
    x = x_i;
    t = t_i + round(length(x)/2) - 1;
end
end



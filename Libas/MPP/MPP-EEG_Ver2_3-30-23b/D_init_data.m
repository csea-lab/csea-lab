function D_c = D_init_data(X,M,K,n_rep)

% X - single-trial (vector), multi-trial/same length (matrix), or
% mult-trial/different lengths (cell) input with single-channel EEG data
% K - number of clusters

%X_M = zeros(0,0);

n_tr = size(X,1);               % EEG traces MUST be row vectors

% Hilbert amplitude
X_abs = struct();
for i = 1:n_tr
    X_abs(i).Trial = abs(hilbert(X(i).Trial));
end

% Smooth amplitude
X_abs_sm = struct();
aux_M = round(M/2);
spn = round(aux_M/2)*2 - 1;
for i = 1:n_tr
    X_abs_sm(i).Trial = smooth(X_abs(i).Trial,spn);
end

% Find peaks
X_M = zeros(0,0);
alph = zeros(0,0);
min_pk_d = round(1*M);
for i = 1:n_tr
    x_tr = X(i).Trial;
    N = length(x_tr);
    [~, pk_loc] = findpeaks(X_abs_sm(i).Trial,'MinPeakDistance',min_pk_d,'SortStr','descend');
    n_pks = length(pk_loc);
    alph_tr = zeros(n_pks,1);
    X_M_tr = zeros(M,n_pks);
    for j = 1:n_pks
        if ~(pk_loc(j) - round(M/2) <= 0 || pk_loc(j) + round(M/2) - 1 > N)
            idx = pk_loc(j) - round(M/2):pk_loc(j) + fix(M/2) - 1;
            alph_tr(j,1) = norm(x_tr(idx));
            X_M_tr(:,j) = x_tr(idx)';
        end
    end
    idx_nnull = find(alph_tr ~= 0);
    alph_tr = alph_tr(idx_nnull,1);
    X_M_tr = X_M_tr(:,idx_nnull);
    X_M = [X_M X_M_tr];
    alph = [alph; alph_tr];
end


% Get outliers based on maximum norm
fl = 0;
prc_p = 90;
while fl == 0
    idx = find(alph > prctile(alph,prc_p));
    if length(idx) >= K
        fl = 1;
    else
        prc_p = prc_p - 5;
    end
    if prc_p < 0            % Degenerate case
        fl = 1;
        idx = randperm(length(alph),K);
    end
end
X_M_prc = X_M(:,idx);

D_c = struct();
for i = 1:n_rep
    aux = X_M_prc(:,randperm(length(idx),K));
    aux = bsxfun(@rdivide,aux,sqrt(sum(aux.^2)));
    D_c(i).Num = aux;
end
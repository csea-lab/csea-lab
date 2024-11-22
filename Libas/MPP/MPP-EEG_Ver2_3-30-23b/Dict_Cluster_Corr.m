function D_new = Dict_Cluster_Corr(PhEv,D_idx,K,D_old,eps)
% Inputs
% PhEv - all detected events
% D_idx - list of dictionary indices for each event
% K - number of dictionary atoms
% D_old - old dictionary to be updated
% eps - threshold for convergence(optional, default value = 10^-4)
% Outputs
% D_new - Updated Dictionary 

if nargin == 4
    eps = 10^-4;
end

D_new = struct();
dist_K = cell(1,K);
for i = 1:K
    idx = find(D_idx == i);
    if isempty(idx) == 1
        D_new(i).cent = D_old(:,i);
       
    elseif numel(idx) == 1
        a = PhEv(:,idx);
        D_new(i).cent = a - mean(a);
    elseif numel(idx) > 1 && numel(idx) <= 5
        % Use regular svd, correntropy svd not necessary
        a = PhEv(:,idx);
        [aux,~,~] = svds(a,1);
        D_new(i).cent = aux - mean(aux);
        
        c = bsxfun(@times,sign(D_new(i).cent'*a),a);
        dist_K{1,i} = sum(bsxfun(@minus,D_new(i).cent,c).^2,1);
    else
        % Robust Correntropy SVD, if computations are a limitation, use
        % regular svd instead, but it won't be robust anymore
        a = PhEv(:,idx);
        %[aux,~,~] = svds(a,1);
        [aux,~,~] = MCC_SVD(a,eps);
        D_new(i).cent = aux - mean(aux);
        
        c = bsxfun(@times,sign(D_new(i).cent'*a),a);
        dist_K{1,i} = sum(bsxfun(@minus,D_new(i).cent,c).^2,1); 
    end
end

end
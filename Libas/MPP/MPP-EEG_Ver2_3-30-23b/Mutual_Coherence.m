function mu = Mutual_Coherence(D)

K = size(D,2);

if K == 1
    mu = NaN;
else
    ct_c = 1;
    aux_coh = zeros(0,0);
    for i = 1:K-1
        for j = i+1:K
            aux_coh(ct_c) = D(:,i)'*D(:,j);
            ct_c = ct_c + 1;
        end
    end
    mu = max(abs(aux_coh));
end

end
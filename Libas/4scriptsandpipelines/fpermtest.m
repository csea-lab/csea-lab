%make a whole bunch of randomization of 1 through 8 
Fmaxvec = []; 
repeatmat = permute(squeeze(mat4d_movingavg(:, :, :, 1:7)), [2, 1, 3, 4]);
weights = mexweights; 

for x = 1:4000
testrand(x,:) = randperm(7); 
end

%run the actual thing

for run = 1:4000
    
repeatmat_perm = repeatmat; 

for person = 1:20
repeatmat_perm(:, person,:, :) = repeatmat(:, person, :, testrand(ceil(rand(1,1) .* 3999),:));
end
    
for time = 1:64, [Fcontmat_b(:, time),rcontmat_b(:,time),MScont_b(:,time),MScs_b(:,time), dfcs_b(:,time)]=contrast_rep(squeeze(repeatmat_perm(:, :, time,:)),weights);end

% Fmaxvec(run) = quantile(quantile(Fcontmat_b,.99), .99); % for many time points:control for time and topo

 Fmaxvec(:, run) = quantile(Fcontmat_b,.99); % for less than ~100 time points: control for multiple comparisons along all electrodes
 
 % clustersize = 3
 % can't average F values but can average variances:
tempMS1 =  mat2vec(movingavg_as(MScont_b', 3));
tempMS2 =  mat2vec(movingavg_as(MScs_b', 3));

 Fmaxvec_cluster(:, run) = quantile(tempMS1./tempMS2,.99);
 

if run./100 == round(run./100), fprintf([num2str(run) '_']), end

end

[Fcrit_indivsensor] = quantile(mat2vec(Fmaxvec), .95);
[Fcrit_custer3sensors] = quantile(mat2vec(Fmaxvec_cluster), .95);
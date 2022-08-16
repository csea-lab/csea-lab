% alon_stats
filemat = getfilesindir(pwd, '*at.pow3.mat')
filemat_intrus = (filemat(2:2:end,:))
filemat_corr = (filemat(1:2:end,:))

% make the axis just in case
taxis = -600:2:500-2;
faxisall = 0:1000/1100:250;
faxis = faxisall(4:1:35);

% average them
avgmat_coll_intrus_pli = avgmats_mat(filemat_intrus, 'GM21avgPLI_intrus.mat');
avgmat_coll_corr_pli = avgmats_mat(filemat_corr, 'GM21avgPLI_corr.mat');

plidiff = avgmat_coll_intrus_pli-avgmat_coll_corr_pli; 

% plot the averages   
for channel = 1:30   
    subplot(3,1,1), contourf(taxis, faxis, squeeze(avgmat_coll_intrus_pli(channel, :, :))'), colorbar
    subplot(3,1,2), contourf(taxis, faxis, squeeze(avgmat_coll_corr_pli(channel, :, :))'), colorbar
    subplot(3,1,3), contourf(taxis, faxis, squeeze(plidiff(channel, :, :))'), colorbar
    title(num2str(channel))
    pause
end


% do the ttest
[ttestmatPlI, mat4d1, mat4d2] = ttest3d(filemat_intrus, filemat_corr, 1, []);

% plot the data
for channel = 1:30
contourf(taxis, faxis, squeeze(ttestmatPlI(channel, :, :))'), 
title(num2str(channel)), colorbar, pause, 
end

% Calculate t-thresholds
[critTmax, critTmin] = ttest3d_withperm(filemat_intrus, filemat_corr, 1, []);

% single trials are kept in the next one, for trial-based analysis across
% the entire sample.
% test.mat shoudl be 3_d and it has chan by time by trials of the raw time
% domain data. the remaining 4 D file has frequencies as the final
% dimension

%% single trial based stuff

%% build 3 D arrays
% first correct trials
outmatCor =[]; 
for subject = 1:size(filemat_combCor,1)   
   temp = load(deblank(filemat_combCor(subject,:))); 
   outmatCor = cat(3, outmatCor, temp.combmat);
end
 
% now intrusion trials
outmatInt =[]; 
for subject = 1:size(filemat_combInt,1)   
   temp = load(deblank(filemat_combInt(subject,:))); 
   outmatInt = cat(3, outmatInt, temp.combmat);
end

faxisall = 0:1000/1100:250;
faxis = faxisall(4:35);
taxis = -600:2:500-2; 

[WaPower4d_corr] = wavelet_app_matfiles_singtrials('outmatCor.mat', 500, 4, 35, 1);
[WaPower4d_intrus] = wavelet_app_matfiles_singtrials('outmatInt_r.mat', 500, 4, 35, 1);

[~, ~, ~, stats] = ttest(WaPower4d_intrus, WaPower4d_corr, 'Dim', 4);
 tstatarray = stats.tstat;

% plot the data
for channel = 1:30
contourf(taxis, faxis, squeeze(tstatarray(channel, :, :))'), 
title(num2str(channel)), colorbar, pause, 
end

%% stats with cluster-based crap
% with 20 people and doing this at the subject level, the cluster forming
% threshold is 0.05 -> t = 2.089; 
thres_mx = 2.089
thres_mn = -2.089

[ttestmatPlI] = ttest3d(filemat_intrus, filemat_corr, 1, []);

data = ttestmatPlI; 

 size_mx = []; sumDist_mx = [];
 size_mn = []; sumDist_mn = [];

for channel = 1:30
    
    datachan = squeeze(data(channel,:, :)); 
    
    biVec_mx = datachan > thres_mx; 
    cc_mx = bwconncomp(biVec_mx);
    
    biVec_mn = datachan < thres_mn;
    cc_mn = bwconncomp(biVec_mn);
    
    clustIdx_mx = cc_mx.PixelIdxList;
    
    labelmat_mx = labelmatrix(cc_mx); 
    labelmat_mn = labelmatrix(cc_mn);   
    
    % max t
    clustersize_mx = zeros(1, cc_mx.NumObjects); 
    clusterSums_mx = zeros(1, cc_mx.NumObjects);
        
    for clusterindex = 1:cc_mx.NumObjects   
        clustersize_mx(clusterindex) = sum(sum(sum(labelmat_mx == clusterindex)));
        clusterSums_mx(clusterindex) = sum(mat2vec(datachan(labelmat_mx == clusterindex)));
    end
    
    size_mx{channel} = [max(clustersize_mx)];
    sumDist_mx{channel} = [max(clusterSums_mx)];
    
    % min t 
   clustersize_mn = zeros(1, cc_mn.NumObjects); 
   clusterSums_mn = zeros(1, cc_mn.NumObjects);
   
   for clusterindex = 1:cc_mn.NumObjects   
       clustersize_mn(clusterindex) = sum(sum(sum(labelmat_mn == clusterindex)));
       clusterSums_mn(clusterindex) = sum(mat2vec(datachan(labelmat_mn == clusterindex)));
   end
   
   size_mn{channel} = [max(clustersize_mn)];
   sumDist_mn{channel} = [min(clusterSums_mn)];
   
   fprintf('.')
   
end




filemat_combCor = getfilesindir(pwd, '*CWD.acrossLag.mat')
filemat_combInt = getfilesindir(pwd, '*intrusion.acrossLag.mat')



%% Analysis per participant
% 1. participant loop - equalizes the number of trials for
% intrusion/correct, then runs the wavelet analysis
% with 500 sampling rate, starting from the 4th frequency up to the 35th
% frequency (for 1,100 ms, the frequency step is 0.909 (1000/1100). 
% the reference electrode is Oz

for person = 1:21
    
    data1_r = []; 
    data2_r = []; 
    
    filename1 = deblank(filemat_combInt(person,:));
    filename2 = deblank(filemat_combCor(person,:)); 
    
    temp1 = load(filename1); 
    temp2 = load(filename2);
    
    data1 = temp1.combmat;
    data2 = temp2.combmat;
    
    Ntrials = min(size(data1, 3), size(data2, 3)); 
    
    randvec1 = randperm(size(data1, 3)); 
    randvec2 = randperm(size(data2, 3)); 
    
    data1_r(:, :, 1:Ntrials) = data1(:, :, randvec1(1:Ntrials));
    data2_r(:, :, 1:Ntrials) = data2(:, :, randvec2(1:Ntrials)); 

    [WaPowerInt, PLI_int, PLIdiff_int] = wavelet_app_mat(data1_r, 500, 4, 35, 1, 27, filename1);
    [WaPowerCor, PLI_Cor, PLIdiff_Cor] = wavelet_app_mat(data2_r, 500, 4, 35, 1, 27, filename2);
 
end

%% Average, plot, t-test

% POWER
 filematpowInt = getfilesindir(pwd, '*intrusion.acrosslag.mat.pow3.mat')
 filematpowCor = getfilesindir(pwd, '*CWD.acrosslag.mat.pow3.mat')

taxis = -600:2:500-2;
faxisall = 0:1000/1100:250;
faxis = faxisall(4:1:35);

GMpowInt = avgmats_mat(filematpowInt); 
GMpowCor = avgmats_mat(filematpowCor); 
GMpowdiff = GMpowInt-GMpowCor; 

avgmat_coll_intrus_POW = avgmats_mat(filematpowInt, 'GM21avgPOW_intrus.mat');
avgmat_coll_corr_POW = avgmats_mat(filematpowCor, 'GM21avgPOW_corr.mat');

% do the ttest
[ttestmatPOW, mat4d1, mat4d2] = ttest3d(filematpowInt, filematpowCor, 1, []);

% plot the data

figure 
for channel = 1:30   
    subplot(3,1,1), contourf(taxis, faxis, squeeze(GMpowInt(channel, :, :))'), colorbar
    subplot(3,1,2), contourf(taxis, faxis, squeeze(GMpowCor(channel, :, :))'), colorbar
    subplot(3,1,3), contourf(taxis, faxis, squeeze(GMpowdiff(channel, :, :))'), colorbar
    title(num2str(channel))
    pause
end

for channel = 1:30
    
contourf(taxis, faxis, squeeze(ttestmatPOW(channel, :, :))'), 
title(num2str(channel)), colorbar, pause, 
end

%[critTmax, critTmin] = ttest3d_withperm(filematpowInt, filematpowCor, 1, []);
CritMin = -3.1145
CritMax = 3.1116

%% if averaging across dimensions for more targeted t-tests

%this gives you the 4-D arrays with everything: 
[ttestmatPOW, mat4d1, mat4d2] = ttest3d(filematpowInt, filematpowCor, 1, []);

%the following is am example for avging across elecs, time, freqs: 
reducmat1 = squeeze(mean(mean(mean(mat4d1(19:20, 30:100, 10:12, :)))))
reducmat2 = squeeze(mean(mean(mean(mat4d2(19:20, 30:100, 10:12, :)))))
[~, ~, ~, stats] = ttest(reducmat1, reducmat2); 

%% Average, plot, t-test

% PLI
 filematPliInt = getfilesindir(pwd, '*intrusion.acrosslag.mat.pli3.mat')
 filematPliCor = getfilesindir(pwd, '*CWD.acrosslag.mat.pli3.mat')

taxis = -600:2:500-2;
faxisall = 0:1000/1100:250;
faxis = faxisall(4:1:35);

GMpliInt = avgmats_mat(filematPliInt); 
GMpliCor = avgmats_mat(filematPliCor); 
GMplidiff = GMpliInt-GMpliCor; 

avgmat_coll_intrus_PLI = avgmats_mat(filematPliInt, 'GM21avgPLI_intrus.mat');
avgmat_coll_corr_PLI = avgmats_mat(filematPliCor, 'GM21avgPLI_corr.mat');

% do the ttest
[ttestmatPLI, mat4d1, mat4d2] = ttest3d(filematPliInt, filematPliCor, 1, []);

% plot the data

figure 
for channel = 1:30   
    subplot(3,1,1), contourf(taxis, faxis, squeeze(GMpliInt(channel, :, :))'), colorbar
    subplot(3,1,2), contourf(taxis, faxis, squeeze(GMpliCor(channel, :, :))'), colorbar
    subplot(3,1,3), contourf(taxis, faxis, squeeze(GMplidiff(channel, :, :))'), colorbar
    title(num2str(channel))
    pause
end

for channel = 1:30
contourf(taxis, faxis, squeeze(ttestmatPLI(channel, :, :))'), 
title(num2str(channel)), colorbar, pause, 
end

[critTmax, critTmin] = ttest3d_withperm(filematPliInt, filematPliCor, 1, []);


%% Average, plot, t-test

% ispl3
 filematISPL3Int = getfilesindir(pwd, '*intrusion.acrosslag.mat.ispl3_27.mat')
 filematISPL3Cor = getfilesindir(pwd, '*CWD.acrosslag.mat.ispl3_27.mat')

taxis = -600:2:500-2;
faxisall = 0:1000/1100:250;
faxis = faxisall(4:1:35);

GMispl3Int = avgmats_mat(filematPliInt); 
GMispl3Cor = avgmats_mat(filematPliCor); 
GMispl3diff = GMispl3Int-GMispl3Cor; 

avgmat_coll_intrus_ISPL3 = avgmats_mat(filematISPL3Int, 'GM21avgISPL3_intrus.mat');
avgmat_coll_corr_ISPL3 = avgmats_mat(filematISPL3Cor, 'GM21avgISPL3_corr.mat');

% do the ttest
[ttestmatISPL3, mat4d1, mat4d2] = ttest3d(filematISPL3Int, filematISPL3Cor, 1, []);

% plot the data

figure 
for channel = 1:30   
    subplot(3,1,1), contourf(taxis, faxis, squeeze(GMispl3Int(channel, :, :))'), colorbar
    subplot(3,1,2), contourf(taxis, faxis, squeeze(GMispl3Cor(channel, :, :))'), colorbar
    subplot(3,1,3), contourf(taxis, faxis, squeeze(GMispl3diff(channel, :, :))'), colorbar
    title(num2str(channel))
    pause
end

for channel = 1:30
contourf(taxis, faxis, squeeze(ttestmatISPL3(channel, :, :))'), 
title(num2str(channel)), colorbar, pause, 
end

[critTmax, critTmin] = ttest3d_withperm(filematISPL3Int, filematISPL3Cor, 1, []);


%% SINGLE TRIAL POWER ANALYSIS 
% build 3 D arrays
% first correct trials
filemat_combCor = getfilesindir(pwd, '*CWD.acrossLag.mat')
filemat_combInt = getfilesindir(pwd, '*intrusion.acrossLag.mat')

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

Ntrials = min(size(outmatInt, 3), size(outmatCor, 3)); 
    
randvec1 = randperm(size(outmatInt, 3)); 
randvec2 = randperm(size(outmatCor, 3)); 
    
outmatInt_r(:, :, 1:Ntrials) = outmatInt(:, :, randvec1(1:Ntrials)); 
outmatCor_r(:, :, 1:Ntrials) = outmatCor(:, :, randvec2(1:Ntrials));

filename = sprintf('outmatInt_r.mat')
save(filename, 'outmatInt_r') 
filename = sprintf('outmatCor_r.mat')
save(filename, 'outmatCor_r') 

faxisall = 0:1000/1100:250;
faxis = faxisall(4:23);
taxis = -600:2:500-2; 

[WaPower4d_corr] = wavelet_app_matfiles_singtrials('outmatCor_r.mat', 500, 4, 23, 1);
[WaPower4d_intrus] = wavelet_app_matfiles_singtrials('outmatInt_r.mat', 500, 4, 23, 1);

[~, ~, ~, stats] = ttest(WaPower4d_intrus, WaPower4d_corr, 'Dim', 4);
 
tstatarray = stats.tstat;

% plot the data
for channel = 1:30
contourf(taxis, faxis, squeeze(tstatarray(channel, :, :))'), 
title(num2str(channel)), colorbar, pause, 
end

%%
% what is the critical value?

for draw = 1:10 
    
    WaPower4d_4perm = cat(4, WaPower4d_intrus,WaPower4d_corr);
       
    index1 = randperm(4926,2463);
    index2 = find(~ismember(1:4926, index1));
    
    fprintf('_')
               
    [~, ~, ~, stats] = ttest(WaPower4d_4perm(:, :, :,index1) , WaPower4d_4perm(:, :, :,index2), 'Dim', 4);
   
    fprintf('.')
    
    ttestmat = stats.tstat; 
       
    for channel = 1:30
        
        sortedmax = sort(mat2vec(ttestmat(channel,:, :)), 'descend');
        tmaxdist(channel, draw) = quantile(sortedmax, .98);
        
        sortedmin = sort(mat2vec(ttestmat(channel,:, :)), 'ascend');
        tmindist(channel, draw) = quantile(sortedmin, .02);
       
    end % channel  

end
    

%% stats with cluster-based 
% with 20 people and doing this at the subject level, the cluster forming
% threshold is 0.05 -> t = 2.089; 
 filematpowInt = getfilesindir(pwd, '*intrusion.acrosslag.mat.pow3.mat')
 filematpowCor = getfilesindir(pwd, '*CWD.acrosslag.mat.pow3.mat')

thres_mx = 2.089
thres_mn = -2.089

[ttestmatPOW] = ttest3d(filematpowInt, filematpowCor, 1, []);

data = ttestmatPOW; 

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

%% permutation control
filemat = getfilesindir(pwd, '*at.pow3.mat')

thres_mx = 2.089
thres_mn = -2.089

for draw = 1:500
    [ttestmat] = ttest3d(filematpowInt, filematpowCor, 1, []);
    
    data = ttestmat; 
    
    size_mx = []; sumDist_mx = [];
    size_mn = []; sumDist_mn = [];
    
    for channel = 30:30
        if channel == 13
            channel = channel + 1;
        elseif channel == 22
            channel = channel + 1;
        end
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

        size_mx(channel, draw) = max(0, max(clustersize_mx));
        sumDist_mx(channel, draw) = max(0, max(clusterSums_mx));
        
        
        % min t 
       clustersize_mn = zeros(1, cc_mn.NumObjects); 
       clusterSums_mn = zeros(1, cc_mn.NumObjects);
       
       for clusterindex = 1:cc_mn.NumObjects   
           clustersize_mn(clusterindex) = sum(sum(sum(labelmat_mn == clusterindex)));
           clusterSums_mn(clusterindex) = sum(mat2vec(datachan(labelmat_mn == clusterindex)));
       end
       
       size_mn(channel, draw) = max(0, max(clustersize_mx));
       sumDist_mn(channel, draw) = min(0, max(clusterSums_mx));
       channel
       
    end
end % draw

%% example for how to plot
test = rand(50,50);
indicesabove = find(test > .8);
indicesbelow = find(test < .2);
newmat = zeros(size(test));
newmat(indicesabove) = 1;
newmat(indicesbelow) = -1;
contourf(newmat)
%%
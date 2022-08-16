%% permutation control with cluster control
filemat = getfilesindir(pwd, '*at.pow3.mat');
filemat_intrus_orig = (filemat(2:2:end,:));
filemat_corr_orig = (filemat(1:2:end,:));

filemat_intrus = filemat_intrus_orig; 
filemat_corr = filemat_corr_orig; 

% these thresholds come from the t-distribution
thres_mx = 2;
thres_mn = -2;

size_mx = []; sumDist_mx = [];
size_mn = []; sumDist_mn = [];   

for draw = 1:500
        
    for subject = 1:size(filemat_intrus_orig, 1) % this is for within tests
        flipyesno = round(rand(1,1));
        if flipyesno == 1
         filemat_intrus(subject, :) = filemat_corr_orig(subject, :); 
         filemat_corr(subject, :) = filemat_intrus_orig(subject, :); 
        else
         filemat_intrus(subject, :) = filemat_intrus_orig(subject, :); 
         filemat_corr(subject, :) = filemat_corr_orig(subject, :);    
        end
    end

    [ttestmat] = ttest3d(filemat_intrus, filemat_corr, 1, []);
    
    data = ttestmat; 
       
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
        
        size_mx = [size_mx ifemptyzero(max(clustersize_mx))];
        sumDist_mx = [sumDist_mx ifemptyzero(max(clusterSums_mx))];
        
        % min t 
       clustersize_mn = zeros(1, cc_mn.NumObjects); 
       clusterSums_mn = zeros(1, cc_mn.NumObjects); 
       
       for clusterindex = 1:cc_mn.NumObjects   
           clustersize_mn(clusterindex) = sum(sum(sum(labelmat_mn == clusterindex)));
           clusterSums_mn(clusterindex) = sum(mat2vec(datachan(labelmat_mn == clusterindex)));
       end
       
       size_mn = [size_mn ifemptyzero(max(clustersize_mn))];
       sumDist_mn = [sumDist_mn ifemptyzero(min(clusterSums_mn))];
       
    end % channel  
    
    disp(' ')
    disp(draw)
    
end % draw

%% now the real data
filemat = getfilesindir(pwd, '*at.pow3.mat');
filemat_intrus = (filemat(2:2:end,:))
filemat_corr = (filemat(1:2:end,:))


% these thresholds come from the t-distribution
thres_mx = 2.089;
thres_mn = -2.089;

size_mx = []; sumDist_mx = [];
size_mn = []; sumDist_mn = [];   
      
    [ttestmat] = ttest3d(filemat_intrus, filemat_corr, 1, []);
    
    data = ttestmat; 
       
    for channel = 1:30
        
        datachan = squeeze(data(channel,:, :)); 
        
        biVec_mx = datachan > thres_mx; 
        cc_mx = bwconncomp(biVec_mx);
        
        biVec_mn = datachan < thres_mn;
        cc_mn = bwconncomp(biVec_mn);
        
        clustIdx_mx{channel} = cc_mx.PixelIdxList;
        clustIdx_mn{channel} = cc_mn.PixelIdxList;
        
        labelmat_mx = labelmatrix(cc_mx); 
        labelmat_mn = labelmatrix(cc_mn);   
        
        % positive ts
        clustersize_mx = zeros(1, cc_mx.NumObjects); 
        clusterSums_mx = zeros(1, cc_mx.NumObjects);
            
        for clusterindex = 1:cc_mx.NumObjects   
            clustersize_mx(clusterindex) = sum(sum(sum(labelmat_mx == clusterindex)));
            clusterSums_mx(clusterindex) = sum(mat2vec(datachan(labelmat_mx == clusterindex)));
        end
            
        clustersize_mx_out{channel} = clustersize_mx; 
        clusterSums_mx_out{channel} = clusterSums_mx; 
        
        % negative t 
       clustersize_mn = zeros(1, cc_mn.NumObjects); 
       clusterSums_mn = zeros(1, cc_mn.NumObjects); 
       
       for clusterindex = 1:cc_mn.NumObjects   
           clustersize_mn(clusterindex) = sum(sum(sum(labelmat_mn == clusterindex)));
           clusterSums_mn(clusterindex) = sum(mat2vec(datachan(labelmat_mn == clusterindex)));
       end
       
      clustersize_mn_out{channel} = clustersize_mn; 
      clusterSums_mn_out{channel} = clusterSums_mn; 
       
    end % channel   
    
    %% Blair and Karniski method
    % constrain frequencies
    freqvec = 1:20; % only thr first 20 frequencies which is 2.7 to 20 Hz in the below example
   
    filemat = getfilesindir(pwd, '*at.pow3.mat');
    filemat_intrus_orig = (filemat(2:2:end,:));
    filemat_corr_orig = (filemat(1:2:end,:));

    filemat_intrus = filemat_intrus_orig; 
    filemat_corr = filemat_corr_orig; 


for draw = 1:500
        
    for subject = 1:size(filemat_intrus_orig, 1) % this is for within tests
        flipyesno = round(rand(1,1));
        if flipyesno == 1
         filemat_intrus(subject, :) = filemat_corr_orig(subject, :); 
         filemat_corr(subject, :) = filemat_intrus_orig(subject, :); 
        else
         filemat_intrus(subject, :) = filemat_intrus_orig(subject, :); 
         filemat_corr(subject, :) = filemat_corr_orig(subject, :);    
        end
    end

    [ttestmat] = ttest3dfreq(filemat_intrus, filemat_corr, 1:20, 1, []);
    
    data = ttestmat; 
       
    for channel = 1:30
        
        sortedmax = sort(mat2vec(ttestmat(channel,:, :)), 'descend');
        tmaxdist(channel, draw) = quantile(sortedmax, .98);
        
        sortedmin = sort(mat2vec(ttestmat(channel,:, :)), 'ascend');
        tmindist(channel, draw) = quantile(sortedmin, .02);
       
    end % channel  
    
    disp(' ')
    disp(draw)
    
end % draw
    

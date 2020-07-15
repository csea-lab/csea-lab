% sensor downsample

% first find subset of 129 channel HCL that match closely the 65 HCL and
% deliver their indices, 
clear all
sens65 = ft_read_sens('GSN-HydroCel-65.sfp');
sens129 =  ft_read_sens('HC1-129.sfp');
count = 1; 

% for each sensor of the 129, find closest match in 65
for elc = 1:129
    
    for x = 1:65
        
    distmat = repmat(sens129.chanpos(elc+3, :), 65,1) - sens65.chanpos(4:end, :);
    distvec(x) = norm(distmat(x,:));
  
    end
    
 [ distance(elc), index(elc)  ]  = min(distvec); % this is the closest match for each of the 129, with one of the 65
 
find(distvec==0), pause, count = count+1

    
end
    
% Now find out which sensors in the 65 have zero distance with the 129
zerodistelecs = index(find(distance ==0))

% these are their indices in the 129 sensor arry 
indiceswrongorder = find(distance ==0)

% put them in correct order
indicesrightorder = indiceswrongorder(zerodistelecs)
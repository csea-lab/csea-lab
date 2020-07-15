% movgavg_smooth.m
function [outmat] = movavg_smooth_mat(filemat, tconstant); 

% each value oy outvec  is a weighted mean of the corresponding invec 
% values and its tconstant nearest neighbors in each direction.

for file = 1: size(filemat,1)
    
       [inmat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,SampRate]  = ReadAvgFile(deblank(filemat(file,:))); 


for index = 1:tconstant
    
    outmat(:, index) = 0.60.* mean(inmat(:, 1:tconstant), 2) + 0.20.* inmat(:, index); 
    
end


for index = tconstant+1 : size(inmat,2)-tconstant
    
    outmat(:, index) = mean(inmat(:, index-tconstant:index+tconstant), 2);

end


for index = size(inmat,2)-tconstant + 1 : size(inmat,2)
    
    outmat(:, index) = 0.65.* mean(inmat(:, size(inmat,2)-tconstant + 1 : size(inmat,2)), 2) + 0.20.* inmat(:, index); 
    
end


    
    % smooth transition between forward and symmetric filtered pieces of
    % the smoothed time series

%     
   	[B, A] = butter(2, 0.05);  % real filter for faces and IAPS
%    
     outmat = filtfilt(B, A, outmat'); 
     outmat = outmat'; 
     
     [File,Path,FilePath]=SaveAvgFile([deblank(filemat(file,:)) '.sm'],outmat,NTrialAvgVec,StdChanTimeMat, SampRate);
    
end
    
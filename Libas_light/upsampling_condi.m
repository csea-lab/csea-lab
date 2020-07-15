function upsampling_condi(filemat,sample_factor)

% code for upsampling through interpolation function
% sensors are input for which net is being used, sample_factor is the
% multiple needed to correctly upsample to the matched sampling rate, i.e.
% to upsample a 250Hz to a 500Hz sampling rate, sample_factor will be 2

for loop = 1:size(filemat,1)
    
    [AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat] = ReadAvgFile(deblank(filemat(1,:)));
    
        file = ReadAvgFile(deblank(filemat(loop,:)));
        [pathstr, name, ext] = fileparts(deblank(filemat(loop,:)));     % for naming of new file during saveavgfile
        
        a_up = [];
            for index = 1:size(AvgMat,1)
            vec = interp(file(index,:),sample_factor);
            a_up = [a_up; vec];
            end
            
        a_up = a_up(:,[1:size(a_up,2)-1]);  
        % added only because through upsampling, there is one additional
        % sample point in the file, so needs to be erased
            
    SaveAvgFile([name '.up' ext],a_up,NTrialAvgVec,StdChanTimeMat);
end
function [outmat] = app2singtrialalpha(filemat)


for fileindex = 1:size(filemat,1)
    
outmat = []; 
    
    [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate] = ReadAppData(deblank(filemat(fileindex,:))); 
     
    for trialindex = 1:NTrials; 
        
        [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate] = ReadAppData(deblank(filemat(fileindex,:)), trialindex); 
        
        % 
        [pow,freq] = FFT_spectrum(Data(:, [1050:1700]), 500);
        


        outmat(:,trialindex)  = mean(pow(:, 12:17),2);  % topography in alpha range
        
   
   
    end
    
    eval(['save ' deblank(filemat(fileindex,:)) 'alph.sing.mat outmat -mat'])

     fclose('all') 
     
end

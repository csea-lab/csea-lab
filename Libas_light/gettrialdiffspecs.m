function[powdiff] = gettrialdiffspecs(filemat);

for index = 1:size(filemat,1)
    
    [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
	ReadAppData(deblank(filemat(index,:))); 

        for trialindex = 1:NTrials; 
               [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
                ReadAppData(deblank(filemat(index,:)),trialindex); 
            
            [pow1, phase, freqs] = fft_spectrum(Data(:, 301:1300), SampRate ); 
            [pow2, phase, freqs] = fft_spectrum(Data(:, 1301:2300), SampRate); 
            
            powdiff = pow2-pow1; 
            
            SaveAvgFile([deblank(filemat(index,:)) '.at.' num2str(trialindex)],powdiff,[],[], ...
            2000)
            
            
        end
        
        fclose('all')
        
end


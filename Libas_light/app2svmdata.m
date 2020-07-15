function [dat4svmtrain, dat4svmtest, labelvectrain, labelvectest] = app2svmdata(filemat, labels)
labelvectrain= [];
labelvectest =[]; 
dat4svmtrain = []; 
dat4svmtest = []; 
% first check # of trials in each file
% then assign odd and even trials to train and test

for fileindex = 1:size(filemat,1)
    
    label = labels(fileindex);
    
    [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate] = ReadAppData(deblank(filemat(fileindex,:))); 
     
    for trialindex = 1:NTrials; 
        
        [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate] = ReadAppData(deblank(filemat(fileindex,:)), trialindex); 
        
        % feature extraction here - - by the user ...
        [pow,freq] = FFT_spectrum(Data, 250);
        
%         vec1 = mean(pow(70:2:87, 39:40),2); % posterior spectrum
%         vec2 = (pow(70:2:87, 49));
%         outvectemp = [vec1-vec2]; 

        outvectemp = (pow(:, 97));  % topography at 15 Hz
        
        outvectemp = (outvectemp-mean(outvectemp)) ./std(outvectemp);
       figure(1), plot(outvectemp),title(num2str(label)), pause(.5)
       % make sure it is a row vector
       if size(outvectemp,1) ~= 1, outvectemp = outvectemp'; end
       
       if trialindex./2 == floor(trialindex./2)
        dat4svmtrain  = [dat4svmtrain; outvectemp];
        labelvectrain = [labelvectrain; label];
       else
         dat4svmtest = [dat4svmtest; outvectemp];
        labelvectest = [labelvectest; label];      
       end
       
    end
    
    fclose('all') 
end

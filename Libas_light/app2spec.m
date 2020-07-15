%app2spec
% calculates spectra from apps
function[meanmag]=app2spec(appfilepath);

[Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials] = ReadAppData(appfilepath);

delta_f = 250/NPoints;

faxis = 0:delta_f:125;

magsum = []; 

for trialnum = 1:NTrials; 
    [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials] = ReadAppData(appfilepath,trialnum );
    
    b = fft(Data');
    mag = abs(b);
    mag = mag*4/NPoints;
    
    plot(faxis(2:40), mean(mag(2:40, 50:80) , 2))
    
    
    take(trialnum) = input('take?')
    
    if trialnum == 1 & take(trialnum) == 1
        magsum = mag;
    elseif take(trialnum) == 1
    magsum = magsum + mag;
    else magsum = magsum;
    end
    
end

meanmag = magsum ./ sum(take);

plot(faxis(2:40), mean(meanmag(2:40, 50:80) , 2))
    

function [ sumseg ] = Maeve_getCoherMotion(appfilepath,datfilepath, ifilepath  )
% this one finds coherent motion events insingle trials
% and aligns them before averaging them

% first read in all the data for this file for a suibject and condition
% 1.) Read the appfile to know the number of trials
[DataDummy,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate]=...
ReadAppData(appfilepath);
% 2.) load the datfile (log)... the onsets are in the 5th column
log = load(datfilepath); onsetindices = log(:,5)
% 3. load the index file taht has the indices of the trials in the appfile.
[trialindices] = ReadData(ifilepath,1,[],'ascii','ascii')

% now piece it together
for trialindex = 1:NTrials
    datatrial = ReadAppData(appfilepath, trialindex);
    onsetfromlog = onsetindices(trialindices(trialindex)); 
    onsetSPs = round((onsetfromlog*583-583)./2)+501
    segment = datatrial(:, onsetSPs:onsetSPs+899); 
    
    if trialindex==1
        sumseg = segment; 
    else
        sumseg = sumseg+segment
    end
    
    plot(sumseg'), pause
end
fclose('all')
    
    







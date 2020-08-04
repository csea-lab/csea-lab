% Scads2fieldtrip
function [timelock] = scads2fieldtrip(filemat, sens, timerange,bslrange); 

% sens is a structure arry imported by means of 
% [sens] = ft_read_sens('XXX.sfp')
% it has labels and pnts as separate elements.

if nargin < 4
    bslrange = 1:10; 
    disp('warning: first 10 samples used as baseline')
end

for index = 1:size(filemat)
    
    atfilepath = deblank(filemat(index,:)); 

[AvgMat,File,Path,FilePath,NTrialAvgVec,StdChanTimeMat,...
	SampRate,AvgRef,Version,MedMedRawVec,MedMedAvgVec,EegMegStatus,...
    NChanExtra,TrigPoint,HybridFactor,HybridDataCell,DataTypeVal]=ReadAvgFile(atfilepath);

AvgMat = bslcorr(AvgMat, bslrange); 

if ~isempty(timerange)
    timelock.avg = AvgMat(:, timerange)
    timelock.var        = [];
    timelock.fsample    = SampRate;
    timelock.numsamples = length(timerange)
    timelock.time       = [0:1000/SampRate:length(timerange)*4-4]/1000;
    timelock.label      = sens.label;
    timelock.dimord = 'chan_time';
else

    timelock.avg        = AvgMat;
    timelock.var        = [];
    timelock.fsample    = SampRate;
    timelock.numsamples = size(AvgMat,2);
    timelock.time       = [0:1000/SampRate:size(AvgMat,2)*4-4]/1000;
    timelock.label      = sens.label;
    timelock.dimord = 'chan_time';
end

timelock.elec = sens;


eval(['save ' atfilepath '.bsl.ftERP timelock'])

end
 
 
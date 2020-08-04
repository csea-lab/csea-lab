function EEG = app2eeglab(FilePath)

if nargin<1;
    FilterSpec='*.app*'; 
    [DefPath]=SetDefPath(1,FilterSpec);
    [File,Path,FilePath]=ReadFilePath('',DefPath,'Please choose an app file:');
end

[Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal]=...
	ReadAppData(FilePath,1);

appind = strfind(FilePath, 'app');
condition = FilePath((max(appind)+3):end);
EEG.setname = strcat('Imported data from', strrep(FilePath(max(strfind(FilePath, filesep))+1:length(FilePath)-4), '_', '-'));
EEG.filename = strcat(strrep(FilePath(max(strfind(FilePath, filesep))+1:max(strfind(FilePath, '.'))-1), '_', '-'), condition, '.set');
EEG.filepath = strcat(FilePath(1:max(strfind(FilePath, filesep))));
EEG.pnts = NPoints;
EEG.nbchan = NChan;
EEG.trials = NTrials;
EEG.srate = SampRate;
EEG.xmin = 0.001;
EEG.xmax = (1/SampRate) * NPoints;

if AvgRefStatus; EEG.averef = 'yes'; else EEG.averef = 'no'; end

for i = 1:EEG.trials
    if i == 1 
        EEG.data = Data;
        
    else 
        clc;
        fprintf('reading trial %g\n', i);
        [Data,Version,LHeader,ScaleBins,NChan,NPoints,NTrials,SampRate,AvgRefStatus,File,Path,FilePath,EegMegStatus,NChanExtra,AppFileFormatVal] = ReadAppData(FilePath, i);
        EEG.data = cat(3, EEG.data, Data);
    end 
end





% reads channel locations
[NoUse,BasePath]=SepFilePath(which('emegs2d.m'));
ECfgFilePath=[BasePath,'emegs2dUtil',filesep,'SensorCfg',filesep,GetDefEcfgFile(NChan)];
if isequal(filesep, '\'); 
    printecfgfilepath=strrep(ECfgFilePath, filesep, strcat(filesep, filesep));
else
    printecfgfilepath=ECfgFilePath;
end
fprintf(strcat('read channel locations from \n', printecfgfilepath, '\n'));

[NChan,SpherRadius,EPosSpher,ENames,EConfigFile,EConfigPath,EConfigFilePath]=ReadEConfig(ECfgFilePath);
theta=EPosSpher(:,1);
phi=EPosSpher(:,2);
SpherRadiustmp=1;
[X_Out]=change_sphere_cart([theta,phi],SpherRadiustmp,1);
XYZdata = [1:NChan; X_Out(:,[1 2 3])']';
fid=fopen([EEG.filepath 'dummy.xyz'], 'w');
for i= 1:NChan
    fprintf(fid, '%g\t%g\t%g\t%g\t%s\n', XYZdata(i,:), ENames(i,:));
end
fclose(fid);
EEG.chanlocs = readlocs([EEG.filepath 'dummy.xyz']);








% reads epoch information
for i=1:EEG.trials
    EEG.event(i).latency=EEG.pnts*(i-1);
    EEG.event(i).type = FilePath(max(strfind(FilePath, '.'))+4:length(FilePath));
    EEG.event(i).epoch=i;    
end








%EEG.comments: [8x150 char]

%EEG.rt = [];
%EEG.eventdescription: {1x5 cell}
EEG.epochdescription = {};
%EEG.specdata = [];
%EEG.specicaact = [];
%EEG.reject: [1x1 struct]
%EEG.reject: [1x1 struct]
%EEG.stats: [1x1 struct]
EEG.splinefile = [];
EEG.ref = 'common';
%EEG.history: [7x138 char]
%EEG.urevent: [1x154 struct]
%EEG.times: [1x384 double]


EEG.icawinv=[];%: [32x32 double]
EEG.icasphere=[]; %: [32x32 double]
EEG.icaweights=[]; %: [32x32 double]
EEG.icaact=[]; %: []




EEG = eeg_checkset( EEG );
outfile=strcat(EEG.filepath, EEG.filename);
fprintf('saving %s\n\n', outfile);
save(outfile, 'EEG');



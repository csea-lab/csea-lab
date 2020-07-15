function EEG = app2fieldtrip(FilePath)

if nargin<1;
    FilterSpec='*.app*'; 
    [DefPath]=SetDefPath(1,FilterSpec);
    [File,Path,FilePath]=ReadFilePath('',DefPath,'Please choose an app file:');
end

EEG = app2eeglab(FilePath);
EEG = eeglab2fieldtrip(EEG, 'preprocessing', 'none');


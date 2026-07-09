function [picturenamelist_subject,trialamp,winmat3d,phasestabmat,trialSNR ] = getsingtrialSSVEP_RDK(trialsg_filemat, dat_filemat, artifactlog_filemat)


for fileindex = 1:size(trialsg_filemat,1)

    % load the three components/files
    EEGdata = load(trialsg_filemat(fileindex,:)); 
    tabledata = readtable(dat_filemat(fileindex,:));
    artifactdata = load(artifactlog_filemat(fileindex,:));

    % get the actual list of picture names, in order
    picturenamelist_subject = table2cell(tabledata(:,8)); 
    picturenamelist_subject(artifactdata.artifactlog.badtrialstotal) = []; 

    % now do the single trial ssvep amplitude
    [trialamp,winmat3d,phasestabmat,trialSNR] = freqtag_slidewin(EEGdata.Mat3D, 0, 1:100, 1759:4700, 8.57, 600, 500, trialsg_filemat(fileindex,1:7));

    % save the output we need
   eval(['save ' trialsg_filemat(fileindex,1:7) 'freqtag.mat  trialamp phasestabmat  trialSNR -mat'])

end
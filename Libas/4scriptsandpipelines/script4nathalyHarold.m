% 1. get the specfiles across 6000 seconds, for data quality check

specfilemat1 = getfilesindir(pwd, '*csd.at1.ar.spec1');
specfilemat2 = getfilesindir(pwd, '*csd.at2.ar.spec1');

MergeAvgFiles(specfilemat1,'GMcsdspec.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2,'GMcsdspec.at2.ar',1,1,[],0,[],[],0,0)

% separately by order group
order1 = [1:10,22,23]; %face at 5 Hz, gabor(at1) or nothing(at2) at 7.5 Hz
order2 = [11:21,24]; %face at 7.5 Hz, gabor(at1) or nothing(at2) at 5 Hz

MergeAvgFiles(specfilemat1(order1,:),'GMOrder1csdspec1.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order1,:),'GMOrder1csdspec1.at2.ar',1,1,[],0,[],[],0,0)

MergeAvgFiles(specfilemat1(order2,:),'GMOrder2csdspec1.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order2,:),'GMOrder2csdspec1.at2.ar',1,1,[],0,[],[],0,0)

% actually these look quite good ¯\_(?)_/¯

%% FFTs for data analysis, in three overlapping windows
get_FFT_atg(pwd, 501:1700); % move result in other folder
get_FFT_atg(pwd, 1401:2600); % move result in other folder
get_FFT_atg(pwd, 2301:3500); % move result in other folder

%%
% 3. get the specfiles across 2400 seconds, in three windows
% window 1; it is one folder
specfilemat1 = getfilesindir(pwd, '*csd.at1.ar.spec');
specfilemat2 = getfilesindir(pwd, '*csd.at2.ar.spec');

MergeAvgFiles(specfilemat1,'GMcsdspec1.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2,'GMcsdspec1.at2.ar',1,1,[],0,[],[],0,0)

% separately by order group
order1 = [1:10,22,23]; %face at 5 Hz, gabor(at1) or nothing(at2) at 7.5 Hz
order2 = [11:21,24]; %face at 7.5 Hz, gabor(at1) or nothing(at2) at 5 Hz

MergeAvgFiles(specfilemat1(order1,:),'GMOrder1csdspec1.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order1,:),'GMOrder1csdspec1.at2.ar',1,1,[],0,[],[],0,0)

MergeAvgFiles(specfilemat1(order2,:),'GMOrder2csdspec1.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order2,:),'GMOrder2csdspec1.at2.ar',1,1,[],0,[],[],0,0)

%%
% % window 2; it is another folder
specfilemat1 = getfilesindir(pwd, '*csd.at1.ar.spec');
specfilemat2 = getfilesindir(pwd, '*csd.at2.ar.spec');

MergeAvgFiles(specfilemat1,'GMcsdspec2.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2,'GMcsdspec2.at2.ar',1,1,[],0,[],[],0,0)

% separately by order group
order1 = [1:10,22,23]; %face at 5 Hz, gabor(at1) or nothing(at2) at 7.5 Hz
order2 = [11:21,24]; %face at 7.5 Hz, gabor(at1) or nothing(at2) at 5 Hz

MergeAvgFiles(specfilemat1(order1,:),'GMOrder1csdspec2.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order1,:),'GMOrder1csdspec2.at2.ar',1,1,[],0,[],[],0,0)

MergeAvgFiles(specfilemat1(order2,:),'GMOrder2csdspec2.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order2,:),'GMOrder2csdspec2.at2.ar',1,1,[],0,[],[],0,0)

%%
% % window 3; it is in yet another folder
specfilemat1 = getfilesindir(pwd, '*csd.at1.ar.spec');
specfilemat2 = getfilesindir(pwd, '*csd.at2.ar.spec');

MergeAvgFiles(specfilemat1,'GMcsdspec3.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2,'GMcsdspec3.at2.ar',1,1,[],0,[],[],0,0)

% separately by order group
order1 = [1:10,22,23]; %face at 5 Hz, gabor(at1) or nothing(at2) at 7.5 Hz
order2 = [11:21,24]; %face at 7.5 Hz, gabor(at1) or nothing(at2) at 5 Hz

MergeAvgFiles(specfilemat1(order1,:),'GMOrder1csdspec3.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order1,:),'GMOrder1csdspec3.at2.ar',1,1,[],0,[],[],0,0)

MergeAvgFiles(specfilemat1(order2,:),'GMOrder2csdspec3.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order2,:),'GMOrder2csdspec3.at2.ar',1,1,[],0,[],[],0,0)

%% SNRs
% in each folder, get SNR - I changed getsnrspec by adding 1 to spec and polyfit 
filemat = getfilesindir(pwd, '*.spec')
[SpecSNR, expmodmat, freqs] = getsnrspec(filemat, 2:30, [5 7.5 10 15], 250, 1);

%%
% 4. average the SNRs
% window 1; it is one folder
specfilemat1 = getfilesindir(pwd, '*at1.ar.spec.SNR.at');
specfilemat2 = getfilesindir(pwd, '*at2.ar.spec.SNR.at');

% separately by order group
order1 = [1:10,22,23]; %face at 5 Hz, gabor(at1) or nothing(at2) at 7.5 Hz
order2 = [11:21,24]; %face at 7.5 Hz, gabor(at1) or nothing(at2) at 5 Hz

MergeAvgFiles(specfilemat1(order1,:),'GMOrder1csdspec1_SNR.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order1,:),'GMOrder1csdspec1_SNR.at2.ar',1,1,[],0,[],[],0,0)

MergeAvgFiles(specfilemat1(order2,:),'GMOrder2csdspec1_SNR.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order2,:),'GMOrder2csdspec1_SNR.at2.ar',1,1,[],0,[],[],0,0)

%%
% % window 2; it is another folder
specfilemat1 = getfilesindir(pwd, '*at1.ar.spec.SNR.at');
specfilemat2 = getfilesindir(pwd, '*at2.ar.spec.SNR.at');

% separately by order group
order1 = [1:10,22,23]; %face at 5 Hz, gabor(at1) or nothing(at2) at 7.5 Hz
order2 = [11:21,24]; %face at 7.5 Hz, gabor(at1) or nothing(at2) at 5 Hz

MergeAvgFiles(specfilemat1(order1,:),'GMOrder1csdspec2_SNR.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order1,:),'GMOrder1csdspec2_SNR.at2.ar',1,1,[],0,[],[],0,0)

MergeAvgFiles(specfilemat1(order2,:),'GMOrder2csdspec2_SNR.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order2,:),'GMOrder2csdspec2_SNR.at2.ar',1,1,[],0,[],[],0,0)

%%
% % window 3; it is in yet another folder
specfilemat1 = getfilesindir(pwd, '*at1.ar.spec.SNR.at');
specfilemat2 = getfilesindir(pwd, '*at2.ar.spec.SNR.at');

% separately by order group
order1 = [1:10,22,23]; %face at 5 Hz, gabor(at1) or nothing(at2) at 7.5 Hz
order2 = [11:21,24]; %face at 7.5 Hz, gabor(at1) or nothing(at2) at 5 Hz

MergeAvgFiles(specfilemat1(order1,:),'GMOrder1csdspec3_SNR.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order1,:),'GMOrder1csdspec3_SNR.at2.ar',1,1,[],0,[],[],0,0)

MergeAvgFiles(specfilemat1(order2,:),'GMOrder2csdspec3_SNR.at1.ar',1,1,[],0,[],[],0,0)
MergeAvgFiles(specfilemat2(order2,:),'GMOrder2csdspec3_SNR.at2.ar',1,1,[],0,[],[],0,0)


%%
% combine faces and gabors for each order
% do this for each window, i.e. 1 2 3 
clear
window = 1; 

filemat = getfilesindir(pwd, '*.SNR.at')
order1 = [1:20,43:46]; %face at 5 Hz, gabor(at1) or nothing(at2) at 7.5 Hz
order2 = [21:42,47,48]; %face at 7.5 Hz, gabor(at1) or nothing(at2) at 5 Hz

% 5 Hz = bin 13; 7.5 Hz = bin 19; 10 Hz = bin 25; 15 Hz = bin 37
for x = 1:size(filemat,1); 
    temp = ReadAvgFile(filemat(x,:)); 
    if ismember(x, order1); 
        facefund(:, x)  = temp(:, 13); 
        gaborfund(:,x) = temp(:,19); 
    else
        facefund(:, x)  = temp(:, 19);
        gaborfund(:,x) = temp(:,13);
    end
end
  
facefund1 = facefund(:, 1:2:end);
facefund2 = facefund(:, 2:2:end);
gaborfund1 = gaborfund(:, 1:2:end);
gaborfund2 = gaborfund(:, 2:2:end);

SaveAvgFile(['Facefundamental_spec' num2str(window) '.at1'],facefund1); 
SaveAvgFile(['Facefundamental_spec' num2str(window) '.at2'],facefund2);
SaveAvgFile(['Gaborfundamental_spec' num2str(window) '.at1'],gaborfund1); 
SaveAvgFile(['Gaborfundamental_spec' num2str(window) '.at2'],gaborfund2);
       
% and for the harmonic
for x = 1:size(filemat,1); 
    temp = ReadAvgFile(filemat(x,:));
    if ismember(x, order1); 
        faceharmon(:, x)  = temp(:, 25);
        gaborharmon(:,x) = temp(:,37); 
    else
        faceharmon(:, x)  = temp(:, 37);
        gaborharmon(:,x) = temp(:,25);
    end
end

faceharmon1 = faceharmon(:, 1:2:end);
faceharmon2 = faceharmon(:, 2:2:end);
gaborharmon1 = gaborharmon(:, 1:2:end);
gaborharmon2 = gaborharmon(:, 2:2:end);

SaveAvgFile(['Faceharmonic_spec' num2str(window) '.at1'],faceharmon1); 
SaveAvgFile(['Faceharmonic_spec' num2str(window) '.at2'],faceharmon2);
SaveAvgFile(['Gaborharmonic_spec' num2str(window) '.at1'],gaborharmon1); 
SaveAvgFile(['Gaborharmonic_spec' num2str(window) '.at2'],gaborharmon2);


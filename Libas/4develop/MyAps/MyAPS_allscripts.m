% MYAPS SCRIPT

% Begins with preprocessing for eeg data, followed by alpha processing, LPP extraction,
% pupil processing, and behavioral ratings extraction

% alternative codes needed, found in MyAps_Scripts folder on Github
% getcon_MyAPS1: for first iteration preprocessing and pupil
% getcon_MyAPS2: for second iteration preprocessing and pupil
% getcon_singtrials_MyAPS1: for first iteration single picture preprocessing
% getcon_MyAPS2_singletrial: for second iteration single picture preprocessing


% getcon_MyAPS_Behavior: for getting the rating values by condition for
% iteration 1
% getcon_MyAPS2_rate: for getting the rating values by condition for
% iteration 2
% getcon_MyAPS1_affspace: for getting the rating values by picture for
% iteration 1
% getcon_MyAPS2_affspace: for getting the rating values by picture for
% iteration 2


%%
% First, preprocessing by condition 
% MyAPS1

clear

cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/data'

% Get a list of all files and folders in the current directory
files = dir("myaps*_5*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);

% loop over subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

   delete *.at*
   delete *.mat*

    logpath = getfilesindir(pwd, '*myaps*.dat');
    datapath = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
    [EEG_allcond] = prepro_scadsandspline_log(datapath, logpath, 'getcon_MyAPS1', ...
        9, {'11' '12' '13' '21' '22' '23'}, [-0.6 2], [.2 25], [3 9], 1, 'GSN-HydroCel-129.sfp', 'HC1-128.ecfg'); 

    cd ..

    pause(.5)
    fclose('all');

end
%%
% Condition preprocessing
% Now MyAPS2

clear

cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/data'

% Get a list of all files and folders in the current directory
files = dir("myAPS2*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);

% loop over subjects
for subindex = 5:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

   delete *.at*
   delete *.mat*

    logpath = getfilesindir(pwd, '*myaps*.dat');
    datapath = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
    [EEG_allcond] = prepro_scadsandspline_log(datapath, logpath, 'getcon_MyAPS2', ...
        9, {'11' '12' '13' '21' '22' '23'}, [-0.6 2], [.2 25], [3 9], 1, 'GSN-HydroCel-129.sfp', 'HC1-128.ecfg'); 

    cd ..

    pause(.5)
    fclose('all');

end

%%
% Next, preprocessing for individual pictures
% MyAPS1

clear

% change directory to folder with data
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/data'

% Get a list of all files and folders in the current directory
files = dir("myaps_5*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);

% loop over subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

   delete *.at*
   delete *.mat*

    logpath = getfilesindir(pwd, '*.dat');
    datapath = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
    [EEG_allcond] = prepro_scadsandspline_singletrial(datapath, logpath, 'getcon_singtrials_MyAPS1', ...
        9, {'11205', '11205', '11270', '11270', '11419', '11419', '11510', '11510', '11604', '11604', '11640', '11640', '12010', '12010', '12045', '12045', '12092', '12092', '12110', '12110', '12300', '12300', '12314', '12314', '12446', '12446', '12484', '12484', '12499', '12499', '12540', '12540', '12550', '12550', '12580', '12580', '12850', '12850', '12900', '12900', '13016', '13016', '13051', '13051', '13101', '13101', '13230', '13230', '14001', '14001', '14150', '14150', '14180', '14180', '14210', '14210', '14232', '14232', '14505', '14505', '14534', '14534', '14574', '14574', '14597', '14597', '14601', '14601', '14604', '14604', '14628', '14628', '14770', '14770', '15395', '15395', '15455', '15455', '15470', '15470', '15551', '15551', '15600', '15600', '15661', '15661', '15665', '15665', '15779', '15779', '16211', '16211', '16940', '16940', '17186', '17186', '17405', '17405', '17451', '17451', '19075', '19075', '19140', '19140', '19300', '19300', '19430', '19430', '19491', '19491', '19570', '19570', '19630', '19630', '19900', '19900', '19905', '19905', '19909', '19909', '21205', '21205', '21270', '21270', '21419', '21419', '21510', '21510', '21604', '21604', '21640', '21640', '22010', '22010', '22045', '22045', '22092', '22092', '22110', '22110', '22300', '22300', '22314', '22314', '22446', '22446', '22484', '22484', '22499', '22499', '22540', '22540', '22550', '22550', '22580', '22580', '22850', '22850', '22900', '22900', '23016', '23016', '23051', '23051', '23101', '23101', '23230', '23230', '24001', '24001', '24150', '24150', '24180', '24180', '24210', '24210', '24232', '24232', '24505', '24505', '24574', '24574', '24601', '24601', '24604', '24604', '24628', '24628', '24770', '24770', '25395', '25395', '25455', '25455', '25470', '25470', '25551', '25551', '25600', '25600', '25661', '25661', '25665', '25665', '25779', '25779', '25910', '25910', '26211', '26211', '26940', '26940', '27186', '27186', '27405', '27405', '27451', '27451', '27502', '27502', '29075', '29075', '29140', '29140', '29300', '29300', '29430', '29430', '29491', '29491', '29570', '29570', '29630', '29630', '29900', '29900', '29905', '29905', '29909', '29909'}, [-0.6 2], [.2 25], [3 9], 1, 'GSN-HydroCel-128.sfp', 'HC1-128.ecfg'); 


    cd ..

    pause(.5)
    fclose('all');

end

%%
% Picture preprocessing 
% Now MyAPS2

clear

% change directory to folder with data
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/data'

% Get a list of all files and folders in the current directory
files = dir("MyAPS2*");

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);

% loop over subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

   delete *.at*
   delete *.mat*

    logpath = getfilesindir(pwd, '*log*.dat');
    datapath = getfilesindir(pwd, '*.RAW');

    % actual preprocessing
    [EEG_allcond] = prepro_scadsandspline_singletrial(datapath, logpath, 'getcon_MyAPS2_singletrial', ...
        10, {'1101', '1102', '1103', '1104', '1105', '1106', '1107', '1108', '1109', '1110', '1111', '1112', '1113', '1114', '1115', '1116', '1117', '1118', '1119', '1120', '1121', '1122', '1123', '1124', '1125', '1126', '1127', '1128', '1129', '1130', '1131', '1132', '1133', '1134', '1135', '1136', '1137', '1138', '1139', '1140', '1201', '1202', '1203', '1204', '1205', '1206', '1207', '1208', '1209', '1210', '1211', '1212', '1213', '1214', '1215', '1216', '1217', '1218', '1219', '1220', '1221', '1222', '1223', '1224', '1225', '1226', '1227', '1228', '1229', '1230', '1231', '1232', '1233', '1234', '1235', '1236', '1237', '1238', '1239', '1240', '1301', '1302', '1303', '1304', '1305', '1306', '1307', '1308', '1309', '1310', '1311', '1312', '1313', '1314', '1315', '1316', '1317', '1318', '1319', '1320', '1321', '1322', '1323', '1324', '1325', '1326', '1327', '1328', '1329', '1330', '1331', '1332', '1333', '1334', '1335', '1336', '1337', '1338', '1339', '1340', '2101', '2102', '2103', '2104', '2105', '2106', '2107', '2108', '2109', '2110', '2111', '2112', '2113', '2114', '2115', '2116', '2117', '2118', '2119', '2120', '2121', '2122', '2123', '2124', '2125', '2126', '2127', '2128', '2129', '2130', '2131', '2132', '2133', '2134', '2135', '2136', '2137', '2138', '2139', '2140', '2201', '2202', '2203', '2204', '2205', '2206', '2207', '2208', '2209', '2210', '2211', '2212', '2213', '2214', '2215', '2216', '2217', '2218', '2219', '2220', '2221', '2222', '2223', '2224', '2225', '2226', '2227', '2228', '2229', '2230', '2231', '2232', '2233', '2234', '2235', '2236', '2237', '2238', '2239', '2240', '2301', '2302', '2303', '2304', '2305', '2306', '2307', '2308', '2309', '2310', '2311', '2312', '2313', '2314', '2315', '2316', '2317', '2318', '2319', '2320', '2321', '2322', '2323', '2324', '2325', '2326', '2327', '2328', '2329', '2330', '2331', '2332', '2333', '2334', '2335', '2336', '2337', '2338', '2339', '2340'}, [-0.6 2], [.2 25], [3 9], 1, 'GSN-HydroCel-129.sfp', 'HC1-128.ecfg'); 

    cd ..

    pause(.5)
    fclose('all');

end

% END PREPROCESSING

%%

% BEGIN ALPHA
% Create pow3 files from the mat files
% Requires that all mat files be moved into a separate folder
%

% ALPHA

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/eeg/matfiles'

totalaxis = 0:0.3846:40;faxis = totalaxis(10:3:80);taxis = -598:2:2000;

filemat = getfilesindir(pwd, '*mat*');

[WaPower, PLI, PLIdiff] = wavelet_app_matfiles(filemat, 500, 10, 80, 3, 100:200, []);

%%

% Visualize time frequency, iteration 1

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/eeg/powfiles'
filemat = getfilesindir(pwd, 'myaps_*pow3*');

% no baseline correction
[avgmatALL] = avgmats_mat(filemat, 'v1_gmall.pow3.mat');
figure, contourf(taxis(100:end-50), faxis, squeeze(mean(avgmatALL([62 72 75 61 78 60 85 67 77 66 84 70 83 71 76], (100:end-50), :)))', 15); colorbar; caxis([1 6]); % no bsl time freq plot

avgmattest = squeeze(mean(avgmatALL(:, :, 7:9), 3)); 
SaveAvgFile('v1_gm_nobsl.at',avgmattest,[],[], 500,[],[],[],[],1); % this saves the file to disk and you can open with emegs2d and then emegs3d.

% baseline corrected
[outWaMatALL] = bslcorrWAMat_div(avgmatALL, 100:200);
figure, contourf(taxis(100:end-50), faxis, squeeze(mean(outWaMatALL([62 72 75 61 78 60 85 67 77 66 84 70 83 71 76], 100:end-50, :)))', 15); colorbar; caxis([0.7 1.2]);

tempALL = squeeze(mean(outWaMatALL(:, :, 7:9), 3)); 
SaveAvgFile('v1_gm_bsl.at',tempALL,[],[], 500,[],[],[],[],1); % visualize baseline corrected topographies. This saves the file to disk and you can open with emegs2d and then emegs3d.

%%

% Visualize time frequency, iteration 2

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/eeg/powfiles'
filemat = getfilesindir(pwd, 'myaps2_*pow3*');

% no baseline correction
[avgmatALL] = avgmats_mat(filemat, 'v2_gmall.pow3.mat');
figure, contourf(taxis(100:end-50), faxis, squeeze(mean(avgmatALL([62 72 75 61 78 60 85 67 77 66 84 70 83 71 76], (100:end-50), :)))', 15); colorbar; caxis([1 6]); % no bsl time freq plot

avgmattest = squeeze(mean(avgmatALL(:, :, 7:9), 3)); 
SaveAvgFile('v2_gm_nobsl.at',avgmattest,[],[], 500,[],[],[],[],1); % this saves the file to disk and you can open with emegs2d and then emegs3d.

% baseline corrected
[outWaMatALL] = bslcorrWAMat_div(avgmatALL, 100:200);
figure, contourf(taxis(100:end-50), faxis, squeeze(mean(outWaMatALL([62 72 75 61 78 60 85 67 77 66 84 70 83 71 76], 100:end-50, :)))', 15); colorbar; caxis([0.7 1.2]);

tempALL = squeeze(mean(outWaMatALL(:, :, 7:9), 3)); 
SaveAvgFile('v2_gm_bsl.at',tempALL,[],[], 500,[],[],[],[],1); % visualize baseline corrected topographies. This saves the file to disk and you can open with emegs2d and then emegs3d.

%%
% Now, extract alpha values from 500-1500ms, separate for each iteration

filemat2 = getfilesindir(pwd, 'myaps2_7*')
filemat1 = getfilesindir(pwd, 'myaps_5*')
[alpha1]  = extractstats_TF(filemat1, 6, 550:1050, 7:9, [62 72 75 61 78 60 85 67 77 66 84 70 83 71 76], []);
[alpha2]  = extractstats_TF(filemat2, 6, 550:1050, 7:9, [62 72 75 61 78 60 85 67 77 66 84 70 83 71 76], []);

% Calculate effect size
alphav1 = zeros(1, 45, 6);
alphav1(1, :, :) = alpha1;
alphav2 = zeros(1, 43, 6);
alphav2(1, :, :) = alpha2;

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(alphav1(:, :, 1:3),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(alphav1(:, :, 4:6),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(alphav2(:, :, 1:3),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(alphav2(:, :, 4:6),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)

% END ALPHA
%% 

% BEGIN LPP
% Extract LPP from 400-800ms, separate for each iteration
% CONDITION
%

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/eeg/atfiles'

filemat1 = getfilesindir(pwd, 'myaps_5*')
filemat2 = getfilesindir(pwd, 'myaps*_7*')

%bsl
[lpp1] = extractstats(filemat1, 6, [37 87 53 54 55 79 86 61 78 62], 500:700, 250:300)
[lpp2] = extractstats(filemat2, 6, [37 87 53 54 55 79 86 61 78 62], 500:700, 250:300)

%nobsl
[lpp1] = extractstats(filemat1, 6, [37 87 53 54 55 79 86 61 78 62], 500:700, [])
[lpp2] = extractstats(filemat2, 6, [37 87 53 54 55 79 86 61 78 62], 500:700, [])

%lpp
lppv1 = zeros(1, 45, 6);
lppv1(1, :, :) = lpp1;
lppv2 = zeros(1, 43, 6);
lppv2(1, :, :) = lpp2;

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(lppv1(:, :, 1:3),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(lppv1(:, :, 4:6),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(lppv2(:, :, 1:3),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(lppv2(:, :, 4:6),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)

%%

% LPP Single Trial and Correlations

% Set up directory and picture labels
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/eeg/singletrialmatfiles'
load('PIC_V1.mat');
load('PIC_V2.mat');
load('PIC_V1_Scatter.mat');
load('PIC_V2_Scatter.mat');

%% Version 2 only
indexvec = [];
picindex = [];
pic_str = []; 
picindex = [];
filelist = getfilesindir(pwd, 'myaps2*.at*');

for i = 1:length(PIC_V2);
    indexvec = [];
    pic_str = num2str(PIC_V2(i));
        for x = 1:size(filelist, 1);
            picindex = strfind(filelist(x, :), pic_str); if~isempty(picindex), indexvec = [indexvec, x]; end
        end
    filelist(indexvec,:);
    output_filename = sprintf('myaps2_GMbypic_%s.at', pic_str);   
    MergeAvgFiles(filelist(indexvec, :),output_filename,1,1,[],0,[],[],0,0);
end

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/eeg/singletrialGMs'
filelist = getfilesindir(pwd, 'myaps2*.at*');

outmatall2 = []
indexvec = [];
picindex = [];
pic_str = []; 
picindex = [];

for i = 1:length(PIC_V2);
    indexvec = [];
    pic_str = num2str(PIC_V2(i));
        for x = 1:size(filelist, 1);
            picindex = strfind(filelist(x, :), pic_str); if~isempty(picindex), indexvec = [indexvec, x]; end
        end
    [outmat] = extractstats(filelist(indexvec,:), 1, [37 87 53 54 55 79 86 61 78 62], 500:700, 250:300);
    outmatall2 = [outmatall2 outmat]
end


%% Version 1 only
picindex = [];
pic_str = []; 

filelist = getfilesindir(pwd, 'myaps_5*.at*');

for i = 1:length(PIC_V1);
    indexvec = [];
    pic_str = num2str(PIC_V1(i));
        for x = 1:size(filelist, 1);
            picindex = strfind(filelist(x, :), pic_str); if~isempty(picindex), indexvec = [indexvec, x]; end
        end
    filelist(indexvec,:);
    output_filename = sprintf('myaps_GMbypic_%s.at', pic_str);   
    MergeAvgFiles(filelist(indexvec, :),output_filename,1,1,[],0,[],[],0,0);
end

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/eeg/singletrialGMs'
filelist = getfilesindir(pwd, 'myaps_G*.at*');

outmatall1 = [];
indexvec = [];
picindex = [];
pic_str = []; 
picindex = [];

for i = 1:length(PIC_V1);
    indexvec = [];
    pic_str = num2str(PIC_V1(i));
        for x = 1:size(filelist, 1);
            picindex = strfind(filelist(x, :), pic_str); if~isempty(picindex), indexvec = [indexvec, x]; end
        end
    [outmat] = extractstats(filelist(indexvec,:), 1, [37 87 53 54 55 79 86 61 78 62], 500:700, 250:300);
    outmatall1 = [outmatall1 outmat]
end

%%

% correlations
outmat1 = outmatall1'
outmat2 = outmatall2'

corrv1=corrcoef(outmat1(1:60,1), outmat1(61:120,1))
corrv2=corrcoef(outmat2(1:120,1), outmat2(121:240,1))

figure
hold on
h1 = scatter(outmat1(1:60,1), outmat1(61:120,1), 100, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'Marker', 'o');
text(outmat1(1:60,1), outmat1(61:120,1), num2str(PIC_V1_Scatter), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 16, 'FontWeight', 'bold');
hold off

figure
hold on
h1 = scatter(outmat2(1:120,1), outmat2(121:240,1), 100, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'Marker', 'o', 'DisplayName', 'Original Pleasant');
text(outmat2(1:120,1), outmat2(121:240,1), num2str(PIC_V2_Scatter), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 16, 'FontWeight', 'bold');
hold off

% END LPP

%%

% BEGIN PUPIL
% Conditions
%
%

% PUPIL, preprocessing
clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/pupil/Data'

% make matrices that match, start wit myaps 1
filemat_edf = getfilesindir(pwd, 'MyAp5*edf');
filemat_dat = getfilesindir(pwd, 'myaps5*');

for subject = 1:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_MyAPS1', filemat_dat(subject,:), 'cue_on', 250, 2000, []);   

end

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/pupil/Data'
% myaps 2
filemat_edf = getfilesindir(pwd, 'MyA2*edf');
filemat_dat = getfilesindir(pwd, 'myaps2*');

for subject = 1:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_MyAPS2', filemat_dat(subject,:), 'cue_on', 250, 2000, 0);   

end

%% this is for the averaging

% MyAPS1
% VISUALIZE
clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/pupil/Conditions/pupmatfiles'
filemat1 = getfilesindir(pwd, 'MyAp*out.mat');

data = []; 
figure

for subject = 1:size(filemat1,1)

    temp = load(filemat1(subject,:));
    datatemp = temp.matout; 

    cali1 = mean(mean(datatemp)); 
    
    if subject >= 25
        datatransform = (datatemp./cali1).*1000;
        [data] = bslcorr(datatransform', 1:250)';
    else subject < 25
        [data] = bslcorr(datatemp', 1:250)';
    end

    % hold on
    % plot(data(:, 1), 'b')
    % plot(data(:, 2), 'k')
    % plot(data(:, 3), 'r')
    % plot(data(:, 5), 'b--')
    % plot(data(:, 6), 'k--')
    % plot(data(:, 7), 'r--')
    % pause
    % hold off
    % clf

      if subject ==1 
        v1grand_sum = data; 
    else
        v1grand_sum = v1grand_sum + data; 
    end

end

v1grand_mean = v1grand_sum./size(filemat1,1); 

% EXTRACT STATS
% Create matrix for pupil data + baseline correct
pupilmat =[]; 
filemat1 = getfilesindir(pwd, 'MyAp*out.mat');

for x = 1:size(filemat1)
temp = load(filemat1(x,:)); datatemp = temp.matout; cali1 = mean(mean(datatemp));

    if x >= 25
        datatransform = (datatemp./cali1).*1000;
        [data] = bslcorr(datatransform(:, 1:8)', 1:250)';
    else x < 25
        [data] = bslcorr(datatemp(:, 1:8)', 1:250)';
    end

datanew = (data*10)/5222
pupilmat(:, :, x) = datanew; 

end

% average across timepoints
v1_gm_time = []
v1_gm_time(:, :) = mean(pupilmat(751:1751, :, :));
pupil1 = v1_gm_time'

pupilv1 = zeros(1, 59, 8);
pupilv1(1, :, :) = pupil1;

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(pupilv1(:, :, 1:3),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(pupilv1(:, :, 5:7),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)

%% MyAPS2
% VISUALIZE
clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/pupil/Conditions/pupmatfiles'
filemat2 = getfilesindir(pwd, 'MyA2*out.mat');
data = [];

for subject = 1:size(filemat2,1)

    temp = load(filemat2(subject,:));
    datatemp = temp.matout;     
    [data] = bslcorr(datatemp', 1:250)';
    
    % hold on
    % plot(data(:, 1), 'b')
    % plot(data(:, 2), 'k')
    % plot(data(:, 3), 'r')
    % plot(data(:, 4), 'b--')
    % plot(data(:, 5), 'k--')
    % plot(data(:, 6), 'r--')
    % pause
    % hold off
    % clf

      if subject ==1 
        v2grand_sum = data; 
    else
        v2grand_sum = v2grand_sum + data; 
    end

end

v2grand_mean = v2grand_sum./size(filemat2,1); 

% EXTRACT STATS
% Create matrix for pupil data + baseline correct
pupilmat =[]; 
filemat2 = getfilesindir(pwd, 'MyA2*out.mat');
for x = 1:size(filemat2)
temp = load(filemat2(x,:)); [matout_all] = bslcorr(temp.matout(:, 1:6)', 1:250)'
datanew = (matout_all*10)/5222
pupilmat(:, :, x) = datanew; 
fprintf('.');
end
disp('done')

% average across timepoints
v2_gm_time = []
v2_gm_time(:, :) = mean(pupilmat(751:1251, :, :));
pupil2 = v2_gm_time'

pupilv2 = zeros(1, 46, 6);
pupilv2(1, :, :) = pupil2;

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(pupilv2(:, :, 1:3),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(pupilv2(:, :, 4:6),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)


%% for the validation 
filemat = getfilesindir(pwd, '*.edf');

outvec =[];

for x = 1:size(filemat,1)

test = Edf2Mat(filemat(x,:));

disp(filemat(x,:))
disp("this is the mean:")
disp(mean(test.Samples.pupilSize(test.Samples.pupilSize~=0)))

outvec(filemat) = mean(test.Samples.pupilSize(test.Samples.pupilSize~=0));

end

%%

% Single trial

% PUPIL, preprocessing

cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/pupil/Data'

% make matrices that match, start wit myaps 1
filemat_edf = getfilesindir(pwd, 'MyAp5*edf');
filemat_dat = getfilesindir(pwd, 'myaps5*');

for subject = 1:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_singtrials_MyAPS1', filemat_dat(subject,:), 'cue_on', 250, 2000, []);   

end

% myaps 2
filemat_edf = getfilesindir(pwd, 'MyA2*edf');
filemat_dat = getfilesindir(pwd, 'myaps2*');

for subject = 1:size(filemat_dat,1)

 [matcorr, matout, matoutbsl, percentbadvec, percentbadsub, percentbadcond] = eye_pipeline(filemat_edf(subject,:), 500, 'getcon_MyAPS2_singletrial', filemat_dat(subject,:), 'cue_on', 250, 2000, 0);   

end

%%

% Pupil, correlations

% EXTRACT STATS
% Create matrix for pupil data + baseline correct

cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/pupil/Singletrials/pupmatfiles'
clear

% VERSION 2

pupilmat =[]; 
filemat2 = getfilesindir(pwd, 'MyA2*out.mat');
for x = 1:size(filemat2)
temp = load(filemat2(x,:)); [matout_all] = bslcorr(temp.matout(:, 1:240)', 1:250)';
datanew = (matout_all*10)/5222;
pupilmat(:, :, x) = datanew; 
fprintf('.');
end
disp('done')

% average across timepoints
v2_gm_time = []
v2_gm_time(:, :) = mean(pupilmat(751:1251, :, :));
v2_gm_time = v2_gm_time'

% correlations
GM_allppl(:) = mean(v2_gm_time(1:46, :))

ORpic_v2 = GM_allppl(1, 1:120)'
AIpic_v2 = GM_allppl(1, 121:240)'

corrv2=corrcoef(ORpic_v2, AIpic_v2)'

% VERSION 1
clear 

pupilmat =[]; 
filemat1 = getfilesindir(pwd, 'MyAp*out.mat');

for x = 1:size(filemat1)
temp = load(filemat1(x,:)); datatemp = temp.matout; cali1 = mean(mean(datatemp));

    if x >= 25
        datatransform = (datatemp./cali1).*1000;
        [data] = bslcorr(datatransform(:, 1:120)', 1:250)';
    else x < 25
        [data] = bslcorr(datatemp(:, 1:120)', 1:250)';
    end

datanew = (data*10)/5222;
pupilmat(:, :, x) = datanew; 

end

% average across timepoints
v1_gm_time = []
v1_gm_time(:, :) = mean(pupilmat(751:1751, :, :));
v1_gm_time = v1_gm_time'

% correlations
GM_allppl(:) = mean(v1_gm_time(1:59, :))

ORpic_v1 = GM_allppl(1, 1:60)'
AIpic_v1 = GM_allppl(1, 61:120)'

corrv1=corrcoef(ORpic_v1, AIpic_v1)'

% END PUPIL
%%

% BEGIN RATINGS


% Ratings, by condition
% MyAPS2

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/ratings'

datFiles = dir('*myaps2*.dat');
numFiles = length(datFiles);
numMetrics = 6; % Number of elements in each statvec
results = zeros(numFiles, 2 * numMetrics); % Preallocate for efficiency

% Loop through each .dat file
for i = 1:length(datFiles)
    % Get the full path of the .dat file
    fileName = datFiles(i).name;
    
    % Call the function and pass the file name as input
    [condvec, picvec, statvec_aro, statvec_val, arousal, valence] = getcon_MyAPS2_rate(fileName);
    
    % Display or store the result if needed
    fprintf('Processed file: %s\n', fileName);
    % save results
    results(i, 1:numMetrics) = statvec_aro;         % Columns 1-6 = pleasant_original, neutral_original, unpleasant_original, pleasant_AI, neutral_AI, unpleasant_AI
    results(i, numMetrics+1:end) = statvec_val;     % Columns 7-12 = pleasant_original, neutral_original, unpleasant_original, pleasant_AI, neutral_AI, unpleasant_AI
end

arousal2 = results(:, 1:6);
valence2 = results(:, 7:12);


%%
% Ratings, by condition
% MyAPS1

clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/ratings'

% Version 1
datFiles = dir('*myaps5*.dat');
results = [];
numFiles = length(datFiles);
numMetrics = 6; % Number of elements in each statvec
results = zeros(numFiles, 2 * numMetrics); % Preallocate for efficiency

% Loop through each .dat file
for i = 1:length(datFiles)
    % Get the full path of the .dat file
    fileName = datFiles(i).name;
    
    % Call the function and pass the file name as input
    [condvec, picvec, statvec_aro, statvec_val] = getcon_MyAPS_Behavior(fileName);
    
    % Display or store the result if needed
    fprintf('Processed file: %s\n', fileName);
    % save results
    results(i, 1:numMetrics) = statvec_aro;         % Columns 1-6
    results(i, numMetrics+1:end) = statvec_val;     % Columns 7-12
end

arousal1 = results(:, 1:6);
valence1 = results(:, 7:12);

%%
% Effect size testing

%valence
valencev1 = zeros(1, 61, 6);
valencev1(1, :, :) = valence1;
valencev2 = zeros(1, 47, 6);
valencev2(1, :, :) = valence2;

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(valencev1(:, :, 1:3),[-1 0 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(valencev1(:, :, 4:6),[-1 0 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(valencev2(:, :, 1:3),[-1 0 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(valencev2(:, :, 4:6),[-1 0 1]);
fpdf(Fcontmat, 1, dfcs)


%arousal
arousalv1 = zeros(1, 61, 6);
arousalv1(1, :, :) = arousal1;
arousalv2 = zeros(1, 47, 6);
arousalv2(1, :, :) = arousal2;

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(arousalv1(:, :, 1:3),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(arousalv1(:, :, 4:6),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(arousalv2(:, :, 1:3),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)
[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep(arousalv2(:, :, 4:6),[1 -2 1]);
fpdf(Fcontmat, 1, dfcs)


%%
% Ratings, by picture with correlations

% Correlation script
clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/ratings'

% MyAPS2
filemat = getfilesindir(pwd, '*myaps2ratings*.dat')

outtable = []; 
outtablecontrol = []' 

for fileindex = 1:size(filemat,1)
    
    [singpicvec_num_sorted, val_sorted, aro_sorted] = getcon_MyAPS2_affspace(filemat(fileindex,:)); 
    
    outtable = [outtable val_sorted aro_sorted]; 
    outtablecontrol = [outtablecontrol singpicvec_num_sorted val_sorted aro_sorted]; 
    
end

% make scatter plot data table
meanval_v2 = mean(outtable(:, 1:2:end),2);
meanaro_v2 = mean(outtable(:, 2:2:end),2);
scattertable_v2 = [singpicvec_num_sorted meanval_v2 meanaro_v2]

% correlations
corrval_v2=corrcoef(scattertable_v2(1:120,2), scattertable_v2(121:240,2))
corraro_v2=corrcoef(scattertable_v2(1:120,3), scattertable_v2(121:240,3))

%%
% Ratings by picture with correlations
% MyAPS1
clear
cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/ratings'

filemat = getfilesindir(pwd, '*myaps5*.dat')

outtable = []; 
outtablecontrol = []'

for fileindex = 1:size(filemat,1)
    
   [picvec_sorted, val_sorted, aro_sorted] = getcon_MyAPS1_affspace(filemat(fileindex,:)); 
    outtable = [outtable val_sorted aro_sorted]; 
    outtablecontrol = [outtablecontrol picvec_sorted val_sorted aro_sorted]; 
    
end

% make scatter plot data table
meanval_v1 = mean(outtable(:, 1:2:end),2);
meanaro_v1 = mean(outtable(:, 2:2:end),2);

scattertable_v1 = [meanval_v1 meanaro_v1]

averaged_scatter = []
for i = 1:2:length(scattertable_v1)-1
    % Average the current row and the next row
    average_scatter = (scattertable_v1(i,:) + scattertable_v1(i+1,:)) / 2;
    averaged_scatter = [averaged_scatter; average_scatter];  % Append the result
end

% correlations
corrval_v1=corrcoef(averaged_scatter(1:60,1), averaged_scatter(61:120,1))
corraro_v1=corrcoef(averaged_scatter(1:60,2), averaged_scatter(61:120,2))

% END RATINGS

%% single trial picture based alpha analysis

% Version 2 only
indexvec = [];
picindex = [];
pic_str = []; 
picindex = [];
filelist = getfilesindir(pwd, 'myaps2*.trls*mat');

for i = 1:length(PIC_V2)
    indexvec = [];
    pic_str = num2str(PIC_V2(i));
        for x = 1:size(filelist, 1);
            picindex = strfind(filelist(x, :), pic_str); if~isempty(picindex), indexvec = [indexvec, x]; end
        end
    filemat = filelist(indexvec,:)
    output_filename = sprintf('myaps2_concatbypic_%s.mat', pic_str)

    [outmat] = concat_matfiles(filemat, output_filename);

    pause(1)
end


% Version 1 only
indexvec = [];
picindex = [];
pic_str = []; 
picindex = [];
filelist = getfilesindir(pwd, 'myaps_*.trls*mat');

for i = 1:length(PIC_V1)
    indexvec = [];
    pic_str = num2str(PIC_V1(i));
        for x = 1:size(filelist, 1);
            picindex = strfind(filelist(x, :), pic_str); if~isempty(picindex), indexvec = [indexvec, x]; end
        end
    filemat = filelist(indexvec,:)
    output_filename = sprintf('myaps1_concatbypic_%s.mat', pic_str)

    [outmat] = concat_matfiles(filemat, output_filename);

    pause(1)
end

%%
% Now process pow files

totalaxis = 0:0.3846:40;faxis = totalaxis(10:3:80);taxis = -598:2:2000;

filemat = getfilesindir(pwd, '*myaps1*');

[WaPower, PLI, PLIdiff] = wavelet_app_matfiles(filemat, 500, 10, 80, 3, 100:200, []);

% 

cd '/Users/faithgilbert/Desktop/1_MyAps/Paper/eeg/singletrialpowfiles'

filelist1 = getfilesindir(pwd, 'myaps1*.pow3.mat');
[outmat1] = extractstats_TF(filelist1, 120, 550:1050, 7:9, [62 72 75 61 78 60 85 67 77 66 84 70 83 71 76], []);

filelist2 = getfilesindir(pwd, 'myaps2*.pow3.mat');
[outmat2] = extractstats_TF(filelist2, 240, 550:1050, 7:9, [62 72 75 61 78 60 85 67 77 66 84 70 83 71 76], []);

 % correlations
outmat1 = outmat1';
outmat2 = outmat2';

corrv1=corrcoef(outmat1(1:60,1), outmat1(61:120,1))
corrv2=corrcoef(outmat2(1:120,1), outmat2(121:240,1))

%%
b_corrline = polyfit(outmat2(1:120,1), outmat2(121:240,1), 1);  % Ensure degree is 1 for linear regression

% Make scatter plots with corr lines
figure('Position', [1200,1200,1400,1400]), hold on
% Set axis limits
% xlim([400 1500]);
% xticks(400:200:1500);
% ylim([400 1500]);
% yticks(400:200:1500);

% Scatter plots
scatter(outmat2(1:120,1), outmat2(121:240,1), 300, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', 'o')
set(gca, 'FontSize', 40, 'FontWeight', 'bold', LineWidth=4);
xlabel('Original');
ylabel('AI');
title('Iteration 2');

% Set plot properties
set(gca, 'FontSize', 50, 'FontWeight', 'bold'); % Axis font size and weight

% Add regression lines
x_vals = -2:1:8; y_vals_corr = b_corrline(1) * x_vals + b_corrline(2); plot(x_vals, y_vals_corr, 'k--', 'LineWidth', 5);

hold off
% script for matfiles 3-d spec
cd /Users/andreaskeil/Desktop/Gaborgen_Laura/StartingPoint/Gaborgen24/MATFiles

filemat = getfilesindir(pwd, '*app*.mat');

timewinSP = 501:1500; %start after onset ERP
    
[spec] = get_FFT_mat3d(filemat, timewinSP, 500);

%[RESS_time] = RESS_mat(filemat, 51:97, timewinSP, 500, 15, 1);
% RESS does not seem to work well with extinction because few trials

% filemat = getfilesindir(pwd, '*RESSpow.mat');

%% script for CSD 3-d spec
cd /Users/andreaskeil/Desktop/Gaborgen_Laura/StartingPoint/Gaborgen24/CSDFiles

filemat = getfilesindir(pwd, '*csd.mat');

timewinSP = 501:1500; %start after onset ERP
    
[spec] = get_FFT_mat3d(filemat, timewinSP, 500);

%[RESS_time] = RESS_mat(filemat, 51:97, timewinSP, 500, 15, 1);
% RESS does not seem to work well with extinction because few trials

% filemat = getfilesindir(pwd, '*RESSpow.mat');


%% pipeline for RESS files
filemat = getfilesindir(pwd, '*.RESSpow.at');
mergemulticons(filemat, 14, 'GM31.RESSpow')
bin = 31

[repmat] = makerepmat(filemat, bin, 14, []);

mat4plot = squeeze(repmat(1, bin,:, [1 2 3 4 5 7 8 9 11 12 13 14]))


%% pipeline for mat and CSD spec files
filemat = getfilesindir(pwd, '*.spec');
mergemulticons(filemat, 14, 'GM31.3dspec.spec')

generMcteague = [1.75 1.25 0.25 -3.25];
generGauss = [1.5 .25 -0.75 -1.0];
sharp = [1.5 -1.0 -0.75 .25];

bin = 31;

[repmat] = makerepmat(filemat, bin, 14, []);

repmat = repmat(:, :, :, [1 2 3 4 5 7 8 9 11 12 13 14]);

mat4plot = squeeze(repmat(81, bin,:, :));
figure
bar(mean(mat4plot))

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, 5:8)), generGauss);

figure, plot(Fcontmat)

%% Bootstrapping



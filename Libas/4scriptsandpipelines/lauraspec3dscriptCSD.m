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

generMcteague = [1.25 .75 -0.75 -1.25];
generGauss = [1.5 .25 -0.75 -1.0];
sharp = [1.5 -1.0 -0.75 .25];

bin = 31;

[repmat] = makerepmat(filemat, bin, 14, []);

repmat = repmat(:, :, :, [1 2 3 4 5 7 8 9 11 12 13 14]);

mat4plot = squeeze(repmat(81, bin,:, :));
figure
bar(mean(mat4plot))

[Fcontmat_gauss,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, 5:8)), sharp);
[Fcontmat_sharp,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, 5:8)), generGauss);
[Fcontmat_mcteag,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, 5:8)), generMcteague);

figure(1), plot(Fcontmat_gauss), title('generalization')
figure(2), plot(Fcontmat_sharp),  title('sharpening')
figure(3), plot(Fcontmat_mcteag), title('McTeague')

%% Bootstrapping
% the models
generMcteague = [1.25 .75 -0.75 -1.25];
generGauss = [1.5 .25 -0.75 -1.0];
sharp = [1.5 -1.0 -0.75 .25];

bin = 31;

ndraws = 5000; 

% make bootstrap distributions of inner products: ACQUISITION
for draw = 1:ndraws

    if draw./100 == round(draw./100), sprintf('%s', ['draw: ' num2str(draw) ' of ' num2str(ndraws)]), end

    %for nullmodel:
    repmat_null = repmat; 
    for sub = 1:31 
        repmat_null(:, bin, sub, :) = repmat_null(:, bin, sub, randperm(12)) ;
    end

    innerprod_null(:, draw) = squeeze(mean(repmat_null(:, bin, randi(31, 1,31), 1:4), 3)) * generGauss(randperm(4))';

    % habituation
    innerprod_hab_sharp(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * sharp';
    innerprod_hab_gauss(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * generGauss';
    innerprod_hab_genMcTea(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * generMcteague';

     % acquisition
    innerprod_acq_sharp(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3)) * sharp';
    innerprod_acq_gauss(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3)) * generGauss';
    innerprod_acq_genMcTea(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3)) * generMcteague';
    
     % extinction
    innerprod_ext_sharp(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3)) * sharp';
    innerprod_ext_gauss(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3)) * generGauss';
    innerprod_ext_genMcTea(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3)) * generMcteague';


end

%% convert to BFs for each model and channel

for chan = 1:129

    BF_acq_gauss(chan) = bootstrap2BF(innerprod_acq_gauss(chan,:),innerprod_null(chan,:), 0);
    BF_acq_sharp(chan) = bootstrap2BF(innerprod_acq_sharp(chan,:),innerprod_null(chan,:), 0);
    BF_acq_genMcTea(chan) = bootstrap2BF(innerprod_acq_genMcTea(chan,:),innerprod_null(chan,:), 0);
end


for chan = 1:129

    BF_ext_gauss(chan) = bootstrap2BF(innerprod_ext_gauss(chan,:),innerprod_null(chan,:), 0);
    BF_ext_sharp(chan) = bootstrap2BF(innerprod_ext_sharp(chan,:),innerprod_null(chan,:), 0);
    BF_ext_genMcTea(chan) = bootstrap2BF(innerprod_ext_genMcTea(chan,:),innerprod_null(chan,:), 0);
end


%%
SaveAvgFile('BF_acq_gauss.at.ar', BF_acq_gauss');
SaveAvgFile('BF_acq_sharp.at.ar', BF_acq_sharp');
SaveAvgFile('BF_acq_genMcTea.at.ar', BF_acq_genMcTea');
SaveAvgFile('BF_ext_gauss.at.ar', BF_ext_gauss');
SaveAvgFile('BF_ext_sharp.at.ar', BF_ext_sharp');
SaveAvgFile('BF_ext_genMcTea.at.ar', BF_ext_genMcTea');


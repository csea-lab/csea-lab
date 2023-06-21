%% script for CSD 3-d spec
% if needed, make the csd files
cd /Users/andreaskeil/Desktop/Gaborgen_Laura/StartingPoint/Gaborgen24/CSDFiles

clear 

filemat = getfilesindir(pwd, '*.mat')

filemat = filemat(1:end,:);

for index = 1:size(filemat,1) 

    deblank(filemat(index,:))
    
    a = load(deblank(filemat(index,:))); 
    
    CSDarray = Array2Csd(a.outmat, 5, 'HC1-129.ecfg');
    
    eval(['save ' deblank(filemat(index,:)) '.csd.mat CSDarray -mat'])
    
end

%%

filemat = getfilesindir(pwd, '*csd.mat');

timewinSP = 501:1500; %start after onset ERP
    
[spec] = get_FFT_mat3d(filemat, timewinSP, 500);

%[RESS_time] = RESS_mat(filemat, 51:97, timewinSP, 500, 15, 1);
% RESS does not seem to work well with extinction because few trials

% filemat = getfilesindir(pwd, '*RESSpow.mat');


%% pipeline for mat and CSD spec files
filemat = getfilesindir(pwd, '*.spec');
mergemulticons(filemat, 14, 'GM31.3dspec.spec')

% the old models
%generMcteague = [1.25 .75 -0.75 -1.25];
%generGauss = [1.5 .25 -0.75 -1.0];
%sharp = [1.5 -1.0 -0.75 .25];

% the new models
allno = [3 -1 -1 -1];
gener = [1.75 1.25 -0.25 -2.75];
generGauss = [1.5 .25 -0.75 -1.0];
sharp = [1.75 -2.75 -0.25 1.25];


bin = 31;

[repmat] = makerepmat(filemat, bin, 14, []);

repmat = repmat(:, :, :, [1 2 3 4 5 7 8 9 11 12 13 14]);

mat4plot = squeeze(repmat(74, bin,:, :));
figure(99)
bar(mean(mat4plot))

[Fcontmat_allno,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, 5:8)), allno);
[Fcontmat_generGauss,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, 5:8)), generGauss);
[Fcontmat_gener,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, 5:8)), gener);
[Fcontmat_sharp,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, 5:8)), sharp);

figure(1), plot(Fcontmat_allno), title('all-nothing')
figure(2), plot(Fcontmat_gener),  title('generalization')
figure(3), plot(Fcontmat_sharp), title('sharpening')
figure(4), plot(Fcontmat_generGauss), title('Gaussian')

%% Bootstrapping
% the old models
%generMcteague = [1.25 .75 -0.75 -1.25];
%generGauss = [1.5 .25 -0.75 -1.0];
%sharp = [1.5 -1.0 -0.75 .25];

% the new models
allno = [3 -1 -1 -1];
gener = [1.75 1.25 -0.25 -2.75];
generGauss = [1.5 .25 -0.75 -1.0];
sharp = [1.75 -2.75 -0.25 1.25];

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

    innerprod_null(:, draw) = squeeze(mean(repmat_null(:, bin, randi(31, 1,31), 1:4), 3)) * gener(randperm(4))';

    % habituation
    innerprod_hab_sharp(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * sharp';
    innerprod_hab_gener(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * gener';
    innerprod_hab_allno(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * allno';

     % acquisition
    innerprod_acq_sharp(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3)) * sharp';
    innerprod_acq_gener(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3)) * gener';
    innerprod_acq_allno(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3)) * allno';
    
     % extinction
    innerprod_ext_sharp(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3)) * sharp';
    innerprod_ext_gener(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3)) * gener';
    innerprod_ext_allno(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3)) * allno';


end

%% convert to BFs for each model and channel

for chan = 1:129

    BF_acq_sharp(chan) = bootstrap2BF(innerprod_acq_sharp(chan,:),innerprod_null(chan,:), 0);
    BF_acq_gener(chan) = bootstrap2BF(innerprod_acq_gener(chan,:),innerprod_null(chan,:), 0);
    BF_acq_allno(chan) = bootstrap2BF(innerprod_acq_allno(chan,:),innerprod_null(chan,:), 0);
end


for chan = 1:129

    BF_ext_sharp(chan) = bootstrap2BF(innerprod_ext_sharp(chan,:),innerprod_null(chan,:), 0);
    BF_ext_gener(chan) = bootstrap2BF(innerprod_ext_gener(chan,:),innerprod_null(chan,:), 0);
    BF_ext_allno(chan) = bootstrap2BF(innerprod_ext_allno(chan,:),innerprod_null(chan,:), 0);
end


%%
SaveAvgFile('BF_acq_gener.at.csd', BF_acq_gener');
SaveAvgFile('BF_acq_sharp.at.csd', BF_acq_sharp');
SaveAvgFile('BF_acq_allno.at.csd', BF_acq_allno');
SaveAvgFile('BF_ext_gener.at.csd', BF_ext_gener');
SaveAvgFile('BF_ext_sharp.at.csd', BF_ext_sharp');
SaveAvgFile('BF_ext_allno.csd', BF_ext_allno');


% trial-based analysis 
%     (1) takes avg imag BOLD and cuts out the single trials using the single trial latency files.
%     (2) correlates each BOLD and alpha
%     (3) saves 3d BRIK corrs

% ========================================================== MB, Aug 2020
tic
lat_mat = getfilesindir('/Users/Maeve/Desktop/SimImag/00_redo/st.lat','*st.lat*');
nii_mat = getfilesindir('/Users/Maeve/Desktop/SimImag/00_redo/niftis/r4.nii/','*.nii');
wholebrain1141 = [];
alphavecALL = [];

for sub = 1:size(nii_mat,1)
    BOLDfile = nii_mat(sub,:);
    V = niftiread(BOLDfile);
    subNo = BOLDfile(1,1:3);
    lat_file = lat_mat(sub,:);
    timevec = load(['/Users/Maeve/Desktop/SimImag/00_redo/st.lat/' lat_file]);
    TRvec_all = round(timevec/3); % this gives TRs where the 1-TR baseline starts
%     maxforeachtrialmat=[];
    trialmat_bsl=[];
    meanforeachtrialmat = [];
    
    for trial = 1:length(TRvec_all)
        trialmat = V(:, :, :, TRvec_all(trial):TRvec_all(trial)+8); 
        trialbsl = repmat(trialmat(:, :, :, 1), [1 1 1 9]);
        trialmat_bsl = trialmat-trialbsl; % baseline corrected 3-d matrix for each trial
        meanforeachtrialmat(:, :, :, trial) = mean(trialmat_bsl(:, :, :, 5:7), 4) - mean(trialmat_bsl(:, :, :, 2:3), 4); % 
    end
    
% wholebrain1141 = cat(4, wholebrain1141, meanforeachtrialmat); % get one giant mat with BOLDcord x 1141 trials
% save([subNo '.mat'],'meanforeachtrialmat') % save subj BOLDcord x 1141 trials
%         maxforeachtrialmatALL1141 = cat(4, maxforeachtrialmatALL1141, maxforeachtrialmat);

% alpha
    load(['/Users/Maeve/Desktop/SimImag/00_redo/0_EEGalone.Final/2_S2eeg/' subNo '_3TW.mat'],'IRdiff9_13') % load the alpha data
    alpha = IRdiff9_13(1:31,1:size(timevec,1));
    alphavec = mean(alpha([7 8 19 31],:),1); 
    alphavecALL = [alphavecALL alphavec]; % get one giant vec with 1141 trials
           
    for xcor = 1:64
        for ycor = 1:76
            for zcor = 1:60
                [Spearman(xcor,ycor,zcor), pvalS(xcor,ycor,zcor)] = corr(squeeze(meanforeachtrialmat(xcor, ycor, zcor,:)),alphavec','type','Spearman');
            end % z
        end % y
    end % z
    
disp(['Subj ' subNo ' finished! Moving on...']) 
mat2BRIK('/Users/Maeve/Desktop/SimImag/00_redo/zz_Prepro/condition_files/202.CSPLINz.pls+tlrc.BRIK', 'whatever', Spearman)
end % subj
% save('/Users/Maeve/Desktop/SimImag/3_wholeBrain/2_allS2corrmat_brain.mat','Spearman');
disp(['Ok... I´m actually done now and it only took ' num2str(toc/60) ' minutes :))))))'])
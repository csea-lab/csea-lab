function [ inmat3d, badindex ] = Lisascottcontrolgroup;

% EEGLAB history file generated on the 06-Sep-2018
% ------------------------------------------------
filemat = [getfilesindir(pwd,[ '*.set'])]

for fileindex = 1:size(filemat,1); 
    
    %[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    filepath = deblank(filemat(fileindex,:));
    subj = filemat(fileindex,1:13)
    
    [ EEG ] = pop_loadset(filepath);
    EEG = pop_eegfiltnew(EEG, 1.5, 20, [], 0, [], 1);
    EEG = eeg_checkset( EEG ); 
    EEG = pop_epoch( EEG, {  }, [-1         7.4]);
   EEG = eeg_checkset( EEG );
   EEG = pop_rmbase( EEG, [-1000     0]);
   EEG = eeg_checkset( EEG );

   data3d = double(EEG.data); 
    
    [ inmat3d, badindex ] = scadsAK_3dtrials(data3d);
    
    [outmat3d, interpsensvec] = scadsAK_3dchan(inmat3d, EEG.chanlocs);
   
    outmat3d = avg_ref_3d(outmat3d);
% 
%     figure(1)
%     for sens = 1:129
%         plot(squeeze(outmat3d2(sens, :, :))), title([subj '_snsr' num2str(sens)]), pause(.25)
%     end

    ERP = mean(outmat3d, 3); 
    
    disp(['test: ' num2str(max(max((ERP))))])
    
    SaveAvgFile([subj '.ERP.at'],ERP,[],[], 500)
    [specavg, ~, freqs] = FFT_spectrum(ERP(:, 501:3500), 500);
    SaveAvgFile([subj '.at.spec'],specavg,[],[], 6000)
%     for sens = 68:89, 
%         plot(freqs(1:90), specavg(sens,1:90)), title([subj '_snsr' num2str(sens)]), pause(0.25)
%     end
    
    close all;
end



end



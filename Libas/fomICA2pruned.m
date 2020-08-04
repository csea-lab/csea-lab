function [ECGcomplog] = fomICA2pruned(filemat);
% to examine ICA components and project out just the HR component
    % if there is no HR component, enter 0 and the output is a 'NoECG.set'
% ECGcomplog is the record of all the HR components entered for the
% filemat. This function is currently set up to run one filemat/subj

% for the fom project, MB
% =======================================================================

% for the dialog box
prompt = 'ECG component?';
dlgtitle = 'ICA artifact correction';


bigname = zeros(121,1);
% load the set file, pause to look at the components, enter ECG component
% into dialog box, get weighted sum for ECG: trials x SP
for fileindex = 1:size(filemat,1)
    name = filemat(fileindex,1:6);
    cond = filemat(fileindex,18:22);
    bigname(fileindex,1) = str2double([name '.' cond]);
    
    filepath = deblank(filemat(fileindex,:));

    EEG = pop_loadset('filename', filepath)  % filepath,'filepath','/Users/Maeve/Desktop/FOM_HR/app_files/');
    EEG = eeg_checkset(EEG);
    data = EEG.data; 
    data2d = reshape(EEG.data, 129, size(data,2)*size(data,3)); 
   for x = 1:30, 
     subplot(5,6,x)
     plot(EEG.icaweights(x,:)*data2d(:, 1:3101*4)); title([name ' ' cond ' Comp ' num2str(x)])
%      title(num2str(x))
 %    vertmarks([2301 2301*2 2301*3])
   end
    
    
    answer = inputdlg(prompt,dlgtitle,[1 50]);
    ECGcomp = str2double(answer{1});
    if ECGcomp == 0 % if there is no HR component
       ECGcomplog(fileindex) = str2double(answer{1});
       EEG = pop_saveset(EEG, 'filepath', [filepath '_NoECG.temp']);
    else
        ECGcomp = str2double(answer{1});
        ECGcomplog(fileindex) = str2double(answer{1});
            for trial = 1:size(EEG.data,3)
                test(trial,:) = EEG.icaweights(ECGcomp,:) * squeeze(EEG.data(:, :, trial));
            end
        SaveAvgFile([filepath '_pruned.at'],test); 
    end
%     close all;

end
close all;
% a record of all ECG components in filemat (filemats by subj) (should be 12x1)
ECGcomplog = [bigname ECGcomplog'];
save('ECGlog_no', 'ECGcomplog')
function [datamat] = segmentNOAM(filemat)

[B,A] = butter(5,.15)

for fileindex = 1:size(filemat,1)
    
    filename = deblank(filemat(fileindex,:)) 
    outname = ['s' num2str(fileindex) '_' filename(1:5)]

        EEG = pop_fileio(['/Users/andreaskeil/Desktop/ssVEP_FibromyalgiaFromNate/AK_2nd_batch/data_raw/' filename], 'channels' , 1:16);
        EEG.setname=[filename '_set']; 
        datafilt = EEG.data; 
        datafilt = filtfilt(B, A, double(datafilt')); 
        EEG.data = datafilt'; 
        EEG = eeg_checkset( EEG );
       EEG = pop_epoch( EEG, {  'S 10'  'S 20'  'S 30'  }, [-4         7.5]);
        EEG = eeg_checkset( EEG );
       EEG = pop_rmbase( EEG, [-3400    -3000]);
       EEG = eeg_checkset( EEG );
        datamat = EEG.data; 
        eval(['save /Users/andreaskeil/Desktop/ssVEP_FibromyalgiaFromNate/AK_2nd_batch/eeglabdata/' outname ' datamat'])
        pause(1)
        clear EEG*
        clear ALL*
        pause(1)
        
end
        
        



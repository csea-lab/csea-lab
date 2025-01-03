function [datamat] = segmentETI(filemat)

[B,A] = butter(5,.15)

for fileindex = 1:size(filemat,1)
    
    filename = deblank(filemat(fileindex,:)) 
    outname = ['s' num2str(fileindex) '_' filename(1:5)]

        EEG = pop_loadbv('/Users/andreaskeil/As_Exps/Eti_sleep/SleepDepriv/', filename, [], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32]);
        EEG.setname=[filename '_set']; 
        datafilt = EEG.data; 
        datafilt = filtfilt(B, A, datafilt'); 
        EEG.data = datafilt'; 
        EEG = eeg_checkset( EEG );
       EEG = pop_epoch( EEG, {  'S 10'  'S 20'  'S 30'  }, [-3.4         7.2]);
        EEG = eeg_checkset( EEG );
       EEG = pop_rmbase( EEG, [-3400    -3000]);
       EEG = eeg_checkset( EEG );
        datamat = EEG.data; 
        eval(['save /Users/andreaskeil/As_Exps/Eti_sleep/SleepDeprivEEGLAB/' outname ' datamat'])
        pause(1)
        clear EEG*
        clear ALL*
        pause(1)
        
end
        
        



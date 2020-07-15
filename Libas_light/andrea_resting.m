function [specavg, freqs] = andrea_resting(filemat); 

for fileindex = 1:size(filemat,1); 
    
    filepath = deblank(filemat(fileindex,:))

           EEG = pop_fileio(filepath, 'channels',[1:8 10 11:16 19 20 22 23:25] );
            
           EEG = eeg_checkset( EEG );
            
            EEG=pop_chanedit(EEG, 'load',{'/Users/andreaskeil/Dropbox (UFL)/Grand Mean/karapasha21elecseeglabformat.ced'});
            
            data2d = EEG.data; 
            
            data2d = data2d(1:20,:); 
            
             [Blow,Alow] = butter(4, .3); 
    
             [Bhigh,Ahigh] = butter(2, 0.008, 'high'); 
	
            % flip AvgMat and filter over all channels
            orig = double(data2d)'; 

            % filter now
             lowpasssig = filtfilt(Blow,Alow, orig); 
             lowhighpasssig = filtfilt(Bhigh, Ahigh, lowpasssig);

             orig = lowhighpasssig';
             
             orig = orig(:,1:12000);
             
             datamat = reshape(orig, [20 600 20]);
             
             % artifact rejection
             
          [ datamat, NGoodtrials ] = scadsAK_3dtrials(datamat);
          
           % find and interpolate bad trials      
           [datamat, interpsensvec] =  scadsAK_3dchan(datamat, EEG.chanlocs);  
           
             
          datamat = avg_ref_3d(datamat);
           
           
        disp('done. percent good segments:')
        disp(NGoodtrials)
        disp(interpsensvec)

         [specavg, freqs] = FFT_spectrum3D(datamat, 1:600, 300);

          fsmapnew = 2000
    
    [File,Path,FilePath]=SaveAvgFile([filepath '.spec'],specavg,[],[], fsmapnew);


end % files


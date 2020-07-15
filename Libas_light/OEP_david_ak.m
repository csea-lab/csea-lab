       
function [data3d, data2d] = OEP_david_ak(rawfilepath, outname)
      
      temp = load(rawfilepath);
      
      data = temp.data; 
     
      onsets = temp.onsets; 
     
     disp('filtering data...')
     
     [fila, filb] = butter(2, 0.0001, 'high'); 
     
     data.streams.Rawx.data = filtfilt(fila, filb, double(data.streams.Rawx.data)')'; 
     
         [fila, filb] = butter(5, 0.0092, 'low'); 
         
     data.streams.Rawx.data = filtfilt(fila, filb, double(data.streams.Rawx.data)')';   
     
      disp('filtering done...')
      
      mat3d = [];  

     ttt = (1:size(data.streams.Rawx.data,2)) / data.streams.Rawx.fs;

     fs = data.streams.Rawx.fs;

    ONSET = -.4;
    DURATION = 2;
    
    t = ONSET:1/fs:DURATION-(abs(ONSET));

    % get chunk around onset
    for jj = 1:numel(onsets)
         ts = onsets(jj);
         onset_ind = find(ttt > ts, 1);
         start_ind = onset_ind + floor(ONSET * fs);
         stop_ind = start_ind + floor(DURATION * fs);
         mat3d(:, :, jj) = data.streams.Rawx.data(:, start_ind:stop_ind) * 1000;
    end
    
    size(mat3d)
    
    mat3d = mat3d.*1000; % convert from millivolts to microvolts
    
    [ data3d, NGoodtrials ] = scadsAK_3dtrials(mat3d);
    
    disp('percent trials kept:')
    disp(NGoodtrials./size(mat3d,3))
    
    data2d = mean(data3d,3); 
    
   % data2d = regressionMAT(data2d); 
    
    data2d  = bslcorr(data2d, [1000:2443]); 
       
    figure (99)   
    plot(t, data2d')
    
    figure (98)   
    plot(t, bslcorr(mean(data3d,3), 1000:2443)')
    
    SaveAvgFile([outname '.ERP.atg'], data2d, [], [], fs, [], [], [], [], 2443); 
    
   eval(['save ' outname '.data3d.mat data3d -mat'])
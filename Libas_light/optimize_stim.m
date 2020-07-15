function [pow,freqs] = optimize_stim(filemat, locations); 

for fileindex = 1:size(filemat,1); 
    
    filepath = deblank(filemat(fileindex,:))
    
    % read the data and take only 32 chans

    dataraw = ft_read_data(filepath); 

    dataraw = dataraw(1:32,:); 
    
    % artifact control

    [dataraw] =SCADS_AK(dataraw, locations); disp(size(dataraw))
    
    % avg reference

    dataraw = avg_ref_add(dataraw); 
    
    %filtering

    dataraw = dataraw(1:32,:)'; 

    [A, B] = butter(2, [0.001 .15]);

    datafilt = filtfilt(A, B, dataraw(:, 1:32))';

    plot(datafilt(10,1:20000)), pause(1)

    datafilt = datafilt(:, 3001:90000);
    
    % FFT

    [pow, phase, freqs] = FFT_spectrum(datafilt, 500);

    %for x = 1:32, plot(freqs(30:800), pow(x,30:800)), title(num2str(x)), pause(1), end

    figure, plot(freqs(40:800), pow(25,40:800)), title('c4'), pause(1)

    fsmapnew = 1000./(500./size(datafilt,2));

    [File,Path,FilePath]=SaveAvgFile([filepath '.spec'],pow,[],[], fsmapnew);
    
end

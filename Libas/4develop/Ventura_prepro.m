function [specavg, freqs, mat_end, demodmat] = Ventura_prepro(filemat, plotflag)

% sample rate is 250 Hz
% mff files

for fileindex = 1:size(filemat,1)

    disp(filemat(fileindex,:))
    
    disp(fileindex)
    
    filepath = deblank(filemat(fileindex,:));

    taxis = -1000:1:0; 

    data = ft_read_data(filepath);  % filepath is an mff file
    
    events = ft_read_event(filepath);

    warning('off')

    % build a lowpass filter
    [a, b] = butter(4, .16); 
    data = filtfilt(a, b, double(data)')'; 

    % build a highpass filter
    [ah, bh] = butter(2, .01, 'high'); 
    data = filtfilt(ah, bh, data')'; 
 
    load('locsEEGLAB129HCL.mat');
    locations = locsEEGLAB129HCL;

    % interpolate bad channels throughoutlocs
    [data, interpvecthroughout] = scadsAK_2dInterpChan(data, locations, 3);

    % this is the first step after reading stuff in: 
    % find the times (in sample points) where a stm+ event happened
    % we think that this may be the stimulus but estelle will find out

    segmentvec = []; 
    for x = 1: size(events,2)    
       if strcmp(events(x).value, 'DIN2')
          segmentvec = [segmentvec events(x).sample]; 
          % conditionvec = [conditionvec; events(x+1).value]; this works on
          % some select few subjects
       end
    end


    % now find the data segments and get the ERP data
    mat = zeros(129, 1201, size(segmentvec,2));
    for x = 1:size(segmentvec,2)
    mat(:, :, x) = data(:, segmentvec(x)-100:segmentvec(x)+1100);  
    end

    % do artifact correction
    % first bad channels within trials
    [ mat_end, badindex, NGoodtrials ] = scadsAK_3dtrials(mat, 1.5); 

    % average
    mat_end = avg_ref_add3d(mat_end); 

    [specavg, freqs] = FFT_spectrum3D(mat_end, 600:1100, 250);
    [demodmat, phasemat, complexmat]=steadyHilbertMat(mean(mat_end,3), 7.5, 1:100, 10, 1, 250);

    if plotflag
    figure
    plot(freqs(1:80), specavg(:, 1:80)')
    pause(1)
    end

    eval(['save ' filepath(1:15) '.spec.mat specavg -mat'])
    
    fprintf('.')
    
end





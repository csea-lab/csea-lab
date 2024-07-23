function [specavg, freqs2, mat_end] = Ventura_prepro(filemat, plotflag)

% sample rate is 250 Hz
fsamp = 250; 
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

     [~,S2] = regress_eog(data', 1:129, sparse([125,128,25,127,8,126],[1,1,2,2,3,3],[1,-1,1,-1,1,-1]));

     data = S2'; 

    % interpolate bad channels throughoutlocs
    [data, interpvecthroughout] = scadsAK_2dInterpChan(data, locations, 2);

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
    mat = zeros(128, 1201, size(segmentvec,2));
    for x = 1:size(segmentvec,2)
    mat(:, :, x) = data(1:128, segmentvec(x)-100:segmentvec(x)+1100);  
    end

    % do artifact correction
    % first bad channels within trials
    [ mat_end, badindex, NGoodtrials ] = scadsAK_3dtrials(mat, 1); 

    % average
    mat_end = avg_ref_add3d(mat_end); 

    ERP = squeeze(mean(mat_end,3));

    [specavg, freqs1] = FFT_spectrum3D(mat_end, 101:1100, 250);
    [spec, ~, freqs2] = FFT_spectrum(ERP(:, 101:1100), 250);
    %[demodmat, phasemat, complexmat]=steadyHilbertMat(mean(mat_end,3), 5, 1:100, 10, 1, 250);

    if plotflag
    figure(300)
    subplot(2,1,1), plot(freqs1(1:80), specavg(:, 1:80)')
    subplot (2,1,2), plot(freqs2(1:80), spec(:, 1:80)')
    pause(1)
    end

    fakesamplerate = 1000./(fsamp./(size(spec,2).*2));
    SaveAvgFile([filemat(fileindex,1:end-3) 'at.spec'],spec,[],[],fakesamplerate); 

    
end





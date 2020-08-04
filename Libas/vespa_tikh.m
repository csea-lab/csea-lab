
function [InvVal, X] = vespa_tikh(tmin,tmax, lambda, outname)
% Tikhonoch Philips Regularisierung für vespa
%   tmin   - minimum time lag (ms)
%   tmax   - maximum time lag (ms)
%   [X] = stim x length x time lag


%   irffinal   - response function (time by features) - stepfunction
%   (Reihenfolge: valence, arousal entropy, iti, jpeg)
%   data4vespa   - neural response data (time by channels) - not normed,
%   filtered (30Hz low pass, 0.1Hz high pass, blinks removed with PCA) 
%   fs     - sampling frequency (Hz)
%   heißt aus Faulheitsgründen praktischerweise alles gleich:
    load('data4vespa.mat');
    load('irffinal_7x90000.mat');

    % Nullen weg
    k = 86000;
    for i=1:1000, m = k+i; 
        if irffinal(1,m) == 0; break, end, 
    end
    length = m-1; 
    data = data4vespa(1:length,:); 
    irf = irffinal(3:7,1:length)';
    
    clearvars m i k data4vespa irffinal

    % generate lag time window
    fs = 500;
    tmin = floor(tmin/1000*fs);
    tmax = ceil(tmax/1000*fs);

	% generate lag matrix X
    for i = 1:size(irf,2), 
        temp = irf(:,i);
        X(i,:,:) = [ones(size(temp)),lagGen(temp,tmin:tmax)];
    end
    
    %%% falls das für danach nützlicher ist - yep it is, juhu danke!
        Xval = squeeze(X(1,:,:));
        Xaro = squeeze(X(2,:,:));
        Xent = squeeze(X(3,:,:));
        Xiti = squeeze(X(4,:,:));
        Xjpeg = squeeze(X(5,:,:));
        
   %% loop pover channels and create pinv_tikh
   %first remove mean from all channels, but make sure it is still col vec
   data = bslcorr(data',1:size(data,1))';  
   
   % now loop
   for channel = 1:size(data,2)
       
       InvVal(channel,:) = pinv_tikh(Xval'*Xval,lambda)*Xval'*(data(:,channel)).*length(data); 
       InvAro(channel,:) = pinv_tikh(Xaro'*Xaro,lambda)*Xaro'*(data(:,channel)).*length(data);
       InvEnt(channel,:) = pinv_tikh(Xent'*Xent,lambda)*Xent'*(data(:,channel)).*length(data);
       InvITI(channel,:) = pinv_tikh(Xiti'*Xiti,lambda)*Xiti'*(data(:,channel)).*length(data);
       InvJPG(channel,:) = pinv_tikh(Xjpeg'*Xjpeg,lambda)*Xjpeg'*(data(:,channel)).*length(data);    
       
       if channel/10 == round(channel/10), disp(['channel: ' num2str(channel)]), end
       
   end
   
   % get rid of onset artifact and save as .at file
   SaveAvgFile([outname 'InvVal.at'],InvVal(:, 3:end),[],[], 500);
   SaveAvgFile([outname 'InvAro.at'],InvAro(:, 3:end),[],[], 500);
   SaveAvgFile([outname 'InvEnt.at'],InvEnt(:, 3:end),[],[], 500);
   SaveAvgFile([outname 'InvITI.at'],InvITI(:, 3:end),[],[], 500);
   SaveAvgFile([outname 'InvJPG.at'],InvJPG(:, 3:end),[],[],500);
       
end


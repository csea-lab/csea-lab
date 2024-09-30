function [WaPower4d] = wavelet_app_mat_singtrials(data, SampRate, f0start, f0end, fdelta) 


  NPointsNew = size(data,2);
  NTrials = size(data,3);
 
  % compute wavelets and their parameters 
  wavelet = gener_wav(NPointsNew, fdelta, f0start, f0end);
 
  disp('size of waveletMatrix')
  disp(size(wavelet))
  disp (' frequency step for delta_f0 = 1 is ')
  disp(SampRate/NPointsNew)
 

   % create 3d matrix objects for wavelet
   % channels * time * frequencies

    waveletMat3d = repmat(wavelet, [1 1 size(data,1)]); 
    waveletMat3d = permute(waveletMat3d, [3, 2, 1]); 

    % loop over trials

    disp(['trial index of '])
    disp(NTrials)

    for trialindex = 1:NTrials

        Data = data(:,:,trialindex);

        fprintf('.')

        if trialindex/10 == round(trialindex/10), disp(trialindex), end

        Data = bslcorr(Data, 1:200); 

       size(Data);

        % window data with cosine square window
        window = cosinwin(20, size(Data,2), size(Data,1)); 
        Data = Data .* window; 

        data_pad3d = repmat(Data, [1 1 size(wavelet,1)]); 

        % transform data  to the frequency domain

        data_trans = fft(data_pad3d, NPointsNew, 2);

        thetaMATLABretrans = []; 

        ProdMat= waveletMat3d .*(data_trans);

        thetaMATLABretrans = ifft(ProdMat, NPointsNew, 2);

       % temp = downsample3dmat(abs(thetaMATLABretrans). 10, 100, SampRate);

       %  WaPower4d(:, :, :, trialindex) = downsample3dmat(abs(thetaMATLABretrans).* 10, 100, SampRate);

       WaPower4d(:, :, :, trialindex) = abs(thetaMATLABretrans).* 10; 

     end % loop over trials

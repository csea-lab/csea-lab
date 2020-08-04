%% 
corrmat = []; 

% first part just reads data and does hilbert transform on each trial, at
% each tagging frequency 
for index = 1:size(filemat,1), 
    
    powsubj = []; 
    
    a = load(deblank(filemat(index,:))); 
    
    deblank(filemat(index,:));
    
    data = double(a.mat3d); 
   
    for trial = 1:size(data,3), 
    
          [demodmat10, phasemat, complexmat]=steadyHilbertMat(data(:, :, trial), 10, [], 10, 0, 500);
           [demodmat13, phasemat, complexmat]=steadyHilbertMat(data(:, :, trial), 13.33, [], 9, 0, 500);
           
             % for bsl: 
          demodmat10 =bslcorr(demodmat10, 1:2000);
          demodmat13 = bslcorr(demodmat13, 1:2000);
           
  
           
           %plot(demodmat10(75,:), demodmat13(75,:), '*'), pause(.5)
          corrmat(index, trial, :) = diag(corr(z_norm(demodmat10(74:76, 400:800))', z_norm(demodmat13(74:76, 400:800))', 'type', 'Spearman'));
           
    end
                 
    fprintf('.')
    
    
end

corrmat(corrmat==0) = nan; 
allcorrs = squeeze(nanmean(corrmat, 2));

corrs129_11 = allcorrs(1:4:end, :);
corrs129_21 = allcorrs(2:4:end, :);
corrs129_31 = allcorrs(3:4:end, :);
corrs129_41 = allcorrs(4:4:end, :);

%%%%
%%%
%% wavelets of difference curve
diffmat = []; 
wavmat = []; 

taxis = -600:2:3998;

fstart=5;   % in indices not Hz
fend=40; 

for index = 1:size(filemat,1), 
    
    powsubj = []; 
    
    a = load(deblank(filemat(index,:))); 
    
    data = double(a.mat3d); 
      
   
   for trial = 1:size(data,3), 
    
          [demodmat10, phasemat, complexmat]=steadyHilbertMat(data(:, :, trial), 10, [], 4, 0, 500);
          [demodmat13, phasemat, complexmat]=steadyHilbertMat(data(:, :, trial), 13.33, [], 4, 0, 500);
          
          COEFF10 = pca(demodmat10');
          COEFF13 = pca(demodmat13');
          
          weights10 = COEFF10(:,1);
          weights13 = COEFF13(:,1);
          
          
                out10 = weights10' * demodmat10;
                out13 = weights13' * demodmat13;
          
          
          
          % for normalization: 
          demodmat10 = z_norm(out10); 
          demodmat13 = z_norm(out13);
        
           cosinwinmat = cosinwin(150,2300, 1);
           
          diffmat = bslcorr(demodmat10(1:end), []) - bslcorr(demodmat13(1:end), []);
          
           [B,A] = butter(4,0.006,'high') ; 
           
         %  diffmat = filtfilt(B, A, diffmat')'; 
          
          diffmat = diffmat.*cosinwinmat; 
          
          wavelet = gener_wav(size(diffmat,2), 1, fstart, fend);
          
          
           waveletMat3d = repmat(wavelet, [1 1 size(diffmat,1)]); 
           waveletMat3d = permute(waveletMat3d, [2, 3, 1]); 
          
            window = cosinwin(45, size(diffmat,2), size(diffmat,1)); 
        
            data_pad = diffmat .* window; 
        
        data_pad3d = repmat(data_pad', [1 1 size(wavelet,1)]); 
    
        % transform data  to the frequency

        data_trans = fft(data_pad3d, size(diffmat,2), 1);

        thetaMATLABretrans = []; 

        ProdMat= waveletMat3d .*(data_trans);

        thetaMATLABretrans = ifft(ProdMat, size(diffmat,2), 1);
              
        if trial == 1
            WaPowerSum = abs(thetaMATLABretrans).* 10; 
         
        else
        WaPowerSum = WaPowerSum + abs(thetaMATLABretrans).* 10; 
 
        end
        
    end
                 
    fprintf('.')
    
    wavmat(index, : , :) =   squeeze(WaPowerSum./size(data,3)); 

end

  disp('size of waveletMatrix')
  
  disp(size(wavelet))
  
 disp (' frequency step for delta_f0 = 1 is ')
  
 res = 500/size(diffmat,2);
  disp(res)
  
  faxis = (fstart-1).* res:res:(fend-1).*res

wavmat_11 = squeeze(nanmean(wavmat(1:4:end, :, :)))';
wavmat_21 = squeeze(nanmean(wavmat(2:4:end, :, :)))';
wavmat_31 = squeeze(nanmean(wavmat(3:4:end, :, :)))';
wavmat_41 = squeeze(nanmean(wavmat(4:4:end, :, :)))';

wavmat_11_bsl = bslcorr(wavmat_11, 2000:2300);
wavmat_21_bsl = bslcorr(wavmat_31, 2000:2300);
wavmat_31_bsl = bslcorr(wavmat_21, 2000:2300);
wavmat_41_bsl = bslcorr(wavmat_41, 2000:2300);

figure
subplot(4,1,1), contourf(taxis(200:end-400), faxis(3:end-13), squeeze(wavmat_11_bsl(3:end-13, 200:end-400)), 15), caxis([-.15 0.25]), colorbar
subplot(4,1,2), contourf(taxis(200:end-400), faxis(3:end-13), squeeze(wavmat_21_bsl(3:end-13, 200:end-400)), 15), caxis([-.15 0.25]), colorbar
subplot(4,1,3), contourf(taxis(200:end-400), faxis(3:end-13), squeeze(wavmat_31_bsl(3:end-13, 200:end-400)), 15), caxis([-.15 0.25]), colorbar
subplot(4,1,4), contourf(taxis(200:end-400), faxis(3:end-13), squeeze(wavmat_41_bsl(3:end-13, 200:end-400)), 15), caxis([-.15 0.25]), colorbar

figure
subplot(4,1,1), contourf(taxis, faxis, squeeze(wavmat_11), 15), colorbar
subplot(4,1,2), contourf(taxis, faxis, squeeze(wavmat_21), 15), colorbar
subplot(4,1,3), contourf(taxis, faxis, squeeze(wavmat_31), 15), colorbar
subplot(4,1,4), contourf(taxis, faxis, squeeze(wavmat_41), 15), colorbar

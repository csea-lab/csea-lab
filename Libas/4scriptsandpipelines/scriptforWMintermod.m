% create filemats if needed

filemat_11 = filemat(1:4:end, :)
filemat_21 = filemat(2:4:end, :)
filemat_31 = filemat(3:4:end, :)
filemat_41 = filemat(4:4:end, :)
%%%%%
%%%%
%% 


powsum = []; 

filemat = filemat_41; 

for index = 1:size(filemat,1), 
    
    a = load(deblank(filemat(index,:))); 
    
    data = a.mat3d; 
    
    meanERP = mean(data, 3); 
    
    [pow, phase, freqs] = FFT_spectrum(meanERP(:, 400:2300), 500);
    
    if index ==1, 
        powsum = pow; 
    else
        powsum = pow+ powsum; 
    end
    
    
    plot(freqs(3:80), pow(:, 3:80)'), title(deblank(filemat(index,:))); pause
    
    fprintf('.')
    
    
end

%%%%%%
%%%%%%%%%%%%%%%%%%%%
%single trials
%% 

filemat = filemat_41; 
for index = 1:size(filemat,1), 
    
    powsubj = []; 
    
    a = load(deblank(filemat(index,:))); 
    
    data = a.mat3d; 
   
    for trial = 1:size(data,3), 
    
            [pow1, phase, freqs] = FFT_spectrum(data(:, 400:2300, trial), 500);

            if trial==1, 
                powsubj = pow1; 
            else
                powsubj = powsubj+ pow1; 
            end

     end
    
    if index ==1, 
        powsum = powsubj; 
    else
        powsum = powsubj+ powsum; 
    end
    
    
    plot(freqs(3:80), powsubj(:, 3:80)'), title(deblank(filemat(index,:))); pause
    
    fprintf('.')
    
    
end
%%%%%%
%%%%%%
%% 
corrmat = []; 


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
%% abs of the difference of the (normalized waveforms) 
diffmat = []; 

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
           
           %plot(demodmat10(75,:), demodmat13(75,:), '*'), pause(.5)
          diffmat(index, trial, :) = demodmat10(:, :) - demodmat13(:, :);
          absmat(index, trial, :) = abs(demodmat10(:, :) - demodmat13(:, :));
           
           
    end
                 
    fprintf('.')
    
    
end


diffmat(diffmat==0) = nan;
absmat(absmat==0) = nan; 


alldiffs = squeeze(nanmean(diffmat, 2));
allabs = squeeze(nanmean(absmat, 2));
allrange = squeeze(range(diffmat, 2));


diffs129_11 = alldiffs(1:4:end, :);
diffs129_21 = alldiffs(2:4:end, :);
diffs129_31 = alldiffs(3:4:end, :);
diffs129_41 = alldiffs(4:4:end, :);

abs129_11 = allabs(1:4:end, :);
abs129_21 = allabs(2:4:end, :);
abs129_31 = allabs(3:4:end, :);
abs129_41 = allabs(4:4:end, :);

range129_11 = allrange(1:4:end, :);
range129_21 = allrange(2:4:end, :);
range129_31 = allrange(3:4:end, :);
range129_41 = allrange(4:4:end, :);

diffmat2 = diffmat;
diffmat2(isnan(diffmat)) = 0;
diffsall_11 = diffmat2(1:4:end, :, :);
diffsall_21 = diffmat2(2:4:end, :, :);
diffsall_31 = diffmat2(3:4:end, :, :);
diffsall_41 = diffmat2(4:4:end, :, :);

% plot(mean(diffs129_11))
% figure, plot(mean(diffs129_21))
% figure,plot(mean(diffs129_31))
% figure,plot(mean(diffs129_41))

figure
plot(mean(diffs129_11(:, 300:end-100)), 'k')
hold on, plot(mean(diffs129_21(:, 300:end-100)), 'g')
hold on, plot(mean(diffs129_31(:, 300:end-100)), 'r')
hold on, plot(mean(diffs129_41(:, 300:end-100)), 'm')
hold off

figure
plot(mean(range129_11(:, 300:end-100)), 'k')
hold on, plot(mean(range129_21(:, 300:end-100)), 'g')
hold on, plot(mean(range129_31(:, 300:end-100)), 'r')
hold on, plot(mean(range129_41(:, 300:end-100)), 'm')
hold off


figure
plot(mean(abs129_11(:, 300:end-100)), 'k')
hold on, plot(mean(abs129_21(:, 300:end-100)), 'g')
hold on, plot(mean(abs129_31(:, 300:end-100)), 'r')
hold on, plot(mean(abs129_41(:, 300:end-100)), 'm')
hold off

%%%
%% number of zero transition of difference curve
diffmat = []; 

for index = 1:size(filemat,1), 
    
    powsubj = []; 
    
    a = load(deblank(filemat(index,:))); 
    
    data = double(a.mat3d); 
   
    for trial = 1:size(data,3), 
    
          [demodmat10, phasemat, complexmat]=steadyHilbertMat(data(75, :, trial), 10, [], 6, 0, 500);
          [demodmat13, phasemat, complexmat]=steadyHilbertMat(data(75, :, trial), 13.33, [], 5, 0, 500);
          
          % for normalization: 
          demodmat10 = z_norm(demodmat10); 
          demodmat13 = z_norm(demodmat13);
           
           %plot(demodmat10(75,:), demodmat13(75,:), '*'), pause(.5)
          diffmat = bslcorr(demodmat10(:, 400:end-100), []) - bslcorr(demodmat13(:, 400:end-100), []);
          %figure(1), plot(diffmat), pause
           zerosmat(index, trial, :) = length(find(abs(diffmat)<0.005)); 
           
    end
                 
    fprintf('.')
    
    
end

zerosmat(zerosmat==0) = nan;
allzeros = squeeze(nanmean(zerosmat, 2));

zeros129_11 = allzeros(1:4:end, :);
zeros129_21 = allzeros(2:4:end, :);
zeros129_31 = allzeros(3:4:end, :);
zeros129_41 = allzeros(4:4:end, :);

bar([mean(zeros129_11) mean(zeros129_21)  mean(zeros129_31) mean(zeros129_41)])


%% range over time
diffmat = []; 
stdmat = []; 

for index = 1:size(filemat,1), 
    
    powsubj = []; 
    
    a = load(deblank(filemat(index,:))); 
    
    data = double(a.mat3d); 
   
    for trial = 1:size(data,3), 
    
          [demodmat10, phasemat, complexmat]=steadyHilbertMat(data(75, :, trial), 10, [], 6, 0, 500);
          [demodmat13, phasemat, complexmat]=steadyHilbertMat(data(75, :, trial), 13.33, [], 5, 0, 500);
          
          % for normalization: 
          demodmat10 = z_norm(demodmat10); 
          demodmat13 = z_norm(demodmat13);
           
          % 
           %plot(demodmat10(75,:), demodmat13(75,:), '*'), pause(.5)
          diffmat = bslcorr(demodmat10(:, 200:end-100), []) - bslcorr(demodmat13(:, 200:end-100), []);
          %figure(1), plot(diffmat), pause
          stdmat(index, trial, :) = [range(diffmat(150:350)) range(diffmat(200:400)) range(diffmat(250:450)) range(diffmat(300:500)) range(diffmat(350:550)) range(diffmat(400:600)) ...
              range(diffmat(450:650)) range(diffmat(500:700)) range(diffmat(550:750)) range(diffmat(600:800)) range(diffmat(650:850)) range(diffmat(700:900)) ...
              range(diffmat(750:950)) range(diffmat(800:1000)) range(diffmat(850:1050)) range(diffmat(900:1100)) range(diffmat(950:1150))  ...
              range(diffmat(1000:1200)) range(diffmat(1050:1250))  range(diffmat(1100:1300)) range(diffmat(1150:1350)) ...
              range(diffmat(1200:1400))  range(diffmat(1250:1450))  range(diffmat(1300:1500))   range(diffmat(1350:1550)) ...
              range(diffmat(1400:1600)) range(diffmat(1450:1650)) range(diffmat(1500:1700)) range(diffmat(1550:1750)) range(diffmat(1600:1800))...
             range(diffmat(1650:1850)) range(diffmat(1700:1900)) range(diffmat(1750:1950)) range(diffmat(1800:2000))];
           
    end
                 
    fprintf('.')
    
    
end

stdmat(stdmat==0) = nan;
allzeros = squeeze(nanmean(stdmat, 2));

zeros129_11 = allzeros(1:4:end, :);
zeros129_21 = allzeros(2:4:end, :);
zeros129_31 = allzeros(3:4:end, :);
zeros129_41 = allzeros(4:4:end, :);

zeros129_11 = bslcorr(zeros129_11, 5); 
zeros129_21 = bslcorr(zeros129_21, 5); 
zeros129_31 = bslcorr(zeros129_31, 5); 
zeros129_41 = bslcorr(zeros129_41, 5); 

figure, hold on, plot(mean(zeros129_11), 'k')
plot(mean(zeros129_31), 'b')
plot(mean(zeros129_21), 'g')
plot(mean(zeros129_41), 'r')


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
%%
%%%%
%do stats and final figures
 load('waveletsExp3.mat')
temp = permute(wavmat, [2 1 3]);

%linear trend
% for freq = 1:30;
% temp2 = squeeze(mean(temp(:, :, freq),3));repeatmatExp3 = cat(3, temp2(:, 1:4:end), temp2(:, 2:4:end), temp2(:, 3:4:end), temp2(:, 4:4:end)); ...
% [Fcontmat(freq,:),rcontmat,MScont,MScs, dfcs]=contrast_rep(log(repeatmatExp3),[-2 -1 -1 4]); 
% end

%no and 1 versus both 
for freq = 1:30;
temp2 = squeeze(mean(temp(:, :, freq),3));repeatmatExp3 = cat(3, temp2(:, 1:4:end), temp2(:, 2:4:end), temp2(:, 3:4:end), temp2(:, 4:4:end)); ...
[Fcontmat(freq,:),rcontmat,MScont,MScs, dfcs]=contrast_rep(log(repeatmatExp3),[-1 -1 -1 3]); 
end

% 
% %no versus 1 ignoring both 
% for freq = 1:30;
% temp2 = squeeze(mean(temp(:, :, freq),3));repeatmatExp3 = cat(3, temp2(:, 1:4:end), temp2(:, 2:4:end), temp2(:, 3:4:end), temp2(:, 4:4:end)); ...
% [Fcontmat(freq,:),rcontmat,MScont,MScs, dfcs]=contrast_rep(log(repeatmatExp3),[-2 1 1 0]); 
% end

taxis = -600:2:3998;
fstart=5;   % in indices not Hz
fend=40; 
res = 500/2300; 
faxis = (fstart-1).* res:res:(fend-1).*res; 
scalemat = repmat(faxis', 1,2300);


figure
subplot(5,1,1), contourf(taxis, faxis(1:25), squeeze(wavmat_11(1:25, :).*scalemat(1:25, :)), 20), caxis([1.2 2.6]), colorbar
subplot(5,1,2), contourf(taxis, faxis(1:25), squeeze(wavmat_21(1:25, :).*scalemat(1:25, :)), 20), caxis([1.2 2.6]), colorbar
subplot(5,1,3), contourf(taxis, faxis(1:25), squeeze(wavmat_31(1:25, :).*scalemat(1:25, :)), 20), caxis([1.2 2.6]), colorbar
subplot(5,1,4), contourf(taxis, faxis(1:25), squeeze(wavmat_41(1:25, :).*scalemat(1:25, :)), 20), caxis([1.2 2.5]), colorbar
subplot(5,1,5), contourf(taxis, faxis(1:25), Fcontmat(1:25,:), 4),  caxis([1 9]), colormap jet, colorbar

%test
wavmat_A = (wavmat_11 + wavmat_21)./2.1; 
wavmat_B = (wavmat_11 + wavmat_31)./2;
wavmat_C = (wavmat_31 + wavmat_41)./1.8; 
subplot(3,1,1), contourf(taxis, faxis(1:25), squeeze(wavmat_A(1:25, :).*scalemat(1:25, :)), 20), caxis([1.2 2.8]), colorbar
subplot(3,1,2), contourf(taxis, faxis(1:25), squeeze(wavmat_B(1:25, :).*scalemat(1:25, :)), 20), caxis([1.2 2.8]), colorbar
subplot(3,1,3), contourf(taxis, faxis(1:25), squeeze(wavmat_C(1:25, :).*scalemat(1:25, :)), 20), caxis([1.2 2.8]), colorbar


  
%% histograms
diffmat = []; 
stdmat = []; 

for index = 1:size(filemat,1), 
    
    powsubj = []; 
    
    a = load(deblank(filemat(index,:))); 
    
    data = double(a.mat3d); 
   
    for trial = 1:size(data,3), 
    
          [demodmat10, phasemat, complexmat]=steadyHilbertMat(data(75, :, trial), 10, [], 6, 0, 500);
          [demodmat13, phasemat, complexmat]=steadyHilbertMat(data(75, :, trial), 13.33, [], 5, 0, 500);
          
          % for normalization: 
          demodmat10 = z_norm(demodmat10); 
          demodmat13 = z_norm(demodmat13);
           
          % 
           %plot(demodmat10(75,:), demodmat13(75,:), '*'), pause(.5)
          diffmat = bslcorr(demodmat10(:, 100:end-1600), []) - bslcorr(demodmat13(:, 100:end-1600), []);
          
           stdmatmax(index, trial)  = max(diffmat);
           stdmatmin(index, trial)  = min(diffmat); 
           
           
    end
                 
    fprintf('.')
    
    
end

stdmatmax(stdmatmax==0) = nan;
stdmatmin(stdmatmin==0) = nan;



max129_11 = reshape(stdmatmax(1:4:end, :), [1 numel(stdmatmax(1:4:end, :))]);
max129_21 = reshape(stdmatmax(2:4:end, :), [1 numel(stdmatmax(1:4:end, :))]);
max129_31 = reshape(stdmatmax(3:4:end, :), [1 numel(stdmatmax(1:4:end, :))]);
max129_41 = reshape(stdmatmax(4:4:end, :), [1 numel(stdmatmax(1:4:end, :))]);

min129_11 = reshape(stdmatmin(1:4:end, :), [1 numel(stdmatmin(1:4:end, :))]);
min129_21 = reshape(stdmatmin(2:4:end, :), [1 numel(stdmatmin(1:4:end, :))]);
min129_31 = reshape(stdmatmin(3:4:end, :), [1 numel(stdmatmin(1:4:end, :))]);
min129_41 = reshape(stdmatmin(4:4:end, :), [1 numel(stdmatmin(1:4:end, :))]);

figure, subplot(4,1,1), bar(nanmean(min129_11, 2), 'k')
subplot(4,1,2),bar(nanmean(min129_31, 2), 'b')
subplot(4,1,3),bar(nanmean(min129_21, 2), 'g')
subplot(4,1,4),bar(nanmean(min129_41, 2), 'r')

figure, subplot(4,1,1), bar(nanmean(max129_11, 2), 'k')
subplot(4,1,2),bar(nanmean(max129_31, 2), 'b')
subplot(4,1,3),bar(nanmean(max129_21, 2), 'g')
subplot(4,1,4),bar(nanmean(max129_41, 2), 'r')



%%
% 1) do training AND test to averaged topographies, December 2019
% 
% 
% load 4 d files. these come from here: 
% [WaPower4d] = wavelet_app_matfiles_singtrials(filemat, 500, 10, 104, 5);
% 
% this for spp3 and app6
% i.e. this is about expectancy
 
clear
filemat3 = getfilesindir(pwd, '*3.mat.pow4*');
filemat6 = getfilesindir(pwd, '*6.mat.pow4*');

mat3d3 = [];
mat3d6 = [];

channels =  [1:129];
%channels =  [55 54 53 52 58 79 86 92 96 72 71 76 75 70 83 69 89 95 64 50 101 30 105 46 102 ];

stepsize = 30; 

taxis = -3600:10:1500;
faxisfull = 0:0.1960:250; 
faxis = faxisfull(10:5:104);
 
% now make a matrix for alpha frequency

for freq = 1:15
        
mat3d3 = [];
mat3d6 = [];
mat3d3avg = []; 
mat3d6avg = []; 
    
    disp('loading ... ')

    
    %load that freq into workspace
    for x = 1:size(filemat3,1)
        a3 = load(filemat3(x,:)); 
        temp = a3.WaPower4d; 
       %mat3d3 = cat(3, mat3d3, squeeze(mean(temp(:, :, 8:13, :), 3))); %alpha only
       mat3d3 = cat(3, mat3d3, squeeze(mean(temp(:, :, freq:freq+2, :), 3))); 
        a6 = load(filemat6(x,:)); 
        temp = a6.WaPower4d; 
       %mat3d6 = cat(3, mat3d6, squeeze(mean(temp(:, :, 8:13, :), 3))); %alpha only
       mat3d6 = cat(3, mat3d6, squeeze(mean(temp(:, :, freq:freq+2, :), 3)));
        fprintf('-_'), if x/10 == round(x/10), disp(x), end
        
    end
    
    % now average some trials before classifier
    for x = 1:stepsize
    mat3d3avg(:, :, x) = mean(mat3d3(:, :, x:stepsize:end), 3); 
    mat3d6avg(:, :, x) = mean(mat3d6(:, :, x:stepsize:end), 3);     
    end
  
   mat3d3avg = mat3d3avg(:, 1:5:end,:); % downsample for speed
    mat3d6avg = mat3d6avg(:, 1:5:end,:); 
    
    mat3d3avg = movmean(mat3d3avg, 20, 2); % smooth to reduce noise 
    mat3d6avg = movmean(mat3d6avg, 20, 2); 
    
    labelvectorfull = [ones(size(mat3d3avg,3),1).*3;  ones(size(mat3d6avg,3),1).*6];


disp('... done! starting classification.')


Y = labelvectorfull'; 

for timepoint1 = 1:size(mat3d3avg,2)
    
    for timepoint2 = 1:size(mat3d3avg,2)

         trainmatfull1 = z_norm([squeeze((mat3d3avg(channels, timepoint1, : )))'; squeeze((mat3d6avg(channels, timepoint1, :)))']); % 1st dim are channels  
         trainmatfull2 = z_norm([squeeze((mat3d3avg(channels, timepoint2, : )))'; squeeze((mat3d6avg(channels, timepoint2, :)))']); % 1st dim are channels  
        
         %version control: this used to be 'Solver','sparsa','Regularization','lasso',
         
         if timepoint1 == timepoint2
               obj = fitclinear(trainmatfull1(:,:)',labelvectorfull, 'Kfold',20, 'Solver','sparsa', 'ObservationsIn','columns');     
               Yhat = kfoldPredict(obj); 
               aha = confusionmat(Y,Yhat); 
         else
             aha = zeros(2,2); 
             for x = 1:50
              subindex = randperm(60); 
              trainindex = subindex(1:50); 
               testindex = subindex(51:end); 
               obj = fitclinear(trainmatfull1(trainindex,:)',labelvectorfull(trainindex), 'Solver','sparsa', 'ObservationsIn','columns');     
              Yhat = predict(obj, trainmatfull2(testindex,:));
              aha = aha + confusionmat(Y(testindex),Yhat); 
             end
         end
       
         meanaccuracy(freq, timepoint1, timepoint2) = sum(diag(aha))./(sum(sum(aha))); 

    end % timepoint2
    
    fprintf('.'); 
    if timepoint1/50 == round(timepoint1/50), disp(num2str(timepoint1)), end

end % timepoint1

 
end % frequencies

%smooth the result
spatfilt = 3; 
for x = 1:freq    
    temp1 = movmean(squeeze(meanaccuracy(x,:,:)), spatfilt, 1); 
    meanaccuracy_smooth(x,:,:) = movmean(temp1, spatfilt, 2); 
end

%plot the result
for x = 1:freq
subplot(5,3,x),  imagesc(squeeze(meanaccuracy(x,:,:))), caxis([.4 0.7]), title(x), colorbar, end


%%
 
% 2) do training AND test to averaged topographies, December 2019
% 
% 
% load 4 d files. these come from here: 
% [WaPower4d] = wavelet_app_matfiles_singtrials(filemat, 500, 10, 104, 5);
% 
% this for spp1 and app2
% i.e. this is about what happened
 
clear
filemat3 = getfilesindir(pwd, '*001.mat.pow4*');
filemat6 = getfilesindir(pwd, '*002.mat.pow4*');

mat3d3 = [];
mat3d6 = [];

channels =  [1:129];
%channels =  [55 54 53 52 58 79 86 92 96 72 71 76 75 70 83 69 89 95 64 50 101 30 105 46 102 ];

stepsize = 30; 

taxis = -3600:10:1500;
faxisfull = 0:0.1960:250; 
faxis = faxisfull(10:5:104);
 
% now make a matrix for alpha frequency

for freq = 1:15
        
mat3d3 = [];
mat3d6 = [];
mat3d3avg = []; 
mat3d6avg = []; 
    
    disp('loading ... ')

    
    %load that freq into workspace
    for x = 1:size(filemat3,1)
        a3 = load(filemat3(x,:)); 
        temp = a3.WaPower4d; 
       %mat3d3 = cat(3, mat3d3, squeeze(mean(temp(:, :, 8:13, :), 3))); %alpha only
       mat3d3 = cat(3, mat3d3, squeeze(mean(temp(:, :, freq:freq+2, :), 3))); 
        a6 = load(filemat6(x,:)); 
        temp = a6.WaPower4d; 
       %mat3d6 = cat(3, mat3d6, squeeze(mean(temp(:, :, 8:13, :), 3))); %alpha only
       mat3d6 = cat(3, mat3d6, squeeze(mean(temp(:, :, freq:freq+2, :), 3)));
        fprintf('-_'), if x/10 == round(x/10), disp(x), end
        
    end
    
    % now average some trials before classifier
    for x = 1:stepsize
    mat3d3avg(:, :, x) = mean(mat3d3(:, :, x:stepsize:end), 3); 
    mat3d6avg(:, :, x) = mean(mat3d6(:, :, x:stepsize:end), 3);     
    end
  
    mat3d3avg = mat3d3avg(:, 1:5:end,:); % downsample for speed
    mat3d6avg = mat3d6avg(:, 1:5:end,:); 
    
    mat3d3avg = movmean(mat3d3avg, 20, 2); % smooth time to reduce noise 
    mat3d6avg = movmean(mat3d6avg, 20, 2); 
    
    labelvectorfull = [ones(size(mat3d3avg,3),1).*3;  ones(size(mat3d6avg,3),1).*6];


disp('... done! starting classification.')


Y = labelvectorfull'; 

for timepoint1 = 1:size(mat3d3avg,2)
    
    for timepoint2 = 1:size(mat3d3avg,2)

         trainmatfull1 = z_norm([squeeze((mat3d3avg(channels, timepoint1, : )))'; squeeze((mat3d6avg(channels, timepoint1, :)))']); % 1st dim are channels  
         trainmatfull2 = z_norm([squeeze((mat3d3avg(channels, timepoint2, : )))'; squeeze((mat3d6avg(channels, timepoint2, :)))']); % 1st dim are channels  
        
         %version control: this used to be 'Solver','sparsa','Regularization','lasso',
         
         if timepoint1 == timepoint2
               obj = fitclinear(trainmatfull1(:,:)',labelvectorfull, 'Kfold',20, 'Solver','sparsa', 'ObservationsIn','columns');     
               Yhat = kfoldPredict(obj); 
               aha = confusionmat(Y,Yhat); 
         else
             aha = zeros(2,2); 
             for x = 1:50
              subindex = randperm(60); 
              trainindex = subindex(1:50); 
               testindex = subindex(51:end); 
               obj = fitclinear(trainmatfull1(trainindex,:)',labelvectorfull(trainindex), 'Solver','sparsa', 'ObservationsIn','columns');     
              Yhat = predict(obj, trainmatfull2(testindex,:));
              aha = aha + confusionmat(Y(testindex),Yhat); 
             end
         end
       
         meanaccuracy(freq, timepoint1, timepoint2) = sum(diag(aha))./(sum(sum(aha))); 

    end % timepoint2
    
    fprintf('.'); 
    if timepoint1/50 == round(timepoint1/50), disp(num2str(timepoint1)), end

end % timepoint1

 
end % frequencies

%smooth the result
spatfilt = 3; 
for x = 1:freq    
    temp1 = movmean(squeeze(meanaccuracy(x,:,:)), spatfilt, 1); 
    meanaccuracy_smooth(x,:,:) = movmean(temp1, spatfilt, 2); 
end

%plot the result
for x = 1:freq
subplot(5,3,x),  imagesc(squeeze(meanaccuracy(x,:,:))), caxis([.4 0.7]), title(x), colorbar, end

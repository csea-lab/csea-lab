%%
% 1) the original script
clear
cd /Users/andreaskeil/As_Exps/bop/mat3andmat6/oldclassify_results/
disp('loading a lot of data....')
load workspacealphamats.mat

offset = 537; % this is just the number of trials in first condition, i.e. the second condition starts at 538
trainsetsize = 450; % this is the number of trials from each condition used for training, the rest is used for test

taxis = -3600:2:1500;

comp1 = 1:537; 
comp2 = (1:491)+offset; 

disp('... done! starting classification.')

for timepoint = 1:24:2551-23

trainmatfull = z_norm([squeeze(mean(mat3d3(:, timepoint:timepoint+23, :),2))'; squeeze(mean(mat3d6(:, timepoint:timepoint+23, :),2))']);

labelvectorfull = [ones(size(mat3d3,3),1).*3;  ones(size(mat3d6,3),1).*6];

        % to enable crossvalidation, pick 90% of the data, pick 300 from each
        % category

        for valstep = 1:50

        indicestrain1 = randperm(537, trainsetsize)'; 
        indicestrain2 =  randperm(491, trainsetsize)'+offset; 
        
        indicestrain = [indicestrain1; indicestrain2]; 

        indicestest1 = find(~ismember(comp1, indicestrain1))';
        indicestest2 = find(~ismember(comp2, indicestrain2))' + offset; 
        
        indicestest = [indicestest1; indicestest2]; 

        %obj = fitcsvm(trainmatfull(indicestrain,:),[ones(400,1).*3;  ones(400,1).*6]); 
        obj = fitclinear(trainmatfull(indicestrain,:),[ones(trainsetsize,1).*3;  ones(trainsetsize,1).*6], 'Solver','sparsa','Regularization','lasso'); 
        
        [LABEL,SCORE]=predict(obj,trainmatfull(indicestest,:));
        
       accuracytemp(valstep) = sum(diag(crosstab(LABEL, labelvectorfull(indicestest))))./length(LABEL); 
      
       end
        
        meanaccuracy(timepoint) = mean(accuracytemp);
        temp = bootci(200,@mean,accuracytemp); 
        erroraccuracy(1, timepoint) = temp(1)-meanaccuracy(timepoint); 
        erroraccuracy(2, timepoint) = meanaccuracy(timepoint)-temp(2); 

    fprintf('.'); 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end

shadedErrorBar(taxis(1:24:end-23), meanaccuracy(1:24:end), erroraccuracy(:, 1:24:end))

%%
% 2) do it again with scrambled labels
clear
disp('loading a lot of data....')
load workspacealphamats.mat

taxis = -3600:2:1500;

comp1 = 1:537; 
comp2 = (1:491)+537; 

for timepoint = 1:24:2551

trainmatfull = z_norm([squeeze(mat3d3(:, timepoint, :))'; squeeze(mat3d6(:, timepoint, :))']);

labelvectorfull = [ones(size(mat3d3,3),1).*3;  ones(size(mat3d6,3),1).*6];

        % to enable crossvalidation, pick 90% of the data, pick 300 from each
        % category

        for valstep = 1:100

        indicestrain1 = randperm(537, 400)'; 
        indicestrain2 =  randperm(491, 400)'+537; 
        
        indicestrain = [indicestrain1; indicestrain2]; 

        indicestest1 = find(~ismember(comp1, indicestrain1))';
        indicestest2 = find(~ismember(comp2, indicestrain2))'; 
        
        indicestest = [indicestest1; indicestest2+537]; 

        %obj = fitcsvm(trainmatfull(indicestrain,:),[ones(400,1).*3;  ones(400,1).*6]); 
        obj = fitclinear(trainmatfull(indicestrain,:),[ones(400,1).*3;  ones(400,1).*6], 'Prior','uniform','Solver','sparsa','Regularization','lasso'); 
        
        [LABEL,SCORE]=predict(obj,trainmatfull(indicestest,:));
        
       accuracytemp(valstep) = sum(diag(crosstab(LABEL, labelvectorfull(indicestest))))./length(LABEL); 
      
       end
        
        meanaccuracy(timepoint) = mean(accuracytemp);
        temp = bootci(200,@mean,accuracytemp); 
        erroraccuracy(1, timepoint) = temp(1)-meanaccuracy(timepoint); 
        erroraccuracy(2, timepoint) = meanaccuracy(timepoint)-temp(2); 

    fprintf('.'); 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end

shadedErrorBar(taxis(1:24:2551), meanaccuracy(1:24:2551), erroraccuracy(:, 1:24:2551))
%%
% 3) this one works on many frequencies. needs to load each frequency first
% this does crossval with monte-carlo, coded by us
filemat3 = getfilesindir(pwd, '*001.mat.pow4*');
filemat6 = getfilesindir(pwd, '*002.mat.pow4*');

mat3d3 = [];
mat3d6 = [];


taxis = -3600:10:1500;
offset = 788; % this is just the number of trials in first condition, i.e. the second condition starts at 538
trainsetsize = 650; % this is the number of trials from each condition used for training, the rest is used for test

% now make a matrix for each frequency

for freq = 1:19
        
mat3d3 = [];
mat3d6 = [];
    
    disp('loading this frequency:')
    disp(freq)
    
    %load that freq into workspace
    for x = 1:size(filemat3,1)
        a3 = load(filemat3(x,:)); 
        temp = a3.WaPower4d; 
       mat3d3 = cat(3, mat3d3, squeeze(temp(:, :, freq, :))); 
        a6 = load(filemat6(x,:)); 
        temp = a6.WaPower4d; 
       mat3d6 = cat(3, mat3d6, squeeze(temp(:, :, freq, :))); 
        fprintf('-_'), if x/10 == round(x/10), disp(x), end
    end
  
comp1 = 1:537; 
comp2 = (1:491)+offset; 


disp('... done! starting classification.')

for timepoint = 1:10:511-9

trainmatfull = z_norm([squeeze(mean(mat3d3(:, timepoint:timepoint+9, :),2))'; squeeze(mean(mat3d6(:, timepoint:timepoint+9, :),2))']);

labelvectorfull = [ones(size(mat3d3,3),1).*3;  ones(size(mat3d6,3),1).*6];

        % to enable crossvalidation, pick 90% of the data, pick 300 from each
        % category

        for valstep = 1:50

        indicestrain1 = randperm(788, trainsetsize)'; 
        indicestrain2 =  randperm(729, trainsetsize)'+offset; 
        
        indicestrain = [indicestrain1; indicestrain2]; 

        indicestest1 = find(~ismember(comp1, indicestrain1))';
        indicestest2 = find(~ismember(comp2, indicestrain2))' + offset; 
        
        indicestest = [indicestest1; indicestest2]; 

        %obj = fitcsvm(trainmatfull(indicestrain,:),[ones(400,1).*3;  ones(400,1).*6]); 
        obj = fitclinear(trainmatfull(indicestrain,:),[ones(trainsetsize,1).*3;  ones(trainsetsize,1).*6], 'Solver','sparsa','Regularization','lasso'); 
        
        [LABEL,SCORE]=predict(obj,trainmatfull(indicestest,:));
        
       accuracytemp(valstep) = sum(diag(crosstab(LABEL, labelvectorfull(indicestest))))./length(LABEL); 
      
       end
        
        meanaccuracy(freq, timepoint) = mean(accuracytemp);
        temp = bootci(200,@mean,accuracytemp); 
        erroraccuracy(1, freq, timepoint) = temp(1)-meanaccuracy(freq, timepoint); 
        erroraccuracy(2, freq, timepoint) = meanaccuracy(freq, timepoint)-temp(2); 

    fprintf('.'); 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end % timepoint

shadedErrorBar(taxis(1:10:511-9), squeeze(meanaccuracy(freq, 1:10:511-9)), squeeze(erroraccuracy(:, freq,1:10:511-9)))
figure

end % frequencies


%%
% 4) apply test to averaged topographies
% this one works on many frequencies. needs to load each frequency first
% load 4 d files. these comd from here: 
% [WaPower4d] = wavelet_app_matfiles_singtrials(filemat, 500, 10, 104, 5);
% 
% this for 1001, 1002, 2001, 2002 files
% i.e. this is about the reinforcement history
 
clear
filemat3 = getfilesindir(pwd, '*001.mat.pow4*');
filemat6 = getfilesindir(pwd, '*002.mat.pow4*');

mat3d3 = [];
mat3d6 = [];


taxis = -3600:10:1500;
faxisfull = 0:0.1960:250; 
faxis = faxisfull(10:5:104);
 
offset = 788; % this is just the number of trials in first condition, i.e. the second condition starts after that number
Ncondi2 = 729; % this is just the number of trials in secon condition
trainsetsize = 600; % this is the number of trials from each condition used for training, the rest is used for test

% now make a matrix for each frequency

for freq = 1:19
        
mat3d3 = [];
mat3d6 = [];
    
    disp('loading this frequency:')
    disp(freq)
    
    %load that freq into workspace
    for x = 1:size(filemat3,1)
        a3 = load(filemat3(x,:)); 
        temp = a3.WaPower4d; 
       mat3d3 = cat(3, mat3d3, squeeze(temp(:, :, freq, :))); 
        a6 = load(filemat6(x,:)); 
        temp = a6.WaPower4d; 
       mat3d6 = cat(3, mat3d6, squeeze(temp(:, :, freq, :))); 
        fprintf('-_'), if x/10 == round(x/10), disp(x), end
    end
  
comp1 = 1:offset; 
comp2 = (1:Ncondi2)+offset; 


disp('... done! starting classification.')

timepointindex = 1; 

for timepoint = 1:10:511-29

trainmatfull = z_norm([squeeze(mean(mat3d3(:, timepoint:timepoint+29, :),2))'; squeeze(mean(mat3d6(:, timepoint:timepoint+29, :),2))']);

labelvectorfull = [ones(size(mat3d3,3),1).*3;  ones(size(mat3d6,3),1).*6];


        % classify the whole thing to obtain the weights
        objall = fitclinear(trainmatfull',[ones(1, offset).*3  ones(1, Ncondi2,1).*6], 'Solver','sparsa','Regularization','lasso', 'ObservationsIn','columns', 'Prior', 'empirical'); %'CrossVal', 'on'
        Wtopo(freq, timepointindex, :) = objall.Beta; 
        % to enable crossvalidation, pick 90% of the data, pick 300 from each
        % category

        for valstep = 1:200

        indicestrain1 = randperm(offset, trainsetsize)'; 
        indicestrain2 =  randperm(Ncondi2, trainsetsize)'+offset; 
        
        indicestrain = [indicestrain1; indicestrain2]; 

        indicestest1 = find(~ismember(comp1, indicestrain1))';
        indicestest2 = find(~ismember(comp2, indicestrain2))' + offset; 
        
        indicestest = [indicestest1; indicestest2]; 

        %obj = fitcsvm(trainmatfull(indicestrain,:),[ones(400,1).*3;  ones(400,1).*6]); 
        obj = fitclinear(trainmatfull(indicestrain,:)',[ones(1, trainsetsize).*3  ones(1, trainsetsize,1).*6], 'Solver','dual','Regularization','lasso', 'ObservationsIn','columns');
        
% solver was sparsa
        %testset is averaged
        test1a = mean(trainmatfull(indicestest1(1:floor(size(indicestest1,1)./2)), :)); 
        test1b = mean(trainmatfull(indicestest1(floor(size(indicestest1,1)./2)):end, :)); 
        test2a = mean(trainmatfull(indicestest2(1:floor(size(indicestest2,1)./2)), :)); 
        test2b = mean(trainmatfull(indicestest2(floor(size(indicestest2,1)./2)):end, :)); 
        
        [LABEL,SCORE]=predict(obj,[test1a; test1b; test2a; test2b]);
        
       accuracytemp(valstep) = ((LABEL(1) == 3) + (LABEL(2) == 3) + (LABEL(3) == 6) + (LABEL(4) == 6))./4; 
      
       end
        
        meanaccuracy(freq, timepoint) = mean(accuracytemp);
        temp = bootci(200,@mean,accuracytemp); 
        erroraccuracy(1, freq, timepoint) = temp(1)-meanaccuracy(freq, timepoint); 
        erroraccuracy(2, freq, timepoint) = meanaccuracy(freq, timepoint)-temp(2); 

    fprintf('.'); timepointindex = timepointindex+1; 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end % timepoint

figure
shadedErrorBar(taxis(1:10:511-29), squeeze(meanaccuracy(freq, 1:10:511-29)), squeeze(erroraccuracy(:, freq,1:10:511-29)))


end % frequencies
figure
contourf(taxis(1:10:511-29), faxis, meanaccuracy(:, 1:10:511-29))


%%
% 5) apply test to averaged topographies
% this one works on many frequencies. needs to load each frequency first
% load 4 d files. these comd from here: 
% [WaPower4d] = wavelet_app_matfiles_singtrials(filemat, 500, 10, 104, 5);
% 
% this for app3 and app6
% i.e. this is about expectancy
 
clear
filemat3 = getfilesindir(pwd, '*3.mat.pow4*');
filemat6 = getfilesindir(pwd, '*6.mat.pow4*');

mat3d3 = [];
mat3d6 = [];

channels =  [1:124 129];


taxis = -3600:10:1500;

faxisfull = 0:0.1960:250; 
faxis = faxisfull(10:5:104);
 
offset = 537; % this is just the number of trials in first condition, i.e. the second condition starts after that number
Ncondi2 = 491; % this is just the number of trials in secon condition
trainsetsize = 420; % this is the number of trials from each condition used for training, the rest is used for test

% now make a matrix for each frequency

for freq = 1:19
        
mat3d3 = [];
mat3d6 = [];
    
    disp('loading this frequency:')
    disp(freq)
    
    %load that freq into workspace
    for x = 1:size(filemat3,1)
        a3 = load(filemat3(x,:)); 
        temp = a3.WaPower4d; 
       mat3d3 = cat(3, mat3d3, squeeze(temp(:, :, freq, :))); 
        a6 = load(filemat6(x,:)); 
        temp = a6.WaPower4d; 
       mat3d6 = cat(3, mat3d6, squeeze(temp(:, :, freq, :))); 
        fprintf('-_'), if x/10 == round(x/10), disp(x), end
    end
  
comp1 = 1:offset; 

comp2 = (1:Ncondi2)+offset; 


disp('... done! starting classification.')

timepointindex = 1; 

for timepoint = 1:10:511-29

trainmatfull = z_norm([squeeze(mean(mat3d3(:, timepoint:timepoint+29, :),2))'; squeeze(mean(mat3d6(:, timepoint:timepoint+29, :),2))']);

labelvectorfull = [ones(size(mat3d3,3),1).*3;  ones(size(mat3d6,3),1).*6];


        % classify the whole thing to obtain the weights
        objall = fitclinear(trainmatfull',[ones(1, offset).*3  ones(1, Ncondi2,1).*6], 'Solver','sparsa','Regularization','lasso', 'ObservationsIn','columns', 'Prior', 'empirical'); %'CrossVal', 'on'
        Wtopo(freq, timepointindex, :) = objall.Beta; 
        % to enable crossvalidation, pick 90% of the data, pick 300 from each
        % category

        for valstep = 1:200

        indicestrain1 = randperm(offset, trainsetsize)'; 
        indicestrain2 =  randperm(Ncondi2, trainsetsize)'+offset; 
        
        indicestrain = [indicestrain1; indicestrain2]; 

        indicestest1 = find(~ismember(comp1, indicestrain1))';
        indicestest2 = find(~ismember(comp2, indicestrain2))' + offset; 
        
        indicestest = [indicestest1; indicestest2]; 

        %obj = fitcsvm(trainmatfull(indicestrain,:),[ones(400,1).*3;  ones(400,1).*6]); 
        obj = fitclinear(trainmatfull(indicestrain,:)',[ones(1, trainsetsize).*3  ones(1, trainsetsize).*6], 'Solver','sparsa','Regularization','lasso', 'ObservationsIn','columns');
        
        %testset is averaged
        test1a = mean(trainmatfull(indicestest1(1:floor(size(indicestest1,1)./2)), :)); 
        test1b = mean(trainmatfull(indicestest1(floor(size(indicestest1,1)./2)):end, :)); 
        test2a = mean(trainmatfull(indicestest2(1:floor(size(indicestest2,1)./2)), :)); 
        test2b = mean(trainmatfull(indicestest2(floor(size(indicestest2,1)./2)):end, :)); 
        
        [LABEL,SCORE]=predict(obj,[test1a; test1b; test2a; test2b]);
        
       accuracytemp(valstep) = ((LABEL(1) == 3) + (LABEL(2) == 3) + (LABEL(3) == 6) + (LABEL(4) == 6))./4; 
      
       end
        
        meanaccuracy(freq, timepoint) = mean(accuracytemp);
        temp = bootci(200,@mean,accuracytemp); 
        erroraccuracy(1, freq, timepoint) = temp(1)-meanaccuracy(freq, timepoint); 
        erroraccuracy(2, freq, timepoint) = meanaccuracy(freq, timepoint)-temp(2); 

    fprintf('.'); 
    
    timepointindex = timepointindex+1; 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end % timepoint

pause(.5)
figure
shadedErrorBar(taxis(1:10:511-29), squeeze(meanaccuracy(freq, 1:10:511-29)), squeeze(erroraccuracy(:, freq,1:10:511-29)))
pause(.5)

end % frequencies
figure
contourf(taxis(1:10:511-29), faxis, meanaccuracy(:, 1:10:511-29))

%%
% try matlab crossval

%%
% 6) do training AND test to averaged topographies, December 2019
% uses matlab k-fold crossvalidation
% this one works on many frequencies. needs to load each frequency first
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
 
offset = 537; % this is just the number of trials in first condition, i.e. the second condition starts after that number
Ncondi2 = 491; % this is just the number of trials in second condition
trainsetsize = 420; % this is the number of trials from each condition used for training, the rest is used for test

% now make a matrix for each frequency

for freq = 1:19
        
mat3d3 = [];
mat3d6 = [];
    
    disp('loading this frequency:')
    disp(freq)
    
    %load that freq into workspace
    for x = 1:size(filemat3,1)
        a3 = load(filemat3(x,:)); 
        temp = a3.WaPower4d; 
       mat3d3 = cat(3, mat3d3, squeeze(temp(:, :, freq, :))); 
        a6 = load(filemat6(x,:)); 
        temp = a6.WaPower4d; 
       mat3d6 = cat(3, mat3d6, squeeze(temp(:, :, freq, :))); 
       
        fprintf('-_'), if x/10 == round(x/10), disp(x), end
        
    end
    
    % now average some trials before classifier
    for x = 1:stepsize
    mat3d3avg(:, :, x) = mean(mat3d3(:, :, x:stepsize:end), 3); 
    mat3d6avg(:, :, x) = mean(mat3d6(:, :, x:stepsize:end), 3);     
    end
  
    comp1 = 1:offset; 
    comp2 = (1:Ncondi2)+offset; 
    
    labelvectorfull = [ones(size(mat3d3avg,3),1).*3;  ones(size(mat3d6avg,3),1).*6];


disp('... done! starting classification.')

timepointindex = 1; 

Y = labelvectorfull'; 

for timepoint = 1:size(mat3d3avg,2)

         trainmatfull = z_norm([squeeze((mat3d3avg(channels, timepoint, : )))'; squeeze((mat3d6avg(channels, timepoint, :)))']); % 1st dim are channels  
         
         objforweights = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Solver','dual', 'ObservationsIn','columns');    
         Weight_topo(freq, timepoint, :) = objforweights.Beta;     
        
         Ynoise =  labelvectorfull(randperm(length(labelvectorfull)))'; 
         
         obj = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Kfold',20, 'Solver','dual', 'ObservationsIn','columns');         
         %version control: this used to be 'Solver','sparsa','Regularization','lasso',
         
         Yhat = kfoldPredict(obj);
  
         aha = confusionmat(Y,Yhat); 
         
         ahanoise = confusionmat(Ynoise,Yhat); 
        
         meanaccuracy(freq, timepoint) = sum(diag(aha))./(sum(sum(aha))); 
     
         erroraccuracy(freq, timepoint) =  sum(diag(ahanoise))./(sum(sum(ahanoise))); % error for error bars. the eror stats needs more iterations

    fprintf('.'); 
    
    timepointindex = timepointindex+1; 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end % timepoint
% 
 meanaccuracy(freq,:) = movingavg_as(meanaccuracy(freq,:), 14); 
 erroraccuracy(freq,:) = movingavg_as(abs(erroraccuracy(freq,:)-0.5),14);

pause(.5)
figure
shadedErrorBar(taxis, meanaccuracy(freq,:), erroraccuracy(freq,:))
pause(.5)

end % frequencies
figure
contourf(taxis, faxis, meanaccuracy), colorbar


%%
% 7) do training AND test to averaged topographies, December 2019
% uses matlab k-fold crossvalidation
% this one works on many frequencies. needs to load each frequency first
% load 4 d files. these come from here: 
% [WaPower4d] = wavelet_app_matfiles_singtrials(filemat, 500, 10, 104, 5);
% 
% this for spp1 and app2
% i.e. this is about what happened in the past
 
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
 
% now make a matrix for each frequency

for freq = 1:19
        
mat3d3 = [];
mat3d6 = [];
    
    disp('loading this frequency:')
    disp(freq)
    
    %load that freq into workspace
    for x = 1:size(filemat3,1)
        a3 = load(filemat3(x,:)); 
        temp = a3.WaPower4d; 
       mat3d3 = cat(3, mat3d3, squeeze(temp(:, :, freq, :))); 
        a6 = load(filemat6(x,:)); 
        temp = a6.WaPower4d; 
       mat3d6 = cat(3, mat3d6, squeeze(temp(:, :, freq, :))); 
       
        fprintf('-_'), if x/10 == round(x/10), disp(x), end
        
    end
    
    % now average some trials before classifier
    for x = 1:stepsize
    mat3d3avg(:, :, x) = mean(mat3d3(:, :, x:stepsize:end), 3); 
    mat3d6avg(:, :, x) = mean(mat3d6(:, :, x:stepsize:end), 3);     
    end
  
    
    labelvectorfull = [ones(size(mat3d3avg,3),1).*3;  ones(size(mat3d6avg,3),1).*6];


disp('... done! starting classification.')

timepointindex = 1; 

Y = labelvectorfull'; 

for timepoint = 1:size(mat3d3avg,2)

         trainmatfull = z_norm([squeeze((mat3d3avg(channels, timepoint, : )))'; squeeze((mat3d6avg(channels, timepoint, :)))']); % 1st dim are channels  
         
         objforweights = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Solver','dual', 'ObservationsIn','columns');    
         Weight_topo(freq, timepoint, :) = objforweights.Beta;     
        
         Ynoise =  labelvectorfull(randperm(length(labelvectorfull)))'; 
         
         obj = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Kfold',20, 'Solver','dual', 'ObservationsIn','columns');         
         %version control: this used to be 'Solver','sparsa','Regularization','lasso',
         
         Yhat = kfoldPredict(obj);
  
         aha = confusionmat(Y,Yhat); 
         
         ahanoise = confusionmat(Ynoise,Yhat); 
        
         meanaccuracy(freq, timepoint) = sum(diag(aha))./(sum(sum(aha))); 
     
         erroraccuracy(freq, timepoint) =  sum(diag(ahanoise))./(sum(sum(ahanoise))); % error for error bars. the eror stats needs more iterations

    fprintf('.'); 
    
    timepointindex = timepointindex+1; 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end % timepoint
% 
 meanaccuracy(freq,:) = movingavg_as(meanaccuracy(freq,:), 14); 
 erroraccuracy(freq,:) = movingavg_as(abs(erroraccuracy(freq,:)-0.5),14);

pause(.5)
figure
shadedErrorBar(taxis, meanaccuracy(freq,:), erroraccuracy(freq,:))
pause(.5)

end % frequencies
figure
contourf(taxis, faxis, meanaccuracy), colorbar


%%
% 8) do training AND test to averaged topographies, December 2019
% uses matlab k-fold crossvalidation
% this one works focuses on alpha
% load 4 d files. these come from here: 
% [WaPower4d] = wavelet_app_matfiles_singtrials(filemat, 500, 10, 104, 5);
% 
% this for spp1 and app2
% i.e. this is about what happened in the past
 
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

for freq = 1:17
        
mat3d3 = [];
mat3d6 = [];
    
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
  
    
    labelvectorfull = [ones(size(mat3d3avg,3),1).*3;  ones(size(mat3d6avg,3),1).*6];


disp('... done! starting classification.')

timepointindex = 1; 

Y = labelvectorfull'; 

for timepoint = 1:size(mat3d3avg,2)

         trainmatfull = z_norm([squeeze((mat3d3avg(channels, timepoint, : )))'; squeeze((mat3d6avg(channels, timepoint, :)))']); % 1st dim are channels  
         
         objforweights = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Solver','sparsa', 'ObservationsIn','columns');    
         Weight_topo(freq, timepoint, :) = objforweights.Beta;     
        
         Ynoise =  labelvectorfull(randperm(length(labelvectorfull)))'; 
         
         obj = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Kfold',20, 'Solver','sparsa', 'ObservationsIn','columns');         
         %version control: this used to be 'Solver','sparsa','Regularization','lasso',
         
         Yhat = kfoldPredict(obj);
  
         aha = confusionmat(Y,Yhat); 
         
         ahanoise = confusionmat(Ynoise,Yhat); 
        
         meanaccuracy(freq, timepoint) = sum(diag(aha))./(sum(sum(aha))); 
     
         erroraccuracy(freq, timepoint) =  sum(diag(ahanoise))./(sum(sum(ahanoise))); % error for error bars. the eror stats needs more iterations

    fprintf('.'); 
    
    timepointindex = timepointindex+1; 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end % timepoint
% 
 meanaccuracy(freq,:) = movingavg_flip(meanaccuracy(freq,:), 14); 
 erroraccuracy(freq,:) = movingavg_flip(abs(erroraccuracy(freq,:)-0.5),14);

pause(.5)
figure
shadedErrorBar(taxis, meanaccuracy(freq,:), erroraccuracy(freq,:))
pause(.5)

end % frequencies

%%
% 9) do training AND test to averaged topographies, December 2019
% uses matlab k-fold crossvalidation
% this one  focuses on alpha
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

for freq = 1:19-2
        
mat3d3 = [];
mat3d6 = [];
    
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
  
    
    labelvectorfull = [ones(size(mat3d3avg,3),1).*3;  ones(size(mat3d6avg,3),1).*6];


disp('... done! starting classification.')

timepointindex = 1; 

Y = labelvectorfull'; 

for timepoint = 1:size(mat3d3avg,2)

         trainmatfull = z_norm([squeeze((mat3d3avg(channels, timepoint, : )))'; squeeze((mat3d6avg(channels, timepoint, :)))']); % 1st dim are channels  
         
         objforweights = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Solver','sparsa', 'ObservationsIn','columns');    
         Weight_topo(freq, timepoint, :) = objforweights.Beta;     
        
         Ynoise =  labelvectorfull(randperm(length(labelvectorfull)))'; 
         
         obj = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Kfold',20, 'Solver','sparsa', 'ObservationsIn','columns');         
         %version control: this used to be 'Solver','sparsa','Regularization','lasso',
         
         Yhat = kfoldPredict(obj);
  
         aha = confusionmat(Y,Yhat); 
         
         ahanoise = confusionmat(Ynoise,Yhat); 
        
         meanaccuracy(freq, timepoint) = sum(diag(aha))./(sum(sum(aha))); 
     
         erroraccuracy(freq, timepoint) =  sum(diag(ahanoise))./(sum(sum(ahanoise))); % error for error bars. the eror stats needs more iterations

    fprintf('.'); 
    
    timepointindex = timepointindex+1; 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end % timepoint
% 
 meanaccuracy(freq,:) = movingavg_as(meanaccuracy(freq,:), 14); 
 erroraccuracy(freq,:) = movingavg_as(abs(erroraccuracy(freq,:)-0.5),14);

pause(.5)
figure
shadedErrorBar(taxis, meanaccuracy(freq,:), erroraccuracy(freq,:))
pause(.5)

end % frequencies












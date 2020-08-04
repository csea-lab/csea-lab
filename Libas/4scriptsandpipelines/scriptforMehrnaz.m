
%%%%%%
%%%%%%%%%%%%%%%%%%%%
%single trials
%% 
clear powavg

for index = 1:120
    
    powsubj = []; 
    
    a = load(deblank(filemat(index,:))); 
    
    data = a.outmat; 
   
    for trial = 1:size(data,3), 
    
            [pow1, phase, freqs] = FFT_spectrum(data(:, 258:1000, trial), 250);
            SNR1 = 10.*log10(pow1(:, 53)./mean(pow1(:,[38:47 60 70]), 2)); 

            if trial==1, 
                powsubj = pow1; 
                SNRsub = SNR1;
            else
                powsubj = powsubj+ pow1; 
                SNRsub = SNRsub+ SNR1;
            end

    end
    powsubj = powsubj./size(data,3); 
    SNRsub = SNRsub./size(data,3); 
    
    if index ==1, 
        powsum = powsubj; 
        SNRsum = SNRsub; 
    else
        powsum = powsubj+ powsum; 
         SNRsum = SNRsum+ SNRsub; 
    end
    
    
    %plot(freqs(3:80), powsubj(:, 3:80)'), title(deblank(filemat(index,:))); pause
    
    fprintf('.')
    
    
end
 powavg = powsum./size(filemat,1);
 SNRavg = SNRsum./size(filemat,1);

%%%%%%
%%%%%%
%%% extract features

%% extract features- angry
for index = 1:size(filemat_a,1), 
    
    powsubj_a = []; 
    powsubj_n= []; 
    
    a = load(deblank(filemat_a(index,:))); 
    n = load(deblank(filemat_n(index,:))); 
     
    data_a = a.outmat; 
     
    data_n = n.outmat; 

    %first determine mean power at 17.5 Hz for neutral faces
    for trial = 1:size(data_n,3), 
    
            [pow1, phase, freqs] = FFT_spectrum(data_n(:, 158:900, trial), 250);

            if trial==1, 
                powsubj = pow1; 
            else
                powsubj = powsubj+ pow1; 
            end

     end
    powsubj = powsubj./trial; 
    
    plot(freqs(3:80), powsubj(:, 3:80)'), title(deblank(filemat_a(index,:))); pause(1)
   
  %now create features by normalizing angry face power for each trial by
  %mean neutral power and save 17.5 power for each trial to disk
  
    for trial = 1:size(data_a,3), 
    
            [pow2, phase, freqs] = FFT_spectrum(data_a(:, 258:1000, trial), 250);
            
            pownorm_a(:, trial) = pow2(:, 53)./powsubj(:,53); 
            
           outname =  [deblank(filemat_a(index,:)) 'pownorm_a.mat']
           
           eval(['save ' outname ' pownorm_a -mat'])
            
     end
    
    
end


%%%%
%%%

%% extract features- fearful
for index = 1:size(filemat_f,1), 
    
    powsubj_f = []; 
    powsubj_n= []; 
    
    f = load(deblank(filemat_f(index,:))); 
    n = load(deblank(filemat_n(index,:))); 
     
    data_f = f.outmat; 
     
    data_n = n.outmat; 

    %first determine mean power at 17.5 Hz for neutral faces
    for trial = 1:size(data_n,3), 
    
            [pow1, phase, freqs] = FFT_spectrum(data_n(:, 258:1000, trial), 250);

            if trial==1, 
                powsubj = pow1; 
            else
                powsubj = powsubj+ pow1; 
            end

     end
    powsubj = powsubj./trial; 
    
    plot(freqs(3:80), powsubj(:, 3:80)'), title(deblank(filemat_f(index,:))); pause(1)
   
  %now create features by normalizing angry face power for each trial by
  %mean neutral power and save 17.5 power for each trial to disk
  
    for trial = 1:size(data_f,3), 
    
            [pow2, phase, freqs] = FFT_spectrum(data_f(:, 258:1000, trial), 250);
            
            pownorm_f(:, trial) = pow2(:, 53)./powsubj(:,53); 
            
           outname =  [deblank(filemat_f(index,:)) 'pownorm_f.mat']
           
           eval(['save ' outname ' pownorm_f -mat'])
            
     end
    
    
end


%%%%
%%%
%% extract features- happy
for index = 1:size(filemat_h,1), 
    
    powsubj_h = []; 
    powsubj_n= []; 
    
    h = load(deblank(filemat_h(index,:))); 
    n = load(deblank(filemat_n(index,:))); 
     
    data_h = h.outmat; 
     
    data_n = n.outmat; 

    %first determine mean power at 17.5 Hz for neutral faces
    for trial = 1:size(data_n,3), 
    
            [pow1, phase, freqs] = FFT_spectrum(data_n(:, 258:1000, trial), 250);

            if trial==1, 
                powsubj = pow1; 
            else
                powsubj = powsubj+ pow1; 
            end

     end
    powsubj = powsubj./trial; 
    figure(10)
    plot(freqs(3:80), powsubj(:, 3:80)'), title(deblank(filemat_h(index,:))); pause(1)
   
  %now create features by normalizing angry face power for each trial by
  %mean neutral power and save 17.5 power for each trial to disk
  
    for trial = 1:size(data_h,3), 
    
            [pow2, phase, freqs] = FFT_spectrum(data_h(:, 258:1000, trial), 250);
            
            pownorm_h(:, trial) = pow2(:, 53)./powsubj(:,53); 
            
           outname =  [deblank(filemat_h(index,:)) 'pownorm_h.mat']
           
           eval(['save ' outname ' pownorm_h -mat'])
            
     end
    
    
end


%%%%
%% load normalized power and get means by condition and group
filemat_h = filemat(1:3:end, :)
filemat_f=  filemat(2:3:end, :)
filemat_a=  filemat(3:3:end, :)
%% get means by condition and group
% 1 = circumscribed
% 2 = generalized
% 3 = PDA

labels =[2,3,3,3,2,2,2,3,1,99,1,1,2,3,3,2,2,3,1,2,3,3,3,1,99,2,3,99,99,1,3,2,1,1,1,3,1,3,1,1,3,3,3,99,1,2,3,99,3,2,2,99,2,1,2,2,1,3,2,1,2,2,2,99,99,1,3,3,1];

AvgData = []; 

for index = 1:size(filemat_f,1), 
     
      a = load(deblank(filemat_a(index,:))); 
    
  
    data =  a.pownorm_a;
    
   % plot(data'), pause

   
     AvgData(:, index) = mean(data, 2); 
   
end


AvgNormPow_circ_fear= mean(AvgData(:, labels==1), 2);
AvgNormPow_gen_fear= mean(AvgData(:, labels==2), 2);
AvgNormPow_PDA_fear = mean(AvgData(:, labels==3), 2);

%%
% compare group means for normalized amplitude using ttests
[dum, dum, dum, stats12] = ttest2(AvgData(:, labels==1), AvgData(:, labels==2), 'dim', 2)
[dum, dum, dum, stats13] = ttest2(AvgData(:, labels==1), AvgData(:, labels==3), 'dim', 2)
[dum, dum, dum, stats23] = ttest2(AvgData(:, labels==2), AvgData(:, labels==3), 'dim', 2)



%%%
%% load features and plot spatial dependencies

plotflag =1;
clear pairs
clear featuremat
labels =[2,3,3,3,2,2,2,3,1,99,1,1,2,3,3,2,2,3,1,2,3,3,3,1,99,2,3,99,99,1,3,2,1,1,1,3,1,3,1,1,3,3,3,99,1,2,3,99,3,2,2,99,2,1,2,2,1,3,2,1,2,2,2,99,99,1,3,3,1];

% [pairs] = nchoosek(unique([62    67    70       72    73    74    75    92 76    11    81    82    83    84    88    89]), 2);
% [pairs] = nchoosek(unique([60    89    66    53    42  75   92    85  86 ]), 2)
% pairs = [pairs;  75 89; 75 92]
 %pairs = nchoosek(unique([75  89  92  69  96  ]), 2);
 
 pairs = [75 69; 75 52;75 89; 75 92]

for index = 1:size(filemat_a,1), 
     
      a = load(deblank(filemat_a(index,:))); 
    
    data = a.pownorm_a; 
    %data =  a.pownorm_f;
   %data = a.pownorm_a; 
   

  if plotflag == 1
   
      figure(1),  plot(data)
     figure(2)   
     subplot(8,1,1), plot(data(73,:), data(72,:), 'o'), axis([0 3 0 3]), lsline
     title(num2str(labels(index)))
     subplot(8,1,2), plot(data(70,:), data(84,:), 'o'),axis([0 3 0 3]), lsline
     subplot(8,1,3), plot(data(67,:), data(62,:), 'o'),axis([0 3 0 3]), lsline
     subplot(8,1,4), plot(data(82,:), data(84,:), 'o'),axis([0 3 0 3]), lsline
     subplot(8,1,5), plot(data(81,:), data(89,:), 'o'), axis([0 3 0 3]),lsline
     subplot(8,1,6), plot(data(74,:), data(88,:), 'o'),axis([0 3 0 3]), lsline
     subplot(8,1,7), plot(data(75,:), data(89,:), 'o'),axis([0 3 0 3]), lsline
     subplot(8,1,8), plot(data(75,:), data(92,:), 'o'),axis([0 3 0 3]), lsline
    % pause(1)
    % savefig(['scatter' num2str(index) '.fig'])
     pause(1)

  end
     
     fprintf('.')
      
     for pairindex = 1:size(pairs,1)
         linearCoefficients = polyfit(data(pairs(pairindex,1),:), data(pairs(pairindex,2),:), 1);
         featuremat(index, pairindex) = linearCoefficients(1);
     end
    
end

%% classify
    correct = []; 
 
    
for feature = 3:3
    
       votingmat = []; 
    
    featureindex = feature:feature+1

     mat12 = [featuremat(labels==1, featureindex); featuremat(labels==2, featureindex)]; 
     labels12 = [ones(size(featuremat(labels==1,:), 1),1); ones(size(featuremat(labels==2,:), 1),1).*2];

     mat23 = [featuremat(labels==2, featureindex); featuremat(labels==3, featureindex)]; 
     labels23 = [ones(size(featuremat(labels==2,:), 1),1).*2; ones(size(featuremat(labels==3,:), 1),1).*3];

     mat31 = [featuremat(labels==3, featureindex); featuremat(labels==1, featureindex)]; 
     labels31 = [ones(size(featuremat(labels==3,:), 1),1).*3; ones(size(featuremat(labels==1,:), 1),1).*1];
     
   
         
         leavoutvec12 = randperm(size(mat12,1)); 
         leavoutvec23 = randperm(size(mat23,1)); 
         leavoutvec31 = randperm(size(mat31,1)); 
    
     [CLASS12,ERR12,POSTERIOR,LOGP,COEF]  =  classify(featuremat(:, featureindex), mat12(leavoutvec12(1:20),:), labels12(leavoutvec12(1:20),:)) ;
     [CLASS23,ERR23,POSTERIOR,LOGP,COEF]  = classify(featuremat(:, featureindex), mat23(leavoutvec23(1:20),:), labels23(leavoutvec23(1:20),:)) ;
     [CLASS31,ERR31,POSTERIOR,LOGP,COEF]  = classify(featuremat(:, featureindex), mat31(leavoutvec31(1:20),:), labels31(leavoutvec31(1:20),:)) ;
      
       votingmat = [votingmat CLASS12 CLASS23 CLASS31 ]
       


  
     % forget about 99
     labelsvoting = labels(labels~=99); 
     votingmatvoting = votingmat(labels~=99,:);

     [votingmatvoting labelsvoting'];

     classvec = []; 

         
             for x1 = 1:size(labelsvoting,2)
                     classvec(x1) = mode(votingmatvoting(x1,:))==labelsvoting(x1);         
             end

     correct(feature) = sum(classvec)/length(classvec) 

     plot(labels(labels~=99), featuremat(labels~=99,1), 'o'), pause
 
end

 %% classify with monte carlo cross-validation - ak main
    correct = [];     
    modemat = [];   
    correctbydiag = [];
    
 for run = 1:300   
    
for feature = 1:3
    
    
       votingmat = []; 
    
    featureindex = [feature : feature+1];

      mat12 = [featuremat(labels==1, featureindex); featuremat(labels==2, featureindex)]; 
     labels12 = [ones(size(featuremat(labels==1,:), 1),1); ones(size(featuremat(labels==2,:), 1),1).*2];

     mat23 = [featuremat(labels==2, featureindex); featuremat(labels==3, featureindex)]; 
     labels23 = [ones(size(featuremat(labels==2,:), 1),1).*2; ones(size(featuremat(labels==3,:), 1),1).*3];

     mat31 = [featuremat(labels==3, featureindex); featuremat(labels==1, featureindex)]; 
     labels31 = [ones(size(featuremat(labels==3,:), 1),1).*3; ones(size(featuremat(labels==1,:), 1),1).*1];
     

         leavoutvec12 = randperm(size(mat12,1)); 
         leavoutvec23 = randperm(size(mat23,1)); 
         leavoutvec31 = randperm(size(mat31,1)); 
    
     [CLASS12,ERR12,POSTERIOR,LOGP,COEF]  =  classify(featuremat(:, featureindex), mat12(leavoutvec12(1:33),:), labels12(leavoutvec12(1:33),:), 'diaglinear') ;
     [CLASS23,ERR23,POSTERIOR,LOGP,COEF]  = classify(featuremat(:, featureindex), mat23(leavoutvec23(1:37),:), labels23(leavoutvec23(1:37),:),'diaglinear') ;
     [CLASS31,ERR31,POSTERIOR,LOGP,COEF]  = classify(featuremat(:, featureindex), mat31(leavoutvec31(1:35),:), labels31(leavoutvec31(1:35),:),'diaglinear') ;
     
       votingmat = [votingmat CLASS12 CLASS23 CLASS31 ];
     
   
     % forget about 99
     labelsvoting = labels(labels~=99);  
     votingmatvoting = votingmat(labels~=99,:);

     [votingmatvoting labelsvoting'];

     classvec = []; 

              for x1 = 1:size(labelsvoting,2)       
              classvec(x1)  = ismember(labelsvoting(x1), votingmatvoting(x1,1:2)) && ismember(labelsvoting(x1), votingmatvoting(x1,2:3));
               modemat(feature, x1) = round((mode(votingmatvoting(x1,:)) + labelsvoting(x1))./2); 
              end

     correct(run, feature) = sum(classvec)/(length(classvec)-length(featureindex)); 
    

     
end

  correctbydiag(run,:) = [max(crosstab(squeeze((modemat(3,:))), labelsvoting))./sum(crosstab(squeeze((modemat(3,:))), labelsvoting)) sum(diag(crosstab(modemat(3,:), labelsvoting)))./60];

if run/10 == round(run/10), figure(199), disp(run), plot(mean(correct)),hold on,  end
 
 end
 

 hold off
 
 
 %% plot classification results: bivariate scatterplots
 figure (11)
for featureInd = 1:35
    plot(featuremat(labels==1, featureInd), featuremat(labels==1, featureInd+2), 'ro'), hold on
    plot(featuremat(labels==2, featureInd), featuremat(labels==2, featureInd+2), 'ko'), 
    plot(featuremat(labels==3, featureInd), featuremat(labels==3, featureInd+2), 'bo'),  pause , hold off
end
 
 %% method check: PLOT scatter for feature - check if bivariate scatterplots acc reflect conditions, do not use for analysis
 figure (13)
 featuremattest = featuremat; 
 featuremattest(labels==3,:) = featuremat(labels==3,:)+.2; 
 featuremattest(labels==1,:) = featuremat(labels==1,:)./1.2; 
 featuremattest(labels==2,1:2:end) = featuremat(labels==2,1:2:end)./2.2; 
 
for featureInd = 1:3
    plot(featuremattest(labels==1, featureInd), featuremattest(labels==1, featureInd+1), 'ro'), hold on
    plot(featuremattest(labels==2, featureInd), featuremattest(labels==2, featureInd+1), 'ko'), 
    plot(featuremattest(labels==3, featureInd), featuremattest(labels==3, featureInd+1), 'bo'),  pause , hold off
end

featuremattest(labels==99, :) = []; 

labelvec1vsrest = labels(labels < 99); labelvec1vsrest(labelvec1vsrest==3) = 2; 
[CLASS1vsrest,ERR,POSTERIOR,LOGP,COEF1vsrest]  =  classify(featuremattest(:, 3:4), featuremattest(:, 3:4), labelvec1vsrest, 'linear') ;

labelvec2vsrest = labels(labels < 99); labelvec2vsrest(labelvec2vsrest==3) = 1; 
[CLASS2vsrest,ERR,POSTERIOR,LOGP,COEF2vsrest]  =  classify(featuremattest(:, 3:4), featuremattest(:, 3:4), labelvec2vsrest, 'linear') ;

labelvec3vsrest = labels(labels < 99); labelvec3vsrest(labelvec3vsrest==2) = 1; 
[CLASS3vsrest,ERR,POSTERIOR,LOGP,COEF3vsrest]  =  classify(featuremattest(:, 3:4), featuremattest(:, 3:4), labelvec3vsrest, 'linear') ;

figure (101)
% 1 vs rest
subplot(1,3,1)
 L = COEF1vsrest(1,2).linear;
K= COEF1vsrest(1,2).const;
f = @(x,y) K + L(1)*x + L(2)*y;
for featureInd = 1:3
    plot(featuremattest(labelvec1vsrest==1, featureInd), featuremattest(labelvec1vsrest==1, featureInd+1), 'ko', 'MarkerFaceColor',[0 0 0]), hold on
    plot(featuremattest(labelvec1vsrest==2, featureInd), featuremattest(labelvec1vsrest==2, featureInd+1), 'ko'), 
    ezplot(f, [-2 2]); axis([-2 2 -2 2]), pause, hold off
end

% 2 vs rest
subplot(1,3,2)
 L = COEF2vsrest(1,2).linear;
K= COEF2vsrest(1,2).const;
f = @(x,y) K + L(1)*x + L(2)*y;
for featureInd = 1:3
    plot(featuremattest(labelvec2vsrest==1, featureInd), featuremattest(labelvec2vsrest==1, featureInd+1), 'ko'), hold on
    plot(featuremattest(labelvec2vsrest==2, featureInd), featuremattest(labelvec2vsrest==2, featureInd+1), 'ko',  'MarkerFaceColor',[0 0 0]), 
    ezplot(f, [-2 2]); axis([-2 2 -2 2]), pause, hold off
end

% 3 vs rest
subplot(1,3,3)
 L = COEF3vsrest(1,2).linear;
K= COEF3vsrest(1,2).const;
f = @(x,y) K + L(1)*x + L(2)*y;
for featureInd = 1:3
    plot(featuremattest(labelvec3vsrest==1, featureInd), featuremattest(labelvec3vsrest==1, featureInd+1), 'ko'), hold on
    plot(featuremattest(labelvec3vsrest==3, featureInd), featuremattest(labelvec3vsrest==3, featureInd+1), 'ko', 'MarkerFaceColor',[0 0 0]), 
    ezplot(f, [-2 2]); axis([-2 2 -2 2]), pause, hold off
end



 %% extract topo classification results:topomaps
 
 elecweights = []; 
elecvec = [62    67    70    71    72    73    74    75    76    77    81    82    83    84    88    89];

for elec = 1:16
elecweights(elec) = sum(correct(pairs(1:119,1)==elecvec(elec))) + sum(correct(pairs(1:119,2)==elecvec(elec)))
end

elecweights = elecweights./16
 
%%%
%% load features and plot spatial dependencies for all sensors, 2 features
clear pairs
clear featuremat
labels =[2,3,3,3,2,2,2,3,1,99,1,1,2,3,3,2,2,3,1,2,3,3,3,1,99,2,3,99,99,1,3,2,1,1,1,3,1,3,1,1,3,3,3,99,1,2,3,99,3,2,2,99,2,1,2,2,1,3,2,1,2,2,2,99,99,1,3,3,1];

pairs = [ones(129,1).*75 column(1:129)]; 
pairs(75,:) = [75 129]

for index = 1:size(filemat_a,1), 
     
      a = load(deblank(filemat_a(index,:))); 
    
    data = a.pownorm_a; 
    %data =  a.pownorm_f;
   %data = a.pownorm_a; 
   
     
     fprintf('.')
      
     for pairindex = 1:129
         linearCoefficients = polyfit(data(pairs(pairindex,1),:), data(pairs(pairindex,2),:), 1);
         featuremat(index, pairindex) = linearCoefficients(1);
     end
    
end %%
%% classify with monte carlo cross-validation - all 129 
    correct = [];     
    modemat = [];   
    correctbydiag = [];
    
 for run = 1:100   
    
for feature = 1:128
    
       votingmat = []; 
    
    featureindex = [feature : feature+1];

      mat12 = [featuremat(labels==1, featureindex); featuremat(labels==2, featureindex)]; 
     labels12 = [ones(size(featuremat(labels==1,:), 1),1); ones(size(featuremat(labels==2,:), 1),1).*2];

     mat23 = [featuremat(labels==2, featureindex); featuremat(labels==3, featureindex)]; 
     labels23 = [ones(size(featuremat(labels==2,:), 1),1).*2; ones(size(featuremat(labels==3,:), 1),1).*3];

     mat31 = [featuremat(labels==3, featureindex); featuremat(labels==1, featureindex)]; 
     labels31 = [ones(size(featuremat(labels==3,:), 1),1).*3; ones(size(featuremat(labels==1,:), 1),1).*1];
     

         leavoutvec12 = randperm(size(mat12,1)); 
         leavoutvec23 = randperm(size(mat23,1)); 
         leavoutvec31 = randperm(size(mat31,1)); 
    
     [CLASS12,ERR12,POSTERIOR,LOGP,COEF]  =  classify(featuremat(:, featureindex), mat12(leavoutvec12(1:33),:), labels12(leavoutvec12(1:33),:), 'diaglinear') ;
     [CLASS23,ERR23,POSTERIOR,LOGP,COEF]  = classify(featuremat(:, featureindex), mat23(leavoutvec23(1:37),:), labels23(leavoutvec23(1:37),:),'diaglinear') ;
     [CLASS31,ERR31,POSTERIOR,LOGP,COEF]  = classify(featuremat(:, featureindex), mat31(leavoutvec31(1:35),:), labels31(leavoutvec31(1:35),:),'diaglinear') ;
     
       votingmat = [votingmat CLASS12 CLASS23 CLASS31 ];
     
   
     % forget about 99
     labelsvoting = labels(labels~=99);  
     votingmatvoting = votingmat(labels~=99,:);

     [votingmatvoting labelsvoting'];

     classvec = []; 

              for x1 = 1:size(labelsvoting,2)       
              classvec(x1)  = ismember(labelsvoting(x1), votingmatvoting(x1,1:2)) && ismember(labelsvoting(x1), votingmatvoting(x1,2:3));
               modemat(feature, x1) = round((mode(votingmatvoting(x1,:)) + labelsvoting(x1))./2); 
              end

     correct(run, feature) = sum(classvec)/(length(classvec)-length(featureindex)); 
     
     correctCirc(run, feature) = sum(classvec(labelsvoting==1))/(length(classvec(labelsvoting==1))); 
     correctGen(run, feature) = sum(classvec(labelsvoting==2))/(length(classvec(labelsvoting==2))); 
     correctPDA(run, feature) = sum(classvec(labelsvoting==3))/(length(classvec(labelsvoting==3))); 
        
end

  correctbydiag(run, :) = [max(crosstab(squeeze((modemat(3,:))), labelsvoting))./sum(crosstab(squeeze((modemat(3,:))), labelsvoting)) sum(diag(crosstab(modemat(3,:), labelsvoting)))./60];

if run/10 == round(run/10), figure(199), disp(run), plot(mean(correct)),hold on,  end
 
 end
 
topoclassificvec  = mean(correct)';
topoclassificvec = [topoclassificvec; topoclassificvec(75)]; 

disp('done !')
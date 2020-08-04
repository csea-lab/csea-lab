function [pvalmatout, partOmegaout, partEtasquareout, percentdetectout] = montecarloRM_kierstin(runs)

pvalmat = []; 

time =  ['b'; 'a'; 'b'; 'a'; 'b'; 'a'; 'b'; 'a'];
content =  ['n'; 'n'; 'u'; 'u'; 'n'; 'n'; 'u'; 'u'];
modality = ['v'; 'v';'v'; 'v';'a'; 'a'; 'a'; 'a'];

withindesign = array2table([time content modality]);

withindesign.Properties.VariableNames = {'w1', 'w2', 'w3'};

samplesizeindex = 1; 

for sample = 8:30

for run = 1:runs
    
    for meandiff = 1:100

    %create data
     datarun = rand(sample,8); 
     
     datarun(:, [1 2 5 6]) = datarun(:, [1 2 5 6])+meandiff./1000; 
     
     datarun(:, [1:4]) = datarun(:, [1:4]) - meandiff./1000; 
     
     datarun(:, [5:8]) = datarun(:, [5:8]) + meandiff./1000; 
     
     datatable_run = array2table([linspace(1,sample,sample)' datarun]); 
     
     datatable_run.Properties.VariableNames = {'ID', 'y1', 'y2','y3','y4','y5','y6','y7','y8'}; 
     
     R = fitrm(datatable_run, 'y1-y8~1', 'WithinDesign',withindesign);
     
     [TBL,A,C,D] = ranova(R, 'WithinModel', 'w1*w2*w3');
     
    numpartOmega = table2array(TBL(7,'DF')) .*(table2array(TBL(7,'MeanSq'))- table2array(TBL(8,'MeanSq')));
    denompartOmega =  table2array(TBL(7,'SumSq')) + table2array(TBL(8,'SumSq')) + table2array(TBL(2,'SumSq')) + table2array(TBL(2,'MeanSq'));
      
    partOmega(run, meandiff) = numpartOmega./denompartOmega;
    
    partEtasquare(run,  meandiff) =  table2array(TBL(7,'SumSq'))./(table2array(TBL(7,'SumSq'))+table2array(TBL(8,'SumSq')));

    pvalmat(run, meandiff) = table2array(TBL(7,'pValue')); 
     
    end
  
end

 disp(['samplesize: ' num2str(sample)])


% find percentages of detected effects by partial eta square: 
percentdetect = []; 
for eta = 0.01:0.01:0.3
percentdetect = [percentdetect sum(pvalmat(partEtasquare>eta)<0.05)./length(pvalmat(partEtasquare>eta)<0.05)];
end

%summarize information for each sample size

pvalmatout(samplesizeindex, :) = median(pvalmat); 
partOmegaout(samplesizeindex, :) = median(partOmega); 
partEtasquareout(samplesizeindex, :) = median(partEtasquare); 
percentdetectout(samplesizeindex, :) = percentdetect; 

samplesizeindex = samplesizeindex +1; 
end % loop overt sample sizes

figure(5)
title(' percentage of effects detected given eta and sample size')
contourf(eta, sample, percentdetectout, 20),colorbar, xlabel('partial eta square of effect'), ylabel('sample size'), 
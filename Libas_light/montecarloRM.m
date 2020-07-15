function [pvalmat, partOmega, partEtasquare, percentdetect] = montecarloRM(runs)

pvalmat = []; 

expression =  ['h'; 'h'; 'h'; 'n';'n';'n'; 'f'; 'f'; 'f'; 'a'; 'a'; 'a'];
time =  ['b'; 'c'; 'r'; 'b'; 'c'; 'r'; 'b'; 'c'; 'r'; 'b'; 'c'; 'r'];
withindesign = array2table([expression time]);
withindesign.Properties.VariableNames = {'w1', 'w2'};

for run = 1:runs
    
    for meandiff = 1:100

    %create data
     datarun = rand(22,12); 
     datarun(:, [4:6]) = datarun(:, [4:6])+meandiff./250; 
     datarun(:, [11:12]) = datarun(:, [11:12]) - meandiff./250; 
     
     datatable_run = array2table([linspace(1,22,22)' datarun]); 
     datatable_run.Properties.VariableNames = {'ID', 'y1', 'y2','y3','y4','y5','y6','y7','y8','y9','y10','y11','y12'}; 
     
     R = fitrm(datatable_run, 'y1-y12~1', 'WithinDesign',withindesign);
     
     [TBL,A,C,D] = ranova(R, 'WithinModel', 'w1*w2');
     
    numpartOmega = table2array(TBL(7,'DF')) .*(table2array(TBL(7,'MeanSq'))- table2array(TBL(8,'MeanSq')));
    denompartOmega =  table2array(TBL(7,'SumSq')) + table2array(TBL(8,'SumSq')) + table2array(TBL(2,'SumSq')) + table2array(TBL(2,'MeanSq'));
      
    partOmega(run, meandiff) = numpartOmega./denompartOmega;
    
    partEtasquare(run,  meandiff) =  table2array(TBL(7,'SumSq'))./(table2array(TBL(7,'SumSq'))+table2array(TBL(8,'SumSq')));

    pvalmat(run, meandiff) = table2array(TBL(7,'pValue')); 
     
    end
    
    if run/10 == round(run/10), fprintf('.'), end 
    
end


% find percentages of detected effects by partial eta square: 
percentdetect = []; 
for eta = 0.01:0.01:0.3
percentdetect = [percentdetect sum(pvalmat(partEtasquare>eta)<0.05)./length(pvalmat(partEtasquare>eta)<0.05)];
end
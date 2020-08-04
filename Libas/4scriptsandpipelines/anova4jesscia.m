function [pvec, Fvec, partOmega, partEtasquare] = anova4jesscia(data)

datarun = data;

hemi =  ['c'; 'i'; 'c'; 'i'; 'c'; 'i'; 'c'; 'i'];
valence =  ['n'; 'n'; 'u'; 'u'; 'n'; 'n'; 'u'; 'u'];
setsize = ['2'; '2'; '2'; '2';'4'; '4'; '4'; '4'];

withindesign = array2table([hemi valence setsize]);

withindesign.Properties.VariableNames = {'v1', 'v2', 'v3'};


    % datarun = rand(28,8); 
     
    
     datatable_run = array2table([linspace(1,28,28)' datarun]); 
     
     datatable_run.Properties.VariableNames = {'ID', 'y1', 'y2','y3','y4','y5','y6','y7','y8'}; 
     
     R = fitrm(datatable_run, 'y1-y8~1', 'WithinDesign',withindesign);
     
     [TBL,A,C,D] = ranova(R, 'WithinModel', 'v1*v2*v3');
     
    numpartOmega = table2array(TBL(7,'DF')) .*(table2array(TBL(7,'MeanSq'))- table2array(TBL(8,'MeanSq')));
    
    denompartOmega =  table2array(TBL(7,'SumSq')) + table2array(TBL(8,'SumSq')) + table2array(TBL(2,'SumSq')) + table2array(TBL(2,'MeanSq'));
      
    partOmega = numpartOmega./denompartOmega;
    
    partEtasquare =  table2array(TBL(7,'SumSq'))./(table2array(TBL(7,'SumSq'))+table2array(TBL(8,'SumSq')));

    % pvalmat = table2array(TBL(7,'pValue')); this is just the three way  interaction if needed. 
    
    Fvec = table2array(TBL(3:2:end,'F'));
    pvec = table2array(TBL(3:2:end,'pValue'));

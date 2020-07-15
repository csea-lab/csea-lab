function [ tempcorrmat,indexmat ] = etafitRescorla_alexandra(inmat, reinforcemat, windex)
%etafitRescorla_alexandra looks for best fitting eta for a given person,
%given RW model for 82 trials in zuerich aging/rating/conditioning study
% indexmat is max corr, max eta, max Udiff
% needs workspace: workspacemodelfitnov2015.mat


for subject = 1:122, 
   
   udifindex = 1;
    
    for udiff = 0.0:0.025:0.975
        
    firstdimensionvec = zeros(82,1); 
    firstdimensionvec(reinforcemat(:, 2) == 1)=.5;  %CS+
    firstdimensionvec(reinforcemat(:, 2) == -1)=udiff; 

    secdimensionvec = zeros(82,1); 
    secdimensionvec(reinforcemat(:, 2) == 1)=udiff;  
    secdimensionvec(reinforcemat(:, 2) == -1)=.5; %CS-

        
         etaindex = 1;
    
        for eta = 0.01:0.02:1

            % calculate full model (82 trials)
           % w = rescorlaWagnerModelAK([ones(82,1) (reinforcemat(:, 2) == 1)./2], reinforcemat(:, 3), eta);
           w = rescorlaWagnerModelAK([firstdimensionvec secdimensionvec ], (reinforcemat(:, 3)) ./ 2.8, eta);

            % for each stimulus, take only the ones with ratings

            wsub = w(reinforcemat(:, 1) == 1, :);

            % calculate correlation for each stimulus and eta separately and get a
            % vector of correlations
            
            %for estimtaion/expectancy variable: no baseline -> 30 ratings
            [temp1] = corrcoef(wsub(3:32, windex)', inmat(subject,:));

            % for val, aro, motiv, all trials = 32 ...      
            %[temp1] = corrcoef(wsub(:, windex)', inmat(subject,:));
           
            tempcorrmat(subject, etaindex, udifindex) = temp1(1,2); 

            etaindex = etaindex+1; 

        end
        
        udifindex = udifindex+1; 
        
    end
    
    [value,row,column]=max2d(squeeze(tempcorrmat(subject, :, :))); 
    
    
    % artifact handling
    if row == 50 || row == 1
       critvalrows =  (mean(tempcorrmat(subject, :, column)) + max(tempcorrmat(subject, :, column)))./2;
       tempvecrows = find(tempcorrmat(subject, :, column) >= critvalrows);
       index_r = round(length(tempvecrows)./2);
       row_end = tempvecrows(index_r);
    else
        row_end = row;
    end
   
    
    if column == 40 || column == 1 
       critvalcols =  (mean(tempcorrmat(subject, row, :)) + max(tempcorrmat(subject, row, :)))./2;
       tempveccols = find(tempcorrmat(subject, row, :) >= critvalcols);
       index_c = round(length(tempveccols)./2);
       col_end = tempveccols(index_c);
    else
        col_end = column;
    end
    
    indexmat(subject,:) = [value,row_end,col_end];
    
end
    






function [] = modelfit_alpha_bop_Tcourse_perm(appmatfilemat, igfilemat)

OPTIONS = statset('MaxIter', 100000, 'FunValCheck', 'off');

Betamat = []; 

warning('off')

for fileindex = 1:size(igfilemat,1)
    
    % load each person's data
    
        temp1 = load(['/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/appg/rig/' igfilemat(fileindex,:)]);
           
          
        eval(['contingencies = temp1.' igfilemat(fileindex,1:6) ';']); 
        
        contingencies = contingencies(1:end-1); % lose the last trial, to match length
             
        temp2 = load(['/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/Model fitting/time course/' deblank(appmatfilemat(fileindex,:))], '-mat'); 
        
        alpha3d_Welch = temp2.alpha3d_Welch; 
        
     for randomdraw = 1:10
              
        for timepoint = 1: size(alpha3d_Welch,2)
            
            power = []; 
            
              if timepoint/50 == round(timepoint/50), disp(timepoint), end
     
        
            for chan = 1:129
            power(chan,:) = squeeze(alpha3d_Welch(chan,timepoint, :))./(max(squeeze(alpha3d_Welch(chan,timepoint,:))));
            end

            
            % random permutatino occurs here
            power = power(:, randperm(size(power,2)-1)); % lose the first trial
        
        
        % loop over channels
        
        for channel = 1:129            
        
            % NOW FIT MODEL(S)
            % first model

            model = 1; % the orig RW model with intercept

            [BETA,R,J,COVB,MSE(channel,timepoint, randomdraw)] = nlinfit(contingencies,power(channel,:)',@rescorlaWagnerLearnOrigIntcpt, [0.5 0.5 .1], OPTIONS);

            temp = rescorlaWagnerLearnOrigIntcpt([BETA], contingencies);

            RSS = sum(R.^2);

            BICmat(channel, timepoint, randomdraw) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R));

            corrtemp = corrcoef(temp, power(channel,:)); 
            
            corrmat(channel,timepoint, randomdraw) = corrtemp(1,2);
        
        
        end % channels
        
        end % timepoints
        
     end % random draws
        
        eval(['save ' appmatfilemat(fileindex,:) '.corr.perm.mat corrmat -mat'])
        eval(['save ' appmatfilemat(fileindex,:) '.MSE.perm.mat MSE -mat'])  
        eval(['save ' appmatfilemat(fileindex,:) '.BIC.perm.mat BICmat -mat'])
        
end % files

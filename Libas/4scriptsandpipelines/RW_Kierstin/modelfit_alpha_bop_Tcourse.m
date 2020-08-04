function [] = modelfit_alpha_bop_Tcourse(appmatfilemat, igfilemat)
%appmatfilemat = timevarying alpha from /Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/matfiles
    %this folder needs to only contain the alpha files you're working with
%igfilemat = contingencies from trials kept in /Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/appg/rig

OPTIONS = statset('MaxIter', 100000, 'FunValCheck', 'off');
Betamat = []; 

warning('off')

for fileindex = 1:size(igfilemat,1)
   
    alpha_model = []; %%empties matrix

    % load each person's data
    
        temp1 = load([igfilemat(fileindex,:)]);
        
        eval(['contingencies = temp1.' igfilemat(fileindex,1:6) ';']); 
        
        load([appmatfilemat(fileindex,:)]);

        alpha3d_Welch = alphapowertrial; 
        
        for timepoint = 1: size(alpha3d_Welch,2) %used to be (alpha3d_Welch,2)
            
            power = []; 
            
%          if timepoint/50 == round(timepoint/50), disp(timepoint), end
     
        
        for chan = 1:129
        power(chan,:) = squeeze(alpha3d_Welch(chan,timepoint, :))./(max(squeeze(alpha3d_Welch(chan,timepoint,:))));
        end
        
        power = power(:, 2:end); % lose the first trial
        
        
        if timepoint ==1; 
        contingencies = contingencies(1:end-1); % lose the last trial, to match length
        end
        
        % loop over channels
        
        for channel = 1:129            
        
            % NOW FIT MODEL(S)
            % first model

            model = 1; % the orig RW model with intercept

            [BETA,R,J,COVB,MSE(channel,timepoint)] = nlinfit(contingencies,power(channel,:)',@rescorlaWagnerLearnOrigIntcpt, [0.5 0.5 .1], OPTIONS);

            temp = rescorlaWagnerLearnOrigIntcpt([BETA], contingencies);

            RSS = sum(R.^2);

            BICmat(channel, timepoint) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R));

            ChiSquaremat(channel, timepoint) = sum((R./std(power(channel,:))).^2);

            Betamat(channel,timepoint) = BETA(1); % just the learning rate

            corrtemp = corrcoef(temp, power(channel,:)); corrmat(channel,timepoint) = corrtemp(1,2);

            Bayescorrtemp = bf.corr(temp, power(channel,:)'); 

%             l = log(Bayescorrtemp);

            Bayescorrmat(channel, timepoint) = Bayescorrtemp(1,1);


    %         if channel == 62 
    %         figure(1)
    %         subplot(4,1,1), plot(temp)
    %         hold on 
    %         plot(power(62,:), 'r')
    %         end

        alpha_model(channel, timepoint, :) = temp; %%puts model alpha in matrix
        
        end % channels
        end % timepoints
        
              disp(fileindex) 
        save([appmatfilemat(fileindex,1:end-4) '.Tmodel.mat'], 'alpha_model', '-mat');%%saves modeled alpha per participant
         SaveAvgFile([appmatfilemat(fileindex,:) '.at.Tcorrmat'], corrmat)
         SaveAvgFile([appmatfilemat(fileindex,:) '.at.TBayescorrmat'], Bayescorrmat)
         SaveAvgFile([appmatfilemat(fileindex,:) '.at.Tbetamat'], Betamat)
         SaveAvgFile([appmatfilemat(fileindex,:) '.at.TMSE'], MSE)
%         SaveAvgFile([appmatfilemat(fileindex,:) '.at.TBIC'], BICmat)
        
end % files

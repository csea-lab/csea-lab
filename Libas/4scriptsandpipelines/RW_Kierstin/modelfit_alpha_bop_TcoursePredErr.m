function [] = modelfit_alpha_bop_TcoursePredErr(appmatfilemat, igfilemat)

OPTIONS = statset('MaxIter', 100000, 'FunValCheck', 'off');

Betamat = []; 

warning('off')

for fileindex = 1:size(igfilemat,1)
    delta_model = []
    % load each person's data
    
        temp1 = load(['/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/appg/rig/' igfilemat(fileindex,:)]);
        
        eval(['contingencies = temp1.' igfilemat(fileindex,1:6) ';']); 
        
        temp2 = load(['/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/matfiles/' appmatfilemat(fileindex,:)]);
        
        % create the power for each trial and time point
        
        mat3d = temp2.outmat; 
        
        % call other function that gives us time varying alpha
        
        [alpha3d_Welch] = FFT_spectrum3D_singtrialWelchTime(mat3d, 500);
        
        eval(['save ' appmatfilemat(fileindex,:) '.alpha3d alpha3d_Welch -mat'])
        
        
        for timepoint = 1: size(alpha3d_Welch,2)
            
            power = []; 
            
         if timepoint/50 == round(timepoint/50), disp(timepoint), end
     
        
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

            [BETA,R,J,COVB,MSE(channel,timepoint)] = nlinfit(contingencies,power(channel,:)',@rescorlaWagnerLearnOrigIntcptDelta, [0.5 0.5 .1], OPTIONS);

            temp = rescorlaWagnerLearnOrigIntcptDelta([BETA], contingencies);

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

         delta_model(channel, timepoint, :) = temp;
        
        end % channels
        
        end % timepoints
        save([appmatfilemat(fileindex,1:end-4) '.TDmodel.mat'], 'delta_model', '-mat');
        SaveAvgFile([appmatfilemat(fileindex,:) '.at.TcorrmatPE'], corrmat)
        SaveAvgFile([appmatfilemat(fileindex,:) '.at.TBayescorrmatPE'], Bayescorrmat)
        SaveAvgFile([appmatfilemat(fileindex,:) '.at.TbetamatPE'], Betamat)
        SaveAvgFile([appmatfilemat(fileindex,:) '.at.TMSEPE'], MSE)
        SaveAvgFile([appmatfilemat(fileindex,:) '.at.TBICPE'], BICmat)
        disp(fileindex) 
end % files

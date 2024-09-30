function [temp] = modelfit_alpha_bop_negat(alphafilemat, igfilemat, conmat, time)

Betamat = []; 
warning('off')

for fileindex = 1:size(igfilemat,1)
    % load each person's data
        pred_mat = [];
        
        temp1 = load(igfilemat(fileindex,:));
        
        goodvec = temp1.goodindex;
        
        alpha = load(alphafilemat(fileindex,:));
        power = alpha.alphapowertrial;        
        power = squeeze(mean(power(:, time, :), 2)); %makes the data the mean of the time window you want to model

        for chan = 1:129
        power(chan,:) = power(chan,:)./(max(power(chan,:)));
        end
        
        contingencies = conmat(fileindex,goodvec)';
        
%         
        
        % loop over channels
        
for channel = 1:129
        % first model
        
        model = 1; % 

        [BETA,R,J,COVB,MSE(channel,model)] = nlinfit(contingencies,power(channel,:)',@rescorlaWagnerLearnOrigIntcpt, [0.5 0.5 0.1]);

        temp = rescorlaWagnerLearnOrigIntcpt([BETA], contingencies);
        temp(1)= 0.5;

        RSS = sum(R.^2);

        BICmat(channel, model) = length(R) .* log(RSS./length(R)) + (length(BETA)-1)* log(length(R));

        ChiSquaremat(channel, model) = sum((R./std(power(channel,:))).^2);
        
        Betamat(channel,model*2-1:model*2) = BETA(1:2); 
        
        corrtemp = corrcoef(temp, power(channel,:)); 
        corrmat(channel,model) = corrtemp(1,2);
        
        Bayescorrtemp = bf.corr(temp, power(channel,:)'); 
                
        Bayescorrmat(channel, model) = Bayescorrtemp(1,1);
        
        pred_mat(channel,:,model) = temp;

        if channel == 62 
        figure
        subplot(1,2,1), plot(power(62,:), 'r')
        hold on 
        subplot(1,2,1), plot(temp)
        title({fileindex; corrmat(channel,model)})
        pause(0.5)
        hold off
        end
        


% gambler's fallacy
        model = 2; % 

        [BETA,R,J,COVB,MSE(channel,model)] = nlinfit(contingencies,power(channel,:)',@gamblersf, [0.5 0.5 0.1]);

        temp = gamblersf([BETA], contingencies);
        temp(1)= 0.5;

        RSS = sum(R.^2);

        BICmat(channel, model) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R));

        ChiSquaremat(channel, model) = sum((R./std(power(channel,:))).^2);
        
        Betamat(channel,model*2-1:model*2) = BETA(1:2); 
        
        corrtemp = corrcoef(temp, power(channel,:)); 
        corrmat(channel,model) = corrtemp(1,2);
        
        Bayescorrtemp = bf.corr(temp, power(channel,:)'); 
                
        Bayescorrmat(channel, model) = Bayescorrtemp(1,1);
        
        pred_mat(channel,:,model) = temp;
        
        if channel == 62 
        subplot(1,2,2), plot(power(62,:), 'r')
        hold on 
        subplot(1,2,2), plot(temp)
        title({fileindex; corrmat(channel,model)})
        pause(0.5)
        hold off
        end % channels
%         
%         eval(['save ' alphafilemat(fileindex,1:end-4) '.latemodel.mat pred_mat -mat']);
%         SaveAvgFile([alphafilemat(fileindex,1:end-4) '.late.at.corrmat'], corrmat)
%         SaveAvgFile([alphafilemat(fileindex,1:end-4) '.late.at.Bayescorrmat'], Bayescorrmat)
%         SaveAvgFile([alphafilemat(fileindex,1:end-4) '.late.at.betamat'], Betamat)
%         SaveAvgFile([alphafilemat(fileindex,1:end-4) '.late.at.MSE'], MSE)
%         SaveAvgFile([alphafilemat(fileindex,1:end-4) '.late.at.BIC'], BICmat)
%         disp(fileindex) 
        
end % files
%         close all
end



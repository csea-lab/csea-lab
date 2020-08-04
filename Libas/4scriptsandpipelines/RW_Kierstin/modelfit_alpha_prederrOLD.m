function [corrmat] = modelfit_alpha_prederr(alphafilemat, igfilemat)


Betamat = []; 

% for fileindex = 1:size(igfilemat,1);
%     
%     % load each person's data
%     
%         temp1 = load(['/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/appg/rig/' igfilemat(fileindex,:)]);
%         eval(['contingencies = temp1.' igfilemat(fileindex,1:6) ';']); 
%         
%         alpha = load(alphafilemat(fileindex,:));
%         power = alpha.outmat;
%         power = power./(max(max(power)));
%         
%         % loop over channels
%         
%         for channel = 1:129 
%             model = 1; % the orig RW model with intercept
% 
%         [BETA,R,J,COVB,MSE(channel,model)] = nlinfit(contingencies,power(channel,:)',@rescorlaWagnerLearnOrigIntcptDelta, [0.5 0.5 .1]);
% 
%         temp = rescorlaWagnerLearnOrigIntcptDelta([BETA], contingencies);
% 
%         RSS = sum(R.^2);
% 
%         BICmat(channel, model) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R));
% 
%         ChiSquaremat(channel, model) = sum((R./std(power(channel,:))).^2);
%         
%         Betamat(channel,model*2-1:model*2) = BETA(1:2); 
%         
%         corrtemp = corrcoef(temp, power(channel,:)); corrmat(channel,model) = corrtemp(1,2);
% 
% %         if channel == 62 
% %         figure(1)
% %         subplot(2,1,1), plot(temp)
% %         hold on 
% %         plot(power(62,:), 'r')
% %         end
%         end
% end
       
        
for fileindex = 1:size(igfilemat,1)
        delta_model = [];
        temp1 = load(['/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/appg/rig/' igfilemat(fileindex,:)]);
        eval(['contingencies = temp1.' igfilemat(fileindex,1:6) ';']); 
        alpha = load(alphafilemat(fileindex,:));
        power = alpha.outmat;
        
        for chan = 1:129
        power(chan,:) = power(chan,:)./(max(power(chan,:)));
        end
        
        power = power(:, 2:end); % lose the first trial
        contingencies = contingencies(1:end-1); % lose the last trial, to match length
        
        % loop over channels
        
        for channel = 1:129
        
         model = 2; % the orig RW model with intercept shifted

        [BETA,R,J,COVB,MSE(channel,model)] = nlinfit(contingencies,power(channel,:)',@rescorlaWagnerLearnOrigIntcptDelta, [0.5 0.5 .1]);

        temp = rescorlaWagnerLearnOrigIntcptDelta([BETA], contingencies);

        RSS = sum(R.^2);

        BICmat(channel, model) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R));

        ChiSquaremat(channel, model) = sum((R./std(power(channel,:))).^2);
        
        Betamat(channel,model*2-1:model*2) = BETA(1:2); 
        
        corrtemp = corrcoef(temp(30:end), power(channel,30:end)); corrmat(channel,model) = corrtemp(1,2);
        
        Bayescorrtemp = bf.corr(temp, power(channel,:)'); 
        
%         l = log(Bayescorrtemp);
        
        Bayescorrmat(channel, model) = Bayescorrtemp(1,1);
       alpha_model(channel, :) = temp;
        end %channels
       
       save([appmatfilemat(fileindex,1:end-4) '.Dmodel.mat'], 'delta_model', '-mat');

%         SaveAvgFile([alphafilemat(fileindex,:) '.at.DBayescorrmatPEL'], Bayescorrmat)
       SaveAvgFile([alphafilemat(fileindex,:) '.at.Dbetamat'], Betamat)
       SaveAvgFile([alphafilemat(fileindex,:) '.DcorrmatPE'], corrmat)
end      
end
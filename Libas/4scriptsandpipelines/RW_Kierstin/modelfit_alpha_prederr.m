function [corrmat] = modelfit_alpha_prederr(alphafilemat, igfilemat, timevec)
%alpha files should be the ones with channel and trial info, but collapsed
%over pre-determined time period
%in this case, for modeling prediction error, we will need to load files
%that are the alpha blocking between anticipation and cue onset for that
%trial

%igfilemat is the contingencies 

Betamat = []; 


        
for fileindex = 1:size(igfilemat,1)
        delta_model = [];
        temp1 = load(['/Users/kierstin_riels/Desktop/Experiments/BOP/Alpha things/appg/rig/' igfilemat(fileindex,:)]);
        eval(['contingencies = temp1.' igfilemat(fileindex,1:6) ';']); 
        struct = load(alphafilemat(fileindex,:));
        alpha = struct.alpha3d_Welch;
        power = bslcorrTrial(alpha, [701:1101]);
        power = squeeze(mean(power(:, timevec, :),2));
        
        for chan = 1:129
        power(chan,:) = power(chan,:)./(max(power(chan,:)));
        end
        
        power = power(:, 2:end); % lose the first trial %sidenote. we lose the first alpha trial because there was no rating or cue before it
        contingencies = contingencies(1:end-1); % lose the last trial, to match length
        
        % loop over channels
        
        for channel = 1:129
        
          % the orig RW model with intercept shifted pred err

        [BETA,R,J,COVB,MSE(channel)] = nlinfit(contingencies,power(channel,:)',@rescorlaWagnerLearnOrigIntcptDelta, [0.5 0.5 .1]);

        temp = rescorlaWagnerLearnOrigIntcptDelta([BETA], contingencies);

        RSS = sum(R.^2);

        BICmat(channel) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R));

        ChiSquaremat(channel) = sum((R./std(power(channel,:))).^2);
        
        %Betamat(channel) = BETA(1:2); 
        
        corrtemp = corrcoef(temp(30:end), power(channel,30:end)); corrmat(channel) = corrtemp(1,2);
        
        Bayescorrtemp = bf.corr(temp, power(channel,:)'); 
        
%         l = log(Bayescorrtemp);
        
       Bayescorrmat(channel) = Bayescorrtemp(1,1);
       delta_model(channel, :) = temp;
        end %channels
       
       save([alphafilemat(fileindex,1:end-4) '.Dmodel.mat'], 'delta_model', '-mat');
%         SaveAvgFile([alphafilemat(fileindex,:) '.at.DBayescorrmatPEL'], Bayescorrmat)
       SaveAvgFile([alphafilemat(fileindex,:) '.at.Dbetamat'], Betamat)
       SaveAvgFile([alphafilemat(fileindex,:) '.DcorrmatPE'], corrmat)
end  %files    
end
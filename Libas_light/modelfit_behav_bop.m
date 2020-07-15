function [] = modelfit_behav_bop(filemat)


Betamat = []; 

for fileindex = 1:size(filemat,1)
    
    % load each person's data
    
        a = load(filemat(fileindex,:));

        contingencies = a(:,3);
        ratings = a(:,4);
        
        
        % NOW FIT A WHOLE BUNCH IF MODELS
        % first model
        model = 1; % the orig RW model with NO intercept

        [BETA,R,J,COVB,MSE(fileindex,model)] = nlinfit(contingencies,ratings./max(ratings),@rescorlaWagnerLearnOrig, [0.5 0.5]);

        temp = rescorlaWagnerLearnOrig([BETA], contingencies);

        RSS = sum(R.^2);

        BICmat(fileindex, model) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R))

        ChiSquaremat(fileindex, model) = sum((R./std(ratings)).^2)
        
        Betamat(fileindex,model*2-1:model*2) = BETA(1:2); 
        
        corrtemp = corrcoef(temp, ratings./max(ratings)); corrmat(fileindex,model) = corrtemp(1,2)

        figure(1)
        subplot(5,1,1), plot(temp)
        hold on 
        plot(ratings./max(ratings), 'r')

        
         % second model
        model = 2; % the orig RW model with intercept

        [BETA,R,J,COVB,MSE(fileindex,model)] = nlinfit(contingencies,ratings./max(ratings),@rescorlaWagnerLearnOrigIntcpt, [0.5 0.5 .1]);

        temp = rescorlaWagnerLearnOrigIntcpt([BETA], contingencies);

        RSS = sum(R.^2);

        BICmat(fileindex, model) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R))

        ChiSquaremat(fileindex, model) = sum((R./std(ratings)).^2)
        
        Betamat(fileindex,model*2-1:model*2) = BETA(1:2); 
        
        corrtemp = corrcoef(temp, ratings./max(ratings)); corrmat(fileindex,model) = corrtemp(1,2)

        figure(1)
        subplot(5,1,2), plot(temp)
        hold on 
        plot(ratings./max(ratings), 'r')
      
        
        
         % third model
        model = 3; % the modified RW model with no intercept

        [BETA,R,J,COVB,MSE(fileindex,model)] = nlinfit(contingencies,ratings./max(ratings),@rescorlaWagnerLearnMod, [0.5 0.5]);

        temp = rescorlaWagnerLearnMod([BETA], contingencies);

        RSS = sum(R.^2);

        BICmat(fileindex, model) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R))

        ChiSquaremat(fileindex, model) = sum((R./std(ratings)).^2)
        
        Betamat(fileindex,model*2-1:model*2) = BETA(1:2); 
        
        corrtemp = corrcoef(temp, ratings./max(ratings)); corrmat(fileindex,model) = corrtemp(1,2)

        figure(1)
        subplot(5,1,3), plot(temp)
        hold on 
        plot(ratings./max(ratings), 'r')
   
        
        
         % fourth model
        model = 4; % the mod PH model with no intercept

        [BETA,R,J,COVB,MSE(fileindex,model)] = nlinfit(contingencies,ratings./max(ratings),@PearceHallMod, [0.5 0.5]);

        temp = PearceHallMod([BETA], contingencies);

        RSS = sum(R.^2);

        BICmat(fileindex, model) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R))

        ChiSquaremat(fileindex, model) = sum((R./std(ratings)).^2)
        
        Betamat(fileindex,model*2-1:model*2) = BETA(1:2); 
        
        corrtemp = corrcoef(temp, ratings./max(ratings)); corrmat(fileindex,model) = corrtemp(1,2)

        figure(1)
        subplot(5,1,4), plot(temp)
        hold on 
        plot(ratings./max(ratings), 'r')

        
         % fifth model
        model = 5; % the mod PH model with intercept

        [BETA,R,J,COVB,MSE(fileindex,model)] = nlinfit(contingencies,ratings./max(ratings),@PearceHallModIntcpt, [0.5 0.5 .1]);

        temp = PearceHallModIntcpt([BETA], contingencies);

        RSS = sum(R.^2);

        BICmat(fileindex, model) = length(R) .* log(RSS./length(R)) + length(BETA)* log(length(R))

        ChiSquaremat(fileindex, model) = sum((R./std(ratings)).^2)
        
        Betamat(fileindex,model*2-1:model*2) = BETA(1:2)
        
        corrtemp = corrcoef(temp, ratings./max(ratings)); corrmat(fileindex,model) = corrtemp(1,2)

        figure(1) 
        subplot(5,1,5), plot(temp)
        hold on 
        plot(ratings./max(ratings), 'r')
        pause
        close('all')
end
